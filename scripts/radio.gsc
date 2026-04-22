#include scripts\cl;
#include scripts\pl;
#include scripts\bots_utilities;

init()
{		
	level.axisRadioQueue = [];
	level.alliesRadioQueue = [];

	level thread _player_connected();
	level thread _allies_radio_queue();
	level thread _bot_radio_get_out();
	level thread _bot_radio_moveout();
	level thread _bot_radio_bomb();
	
	//level thread _dev_radio_queue();
}

_allies_radio_queue()
{
	level endon("disconnect");
	level endon("intermission");
	level endon("game_ended");
	
	size = 0;

	for(;;)
	{
		if(level.alliesRadioQueue.size > 0)
		{
			sender = level.alliesRadioQueue[0];
			message = level.alliesRadioQueue[0].message;
			
			if(isDefined(message))
			{
				if(isAlive(sender))
				{
					sender _player_use_radio(message);
					message = undefined;
					
					wait 1.5;
				}				
			}
			
			level.alliesRadioQueue = scripts\main::_arr_remove_with_index(level.alliesRadioQueue, 0);
		}

		wait 0.5;
	}
}

_dev_radio_queue()
{
	wait 2;
	
	for(;;)
	{
		cl("size: " + level.alliesRadioQueue.size);
		
		wait 0.1;
	}
}

_player_connected()
{
	level endon("disconnect");
	level endon("intermission");
	level endon("game_ended");
			
	for(;;)
	{
		level waittill("connected", player);
		
		player thread _player_spawn_loop();
	}
}

_player_spawn_loop()
{
	//self endon("death");
	self endon("disconnect");
	self endon("intermission");
	level endon("game_ended");
	
	for(;;)
	{
		self waittill("spawned_player");
		
		if(self.isbot)
		{
			self thread _bot_radio_contact();	
			self thread _bot_affirm_follow_player();
		}
		else
		{
			self thread _player_radio_menu();			
			self thread _player_taunts_menu();			
		}
			
		//self thread _dev_radio();
	}
}

_player_head_icon(player)
{
	//self setClientDvars("cg_thirdperson", 1);

	h = _get_head_pos(player);
	o = player.origin;
	dur = 3;
	offset = (0, 0, 64);
	//offset = (h[0] + o[0], h[1] + o[1], h[2] + o[2] );
	
	self thread scripts\main::_show_hud_element("voice_on", undefined, player, offset);
	//self thread scripts\main::_show_hud_element("voice_on", h, undefined, 3, 1, 1);

	wait dur + 0.5;
	//self setClientDvars("cg_thirdperson", 0);
}

_player_use_radio(message)
{
	if(!isDefined(message)){ return; }
	
	//self thread _player_head_icon(self);
	
	//coms = StrTok("Roger That,Negative,Clear,Contact,Go Go Go,Need Backup,In Position,Follow Me,Cover This Area", "," );

	self pingPlayer();

	players = getentarray( "player", "classname" );
	for(i = 0; i < players.size; i++)
	{
		if(players[i].team == self.team && players[i].team == "allies")
		{
			//players[i] iprintln("^4"+self.name+":: "+coms[int(message[6])-1]+"!");
			players[i] playSound(message);
			//players[i] thread _player_head_icon(self);
		}
	}
}

_player_taunt(message)
{
	if(!isDefined(message)){ return; }
	if(!isDefined(self.ps_ended)){ return; }
	
	if(self.pers["team"]=="axis")
	{ 
		self playSound(self.bc); 
		wait 3;
		self closeMenu(); //not working on qm menu
		self closeInGameMenu(); //not working on qm menu
	}
	else if(self.pers["team"]=="allies" && message[0] == "c")
	{
		cl("message: " + message);
		self playSound(message);
		wait 3;
	}	
	
	cl("taunt");
}

