#include scripts\cl;
#include scripts\pl;

init()
{		
	level thread _player_connected();
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
			self thread _radio_init();
			
			self thread _dev_radio();
		}
		else
		{
			self thread _bot_radio();
		}
	}
}