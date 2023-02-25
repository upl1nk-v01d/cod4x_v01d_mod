#include maps\mp\_load;
#include maps\mp\_utility;
#include scripts\cl;

init()
{	
	//if(getDvar("v01d_dev") == ""){ setDvar("v01d_dev",1); }
	//setDvar( "bots_play_move", 0 );
	//setDvar( "bots_fire_ext", 0 );
	//setDvar( "bots_aim_ext", 0 );
	//level.doNotAddBots=true;

	if (getDvarInt("v01d_dev")>0){
		//setdvar( "developer_script", 1 );
		//setdvar( "developer", 1 );		
		//setdvar( "sv_mapRotation", "map " + getDvar( "mapname" ) );
		//exitLevel( false );
	}
	
	//if (!getdvarint("v01d_dev")>0){ return; }
	if (getdvarint("bots_main_debug")>0) { return; }
	
	//if (level.waypointCount != 0) { return; }
	
	level.nodes = [];
	level.nodes_quantity = 0;
	level.node_types = StrTok("any,mg,sniper,grenadier,rocket",",");
	
	level.sniper_weapons = StrTok("tac330_sil_mp,mors_acog_mp,svg100_mp,barrett_mp,dragunov_mp,m40a3_mp,m21_mp",",");
	level.grenade_weapons = StrTok("mm1_mp",",");
	level.rocket_weapons = StrTok("em1_mp,rpg_mp,law_mp",",");
	level.mg_weapons = StrTok("saw_mp,rpd_mp,m60e4_mp",",");

	precacheShader("compass_waypoint_defend");
	precacheShader("compass_waypoint_target");
	precacheShader("compass_waypoint_bomb");
	
	//if(!isDefined(getDvar( "bots_nav_enable"))){ setDvar( "bots_nav_enable", ""); }
	//setDvar( "bots_play_move", false );
	
	level thread _load_nodes();
	//level thread _add_some_bots(2);
	
	for(;;)
    {
		level waittill("connected", player);
		player thread _start_tactical();
		player thread _add_remove_nodes();
		player thread _hud_draw_nodes();
		//player thread _hud_draw_squad();
		//player thread _hud_draw_tagged();
		//player thread _bot_move_to();
		player thread _marked_nodes();
		player thread _save_nodes();
		//player thread _bot_self_nav();
		player thread _bot_take_cover();
		player thread _node_info();
	}
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

_node_info(){
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	if (!getDvarInt("v01d_dev")>0){ return; }
	if (self.isbot) { return; }
	
	for(;;){
		self waittill("showNodeInfo");
		node = self.nodecatch;
		
		if(isDefined(node)){
			self iprintln("^3Node params: nr "+node.id+", pos "+node.pos+",stance:"+node.type+",angles:"+node.angles+",cover:"+node.cover);
		}
		wait 0.5;
	}

}

_add_node(pos)
{
	type = self getStance();
	angles = self getPlayerAngles();
	
	level.nodes[level.nodes_quantity] = spawnstruct();
	level.nodes[level.nodes_quantity].id = level.nodes_quantity+1;
	level.nodes[level.nodes_quantity].pos = pos;
	level.nodes[level.nodes_quantity].type = type;
	level.nodes[level.nodes_quantity].angles = angles;
	level.nodes[level.nodes_quantity].names = [];
	level.nodes[level.nodes_quantity].name = undefined;
	level.nodes[level.nodes_quantity].marked = false;
	level.nodes[level.nodes_quantity].cover = "any";
	//iprintln("node added at "+pos); 
	cl("node "+level.nodes.size+" added at "+pos+",stance:"+type+",angles:"+angles); 
	self iprintln("^3Node params: nr "+level.nodes.size+", pos "+pos+",stance:"+type+",angles:"+angles);
	//level.nodes_quantity = level.nodes.size+1;
	level.nodes_quantity++;
}

_add_remove_nodes(){
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	if (!getDvarInt("v01d_dev")>0){ return; }
	if (getdvarint("bots_main_debug")>0) { return; }  
	if (self.isbot) { return; }
	
	cl("^3_add_nodes started on "+self.name);

	for(;;){
		c=10; self.execute = false;
		while ( !self UseButtonPressed() ){	wait (0.05); }
		//wait 1;
		
		while ( self UseButtonPressed() && c>0){ 
			c--; wait 0.05;
		}
		
		if (c<=0){ 
			cl("^1EXECUTE"); self thread _squad_add_remove_snd("execute");
			if(isDefined(self.squad)){ 
				for(i=0;i<self.squad.size;i++){
					self.squad[i].execute = true;
				}
			}
			//while (self.execute==true){ wait 1; }
			wait 0.2;
		}
		
		//if (!self UseButtonPressed()){ continue; } 
		if (self.pers["team"] != "spectator" && c>0) {
			delete=false; change=false; 
			myAngles = self GetPlayerAngles();
			startPos = self getEye();
			startPosForward = startPos + anglesToForward( ( myAngles[0], myAngles[1], 0 ) ) * 1200;
			trace = bulletTrace( startPos, startPosForward, true, self );
			//pos = trace["position"];
			pos = trace["position"];
			bot = trace["entity"];
			self PingPlayer();
			
			if(isDefined(bot) && bot.classname == "player"){
				self thread _add_remove_squad(bot);
			} else if(isDefined(self.squad) && self.squad.size<1){
				objs = level.nodes;	
				self.closest = undefined;
				closest = 2147483647;
				nr=undefined;
				if (objs.size>0){
					for( i = 0 ; i < objs.size ; i++ ){
						if(isDefined(objs[i])){
							dist = distance( pos, objs[i].pos ); 
							if(dist<70){ nr=i; closest=dist; }
						}
					}
					
					if(isDefined(nr) && isDefined(closest)){ cl("^3"+closest+" to "+nr); }
					
					if (isDefined(nr)) {
						if(isDefined(objs[nr].cover)) { 
							for(i=0;i<level.node_types.size;i++){
								if(objs[nr].cover == level.node_types[i]){
									objs[nr].cover = level.node_types[i+1]; 
									if(isDefined(objs[nr].cover)){
										change = true; cl("^3Node changed to type "+objs[nr].cover);
										self iprintln("^3Node changed to type "+objs[nr].cover);
										self notify("showNodeInfo");
									}
									break;
								}
								change = false;
							}
						} 
						if (change == false){
							self iprintln("^3deleting:"+nr);
							delete = true; cl("delete");
							level.nodes = scripts\main::_arr_remove(objs,objs[nr]);
							level.nodes_quantity=level.nodes.size;
							objs = undefined;
							self iprintln("^3Node deleted");
						}
					}
				} 
				if (delete == false && change == false){ 
					self _add_node((self.origin[0],self.origin[1],self.origin[2]-20)); 
					//self _add_node((pos[0],pos[1],pos[2]-20)); 
					delete = false; change = false; 
					self iprintln("^3Node added");
				}
				wait 0.2;	
			}	
		}
		
	while( self UseButtonPressed() ){ wait (0.05); }
	wait (0.05);
	}
}

/*_bot_move_to(commander){
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	//self endon( "death" );
	if (!self.isbot){ return; }
	//self.nodesPassed = [];
	self.reachedNode = -1;
	self.execute = false;

	for(;;){
		if(isAlive(self)){
			while (isDefined(self.execute) && self.execute==false) { wait 0.5; }
			closest = 2147483647;
			node = undefined;
			name = undefined;
			nr = undefined;
			exists = false;
			dist = 0;
			marker_pos=undefined;
			self.campAtSpot=false;
			
			if(isDefined(level.nodes)){
				for( i = 0 ; i < level.nodes.size; i++ ){
					dist = distance(self.origin, level.nodes[i].pos); 
					for( j = 0;j<level.nodes[i].names.size; j++ ){
						if (level.nodes[i].names[j] == self.name){ 
							exists = true;
						}
					}	
					if (exists == false){
						level.nodes[i].names[level.nodes[i].names.size] = self.name;
					}
					
					if (dist > 30 && dist < 350 && !isDefined(self.approachNode)) {
						//cl("^3"+self.name+" is to "+dist);
						closest = dist;
						self.nodeAngles = level.nodes[i].angles;
						self.nodeCover = level.nodes[i].type;
						self.moveToPos = level.nodes[i].pos;
						self.approachNode = self.moveToPos;
						//level.nodes[i].name=self.name;
						name = self.name;
						nr = i;
					}
				}
				
				
				if (isDefined(self.moveToPos) && isDefined(nr)){ 
					level.nodes[nr].name=name;
					self.campAtSpot=false;
					
					weapon = self GetCurrentWeapon();
					cl(weapon); 
					self.hasSniper=false;
					for(i=0;i<level.sniper_weapons.size;i++){
						if (weapon == level.sniper_weapons[i]){ self.hasSniper=true; break; }
					}
					
		 			if (self.hasSniper && self.nodeCover == "sniper"){
						//self thread maps\mp\bots\_bot_utility::SetScriptGoal(self.moveToPos,48);
						//self botMoveTo(self.moveToPos);
						
						cl("^3"+self.name+" is moving to "+self.moveToPos);
						//self botLookAt( self.approachNode, self.pers["bots"]["skill"]["aim_time"] );
			
						while(isDefined(self.approachNode)){
							dist = distance( self.origin, self.moveToPos ); 
							//self botMoveTo(self.moveToPos);
							//cl("^3"+name+" dist to "+nr+" is "+dist);
							wait 0.1;
							if(dist>64){ 
								self maps\mp\bots\_bot_utility::SetScriptGoal(self.moveToPos,30);
								self.campAtSpot=false;
								//self.bot.stop_move=true;
							}
							if(dist<=150 && dist>64){ 
								self botAction( "+gocrouch" );
								//cl("^3"+name+" dist to "+nr+" is "+dist);
								//self maps\mp\bots\_bot_script::CampAtSpot(self.moveToPos, self.moveToPos + AnglesToForward(self.nodeAngles) * 2048);
							}
							if(dist<=64 || isDefined(self.approachNode) ){ 
								cl("^3"+self.name+" reached goal at"+self.moveToPos);
								if(isDefined(self.nodeCover) && self.nodeCover != "no_cover" ){ self botAction( "+go"+ self.nodeCover); }
								else { self botAction( "+gocrouch"); }
								self.execute = false;
								self setPlayerAngles(self.nodeAngles);
								cl(self.name+":"+self.nodeAngles);
								self.campAtSpot=true;
								self.bot.stop_move=true;
								wait 5;
								self.bot.stop_move=false;
								self.moveToPos = undefined;
								self.approachNode = undefined; 
								self.execute=true;
								self.campAtSpot=false;
							}
						}
					}
				}
			}
		}
		wait 0.5;
	}
}*/

_bot_take_cover(){
	self endon("disconnect");
	self endon("game_ended");
	if (!self.isbot){ return; }
	
	for(;;){
	
		if (isAlive(self)){

			wait 1;
			
			closest = 2147483647;
			exists = false;
			dist = 0;
			node=undefined;
			
			if(isDefined(level.nodes)){
			
				weapon = self GetCurrentWeapon();
				self.hasSniper=false;
				self.hasGrenadeLauncher=false;
				self.hasRocketLauncher=false;
				self.hasMG=false;
				for(i=0;i<level.sniper_weapons.size;i++){
					if (weapon == level.sniper_weapons[i]){ self.hasSniper=true; break; }
				}
				for(i=0;i<level.grenade_weapons.size;i++){
					if (weapon == level.grenade_weapons[i]){ self.hasGrenadeLauncher=true; break; }
				}
				for(i=0;i<level.rocket_weapons.size;i++){
					if (weapon == level.rocket_weapons[i]){ self.hasRocketLauncher=true; break; }
				}
				for(i=0;i<level.mg_weapons.size;i++){
					if (weapon == level.mg_weapons[i]){ self.hasMG=true; break; }
				}
				
				if (self.hasSniper || self.hasGrenadeLauncher || self.hasRocketLauncher || self.hasMG){
					for( i = 0 ; i < level.nodes.size; i++ ){
					
						if (isDefined(level.nodes[i].name) && level.nodes[i].name == self.name){ continue; }
						
						for( j = 0;j<level.nodes[i].names.size; j++ ){
							if (level.nodes[i].names[j] == self.name){ 
								exists = true; continue;
							}
						}	
						if (exists == true){
							//level.nodes[i].names[level.nodes[i].names.size] = self.name;
							continue;
						}
						
						dist = distance(self.origin, level.nodes[i].pos); 
						
						if (dist < 1000 && self.hasSniper && level.nodes[i].cover == "sniper") { closest = dist; node=level.nodes[i]; break; }
						else if (dist < 1000 && self.hasMG && level.nodes[i].cover == "mg") { closest = dist; node=level.nodes[i]; break;  }
						else if (dist < 1000 && self.hasGrenadeLauncher && level.nodes[i].cover == "grenadier") { closest = dist; node=level.nodes[i]; break;  }
						else if (dist < 1000 && self.hasRocketLauncher && level.nodes[i].cover == "rocket") { closest = dist; node=level.nodes[i]; break;  }
						else if (dist < 1000 && level.nodes[i].cover == "any") { closest = dist; node=level.nodes[i]; break;  }
					}
					
					if (isDefined(node)){ 
						self.moveToPos = node.pos;
						self.nodeAngles = node.angles;
						self.nodeStance = node.type;
						self.nodeCover = node.cover;
						node.name = self.name;
					
						cl("^3"+self.name+" is moving to "+self.moveToPos);
						//self.bot.stop_move=true;
						//self.bot.isfrozen=true;
						//self thread _bot_move_to_pos(self.moveToPos);
						//self botMoveTo(self.moveToPos);
						//self botLookAt( self.approachNode, self.pers["bots"]["skill"]["aim_time"] );
						self maps\mp\bots\_bot_utility::ClearScriptGoal();
						self maps\mp\bots\_bot_utility::SetScriptGoal(self.moveToPos,48);
						//self.bot.towards_goal=self.moveToPos;
			
						while(isDefined(self.moveToPos) && isAlive(self)){
							dist = distance( self.origin, self.moveToPos );
							wait 0.2;
							//cl(self.name+":"+dist);
							if(dist<64){ 
								cl("^3"+self.name+" reached goal at"+self.moveToPos);
								if(isDefined(self.nodeStance) && self.nodeStance != "any" ){ self botAction( "+go"+ self.nodeStance); }
								else { self botAction( "+gocrouch"); }
								self maps\mp\bots\_bot_script::CampAtSpot(self.moveToPos, self.moveToPos + AnglesToForward(self.nodeAngles) * 2048);
								self setPlayerAngles(self.nodeAngles);
								//cl(self.name+":"+self.nodeAngles);
								self.bot.stop_move=true;
								self.moveToPos = undefined;
								wait 5;
								self.bot.stop_move=false;
							}
							else if(dist<=150 && dist>100){ 
								//self botAction( "+gocrouch" );
								//cl("^3"+name+" dist to "+nr+" is "+dist);
							}
							else if(dist>64){ 
								//self maps\mp\bots\_bot_utility::ClearScriptGoal();
								//self maps\mp\bots\_bot_utility::SetScriptGoal(self.moveToPos,48);
								//self maps\mp\bots\_bot_script::CampAtSpot(self.moveToPos, self.moveToPos + AnglesToForward(self.nodeAngles) * 2048);
							}
						}
					}
				}
			}
		}
		wait 0.05;
	}
}

_bot_move_to_pos(pos){
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	self endon( "death" );
	if (!self.isbot) { return; }
	
	while(isDefined(self.moveToPos)){
		node=undefined;
		closest=10000000;
		for( i = 0 ; i < level.nodes.size; i++ ){
			dist = distance(self.origin, level.nodes[i].pos);
			if(dist < closest) { 
				closest = dist; 
				node=level.nodes[i];
			}
		}
		
		if (isDefined(node)){ 
			self.nodeAngles = node.angles;
			self.nodeStance = node.type;
			self.nodeCover = node.cover;
			node.name = self.name;
		
			cl("^3"+self.name+" is moving to "+node.pos);
			self botMoveTo(node.pos);
			while(isDefined(node.pos) && isAlive(self)){
				dist = distance(self.origin, node.pos);
				wait 0.2;
				//cl(self.name+":"+dist);
				if(dist<32){ 
					cl("33"+self.name+" reached node at"+node.pos);
					//if(isDefined(self.nodeStance) && self.nodeStance != "any" ){ self botAction( "+go"+ self.nodeStance); }
					//else { self botAction( "+gocrouch"); }
					//self maps\mp\bots\_bot_script::CampAtSpot(self.moveToPos, self.moveToPos + AnglesToForward(self.nodeAngles) * 2048);
					//self setPlayerAngles(self.nodeAngles);
					//cl(self.name+":"+self.nodeAngles);
					//self.bot.stop_move=true;
					node.pos = undefined;
					//wait 5;
					//self.bot.stop_move=false;
				}
				else if(dist<=150 && dist>100){ 
					//self botAction( "+gocrouch" );
					//cl("^3"+name+" dist to "+nr+" is "+dist);
				}
				else if(dist>64){ 
					//self maps\mp\bots\_bot_utility::ClearScriptGoal();
					//self maps\mp\bots\_bot_utility::SetScriptGoal(self.moveToPos,48);
					//self maps\mp\bots\_bot_script::CampAtSpot(self.moveToPos, self.moveToPos + AnglesToForward(self.nodeAngles) * 2048);
				}
			}
		}
	}
}

_marked_nodes(){
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	if (!getDvarInt("v01d_dev")>0){ return; }
	if (self.isbot) { return; }
	
	//cl("^3_marked_nodes started on "+self.name);

	for(;;){
		myAngles = self GetPlayerAngles();
		startPos = self getEye();
		startPosForward = startPos + anglesToForward( ( myAngles[0], myAngles[1], 0 ) ) * 1200;
		trace = bulletTrace( startPos, startPosForward, true, self );
		pos = trace["position"];
		
		objs = level.nodes;	
		closest = 2147483647;
		nr=undefined;
		self.nodecatch = undefined;
		if (objs.size>0){
			for( i = 0 ; i < objs.size ; i++ ){
				if(isDefined(objs[i])){
					dist = distance( pos, objs[i].pos ); 
					objs[i].marked = false;
					if(dist<70){ 
						nr=i; closest=dist;
					}
				}
			}
			
			if (isDefined(nr)) {
				objs[nr].marked = true;
				self.nodecatch = objs[nr];
				if(isDefined(self.squad)){
					for(i=0;i<self.squad.size;i++){
						self.squad[i].aproachNode=objs[i].pos;
					}
				}
			}
		} 
		
		wait 0.1;
	}
}

_marked_bot(){
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	if (!getDvarInt("v01d_dev")>0){ return; }
	if (self.isbot) { return; }
	
	//cl("^3_marked_bot started on "+self.name);

	for(;;){
		myAngles = self GetPlayerAngles();
		startPos = self getEye();
		startPosForward = startPos + anglesToForward( ( myAngles[0], myAngles[1], 0 ) ) * 1200;
		trace = bulletTrace( startPos, startPosForward, true, self );
		bot = trace["entity"];
		
		if(isDefined(bot) && bot.classname == "player" && bot.isbot){
			bot.marked = true;
		}
		wait 0.05;
	}
}

_hud_draw_nodes(){
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );	
	if (!getDvarInt("v01d_dev")>0){ return; }
	if (self.isbot) {return;}
	
	//cl("^3starting _hud_draw_nodes thread "+self.name);
	dist = 0; size=0; threshold=100;
	hud_q=0;
	
	for(;;){
		objs = level.nodes;	
		if (isDefined(objs)){
			closest = 2147483647;
			for( i = 0 ; i < objs.size ; i++ ){
				if(isDefined(objs[i])){
					dist = distance( self.origin, objs[i].pos );
					if(dist<500){
						self.hudwpt[hud_q] = newClientHudElem( self ); 
						if(objs[i].marked) { self.hudwpt[hud_q] setShader( "compass_waypoint_target", 15, 15 ); }
						else if(isDefined(objs[i].cover) && objs[i].cover != "any") { self.hudwpt[hud_q] setShader( "compass_waypoint_bomb", 15, 15 ); }
						else { self.hudwpt[hud_q] setShader( "compass_waypoint_defend", 15, 15 ); }
						self.hudwpt[hud_q].alpha = 0.5;
						self.hudwpt[hud_q].x = objs[i].pos[0]; self.hudwpt[hud_q].y = objs[i].pos[1]; self.hudwpt[hud_q].z = objs[i].pos[2]+32;
						if(objs[i].marked) { self.hudwpt[hud_q] SetWayPoint(true, "compass_waypoint_target"); }
						else if(isDefined(objs[i].cover) && objs[i].cover != "any") { self.hudwpt[hud_q] SetWayPoint(true, "compass_waypoint_bomb"); }
						else { self.hudwpt[hud_q] SetWayPoint(true, "compass_waypoint_defend"); }
						self notify("showNodeInfo");
						hud_q++;
					}
				}
			}
			//self iprintln("^3level.nodes.size:"+objs.size);
		}
		wait 0.1;
		if(isDefined(self.hudwpt)){
			for( i = 0 ; i < self.hudwpt.size; i++ ){ 
				if(isDefined(self.hudwpt[i])) { self.hudwpt[i] Destroy(); }
			}
		}
		hud_q=0;
	}
}

