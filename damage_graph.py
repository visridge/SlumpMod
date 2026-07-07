"""
Damage Graph Generator for BangMod (Chivalry: Medieval Warfare)
Calculates effective torso-hit damage for each weapon vs each class.
Formula: EffectiveDamage = fBaseDamage * sum(DamageType[i] * DamageResistances[i])
         Torso LocationModifier = 1.0 for melee, so it cancels out.
"""
import os
import re
import matplotlib.pyplot as plt
import matplotlib
import numpy as np

matplotlib.use('Agg')

# Damage Type Compositions (EDMG_Swing, EDMG_Pierce, EDMG_Blunt, EDMG_Generic)
DAMAGE_TYPES = {
    "AOCDmgType_Swing":       [1.0, 0.0, 0.0, 0.0],
    "AOCDmgType_Pierce":      [0.0, 1.0, 0.0, 0.0],
    "AOCDmgType_Blunt":       [0.0, 0.0, 1.0, 0.0],
    "AOCDmgType_SwingBlunt":  [0.5, 0.0, 0.5, 0.0],
    "AOCDmgType_PierceBlunt": [0.0, 0.5, 0.5, 0.0],
    "AOCDmgType_Generic":     [0.0, 0.0, 0.0, 1.0],
    "AOCDmgType_Shove":       [0.0, 0.0, 0.0, 1.0],
}

# Class Damage Resistances (multiplier - LOWER = more resistant)
CLASSES = {
    "Archer":    {"Swing": 0.85, "Pierce": 0.85, "Blunt": 0.65},
    "Knight":    {"Swing": 0.40, "Pierce": 0.50, "Blunt": 0.61},
    "ManAtArms": {"Swing": 0.80, "Pierce": 0.85, "Blunt": 0.65},
    "Vanguard":  {"Swing": 0.60, "Pierce": 0.80, "Blunt": 0.70},
}

# Color schemes for classes
CLASS_COLORS = {
    "Archer":    "#4CAF50",
    "Knight":    "#F44336",
    "ManAtArms": "#2196F3",
    "Vanguard":  "#FF9800",
}

def calc_resistance(dmg_type_name, class_name):
    """Calculate effective resistance multiplier for a damage type vs a class."""
    dmg_composition = DAMAGE_TYPES.get(dmg_type_name, [0, 0, 0, 1.0])
    res = CLASSES[class_name]
    # sum(DamageType[i] * DamageResistances[i])
    resistance = (dmg_composition[0] * res["Swing"] +
                  dmg_composition[1] * res["Pierce"] +
                  dmg_composition[2] * res["Blunt"] +
                  dmg_composition[3] * 1.0)  # Generic = 1.0 multiplier
    return resistance

def calc_effective_damage(base_damage, dmg_type_name, class_name):
    """Calculate effective torso damage."""
    if dmg_type_name in ("AOCDmgType_Shove", "AOCDmgType_Generic"):
        return 0  # Shove/Generic damage doesn't use the normal formula
    return base_damage * calc_resistance(dmg_type_name, class_name)

def parse_weapon_files(base_dir):
    """Parse all weapon attachment files and extract damage data."""
    weapons = {}
    
    attach_dir = os.path.join(base_dir, "Classes")
    pattern = re.compile(r'BangModWeaponAttachment_(\w+)\.uc')
    
    for fname in sorted(os.listdir(attach_dir)):
        m = pattern.match(fname)
        if not m:
            continue
        weapon_name = m.group(1)
        
        filepath = os.path.join(attach_dir, fname)
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
        
        # Parse AttackTypeInfo entries
        # AttackTypeInfo(n)=(fBaseDamage=X, ... cDamageType="AOC.AOCDmgType_YYY", ...)
        atk_pattern = re.compile(
            r'AttackTypeInfo\((\d+)\)=\(fBaseDamage=([\d.]+).*?cDamageType="([^"]+)"',
            re.DOTALL
        )
        
        attacks = {}
        for match in atk_pattern.finditer(content):
            idx = int(match.group(1))
            dmg = float(match.group(2))
            dmg_type = match.group(3).split('.')[-1]  # Extract just "AOCDmgType_Swing"
            attacks[idx] = (dmg, dmg_type)
        
        if attacks:
            weapons[weapon_name] = attacks
    
    return weapons

