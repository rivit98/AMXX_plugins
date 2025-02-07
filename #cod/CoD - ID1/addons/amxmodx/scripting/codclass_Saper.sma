#include <amxmodx>
#include <codmod>
#include <engine>
#include <hamsandwich>
#include <cstrike>
        
new const nazwa[]   = "Saper";
new const opis[]    = "Ma 2 miny, defuser, 1/7 na zadanie 2 razy wiekszych dmg";
new const bronie    = (1<<CSW_FIVESEVEN)|(1<<CSW_P90);
new const zdrowie   = 20;
new const kondycja  = 15;
new const inteligencja = 5;
new const wytrzymalosc = 15;
    
new const modelMiny[] = "models/QTM_CodMod/mine.mdl"

new sprite_blast_miny, ilosc_min_gracza[33], bool:ma_klase[33];

public plugin_init()
{
	register_plugin(nazwa, "1.0", "RiviT");

	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc, "Darmowe");
	
	register_touch("mine", "player",  "DotykMiny");

	RegisterHam(Ham_TakeDamage, "player", "TakeDamage", 0);
	RegisterHam(Ham_Spawn, "player", "fwSpawn_Miny", 1);
}

public plugin_precache()
{
	precache_model(modelMiny);
	sprite_blast_miny = precache_model("sprites/dexplo.spr");
}

public cod_class_enabled(id)
{
	ilosc_min_gracza[id] = 2;
	cs_set_user_defuse(id, 1);
	ma_klase[id] = true;
}

public cod_class_disabled(id)
{
	ma_klase[id] = false;
	cs_set_user_defuse(id, 0);
}

public cod_class_skill_used(id)
{
	if (!ilosc_min_gracza[id])
		client_print(id, print_center, "Wykorzystales juz wszystkie miny!");

	else
	{
		ilosc_min_gracza[id]--;

		new Float:origin[3];
		entity_get_vector(id, EV_VEC_origin, origin);

		new ent = create_entity("info_target");
		entity_set_string(ent ,EV_SZ_classname, "mine");
		entity_set_edict(ent ,EV_ENT_owner, id);
		entity_set_int(ent, EV_INT_movetype, MOVETYPE_TOSS);
		entity_set_origin(ent, origin);
		entity_set_int(ent, EV_INT_solid, SOLID_BBOX);

		entity_set_model(ent, modelMiny);
		entity_set_size(ent,Float:{-16.0,-16.0,0.0},Float:{16.0,16.0,2.0});

		drop_to_floor(ent);

		set_rendering(ent,kRenderFxNone, 0,0,0, kRenderTransTexture,50);
	}
}

public fwSpawn_Miny(id)
{
	if(ma_klase[id])
	{
		ilosc_min_gracza[id] = 2;
		cs_set_user_defuse(id, 1);
      }
}

public DotykMiny(ent, id)
{
	if(!is_valid_ent(ent))
		return;

	new attacker = entity_get_edict(ent, EV_ENT_owner);
	if (get_user_team(attacker) != get_user_team(id))
	{
		new Float:fOrigin[3];
		entity_get_vector( ent, EV_VEC_origin, fOrigin);

		new iOrigin[3];
		for(new i=0;i<3;i++)
			iOrigin[i] = floatround(fOrigin[i]);

		message_begin(MSG_BROADCAST,SVC_TEMPENTITY, iOrigin);
		write_byte(TE_EXPLOSION);
		write_coord(iOrigin[0]);
		write_coord(iOrigin[1]);
		write_coord(iOrigin[2]);
		write_short(sprite_blast_miny);
		write_byte(32);
		write_byte(20);
		write_byte(0);
		message_end();

		new entlist[33];
		iOrigin[0] = find_sphere_class(ent,"player", 90.0 ,entlist, 32);

		for (new i=0; i < iOrigin[0]; i++)
		{
			if (!is_user_alive(entlist[i]) || get_user_team(attacker) == get_user_team(entlist[i]))
				continue;

			cod_inflict_damage(attacker, entlist[i], 70.0, 0.8, ent, (1<<24));
		}
		remove_entity(ent);
	}
}


public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker))
		return HAM_IGNORED;
		
	if(!ma_klase[idattacker])
		return HAM_IGNORED;
		
	if(!random(7))
		SetHamParamFloat(4, damage * 2)

	return HAM_IGNORED;
}
