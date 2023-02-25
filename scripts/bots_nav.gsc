#include maps\mp\_load;
#include maps\mp\_utility;
#include scripts\cl;

init()
{
	setDvar( "bots_play_move", false );
	setDvar( "bots_fire_ext", 0 );
	setDvar( "bots_aim_ext", 0 );
	level.doNotAddBots=true;
	
	if (getDvar("v01d_dev") == ""){ setdvar("v01d_dev",1); }
	
	if (!getdvarInt("v01d_dev")){
		setdvar( "developer_script", 1 );
		setdvar( "developer", 1 );
		
		setdvar( "sv_mapRotation", "map " + getDvar( "mapname" ) );
		exitLevel( false );
	}

	
	//if (!getdvarint("developer")>0){ return; }
	
	//if (level.waypointCount != 0) { return; }

	precacheShader("compass_waypoint_defend");
	precacheShader("compass_waypoint_target");
	precacheShader("compass_waypoint_bomb");
	
	if(!isDefined(getDvar( "bots_nav_enable"))){ setDvar( "bots_nav_enable", ""); }
	cl("33bots_nav");
	
	level.bomb = undefined;
	//level.nodes = [];
	//level.nodes_quantity = 0;
	
	level thread _player_connecting();
	level thread _add_some_bots(2);
			
	for(;;)
    {
		level waittill("connected", player);
		player thread _player_spawn();
		player thread _start_nav();
		//player thread _checkPos();
		//player thread _place_markers();
		//player thread _reset_nodes();
		//player thread _bot_move();
		//player thread _room_center_node();
		//player thread _aim_speed();
		//player thread _add_nodes();
		//player thread _calc_nearest_node();
	}
}

_arr_remove(arr, remover){
	new_arr = [];
	for (i = 0; i < arr.size; i++ )
	{
		index = arr[i];
		
		if (isDefined(index)){
			if ( index != remover )
				new_arr[ new_arr.size ] = index;
		}
	}
	return new_arr;
}

_player_connecting(){
	level endon ( "disconnect" );
	level endon( "intermission" );
	level endon( "game_ended" );

	//if (getdvarint("developer")>0){ return; }
	//if(self.isbot){ return; }
	
	for(;;){
		level waittill("connecting", player);
		player thread _connecting();
		wait 0.05;
	}
}

_connecting(){
	if (getdvarInt("v01d_dev")>0){
		self setClientDvar( "developer_script", 1 );
		self setClientDvar( "developer", 1 );
		//cl("33connecting");
	}
}

_player_spawn()
{
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "death" );
	self endon( "game_ended" );
	//if (self.isbot){ return; }
	
	self waittill("spawned_player");
	//self thread _draw_grid();
	self thread _grid_loop();
	self thread _draw_nodes();
	
	//self setClientDvars("cg_thirdperson", 1);		
}


_start_nav()
{
	self endon ( "disconnect" );
	//self endon( "intermission" );
	//self endon( "death" );
	self endon( "game_ended" );
	if (!self.isbot){ return; }
	
	self.approachNode = undefined;
	//if(getDvar( "bots_nav_enable") != true ) { return; }
	//if (!self.isbot){ return; }
	//if (!getdvarint("developer")>0){ return; }
	cl("_start_nav started on "+self.name);
	
	self waittill("spawned_player");
	//self thread _add_wpt_for_bomb();
	//self thread _nav_loop();
	
	//self setClientDvars("cg_thirdperson", 1);	
	
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

_draw_grid(){
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "death" );
	self endon( "game_ended" );
	if (self.isbot){ return; }
	
	cl("33draw_grid");
	for(;;){
		while(!self UseButtonPressed()){ wait 0.05; }
		myAngles = self GetPlayerAngles();
		startPos = self getEye();
		startPosForward = startPos + anglesToForward((0,myAngles[1],0))*120;
		trace = bulletTrace(startPos,startPosForward,true,self);
		//pos = trace["position"];
		pos = startPos;
		//ent = trace["entity"];
		if(isDefined(pos)){
			for(i=1;i<=10;i++){
				for(j=1;j<=10;j++){
					trace_down = bulletTrace((pos[0]-(64*10/2)+(i*64), pos[1]-(64*10/2)+(j*64), pos[2]), (pos[0]-(64*10/2)+(i*64)-64, pos[1]-(64*10/2)+(j*64), pos[2]-100), false,self);
					pos2 = trace_down["position"];
					if((i==1 && j==1) || (i==1 && j==10) || (i==10 && j==1) || (i==10 && j==10)){	
						//marker = spawn( "script_origin", (pos2[0],pos2[1],pos2[2]),0,0,0);
						//marker.targetname = "markers_"+self.name;
					}
					//line(fw1, fw2, (1, 1, 0.5), 1, 1, 30);
					//print3d(self.origin, "START", (1.0, 0.8, 0.5), 1, 3, 10000);
					cl("33pos:"+pos2);
					//wait 0.5;
				}
			}
		}
		while(self UseButtonPressed()){	wait 0.05; }
		wait 0.05;
	}wait 0.05;
}