def main():
    base_dir = r"c:\Program Files (x86)\Steam\steamapps\common\chivalrymedievalwarfare\Development\Src\BangMod"
    
    weapons = parse_weapon_files(base_dir)
    
    # Attack type labels
    atk_labels = {0: "Slash", 1: "Alt-Slash", 2: "Stab", 3: "Sprint", 4: "ParryRiposte"}
    
    # Build data for all non-trivial attacks (ignore Shove at index 5, and 0-damage)
    data = []
    for wname, attacks in sorted(weapons.items()):
        for idx, (dmg, dtype) in attacks.items():
            if dmg <= 0 or dtype in ("AOCDmgType_Shove", "AOCDmgType_Generic"):
                continue
            if idx > 2:  # Only show Slash, Alt-Slash, Stab (main attack types)
                continue
            for cls_name in CLASSES:
                eff = calc_effective_damage(dmg, dtype, cls_name)
                label = f"{wname}\n{atk_labels.get(idx, idx)}"
                data.append((label, cls_name, eff, dmg, dtype))
    
    # ==========================================
    # Graph 1: Grouped bar chart - All Weapons
    # ==========================================
    # This gets very large. Let's create a heatmap instead for the first graph.
    
    # Build matrix for heatmap
    unique_weapons = sorted(set(d[0] for d in data))
    class_names = list(CLASSES.keys())
    
    matrix = np.zeros((len(unique_weapons), len(class_names)))
    
    for d in data:
        wi = unique_weapons.index(d[0])
        ci = class_names.index(d[1])
        # Take max damage among attack types for each weapon+class combo
        if d[2] > matrix[wi, ci]:
            matrix[wi, ci] = d[2]
    
    # Create heatmap
    fig, ax = plt.subplots(figsize=(14, max(10, len(unique_weapons) * 0.35)))
    
    im = ax.imshow(matrix, cmap='RdYlGn', aspect='auto', vmin=0, vmax=120)
    
    ax.set_xticks(range(len(class_names)))
    ax.set_xticklabels(class_names, fontsize=11, fontweight='bold')
    ax.set_yticks(range(len(unique_weapons)))
    ax.set_yticklabels(unique_weapons, fontsize=8)
    
    # Add text annotations
    for i in range(len(unique_weapons)):
        for j in range(len(class_names)):
            val = matrix[i, j]
            color = 'white' if val < 40 else 'black'
            ax.text(j, i, f'{val:.0f}', ha='center', va='center',
                    fontsize=7, fontweight='bold', color=color)
    
    ax.set_title('Effective Torso Damage (Max of Slash/Alt-Slash/Stab)\nBangMod Weapons vs Class Damage Resistances',
                 fontsize=14, fontweight='bold', pad=10)
    
    plt.colorbar(im, ax=ax, label='Effective Damage')
    plt.tight_layout()
    plt.savefig(os.path.join(base_dir, 'damage_heatmap.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved damage_heatmap.png")
    
    # ==========================================
    # Graph 2: Top weapons grouped bar chart
    # ==========================================
    # Select a good subset of weapons for readability
    key_weapons = [
        "Longsword", "Greatsword", "Zweihander", "Claymore", "Nodachi",
        "Messer", "SwordOfWar", "BastardSword", "Broadsword", "NorseSword",
        "Falchion", "Saber", "Katana",
        "Maul", "GrandMace", "WarHammer", "Mace", "MorningStar", "HolyWaterSprinkler",
        "DoubleAxe", "PoleAxe", "Bearded", "Bardiche", "Halberd", "Bill",
        "Dane", "WarAxe", "Hatchet",
        "Spear", "Brandistock",
        "QuarterStaff", "Cudgel"
    ]
    
    # Filter to available weapons
    avail = [w for w in key_weapons if w in weapons]
    
    # Get max effective damage for each weapon vs each class
    plot_data = {cls: [] for cls in CLASSES}
    labels = []
    
    for wname in avail:
        attacks = weapons[wname]
        labels.append(wname)
        for cls_name in CLASSES:
            max_eff = 0
            for idx, (dmg, dtype) in attacks.items():
                if dmg <= 0 or dtype in ("AOCDmgType_Shove", "AOCDmgType_Generic"):
                    continue
                if idx > 2:
                    continue
                eff = calc_effective_damage(dmg, dtype, cls_name)
                if eff > max_eff:
                    max_eff = eff
            plot_data[cls_name].append(max_eff)
    
    x = np.arange(len(labels))
    width = 0.2
    multiplier = 0
    
    fig, ax = plt.subplots(figsize=(20, 8))
    
    for cls_name, color in CLASS_COLORS.items():
        offset = width * multiplier
        rects = ax.bar(x + offset, plot_data[cls_name], width, label=cls_name,
                       color=color, alpha=0.85, edgecolor='black', linewidth=0.5)
        # Add value labels on bars
        for rect, val in zip(rects, plot_data[cls_name]):
            if val > 5:
                ax.text(rect.get_x() + rect.get_width()/2., rect.get_height() + 0.5,
                        f'{val:.0f}', ha='center', va='bottom', fontsize=6, fontweight='bold')
        multiplier += 1
    
    ax.set_ylabel('Effective Torso Damage', fontsize=12, fontweight='bold')
    ax.set_title('Effective Torso Damage by Weapon & Class (Max of Main Attacks)\nBangMod', 
                 fontsize=14, fontweight='bold')
    ax.set_xticks(x + width * 1.5)
    ax.set_xticklabels(labels, rotation=45, ha='right', fontsize=8)
    ax.legend(loc='upper right', fontsize=10)
    ax.set_ylim(0, max(max(v) for v in plot_data.values()) * 1.15)
    ax.grid(axis='y', alpha=0.3)
    
    plt.tight_layout()
    plt.savefig(os.path.join(base_dir, 'damage_grouped_bar.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved damage_grouped_bar.png")
    
    # ==========================================
    # Graph 3: Detailed per-attack-type comparison
    # ==========================================
    # For top weapons, show slash/alt-slash/stab separately
    top_weapons = ["Longsword", "Maul", "Greatsword", "Messer", "DoubleAxe",
                   "PoleAxe", "Broadsword", "Mace", "Dane", "Spear"]
    avail_top = [w for w in top_weapons if w in weapons]
    
    atk_names = {0: "Slash", 1: "Alt-Slash", 2: "Stab"}
    
    fig, axes = plt.subplots(len(CLASSES), 1, figsize=(16, 4 * len(CLASSES)), sharex=False)
    
    for cls_idx, (cls_name, color) in enumerate(CLASS_COLORS.items()):
        ax = axes[cls_idx]
        all_labels = []
        all_values = []
        all_colors = []
        
        for wname in avail_top:
            attacks = weapons[wname]
            for idx in [0, 1, 2]:
                if idx in attacks:
                    dmg, dtype = attacks[idx]
                    if dmg > 0 and dtype not in ("AOCDmgType_Shove", "AOCDmgType_Generic"):
                        eff = calc_effective_damage(dmg, dtype, cls_name)
                        all_labels.append(f"{wname}\n{atk_names[idx]}")
                        all_values.append(eff)
                        # Color by damage type
                        if "SwingBlunt" in dtype:
                            all_colors.append('#FF7043')
                        elif "PierceBlunt" in dtype:
                            all_colors.append('#AB47BC')
                        elif "Blunt" in dtype:
                            all_colors.append('#42A5F5')
                        elif "Pierce" in dtype:
                            all_colors.append('#66BB6A')
                        elif "Swing" in dtype:
                            all_colors.append('#EF5350')
                        else:
                            all_colors.append('#BDBDBD')
        
        bars = ax.bar(range(len(all_labels)), all_values, color=all_colors, edgecolor='black', linewidth=0.5)
        ax.set_xticks(range(len(all_labels)))
        ax.set_xticklabels(all_labels, rotation=45, ha='right', fontsize=7)
        ax.set_ylabel('Effective Damage', fontsize=11, fontweight='bold')
        ax.set_title(f'vs {cls_name} (Swing:{CLASSES[cls_name]["Swing"]} Pierce:{CLASSES[cls_name]["Pierce"]} Blunt:{CLASSES[cls_name]["Blunt"]})',
                    fontsize=12, fontweight='bold', color=color)
        ax.set_ylim(0, 140)
        ax.grid(axis='y', alpha=0.3)
        
        # Add value labels
        for bar, val in zip(bars, all_values):
            ax.text(bar.get_x() + bar.get_width()/2., bar.get_height() + 0.5,
                   f'{val:.0f}', ha='center', va='bottom', fontsize=6, fontweight='bold')
    
    # Legend for damage types
    from matplotlib.patches import Patch
    legend_elements = [
        Patch(facecolor='#EF5350', label='Swing'),
        Patch(facecolor='#66BB6A', label='Pierce'),
        Patch(facecolor='#42A5F5', label='Blunt'),
        Patch(facecolor='#FF7043', label='SwingBlunt'),
        Patch(facecolor='#AB47BC', label='PierceBlunt'),
    ]
    fig.legend(handles=legend_elements, loc='upper right', fontsize=9, title='Damage Type')
    
    plt.tight_layout()
    plt.savefig(os.path.join(base_dir, 'damage_per_attack.png'), dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved damage_per_attack.png")
    
    # Print summary table
    print("\n\n=== EFFECTIVE TORSO DAMAGE SUMMARY (Max of Slash/Alt-Slash/Stab) ===")
    print(f"{'Weapon':<25}", end="")
    for cls in CLASSES:
        print(f"{cls:>12}", end="")
    print()
    print("-" * (25 + 12 * len(CLASSES)))
    
    for wname in sorted(weapons.keys()):
        attacks = weapons[wname]
        print(f"{wname:<25}", end="")
        for cls_name in CLASSES:
            max_eff = 0
            for idx, (dmg, dtype) in attacks.items():
                if dmg <= 0 or dtype in ("AOCDmgType_Shove", "AOCDmgType_Generic"):
                    continue
                if idx > 2:
                    continue
                eff = calc_effective_damage(dmg, dtype, cls_name)
                if eff > max_eff:
                    max_eff = eff
            print(f"{max_eff:>12.1f}", end="")
        print()

if __name__ == "__main__":
    main()