_player_radio_menu()
{
	self endon("death");
	self endon("disconnect");
	self endon("intermission");
	level endon("game_ended");
	
	if(self.isbot){ return; }
	
	for(;;)
	{
		level waittill("radio_chatter", message, sender);
				
		if(!isAlive(self)){ continue; }
		
		self.message = message;
		
		if(isSubStr(message, "rc_t_"))
		{
			//level.axisRadioQueue[level.axisRadioQueue.size] = self;
		}
		else if(isSubStr(message, "rc_ct_"))
		{
			level.alliesRadioQueue[level.alliesRadioQueue.size] = self;
		}
	}
}

_player_taunts_menu()
{
	self endon("death");
	self endon("disconnect");
	self endon("intermission");
	level endon("game_ended");
	
	if(self.isbot){ return; }
	
	for(;;)
	{
		level waittill("taunt_chatter", message, sender);
				
		if(!isAlive(self)){ continue; }

		if(isSubStr(message, "taunt"))
		{
			self _player_taunt(message);
		}
	}
}

_bot_radio_queue(message)
{
	self.message = message;
	level.alliesRadioQueue[level.alliesRadioQueue.size] = self;
}

_bot_radio_contact()
{
	self endon("death");
	self endon("disconnect");
	self endon("intermission");
	level endon("game_ended");
	
	if(self.pers["team"] != "allies"){ return; }
	
	wait randomFloatRange(3, 9);
	
	for(;;)
	{
		if(level.playerLives["allies"] < 2){ return; }
		
		while(!isDefined(self.hasEnemyTarget)){ wait 1; }
		
		self _bot_radio_queue("rc_ct_141_contact");
		
		for(c = 0; c < 8; c++)
		{
			if(!isDefined(self.hasEnemyTarget)){ break; }
			if(c > 6){ self _bot_radio_queue("rc_ct_161_backup"); }
			
			wait 1;
		}

		for(c = 0; c < 5; c++)
		{
			if(isDefined(self.hasEnemyTarget)){ break; }
			if(c > 3){ self _bot_radio_queue("rc_ct_131_clear"); }
			
			wait 1;
		}

		wait 1;
	}		
}

_bot_radio_moveout()
{
	level endon("game_ended");
				
	wait randomFloatRange(2, 5);
		
	players = getentarray( "player", "classname" );
	for(i = 0; i < players.size; i++ )
	{
		player = players[i];
		
		if(isAlive(player) && player.pers["team"] == "allies")
		{
			player thread _bot_radio_queue("rc_ct_211_go");
			break;
		}
	}
}

_bot_radio_get_out()
{
	level endon("game_ended");

	for(;;)
	{		
		level waittill("incoming", item);
				
		if
		(
			item != "airstrike_mp" 
			&& item != "artillery_mp"
		)
		{ 
			continue; 
		}
		
		wait randomFloatRange(2, 5);
		
		players = getentarray( "player", "classname" );
		for(i = 0; i < players.size; i++ )
		{
			player = players[i];
			
			if(isAlive(player) && player.pers["team"] == "allies")
			{
				player _bot_radio_queue("rc_ct_171_blow");
				break;
			}
		}
	}
}

_bot_radio_secure_area()
{
	level endon("game_ended");

	for(;;)
	{		
		level waittill("bomb_planted", player);
		
		wait randomFloatRange(1, 3);
		
		player _bot_radio_queue("rc_ct_231_secure_this_area");
	}
}

_bot_radio_bomb()
{
	level endon("game_ended");

	for(;;)
	{		
		level waittill("bomb_planted", player);
		
		timer = getDvarFloat("scr_sab_bombtimer");
		
		wait timer - randomFloatRange(1, 3);
		
		players = getentarray( "player", "classname" );
		for(i = 0; i < players.size; i++ )
		{
			player = players[i];
			
			if(isAlive(player) && player.pers["team"] == "allies")
			{
				player thread _bot_radio_queue("rc_ct_171_blow");
				break;
			}
		}
	}
}

_bot_affirm_follow_player()
{
	self endon("death");
	self endon("disconnect");
	self endon("intermission");
	level endon("game_ended");
	
	for(;;)
	{
		self waittill("bot_follow", player);
		
		if(!isDefined(player)){ continue; }
		
		self thread _bot_radio_queue("rc_ct_111_roger");
	}
}