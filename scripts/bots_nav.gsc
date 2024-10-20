#include maps\mp\_load;
#include maps\mp\_utility;
#include scripts\cl;

init()
{	
	precacheShader("compass_waypoint_defend");
	precacheShader("compass_waypoint_target");
	precacheShader("compass_waypoint_bomb");
	precacheShader("compassping_enemy"); 
	precacheShader("compassping_enemyfiring"); 
	precacheShader("compassping_player"); 
	precacheShader("map_artillery_selector"); 
	
	setDvar("bots_play_move", 1);
	//setDvar("v01d_dev","0");
	//setDvar("v01d_dev","nav");

	if (getDvar("v01d_dev") == "nav"){
		//if (isDefined(game["devmode"]) && game["devmode"] != "on"){ 
			game["devmode"]="on"; 
			//setdvar( "developer_script", 1 );
			//setdvar( "developer", 1 );		
			//setdvar( "sv_mapRotation", "map " + getDvar( "mapname" ) );
			//exitLevel( false );
			setDvar( "bots_play_move", 0 );
			setDvar( "bots_aim_ext", 1 );
			setDvar( "bots_fire_ext", 1 );
			level.doNotAddBots=true;
			//wait 5;
		//}
	} else {
		game["devmode"] = "off";
	}
	
	//if (!getdvarint("v01d_dev")>0){ return; }
	if (getdvarint("bots_main_debug")>0) { return; }

	level.icon = "map_artillery_selector";
	
	//if (level.waypointCount != 0) { return; }
	
	level.nodes = [];
	level.nodes_quantity = 0;
	level.node_types = StrTok("any,mg,sniper,grenadier,rocket",",");
	
	//level.grid = [];
	//level.grid_quantity = 0;
	
	level.objectivePos = undefined;
	if(isDefined(level.sabBomb)){
		level.objectivePos = level.sabBomb.curOrigin;
		cl("22this level has a bomb!");
	}
	
	level.sniper_weapons = StrTok("tac330_sil_mp,mors_acog_mp,svg100_mp,barrett_mp,dragunov_mp,m40a3_mp,m21_mp",",");
	level.grenade_weapons = StrTok("mm1_mp",",");
	level.rocket_weapons = StrTok("em1_mp,rpg_mp,law_mp",",");
	level.mg_weapons = StrTok("saw_mp,rpd_mp,m60e4_mp",",");
	
	level.objectives = [];
	for(i=1;i<16;i++){
		level.objectives[i] = spawnStruct();
		level.objectives[i].id = i;
		level.objectives[i].icon = "compassping_enemyfiring";
		level.objectives[i].state = "invisible";
		level.objectives[i].pos = (0,0,0);
		Objective_Add(i, "invisible", level.objectives[i].pos); 
		Objective_Icon(i,level.objectives[i].icon);
	}
		
	//if(!isDefined(getDvar( "bots_nav_enable"))){ setDvar( "bots_nav_enable", ""); }
	//setDvar( "bots_play_move", false );
	
	level thread _load_nodes();
	level thread _bomb_pos();
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
		//player thread _bot_take_cover();
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
	if (getdvarInt("v01d_dev") != 0){
		//self setClientDvar( "developer_script", 1 );
		//self setClientDvar( "developer", 1 );
		//cl("33connecting");
	}
}

_player_spawn()
{
	self endon ( "disconnect" );
	self endon( "intermission" );
	//self endon( "death" );
	self endon( "game_ended" );
	//if (self.isbot){ return; }
	
	if (getDvar("v01d_dev") != "nav"){ return; }
	
	for(;;){
		self waittill("spawned_player");
		
		
		self thread _bot_start_nav();
		//self thread _grid();
		//self thread _hud_draw_grid();
		self thread _bot_nodes_acm();
		self thread _bot_self_nav();	
		self thread _open_map();		
		//self thread _bot_go_to_objective();
		self thread _bot_look_at_bombpos();
		self thread _bot_look_at_enemy();
	}
}

_bomb_pos(){
	level endon ( "disconnect" );
	level endon( "intermission" );
	level endon( "game_ended" );
	
	while(1){
		players = getentarray("player", "classname");
		for(i=0;i<players.size;i++){
			if(isDefined(players[i].isBombCarrier) && players[i].isBombCarrier == true){
				level.bombCarrier = players[i]; 
				break;
			}
		}
		if(isDefined(level.bombCarrier)){ 
			//level.objectivePos = level.bombCarrier.origin; 
			//cl("level.bombCarrier: "+level.bombCarrier.name);
			team = level.bombCarrier.pers["team"];
			if(team == "axis"){ team = "allies"; }
			else if(team == "allies"){ team = "axis"; }
			ent = getEnt("sab_bomb_"+team+"", "targetname");
			level.objectivePos = ent.origin;
			//cl("ent origin: "+ent.origin);
		} else{ 
			level.objectivePos = level.sabBomb.curOrigin; 
			//cl("level.objectivePos: "+level.objectivePos);
		}
		wait 1;
	}
}

_bot_start_nav(){
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "death" );
	self endon( "game_ended" );

	if(!self.isbot){
		if(self.pers["team"] == "axis"){ level maps\mp\bots\_bot::add_bot("axis"); }
		else{ level maps\mp\bots\_bot::add_bot("allies"); }
	}

	if (!self.isbot){ return; }
	
	//self.approachNode = undefined;
	cl("_start_nav started on "+self.name);
	
	self.wptArr = [];
	self.gridArr = [];
	self.calculating = "idle";
	
	//self thread _add_wpt_for_bomb();
	//self thread _nav_loop();
	//self thread _bot_following_player();
	
	//self setClientDvars("cg_thirdperson", 1);	
	
}

