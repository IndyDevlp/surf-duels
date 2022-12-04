#include <amxmodx>
#include <amxmisc>
#include <fun>
#include <hamsandwich>
#include <cstrike>

#include <colorchat>

#define MAX_CHAR		512

new PLUGIN[] = "Surf duels"
new AUTHOR[] = "\mEl\"
new VERSION[] = "0.3-a"

new CHATSERVERNAME[] = "!n[!gSurf Duels!n]"

new g_iPlayerPage[33] 
new Timer = 0
new bool:isNowDuel = false

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR)
    register_clcmd("get_awp","f_get_awp",_,_)
    register_menucmd(register_menuid("Show_Judge_Menu"), (1<<0|1<<9), "Handle_Judge_Menu")
    register_clcmd("nightvision","Show_Judge_Menu")

    register_menucmd(register_menuid("Judge_choose_players"), (1<<0|1<<1|1<<2|1<<3|1<<4|1<<5|1<<6|1<<7|1<<8|1<<9), "Handle_Judge_choose_players")
    register_event("TeamScore", "team_score", "a")
    register_logevent("Round_End", 2, "1=Round_End")
}

public f_get_awp(id)
{
    give_item(id, "weapon_awp")
    print_color_chat(id, "%s you getting !t[!gAWP!t]", CHATSERVERNAME)
}

public Show_Judge_Menu(id)
{
	new szMenu[512], iKeys = (1<<9), iLen
	iLen = formatex(szMenu[iLen], charsmax(szMenu), "\yПанель Судьи^n^n")

	if(get_user_flags(id) & ADMIN_KICK && !isNowDuel)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[\w1\r] \wВыбрать игроков для дуэли^n")
		iKeys |= (1<<0)	
	}
    else if(isNowDuel)
    {
        iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[\w1\r] \dВыбрать игроков для дуэли \y(\rИдёт дуэль\y)^n")
    }

    if(get_user_flags(id) & ADMIN_KICK)
	{
		iLen += formatex(szMenu[iLen], charsmax(szMenu) - iLen, "\r[\w2\r] \wСбросить дуэль - неработает^n")
		iKeys |= (1<<1)	
	}
	
	formatex(szMenu[iLen], charsmax(szMenu) - iLen, "^n\r[\w0\r] \wВыход")
	iKeys |= (1<<9)
	
	return show_menu(id, iKeys, szMenu, -1, "Show_Judge_Menu");
}

new szPlayersMenu[33][32]
new szJudgeChoice[33][2]

public Handle_Judge_Menu(id, iKey)
{
	new name[32]
	get_user_name(id, name, 31)

    switch(iKey)
	{
        case 0: 
		{
            szJudgeChoice[id][0] = 0
            szJudgeChoice[id][1] = 0
            Judge_choose_players(id, g_iPlayerPage[ id ] = 0)
            return PLUGIN_HANDLED
        }
        case 1: 
		{
            isNowDuel = false



            return PLUGIN_HANDLED
        }

		case 9: return PLUGIN_HANDLED
	}

    return PLUGIN_HANDLED
}    


public Judge_choose_players(id, iPage)
{
    new szPlayers[ 32 ] , iNum , iLen , menu[ MAX_CHAR ] , iKey, iItem, name[ 32 ]
    
	get_players(szPlayers, iNum)
	szPlayersMenu[id] = szPlayers

	new iStart = iPage * 8;
	new iEnd = iStart + 8;

	iLen = format(menu[ iLen ] , charsmax( menu ) - iLen , "\yВыберите пару игроков для дуэли^n^n")

    if(szJudgeChoice[id][0] != 0)
    {
        iLen += format(menu[ iLen ] , charsmax( menu ) - iLen , "\yВыбраны:^n" )
        new szNameVictim[32]
        get_user_name( szJudgeChoice[id][0] , szNameVictim , charsmax( szNameVictim ) )
        iLen += format(menu[ iLen ] , charsmax( menu ) - iLen , "\w%s^n%s", szNameVictim, szJudgeChoice[id][1] == 0 ? "^n" : "")
    }
    if(szJudgeChoice[id][1] != 0)
    {
        new szNameVictim[32]
        get_user_name( szJudgeChoice[id][1] , szNameVictim , charsmax( szNameVictim ) )
        iLen += format(menu[ iLen ] , charsmax( menu ) - iLen , "\w%s^n^n", szNameVictim)

        // Делаем новое меню
        iKey |= (1<<0)
        iLen += format( menu[ iLen ] , charsmax( menu ) - iLen , "\r[\w1\r] \wНачать дуэль!^n")
       
        iKey |= (1<<9)
        formatex(menu[iLen], charsmax(menu) - iLen, "^n\r[\w0\r] \wВыход")
        

        return show_menu( id , iKey , menu , -1 , "Judge_choose_players" )
    }
    

	
	for( new i = iStart; i < iEnd; i++ ) 
	{
		if( i < iNum )
		{
			get_user_name(szPlayers[ i ], name, charsmax(name))

            if(szPlayers[i] == szJudgeChoice[id][0])
            {
                iKey |= ( 1<<iItem )
				iLen += format( menu[ iLen ] , charsmax( menu ) - iLen , "\r[\w%d\r] \w%s \y(\rВыбран\y)^n" , ++iItem , name )
            }
			else
			{
				iKey |= ( 1<<iItem )
				iLen += format( menu[ iLen ] , charsmax( menu ) - iLen , "\r[\w%d\r] \w%s^n" , ++iItem , name )
			}
		}
	}

	iKey |= ( 1<<9 )

	if(iEnd < iNum)
	{
		iKey |= ( 1<<8 )
		iLen += format( menu[ iLen ] , charsmax( menu ) - iLen , "^n\r9. \wДальше^n\r0. \w%s" , iPage ? "Назад" : "Выход" )
	}
	else
    {
		iLen += format( menu[ iLen ] , charsmax( menu ) - iLen , "^n\r0. \w%s" , iPage ? "Назад" : "Выход" )
    }

    return show_menu( id , iKey , menu , -1 , "Judge_choose_players" )
}

