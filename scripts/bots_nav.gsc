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
	setDvar("v01d_dev","nav");

	if (getDvar("v01d_dev") == "nav"){
		//if (isDefined(game["devmode"]) && game["devmode"] != "on"){ 
			game["devmode"]="on"; 
			//setdvar( "developer_script", 1 );
			//setdvar( "developer", 1 );		
			//setdvar( "sv_mapRotation", "map " + getDvar( "mapname" ) );
			//exitLevel( false );
			setDvar( "bots_aim_ext", 0 );
			setDvar( "bots_fire_ext", 0 );
			setDvar( "bots_play_fire", 0 );
			setDvar( "bots_play_aim", 0 );
			setDvar( "bots_play_move", 0 );
			setDvar( "bots_play_nade", 0 );
			setDvar( "bots_play_knife", 0 );
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
	
	if(isDefined(level.sabBomb))
	{
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
	
    level thread _player_connecting();
	level thread _load_nodes();
	level thread _bomb_pos();
	//level thread _add_some_bots(2);
	
	for(;;)
    {
		level waittill("connected", player);
		
		player thread _player_spawn();
		player thread _add_remove_nodes();
		player thread _hud_draw_nodes();
		player thread _hud_draw_grid();
		//player thread _hud_draw_squad();
		//player thread _hud_draw_tagged();
		//player thread _bot_move_to();
		player thread _marked_nodes();
		player thread _save_nodes();
		player thread _clear_nodes();
		//player thread _bot_take_cover();
		player thread _node_info();
		
		if(!player.isbot)
		{
			level maps\mp\bots\_bot::add_bot("axis");
			//level maps\mp\bots\_bot::add_bot("allies");
		}
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
			
		cl("player " + player.name + " connected!");
		if (getDvar("v01d_dev") != "nav")
		{
			exec("map mp_ancient_ultimate");
		}

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
		self thread _bot_nodes_acm();
		//self thread _bot_self_nav();	
		self thread _open_map();		
		//self thread _bot_go_to_objective();
		//self thread _bot_look_at_bombpos();
		//self thread _bot_look_at_enemy();
		//self thread _bot_move_to_nearest_wpt();
		
		self thread _dev_nodes_plant();
	}
}

_bomb_pos(){
	level endon ( "disconnect" );
	level endon( "intermission" );
	level endon( "game_ended" );
	
	while(1)
	{
		level.bombCarrier = undefined;
		
		players = getentarray("player", "classname");
		for(i=0;i<players.size;i++)
		{
			if(isDefined(players[i].isBombCarrier) && players[i].isBombCarrier == true)
			{
				level.bombCarrier = players[i]; 
				break;
			}
		}
		
		if(isDefined(level.bombCarrier))
		{ 
			//cl("level.bombCarrier: "+level.bombCarrier.name);
			team = level.bombCarrier.pers["team"];
			if(team == "axis"){ team = "allies"; }
			else if(team == "allies"){ team = "axis"; }
			bombSite = getEnt("sab_bomb_"+team+"", "targetname");
			level.objectivePos = bombSite.origin;
		} 
		else
		{ 
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

	if(!self.isbot)
	{
		if(self.pers["team"] == "axis"){ 
			level maps\mp\bots\_bot::add_bot("axis"); 
		}
		else
		{ 
			level maps\mp\bots\_bot::add_bot("allies"); 
		}
	}

	if (!self.isbot){ return; }
	
	//self.approachNode = undefined;
	cl("_start_nav started on "+self.name);
	
	self.wptArr = [];
	self.wptPassed = [];
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
	if(!isDefined(aimspeed)){ aimspeed=1; }
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

_bot_go_to_objective()
{
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	self endon( "death" );
	if (!self.isbot){ return; }
	
	cl("_bot_go_to_objective started on " + self.name);
	
	minDist = 128;
	maxDist = 360;
	prevPos = (0, 0, 0);
	to = _construct_node(self getEye());
	
	while(isAlive(self))
	{
		if(isDefined(level.bombCarrier))
		{
			if(level.bombCarrier.pers["team"] == "axis")
			{
				cl("level.bombZones[axis]: " + level.bombZones["axis"].curOrigin);
				level.objectivePos = level.bombZones["allies"].curOrigin;
			}
			else if(level.bombCarrier.pers["team"] == "allies")
			{
				cl("level.bombZones[allies]: " + level.bombZones["allies"].curOrigin);
				level.objectivePos = level.bombZones["axis"].curOrigin;
			}
		}
		
		bombPos = level.objectivePos;
		btpBomb = BulletTracePassed(self getEye(), (bombPos[0],bombPos[1],bombPos[2]), false, self);

		if(btpBomb)
		{
			node = _construct_node(bombPos);
			self _bot_push_node(node);
			
			while(!isDefined(level.bombCarrier))
			{
				cl("waiting to pickup the bomb...");
				wait 1;
			}
			
			self.wptPassed = [];
		} 
		else
		{
			to = _get_nearest_node(self getEye(), level.objectivePos, undefined, true);
			
			if(isDefined(to))
			{
				from = self _construct_node(self getEye());
				to = self _construct_node(level.objectivePos);
				
				nodes = self _bot_calc_path(from, to);
				
				for(i = 0; i < nodes.size; i++)
				{
					self _bot_push_node(nodes[i]);
					cl("nodes[i]: " + nodes[i].pos);
					//wait 1;
				}
				
				self _bot_push_node(to);
			}
		}
		
		if(!isDefined(to)){ to = _construct_node(self getEye()); }
		
		self _bot_push_node(to);
		
		dist = distance(to.pos, self getEye());
		
		while(dist > 32)
		{
			if(prevPos == self getEye())
			{
				cl(self.name + " prevPos");
				from = self _construct_node(self getEye());
				//self _grid_create(from, to);
				//wait 5;
				break;
			}
			
			/*if(dist > 128)
			{
				distz = to.pos[2] - self getEye()[2];
			
				if(distz > 32)
				{
					cl(self.name + " distz: " + distz);
					wait 1;
					break;
				}
			}*/
			
			wait 1;
					
			dist = distance(to.pos, self getEye());
			prevPos = self getEye();
		}
		
		while(self.wptArr.size < 1)
		{	
			from = self _construct_node(self getEye());
			to = self _construct_node(level.objectivePos);
			
			nodes = self _bot_calc_path(from, to);
			
			for(i = 0; i < nodes.size; i++)
			{
				self _bot_push_node(nodes[i]);
				cl("nodes[i]: " + nodes[i]);
				wait 1;
			}
		}
		
		wait 0.1;
	}
}

_check_adjacent(from, to) //vector
{
	btp = bulletTracePassed(from, to, false, self);

	if(btp)
	{
		while(1)
		{
			a = VectorToAngles(to - from);
			aff = from + anglesToForward((a[0], a[1], a[2])) * 32;
			btf = bulletTrace(from, aff, false, self);
			posf = btf["position"];
			posf = _calc_indents(posf);
			
			//bt = bulletTrace(from, to, false, self);
			//bt = bt["position"];
			
			node = _construct_node(posf);
			self.gridArr[self.gridArr.size] = node;
			
			va = VectorToAngles(posf - from);
			frac = a[0] - va[0];
			
			//cl("va: " + va);
			//cl("frac: " + frac);
			
			if(distance(from, to) < 32)
			{
				cl("return");
				wait 3;
				self.gridArr = [];
				return true;
			}
			
			from = posf;
			
			//wait 0.5;
		}
	}
	else
	{
		cl("btp is false");
	}
	
	return false;
}

_get_nearest_node(from, to, indent, getOnlyVisible, distzMax) //vector
{
	if(!isDefined(level.nodes)){ return; }
	if(!isDefined(indent)){ indent = -32; }
	if(!isDefined(getOnlyVisible)){ getOnlyVisible = false; }
	if(!isDefined(distzMax)){ distzMax = 999; }
			
	eye = self getEye();
	nr = undefined;

	//for(i1 = 0; i1 < level.nodes.size; i1++)
	//{
		closestFrom = 99999;
		closestTo = 99999;
					
		for( i2 = 0 ; i2 < level.nodes.size; i2++ )
		{
			//if(i2 == i1){ continue; }
			
			distFrom = distance(level.nodes[i2].pos, from);
			distTo = distance(level.nodes[i2].pos, to);		
			distFromTo = distance(from, to);
			distz = level.nodes[i2].pos[2] - self getEye()[2];
			
			angles = VectorToAngles(level.nodes[i2].pos - from);
			vd = _dp(from, level.nodes[i2].pos, angles);
			//cl("vd: " + vd);
			//cl("angles: " + angles);
			
			//wait 1;
			
			btp = BulletTracePassed(from, level.nodes[i2].pos, false, self);
			adj = _check_adjacent(from, level.nodes[i2].pos);
		
			if(getOnlyVisible)
			{
				if(btp && distz < distzMax && distFrom > 12 && distFrom < closestFrom && distFromTo - distTo > indent)
				{			
					nr = i2;
					closestFrom = distFrom;
				}
			}
			else
			{
				if(distz < distzMax && distFrom > 12 && distFrom < closestFrom && distFromTo - distTo > indent)
				{			
					nr = i2;
					closestFrom = distFrom;
				}
			}
		}
	//}
	
	if(isDefined(nr))
	{
		return level.nodes[nr];
	}	
	
	return undefined;
}

_bot_calc_path(from, to)
{
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "death" );
	self endon( "game_ended" );
	
	if (!self.isbot){ return; }
		
	cl(self.name+" calculating path to " + to.pos);
		
	wptArr = [];
	self.gridArr = [];
	stop = undefined;
	lastPos = (0,0,0);

	while(!isDefined(stop))
	{
		cl("from.pos: " + from.pos);
		cl("lastPos: " + lastPos);

		nearestNode = _get_nearest_node(from.pos, to.pos, 0, true); //from, to, indent, getOnlyVisible, distzMax
		
		wait 0.05;
		
		/*if(!isDefined(nearestNode))
		{
			cl(self.name + " is trying to get another node");
			nearestNode = _get_nearest_node(from.pos, to.pos, -32, true);
		}*/

		if(isDefined(nearestNode))
		{
			cl("nearestNode.pos: " + nearestNode.pos);
			wptArr[wptArr.size] = nearestNode;
			
			_objective_toggle(8,1,from.pos,"map_artillery_selector");
			self.gridArr[self.gridArr.size] = nearestNode;
						
			btpo = BulletTracePassed(nearestNode.pos, level.objectivePos, false, self);
			btpn = BulletTracePassed(nearestNode.pos, to.pos, false, self);

			/*if(btpo)
			{ 
				wptArr[wptArr.size] = _construct_node(level.objectivePos);
				stop = true;
				break;				
			}
			else */
			
			/*if(btpn)
			{
				wptArr[wptArr.size] = to;
				//lastPos = nearestNode.pos;
				cl("btpn");
				stop = true;
				break;
			}*/
			
			lastPos = nearestNode.pos;
			
			//wait 1;
		}
		
		wait 1;
		
		if(lastPos == from.pos)
		{
			stop = true;
			cl("stopped");
			break;
		}
		
		from.pos = lastPos;
	}

	for(i = 0; i < wptArr.size; i++)
	{
		//self _bot_push_node(wptArr[i]);
		self.gridArr[self.gridArr.size] = wptArr[i];
		//wait 2;
	}
	
	cl(self.name + " calc path ended");
	
	return wptArr;
}

_bot_self_nav(to){ //bot avoiding obstacles by turning, not strafing
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	self endon( "death" );
	
	if (!self.isbot) { return; }
	
	wait 0.5;
	
	self thread _bot_look_at(to.pos);
	thread _ping_marked_node(to);
	
	cl(self.name + " is looking at " + to.pos);
	
	while(isAlive(self))
	{
		if(distance(self getEye(), to.pos) < 16){ return; }
	
		a = self GetPlayerAngles();
		sp = self getEye();
		aff = sp + anglesToForward((0, a[1], 0))*128;
		affu = sp + anglesToForward((a[0]-40, a[1], 0))*64;
		affd = sp + anglesToForward((a[0]+40, a[1], 0))*64;
		afl = sp + anglesToForward((0, a[1]+45, 0))*128; //left
		afr = sp + anglesToForward((0, a[1]-45, 0))*128; //right
		afrr = sp + anglesToForward((0, a[1]+180, 0))*128;
		btf = bulletTrace(sp, aff, true, self);
		btfu = bulletTrace(sp, affu, true, self);
		btfd = bulletTrace(sp, affd, true, self);
		btl = bulletTrace(sp, afl, true, self);
		btr = bulletTrace(sp, afr, true, self);
		btrr = bulletTrace(sp, afr, true, self);
		posf = btf["position"];
		posfu = btfu["position"];
		posfd = btfd["position"];
		posl = btl["position"];
		posr = btr["position"];
		posrr = btrr["position"];
		entf = btf["entity"];
		entl = btl["entity"];
		entr = btr["entity"];	
		
		posl = _calc_indents(posl);
		posr = _calc_indents(posr);
	
		distf=distance(self getEye(),posf);
		distfu=distance(self getEye(),posfu);
		distfd=distance(self getEye(),posfd);
		distl=distance(self getEye(),posl);
		distr=distance(self getEye(),posr);
		
		btp = bulletTracePassed(self getEye(), to.pos, false, self);
		bt = bulletTrace(self getEye(), to.pos, false, self);
		bt = bt["position"];
		
		if(btp)
		{ 
			self botMoveTo(to.pos);	 
			self _bot_look_at(to.pos);
			
			if(distance(bt, self getEye()) < 32)
			{
				self _bot_look_at(self getEye());
				break;
			}

		}	
		else if(distf<32 && distr<32 && distl<32)
		{
			self botMoveTo(self getEye());
		 	self _bot_look_at(posrr);
		 	cl("22" + self.name + " turning 180 degrees");
		 	wait 1;
		}
		else if(distl<32 && distf >= 32)
		{ 
			self _bot_look_at(posr);
			cl("22" + self.name + " turning right");
			
			self botMoveTo(self getEye());
			
			//pos = self _wall_vector();
			//self botMoveTo(pos);
			
			wait 1;
			
			while(1)
			{
				a = self GetPlayerAngles();
				sp = self getEye();
				aff = sp + anglesToForward((0, a[1], 0))*128;
				btf = bulletTrace(sp, aff, true, self);
				posf = btf["position"];
				
				afl = posf + anglesToForward((0, a[1]+30, 0))*128;
				btl = bulletTrace(posf, afl, true, self);
				posl = _calc_indents(btl["position"]);
				
				distl=distance(self getEye(), posl);
				
				self _bot_look_at(posl);
				self botMoveTo(posl);
				
				cl("distl: " + distl);
				
				if(distl >= 48)
				{ 
					self _bot_look_at(posl);
					self botMoveTo(posl);
					cl("22" + self.name + " moving left");
				}
				else
				{
					break;
				}
				
				wait 0.1;
			}
		} 
		else if(distr<32 && distf >= 32)
		{ 
			self _bot_look_at(posl);
			cl("22" + self.name + " turning left");
			
			self botMoveTo(self getEye());
			
			wait 1;
			//pos = self _wall_vector();
			//self botMoveTo(pos);
			
			while(1)
			{
				a = self GetPlayerAngles();
				sp = self getEye();
				aff = sp + anglesToForward((0, a[1], 0))*128;
				btf = bulletTrace(sp, aff, true, self);
				posf = btf["position"];
				
				afr = posf + anglesToForward((0, a[1]-30, 0))*128;
				btr = bulletTrace(posf, afr, true, self);
				posr = _calc_indents(btr["position"]);
				
				distr=distance(self getEye(),posr);
				
				self _bot_look_at(posr);
				self botMoveTo(posr);
				
				cl("distr: " + distr);
				
				if(distl >= 48)
				{ 
					self _bot_look_at(posr);
					self botMoveTo(posr);
					cl("22" + self.name + " moving right");
				}
				else
				{
					break;
				}
				
				wait 0.1;
			}
		}
		else if(distf < 32)
		{ 
			self botMoveTo(self getEye());
			cl("22" + self.name + " _wall_vector");
			//pos = self _wall_vector(posf);
			self _bot_look_at(posr);
			self botMoveTo(posr);
			wait 1;
		}
		else
		{
			self _bot_look_at(posf);
			self botMoveTo(posf);
		}
		
		wait 0.1;
	}
}

_wall_vector(dest)
{
		a = self GetPlayerAngles();
		sp = self getEye();
		
		afl = sp + anglesToForward((0, a[1]+90, 0))*128; //left
		afr = sp + anglesToForward((0, a[1]-90, 0))*128; //right
		
		btl = bulletTrace(sp, afl, true, self);
		btr = bulletTrace(sp, afr, true, self);
		
		posl = btl["position"];
		posr = btr["position"];
		
		posl = _calc_indents(posl);
		posr = _calc_indents(posr);
	
		distl=distance(self getEye(), posl);
		distr=distance(self getEye(), posr);
		
		pos = undefined;
		
		btp = bulletTracePassed(self getEye(), dest, false, self);
		bt = bulletTrace(self getEye(), dest, false, self);
		bt = bt["position"];
		
		if(btp)
		{
			pos = bt;
		}
		else if(distl > distr)
		{
			pos = posl;
		}
		else if(distr > distl)
		{
			pos = posr;
		}
		else
		{
			pos = posr;
		}
		
		return pos;
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
	
	location = undefined;

	while(isAlive(self)){
		while (!self LeanLeftButtonPressed()){ wait 0.05; }
		self beginLocationSelection( "map_artillery_selector", level.artilleryDangerMaxRadius * 1.2 );
		wait 0.5;
		//while (!self LeanLeftButtonPressed()){ wait 0.05; }
		self waittill( "confirm_location", location );
		self endLocationSelection();
		
		if(isDefined(location))
		{
			loc = location;
			traceDown = bulletTrace((loc[0], loc[1], self.origin[2]+999),(loc[0], loc[1], self.origin[2]-999+64), false, self); // + up, - down
			traceDown = traceDown["position"];
			cl("location: " + traceDown);
			_construct_node(traceDown);
		}
		
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

_calc_indents(pos, minDist){
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

	//afn = pos + anglesToForward((0,90,0)*32);
	//afe = pos + anglesToForward((0,0,90)*32);
	//afs = pos + anglesToForward((0,-90,0)*32);
	//afw = pos + anglesToForward((0,0,-90)*32);
	
	if(!isDefined(minDist)){ minDist = 16; }

	btn = bulletTrace(pos,(pos[0]+minDist,pos[1],pos[2]), false, self); // + north, - south
	btn = btn["position"];
	bte = bulletTrace(pos,(pos[0],pos[1]+minDist,pos[2]), false, self); // + west - east 
	bte = bte["position"];
	bts = bulletTrace(pos,(pos[0]-minDist,pos[1],pos[2]), false, self);
	bts = bts["position"];
	btw = bulletTrace(pos,(pos[0],pos[1]-minDist,pos[2]), false, self);
	btw = btw["position"];
	btu = bulletTrace(pos,(pos[0],pos[1],pos[2]+minDist), false, self);
	btu = btu["position"];
	btd = bulletTrace(pos,(pos[0],pos[1],pos[2]-minDist), false, self);
	btd = btd["position"];
	
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
	dist5 = distance(pos,btu);
	dist6 = distance(pos,btd);
	
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
	distz=dist5-dist6;
		
	pos = (pos[0]+disty,pos[1]+distx,pos[2]+distz);
		
	return pos;
}

_dev_nodes_plant()
{
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "death" );
	self endon( "game_ended" );
	if (self.isbot){ return; }

	cl("_dev_nodes");
	
	while(isAlive(self))
	{
		while (!self LeanRightButtonPressed()){ wait 0.05; }

		cl("creating grid");
		
		players = getentarray("player", "classname");
		for(i=0;i<players.size;i++)
		{
			if(players[i].isbot)
			{
				bot = players[i];
				bot.gridArr = [];
				bot _grid_create(self getEye(), bot getEye());
			}
		}
		
		while (self LeanRightButtonPressed()){ wait 0.05; }
		wait 0.05;
	}
}

_grid_node_props(pos, score)
{
	node = spawnstruct();
	node.pos = pos;
	node.score = score;
	
	return node;
}

_grid_node_trace_down(from)
{

}

_grid_check_merged_nodes(bot, pos, minDist)
{
	if(!isDefined(minDist)){ minDist = 4; }
		
	for(i = 0; i < bot.gridArr.size; i++)
	{
		//if(bot.gridArr[i].pos == pos){ continue; }
		
		dist = distance(bot.gridArr[i].pos, pos);
		
		if(isDefined(dist) && dist < minDist)
		{
			//cl("dist: " + dist);
			//bot.gridArr = scripts\main::_arr_remove(bot.gridArr, bot.gridArr[j]);
			return true;
		}
	}
	
	return false;
}

_grid_check_bot_nearby(bot, dest, minDist)
{
	if(!isDefined(minDist)){ minDist = 16; }
		
	for(i = 0; i < bot.gridArr.size; i++)
	{		
		dist = distance(bot.gridArr[i].pos, dest.pos);
		
		stp = BulletTracePassed(bot.gridArr[i].pos, dest.pos, false, self);
		
		if(isDefined(dist) && dist < minDist && stp)
		{
			return true;
		}
	}
	
	return false;
}

_grid_nodes_plant(from, to, score, interval)
{
	if(!isDefined(interval)){ interval = 32; }

	pos = from.pos;
	a = VectorToAngles(to.pos - from.pos);
	afl = pos + anglesToForward(( a[0], a[1]+45, a[2] )) * interval; //left
	afr = pos + anglesToForward(( a[0], a[1]-45, a[2] )) * interval; //right

	btl = bulletTrace(pos, afl, false, self);
	btl = _calc_indents(btl["position"]);
	btr = bulletTrace(pos, afr, false, self);
	btr = _calc_indents(btr["position"]);
	
	if(!_grid_check_merged_nodes(self, btl, interval * 0.5))
	{
		self.gridArr[self.gridArr.size] = _grid_node_props(btl, score);
	}
	
	if(!_grid_check_merged_nodes(self, btr, interval * 0.5))
	{
		self.gridArr[self.gridArr.size] = _grid_node_props(btr, score);
	}
}

/*_grid_nodes_plant(pos, score, interval) //omni directional
{
	if(!isDefined(interval)){ interval = 32; }

	btn = bulletTrace(pos,(pos[0]+interval,pos[1],pos[2]), false, self); // + up, - down
	btn = _calc_indents(btn["position"]);
	bte = bulletTrace(pos,(pos[0],pos[1]+interval,pos[2]), false, self); // + left - right 
	bte = _calc_indents(bte["position"]);
	bts = bulletTrace(pos,(pos[0]-interval,pos[1],pos[2]), false, self);
	bts = _calc_indents(bts["position"]);
	btw = bulletTrace(pos,(pos[0],pos[1]-interval,pos[2]), false, self);
	btw = _calc_indents(btw["position"]);
		
	if(!_grid_check_merged_nodes(self, btn, interval))
	{
		self.gridArr[self.gridArr.size] = _grid_node_props(btn, score);
	}
	if(!_grid_check_merged_nodes(self, bte, interval))
	{
		self.gridArr[self.gridArr.size] = _grid_node_props(bte, score);
	}
	if(!_grid_check_merged_nodes(self, bts, interval))
	{
		self.gridArr[self.gridArr.size] = _grid_node_props(bts, score);
	}
	if(!_grid_check_merged_nodes(self, btw, interval))
	{
		self.gridArr[self.gridArr.size] = _grid_node_props(btw, score);
	}
}*/

_grid_create(from, to){
	self endon ( "disconnect" );
	self endon( "intermission" );
	//self endon( "death" );
	self endon( "game_ended" );
	
	if (getDvar("v01d_dev") != "nav"){ return; }
	//if (!self.isbot){ return; }
	
	if(!isDefined(from)){ return; }
	//if(!isDefined(to)){ return; }
	
	cl("33grid thread");
	self.gridArr = [];
	stop = undefined;
	score = 0;
	interval = 32;
	iterations = 24;
	
	self _grid_nodes_plant(from, to, score, interval);
	
	for(i = 0; i <= iterations; i++)
	{
		if(isDefined(stop)){ break; cl("node planting stopped"); }

		score++;
		
		for(j = 0; j < self.gridArr.size; j++)
		{
			if(self.gridArr[j].score == score - 1)
			{
				self _grid_nodes_plant(self.gridArr[j], to, score, interval);
				//cl("j: " + j);
				
				if(_grid_check_bot_nearby(self, to, interval))
				{
					stop = true;
					break;
				}

				//wait 0.5;
			}
		}
		
		wait 0.05;
	}

	self _bot_grid_calc_path(from, to, score - 1);
	
	cl("22self.gridArr.size:" + self.gridArr.size);
	cl("22grid thread ended");
}

_bot_grid_calc_path(from, to, maxScore)
{
	self endon ( "disconnect" );
	self endon( "intermission" );
	//self endon( "death" );
	self endon( "game_ended" );
	
	if (!self.isbot){ return; }

	if(!isDefined(from)){ return; }
	if(!isDefined(to)){ return; }
	if(!isDefined(self.gridArr)){ return; }
	
	cl(self.name + " calculating grid path from " + from.pos + " to " + to.pos);
	//cl("grid size: "+self.gridArr.size);
	
	nr = undefined;
	stop = undefined;
	score = maxScore;
	lastNode = undefined;
	gridArr = [];
	
	cl("score: " + score);
	
	for( i1 = maxScore ; i1 > 0; i1-- )
	{					
		for( i2 = 0 ; i2 < self.gridArr.size; i2++ )
		{			
			closest = 99999;
			closestTo = 99999;
			closestFrom = 99999;

			dist = distance(self.gridArr[i2].pos, self.gridArr[i1].pos);
			distTo = distance(self.gridArr[i2].pos, to.pos);
			distFrom = distance(self.gridArr[i2].pos, from.pos);

			/*if(score == maxScore)
			{
				//cl("maxScore: " + maxScore);
				if(distTo < closestTo)
				{
					closestTo = distTo;
					nr = i2;
					lastNode = self.gridArr[i2];
				}
			}*/
			if(self.gridArr[i2].score == score)
			{
				for( i3 = 0 ; i3 < self.gridArr.size; i3++ )
				{
					if(i3 == i2){ continue; }
					
					dist = distance(self.gridArr[i3].pos, self.gridArr[i2].pos);
					distTo = distance(self.gridArr[i3].pos, to.pos);
					distFrom = distance(self.gridArr[i3].pos, from.pos);

					if(self.gridArr[i3].score == score)
					{
						if(dist < closest && distTo < closestTo)
						{
							nr = i3;
							closest = dist;
							closestTo = distTo;
						}
					}
				}
			}
		}
		
		if(isDefined(nr))
		{
			gridArr[gridArr.size] = self.gridArr[nr];
			//self.gridArr = gridArr;
			//cl("nr:" + nr);
		}
		
		score--;
		wait 0.05;
	}
	
	self.gridArr = gridArr;

	for(i = 0; i < gridArr.size; i++)
	{
		self.gridArr[self.gridArr.size] = gridArr[i];
		self _bot_push_node(gridArr[i]);
		//wait 1; 
	}
		
	//self _bot_push_node(to);

	self.calculating = "success";
	
	cl("22grid calc ended");
}

_bot_nodes_acm() //bot nodes accumulation
{
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "death" );
	self endon( "game_ended" );
	
	if (!self.isbot){ return; }
		
	nr=undefined;
	prevPos = self getEye();
	
	while(isAlive(self))
	{
		cl(self.name + " wptArr size: "+self.wptArr.size);

		while(self.wptArr.size < 1){ wait 0.2; }
		
		//wait 1;
			
		for(i=0;i<self.wptArr.size;i++)
		{
			if(!isDefined(self.wptArr[i]))
			{
				self.wptArr = scripts\main::_arr_remove(self.wptArr, self.wptArr[i]);
			}
		}
					
		for(i=0;i<self.wptArr.size;i++)
		{
			nr = i;
			break;
		}
		
		while(isAlive(self) && self.wptArr.size > 0 && isDefined(nr) && isDefined(self.wptArr[nr]))
		{
			eye = self getEye();
			eye = (eye[0],eye[1],eye[2]+64);
			dist1 = distance(eye, self.wptArr[nr].pos); 
			bt = bulletTrace(eye, self.wptArr[nr].pos, false, self);
			bt = bt["position"];
			btp = bulletTracePassed(eye, self.wptArr[nr].pos, false, self);
			dist2 = dist1 - distance(bt, self.wptArr[nr].pos);
			
			if(!btp)
			{ 
				cl("11" + self.name + " wall!"); 
				wpt = self.wptArr[nr];
				self.wptArr = [];
				self.moveToPos = undefined;
				self botMoveTo(self getEye());	 
				//self _bot_self_nav(wpt);
				//self _bot_calc_path(_construct_node(self getEye()), wpt);
				wait 5;
				//self _grid_create(self.wptArr[nr], self getEye()); 
				break;
			}
			
			self.moveToPos = self.wptArr[nr].pos;
			if(!isDefined(self.moveToPos)){ 
				cl("11undefined self.moveToPos");
				continue; 
			} 
			
			self botMoveTo(self.moveToPos);
			
			if(self.wptArr.size - 1 > 0 && isDefined(self.wptArr[self.wptArr.size-1]))
			{ 
				self thread _bot_look_at(self.wptArr[self.wptArr.size-1].pos); //pos,aimspeed,c1,c2
			} 
			else
			{
				self thread _bot_look_at(self.wptArr[0].pos);
			}
				
			c=0;
			dist1 = distance(self getEye(), self.wptArr[nr].pos);
				
			while(isAlive(self) && isDefined(self.moveToPos))
			{ 
				dist1 = distance(self getEye(), self.wptArr[nr].pos);  
				dist2 = distance(self getEye(), self.wptArr[self.wptArr.size-1].pos);  
								
				if(self.wptArr.size == 1 && isDefined(dist1) && dist1 < 24)
				{
					cl("22"+self.name+" destination reached!");
					
					self.wptPassed[self.wptPassed.size] = self.wptArr[nr];
					self.wptArr = scripts\main::_arr_remove(self.wptArr,self.wptArr[nr]);
					self.moveToPos = undefined;
					self.gridArr = [];
					
					if(isDefined(self.nodeStance) && self.nodeStance != "any" )
					{ 
						self botAction( "+go"+ self.nodeStance); 
					}
					else 
					{ 
						self botAction( "+gocrouch"); 
					}
					
					nr = undefined;
				}
				else if(isDefined(dist1) && dist1 < 16)
				{ 
					cl("22"+self.name+" node reached!");
					self.moveToPos = undefined;
					self.wptPassed[self.wptPassed.size] = self.wptArr[nr];
				}
				else if(isDefined(dist2) && dist2<256)
				{ 
					self botAction( "+gocrouch"); 
				}
				else{ 
					self botAction("-gocrouch");
					self botAction("-goprone"); 
				}
				 
				dist2 = distance(prevPos, self getEye()); 
				
				if(isDefined(dist2) && dist2<5) 
				{ 
					c++; 
				}
				else
				{ 
					c=0; 
				}
				
				if(c >= 100)
				{ 
					cl(self.name + " destination approach timed out"); 
		
					self.wptArr = [];
					self.gridArr = [];
					//self.wptPassed = [];
					self botMoveTo(self getEye());
					self.moveToPos = undefined;
					break;
				}
				
				prevPos = self getEye();
				
				wait 0.05;
			}
			
			for(i=0;i<self.wptArr.size;i++)
			{
				if(isDefined(self.wptArr[i]))
				{
					self.wptArr = scripts\main::_arr_remove(self.wptArr,self.wptArr[i]);
					break;
				}
			}
		
			wait 0.05;
		}
		
		wait 0.05;
	}
}

_bot_push_node(node) //adding node to bot wptArr
{ 
	if(!self.isbot){ return; }
	if(!isDefined(node)){ return; }
	
	node.pos = _calc_indents(node.pos);
	
	self.wptArr[self.wptArr.size] = node;
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

_construct_node(pos)
{
	type = self getStance();
	angles = self getPlayerAngles();
	
	node = spawnstruct();
	node.id = level.nodes_quantity+1;
	node.pos = pos;
	node.type = type;
	node.angles = angles;
	node.names = [];
	node.name = undefined;
	node.marked = false;
	node.cover = "any";

	self iprintln("^3Node constructed: nr "+node.size+", pos "+pos+",stance:"+type+",angles:"+angles);
	
	return node;
}

_add_node(node)
{
	//level.nodes_quantity++;
	level.nodes[level.nodes.size] = node;
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
		//if (self.pers["team"] != "spectator") 
		//{
			delete=false; change=false; 
			myAngles = self GetPlayerAngles();
			startPos = self getEye();
			startPosForward = startPos + anglesToForward( ( myAngles[0], myAngles[1], 0 ) ) * 1200;
			trace = bulletTrace( startPos, startPosForward, true, self );
			//pos = trace["position"];
			pos = trace["position"];
			bot = trace["entity"];
			self PingPlayer();
			
			if(isDefined(bot) && bot.classname == "player" && c<=0 && use == true)
			{
				//self thread _add_remove_squad(bot);
			//} else if(isDefined(self.squad) && self.squad.size<1){
			} 
			else 
			{
				objs = level.nodes;	
				self.closest = undefined;
				closest = 2147483647;
				nr=undefined;
				if (objs.size>0)
				{
					for( i = 0 ; i < objs.size ; i++ )
					{
						if(isDefined(objs[i]))
						{
							dist = distance( pos, objs[i].pos ); 
							vd = self _dp(self getEye(), objs[i].pos, self.angles);

							//if(dist < 128 && vd > 0.98 && objs[i].marked)
							if(objs[i].marked)
							{ 
								nr=i; 
								closest=dist; 
							}
						}
					}
					
					if (isDefined(nr))
					{
						if(hbr == true)
						{					
							cl("hbr pos: " + objs[nr].pos);
							players = getentarray("player", "classname");
							
							for(i1=0;i1<players.size;i1++)
							{
								bot = players[i1];
								from = bot _construct_node(bot getEye());
								to = bot _construct_node(objs[nr].pos);
								
								nodes = bot _bot_calc_path(from, to);
								
								if(isDefined(nodes))
								{
									cl("nodes.size: " + nodes.size);
									
									for(i2 = 0; i2 < nodes.size; i2++)
									{
										bot _bot_push_node(nodes[i2]);
										//cl("nodes[i2].pos: " + nodes[i2].pos);
										//wait 1;
									}
								}
								
								//players[j] _bot_push_node(objs[nr]);
								//players[j] _bot_calc_path(self getEye(), objs[nr].pos);
							}
						}
						else if(isDefined(objs[nr].cover)) 
						{ 
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
					node = self _construct_node((eye[0],eye[1],eye[2])); 
					self _add_node(node);
					//self _add_node((self.origin[0],self.origin[1],self.origin[2])); 
					//self _add_node((pos[0],pos[1],pos[2]-20)); 
					delete = false; change = false; 
					self iprintln("^3Node added");
				}
				wait 0.2;	
			}	
		//}
		
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
	
	if(isDefined(pos))
	{
		self.moveToPos = pos;
	}
	
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
				if(dist<64){ 
					cl("33"+self.name+" reached node at"+node.pos);
					if(isDefined(self.nodeStance) && self.nodeStance != "any" ){ self botAction( "+go"+ self.nodeStance); }
					//else { self botAction( "+gocrouch"); }
					//self maps\mp\bots\_bot_script::CampAtSpot(self.moveToPos, self.moveToPos + AnglesToForward(self.nodeAngles) * 2048);
					//self setPlayerAngles(self.nodeAngles);
					//cl(self.name+":"+self.nodeAngles);
					//self.bot.stop_move=true;
					node.pos = undefined;
					self.moveToPos = undefined;
					wait 5;
					//self.bot.stop_move=false;
				}
				else if(dist<=150 && dist>100){ 
					self botAction( "+gocrouch" );
					//cl("^3"+name+" dist to "+nr+" is "+dist);
				}
				else if(dist>=64){ 
					//self maps\mp\bots\_bot_utility::ClearScriptGoal();
					//self maps\mp\bots\_bot_utility::SetScriptGoal(self.moveToPos,48);
					//self maps\mp\bots\_bot_script::CampAtSpot(self.moveToPos, self.moveToPos + AnglesToForward(self.nodeAngles) * 2048);
				}
			}
		}
	}
}

_dp(from, to, angles)
{
	dirToTarget = VectorNormalize(to - from);
	forward = AnglesToForward(angles);
	vectorDot = vectordot(dirToTarget, forward);
	//cl(self.name + ":" + vectorDot);
	
	return vectorDot;
}

_ping_marked_node(node, times, freq)
{
	if(!isDefined(node)){ return; }
	if(!isDefined(times)){ times = 5; }
	if(!isDefined(freq)){ freq = 1; }
	
	
	
	for(i = 0; i < times; i++)
	{
		level.nodes[node.id].marked = true;
		wait freq * 0.5;
		level.nodes[node.id].marked = false;
		wait freq * 0.5;
	}
}

_marked_nodes(){
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	if (getDvar("v01d_dev") != "nav"){ return; }
	if (self.isbot) { return; }
	
	//cl("^3_marked_nodes started on "+self.name);

	for(;;)
	{
		a = self GetPlayerAngles();
		startPos = self getEye();
		startPosForward = startPos + anglesToForward( ( a[0], a[1], 0 ) ) * 1200;
		pos = bulletTrace( startPos, startPosForward, true, self );
		pos = pos["position"];
				
		objs = level.nodes;	
		closest = 2147483647;
		nr=undefined;
		self.nodecatch = undefined;
		
		if (objs.size>0)
		{
			for( i = 0 ; i < objs.size ; i++ )
			{
				if(isDefined(objs[i]))
				{
					vd = self _dp(self getEye(), objs[i].pos, a);
					dist = distance( self getEye(), objs[i].pos ); 
					objs[i].marked = false;
					
					if(dist < 999 && vd > 0.98)
					{ 
						nr = i; 
						closest = dist;
						objs[i].marked = true;
						//cl(self.name + ":" + vd);
						break;
					}
				}
			}
			
			if (isDefined(nr))
			{
				objs[nr].marked = true;
				self.nodecatch = objs[nr];
				
				if(isDefined(self.squad))
				{
					for(i=0;i<self.squad.size;i++)
					{
						self.squad[i].aproachNode = objs[i].pos;
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
	dist = 0; size=0; threshold=12;
	hud_q=0;
	drawDistance = 999;
	
	for(;;)
	{
		objs = level.nodes;	
		
		if (isDefined(objs))
		{
			closest = 2147483647;
			
			for( i = 0 ; i < objs.size ; i++ )
			{
				if(isDefined(objs[i]))
				{
					dist = distance( self.origin, objs[i].pos );
					if(dist < drawDistance){
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
	hud_q = 0;
	grid = undefined;
	
	for(;;){
		players = getentarray("player", "classname");
		for(i=0;i<players.size;i++)
		{
			if(players[i].isbot)
			{
				bot = players[i];
				grid = bot.gridArr;
			}
		}
		
		objs = grid;	
		//objs = self.gridArr;	
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
						self.hudgrid[hud_q].x = objs[i].pos[0]; self.hudgrid[hud_q].y = objs[i].pos[1]; self.hudgrid[hud_q].z = objs[i].pos[2];
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

_clear_nodes()
{
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );	
	if (getDvar("v01d_dev") != "nav"){ return; }
	if (self.isbot) { return; }
	
	while (1)
	{
		c = 10;
		while (!self HoldBreathButtonPressed())
		{ 
			wait 0.05;
		}
		
		wait 0.05;

		while ( self HoldBreathButtonPressed() && c > 0)
		{ 
			c--; 
			wait 0.05;
		}
		
		if (c <= 0){ 
			level.nodes = [];
			cl("level.nodes cleared!");
			wait 0.2;
		}
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
		c=20;
		while ( !self meleeButtonPressed() ){ wait 0.05; }
		wait 0.05;

		while ( self meleeButtonPressed() && c>0){ 
			c--; 
			cl("c: " + c);
			wait 0.05;
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