_bot_look_at(pos,aimspeed,c1,c2){
	self endon ( "disconnect" );
	self endon( "intermission" );
	//self endon( "death" );
	self endon( "game_ended" );
	if (!self.isbot){ return; }
	
	if(isDefined(self.isLookingAt)){ 
		//cl("11"+self.name+" already looking at!"); 
		return; 
	}
	self.isLookingAt = true;
	
	if(!isDefined(pos)){ return; }
	if(!isDefined(aimspeed)){ aimspeed=5; }
	if(!isDefined(c1)){ c1=0.5; }
	if(!isDefined(c2)){ c2=0.5; }
	
	c=0;
	_aimspeed = aimspeed;

	while(aimspeed>0.1){ 
		self botLookAt(pos, aimspeed);
		aimspeed *= c1;
		wait 0.05;
	}
	aimspeed = 0.1;
	while(aimspeed<_aimspeed){ 
		self botLookAt(pos, aimspeed);
		aimspeed *= (1+c2);
		wait 0.05;
		//cl("c2:"+c2);
	}
	
	self.isLookingAt = undefined;
	//cl("11ended");
}

_bot_look_at_bombpos(){
	self endon ( "disconnect" );
	self endon( "intermission" );
	//self endon( "death" );
	self endon( "game_ended" );
	if (!self.isbot){ return; }
	
	while(isAlive(self)){
		objPos = level.objectivePos;
		if(isDefined(level.bombCarrier)){
			team = level.bombCarrier.pers["team"];
			if(team == "axis"){ team = "allies"; }
			else if(team == "allies"){ team = "axis"; }
			ent = getEnt("sab_bomb_"+team+"", "targetname");
			objPos = ent.origin;
			//cl("ent origin: "+ent.origin);
		}
		//bombZoneAxis = getEnt("sab_bomb_axis", "targetname");
		//bombZoneAllies = getEnt("sab_bomb_axis", "targetname");
		_objective_toggle(8,1,objPos);
		//cl("sabBombOrg.origin: "+sabBombOrg.origin);
		btObjPos = BulletTracePassed(self getEye(), (objPos[0],objPos[1],objPos[2]+32), false, self);
		
		if(btObjPos){
			if(!isDefined(self.hasEnemy)){ self thread _bot_look_at(objPos); }
			cl("objPos seen at: "+objPos);
			//self.wptArr[self.wptArr.size] = objPos;
			self.movingToObj = true;
		} else {
			self.movingToObj = undefined;
		}
		
		wait randomFloatRange(1.5,3);
	}
}

_bot_look_at_enemy(){
	self endon ( "disconnect" );
	self endon( "intermission" );
	//self endon( "death" );
	self endon( "game_ended" );
	if (!self.isbot){ return; }
	
	self.bot.isfrozen = true;
	self.bot.stop_move = true;
	self.hasEnemy = undefined;
	
	while(isAlive(self)){
		players = getentarray("player", "classname");
		closest = 99999; 
		enemy = undefined;
		enemybtp = false;
		enemystp = false;
		c=0;
		for(i=0;i<players.size;i++){
			if(players[i].pers["team"] != self.pers["team"]){
				dist = distance(self getEye(), players[i] getEye());
				eye = players[i] getEye(); 
				enemybtp = BulletTracePassed(self getEye(), (eye[0],eye[1],eye[2]), false, self);
				//if(dist<closest){ 
				if(enemybtp){ 
					//closest=dist; 
					enemy=players[i];
					break;
				}
			}
			
		}
		if(isDefined(enemy) && isAlive(enemy)){ 
			while(isAlive(self) && isAlive(enemy) && enemybtp && c<10){ 
				self.hasEnemy = true;
				eye = enemy getEye();
				enemybtp = SightTracePassed(self getEye(), (eye[0],eye[1],eye[2]), false, self);
				if(enemybtp){
					//cl("11"+self.name+" is looking at enemy "+enemy.name);
					self botLookAt(eye,0.2);
					//self thread _bot_look_at(eye,0.1,0.1,0.1);
					self.bot.after_target = enemy;
				}
				c++;
				wait randomFloatRange(0.05,1);
			}
			//wait randomFloatRange(0.1,2);
		}
		self.hasEnemy = undefined;
		self.bot.after_target = undefined;
		wait 0.2;
	}
}