_grid_loop(){
	self endon ( "disconnect" );
	self endon( "intermission" );
	//self endon( "death" );
	self endon( "game_ended" );
	if (!self.isbot){ return; }
	
	self.nodes=[];
	self.nodes_quantity=0;

	cl("33grid_loop");
	//while(isAlive(self)){
		myAngles = self GetPlayerAngles();
		startPos = self getEye();
		startPosForward = startPos + anglesToForward((0,myAngles[1],0))*120;
		trace = bulletTrace(startPos,startPosForward,true,self);
		//pos = trace["position"];
		pos = startPos;
		//ent = trace["entity"];
		if(isDefined(pos)){
			for(i=1;i<=10;i++){
				for(j=1;j<=10;j++){
					trace_down = bulletTrace((pos[0]-(64*10/2)+(i*64), pos[1]-(64*10/2)+(j*64), pos[2]), (pos[0]-(64*10/2)+(i*64)-64, pos[1]-(64*10/2)+(j*64), pos[2]-100), false,self);
					pos2 = trace_down["position"];
					self _add_node(pos2);
					if((i==1 && j==1) || (i==1 && j==10) || (i==10 && j==1) || (i==10 && j==10)){
						//node = spawn( "script_origin", (pos2[0],pos2[1],pos2[2]),0,0,0);
						//node.targetname = "markers_"+self.name;
					}
					//line(fw1, fw2, (1, 1, 0.5), 1, 1, 30);
					//print3d(self.origin, "START", (1.0, 0.8, 0.5), 1, 3, 10000);
					cl("33"+self.name+" pos:"+pos2);
					//wait 0.5;
				}
			}
		}
		wait 0.05;
	//}
}

_add_wpt(pos)
{
	level.waypoints[level.waypointCount] = spawnstruct();
	level.waypoints[level.waypointCount].origin = pos;
	level.waypoints[level.waypointCount].type = self getStance();
	level.waypoints[level.waypointCount].angles = self getPlayerAngles();
	level.waypoints[level.waypointCount].children = [];

	/*if ( self AdsButtonPressed() )
		level.waypoints[level.waypointCount].type = "climb";
	else if ( self AttackButtonPressed() && self UseButtonPressed() )
		level.waypoints[level.waypointCount].type = "tube";
	else if ( self AttackButtonPressed() )
		level.waypoints[level.waypointCount].type = "grenade";
	else if ( self UseButtonPressed() )
		level.waypoints[level.waypointCount].type = "claymore";
	else
		level.waypoints[level.waypointCount].type = self getStance();
	*/

	self iprintln( level.waypoints[level.waypointCount].type + " Waypoint " + level.waypointCount + " Added at " + pos );
	level.waypointCount++;
}

_add_wpt_for_bomb(){
	if(!isDefined(level.bomb)){
		level.bomb = getEnt( "sab_bomb_pickup_trig", "targetname" );
		cl("bombPos " + level.bomb.origin);
		self _add_wpt(level.bomb.origin);
	}
}

_add_node(pos){
	if(isDefined(pos)){
		self.nodes[self.nodes_quantity] = spawnstruct();
		self.nodes[self.nodes_quantity].pos = pos;
		self.nodes[self.nodes_quantity].type = self getStance();
		self.nodes[self.nodes_quantity].angles = self getPlayerAngles();
		self.nodes[self.nodes_quantity].names = [];
		//iprintln("node added at "+pos); 
		//cl("node added at "+pos); 
		cl("self.nodes_quantity: "+self.nodes_quantity); 
		self.nodes_quantity++;
	}
}

_draw_nodes(){
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	if(!self.isbot){ return; }
	
	wait 1;
	
	while(isAlive(self)){
		//self.objs = objs;	
		cl("33self.nodes.size:"+self.nodes.size);	
		//self.objs = getentarray( "markers_"+self.name, "targetname" );		
		closest = 2147483647;
		dist = 0;
		for( i = 0 ; i < self.nodes.size ; i++ ){
			self.markers[i] = newClientHudElem( self ); 
			self.markers[i] setShader( "compass_waypoint_bomb", 15, 15 );
			self.markers[i].alpha = 0.5;
			self.markers[i].x = self.nodes[i].origin[0]; self.markers[i].y = self.nodes[i].origin[1]; self.markers[i].z = self.nodes[i].origin[2]+1;
			self.markers[i] SetWayPoint(true, "compass_waypoint_bomb");
			
			if (isDefined(self.nodes[i])){ 
				dist = distance( self.origin, self.nodes[i].origin ); 
				//self iprintln("^3"+dist);
			}
			if (dist < closest ) {
				closest = dist;
			}
			if(self.nodes.size>2){
				if (isDefined(self.nodes[0])){ 
					//self.nodes[0] delete();
					self.nodes = _arr_remove(self.nodes,self.nodes[0]);
				}
			}
			wait 1;
		}
		
		
		wait 1;
		for( i = 0 ; i < self.nodes.size ; i++ ){ self.markers[i] Destroy(); }
		
		wait 1;
	}
}
