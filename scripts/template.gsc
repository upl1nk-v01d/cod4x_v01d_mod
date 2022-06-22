#include maps\mp\_load;
#include maps\mp\_utility;

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

_start()
{
	self endon ( "disconnect" );
	//self endon( "intermission" );
	//self endon( "death" );
	self endon( "game_ended" );
	if (!self.isbot){ return; }
	
	self waittill("spawned_player");
	cl("_start started on "+self.name);
	
	for(;;){
		if(isAlive(self)){
			wait 1;
		}
		wait 1;
	}
}

cl(txt){
	if (isDefined(txt)){ print("-- "+txt+" -- \n"); }
	else { print("!! undefined !! \n"); }
}
