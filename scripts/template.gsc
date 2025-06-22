#include maps\mp\_load;
#include maps\mp\_utility;
#include scripts\cl;

init()
{
	setDvar( "bots_aim_ext", 1 );
	
	if (!getdvarint("developer")>0){ return; }
	
	precacheShader("compass_waypoint_defend");
	precacheShader("compass_waypoint_target");
	precacheShader("compass_waypoint_bomb");
	
	if(!isDefined(getDvar( "bots_nav_enable"))){ setDvar( "bots_nav_enable", ""); }
	setDvar( "bots_play_move", false );
	
	level.bomb = undefined;
	//level.nodes = [];
	//level.nodes_quantity = 0;
			
	for(;;)
    {
		level waittill("connected", player);
		player thread _start();
		wait 0.05;
	}
}

// var = !var

_template(){
	self endon ( "disconnect" );
	self endon ( "death" );
	self endon ( "intermission" );
	level endon( "game_ended" );
	
	//if (!getdvarint("developer")>0){ return; }
	//if(self.isbot){ return; }
	
	for(;;)
	{
	
		wait 0.05;
	}
}

_start()
{
	self endon ( "disconnect" );
	//self endon ( "intermission" );
	//self endon ( "death" );
	level endon( "game_ended" );
	
	if (!self.isbot){ return; }
	
	self waittill("spawned_player");
	cl("_start started on "+self.name);
	
	for(;;)
	{
		if(isAlive(self))
		{
			wait 1;
		}
		
		wait 1;
	}
}