_bot_go_to_objective(){
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	//self endon( "death" );
	if (!self.isbot){ return; }
	
	cl("_bot_go_to_objective started on "+self.name);
	
	wait 0.5;
	nr = 0;
	point = self getEye(); 
	
	while(isAlive(self)){
		if(isDefined(level.nodes)){
			_objective_toggle(9,0);
			//bombPos = level.objectivePos;
			//_objective_toggle(8,1,bombPos,"");
			closest = 999;
			dist1 = undefined;
			dist2 = undefined;
			
			for(i=0;i<level.nodes.size;i++){
				//cl("level.nodes.size: "+level.nodes.size);
				dist1 = distance(point, level.nodes[i].pos); 				
				dist2 = distance(point, level.objectivePos);
				dist3 = distance(level.nodes[i].pos, level.objectivePos);
				eye = point;
				distz = level.nodes[i].pos[2] - eye[2];
				//cl("distz: "+distz);
				bombObj = dist2 - dist3;
				pos = level.objectivePos;
				wptPos = level.nodes[i].pos;
				btpWpt = BulletTracePassed(point, (wptPos[0],wptPos[1],wptPos[2]+64), false, self);
				btBomb = BulletTracePassed(point, (pos[0],pos[1],pos[2]+64), false, self);
				btBombPos = BulletTrace(point, (pos[0],pos[1],pos[2]+64), false, self);
				btBombPos = btBombPos["position"];
				//btbomb = (btbomb["position"][0],btbomb["position"][1],btbomb["position"][2]);
				//bt = _calc_indents(bt);
				//distbt = distance(self getEye(), btbomb)+32;
				//cl("22i: "+i+" dist1: "+dist1);
				//cl("22i: "+i+" dist2: "+dist2);
				//cl("22i: "+i+" bombObj: "+bombObj);
				//if(!isDefined(distbt)){ distbt=dist1; }
				//if(isDefined(dist1) && dist1 > 64 && dist1 < closest){
				//if (isDefined(distObj) && distbt >= dist1 && dist1 > 64 && distObj < closest){
				//cl("btBomb: "+btBomb);
				
				if(btBomb){
					self.wptArr[self.wptArr.size] = btBombPos;
					break;
					//self.movingToObj = true;
					//cl("11movingToObj");
				} else if(isDefined(self.calculating) && self.calculating != "success"){ 
					//cl("11failed");
					if(dist1 > 64 && dist1<closest && distz < 0){ 
						closest = dist1; 
						nr = i; 
						//cl(self.name+" nr: "+nr);
					}
				} else if (isDefined(bombObj) && bombObj > -256 && bombObj < closest){
				//} else if (isDefined(bombObj) && bombObj > -128 && dist1 < closest){
					//self.calculating = "failed";  
					//cl("11i: "+i+" bombObj: "+bombObj);
					closest = bombObj;
					nr = i; 
				}
				
				//wait 0.05;
			}
			
			//cl("closest: "+closest);
			//cl("---------");
			if(isDefined(nr) && isDefined(level.nodes[nr].pos)){
				//cl("isDefined nr!");
				_objective_toggle(9,1,level.nodes[nr].pos,"map_artillery_selector");
				self.wptArr[self.wptArr.size] = level.nodes[nr].pos;
				point = level.nodes[nr].pos;
				//self _bot_calc_path(self getEye(), level.nodes[nr].pos);
				//self botLookAt(level.nodes[nr].pos, 0.1);
				//if(!isDefined(self.hasEnemy)){
				//	self thread _bot_look_at(level.nodes[nr].pos,undefined,randomFloatRange(0.1,0.5),randomFloatRange(0.1,0.5));
				//}
				//cl("11"+self.name+" goes to "+level.nodes[nr].pos);
				
				//while(isDefined(self.moveToPos)){
				//	wait 0.5;
				//}
				//nr+=1;
			}
			//self.calculating = undefined;
			//self.wptArr = scripts\main::_arr_sort(wptTrail,2);
			
			//dist1 = distance(self.origin, level.nodes[nr].pos);
			//while(isDefined(dist1) && dist1>64){ 
			//	dist1 = distance(self.origin, level.nodes[nr].pos);
			//	cl("dist1: "+dist1);
			//	wait 1;
			//}
		}
		wait 0.05;
	}
}

_bot_self_nav(){ //bot avoiding obstacles by turning not strafing
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	//self endon( "death" );
	
	if (!self.isbot) { return; }
	
	while(isAlive(self)){
		a = self GetPlayerAngles();
		sp = self getEye();
		aff = sp + anglesToForward((0, a[1], 0))*128;
		affu = sp + anglesToForward((a[0]-40, a[1], 0))*64;
		affd = sp + anglesToForward((a[0]+40, a[1], 0))*64;
		afl = sp + anglesToForward((0, a[1]-90, 0))*128;
		afr = sp + anglesToForward((0, a[1]+90, 0))*128;
		btf = bulletTrace(sp, aff, true, self);
		btfu = bulletTrace(sp, affu, true, self);
		btfd = bulletTrace(sp, affd, true, self);
		btl = bulletTrace(sp, afl, true, self);
		btr = bulletTrace(sp, afr, true, self);
		posf = btf["position"];
		posfu = btfu["position"];
		posfd = btfd["position"];
		posl = btl["position"];
		posr = btr["position"];
		entf = btf["entity"];
		entl = btl["entity"];
		entr = btr["entity"];	
	
		distf=distance(self getEye(),posf);
		distfu=distance(self getEye(),posfu);
		distfd=distance(self getEye(),posfd);
		distl=distance(self getEye(),posl);
		distr=distance(self getEye(),posr);
				
		if(distl<32 && !isDefined(self.hasEnemy)){ 
			//self botLookAt(posr, 0.1);
			self thread _bot_look_at(posr,undefined,randomFloatRange(0.1,0.5),randomFloatRange(0.1,0.5));
			//self.wptArr = scripts\main::_arr_add(self.wptArr,0,posr);
			self.wptArr[0] = posr;
			//cl(self.name+" turning left");
			//self _bot_strafe("left",0.5);
		} else if(distr<32 && !isDefined(self.hasEnemy)){ 
			//self botLookAt(posl, 0.1);
			self thread _bot_look_at(posl,undefined,randomFloatRange(0.1,0.5),randomFloatRange(0.1,0.5));
			//self.wptArr = scripts\main::_arr_add(self.wptArr,0,posl);
			self.wptArr[0] = posl;
			//cl(self.name+" turning right");
			//self _bot_strafe("left",0.5);
		} else if(distfu<64){ 
			//self botLookAt(posl, 0.1);
			//self _bot_look_at(posfu);
			//self botAction( "+gocrouch");
			//cl(self.name+" turning right");
			//self _bot_strafe("left",0.5);
		} else if(distfd<64){ 
			//self botLookAt(posl, 0.1);
			//self _bot_look_at(posfd);
			self.wptArr = scripts\main::_arr_add(self.wptArr,0,posfd);
			//cl(self.name+" turning right");
			//self _bot_strafe("left",0.5);
		}
		//cl("a: "+a);
		//cl("pos: "+pos);
		//cl("dist: "+dist);
		
		//if(isDefined(entf)){
		//	cl("ent: "+entf.origin);
		//}
			
		wait 0.5;
		//self botAction( "-gocrouch");
	}
}

