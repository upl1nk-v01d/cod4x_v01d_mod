#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include scripts\cl;
#include scripts\pl;
#include scripts\bots_utilities;

init()
{
	if (getDvar("v01d_bots") != "1")
	{
		init_botwarfare();
		
		return;
	}
	
	/*if(getDvar("v01d_dev") != "nav")
	{
		setDvar("v01d_dev","nav");
		setDvar("scr_game_spectatetype", "2"); 
		exec("map mp_ancient_ultimate");
	}*/
	
	cl("v01d bots is active!");
	//_toggle_ineedbots(0);
	
	//level.doNotAddBots=true;
	level.bots = 0;
	level.botNames = _read_text_file("botnames.txt"); 
	
	level thread scripts\bots_navigation::init();
	level thread scripts\bots_tactics::init();
	
	if(scripts\bots_navigation::_check_if_no_nodes())
	{ 
		init_botwarfare();
		return; 
	}
	
    level thread _player_connecting();
    level thread _player_connected();
}

_player_connecting()
{
	level endon ("disconnect");
	level endon("intermission");
	level endon("game_ended");
		
	for(;;)
	{					
		level waittill("connecting", player);
		
		//cl("player " + player.name + " is connecting");
	
	}
}

_player_connected()
{
	level endon ("disconnect");
	level endon("intermission");
	level endon("game_ended");
		
	for(;;)
	{					
		level waittill("connected", player);
		
		if(getDvar("v01d_dev") != "0" && getDvar("v01d_dev") == "nav" && !player.isbot && level.bots == 0)
		{
			player AllowSpectateTeam("axis",true);
			player AllowSpectateTeam("allies",true);
		
			bot = level scripts\bots_utilities::bot_add("axis");
			bot = level scripts\bots_utilities::bot_add("axis");
			bot = level scripts\bots_utilities::bot_add("axis");
			bot = level scripts\bots_utilities::bot_add("allies");
			bot = level scripts\bots_utilities::bot_add("allies");
			bot = level scripts\bots_utilities::bot_add("allies");
			//wait 0.1;
			//_teleport(bot, (2491.21, 1633.58, 56.1249));
			
			//level maps\mp\bots\_bot::add_bot("allies");
		}

		//player thread _bot_connected();

		wait 0.05;
	}
}

_dev_weapons()
{
	self endon ( "disconnect" );
	self endon( "intermission" );
	level endon( "game_ended" );
	
	if(self.isbot){ return; }

	cl("called thread _dev_weapons() on " + self.name);
	
	classes = StrTok("pistol,mg,smg,rpg,sniper", ",");
	pistols = StrTok("aaa,bb,cc", ",");
	snipers = StrTok("111,22,33", ",");
	
	c1 = [];
	
	for(;;)
	{
		while (!self LeanLeftButtonPressed()){ wait 0.05; }
		
		for(i = 0; i < classes.size; i++)
		{
			c1[classes[i]] = i;
		}
		
		r = GetArrayKeys( c1 );
		for(i = 0; i < r.size; i++)
		{
			cl(r[i]);
		}
		
		while (self LeanLeftButtonPressed()){ wait 0.05; }
		
		wait 0.05;
	}
}
