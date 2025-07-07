#include common_scripts\utility;
#include maps\mp\_load;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include scripts\cl;
#include scripts\pl;

init_botwarfare()
{
	level thread maps\mp\bots\_bot::init();
	level thread maps\mp\bots\_bot_chat::init();
	level thread maps\mp\bots\_menu::init();
	level thread maps\mp\bots\_wp_editor::init();

	level thread scripts\bots_aim_ext::init();
	level thread scripts\bots_fire_ext::init();
}

_dp(from, to, angles)
{
	dirToTarget = VectorNormalize(to - from);
	forward = AnglesToForward(angles);
	vectorDot = vectordot(dirToTarget, forward);
	//cl(self.name + ":" + vectorDot);
	
	return vectorDot;
}

_get_head_pos(player)
{
	head = player GetTagOrigin("j_head");
	
	if(player getStance() == "prone")
	{
		head = (head[0], head[1], head[2]+2);
	} 
	else if(isDefined(player.lastStand))
	{
		head = player.origin;
		head = (head[0], head[1], head[2]+2);
	}
	else
	{
		head = (head[0], head[1], head[2]+2);
	}
	
	return head;
}

bot_add(team)
{
	name = _bot_get_name();
	bot = undefined;

	if (isDefined(name))
	{
		bot = addtestclient(name);
	}
	else
	{
		bot = addtestclient();
	}
	
	if (isDefined(bot))
	{		
		bot.pers["isBot"] = true; //this was a real pain to figure why self.isbot was undefined.
		bot.pers["team"] = team;
		bot notify("menuresponse", game["menu_team"], team);
		wait 0.5;
		class = "custom" + ( randomInt( 5 ) + 1 );
		bot notify("menuresponse", game["menu_changeclass"], class);
		
		level.bots++;

		//level.default_perk[bot.curClass][0] = undefined;
		//level.default_perk[bot.curClass][1] = undefined;
		//level.default_perk[bot.curClass][2] = undefined;
		//bot.curClass = undefined;
		//level.default_perk = undefined;
		//level.default_perk = undefined;
		
		return bot;
	}
	
	return undefined;
}

_read_text_file(filename)
{
	lines = [];
	
	if(FS_TestFile(filename))
	{
		file = FS_FOpen(filename, "read");
		line = FS_ReadLine(file);

		while(isDefined(line) && line != "")
		{
			line = FS_ReadLine(file);
			lines[lines.size] = line;
		}

		FS_FClose(file);
	}
	
	return lines;
}

_bot_get_name()
{
	name = "bot";
	
	if(isDefined(level.botNames))
	{
		if (getDvar("temp_dvar_bot_name_cursor" ) == "")
		{
			setDvar("temp_dvar_bot_name_cursor", 0);
		}
		
		cur = getDvarInt( "temp_dvar_bot_name_cursor" );
		
		if (level.botNames.size > 0)
		{
			name = level.botNames[cur % level.botNames.size];
		}
		else
		{
			name = name + cur;
		}
		
		setDvar( "temp_dvar_bot_name_cursor", cur + 1 );
	}

	return name;
}

_find_nearest_enemy(startPos)
{
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "death" );
	level endon( "game_ended" );
	
	closest = 9999999;
	nr = undefined;
	enemy = undefined;
	
	players = getentarray("player", "classname");
	
	for(i = 0; i < players.size; i++)
	{
		if(!isDefined(players[i])){ continue; }
				
		dist = distance(players[i] getEye(), startPos);
		
		if(isAlive(players[i]) && players[i] != self && players[i].pers["team"] != self.pers["team"] && dist < closest)
		{
			closest = dist;
			enemy = players[i];
		}
	}
	
	return enemy;
}

_bot_change_weapon(weapon)
{
	#if isSyscallDefined botWeapon
		self botWeapon(weapon);
	#else
		self switchToWeapon(weapon);
	#endif
}