_bot_strafe(action, dur){
	self botAction("+strafe"); //strafe doesn't work, outputs error
	self botAction("+"+action);
	wait dur;
	self botAction("-strafe");
	self botAction("-"+action);

}

_objective_toggle(n,sw,pos,icon){
	if(!isDefined(n)){ return; }
	
	state = level.objectives[n].state;

	if(isDefined(sw) && sw == 1){ state = "active"; }
	else if(isDefined(sw) && sw == 0){ state = "invisible"; }
	else {
		if(state == "active"){ state = "invisible"; }
		else{ state = "active"; }
	}
	
	level.objectives[n].state = state;
	
	if(isDefined(pos)){ level.objectives[n].pos = pos; }
	Objective_Add(n, level.objectives[n].state, level.objectives[n].pos); 
	//cl("state:"+state);
	
	if(isDefined(icon)){ 
		level.objectives[n].icon = icon; 
		Objective_Icon(n, icon);
	}
}

_open_map(){
	self endon ( "disconnect" );
	self endon( "intermission" );
	//self endon( "death" );
	self endon( "game_ended" );
	if (self.isbot){ return; }

	while(isAlive(self)){
		while (!self LeanLeftButtonPressed()){ wait 0.05; }
		self beginLocationSelection( "map_artillery_selector", level.artilleryDangerMaxRadius * 1.2 );
		wait 0.5;
		//while (!self LeanLeftButtonPressed()){ wait 0.05; }
		self waittill( "confirm_location", location );
		self endLocationSelection();
		wait 0.05;
	}
}

_bt_watcher(){
	setDvar("btn","1");
	setDvar("bte","1");
	setDvar("bts","1");
	setDvar("btw","1");
	
	setDvar("cn","128");
	setDvar("ce","128");
	setDvar("cs","128");
	setDvar("cw","128");
	
	while(isDefined(level.btwatcher)){
		if(getDvar("btn") == "1"){ _objective_toggle(12,1); } else{ _objective_toggle(12,0); }
		if(getDvar("bte") == "1"){ _objective_toggle(13,1); } else{ _objective_toggle(13,0); }
		if(getDvar("bts") == "1"){ _objective_toggle(14,1); } else{ _objective_toggle(14,0); }
		if(getDvar("btw") == "1"){ _objective_toggle(15,1); } else{ _objective_toggle(15,0); }
		wait 0.5;
	}
	
}

_calc_indents(pos){
	//cn = float(getDvar("cn"));
	//ce = float(getDvar("ce"));
	//cs = float(getDvar("cs"));
	//cw = float(getDvar("cw"));
		
	//cl("cn:"+cn);
	//cl("ce:"+ce);
	//cl("cs:"+cs);
	//cl("cw:"+cw);
	
	//to = (to[0]+cn,to[1]+ce,to[2]);
	
	//tg = (btn[0]+(btc[0]-btn[0])+(btc[0]-bts[0]),bte[1]+(btc[1]-bte[1])+(btc[1]-btw[1]),btc[2]);
	//tg = (bte[0]+(bte[0]-btc[0]),bte[1],bte[2]);
	//tg = (bts[0],bts[1]+(bts[1]-btc[1]),bts[2]);
	//tg = (btw[0],btw[1]+(btw[1]-btc[1]),btw[2]);

	afn = pos + anglesToForward((0,90,0)*32);
	afe = pos + anglesToForward((0,0,90)*32);
	afs = pos + anglesToForward((0,-90,0)*32);
	afw = pos + anglesToForward((0,0,-90)*32);

	btn = bulletTrace(pos,(pos[0]+32,pos[1],pos[2]), false, self); // + up, - down
	btn = btn["position"];
	bte = bulletTrace(pos,(pos[0],pos[1]+32,pos[2]), false, self); // + left - right 
	bte = bte["position"];
	bts = bulletTrace(pos,(pos[0]-32,pos[1],pos[2]), false, self);
	bts = bts["position"];
	btw = bulletTrace(pos,(pos[0],pos[1]-32,pos[2]), false, self);
	btw = btw["position"];
	
	//_objective_toggle(11,1,to,icon);
	//_objective_toggle(12,1,btn,undefined);
	//_objective_toggle(13,1,bte,undefined);
	//_objective_toggle(14,1,bts,undefined);
	//_objective_toggle(15,1,btw,undefined);
	
	//pos = from;

	dist1 = distance(pos,btn);
	dist2 = distance(pos,bte);
	dist3 = distance(pos,bts);
	dist4 = distance(pos,btw);
	
	//cl("dist1: "+dist1); 
	//cl("dist2: "+dist2); 
	//cl("dist3: "+dist3); 
	//cl("dist4: "+dist4); 
	
	//if(dist1>dist2 && dist1>dist3 && dist1>dist4){ to = btn; cl("dist1"); }
	//if(dist2>dist1 && dist2>dist3 && dist2>dist4){ to = bte; cl("dist2"); }
	//if(dist3>dist1 && dist3>dist2 && dist3>dist4){ to = bts; cl("dist3"); }
	//if(dist4>dist1 && dist4>dist2 && dist4>dist3){ to = btw; cl("dist4"); } 

	distx=dist2-dist4;
	disty=dist1-dist3;
		
	pos = (pos[0]+disty,pos[1]+distx,pos[2]);
		
	return pos;
}

