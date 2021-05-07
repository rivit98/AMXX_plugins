/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <fakemeta>
#include <xs>
#include <hamsandwich>
#include <csgo>

public plugin_init() {
	register_plugin("CSGO Mod: Podnoszenie broni", "1.0", "donaciak.pl");
	
	register_forward(FM_CmdStart, "fw_CmdStart");
}

public fw_CmdStart(id, iUc) {
	if(!is_user_alive(id)) {
		return FMRES_IGNORED;
	}
	

	static const g_iSlotBroni[] = {
		-1,
		2, //CSW_P228
		-1,
		1, //CSW_SCOUT
		4, //CSW_HEGRENADE
		1, //CSW_XM1014
		5, //CSW_C4
		1, //CSW_MAC10
		1, //CSW_AUG
		4, //CSW_SMOKEGRENADE
		2, //CSW_ELITE
		2, //CSW_FIVESEVEN
		1, //CSW_UMP45
		1, //CSW_SG550
		1, //CSW_GALIL
		1, //CSW_FAMAS
		2, //CSW_USP
		2, //CSW_GLOCK18
		1, //CSW_AWP
		1, //CSW_MP5NAVY
		1, //CSW_M249
		1, //CSW_M3
		1, //CSW_M4A1
		1, //CSW_TMP
		1, //CSW_G3SG1
		4, //CSW_FLASHBANG
		2, //CSW_DEAGLE
		1, //CSW_SG552
		1, //CSW_AK47
		3, //CSW_KNIFE
		1 //CSW_P90
	}

	static iHud;
	static bool:bMoze[33];
	new iEnt = fm_get_user_aiming_ent(id, "weaponbox");
	
	if(!iHud) {
		iHud = CreateHudSyncObj();
	}
	
	if(!pev_valid(iEnt) || task_exists(iEnt)) {
		if(bMoze[id]) {
			ClearSyncHud(id, iHud);
		}
		
		bMoze[id] = false;
		return FMRES_IGNORED;
	}
	
	new Float:fOrigin[2][3];
	
	pev(id, pev_origin, fOrigin[0]);
	pev(iEnt, pev_origin, fOrigin[1]);
	
	if(get_distance_f(fOrigin[0], fOrigin[1]) >= 120.0) {
		if(bMoze[id]) {
			ClearSyncHud(id, iHud);
		}
		
		bMoze[id] = false;
		return FMRES_IGNORED;
	}
	
	new szBron[16], iBron = fm_get_weaponbox_type(iEnt);
	
	if((iBron == CSW_C4 && get_user_team(id) != 1) || !iBron) {
		return FMRES_IGNORED;
	}
		
	bMoze[id] = true;
	
	csgo_get_short_weaponname(iBron, szBron, 15);
	set_hudmessage(0, 127, 255, -1.0, 0.7, 0, 5.0, 5.0, 0.1, 0.1, -1);
	ShowSyncHudMsg(id, iHud, "Kliknij E, aby podniesc %s", szBron);
	
	if(get_uc(iUc, UC_Buttons) & IN_USE && !(pev(id, pev_oldbuttons) & IN_USE)) {
		new iDane[2];
		iDane[0] = id;
		iDane[1] = iEnt;
		
		for(new i = 1; i <= CSW_P90; i++) {
			if(g_iSlotBroni[i] == g_iSlotBroni[iBron] && user_has_weapon(id, i)) {
				new szBronGracza[32];
				get_weaponname(i, szBronGracza, 31);
				
				engclient_cmd(id, "drop", szBronGracza);
				break;
			}
		}
		
		set_task(0.1, "task_DajBronie", iEnt, iDane, 2);
		ClearSyncHud(id, iHud);
	}
	
	return FMRES_IGNORED;
}

public task_DajBronie(iDane[2]) {
	if(pev_valid(iDane[1]) && is_user_alive(iDane[0])) {
		ExecuteHamB(Ham_Touch, iDane[0], iDane[1]);
		ExecuteHamB(Ham_Touch, iDane[1], iDane[0]);
		emit_sound(iDane[0], CHAN_ITEM, "items/gunpickup2.wav", 1.0, 0.8, SND_SPAWNING, PITCH_NORM);
	}
}

stock fm_get_user_aiming_ent(index, const sClassName[])
{
	new Float:vOrigin[3];
	fm_get_aim_origin(index, vOrigin);
	
	new ent, sTempClass[32], iLen = sizeof(sTempClass) - 1;
	do
	{
		pev(ent, pev_classname, sTempClass, iLen);
		if(equali(sClassName, sTempClass))
		{
			return ent;
		}
	}
	while((ent = engfunc(EngFunc_FindEntityInSphere, ent, vOrigin, 0.005)))
	
	return 0;
}

stock fm_get_aim_origin(index, Float:origin[3]) {
	new Float:start[3], Float:view_ofs[3];
	pev(index, pev_origin, start);
	pev(index, pev_view_ofs, view_ofs);
	xs_vec_add(start, view_ofs, start);
	
	new Float:dest[3];
	pev(index, pev_v_angle, dest);
	engfunc(EngFunc_MakeVectors, dest);
	global_get(glb_v_forward, dest);
	xs_vec_mul_scalar(dest, 9999.0, dest);
	xs_vec_add(start, dest, dest);
	
	engfunc(EngFunc_TraceLine, start, dest, 0, index, 0);
	get_tr2(0, TR_vecEndPos, origin);
	
	return 1;
}

stock fm_get_weaponbox_type(entity) {
	static max_clients, max_entities;
	if (!max_clients)
		max_clients = global_get(glb_maxClients);
	if (!max_entities)
		max_entities = global_get(glb_maxEntities);
	
	for (new i = max_clients + 1; i < max_entities; ++i) {
		if (pev_valid(i) && entity == pev(i, pev_owner)) {
			new wname[32];
			pev(i, pev_classname, wname, sizeof wname - 1);
			return get_weaponid(wname);
		}
	}
	
	return 0;
}