_hud_draw_tagged(){
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );	
	if (!getDvarInt("v01d_dev")>0){ return; }
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
	if (!getDvarInt("v01d_dev")>0){ return; }
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
	if (!getDvarInt("v01d_dev")>0){ return; }
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

readNodesFromFile( mapname )
{
	nodes = [];
	filename = "nodes/" + mapname + ".nodes";

	if ( !FS_TestFile( filename ) ) { cl("No nodes file"); return nodes; }

	cl( "^1Attempting to read nodes from " + filename );
	csv = FS_FOpen( filename, "read" );
	//if (!isDefined( FS_ReadLine( csv ) )){ FS_FClose( csv ); return; }
	//cl("int:"+int( FS_ReadLine( csv ) ));
	//cl("line1:"+FS_ReadLine( csv ));
	//cl("line2:"+FS_ReadLine( csv ));

	for ( ;; )
	{
		nodesCount = int( FS_ReadLine( csv ) );
		if ( nodesCount <= 0 ) { break; }
		
		for ( i = 1; i <= nodesCount; i++ )
		{
			line = FS_ReadLine( csv );
			if ( !isDefined( line ) || line == "" ) { continue; }
			tokens = tokenizeLine( line, "," );
			node = parseTokensIntoNodes( tokens );
			nodes[i-1] = node;
		}
		break;
	}
	FS_FClose( csv );
	return nodes;
}

