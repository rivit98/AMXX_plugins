/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <smsshop>

native get_user_level(id);
native set_user_level(id, amount);

new g_iUsluga;

#define NAZWA_DL "Level" 				//Nazwa uslugi wyswietlana w menu
#define NAZWA_KR "level" 				//nazwa uslugi uzywana w logach, jako okienko MOTD itd.


new const g_szJednostkaIlosci[][][] = {
	{ "10", "+10 Leveli" },
	{ "20", "+20 Leveli" },
	{ "50", "+50 Leveli" }
	//Wypisz tutaj po kolei jednostke ilosci uslug
	//Format: "kr. jednostka", "dl. jednostka"
	//dluga jednostka - wyswietlana jest w np. menu
	//krotka jednostka - wykorzystywana w skryptach
	//Pamietaj ze ostatnia linijka nie ma na koncu po klamrze przecinka!
}

new const g_szCena[][][] = {
	{ "1,23", "1,23 zl SMS / 1 zl przelew / 1 zl PSC" },
	{ "2,46", "2,46 zl SMS / 2 zl przelew / 2 zl PSC" },
	{ "6,15", "6,15 zl SMS / 5 zl przelew / 5 zl PSC" }
	//Wypisz tutaj w takiej samej kolejnosci jak dlugosci uslug ich ceny
	//Format: "kr. cena", "dl. cena"
	//krotka cena - cena SMSa uslugi - zlotowki i grosze oddzielone przecinkiem
	//dluga cena - cena wyswietlana w menu
	//Pamietaj ze ostatnia linijka nie ma na koncu po klamrze przecinka!
}

public plugin_init() 
{
	new szNazwa[64]; formatex(szNazwa, 63, "Sklep SMS: Usluga %s", NAZWA_DL);
	register_plugin(szNazwa, "1.0", "d0naciak");
	
	g_iUsluga = ss_register_service(NAZWA_DL, NAZWA_KR);
	
	for(new i = 0; i < sizeof g_szJednostkaIlosci; i++)
		ss_add_service_qu(g_iUsluga, g_szJednostkaIlosci[i][1], g_szJednostkaIlosci[i][0], g_szCena[i][1], g_szCena[i][0]);
}

public ss_buy_service_post(id, iUsluga, iJednostkaIlosci)
{
	if(iUsluga != g_iUsluga)
		return SS_CONTINUE;
	
	set_user_level(id, get_user_level(id) + str_to_num(g_szJednostkaIlosci[iJednostkaIlosci][0]));
	
	ss_finalize_user_service(id);
	
	return SS_CONTINUE;
}