_chk_dest_dist(from,to,dir){
	wpt = from;
	wptArr = [];
	bt = undefined;
	a = (0,0,0);
	am = 0;
	matchedp = undefined;
	matched = false;
	match = (0,0,0);
	
	if(!isDefined(dir)){ dir=0; }
	
	threshold=100;
	c=0;
	self.calculating = "processing";
	
	while(c<=threshold && self.calculating == "processing"){	
		a = VectorToAngles(from-to);
		if(isDefined(wpt)){ al = VectorToAngles(wpt-to); }
		if(isDefined(matchedp)){ ar = VectorToAngles(match-to); }
		af = wpt + anglesToForward((0,a[1]+dir+am,0))*32; // Y X Z = Up/Down Left/Right Fw/Bw 
		aff = wpt + anglesToForward((0,0,a[2]+90))*32;
		
		bt = bulletTrace(wpt, af, false, self);
		btf = bulletTrace(wpt, aff, false, self);
		
		bt = bt["position"];
		btf = btf["position"];

		bt = _calc_indents(bt);
		btf = _calc_indents(btf);
		
		dist = distance(bt,wpt);
		//cl("dist1:"+dist1);
		//cl("dist2:"+dist2);
		//if(isDefined(btl)){ dist1 = distance(wptl,btl); }
		//if(isDefined(btr)){ dist2 = distance(wptr,btr); }
		if(dist<26){ am += 45; }

		distf = distance(bt,btf);
		
		if(distf>20){ wpt = btf; }
		
		//cl("distlf:"+distlf);
		//cl("distrf:"+distrf);
		
		match = bulletTrace(bt, to, false, self);
		matchp = bulletTracePassed(bt, to, false, self);
		match = match["position"];
		distm = distance(match,to);
		
		//cl("dist1m:"+dist1m);
		//cl("dist2m:"+dist2m);

		_objective_toggle(11,1,bt,"");

		if(matchp){ 
			a = VectorToAngles(match-to); 
			matchedp = true; 
			am = 90;
		}
		
		wpt = (bt[0],bt[1],bt[2]);
		wptArr[wptArr.size] = wpt;
		
		
		//wait 0.05;
		
		
		_objective_toggle(11,0,wpt,"");
		
		dist = distance(wpt,to);
		
		//cl("distl:"+dist1);
		//cl("distr:"+dist2);
		//cl("wptl:"+wptl);
		//cl("wptr:"+wptr);
		

		if(matchp){ 
			matched = true; 
			//cl("22success"); 
			//c=threshold; 
			self.wptArr = wptArr; 
			self.calculating = "success";
			//_objective_toggle(11,1,match,"");
			return match;
		}

		//if(matched){ _objective_toggle(11,1,match,""); }
		
		//if(dist1m < 1){ matched1 = true; cl("22matched1"); c=threshold; wptlArr[wptlArr.size-1] = match1; self.wptArr = wptlArr; }
		//else if(dist2m < 1){ matched2 = true; cl("22matched2"); c=threshold; wptrArr[wptrArr.size-1] = match2; self.wptArr = wptrArr; }
		
		c++; 
		//cl("c:"+c);
		if(c>threshold){ 
			//cl("11failed");
			self.calculating = "failed";
			break;
		}
	}
}

_bot_calc_path(from,to){
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "death" );
	self endon( "game_ended" );
	if (!self.isbot){ return; }
		
	//cl(self.name+" calculating path to " + to);
	
	wptlArr = [];
	//if(isDefined(level.btwatcher) && level.btwatcher == true){ cl("11already running!"); return; }
	level.btwatcher = true;
	//level thread _bt_watcher();
	objs=undefined;
	//self.calculating = "processing";
		
	icon = "map_artillery_selector";
	
	//_objective_toggle(11,1,to,icon);
		
	//while(isDefined(self.calculating) && self.calculating == ""){
		//Objective_Add(11, "active", to);
		
		//icon = ""; //rectangle icon
		//icon = level.icon;
		//_objective_toggle(11,1,to,icon);
		
		//wait 1;
		
		from = bulletTrace(from,(to[0],to[1],to[2]-32), false, self);
		from = from["position"];
		from = _calc_indents(from);

		self thread _chk_dest_dist(from,to,45);
		self thread _chk_dest_dist(from,to,90);
		self thread _chk_dest_dist(from,to,-90);
		self thread _chk_dest_dist(from,to,-45);
				
		while(isDefined(self.calculating) && self.calculating != "failed" && self.calculating != "success"){ wait 0.05; };
		cl("22calc ended");
		//if(self.calculating == "success"){ self.calculating = undefined; }
		//self.calculating = undefined;
		
		//cl("self.calculating:"+ self.calculating);
		wait 0.05;
		//to = undefined;
		//break;
	//}

}

