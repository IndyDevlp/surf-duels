#include <amxmodx>
#include <amxmisc>
#include <fun>
#include <hamsandwich>

#include <colorchat>

new PLUGIN[] = "Surf duels"
new AUTHOR[] = "\mEl\"
new VERSION[] = "0.1-a"

new CHATSERVERNAME[] = "!n[!gSurf Duels!n]"

new Timer = 0

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
    register_clcmd("get_awp","f_get_awp",_,_)
    register_menucmd(register_menuid("Show_Judge_Menu"), (1<<0|1<<9), "Handle_Judge_Menu");
    register_clcmd("nightvision","Show_Judge_Menu")

    register_menucmd(register_menuid("Judge_choose_players"), (1<<0|1<<9), "Handle_Judge_choose_players");

}

public f_get_awp(id)
{
    give_item(id, "weapon_awp")
    print_color_chat(id, "%s you getting !t[!gAWP!t]", CHATSERVERNAME)
}

public Show_Judge_Menu(id)
{
	if(!(get_user_flags(id) & ADMIN_KICK))
	{
		print_color_chat(id, "%s У вас нет !tдоступа!n!", CHATSERVERNAME)
		client_cmd(id, "spk events/tutor_msg")
	}
	
	new szMenu[512], iKeys = (1<<9), iLen
	iLen = formatex(szMenu[iLen], charsmax(szMenu), "\yПанель Судьи^n^n")

	if(get_user_flags(id) & ADMIN_KICK)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[\w1\r] \wНачать дуэль^n")
		iKeys |= (1<<0)	
	}
	else
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[\d#\r] \dНачать дуэль^n")
	}
	
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[\w0\r] \wВыход")
	iKeys |= (1<<9)
	
	return show_menu(id, iKeys, szMenu, -1, "Show_Judge_Menu");
}

public Handle_Judge_Menu(id, iKey)
{
	new name[32]
	get_user_name(id, name, 31)

    switch(iKey)
	{
        case 0: 
		{
            print_color_chat(0, "%s !gДуэль !yскоро начнётся. [!t%s!y] против [!t%s!y]", CHATSERVERNAME, "kto-to1", "kogo-to2")
            set_task(5.0, "start_duel", id, _, _, "a", 1)
            return PLUGIN_HANDLED
        }

		case 9: return PLUGIN_HANDLED
	}

    return PLUGIN_HANDLED
}    


// Реализовать выбор двух игроков судьёй
public Judge_choose_players(id)
{

}

public Handle_Judge_choose_players(id, iKey)
{

}





stock print_color_chat(const index, const input[], any:...)
{
	static msg[191];
	
	vformat(msg, 190, input, 3);
	
	replace_all(msg, sizeof(msg), "!g", "^4");
	replace_all(msg, sizeof(msg), "!t", "^3");
	replace_all(msg, sizeof(msg), "!n", "^1");
    replace_all(msg, sizeof(msg), "!y", "^1");

    ColorChat(index, NORMAL, msg);
}

public start_duel(id)
{
    remove_task(id)
    Timer = 10
    set_task(1.0, "duel_countdown", id, _ , _ , "a", Timer+2)
}

public duel_countdown(id)  
{  
    if(Timer > -1)
    {
        if(Timer & 1)
        {
            print_color_chat(0, "%s Дуэль начнётся через !t[!g%d!t] !yсекунд!", CHATSERVERNAME, Timer)
        }
        --Timer
    }
    else
    {
        print_color_chat(0, "%s Дуэль началась!", CHATSERVERNAME)
        remove_task(id)
    }
}  



/*
ADMIN_IMMUNITY      Флаг "a" - Флаг иммунитета
ADMIN_RESERVATION   Флаг "b" - Флаг, разрешающий подключение на резервные слоты
ADMIN_KICK          Флаг "c" - Флаг доступа к команде amx_kick
ADMIN_BAN           Флаг "d" - Флаг доступа к командам amx_ban и amx_unban
ADMIN_SLAY          Флаг "e" - Флаг доступа к командам amx_slap и amx_slay
ADMIN_MAP           Флаг "f" - Флаг доступа к команде amx_map
ADMIN_CVAR          Флаг "g" - Флаг доступа для amx_cvar
ADMIN_CFG           Флаг "h" - Флаг доступа к amx_cfg
ADMIN_CHAT          Флаг "i" - Флаг доступа к amx_chat
ADMIN_VOTE          Флаг "j" - Флаг доступа к amx_vote
ADMIN_PASSWORD      Флаг "k" - Флаг доступа для изменения sv_password
ADMIN_RCON          Флаг "l" - Флаг доступа к amx_rcon
ADMIN_LEVEL_A       Флаг "m" - Зарезервированные флаги
ADMIN_LEVEL_B       Флаг "n" - Зарезервированные флаги
ADMIN_LEVEL_C       Флаг "o" - Зарезервированные флаги
ADMIN_LEVEL_D       Флаг "p" - Зарезервированные флаги
ADMIN_LEVEL_E       Флаг "q" - Зарезервированные флаги
ADMIN_LEVEL_F       Флаг "r" - Зарезервированные флаги
ADMIN_LEVEL_G       Флаг "s" - Зарезервированные флаги
ADMIN_LEVEL_H       Флаг "t" - Зарезервированные флаги
ADMIN_MENU          Флаг "u" - Флаг доступа к меню
ADMIN_USER          Флаг "z" - Флаг пользователя
*/