tokenizeLine( line, tok )
{
	tokens = [];
	token = "";
	for ( i = 0; i < line.size; i++ )
	{
		c = line[i];
		if ( c == tok )
		{
			tokens[tokens.size] = token;
			token = "";
			continue;
		}
		token += c;
	}
	tokens[tokens.size] = token;
	return tokens;
}

parseTokensIntoNodes( tokens )
{
	node = spawnStruct();
	orgStr = tokens[0];
	orgToks = strtok( orgStr, " " );
	node.pos = ( float( orgToks[0] ), float( orgToks[1] ), float( orgToks[2] ) );
	//childStr = tokens[1];
	//childToks = strtok( childStr, " " );
	type = tokens[1];
	node.type = type;
	anglesStr = tokens[2];

	if ( isDefined( anglesStr ) && anglesStr != "" )
	{
		anglesToks = strtok( anglesStr, " " );
		node.angles = ( float( anglesToks[0] ), float( anglesToks[1] ), float( anglesToks[2] ) );
	}
	
	cover = tokens[3];
	//cl("node:"+tokens[3]);
	
	if (isDefined(cover)){ node.cover=cover; }
	else { node.cover = "any"; }

	return node;
}

_load_nodes()
{
	mapname = getDvar( "mapname" );
	level.nodes_quantity = 0;
	level.nodes = [];
	nodes = readNodesFromFile( mapname );

	if(!isDefined(nodes)) { cl( "No nodes to load from file" ); return; }
	level.nodes = nodes;
	cl( "Loaded " + nodes.size + " nodes from file." );
	level.nodes_quantity = level.nodes.size;

	for ( i = 0; i < level.nodes_quantity; i++ )
	{
		if ( !isDefined( level.nodes[i].id ) )
			level.nodes[i].id = i;
		
		if ( !isDefined( level.nodes[i].pos ) )
			level.nodes[i].pos = ( 0, 0, 0 );

		if ( !isDefined( level.nodes[i].type ) )
			level.nodes[i].type = "stand";
		
		if ( !isDefined( level.nodes[i].angles ) )
			level.nodes[i].angles = ( 0, 0, 0 );
		
		if ( !isDefined( level.nodes[i].cover ) )
			level.nodes[i].cover = "any";
			
		if ( !isDefined( level.nodes[i].names ) )
			level.nodes[i].names = [];
		
		if ( !isDefined( level.nodes[i].name ) )
			level.nodes[i].name = undefined;
			
		if ( !isDefined( level.nodes[i].marked ) )
			level.nodes[i].marked = false;

	}
}