_bot_grid_calc_path(from, to){
	self endon ( "disconnect" );
	self endon( "intermission" );
	//self endon( "death" );
	self endon( "game_ended" );
	
	if (!self.isbot){ return; }

	if(!isDefined(from)){ return; }
	if(!isDefined(to)){ return; }
	
	cl(self.name+" calculating grid path from "+from+" to "+to);
	cl("grid size: "+self.gridArr.size);
	
	nr = 0;
	point = self getEye(); 
	stop = undefined;
	self.wptArr = [];
	
	while(isAlive(self) && !isDefined(stop)){
		if(isDefined(self.gridArr)){
			_objective_toggle(9,0);
			closest = 999;
			dist1 = undefined;
			dist2 = undefined;
			
			for(i=0;i<self.gridArr.size;i++){
				if(!isAlive(self)){ break; }
				//cl("self.gridArr.size: "+self.gridArr.size);
				dist1 = distance(point, self.gridArr[i]); 				
				dist2 = distance(point, to);
				dist3 = distance(self.gridArr[i], to);
				dist4 = distance(self getEye(), to);
				eye = point;
				distz = self.gridArr[i][2] - eye[2];
				//cl("distz: "+distz);
				bombObj = dist2 - dist3;
				pos = to;
				nodePos = self.gridArr[i];
				btpNode = BulletTracePassed(point, (nodePos[0],nodePos[1],nodePos[2]+64), false, self);
				btBomb = BulletTracePassed(point, (pos[0],pos[1],pos[2]+64), false, self);
				btBombPos = BulletTrace(point, (pos[0],pos[1],pos[2]+64), false, self);
				btBombPos = btBombPos["position"];
				//btbomb = (btbomb["position"][0],btbomb["position"][1],btbomb["position"][2]);
				//bt = _calc_indents(bt);
				//distbt = distance(self getEye(), btbomb)+32;
				//cl("22i: "+i+" dist1: "+dist1);
				//_objective_toggle(9,1,wptPos,"");
				//cl("22i: "+i+" dist2: "+dist2);
				//cl("22i: "+i+" bombObj: "+bombObj);
				//if(!isDefined(distbt)){ distbt=dist1; }
				//if(isDefined(dist1) && dist1 > 64 && dist1 < closest){
				//if (isDefined(distObj) && distbt >= dist1 && dist1 > 64 && distObj < closest){
				//cl("btBomb: "+btBomb);
				//cl("22i: "+i+" point: "+point);
				//cl("22i: "+i+" dist1: "+dist1);
				//cl("22i: "+i+" bombObj: "+bombObj);
				
				if(btBomb && dist4<128){
					self.wptArr[self.wptArr.size] = btBombPos;
					stop = true;
					//self.movingToObj = true;
					cl("11movingToObj");
					break;
				//} else if(isDefined(self.calculating) && self.calculating != "success"){ 
				/*} else if(btpWpt){ 
					//cl("11failed");
					if(dist1 > 64 && dist1<closest && distz < 0){ 
						closest = dist1; 
						nr = i; 
						cl(self.name+" nr: "+nr);
					} */
				}  
				//else if (isDefined(bombObj) && bombObj > 0 && dist2 < closest){
				else if (isDefined(bombObj) && bombObj > 0 && dist1 < closest && btpNode){
					//self.calculating = "failed";  
					//cl("11i: "+i+" bombObj: "+bombObj);
					closest = dist1;
					nr = i; 
					//wait 1;
				}
				
				//wait 0.1;
			}
			
			//cl("closest: "+closest);
			//cl("---------");
			if(isDefined(nr) && isDefined(self.gridArr[nr]) && nr != 0){
				if(point == self.gridArr[nr]){ 
					stop = true;
					self.calculating = "success";
					cl("22self.calculating: "+self.calculating);
					break; 
				}
				point = self.gridArr[nr];
				//if(dist1 > 128){ stop = true; }
				//cl("point:"+point);
				//self.wptArr[self.wptArr.size] = self.gridArr[nr];
				self _bot_push_node(self.gridArr[nr]);
				_objective_toggle(9,1,self.gridArr[nr],"map_artillery_selector");
				cl("self.wptArr.size:"+self.wptArr.size);
				cl("self.gridArr[nr]:"+self.gridArr[nr]);
				/*if(isDefined(level.nodes)){
					for(j=0;j<level.nodes.size;j++){
						dist1 = distance(point, level.nodes[j].pos);
						if(dist1 < 128){
							self.gridArr[nr] = level.nodes[j].pos; 
							//stop = true;
							//break;
						}
					}
				}*/
			}
		}
		wait 0.05;
	}
	cl("22grid calc ended");
}

_grid(startPos, to, xn, yn, ix, iy){
	self endon ( "disconnect" );
	self endon( "intermission" );
	//self endon( "death" );
	self endon( "game_ended" );
	
	if (getDvar("v01d_dev") != "nav"){ return; }
	if (!self.isbot){ return; }
	
	if(!isDefined(startPos)){ return; }
	if(!isDefined(to)){ return; }
	if(!isDefined(xn)){ xn = 16; }
	if(!isDefined(yn)){ yn = 16; }
	if(!isDefined(ix)){ ix = 128; }
	if(!isDefined(iy)){ iy = 128; }
	
	cl("33grid_loop");
	//while(isAlive(self)){
		//while(!self UseButtonPressed()){ wait 0.05; }
		self.gridArr = [];
		//self.wptArr =2 [];
		myAngles = self GetPlayerAngles();
		prevPos = self getEye();
		//cl("prevPos:"+prevPos);
		dist = distance(self getEye(),prevPos);
		if(!isDefined(startPos)){ startPos = self getEye(); }
		startPosForward = startPos + anglesToForward((0,myAngles[1],0))*120;
		trace = bulletTrace(startPos,startPosForward,true,self);
		//pos = trace["position"];
		pos = startPos;
		x_max=xn;
		y_max=yn;
		x_int=ix;
		y_int=iy;
		c=15;
		//ent = trace["entity"];
		if(isDefined(pos)){
			for(x=1;x<=x_max;x++){
				for(y=1;y<=y_max;y++){
					trace_down = bulletTrace((pos[0]+(y*y_int)-(y_int/2*y_max), pos[1]+(x*x_int)-(x_int/2*x_max), pos[2]), (pos[0]+(y*y_int)-(y_int/2*y_max), pos[1]+(x*x_int)-(x_int/2*x_max), pos[2]-100), false, self);
					//trace_down = bulletTrace((pos[0]+(y*64)-(32*y_max), pos[1]+(x*64)-(32*x_max), pos[2]), (pos[0]+(y*64)-(32*y_max), pos[1]+(x*64)-(32*x_max), pos[2]-100), false, self);
					//trace_down = bulletTrace((pos[0]-(64*10/2)+(x*64), pos[1]-(64*10/2)+(z*64), pos[2]), (pos[0]-(64*10/2)+(x*64)-64, pos[1]-(64*10/2)+(z*64), pos[2]-100), false,self);
					pos2 = trace_down["position"];
					pos2 = _calc_indents(pos2);
					//self _add_node(pos2);
					//cl("self.gridArr.size:"+self.gridArr.size);
					//self.gridArr[self.gridArr.size] = spawnstruct();
					self.gridArr[self.gridArr.size] = pos2;
					//self.grid_quantity++;
					if((x==1 && y==1) || (x==1 && y==y_max) || (x==x_max && y==1) || (x==x_max && y==y_max)){
						//node = spawn( "script_origin", (pos2[0],pos2[1],pos2[2]),0,0,0);
						//node.targetname = "markers_"+self.name;
						Objective_Add(c, "active", pos2);
						Objective_Icon(c,"compass_waypoint_target");
						c--;
					}
					//line(fw1, fw2, (1, 1, 0.5), 1, 1, 30);
					//print3d(self.origin, "START", (1.0, 0.8, 0.5), 1, 3, 10000);
					//cl("33"+self.name+" spawned gridnode: "+pos2);
					//wait 1;
				}
			}
			self _bot_grid_calc_path(startPos, to);
			//while(isAlive(self) && dist < 64){ 
				dist = distance(self getEye(),prevPos);
				//cl("dist:"+dist);
				//wait 5; 
				//self _bot_grid_calc_path(self getEye(), level.objectivePos);
			//}
			startPos = self getEye();
		}
		//while(self UseButtonPressed()){	wait 0.05; }
		//wait 1;
	//}
	cl("22grid thread ended");
}

