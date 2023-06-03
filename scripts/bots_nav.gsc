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
	
	//setDvar("v01d_dev","nav");

	if (getDvar("v01d_dev") == "nav"){
		if (isDefined(game["devmode"]) && game["devmode"] != "on"){ 
			game["devmode"]="on"; 
			//setdvar( "developer_script", 1 );
			//setdvar( "developer", 1 );		
			//setdvar( "sv_mapRotation", "map " + getDvar( "mapname" ) );
			exitLevel( false );
			setDvar( "bots_play_move", 0 );
			setDvar( "bots_fire_ext", 0 );
			setDvar( "bots_aim_ext", 0 );
			level.doNotAddBots=true;
			//wait 5;
		}
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
	
	level.grid = [];
	level.grid_quantity = 0;
	
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
	self endon( "death" );
	self endon( "game_ended" );
	//if (self.isbot){ return; }
	
	self waittill("spawned_player");
	
	if (getDvar("v01d_dev") != "nav"){ return; }
	
	//self thread _grid();
	//self thread _draw_grid();
	self thread _bot_nodes_acm();
	self thread _bot_self_nav();	
	self thread _open_map();		
}

_bot_self_nav(){
	self endon ( "disconnect" );
	
	if (!self.isbot) { return; }
	
	while(isAlive(self)){
		a = self GetPlayerAngles();
		sp = self getEye();
		aff = sp + anglesToForward((0, a[1], 0))*128;
		afl = sp + anglesToForward((0, a[1]-40, 0))*128;
		afr = sp + anglesToForward((0, a[1]+40, 0))*128;
		btf = bulletTrace(sp, aff, true, self);
		btl = bulletTrace(sp, afl, true, self);
		btr = bulletTrace(sp, afr, true, self);
		posf = btf["position"];
		posl = btl["position"];
		posr = btr["position"];
		entf = btf["entity"];
		entl = btl["entity"];
		entr = btr["entity"];	
	
		distf=distance(self getEye(),posf);
		distl=distance(self getEye(),posl);
		distr=distance(self getEye(),posr);
				
		if(distl<80){ 
			self botLookAt(posr, 0.1);
			//cl(self.name+" turning left");
			//self _bot_strafe("left",0.5);
			
		} else if(distr<80){ 
			self botLookAt(posl, 0.1);
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
	}
}

_bot_strafe(action, dur){
	self botAction("+strafe");
	self botAction("+"+action);
	wait dur;
	self botAction("-strafe");
	self botAction("-"+action);

}

_bot_grid_calc_path(from, to){
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "death" );
	self endon( "game_ended" );
	if (!self.isbot){ return; }

	if(!isDefined(from)){ return; }
	if(!isDefined(to)){ return; }
	
	cl(self.name+" calculating grid path from "+from+" to "+to);
	cl("grid size: "+level.grid.size);
	
	while(isDefined(from)){
		node=undefined;
		
		dist = distance(from, to);
		while(dist>32){
			closest = 99999; 
			//cl("22from "+from);
			for(i=0;i<level.grid.size;i++){
				//trace = bulletTrace(from,to/10,false,self);
				dist1 = distance(from, level.grid[i].pos);
				dist2 = distance(level.grid[i].pos,to);
				if(dist1<closest && dist1-dist2>0){ 
					closest=dist1; 
					if(from != level.grid[i].pos){ node=level.grid[i]; }
					Objective_Add(11, "active", node.pos);
					//cl("dist1 "+dist1);
					//cl("from "+node.pos);
					//wait 0.05;
				}
				//wait 0.5;
			}
			
			if(isDefined(node)){
				cl("dist "+dist);
				//cl(self.name+" to nearest node "+node.pos);
				//Objective_Add(11, "active", node.pos);
				from = node.pos;
				dist = distance(from, to);
				//cl("11from "+from);
				wait 0.05;
			}
			//wait 0.5;
		}
		from = undefined;
		cl("ended");
		wait 0.5;
	}
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
	self endon( "death" );
	self endon( "game_ended" );
	if (self.isbot){ return; }

	while(1){
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

_chk_dest_dist(from,to){
	wptl = from;
	wptr = from;
	wptlp = from;
	wptrp = from;
	wptlArr = [];
	wptrArr = [];
	btl = undefined;
	btr = undefined;
	al = (0,0,0);
	ar = (0,0,0);
	alm = 0;
	arm = 0;
	matched1 = false;
	matched2 = false;
	match1 = (0,0,0);
	match2 = (0,0,0);
	threshold=100;
	c=0;
	while(c<100){	
		al = VectorToAngles(from-to);
		ar = VectorToAngles(from-to);
		if(isDefined(wptl)){ al = VectorToAngles(wptl-to); }
		if(isDefined(wptr)){ ar = VectorToAngles(wptr-to); }
		if(isDefined(matched1)){ ar = VectorToAngles(match1-to); }
		if(isDefined(matched2)){ ar = VectorToAngles(match2-to); }
		//if(isDefined(matched)){ al = VectorToAngles(wptr-to); }
		//if(isDefined(matcheself.calculating = undefined;d)){ ar = VectorToAngles(wptr-to); }
		//afl = wptl + anglesToForward((a[0],a[1]+90,a[2]+al))*32;
		//afr = wptr + anglesToForward((a[0],a[1]-90,a[2]+al))*32;
		afl = wptl + anglesToForward((0,al[1]+90+alm,0))*32; // Y X Z
		afr = wptr + anglesToForward((0,ar[1]-90+arm,0))*32;
		aflf = wptl + anglesToForward((0,0,al[2]+90))*32;
		afrf = wptr + anglesToForward((0,0,ar[2]+90))*32;

		btl = bulletTrace(wptl, afl, false, self);
		btr = bulletTrace(wptr, afr, false, self);
		btlf = bulletTrace(wptl, aflf, false, self);
		btrf = bulletTrace(wptr, afrf, false, self);
		
		btl = btl["position"];
		btr = btr["position"];
		btlf = btlf["position"];
		btrf = btrf["position"];

		btl = _calc_indents(btl);
		btr = _calc_indents(btr);
		btlf = _calc_indents(btlf);
		btrf = _calc_indents(btrf);
		
		dist1 = distance(btl,wptl);
		dist2 = distance(btr,wptr);
		//cl("dist1:"+dist1);
		//cl("dist2:"+dist2);
		//if(isDefined(btl)){ dist1 = distance(wptl,btl); }
		//if(isDefined(btr)){ dist2 = distance(wptr,btr); }
		if(dist1<20){ alm += 45; }
		if(dist2<20){ arm -= 45; }

		distlf = distance(btl,btlf);
		distrf = distance(btr,btrf);
		
		if(distlf>20){ wptl = btlf; }
		if(distrf>20){ wptr = btrf; }
		
		//cl("distlf:"+distlf);
		//cl("distrf:"+distrf);
		
		match1 = bulletTrace(btl, to, false, self);
		match2 = bulletTrace(btr, to, false, self);
		match1 = match1["position"];
		match2 = match2["position"];
		dist1m = distance(match1,to);
		dist2m = distance(match2,to);
		
		//cl("dist1m:"+dist1m);
		//cl("dist2m:"+dist2m);

		_objective_toggle(11,1,btl,"map_artillery_selector");
		_objective_toggle(12,1,btr,"");
		//if(dist1m<1 || dist2m <1 && !isDefined(matched)){ 
			//matched = true;
			//self.calculating = undefined; 
			//break;
		//}		
		if(dist1m<5){ 
			al = VectorToAngles(match1-to); 
			matched1 = true; 
			alm = 90;
		}
		if(dist2m<5){ 
			ar = VectorToAngles(match2-to); 
			matched2 = true; 
			arm = -90;
		}
		
		//from = btl;
		wptl = (btl[0],btl[1],btl[2]);
		wptlArr[wptlArr.size] = wptl;
		//wptlp = wptl;
		//self _add_node((wptl[0],wptl[1],wptl[2])); // 2 = Up/Down [Y]
		//from = btr;
		wptr = (btr[0],btr[1],btr[2]);
		wptrArr[wptlArr.size] = wptr;
		//wptrp = wptr;
		//self _add_node((wptr[0],wptr[1],wptr[2]));
		//self.wptArr[self.wptArr.size] = wpt;
		//wait 0.05;
		_objective_toggle(11,0,wptl,"");
		_objective_toggle(12,0,wptr,"");
		
		dist1 = distance(wptl,to);
		dist2 = distance(wptr,to);
		
		cl("distl:"+dist1);
		cl("distr:"+dist2);
		//cl("wptl:"+wptl);
		//cl("wptr:"+wptr);
		

		if(dist1 < 64){ matched1 = true; cl("matched1"); c=threshold; self.wptArr = wptlArr; }
		else if(dist2 < 64){ matched2 = true; cl("matched2"); c=threshold; self.wptArr = wptrArr; }
		

		if(matched1){ _objective_toggle(11,1,match1,"map_artillery_selector"); }
		if(matched2){ _objective_toggle(12,1,match2,""); }
		
		//if(dist1m < 1){ matched1 = true; cl("22matched1"); c=threshold; wptlArr[wptlArr.size-1] = match1; self.wptArr = wptlArr; }
		//else if(dist2m < 1){ matched2 = true; cl("22matched2"); c=threshold; wptrArr[wptrArr.size-1] = match2; self.wptArr = wptrArr; }
		
		if(matched1 || matched2){ 
			self.calculating = "success";
			break; 
		}
		
		c++; cl("c:"+c);
		if(c>threshold){ 
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
		
	cl(self.name+" calculating path to " + to);
	
	if(isDefined(level.btwatcher) && level.btwatcher == true){ cl("11already running!"); return; }
	level.btwatcher = true;
	//level thread _bt_watcher();
	objs=undefined;
	self.calculating = undefined;
		
	icon = "map_artillery_selector";
	//_objective_toggle(11,1,to,icon);
		
	//while(isDefined(self.calculating) && self.calculating == ""){
		//Objective_Add(11, "active", to);
		
		//icon = ""; //rectangle icon
		//icon = level.icon;
		//_objective_toggle(11,1,to,icon);
		
		//wait 1;
		
		from = bulletTrace(from,(to[0],to[1],to[2]), false, self);
		from = from["position"];
		from = _calc_indents(from);

		self _chk_dest_dist(from,to);
				
		while(isDefined(self.calculating) && self.calculating != "failed" && self.calculating != "success"){ wait 0.05; };
		cl("22calc ended");
		//self.calculating = undefined;
		cl("self.calculating:"+ self.calculating);
		wait 0.05;
		//to = undefined;
		//break;
	//}

}

_bot_nodes_acm(){
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "death" );
	self endon( "game_ended" );
	
	if(!self.isbot){
		if(self.pers["team"] == "axis"){ level maps\mp\bots\_bot::add_bot("axis"); }
		else{ level maps\mp\bots\_bot::add_bot("allies"); }
	}
	
	if (!self.isbot){ return; }
		
	self.wptArr = [];
	self.gridArr = [];
	self.calculating = undefined;
	nr=undefined;
	
	while(1){
		while(self.wptArr.size<1){ wait 0.05; }
		
		cl("wptArr size: "+self.wptArr.size);
								
		for(i=0;i<self.wptArr.size;i++){
			if(isDefined(self.wptArr[i])){
				//self.wptArr = scripts\main::_arr_remove(self.wptArr,self.wptArr[i]);
				nr = i;
				break;
			}
		}

		while(self.wptArr.size>0 && isDefined(nr) && isDefined(self.wptArr[nr])){
			cl(self.name+" wptArr.size: "+self.wptArr.size);
			dist1 = distance(self getEye(), self.wptArr[nr]); 
			bt = bulletTrace(self getEye(), self.wptArr[nr], false, self);
			bt = bt["position"];
			//dist2 = dist1 * bt;
			dist2 = dist1 - distance(bt, self.wptArr[nr]);
			cl("pos self: "+self.wptArr[nr]);
			cl("pos wpt: "+self getEye());
			cl("pos bt: "+bt);
			cl("dist1: "+dist1);
			cl("dist2: "+dist2);
			if(dist2<dist1 && !isDefined(self.calculating)){ 
				cl("11wall!"); 
				self.calculating = "processing";
				self _bot_calc_path(self getEye(), self.wptArr[nr]);
				level.btwatcher = undefined;
			}
			//else{
				//Objective_Add(9, "active", self.wptArr[0]);
				if(isDefined(self.calculating) && self.calculating != "success"){ 
					//self.wptArr = scripts\main::_arr_remove(self.wptArr,self.wptArr[nr]);
					nr = undefined;
					self.calculating = undefined;
					break; 
				}
				self.moveToPos = self.wptArr[nr];
				self botLookAt(self.moveToPos, 0.5);
				self botMoveTo(self.moveToPos);
				c=0;
				while(dist1>32){
					//cl("dist1:"+dist1);
					dist1 = distance(self getEye(), self.wptArr[nr]); 
					wait 0.05;
					c++;
					if(c>100){ break; }
				}
				if(c>100){ 
					cl("approach timed out"); 
					self.wptArr = [];
				} else {
					self.wptArr = scripts\main::_arr_remove(self.wptArr,self.wptArr[nr]);
					nr = undefined;
				}
				//for(i=0;i<self.wptArr.size;i++){
				//	if(isDefined(self.wptArr[i])){
				//		self.wptArr = scripts\main::_arr_remove(self.wptArr,self.wptArr[i]);
				//		break;
				//	}
				//}
			//}
			
			//self.gridArr = scripts\main::_arr_remove(self.gridArr,self.gridArr[0]);
			//Objective_Delete(9);
			//cl("wpt "+nr+" passed");
			wait 0.05;
		}
		wait 0.05;
	}
}

_bot_push_node(pos){
	if(!isDefined(pos)){ return; }
	pos = (pos[0],pos[1],pos[2]+64);
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
		//self _grid(bot.origin);
		//bot.gridArr[bot.gridArr.size] = level.grid[0];
		//bot _bot_grid_calc_path(bot.origin, pos);
		//Objective_Add(10, "active", self.origin);
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
	self endon( "game_ended" );	
	if (getDvar("v01d_dev") != "nav"){ return; }
	if(self.isbot) { return; }
	
	cl("starting _draw_grid thread "+self.name);
	dist = 0; size=0; threshold=100; draw_dist=1500;
	hud_q=0;
	
	for(;;){
		objs = level.grid;	
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

_grid(startPos){
	self endon ( "disconnect" );
	self endon( "intermission" );
	//self endon( "death" );
	self endon( "game_ended" );
	if (getDvar("v01d_dev") != "nav"){ return; }
	if (self.isbot){ return; }
	
	//self.nodes=[];
	//self.nodes_quantity=0;

	cl("33grid_loop");
	//for(;;){
		//while(!self UseButtonPressed()){ wait 0.05; }
		myAngles = self GetPlayerAngles();
		if(!isDefined(startPos)){ startPos = self getEye(); }
		startPosForward = startPos + anglesToForward((0,myAngles[1],0))*120;
		trace = bulletTrace(startPos,startPosForward,true,self);
		//pos = trace["position"];
		pos = startPos;
		x_max=64;
		y_max=64;
		x_int=32;
		y_int=32;
		c=15;
		//ent = trace["entity"];
		if(isDefined(pos)){
			for(x=1;x<=x_max;x++){
				for(y=1;y<=y_max;y++){
					trace_down = bulletTrace((pos[0]+(y*y_int)-(y_int/2*y_max), pos[1]+(x*x_int)-(x_int/2*x_max), pos[2]), (pos[0]+(y*y_int)-(y_int/2*y_max), pos[1]+(x*x_int)-(x_int/2*x_max), pos[2]-100), false, self);
					//trace_down = bulletTrace((pos[0]+(y*64)-(32*y_max), pos[1]+(x*64)-(32*x_max), pos[2]), (pos[0]+(y*64)-(32*y_max), pos[1]+(x*64)-(32*x_max), pos[2]-100), false, self);
					//trace_down = bulletTrace((pos[0]-(64*10/2)+(x*64), pos[1]-(64*10/2)+(z*64), pos[2]), (pos[0]-(64*10/2)+(x*64)-64, pos[1]-(64*10/2)+(z*64), pos[2]-100), false,self);
					pos2 = trace_down["position"];
					//self _add_node(pos2);
					level.grid[level.grid_quantity] = spawnstruct();
					level.grid[level.grid_quantity].pos = pos2;
					level.grid_quantity++;
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
					//wait 0.5;
				}
			}
		}
		//while(self UseButtonPressed()){	wait 0.05; }
		//wait 0.05;
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
					self _add_node((self.origin[0],self.origin[1],self.origin[2]-40)); 
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
