"""
Damage Graph Generator for BangMod (Chivalry: Medieval Warfare)
Calculates effective damage for each weapon vs each class at 3 hit locations.
Formula: EffectiveDamage = fBaseDamage * sum(DamageType[i] * DamageResistances[i]) * LocationModifier
         Melee LocationModifiers: Head=1.25, Torso=1.0, Legs=0.8
"""
import os
import re

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

# Melee Hit Location Modifiers (from AOCFamilyInfo.uc)
# Head=1.25, Torso=1.0, Legs=0.8 (Arm also 1.0 but we skip it)
LOCATION_MODIFIERS = {
    "Head":  1.25,
    "Torso": 1.0,
    "Legs":  0.8,
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

def calc_effective_damage(base_damage, dmg_type_name, class_name, location='Torso'):
    """Calculate effective damage at a given hit location."""
    if dmg_type_name in ("AOCDmgType_Shove", "AOCDmgType_Generic"):
        return 0  # Shove/Generic damage doesn't use the normal formula
    return round(base_damage * calc_resistance(dmg_type_name, class_name) * LOCATION_MODIFIERS[location])

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


def generate_html(weapons, output_path):
    """Generate a self-contained HTML file with 3 hit-location charts per weapon."""
    
    # Build JavaScript weapon data
    js_weapons = {}
    for wname, attacks in sorted(weapons.items()):
        js_attacks = {}
        for idx, (dmg, dtype) in attacks.items():
            if dmg <= 0 or dtype in ("AOCDmgType_Shove", "AOCDmgType_Generic"):
                continue
            if idx > 2:  # LMB, OH, Stab only
                continue
            short_type = dtype.replace("AOCDmgType_", "")
            js_attacks[str(idx)] = [int(dmg), short_type]
        if js_attacks:
            js_weapons[wname] = js_attacks
    
    # Build class JS arrays
    class_js = []
    for cls_name, res in CLASSES.items():
        class_js.append({
            "n": cls_name,
            "r": [res["Swing"], res["Pierce"], res["Blunt"]],
            "color": "rgba(63,185,80,0.85)" if cls_name == "Archer" else
                     "rgba(248,81,73,0.85)" if cls_name == "Knight" else
                     "rgba(88,166,255,0.85)" if cls_name == "ManAtArms" else
                     "rgba(210,168,0,0.85)",
            "hex": "#3fb950" if cls_name == "Archer" else
                   "#f85149" if cls_name == "Knight" else
                   "#58a6ff" if cls_name == "ManAtArms" else
                   "#d2a800"
        })
    
    import json
    weapons_json = json.dumps(js_weapons, indent=2)
    classes_json = json.dumps(class_js, indent=2)
    loc_mod_json = json.dumps(LOCATION_MODIFIERS)
    
    html = f'''<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>BangMod Damage — Head / Torso / Legs per Weapon</title>
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<style>
* {{ box-sizing: border-box; }}
body {{ font-family: 'Segoe UI', Arial, sans-serif; background: #0d1117; color: #c9d1d9; padding: 20px; }}
h1 {{ text-align: center; color: #58a6ff; font-size: 24px; margin: 0 0 6px; }}
.subtitle {{ text-align: center; color: #8b949e; font-size: 13px; margin-bottom: 20px; }}
.info {{ background: #161b22; border: 1px solid #30363d; border-radius: 8px; padding: 14px 18px; margin-bottom: 24px; font-size: 13px; line-height: 1.8; max-width: 900px; margin-left: auto; margin-right: auto; }}
.info b {{ color: #58a6ff; }}
.info code {{ background: #21262d; padding: 1px 5px; border-radius: 3px; color: #f0883e; }}
.weapon-grid {{ display: grid; grid-template-columns: 1fr; gap: 20px; max-width: 900px; margin: 0 auto; }}
.per-weapon {{ background: #161b22; border: 1px solid #30363d; border-radius: 10px; padding: 18px; }}
.per-weapon h3 {{ color: #f0883e; font-size: 15px; margin: 0 0 4px; }}
.location-row {{ display: grid; grid-template-columns: 1fr; gap: 12px; margin-top: 8px; }}
.location-card {{ background: #0d1117; border: 1px solid #21262d; border-radius: 6px; padding: 10px; }}
.location-card h4 {{ color: #8b949e; font-size: 12px; margin: 0 0 6px; text-align: center; text-transform: uppercase; letter-spacing: 1px; }}
.location-card canvas {{ max-height: 400px; }}
.location-card .loc-mod {{ font-size: 10px; color: #484f58; text-align: center; margin-top: 2px; }}
.byclass {{ margin-top: 40px; max-width: 1000px; margin-left: auto; margin-right: auto; }}
.byclass h2 {{ color: #58a6ff; font-size: 20px; margin-bottom: 18px; }}
.loc-tabs {{ display: flex; gap: 8px; margin-bottom: 16px; }}
.loc-tab {{ padding: 6px 16px; background: #21262d; border: 1px solid #30363d; border-radius: 6px; color: #8b949e; cursor: pointer; font-size: 13px; transition: all 0.2s; }}
.loc-tab.active {{ background: #1f6feb; border-color: #1f6feb; color: #fff; }}
.loc-tab:hover:not(.active) {{ background: #30363d; }}
</style>
</head>
<body>

<h1>BangMod — Effective Damage by Hit Location</h1>
<p class="subtitle">Damage = fBaseDamage &times; &Sigma;(DmgType[i] &times; Resist[i]) &times; LocationModifier — parsed from BangModWeaponAttachment_*.uc</p>

<div class="info">
<b>Formula:</b> <code>Resistance = DmgType[Swing]&times;Resist[Swing] + DmgType[Pierce]&times;Resist[Pierce] + DmgType[Blunt]&times;Resist[Blunt]</code><br>
<b>Effective Damage = &lfloor;BaseDamage &times; Resistance &times; LocationModifier&rceil;</b> (rounded)<br>
<b>Melee Location Modifiers:</b> Head &times;{LOCATION_MODIFIERS["Head"]}, Torso &times;{LOCATION_MODIFIERS["Torso"]}, Legs &times;{LOCATION_MODIFIERS["Legs"]}<br>
<b>Resistances (S/P/B):</b> <span style="color:#3fb950;">Archer 0.85/0.85/0.65</span> &middot; <span style="color:#f85149;">Knight 0.40/0.50/0.61</span> &middot; <span style="color:#58a6ff;">MaA 0.80/0.85/0.65</span> &middot; <span style="color:#d2a800;">Vanguard 0.60/0.80/0.70</span>
</div>

<div class="weapon-grid" id="weaponGrid"></div>
<div class="byclass" id="byClass"></div>

<script>
const DMG = {{ "Swing":[1,0,0],"Pierce":[0,1,0],"Blunt":[0,0,1],"SwingBlunt":[0.5,0,0.5],"PierceBlunt":[0,0.5,0.5] }};
const CL = {classes_json};
const LOC = {loc_mod_json};
const ATC = {{Swing:"rgba(248,81,73,0.78)",Pierce:"rgba(63,185,80,0.78)",Blunt:"rgba(88,166,255,0.78)",SwingBlunt:"rgba(188,140,255,0.78)",PierceBlunt:"rgba(255,166,87,0.78)"}};

function calc(base, dtype, cls, loc) {{
  const d = DMG[dtype];
  if (!d) return 0;
  const res = d[0]*cls.r[0] + d[1]*cls.r[1] + d[2]*cls.r[2];
  return Math.round(base * res * LOC[loc]);
}}

const W = {weapons_json};
const A = {{0:"LMB",1:"OH",2:"Stab"}};
const ATK_LABELS = ["LMB","OH","Stab"];
const LOCATIONS = ["Head","Torso","Legs"];
const wnames = Object.keys(W).sort();

// ============ PER-WEAPON CHARTS: 3 locations side-by-side ============
const grid = document.getElementById("weaponGrid");

wnames.forEach(wname => {{
  const div = document.createElement("div");
  div.className = "per-weapon";
  
  let canvases = "";
  LOCATIONS.forEach(loc => {{
    canvases += `<div class="location-card"><h4>${{loc}} <span class="loc-mod">(&times;${{LOC[loc]}})</span></h4><canvas id="w_${{wname}}_${{loc}}"></canvas></div>`;
  }});
  div.innerHTML = `<h3>${{wname}}</h3><div class="location-row">${{canvases}}</div>`;
  grid.appendChild(div);

  const atkEntries = [[0,"LMB"],[1,"OH"],[2,"Stab"]];
  const labels = atkEntries.map(([idx, name]) => {{
    const [dmg, dt] = W[wname][idx] || [0,"Swing"];
    return `${{name}}\\n${{dt}} ${{dmg}}dmg`;
  }});

  LOCATIONS.forEach(loc => {{
    const datasets = CL.map(cl => ({{
      label: cl.n,
      data: atkEntries.map(([idx]) => calc(W[wname][idx][0], W[wname][idx][1], cl, loc)),
      backgroundColor: cl.color,
      borderColor: cl.hex,
      borderWidth: 1,
    }}));

    new Chart(document.getElementById(`w_${{wname}}_${{loc}}`), {{
      type: "bar",
      data: {{ labels, datasets }},
      options: {{
        responsive: true,
        maintainAspectRatio: true,
        plugins: {{
          legend: {{ display: loc === "Head" ? true : false, labels: {{ color:"#c9d1d9", font:{{size:10}}, usePointStyle:true, pointStyleWidth:8, boxWidth:8 }} }},
          tooltip: {{
            callbacks: {{
              title: (items) => {{
                if (!items.length) return '';
                const a = ATK_LABELS[items[0].dataIndex];
                const [dmg, dt] = W[wname][ATK_LABELS.indexOf(a)];
                return `${{a}} — ${{dt}} (${{dmg}} base) → ${{loc}}`;
              }},
              label: (ctx) => `${{ctx.dataset.label}}: ${{ctx.raw}} damage`,
            }},
          }},
        }},
        scales: {{
          x: {{ ticks: {{ color:"#8b949e", font:{{size:10}} }}, grid:{{color:"#21262d"}} }},
          y: {{ beginAtZero:true, suggestedMax:160, ticks:{{color:"#8b949e", font:{{size:9}} }}, grid:{{color:"#21262d"}} }},
        }},
      }},
    }});
  }});
}});

// ============ BY-CLASS CHARTS with location tabs ============
const byClassDiv = document.getElementById("byClass");
byClassDiv.innerHTML = '<h2>Full Comparison by Class</h2>';

CL.forEach(cl => {{
  const container = document.createElement("div");
  container.className = "per-weapon";
  container.style.marginBottom = "16px";

  // Location tabs
  let tabsHtml = '<div class="loc-tabs">';
  LOCATIONS.forEach((loc, i) => {{
    tabsHtml += `<button class="loc-tab${{i === 0 ? ' active' : ''}}" data-cls="${{cl.n}}" data-loc="${{loc}}">${{loc}} &times;${{LOC[loc]}}</button>`;
  }});
  tabsHtml += '</div>';

  // Canvas per location (only first visible)
  let canvasesHtml = "";
  LOCATIONS.forEach((loc, i) => {{
    canvasesHtml += `<div class="location-card" id="bc_card_${{cl.n}}_${{loc}}" style="${{i > 0 ? 'display:none' : ''}}"><canvas id="c_${{cl.n}}_${{loc}}"></canvas></div>`;
  }});

  container.innerHTML = `<h3>vs <span style="color:${{cl.hex}}">${{cl.n}}</span> — Resist S:${{cl.r[0]}} P:${{cl.r[1]}} B:${{cl.r[2]}}</h3>${{tabsHtml}}${{canvasesHtml}}`;
  byClassDiv.appendChild(container);

  // Build charts for each location
  LOCATIONS.forEach((loc, locIdx) => {{
    const labels=[], data=[], bg=[], bcInfo=[];
    wnames.forEach(w => {{
      for (const a of [0,1,2]) {{
        const [dmg, dt] = W[w][a]||[0,"Swing"];
        labels.push(`${{w}} ${{A[a]}}`);
        data.push(calc(dmg, dt, cl, loc));
        bg.push(ATC[dt]||"#888");
        bcInfo.push({{w, atk:A[a], dtype:dt, base:dmg, loc}});
      }}
      labels.push('');data.push(null);bg.push('transparent');bcInfo.push(null);
    }});

    new Chart(document.getElementById(`c_${{cl.n}}_${{loc}}`), {{
      type:"bar",
      data:{{labels,datasets:[{{label:`vs ${{cl.n}} (${{loc}})`,data,backgroundColor:bg,borderColor:bg.map(c=>c==='transparent'?'transparent':c.replace("0.78","1")),borderWidth:1,atkInfo:bcInfo}}]}},
      options:{{
        responsive:true,maintainAspectRatio:true,
        plugins:{{legend:{{display:false}},
          tooltip:{{callbacks:{{
            title:(items)=>{{const info=items[0]?.dataset?.atkInfo?.[items[0]?.dataIndex];return info?`${{info.w}} — ${{info.atk}} (${{info.dtype}} ${{info.base}}) → ${{info.loc}}`:'';}},
            label:(ctx)=>ctx.raw===null?'':`${{ctx.raw}} damage`
          }}}}
        }},
        scales:{{
          x:{{ticks:{{color:"#8b949e",font:{{size:7}},maxRotation:90}},grid:{{color:"#21262d"}}}},
          y:{{beginAtZero:true,ticks:{{color:"#8b949e",font:{{size:9}}}},grid:{{color:"#21262d"}}}},
        }},
      }},
    }});
  }});

  // Tab click handlers
  container.querySelectorAll('.loc-tab').forEach(btn => {{
    btn.addEventListener('click', () => {{
      const clsName = btn.dataset.cls;
      const loc = btn.dataset.loc;
      // Update active tab state
      container.querySelectorAll('.loc-tab').forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      // Show/hide canvases
      LOCATIONS.forEach(l => {{
        const card = document.getElementById(`bc_card_${{clsName}}_${{l}}`);
        if (card) card.style.display = l === loc ? '' : 'none';
      }});
    }});
  }});
}});
</script>
</body>
</html>'''
    
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(html)
    
    print(f"Generated {output_path}")
    print(f"  Weapons: {len(js_weapons)}")
    print(f"  Hit locations: {list(LOCATION_MODIFIERS.keys())}")
    
    # Print summary table (torso for backward compat)
    print(f"\n=== EFFECTIVE DAMAGE SUMMARY (Torso, Max of LMB/OH/Stab) ===")
    header = f"{'Weapon':<25}"
    for cls in CLASSES:
        header += f"{cls:>12}"
    print(header)
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
                eff = calc_effective_damage(dmg, dtype, cls_name, 'Torso')
                if eff > max_eff:
                    max_eff = eff
            print(f"{max_eff:>12}", end="")
        print()


def main():
    # Auto-detect base directory: use script's own location
    script_dir = os.path.dirname(os.path.abspath(__file__))
    base_dir = script_dir  # Script lives in BangMod root
    
    # Fallback to Windows path if needed
    if not os.path.isdir(os.path.join(base_dir, "Classes")):
        base_dir = r"c:\Program Files (x86)\Steam\steamapps\common\chivalrymedievalwarfare\Development\Src\BangMod"
    
    weapons = parse_weapon_files(base_dir)
    print(f"Parsed {len(weapons)} weapons from {base_dir}")
    
    output_path = os.path.join(base_dir, "damage_graph.html")
    generate_html(weapons, output_path)


if __name__ == "__main__":
    main()
