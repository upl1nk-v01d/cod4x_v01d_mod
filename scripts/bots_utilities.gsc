#include common_scripts\utility;
#include maps\mp\_load;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include scripts\cl;
#include scripts\pl;

/*init_botwarfare()
{
	level thread maps\mp\bots\_bot::init();
	level thread maps\mp\bots\_bot_chat::init();
	level thread maps\mp\bots\_menu::init();
	level thread maps\mp\bots\_wp_editor::init();

	level thread scripts\bots_aim_ext::init();
	level thread scripts\bots_fire_ext::init();
}*/

_get_head_pos(player, eyePos)
{
	head = player getEye();
	
	if(player getStance() == "stand")
	{
		head = (head[0], head[1], head[2] + 16);
	}	

	if(isDefined(player.modelLoaded) && !isDefined(eyePos))
	{
		head = player GetTagOrigin("j_head");
	}
	else if(isDefined(player.lastStand))
	{
		head = player.origin;
	}
	else if(player getStance() == "prone")
	{
		head = player.origin;
	}	
	else if(player getStance() == "crouch")
	{
		head = (head[0], head[1], head[2]);
	}
	else
	{
		head = (head[0], head[1], head[2]);
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
		wait 0.05;
		class = "custom" + ( randomInt( 5 ) + 1 );
		bot notify("menuresponse", game["menu_changeclass"], class);
		wait 0.05;
		//bot scripts\bots_tactics::_bot_equip();
		
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
	if (!FS_TestFile(filename)){ return undefined; }

	lines = [];
	
	if(FS_TestFile(filename))
	{
		file = FS_FOpen(filename, "read");
		line = FS_ReadLine(file);
		lines[lines.size] = line;

		while(isDefined(line) && line != "")
		{
			line = FS_ReadLine(file);
			lines[lines.size] = line;
		}

		FS_FClose(file);
	}
	
	return lines;
}

_write_text_file(arr, filename)
{
	if (!isDefined(arr)){ return; }
	
	file = FS_FOpen(filename, "write");
	//FS_WriteLine(file, "");
	
	/*if(file > 0)
	{
		if (!FS_WriteLine(file, level.nodes.size + ""))
		{
			FS_FClose(file);
			file = 0;
		}
	}*/
		
	for(i = 0; i < arr.size; i++)
	{
		FS_WriteLine(file, arr[i]);
	}
	
	FS_FClose(file);
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

_get_nearest_entity(class, key, team, sp, minDist, maxDist)
{
	self endon ( "disconnect" );
	
	if(!isDefined(class)){ return; }
	if(!isDefined(key)){ return; }
	if(!isDefined(sp)){ sp = self.origin; }
	if(!isDefined(team)){ team = "any"; }
	if(!isDefined(minDist)){ minDist = 0; }
	if(!isDefined(maxDist)){ maxDist = 9999999; }
	
	closest = 9999999;
	entity = undefined;
	
	entities = getentarray(class, key);
	
	for(i = 0; i < entities.size; i++)
	{
		if(!isDefined(entities[i])){ continue; }
		
		ent = entities[i];
		if(!isDefined(ent.modelLoaded)){ continue; }
		
		pos = ent.origin;
		if(isPlayer(ent)){ pos = ent getEye(); }
		dist = distance(sp, pos);
		
		if(isAlive(ent) && ent != self && team == "friendly" && ent.pers["team"] == self.pers["team"] && dist > minDist && dist < maxDist && dist < closest)
		{
			closest = dist;
			entity = ent;
		}
		else if(isAlive(ent) && ent != self && team == "enemy" && ent.pers["team"] != self.pers["team"] && dist > minDist && dist < maxDist && dist < closest)
		{
			closest = dist;
			entity = ent;
		} 
		else if(isAlive(ent) && team == "any" && dist > minDist && dist < maxDist && dist < closest)
		{
			closest = dist;
			entity = ent;
		}
	}
	
	return entity;
}

_bot_change_weapon(weapon)
{
	if(!isDefined(weapon)){ return; }
	
	#if isSyscallDefined botWeapon
		self botWeapon(weapon);
	#else
		self switchToWeapon(weapon);
	#endif
}