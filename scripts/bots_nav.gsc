#include maps\mp\_load;
#include maps\mp\_utility;

init()
{
	setDvar( "bots_play_move", true );
	if (!getdvarint("developer")>0){ return; }
	
	//if (level.waypointCount != 0) { return; }

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

_nav_loop(){
	self endon ( "disconnect" );
	//self endon( "intermission" );
	//self endon( "death" );
	self endon( "game_ended" );
	if (!self.isbot){ return; }
	
	r = randomFloatRange(1.2,1.4);

	for(;;){
		if(isAlive(self)){
		
			bot_angles = self GetPlayerAngles();
			startPos = self getEye();
			
			//bt_X_angles_arr = StrTok(-45+","+-33.75+","+-22.5+","+-11.25+","+0+","+11.25+","+22.5+","+33.75+","+45,"," );
			bt_X_angles_arr = -60;
			bt_startPos_arr = [];
			bt_trace_arr = [];
			bt_pos_arr = [];
			for(i=0;i<5;i++){
				bt_startPos_arr = startPos + anglesToForward( ( bot_angles[0]+5, bot_angles[1]+bt_X_angles_arr, 0 ) ) * 560;
				if(i==0 || i==4) { bt_startPos_arr = startPos + anglesToForward( ( bot_angles[0], bot_angles[1]+bt_X_angles_arr, 0 ) ) * 560; }
				if(i==2) { bt_startPos_arr = startPos + anglesToForward( ( bot_angles[0]+10, bot_angles[1]+bt_X_angles_arr, 0 ) ) * 320; }
				if(i==5) { bt_startPos_arr = startPos + anglesToForward( ( bot_angles[0], bot_angles[1], 0 ) ) * -160 ; }
				trace = bulletTrace( startPos, bt_startPos_arr, false, self );
				bt_pos_arr[i] = trace["position"];
				//cl(bt_X_angles_arr);
				bt_X_angles_arr += 30;
			}
				
			if(isDefined(self.approachNode)){
				self.moveToPos = self.approachNode;
			} else {
				self.moveToPos = self.origin;
			}
			
			self _calc_dist(bt_pos_arr);
			//self.moveToPos = self _calc_dist(bt_pos_arr);
			aimspeed = 0.1 + (distance( self.origin, self.moveToPos )*0.01);
			r = 0.05+aimspeed*0.1;
			//aimspeed = 0.3;
			dist = distance( self.origin, self.moveToPos );
			//iprintln(self.name+":"+speed);
			if (!isDefined(self.bot.target)){
				//self thread _aim_speed(self.moveToPos,aimspeed); 
				if (isDefined(self.nodeAngles)) { 
					self setPlayerAngles((0, self.nodeAngles[1], 0));
				}
			}
		}
	wait r;
	}
}

_calc_dist(bt_pos_arr){
	closest = 2147483647; a=undefined; h=0; dist = [];
	for(i=0;i<bt_pos_arr.size;i++){
		dist[i] = distance( self.origin, bt_pos_arr[i] );
		//cl(dist[i]);
	}
	
	for(i=0;i<dist.size;i++){
		if(dist[i]<closest){ closest = dist[i]; h=i; }
		//else if (dist[arr.size-1] > 60 ) { closest = dist[1]; h=arr.size-1; }
	}

	//self.approachNode = undefined;
	if (dist[3] > 500 ) { closest = dist[1]; h=1; }
	else if (dist[1] > 500 ) { closest = dist[3]; h=3; }
	else if (dist[2] > 220 ) { closest = dist[2]; h=2; }
	else if (dist[2] < 50 ) { closest = dist[4]; h=4; self.approachNode = undefined; }
	else if (dist[0] > 50 && dist[0] < 90) { closest = dist[4]; h=4; }
	else if (dist[4] > 50 && dist[4] < 90) { closest = dist[0]; h=0; }
	else if (dist[3] < 30 ) { closest = dist[1]; h=1; self.approachNode = undefined; }
	else if (dist[1] < 30 ) { closest = dist[3]; h=3; self.approachNode = undefined; }
	//else if (dist[5] < 120 ) { closest = dist[5]; h=5; iprintln(self.name+":back"); }
	
	//else if (dist[0] < 60 ) { closest = dist[2]; h=0; iprintln(self.name+":right"); }
	//else if (dist[2] < 60 ) { closest = dist[0]; h=2; iprintln(self.name+":left"); }

	a = bt_pos_arr[(bt_pos_arr.size-1)-h]; 
	//cl(closest);
	self thread _bot_hud_bt(bt_pos_arr,h);

	//wait 0.05;
	//iprintln(arr[0]);
	return a;
}

/* _calc_nearest_node(){
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	//self endon( "death" );
	if (!self.isbot){ return; }
	
	//self.nodesPassed = [];
	
	for(;;){
		if(isAlive(self)){
			//nodes = level.nodes;	
			closest = 2147483647;
			node = undefined;
			next_node = undefined;
			name = undefined;
			nr = undefined;
			exists = false;
			dist = 0;
			if(isDefined(level.nodes)){
				for( i = 0 ; i < level.nodes.size; i++ ){
					if (isDefined(level.nodes[i].pos)){ 
						dist = distance( self.origin, level.nodes[i].pos ); 
						//if(!isDefined(level.nodes[level.nodes_quantity].names)){ level.nodes[level.nodes_quantity].names = []; }
						//self iprintln("^3"+level.nodes[i].pos);
					}
					
					//if (dist<closest) {
					if (dist < 150 && dist > 50 ) {
						//if(isDefined(self.nodesPassed)) { iprintln("^3"+self.nodesPassed.size); }
						closest = dist;
						node = level.nodes[i].pos;
						name = self.name;
						nr = i;
						if (isDefined(level.nodes[i])){
							//cl("^3"+level.nodes[i].names.size);
							if (level.nodes[i].names.size < 1) { level.nodes[i].names[level.nodes[i].names.size] = name; }
							for( j = 0 ; j < level.nodes[i].names.size; j++ ){
								//cl("^3"+level.nodes[i].names.size);
								//next_node = level.nodes[i].pos; 
								//level.nodes[i].names[j] = self.name;
								if (level.nodes[i].names[j] == name){ 
									exists = true;
								}
							}	
							if (exists == false){
								level.nodes[i].names[level.nodes[i].names.size] = name;
								//cl("^3Register name "+name+" to "+i+" node at "+node); 
								next_node = level.nodes[i].pos;
								cl("^3Register name "+name+" to "+i+" node at "+node); 
								wait 1;
							}
							exists = false;
						}
					}
				}
				wait 0.5;
				//if(isDefined(level.nodes)){ cl(level.nodes.size); }
				if (isDefined(next_node)){ 
						self.moveToPos = next_node;
						self.approachNode = self.moveToPos;
						level.nodes[nr].names[level.nodes[nr].names.size] = name;
				}
				
				while(isDefined(self.approachNode)){
					dist = distance( self.origin, self.moveToPos ); 
					wait 0.5;
					if(dist<30){ 
						self.approachNode = undefined; 
						self.moveToPos = undefined;
						//iprintln(dist);
						wait 5;
					}
				}
			}
		}
		wait 0.05;
	}
} */

/* _reset_nodes(){
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	//self endon( "death" );
	if (!self.isbot){ return; }
	
	for(;;){
		self waittill("death");
		self.nodesPassed = [];
		wait 1;
	}
} */

_bot_move(){
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	//self endon( "death" );
	if (!self.isbot){ return; }
	
	for(;;){
		while(isAlive(self)){
			if (isDefined(self.approachNode) && isDefined(self.moveToPos)){ self botMoveTo(self.moveToPos); }
			wait 1;
		}
		wait 1;
	}
}

_bot_hud_bt(pos,h){

	if (!self.isbot){ return; }
	
	nearest = "compass_waypoint_target";
	farthest = "compass_waypoint_defend";
	between = "compass_waypoint_bomb";

	for(i=0;i<pos.size;i++){
		self.scc = spawn( "script_origin", pos[i],0,64,64 );
		self.scc.targetname = "scc_"+self.name;
	}
	
	self.objs_scc = getentarray( "scc_"+self.name, "targetname" );
	
	for(i=0;i<self.objs_scc.size;i++){
		self.scc_hud[i] = newClientHudElem( self ); 
		
		if(i==h) { 
			self.scc_hud[i] setShader( nearest , 8, 8 ); 
			self.scc_hud[i] SetWayPoint(false, nearest); 
		} else { 
			self.scc_hud[i] setShader( farthest , 8, 8 ); 
			self.scc_hud[i] SetWayPoint(false, farthest); 	
		}
		self.scc_hud[i].alpha = 0.5;
		self.scc_hud[i].x = self.objs_scc[i].origin[0]; self.scc_hud[i].y = self.objs_scc[i].origin[1]; self.scc_hud[i].z = self.objs_scc[i].origin[2]+20;
	}
	

	wait 0.05;
	//wait 1.5;
	//self.objs_scc = getentarray( "scc_"+self.name, "targetname" );
	for(i=0;i<self.objs_scc.size;i++){
		if(isDefined(self.scc_hud[i])){ self.scc_hud[i] Destroy(); }
		if(isDefined(self.objs_scc[i])){ self.objs_scc[i] delete(); }
	}
}

_checkPos(){
	level endon("game_ended");
	self endon("disconnect");
	//self endon( "death" );
	if (!self.isbot){ return; }

	stay_time = 2;
	bot_stay_time = 0;
	max_distance = 30;
	wait 5;
	
	for(;;){
		while(isAlive(self))
		{
			old_position = self.origin;
			wait 1;	
			new_position = self.origin;
		
			distance = distance2d( old_position, new_position );
			if( distance < max_distance )
				bot_stay_time++;
		
			if( bot_stay_time == stay_time ){
				angles = self GetPlayerAngles();
				self setPlayerAngles((0, angles[1]+180, 0));
				bot_stay_time=0;
				wait 2;
			}
		}
		wait 0.05;
	}
}

/* _place_markers(pos){
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	if(self.isbot){ return; }
	
	self waittill("spawned_player");
	wait 1;
	
	while(isAlive(self)){
		self.objs = getentarray( "markers_"+self.name, "targetname" );		
		closest = 2147483647;
		dist = 0;
		for( i = 0 ; i < self.objs.size ; i++ ){
			self.markers[i] = newClientHudElem( self ); 
			self.markers[i] setShader( "compass_waypoint_bomb", 15, 15 );
			self.markers[i].alpha = 0.5;
			self.markers[i].x = self.objs[i].origin[0]; self.markers[i].y = self.objs[i].origin[1]; self.markers[i].z = self.objs[i].origin[2]+32;
			self.markers[i] SetWayPoint(true, "compass_waypoint_bomb");
			
			if (isDefined(self.objs[i])){ 
				dist = distance( self.origin, self.objs[i].origin ); 
				//self iprintln("^3"+dist);
			}
			if (dist < closest ) {
				closest = dist;
			}
			if(self.objs.size>2){
				if (isDefined(self.objs[0])){ 
					self.objs[0] delete();
				}
			}
		}
		
		if (closest > 300 ) {
			marker = spawn( "script_origin", self.origin,0,64,64 );
			marker.targetname = "markers_"+self.name;
			if(!self.isbot) { 
				self thread _add_wpt(self.origin); 
			}
		}
		
		wait 1;
		for( i = 0 ; i < self.objs.size ; i++ ){ self.markers[i] Destroy(); }
	}
	self.objs = getentarray( "markers_"+self.name, "targetname" );		
	for( i = 0 ; i < self.objs.size ; i++ ){ 
		if(isDefined(self.markers[i])) { self.markers[i] Destroy(); }
		if(isDefined(self.objs[i])) { self.objs[i] delete(); }
	}
} */

_room_center_node(){	
	if(!self.isbot){
		for(;;){
			if(isAlive(self)){
				if(isDefined(self.test_hud) && isDefined(self.test)){
					for(i=0;i<self.test.size;i++){
						if(isDefined(self.test_hud[i])){ self.test_hud[i] Destroy(); }
						if(isDefined(self.test[i])){ self.test[i] delete(); }
					}			
				}
				angles = self GetPlayerAngles();
				Pos = self getEye();
				startPos = (Pos[0],Pos[1],Pos[2]);
				//startPos = self getEye();
				bt_X_angles_arr = 0;
				bt_startPos_arr = [];
				bt_trace_arr = [];
				bt_pos_arr = [];
				for(i=0;i<4;i++){
					bt_startPos_arr = startPos + anglesToForward( ( angles[0]+5, angles[1]+bt_X_angles_arr, 0 ) ) * 260;
					trace = bulletTrace( startPos, bt_startPos_arr, false, self );
					bt_pos_arr[i] = trace["position"];
					bt_X_angles_arr += 90;
					self.test[i] = spawn( "script_origin", bt_pos_arr[i],0,64,64 );
					self.test[i].targetname = "test_"+self.name;
					self.test_hud[i] = newClientHudElem( self ); 
					self.test_hud[i] setShader( "compass_waypoint_defend" , 8, 8 ); 
					self.test_hud[i] SetWayPoint(false, "compass_waypoint_defend"); 	
					self.test_hud[i].alpha = 0.5;
					self.test_hud[i].x = bt_pos_arr[i][0]; self.test_hud[i].y = bt_pos_arr[i][1]; self.test_hud[i].z = bt_pos_arr[i][2]+20;
				}
					
				d1 = distance( bt_pos_arr[0], bt_pos_arr[2] )/2;
				d2 = distance( bt_pos_arr[1], bt_pos_arr[3] )/2;
				point = (bt_pos_arr[0][0]+d1/2,bt_pos_arr[0][1],bt_pos_arr[0][2]);
				//point = bt_pos_arr[0];
				//cl(d1);
				//cl(d2);
				self.test[4] = spawn( "script_origin", point,0,64,64 );
				self.test[4].targetname = "test_"+self.name;
				self.test_hud[4] = newClientHudElem( self ); 
				self.test_hud[4] setShader( "compass_waypoint_target" , 8, 8 ); 
				self.test_hud[4] SetWayPoint(false, "compass_waypoint_target"); 	
				self.test_hud[4].alpha = 0.5;
				self.test_hud[4].x = point[0]; self.test_hud[4].y = point[1]; self.test_hud[4].z = point[2]+20;
			}
		wait 4.1;
		}
	}
}

_aim_speed(pos,speed){
	//self endon ( "death" );2
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	if (!self.isbot){return;}
	if (!isDefined(speed)) {speed=0.2;}
	
	self.swc = 1;
	self.pers["bots"]["skill"]["aim_time"] = speed;
	
	//for(;;){
	
		while (self.swc == 1)  { 
			pos = self.moveToPos;		
			if(self.pers["bots"]["skill"]["aim_time"] < 0.2) {self.swc = 0; }
			if(self.pers["bots"]["skill"]["aim_time"] < 0.1) { self.pers["bots"]["skill"]["aim_time"]=1.7; }
			self.pers["bots"]["skill"]["aim_time"] *= 0.9;
			if(isDefined(pos)){ self botLookAt( pos, self.pers["bots"]["skill"]["aim_time"] ); }
			//if (isDefined(pos)){ self botMoveTo(pos); }
			angles = self getPlayerAngles();
			self setPlayerAngles((0, angles[1], 0)); 
			wait 0.05;
			//self botLookAt( (0,0,0), 0.1 );
			
		} 
		while (self.swc == 0) {
			pos = self.moveToPos;		
			self.pers["bots"]["skill"]["aim_time"] *= 1.2; 
			if(self.pers["bots"]["skill"]["aim_time"] > 2) { self.swc = 1; }
			if(isDefined(pos)){ self botLookAt( pos, self.pers["bots"]["skill"]["aim_time"] ); }
			//if (isDefined(pos)){ self botMoveTo(pos); }
			angles = self getPlayerAngles();
			self setPlayerAngles((0, angles[1], 0)); 
			wait 0.05;
		}
	pos=undefined;
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

/* _add_node(pos)
{
	level.nodes[level.nodes_quantity] = spawnstruct();
	level.nodes[level.nodes_quantity].pos = pos;
	level.nodes[level.nodes_quantity].type = self getStance();
	level.nodes[level.nodes_quantity].angles = self getPlayerAngles();
	level.nodes[level.nodes_quantity].names = [];
	//iprintln("node added at "+pos); 
	cl("node added at "+pos); 
	level.nodes_quantity++;
}

_add_nodes(pos){
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	//if(self.isbot){ return; }
	
	for(;;){
		wait 1;
		while(isAlive(self)){
			self.objs = level.nodes;	
			closest = 2147483647;
			dist = 0;
			if(isDefined(self.objs)){
				for( i = 0 ; i < self.objs.size ; i++ ){
					if (isDefined(self.objs[i].pos)){ 
						dist = distance( self.origin, self.objs[i].pos ); 
						//self iprintln("^3"+dist);
					}
					if (dist < closest ) {
						closest = dist;
					}
				}
			}
			if (closest > 100 ) {
				self thread _add_node(self.origin);
			}
			wait 1;
		}
	}
}*/

cl(txt){
	if (isDefined(txt)){ print("-- "+txt+" -- \n"); }
	else { print("!! undefined !! \n"); }
}