_save_nodes()
{
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );	
	if (!getDvarInt("v01d_dev")>0){ return; }
	if (self.isbot) { return; }

	for ( ;; )
	{
		c=10;
		while ( !self meleeButtonPressed() ){ wait 0.05; }
		wait 0.05;

		while ( self meleeButtonPressed() && c>0){ 
			c--; wait 0.05;
		}
		
		if (c<=0){ 
			self thread _load_nodes();
			wait 0.2;
		}

		if (c>0){ 
			mpnm = getdvar( "mapname" );
			if ( level.nodes.size>0 ) { 
				filename = "nodes/" + getdvar( "mapname" ) + ".nodes";
				fd = FS_FOpen( filename, "write" );
				cl("Saving nodes...");
				
				if ( fd > 0 )
				{
					if ( !FS_WriteLine( fd, level.nodes.size + "" ) )
					{
						FS_FClose( fd );
						fd = 0;
					}
				}
		
				for ( i = 0; i < level.nodes.size; i++ )
				{
					str = "";
					node = level.nodes[i];
		
					str += node.pos[0] + " " + node.pos[1] + " " + node.pos[2];
					
					str += ",";
		
					if ( isDefined( node.type ) ) { str += node.type; }
					
					str += ",";
								
					if ( isDefined( node.angles ) )	{ str += node.angles[0] + " " + node.angles[1] + " " + node.angles[2]; }
					
					str += ",";
		
					if ( isDefined( node.cover ) ) { str += node.cover; }
					
					str += ",";
		
					if ( fd > 0 )
					{
						if ( !FS_WriteLine( fd, str ) )
						{
							FS_FClose( fd );
							fd = 0;
						}
					}
				}
		
				cl( "Nodes saved!!! to " + filename );
				if ( fd > 0 ) { FS_FClose( fd ); }
			} else {
				cl("No nodes to save!");
			}
		}
		
		while( self meleeButtonPressed() ){ wait 0.05; }
	}
}

pl(txt){
	color = "";
	if (isDefined(txt)){
		if(txt[0]=="^")	{ color="^"+txt[1]; }
		iprintln(color+"-- "+txt+" -- \n"); 
	} else { iprintln("!! undefined !! \n"); }
}