public Handle_Judge_choose_players(id, iKey)
{
    switch( iKey )
	{
        case 8:
        {
            return Judge_choose_players( id , ++g_iPlayerPage[ id ] )
        }
		case 9: 
        {
            if(szJudgeChoice[id][0] != 0 && szJudgeChoice[id][1] != 0) return PLUGIN_HANDLED
            
            return Judge_choose_players( id , --g_iPlayerPage[ id ] )
        }
        default:
        {
            if(szJudgeChoice[id][0] != 0 && szJudgeChoice[id][1] != 0)
            {
                new Player1[ 32 ] , Player2[ 32 ]
                get_user_name( szJudgeChoice[id][0] , Player1 , charsmax( Player1 ) )
                get_user_name( szJudgeChoice[id][1] , Player2 , charsmax( Player2 ) )

                print_color_chat(0, "%s !gДуэль !yскоро начнётся.", CHATSERVERNAME)
                print_color_chat(0, "%s [!t%s!y] против [!t%s!y]", CHATSERVERNAME, Player1, Player2)

                set_task(5.0, "start_duel", id, _, _, "a", 1)
                return PLUGIN_HANDLED // ... Можно вернуть меню админки, там будет рестарт, смена мапы и т.д.
            }
            if(szJudgeChoice[id][0] == 0)
            {
                szJudgeChoice[id][0] = szPlayersMenu[ id ][ ( g_iPlayerPage[ id ] * 8 ) + iKey ]
                return Judge_choose_players(id, g_iPlayerPage[id])
            }

            if(szJudgeChoice[id][0] != 0)
            {
                szJudgeChoice[id][1] = szPlayersMenu[ id ][ ( g_iPlayerPage[ id ] * 8 ) + iKey ]
                return Judge_choose_players(id, g_iPlayerPage[id])
            }
        }
    }

    return PLUGIN_HANDLED
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
        remove_task(id)
        print_color_chat(0, "%s Дуэль началась!", CHATSERVERNAME)
        StartDuel(id)
        // Вызов какой-то функции, которая начинает дуэль. Раскидывает по командам, выдаёт оружие, остальных кидает в спек.
    }
}  

new ct_score
new terrorist_score
new id_player_1
new id_player_2

public StartDuel(id)
{
    isNowDuel = true
    new Players[32], count_of_players
    get_players(Players, count_of_players, "h") 

    for(new i = 0; i < count_of_players; i++)
    {
        if(Players[i] != szJudgeChoice[id][0] && Players[i] != szJudgeChoice[id][1])
        {
            cs_set_user_team(Players[i], CS_TEAM_SPECTATOR)
        }

        user_kill(Players[i], 1)
    }

    cs_set_user_team(szJudgeChoice[id][0], CS_TEAM_CT)
    cs_set_user_team(szJudgeChoice[id][1], CS_TEAM_T)

    ct_score = 0
    terrorist_score = 0

    id_player_1 = szJudgeChoice[id][0]
    id_player_2 = szJudgeChoice[id][1]

    server_cmd("sv_restart 1")
    server_cmd("mp_freezetime 6")
}

/*
    TODO(Закончить дуэль досрочно (человек сдался)) "say /resign" или судья засчитает поражение сам | isNowDuel = false
    TODO(Закончить дуэль судьёй) сделал по ошибке типо | isNowDuel = false
    TODO(Закончить дуэль) Отдать победу какому-то игроку, по причине что второй читер или ещё какие-либо нарушения правил | isNowDuel = false

    TODO(После того как дуэль завершена, вернуть как было) т.е. распределить всех по командам и возродить и начать раунд
*/

public team_score()
{
    if(isNowDuel)
    {
        new team[32]
        read_data(1,team,31)

        if (equal(team,"CT"))
            ct_score = read_data(2)
        
        else if (equal(team,"TERRORIST"))
            terrorist_score = read_data(2)
    }
}

public Round_End()
{
        if(isNowDuel)
        {
            new Player1[ 32 ] , Player2[ 32 ]
            get_user_name( id_player_1 , Player1 , charsmax( Player1 ) )
            get_user_name( id_player_2 , Player2 , charsmax( Player2 ) )
            print_color_chat(0, "%s Текущий счёт:", CHATSERVERNAME)
            print_color_chat(0, "%s Игрок !t[!g%s!t] !n- !t%d", CHATSERVERNAME, Player1, ct_score)
            print_color_chat(0, "%s Игрок !t[!g%s!t] !n- !t%d", CHATSERVERNAME, Player2, terrorist_score)
        }
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