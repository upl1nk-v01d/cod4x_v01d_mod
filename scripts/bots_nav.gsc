#include maps\mp\_load;
#include maps\mp\_utility;
#include scripts\cl;

init()
{	
	//setDvar("v01d_dev","nav");

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
		player thread _player_spawn();
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
		//self setClientDvar( "developer_script", 1 );
		//self setClientDvar( "developer", 1 );
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
	//self thread _grid_loop();
	//self thread _draw_nodes();
	self thread _bot_nodes_acm();
	
	//self setClientDvars("cg_thirdperson", 1);		
}

_bot_nodes_acm(){
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "death" );
	self endon( "game_ended" );
	if (!self.isbot){ return; }
		
	self.wptArr = [];
	
	while(1){
		if(self.wptArr.size>0){
			while(self.wptArr.size>0){
				cl(self.name+" wptArr.size: "+self.wptArr.size);
				self.moveToPos = self.wptArr[0];
				dist = distance(self.origin, self.wptArr[0]); 
				self botMoveTo(self.moveToPos);
				while(dist>32){
					dist = distance(self.origin, self.wptArr[0]); 
					wait 0.5;
				}
				self.wptArr = scripts\main::_arr_remove(self.wptArr,self.wptArr[0]);
				wait 0.5;
			}
		}
		wait 0.1;
	}
}

_bot_push_node(pos){
	bots = getentarray( "player", "classname" );
	closest = 99999; bot=undefined;
	for(i=0;i<bots.size;i++){
		if(!bots[i].isbot){ continue; }
		dist = distance(self.origin, bots[i].origin); 
		if(dist<closest){ closest=dist; bot=bots[i]; }
	}
	if(isDefined(bot)){ 
		cl(bot.name+" is closest to "+self.name);
		bot.wptArr[bot.wptArr.size] = pos;
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

_node_info(){
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	if (getDvar("v01d_dev") != "nav"){ return; }
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
	
	if (getDvar("v01d_dev") != "nav"){ return; }
	if (getdvarint("bots_main_debug")>0) { return; }  
	if (self.isbot) { return; }
	
	cl("^3_add_nodes started on "+self.name);
	
	use=false;
	hbr=false;

	for(;;){
		c=10; self.execute = false;
		while (!self UseButtonPressed() && !self HoldBreathButtonPressed()){ wait 0.05; }
		//wait 1;
		
		while ( self UseButtonPressed() && c>0){ use=true; c--; wait 0.05; }
		while ( self HoldBreathButtonPressed() ){ hbr=true; wait 0.05; }
				
		if (use == true && c<=0){ 
			//cl("^1EXECUTE"); self thread _squad_add_remove_snd("execute");
			if(isDefined(self.squad)){ 
				for(i=0;i<self.squad.size;i++){
					self.squad[i].execute = true;
				}
			}
			//while (self.execute==true){ wait 1; }
			wait 0.2;
		}
		
		//if (!self UseButtonPressed()){ continue; } 
		if (self.pers["team"] != "spectator") {
			delete=false; change=false; 
			myAngles = self GetPlayerAngles();
			startPos = self getEye();
			startPosForward = startPos + anglesToForward( ( myAngles[0], myAngles[1], 0 ) ) * 1200;
			trace = bulletTrace( startPos, startPosForward, true, self );
			//pos = trace["position"];
			pos = trace["position"];
			bot = trace["entity"];
			self PingPlayer();
			
			if(isDefined(bot) && bot.classname == "player" && c<=0 && use == true){
				//self thread _add_remove_squad(bot);
			//} else if(isDefined(self.squad) && self.squad.size<1){
			} else {
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
							if(use == true){
								cl("use");
								for(i=0;i<level.node_types.size;i++){
									if(objs[nr].cover == level.node_types[i]){
										objs[nr].cover = level.node_types[i+1]; 
										if(isDefined(objs[nr].cover)){
											change = true; 
											cl("^3Node changed to type "+objs[nr].cover);
											self iprintln("^3Node changed to type "+objs[nr].cover);
											self notify("showNodeInfo");
										}
										break;
									}
									change = false;
								}
							} else if(hbr == true){
								cl("hbr pos: "+objs[nr].pos);
								self thread _bot_push_node(objs[nr].pos);
							}
						} 
						if (use == true && change == false){
							self iprintln("^3deleting:"+nr);
							delete = true; cl("delete");
							level.nodes = scripts\main::_arr_remove(objs,objs[nr]);
							level.nodes_quantity=level.nodes.size;
							objs = undefined;
							self iprintln("^3Node deleted");
						}
					}
				} 
				if (use == true && delete == false && change == false){ 
					self _add_node((self.origin[0],self.origin[1],self.origin[2]-20)); 
					//self _add_node((pos[0],pos[1],pos[2]-20)); 
					delete = false; change = false; 
					self iprintln("^3Node added");
				}
				wait 0.2;	
			}	
		}
		
	while(self UseButtonPressed() || self HoldBreathButtonPressed()){ wait 0.05; }
	use=false; 
	hbr=false;
	wait 0.05;
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
	
	if (getDvar("v01d_dev") != "nav"){ return; }
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
	
	if (getDvar("v01d_dev") != "nav"){ return; }
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
	if (getDvar("v01d_dev") != "nav"){ return; }
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
	if (getDvar("v01d_dev") != "nav"){ return; }
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
