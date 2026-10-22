/**
* Copyright 2010-2012, Torn Banner Studios, All rights reserved
*
* Original Author: Michael Bao
*
* The weapon that is replicated to all clients: Flail.
*/
class XangModWeaponAttachment_Flail extends AOCWeaponAttachment_Flail;


// Parry-box + netcode overrides. MUST be at class level, after any vars - see the file header.
`include(XangMod/Include/XangModWeaponAttachmentCode.uci)
