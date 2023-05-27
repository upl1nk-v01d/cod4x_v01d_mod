#include maps\mp\_load;
#include maps\mp\_utility;
#include scripts\cl;
#include scripts\pl;

init()
{	
	//if(getDvar("v01d_dev") == ""){ setDvar("v01d_dev",1); }

	if (getDvar("v01d_dev") == "nav"){
		//setdvar( "developer_script", 1 );
		//setdvar( "developer", 1 );		
		//setdvar( "sv_mapRotation", "map " + getDvar( "mapname" ) );
		//exitLevel( false );
		setDvar( "bots_play_move", 0 );
		setDvar( "bots_fire_ext", 0 );
		setDvar( "bots_aim_ext", 0 );
		level.doNotAddBots=true;

	}
	
	//if (!getdvarint("v01d_dev")>0){ return; }
	if (getdvarint("bots_main_debug")>0) { return; }
	
	//if (level.waypointCount != 0) { return; }
}

_start_tactical()
{
	self endon ( "disconnect" );
	//self endon( "intermission" );
	//self endon( "death" );
	self endon( "game_ended" );
	
	//if(getDvar( "bots_nav_enable") != true ) { return; }
	//if (!self.isbot){ return; }
	//if (!getdvarint("developer")>0){ return; }
	//cl("_start_tactical started on "+self.name);
	
	self waittill("spawned_player");
	if(self.isbot) { 
		self.execute=true; 
	} else {
		self.squad=[];
	}
	
	if (getdvarint("developer")>0){ 
		//if (!self.isbot) { self thread _openMap(); }
	}
	
}

_add_some_bots(bots){
	setDvar( "testclients_doreload", true );
	wait 0.1;
	setDvar( "testclients_doreload", false );
	if(!isDefined(bots)){ bots=10; }
	for(i=0;i<bots/2;i++){
		setDvar("ab", "axis");
		wait 1.5;
		setDvar("ab","allies");
		wait 1.5;
	}
}

_bot_self_nav(){
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	if (!getdvarint("developer")>0){ return; }
	if (!self.isbot) { return; }

	for(;;){
		if(isAlive(self)){
			//self.execute=true;
			//cl("executed");	
			wait 5;
		}
		wait 1;
	}
}

_openMap(){
	self beginLocationSelection( "map_artillery_selector", level.artilleryDangerMaxRadius * 1.2 );
	self endon( "stop_location_selection" );
	self waittill( "confirm_location", location );
	objective_add( 15, "active", location, "compass_waypoint_target" );
	objective_team( 15, self.pers["team"] );
	self playLocalSound( "mp_suitcase_pickup" );
	wait 0.3;
	self endLocationSelection();
	level.mapPos = location;
	self iprintln(location);
	return true;
}



_hud_draw_tagged(){
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );	
	if (getDvar("v01d_dev") != "nav"){ return; }
	if (self.isbot) { return; }

	for(;;){
		myAngles = self GetPlayerAngles();
		startPos = self getEye();
		startPosForward = startPos + anglesToForward( ( myAngles[0], myAngles[1], 0 ) ) * 1200;
		trace = bulletTrace( startPos, startPosForward, true, self );
		bot = trace["entity"];
		
		if(isDefined(bot)){ 
			if (isDefined(bot.team) && bot.team == self.team){
				self.hud_tagged = newClientHudElem(self); 
				self.hud_tagged SetTargetEnt(bot); 
				self.hud_tagged SetShader( "compass_waypoint_bomb", 15, 15 );
				self.hud_tagged.alpha = 0.5;
				self.hud_tagged SetWayPoint(true, "compass_waypoint_bomb");
			}
		}
		
		wait 0.1;
		if (isDefined(self.hud_tagged)){
			self.hud_tagged Destroy();
		}
	}
}

_hud_draw_squad(){
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );	
	if (getDvar("v01d_dev") != "nav"){ return; }
	if (self.isbot) { return; }
	
	//cl("^3starting _hud_draw_squad thread on "+self.name);
	dist = 0; size=0; threshold=100;
	
	for(;;){
		objs = self.squad;	
		if (isDefined(objs)){
			closest = 2147483647;
			for( i = 0 ; i < objs.size ; i++ ){
				if(isDefined(objs[i])){
					self.hud_squad[i] = newClientHudElem( self ); 
					self.hud_squad[i] SetTargetEnt(objs[i]); 
					if(objs[i].marked) { self.hud_squad[i] setShader( "compass_waypoint_defend", 15, 15 ); }
					else { self.hud_squad[i] setShader( "compass_waypoint_bomb", 15, 15 ); }
					self.hud_squad[i].alpha = 0.5;
					//self.hud_squad[i].x = objs[i].origin[0]; self.hud_squad[i].y = objs[i].origin[1]; self.hud_squad[i].z = objs[i].origin[2];
					if(objs[i].marked) { self.hud_squad[i] SetWayPoint(true, "compass_waypoint_defend"); }
					else { self.hud_squad[i] SetWayPoint(true, "compass_waypoint_bomb"); }
				}
			}
			//self iprintln("^3level.nodes.size:"+objs.size);
		}
		wait 0.1;
		if (isDefined(objs)){
			for( i = 0 ; i < objs.size ; i++ ){ 
				if(isDefined(objs[i])){ self.hud_squad[i] Destroy(); } 
			}
		}
	}
}

_add_remove_squad(bot){
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );	
	if (getDvar("v01d_dev") != "nav"){ return; }
	if (self.isbot) { return; }
	
	exists=false;
	
	if(!isDefined(self.squad)){ self.squad = []; }
	for(i=0;i<self.squad.size;i++){
		if(self.squad[i] == bot){ exists=true; }
	}
	if(exists==false){
		self.squad[self.squad.size] = bot;
		bot.marked=true;
		bot.approachNode = undefined;
		self thread _squad_add_remove_snd("followme");
	} else { 
		self.squad = scripts\main::_arr_remove(self.squad,bot); 
		bot.approachNode = undefined;
		bot.marked=false;
		self thread _squad_add_remove_snd("regroup");
		cl("^2"+self.name+" removed "+bot.name+" teammate"); 
	}

	for(i=0;i<self.squad.size;i++){
		cl("^2"+self.name+" has "+self.squad[i].name+" teammate");
	}
		
	if (isAlive(self)){
		cl("^2"+self.name+" has "+self.squad.size+" squad size");
	}
}

_squad_add_remove_snd(cmd){

	pl(cmd);
	if(!isDefined(cmd)){ cmd="followme"; }
	if (isAlive(self)){
		if (self.team == "allies"){
			if (cmd=="execute"){ self playSound("US_mp_cmd_movein"); }
			if (cmd=="followme"){ self playSound("US_mp_cmd_followme"); }
			if (cmd=="regroup"){ self playSound("US_mp_cmd_regroup"); }
			//else { self playSound("US_mp_cmd_followme"); }
		} else {
	          	//self playSound("t_taunt"+randomIntRange(1, 6));
			switch ( self.pers["team"] ) {
			case "axis":
				self playSound("t_taunt"+randomIntRange(1, 6)); 
				break;
			case "allies":
				self playSound("ct_taunt"+randomIntRange(1, 6));
				break;
			default:
				break;
			}
		}
	}
}