_bot_nodes_acm(){ //bot nodes accumulation
	self endon ( "disconnect" );
	self endon( "intermission" );
	//self endon( "death" );
	self endon( "game_ended" );
	
	if (!self.isbot){ return; }
		
	nr=undefined;
	
	while(isAlive(self)){
		cl("wptArr size: "+self.wptArr.size);

		while(self.wptArr.size<1){ wait 0.05; }
			
			
		for(i=0;i<self.wptArr.size;i++){
			if(!isDefined(self.wptArr[i])){
				self.wptArr = scripts\main::_arr_remove(self.wptArr,self.wptArr[i]);
			}
		}
					
		for(i=0;i<self.wptArr.size;i++){
			nr = i;
			break;
		}
		
		while(isAlive(self) && self.wptArr.size>0 && isDefined(nr) && isDefined(self.wptArr[nr])){
			//cl(self.name+" wptArr.size: "+self.wptArr.size);
			eye = self getEye();
			eye = (eye[0],eye[1],eye[2]-32);
			dist1 = distance(eye, self.wptArr[nr]); 
			bt = bulletTrace(eye, self.wptArr[nr], false, self);
			btp = bulletTracePassed(eye, self.wptArr[nr], false, self);
			bt = bt["position"];
			//dist2 = dist1 * bt;
			dist2 = dist1 - distance(bt, self.wptArr[nr]);
			//cl("pos self: "+self.wptArr[nr]);
			//cl("pos wpt: "+self getEye());
			//cl("pos bt: "+bt);
			//cl("dist1: "+dist1);
			//cl("dist2: "+dist2);
			//if(isDefined(dist1) && isDefined(dist2) && dist2<dist1 && !isDefined(self.calculating)){ 
			//if(isDefined(dist1) && isDefined(dist2) && dist2<dist1){ 
			if(!btp && self.calculating != "success"){ 
				cl("11wall!"); 
				//self.calculating = "processing";
				self _grid(eye, self.wptArr[nr]);
				//self.wptArr = scripts\main::_arr_remove(self.wptArr,self.wptArr[nr]);
				cl("11wptArr size: "+self.wptArr.size);
				level.btwatcher = undefined;
				break;
			}
			//else{
				//Objective_Add(9, "active", self.wptArr[0]);
				//if(isDefined(self.calculating) && self.calculating != "success"){ 
					//self.wptArr = scripts\main::_arr_remove(self.wptArr,self.wptArr[nr]);
					//nr = undefined;
					//self.calculating = "failed";
				//}
				self.moveToPos = self.wptArr[nr];
				if(!isDefined(self.moveToPos)){ 
					cl("11undefined self.moveToPos");
					continue; 
				} 
				//self botLookAt(self.moveToPos, 0.5);
				/*if(!isDefined(self.hasEnemy)){
					wpos = self.moveToPos;
					self thread _bot_look_at((wpos[0],wpos[1],wpos[2]+8),undefined,randomFloatRange(0.1,0.5),randomFloatRange(0.1,0.5));
				}*/
				self botMoveTo(self.moveToPos);
				c=0;
				dist1 = distance(self getEye(), self.wptArr[nr]);
				while(isAlive(self) && isDefined(dist1) && dist1>32){ 
					//cl("self.moveToPos:"+self.moveToPos);
					//cl("nr:"+nr);
					dist1 = distance(self getEye(), self.wptArr[nr]);  
					dist2 = distance(self getEye(), self.wptArr[self.wptArr.size-1]);  
					if(dist1 < 48 ){ 
						//cl("break");
						break; 
					}
					if(self.wptArr.size==1 && isDefined(dist1) && dist1<48){ 
						//self.moveToPos = undefined;
						cl("22"+self.name+" destination reached!");
						self.calculating = "idle";
						self.wptArr = scripts\main::_arr_remove(self.wptArr,self.wptArr[nr]);
						if(isDefined(self.nodeStance) && self.nodeStance != "any" ){ self botAction( "+go"+ self.nodeStance); }
						else { self botAction( "+gocrouch"); }
						nr = undefined;
						//wait 0.05;
						break;
					}
					else if(isDefined(dist2) && dist2<256){ 
						//self _bot_move_to_pos(self.moveToPos);
						self botAction( "+gocrouch"); 
						cl("22"+self.name+" searching!");
					}
					else{ 
						self botAction("-gocrouch");
						self botAction("-goprone"); 
					}
					prevPos = self getEye();
					//cl("dist1:"+dist1);
					//dist1 = distance(self.origin, self.wptArr[nr]); 
					wait 0.2;
					 
					dist2 = distance(prevPos, self getEye()); 
					if(isDefined(dist2) && dist2<8) { c++; }
					else{ c=0; }
					if(c>5){ 
						//self.moveToPos = self.origin; 
						//cl("prevPos!");
						//bombPos = level.objectivePos;
						//self _bot_calc_path(self getEye(), level.objectivePos);
					}
					if(c>=10){ 
						cl("approach timed out"); 
						//cl("22wptArr size: "+self.wptArr.size);
						self.wptArr = [];
						self.moveToPos = self getEye();
						self botMoveTo(self.moveToPos);
						self.calculating = "idle";
						break;
					} 
					
				}
				
				//self.moveToPos = undefined;
				for(i=0;i<self.wptArr.size;i++){
					if(isDefined(self.wptArr[i])){
						self.wptArr = scripts\main::_arr_remove(self.wptArr,self.wptArr[i]);
						break;
					}
				}
				cl("22wptArr size: "+self.wptArr.size);
			//}
			
			//self.gridArr = scripts\main::_arr_remove(self.gridArr,self.gridArr[0]);
			//Objective_Delete(9);
			//cl("wpt "+nr+" passed");
			wait 0.05;
		}
		wait 0.05;
	}
}

_bot_push_node(pos){ //adding node to bot wptArr
	if(!isDefined(pos)){ return; }
	pos = (pos[0],pos[1],pos[2]);
	pos = _calc_indents(pos);
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
		//self _add_node(pos);
		//self _grid(bot.origin);
		//bot.gridArr[bot.gridArr.size] = level.grid[0];
		//bot _bot_grid_calc_path(bot.origin, pos);
		//Objective_Add(10, "active", self.origin);
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
					eye = self getEye();
					self _add_node((eye[0],eye[1],eye[2])); 
					//self _add_node((self.origin[0],self.origin[1],self.origin[2])); 
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
						//self maps\mp\bots\_bot_utility::ClearScriptGoal();
						//self maps\mp\bots\_bot_utility::SetScriptGoal(self.moveToPos,48);
						//self.bot.towards_goal=self.moveToPos;
			
						while(isDefined(self.moveToPos) && isAlive(self)){
							dist = distance(self.origin, self.moveToPos);
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
					if(isDefined(self.nodeStance) && self.nodeStance != "any" ){ self botAction( "+go"+ self.nodeStance); }
					//else { self botAction( "+gocrouch"); }
					//self maps\mp\bots\_bot_script::CampAtSpot(self.moveToPos, self.moveToPos + AnglesToForward(self.nodeAngles) * 2048);
					//self setPlayerAngles(self.nodeAngles);
					//cl(self.name+":"+self.nodeAngles);
					//self.bot.stop_move=true;
					node.pos = undefined;
					wait 5;
					//self.bot.stop_move=false;
				}
				else if(dist<=150 && dist>100){ 
					self botAction( "+gocrouch" );
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

_hud_draw_nodes(){
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );	
	if (getDvar("v01d_dev") != "nav"){ return; }
	if (self.isbot) {return;}
	
	//cl("^3starting _hud_draw_nodes thread "+self.name);
	dist = 0; size=0; threshold=30;
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
						self.hudwpt[hud_q].x = objs[i].pos[0]; self.hudwpt[hud_q].y = objs[i].pos[1]; self.hudwpt[hud_q].z = objs[i].pos[2];
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

_hud_draw_grid(){
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );	
	if (getDvar("v01d_dev") != "nav"){ return; }
	if(self.isbot) { return; }
	
	cl("starting _draw_grid thread "+self.name);
	dist = 0; size=0; threshold=100; draw_dist=1500;
	hud_q=0;
	
	for(;;){
		objs = self.gridArr;	
		//cl("objs.size: "+objs.size);
		if (isDefined(objs)){
			closest = 2147483647;
			for(i=0;i<objs.size;i++){
				if(isDefined(objs[i])){
					dist = distance( self.origin, objs[i].pos );
					if(dist<draw_dist){
						self.hudgrid[hud_q] = newClientHudElem( self ); 
						self.hudgrid[hud_q] setShader( "compass_waypoint_target", 15, 15 );
						self.hudgrid[hud_q].alpha = 0.5;
						self.hudgrid[hud_q].x = objs[i].pos[0]; self.hudgrid[hud_q].y = objs[i].pos[1]; self.hudgrid[hud_q].z = objs[i].pos[2]+32;
						self.hudgrid[hud_q] SetWayPoint(true, "compass_waypoint_target");
						//self notify("showNodeInfo");
						hud_q++;
					}
				}
			}
			//self iprintln("^3level.nodes.size:"+objs.size);
		}
		wait 0.1;
		if(isDefined(self.hudgrid)){
			for( i = 0 ; i < self.hudgrid.size; i++ ){ 
				if(isDefined(self.hudgrid[i])) { self.hudgrid[i] Destroy(); }
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
