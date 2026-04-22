#include maps\mp\_load;
#include maps\mp\_utility;
#include scripts\cl;
#include scripts\pl;
#include scripts\bots_utilities;

init()
{
	if (getDvar("v01d_bots") != "1"){ return; }

	precacheShader("compass_waypoint_defend");
	precacheShader("compass_waypoint_target");
	precacheShader("compass_waypoint_bomb");
	precacheShader("compassping_enemy"); 
	precacheShader("compassping_enemyfiring"); 
	precacheShader("compassping_player"); 
	precacheShader("map_artillery_selector"); 
	
	level.dm1 = "projectile_at4";
	level.dm2 = "projectile_m203grenade";
	level.dm3 = "projectile_rpg7";
	
	precacheModel(level.dm1);
	precacheModel(level.dm2);
	precacheModel(level.dm3);

	//if (!getdvarint("v01d_dev")>0){ return; }
	if (getdvarint("bots_main_debug")>0) { return; }

	level.icon = "map_artillery_selector";
	
	//if (level.waypointCount != 0) { return; }
	
	level.nodes = [];
	//level.nodes_quantity = 0;
	level.node_types = StrTok("any,sniper,rpg,gl,mg",",");
	
	//level.grid = [];
	//level.grid_quantity = 0;
	
	level.objectivePos = undefined;
	
	if(isDefined(level.sabBomb))
	{
		level.objectivePos = level.sabBomb.curOrigin;
		cl("this level has a bomb!");
	}
	
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
		
	level thread _player_connected();

	//if(!isDefined(getDvar( "bots_nav_enable"))){ setDvar( "bots_nav_enable", ""); }
	//setDvar( "bots_play_move", false );
	
	level _load_nodes();
	
	if(_check_if_no_nodes())
	{ 
		return true; 
	}

	level thread _bomb_pos();
}

_player_connected()
{
	level endon ( "disconnect" );
	level endon( "intermission" );
	level endon( "game_ended" );
	
	for(;;)
	{
		level waittill("connected", player);
		
		player thread _player_spawn_loop();
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
		player thread _dev_pause();
	}
}

_player_spawn_loop()
{
	self endon ( "disconnect" );
	self endon( "intermission" );
	//self endon( "death" );
	level endon( "game_ended" );
	
	if (getDvar("v01d_bots") != "1"){ return; }
		
	for(;;)
	{
		self waittill("spawned_player");
		
		if(self.isbot)
		{			
			self thread _bot_init_nav();
			//self thread _grid();
			self thread _bot_nodes_acm();
			//self thread _bot_self_nav();	
			//self thread _open_map();		
			self thread _bot_go_to_objective();
			self thread _bot_check_position();
			//self thread _bot_look_at_bombpos();
			//self thread _bot_move_to_nearest_wpt();
			self thread _bot_strafe();
			self thread _bot_lean();
			//self thread _bot_push();
			self thread _bot_jump_on_obstacle();
			self thread _bot_crouch_below_obstacle();
		}
		else
		{
			//self thread _dev_jump_on_obstacle();
			//self thread _dev_nodes_plant();
			//self thread _dev_player_jump_data(); 
		}
		
		//self _dev_player_spawn_near_bomb();
	}
}

_construct_node(pos, player)
{
	if(!isDefined(pos)){ return; }
		
	node = spawnstruct();
	node.id = level.nodes.size + 1;
	//node.id = level.nodes_quantity + 1;
	node.pos = pos;
	node.type = "stand";
	node.angles = (0,0,0);
	//node.names = [];
	//node.name = undefined;
	node.marked = false;
	node.cover = "any";
	
	if(isDefined(player))
	{ 
		node.type = player getStance();
		node.angles = player.angles;
		
		self iprintln("^3Node constructed: nr " + node.size + ", pos " + pos + ", stance: " + node.type + ", angles: " + node.angles);
	}

	return node;
}

_bot_push()
{
	self endon ( "disconnect" );
	self endon( "intermission" );
	//self endon( "death" );
	level endon( "game_ended" );
	
	for(;;)
	{
		a = self.angles;
		aff = self getEye() + anglesToForward((a[0], a[1], a[2])) * 24;
		btf = bulletTrace(self getEye(), aff, true, self);
		//posf = btf["position"];
		ent = btf["entity"];
		
		if(isDefined(ent) && ent.classname == "player" && isAlive(ent))
		{
			self scripts\main::_push();
		}
		
		wait 0.1;
	}
}

_bomb_pos()
{
	level endon ( "disconnect" );
	level endon( "intermission" );
	level endon( "game_ended" );
	
	level.bombCarrier = undefined;

	while(1)
	{
		level waittill("bomb_is_picked_up");
		/*
		players = getentarray("player", "classname");
		for(i=0;i<players.size;i++)
		{
			if(isDefined(players[i].isBombCarrier) && players[i].isBombCarrier == true)
			{
				level.bombCarrier = players[i]; 
				break;
			}
		}
		*/
		if(isDefined(level.bombCarrier))
		{ 
			//cl("level.bombCarrier: "+level.bombCarrier.name);
			team = level.bombCarrier.pers["team"];
			if(team == "axis"){ team = "allies"; }
			else if(team == "allies"){ team = "axis"; }
			bombSite = getEnt("sab_bomb_"+team+"", "targetname");
			level.objectivePos = bombSite.origin;
			//level.objectivePos = level.sabBomb.curOrigin; 
		} 
		else
		{ 
			level.objectivePos = level.sabBomb.curOrigin; 
			//cl("level.objectivePos: "+level.objectivePos);
		}
		
		level waittill("bomb_is_dropped");
		
		//wait 0.5;
	}
}

_bot_init_nav()
{
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "death" );
	level endon( "game_ended" );

	/*if(!self.isbot)
	{
		if(self.pers["team"] == "axis"){ 
			level maps\mp\bots\_bot::add_bot("axis"); 
		}
		else
		{ 
			level maps\mp\bots\_bot::add_bot("allies"); 
		}
	}*/

	if (!self.isbot){ return; }
	
	//self.approachNode = undefined;
	//cl("_bot_start_nav started on "+self.name);
	
	self.wptArr = [];
	self.wptPassed = [];
	self.gridArr = [];
	self.calculating = "idle";
	self.isLookingAt = undefined;
	self.isGoingToPoint = undefined;
	self.moveToPos = undefined;
	self.isFindingAnotherWay = undefined;
	self.isCamping = undefined;
	
	self botStop();
	self botMoveTo(self GetEye());
	
	//self thread _add_wpt_for_bomb();
	//self thread _nav_loop();
	//self thread _bot_following_player();
	
	//self setClientDvars("cg_thirdperson", 1);	
	
}

_bot_look_at(pos,aimspeed,c1,c2)
{
	self endon ( "disconnect" );
	self endon( "intermission" );
	//self endon( "death" );
	level endon( "game_ended" );
	
	if(!self.isbot){ return; }
	if(!isDefined(pos)){ return; }
	
	if(!isDefined(aimspeed)){ aimspeed=1; }
	if(!isDefined(c1)){ c1=0.5; }
	if(!isDefined(c2)){ c2=0.5; }
	
	if(isDefined(self.isLookingAt))
	{ 
		//cl("11"+self.name+" already looking at!"); 
		return; 
	}
	
	self.isLookingAt = true;
	
	c=0;
	_aimspeed = aimspeed;

	while(isAlive(self) && aimspeed>0.1)
	{ 
		self botLookAt(pos, aimspeed);
		aimspeed *= c1;
		wait 0.05;
	}
	
	aimspeed = 0.1;
	
	while(isAlive(self) && aimspeed<_aimspeed)
	{ 
		self botLookAt(pos, aimspeed);
		aimspeed *= (1+c2);
		wait 0.05;
	}
	
	self.isLookingAt = undefined;
}

_bot_look_at_bombpos()
{
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "death" );
	level endon( "game_ended" );
	
	if (!self.isbot){ return; }
	
	while(isAlive(self))
	{
		wait randomFloatRange(5,15);
		
		if
		(
			!isDefined(self.hasEnemyTarget) 
			&& !isDefined(self.isSelfNavigating)
		)
		{ 
			self thread _bot_look_at(level.objectivePos); 
		}
	}
}

_dev_pause()
{
	self endon ( "disconnect" );
	
	if(self.isbot){ return; }
	
	while(1)
	{
		while (!self HoldBreathButtonPressed()){ wait 0.05; }
		
		level notify("next");
		cl("next");
		
		while (self HoldBreathButtonPressed()){ wait 0.05; }
	}
}

_bot_camping(pos, dur)
{
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "death" );
	level endon( "game_ended" );
	
	if (!self.isbot){ return; }
	if (!isDefined(pos)){ return; }
	if (!isDefined(dur)){ dur = 60; }
	if (isDefined(self.isCamping)){ return; }
			
	cl("_bot_camping() started on " + self.name);
		
	self.isCamping = true;
	self.isGoingToPoint = pos;
	
	for(i = 0; i < dur; i++)
	{
		dist = distance(self getEye(), pos);
		
		if(dist < 64)
		{ 
			self botAction("+goprone"); 
		}

		wait 1;
	}
	
	self.isCamping = undefined;
	self.isGoingToPoint = level.objectivePos;
	
	cl("_bot_camping() ended on " + self.name);
}

_dev_player_jump_data()
{
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "death" );
	level endon( "game_ended" );
	
	if (self.isbot){ return; }

	wait 1;
	cl("_dev_nodes");
	
	t = 0;
	_ground = 0;
	
	for(;;)
	{
		ground = self.origin - _calc_ground(self.origin, 0);
		eye = self getEye() - _calc_ground(self getEye(), 0);
		
		if(_ground != ground[2])
		{
			if(t < ground[2])
			{ 
				t = ground[2]; 
			}

			cl("origin: " + ground[2]); //~0.12
			cl("eye: " + eye[2]); //~40.12
			cl("highest jump: " + t); //~38.38	
			
			_ground = ground[2];
		}
		
		wait 0.05;
	}
}

_dev_spawn_model(pos, model, angles, targetname)
{
	if(!isDefined(pos)){ return; }
	if(!isDefined(model)){ return; }
	if(!isDefined(angles)){ angles = (0,0,0); }
		
	ent = spawn("script_model", pos);
	ent.targetname = targetname;
	ent.angles = angles;
	ent setModel(model);	
	
	return ent;
}

_dev_jump_on_obstacle()
{
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "death" );
	level endon( "game_ended" );
			
	//head = _dev_spawn_model(self GetTagOrigin("j_head"), level.dm1, self.angles);
	//eye = _dev_spawn_model(self getEye(), level.dm2);
	//origin = _dev_spawn_model(self.origin, level.dm3);
	
	for(;;)
	{
		a = self GetPlayerAngles();
		sp = self getEye();
		sp = (sp[0], sp[1], sp[2] - 30);
		aff = sp + anglesToForward((0, a[1], 0))*30;
		affd = aff + anglesToForward((90, 0, 0))*30;
		
		//affm = _dev_spawn_model(aff, level.dm1, a);
		//affdm = _dev_spawn_model(affd, level.dm2, a);
		
		btf = bulletTrace(sp, aff, true, self);
		btfd = bulletTrace(sp, affd, true, self);
		
		posf = btf["position"];
		posfd = btfd["position"];
		
		posfm = _dev_spawn_model(posf, level.dm1, a);
		//posfdm = _dev_spawn_model(posfd, level.dm2, a);

		distf=distance(sp, posf);
		distfd = distance(posf, posfd);
		
		if(distf > 30 && distfd < 20 && distfd > 10)
		{ 
			cl(self.name + " is triggering jump");			
		}
		
		wait 0.05;
		
		posfm delete();
		//posfdm delete();
		//affm delete();
		//affdm delete();
	}
}

_bot_jump_on_obstacle()
{
	self endon("disconnect");
	self endon("intermission");
	self endon("death");
	level endon("game_ended");
	
	if (!self.isbot){ return; }
	
	wait 1;
	
	//head = _dev_spawn_model(self GetTagOrigin("j_head"), level.dm1, self.angles);
	//eye = _dev_spawn_model(self getEye(), level.dm2);
	//origin = _dev_spawn_model(self.origin, level.dm3);
	
	for(;;)
	{
		a = self GetPlayerAngles();
		sp = self getEye();
		sp = (sp[0], sp[1], sp[2] - 20);
		aff = sp + anglesToForward((0, a[1], 0))*30;
		affd = aff + anglesToForward((90, 0, 0))*30;
		
		//affm = _dev_spawn_model(aff, level.dm1, a);
		//affdm = _dev_spawn_model(affd, level.dm2, a);
		
		btf = bulletTrace(sp, aff, false, self);
		btfd = bulletTrace(sp, affd, false, self);
		
		posf = btf["position"];
		posfd = btfd["position"];
		
		//posfm = _dev_spawn_model(posf, level.dm1, a);
		//posfdm = _dev_spawn_model(posfd, level.dm2, a);

		distf = distance(sp, posf);
		distfd = distance(posf, posfd);
		
		//if(distf < 30 && distfd > 10 && distfd < 30)
		if(distf < 20)
		{ 
			self.isJumping = true;
			self botAction( "-gocrouch" );
			self botAction( "+gostand" );
			//cl(self.name + " is jumping over obstacle");			
			//wait 0.05;
			//self botAction( "-gostand" );
		}
		else
		{
			self.isJumping = undefined;
		}
		
		wait 0.5;
		
		//posfm delete();
		//posfdm delete();
		//affm delete();
		//affdm delete();
	}
}

_bot_crouch_below_obstacle()
{
	self endon("disconnect");
	self endon("intermission");
	self endon("death");
	level endon("game_ended");
	
	if (!self.isbot){ return; }
	
	wait 1;
	
	//head = _dev_spawn_model(self GetTagOrigin("j_head"), level.dm1, self.angles);
	//eye = _dev_spawn_model(self getEye(), level.dm2);
	//origin = _dev_spawn_model(self.origin, level.dm3);
	
	for(;;)
	{
		a = self GetPlayerAngles();
		sp = self getEye();
		sp = (sp[0], sp[1], sp[2] + 20);
		aff = sp + anglesToForward((0, a[1], 0))*40;
		
		//affm = _dev_spawn_model(aff, level.dm1, a);
		
		btf = bulletTrace(sp, aff, true, self);
		posf = btf["position"];
		
		//posfm = _dev_spawn_model(posf, level.dm1, a);

		distf = distance(sp, posf);
		
		if(!isDefined(self.isJumping) && distf < 30)
		//if(distf < 30)
		{ 
			self botAction( "+gocrouch" );
			//cl(self.name + " is crouching below obstacle");			
			//wait 0.05;
			//self botAction( "-gostand" );
		}
		else
		{
			self.isJumping = undefined;
		}
		
		wait 1;
		
		//posfm delete();
		//affm delete();
	}
}

_bot_check_position()
{
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "death" );
	level endon( "game_ended" );
	
	if (!self.isbot){ return; }
	
	self.isStuck = undefined;
	
	prevPos = self getEye();
	minDist = 40;
	_c = 10;
	c = _c;
	
	wait 5;
	
	while(isAlive(self))
	{		
		if
		(
			distance(self getEye(), prevPos) < minDist 
			&& !isDefined(self.isCamping)
		)
		{
			c--;
			
			if(c < 1)
			{
				self.isStuck = true;
				self.moveToPos = undefined;
				cl(self.name + " got stuck!");
				
				while(distance(self getEye(), prevPos) < minDist)
				{ 
					wait 3; 
				}
				
				cl(self.name + " is Ok!");
			}
			else
			{
				self.isStuck = undefined;
			}
		}
		else
		{
			c = _c;
		}
		
		prevPos = self getEye();
		
		wait 1;
	}
}

_bot_go_to_objective()
{
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "death" );
	level endon( "game_ended" );
	
	if (!self.isbot){ return; }
	
	wait randomFloatRange(2, 5);
		
	//cl("_bot_go_to_objective started on " + self.name);
	
	to = _construct_node(self getEye(), self);
	nodes = undefined;
	
	self.isGoingToPoint = level.objectivePos;
	
	if(isDefined(self.leader))
	{ 
		self.isGoingToPoint = self.leader getEye(); 
	}
	else if(isDefined(self.getInPos))
	{ 
		self.isGoingToPoint = self.getInPos; 
	}
	
	while(isAlive(self))
	{
		node = undefined;
		//while(isDefined(self.hasEnemyTarget)){ wait 1; }
		while(isDefined(self.moveToPos)){ wait 0.5; }
		//while(isDefined(self.gettingItem)){ wait 0.5; }
		
		//from = self _construct_node(self getEye());
		h = _get_head_pos(self);
		from = self _construct_node(self getEye(), self);
		
		if(isDefined(self.isStuck))
		{
			cl(self.name + " is stuck!");
			
			to = _construct_node(level.objectivePos, self);
			
			self.isStuck = undefined;
			//self.hasEnemyTarget = undefined;
			self.wptArr = [];
			self.wptPassed = [];
			//self.moveToPos = undefined;
			//self _bot_scanning_area();
						
			from = self _construct_node(self getEye(), self);
			to = _construct_node(level.objectivePos, self);
			found = false;
			
			/*for(s = 1; s > -1; s -= 0.1)
			{
				node = self _get_visible_node(from, to, 0, 64, s, 40, false);
				//from, to, indent, minDist, sector, distzMax, ignoreVis, ignoreNodes
				
				cl(self.name + " s: " + s);
								
				if(isDefined(node))
				{
					//cl("break");
					found = true;
					break;
				}
				
				wait 0.05;
			}*/
						
			if(!found)
			{
				node = self _get_visible_node(from, to, 0, 160, -0.25, 40, true);
				
				if(isDefined(node))
				{
					//self _bot_push_node(to);
					cl(self.name + " using grid...");
					success = self _grid_create(node, from);
					//self _bot_self_nav(to);
				
					if(!success)
					{
						from = self _construct_node(self getEye(), self);

						node = self _get_visible_node(from, to, 0, 80, -1, 40, false);
						//from, to, indent, minDist, sector, distzMax, ignoreVis, ignoreNodes
						if(isDefined(node))
						{
							//self _grid_create(to, from);
							self _bot_self_nav(node);
							cl(self.name + " self_nav()");
						}
					}
				}
			}
		}
		
		if(isDefined(self.leader))
		{
			self.wptArr = [];
			self.gridArr = [];
			self.moveToPos = undefined;
			self botMoveTo(self.origin);
			self thread _bot_look_at(self.leader getEye());
			
			while(isDefined(self.leader))
			{
				if(distance(self.origin, self.leader.origin) > 128)
				{
					self botMoveTo(self.leader.origin);
					//cl(self.name + " is following leader " + self.leader.name);
				}
				
				wait 1;
			}
		}

		if(isDefined(level.bombCarrier))
		{
			if(level.bombCarrier.pers["team"] == "axis")
			{
				//cl("level.bombZones[allies]: " + level.bombZones["allies"].curOrigin);
				level.objectivePos = level.bombZones["allies"].curOrigin;
				
				if(self.pers["team"] == "allies")
				{
					self.isGoingToPoint = level.bombCarrier getEye();
				}
			}
			else if(level.bombCarrier.pers["team"] == "allies")
			{
				//cl("level.bombZones[axis]: " + level.bombZones["axis"].curOrigin);
				level.objectivePos = level.bombZones["axis"].curOrigin;
				
				if(self.pers["team"] == "axis")
				{
					self.isGoingToPoint = level.bombCarrier getEye();
				}
			}
		}
		else if(!level.bombPlanted)
		{
			bombPos = level.objectivePos;
			btpBomb = BulletTracePassed(self getEye(), bombPos, false, self);
			distObj = distance(bombPos, self getEye());
			
			if(btpBomb && distObj < 333 && bombPos[2] - self getEye()[2] < 20)
			{
				node = _construct_node(bombPos, self);
				self _bot_push_node(node);
				self botMoveTo(bombPos);	 
				
				while(btpBomb && !isDefined(level.bombCarrier))
				{
					cl(self.name + " is going to pickup the bomb...");
					wait 1;
				}
				
				if(isDefined(level.bombCarrier))
				{
					cl(self.name + " just picked up the bomb!");
					self.moveToPos = undefined;
				}
				else
				{
					cl(self.name + " just missed the bomb!");
				}
			}
		}
		
		if(randomFloatRange(0, 10) > 3)
		{
			pos = undefined;
			
			if(isDefined(_get_nearest_node_by_class(self _bot_get_weapon_class())))
			{
				pos = _get_nearest_node_by_class(self _bot_get_weapon_class());
			}
			
			if(isDefined(pos))
			{
				self thread _bot_camping(pos, randomFloatRange(30, 90));
			}
		}
		
		to = _construct_node(self.isGoingToPoint, self);
		
		if(!isDefined(node))
		{
			node = self _get_visible_node(from, to, 0, 160, 0.25, 40, false);
			//from, to, indent, minDist, sector, distzMax, ignoreVis, ignoreNodes
		}
		
		if
		(
			randomFloatRange(0, 10) > 8 
			&& isDefined(self.hasEnemyTarget)
			&& isPlayer(self.hasEnemyTarget)
			&& !isDefined(self.isCamping)
		)
		{
			self.isGoingToPoint = self.hasEnemyTarget getEye();
			cl(self.name + " self.isGoingToPoint enemy: " + self.hasEnemyTarget.name);
		}
		
		//to = self _construct_node(level.objectivePos, self);
			
		if(isDefined(node))
		{
			success = self _grid_create(node, from);
			//self _bot_push_node(node);
			//cl(self.name + " going to node...");
		}
		else
		{
			//self _grid_create(to, from);
			//cl(self.name + " using grid...");
		}
		
		if(isDefined(level.bombCarrier) && self == level.bombCarrier && distance(self getEye(), level.objectivePos) < 555)
		{
			p = level.objectivePos;
			btpZone = BulletTracePassed(level.bombCarrier getEye(), (p[0],p[1],p[2]+40), false, self);
			
			if(btpZone)
			{
				self.wptArr = [];
				self.gridArr = [];
				self.moveToPos = undefined;
				self botMoveTo(p);	 
				//cl(self.name + " saw btpZone");
				
			}
			
			while(isDefined(level.bombCarrier) && distance(level.bombCarrier getEye(), level.objectivePos) < 80)
			{
				//cl("waiting to plant bomb...");
				wait 0.5;
			}
			
			players = getentarray( "player", "classname" );
			for(i=0;i<players.size;i++)
			{
				if(isDefined(level.bombCarrier) && self == level.bombCarrier)
				{ 
					continue; 
				}
				
				if(players[i].isbot && players[i] != self &&  isDefined(level.bombCarrier) && distance(players[i] getEye(), level.bombCarrier getEye()) < 120)
				{
					node = players[i] _get_visible_node(from, undefined, -256, 128, -0.5, 30, false, players[i].wptArr);
					
					if(isDefined(node))
					{
						//players[i].isGoingToPoint = nearestNode.pos;
						cl(players[i].name + " is leaving bombsite!");
					}
				}
			}
			
			//wait 5;
		}
		
		while(isDefined(level.bombPlantedBy) && level.bombPlantedBy == self.pers["team"])
		{
			cl(self.name + " is evacuating!");
			from = self _construct_node(self getEye(), self);
			node = self _get_visible_node(from, undefined, 1, 128, -0.75, 30, false, self.wptArr);

			self _bot_push_node(node);
			//thread _ping_marked_node(nearestNode);
			
			wait 5;
		}
		
		//level waittill("next");
		
		wait 1;
	}
}

_bot_calc_path(from, to, indent, minDist, sector, distzMax, ignoreVis, ignoreNodes)
{
	self endon("disconnect");
	self endon("intermission");
	self endon("death");
	level endon("game_ended");
	
	if (!self.isbot){ return; }
		
	cl(self.name+" calculating path to " + to.pos);
	
	wptArr = [];
	self.gridArr = [];
	stop = undefined;
	lastPos = from.pos;
	
	while(!isDefined(stop))
	{
		node = self _get_visible_node(from, to, indent, minDist, sector, distzMax, ignoreVis, wptArr);

		if(isDefined(node))
		{
			cl("node.pos: " + node.pos);
			wptArr[wptArr.size] = node;
			thread _ping_marked_node(node);
			
			//_objective_toggle(8,1,from.pos,"map_artillery_selector");
			self.gridArr[self.gridArr.size] = node;
						
			btpo = BulletTracePassed(node.pos, level.objectivePos, false, self);

			if(btpo)
			{ 
				wptArr[wptArr.size] = _construct_node(level.objectivePos, self);
				stop = true;
				cl(self.name + " btpo");
				break;				
			}
			
			wait 0.1;
				
			if(lastPos == node.pos)
			{
				stop = true;
				cl("stop from node.pos");
				break;
			}
			
			if(lastPos == to.pos)
			{
				stop = true;
				cl("stop from to.pos");
				break;
			}
			
			lastPos = node.pos;
			from.pos = lastPos;
		}
		else
		{
			stop = true;
			cl("stop from undefined node");
		}
		
		//level waittill("next");
	}
	
	cl(self.name + " calc path ended");
	
	return wptArr;
}

_bot_scanning_area()
{
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "death" );
	level endon( "game_ended" );
	
	if (!self.isbot){ return; }
		
	//while(isDefined(self.hasEnemyTarget)){ wait 1; }

	cl(self.name + " _bot_scanning_area()");
	
	wait 1;
	
	from = self _construct_node(self getEye(), self);
	to = self _construct_node(level.objectivePos, self);
	nearestNode = self _get_visible_node(from, to, -256, 32, -1, 999, true);
	//from, to, indent, minDist, sector, distzMax, ignoreVis, ignoreNodes

	wait 1;
	
	if(isDefined(nearestNode))
	{
		cl(self.name + " got node!");
		self thread _bot_look_at(nearestNode.pos);
		//thread _ping_marked_node(nearestNode);
	}
	else
	{
		self thread _bot_look_at(level.objectivePos);
	}
			
	cl(self.name + " scanned nodes");
}

_get_visible_node(from, to, indent, minDist, sector, distzMax, ignoreVis, ignoreNodes)
{
	if(!isDefined(level.nodes)){ return; }
	if(!isDefined(indent)){ indent = 0; }
	if(!isDefined(minDist)){ minDist = 32; }
	if(!isDefined(sector)){ sector = 0; }
	if(!isDefined(distzMax)){ distzMax = 999; }
	if(!isDefined(ignoreVis)){ ignoreVis = false; }
		
	eye = self getEye();
	nr = undefined;

	closestFrom = 99999;
	closestTo = 99999;
		
	//cl("self eye/origin dist: " + distance(self getEye(), self.origin)); 
	//40 units
					
	for( i2 = 0 ; i2 < level.nodes.size; i2++ )
	{
		distTo = undefined;
		distFromTo = undefined;
		distFrom = distance(level.nodes[i2].pos, self getEye());
		
		if(!isDefined(to)){ continue; }
		if(!isDefined(to.pos)){ continue; }
		
		distTo = distance(level.nodes[i2].pos, to.pos); 
		distFromTo = distance(from.pos, to.pos);
		
		btp = BulletTracePassed(from.pos, level.nodes[i2].pos, false, self);
		angles = VectorToAngles(level.nodes[i2].pos - from.pos);
		vd = scripts\main::_dp(from.pos, level.nodes[i2].pos, self.angles);
		ocp = self _check_occuppied(level.nodes[i2].pos);
		adj = self _check_adjacent(from.pos, level.nodes[i2].pos, distzMax);
		//cl("vd: " + vd);
		//cl("angles: " + angles);
		//thread _ping_marked_node(level.nodes[i2]);
		
		//wait 0.05;
		
		found = undefined;
		if(isDefined(ignoreNodes))
		{
			for(i3 = 0; i3 < ignoreNodes.size; i3++)
			{
				if(ignoreNodes[i3].id == level.nodes[i2].id)
				{ 
					found = true; 
					cl(self.name + " node passed: " + level.nodes[i2].id);
					break; 
				}
			}
		}
		
		if(isDefined(found)){ continue; }
			
		if(ignoreVis && isDefined(to))
		{
			//cl("ignoreVis");
			if(distFrom < closestFrom && distFromTo - distTo > indent && distFrom > minDist)
			{			
				nr = i2;
				closestFrom = distFrom;
			}
		}
		//else if(isDefined(to) && vd > sector && btp)
		else if(isDefined(to) && vd > sector && btp && adj)
		//else if(isDefined(to) && vd > sector && btp && adj && !ocp)
		{
			//cl("i2: " + i2);
			//thread _ping_marked_node(level.nodes[i2]);
			//if(btp && adj && distz < distzMax && distFrom > 12 && distFrom < closestFrom && distFromTo - distTo > indent)
			//if(distFrom < closestFrom && distFromTo - distTo > indent && distFrom > minDist)
			if(distFrom < closestFrom && distFrom > minDist)
			{			
				nr = i2;
				closestFrom = distFrom;
				//cl("i2: " + i2);
			}
		}
		else if(vd > sector && adj && !ocp)
		//else if(vd > sector && adj)
		{
			if(distFrom > minDist && distFrom < closestFrom)
			{			
				nr = i2;
				closestFrom = distFrom;
			}
		}
	}
	
	if(isDefined(nr))
	{
		//thread _ping_marked_node(level.nodes[nr]);
		return level.nodes[nr];
	}	
	
	return undefined;
}

_get_nearest_node_by_class(class)
{
	for( i = 0 ; i < level.nodes.size; i++ )
	{
		if(level.nodes[i].cover == class)
		{ 
			return level.nodes[i].pos;
		}
	}
	
	return undefined;
}

_calc_ground(pos, indent)
{
	if(!isDefined(indent)){ indent = 40; }

	btd = bulletTrace(pos, (pos[0], pos[1], pos[2] - 999), false, self);
	btd = btd["position"];
	btu = bulletTrace(btd, (btd[0], btd[1], btd[2] + indent), false, self);
	btu = btu["position"];
	//btd = bulletTrace(btu, (btd[0], btd[1], btd[2]), false, self);
	//btd = btd["position"];
			
	return btu;
}

_check_occuppied(pos, minDist)
{
	if(!isDefined(minDist)){ minDist = 64; }
	
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		dist = distance(players[i] getEye(), pos);
		
		if(dist < minDist){ return true; }
	}

	return false;
}

_check_adjacent(from, to, distzMax, minDist) //vector
{
	if(!isDefined(minDist)){ minDist = 32; }
	if(!isDefined(distzMax)){ distzMax = 30; }
	
	iterations = 64;
	
	btp = bulletTracePassed(from, to, false, self);
	eyeHeight = 40;
	
	if(!isDefined(self.gridArr)){ self.gridArr = []; }
	self.gridArr = [];
	
	if(btp)
	{
		//cl(self.name + " btp: "+btp);
		for(i = 0; i < iterations; i++)
		{	
			if(distance(from, to) < minDist)
			{
				//cl("returns true");
				//wait 0.05;
				//level waittill("next");
				//self.gridArr = [];
				return true;
			}
			
			a = VectorToAngles(to - from);
			aff = from + anglesToForward((a[0], a[1], a[2] + 20)) * minDist;
			btf = bulletTrace(from, aff, false, self);
			posf = btf["position"];
			posz = _calc_ground(posf, distzMax);
			zdiff = posf[2] - posz[2];
			//cl("zdiff: " + zdiff);
			
			//wait 0.05;
			
			if((posf[2] - from[2]) > distzMax)
			{
				//cl(self.name + " from.pos[2] > distzMax");
				//level waittill("next");
				//self.gridArr = [];
				return false;			
			}
			
			if(zdiff > distzMax )
			{
				//cl(self.name + " zdiff > distzMax: " + zdiff);
				//cl(self.name + " distzMax: " + distzMax);
				//level waittill("next");
				//self.gridArr = [];
				return false;
			}
			else if(zdiff > eyeHeight)
			{
				//cl("zdiff > eyeHeight: " + zdiff);
				//cl(self.name + " eyeHeight: " + eyeHeight);
				//level waittill("next");
				//self.gridArr = [];
				return false;
			}
						
			node = _construct_node(posz, self);
			
			self.gridArr[self.gridArr.size] = node;
			dist = distance(self getEye(), node.pos);
			//cl("dist: " + dist);
			//cl("node.pos: " + node.pos);
			//cl("self getEye(): " + self getEye());
			//cl("self.gridArr.size: " + self.gridArr.size);

			va = VectorToAngles(posz - from);
			frac = a[0] - va[0];	
			from = posz;
			
			//level waittill("next");
						
			//wait 0.05;
		}
	}
	
	return false;
}

_bot_strafe() //bot trying avoid obstacles by strafing
{
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "death" );
	level endon( "game_ended" );
	
	if(!self.isbot) { return; }
	
	stop = undefined;
	_c = 100; 
	c = _c;
		
	while(isAlive(self) && !isDefined(stop))
	{
		
		if(isDefined(self.moveToPos))
		{	
			c--;
			
			if(c < 1 && self.wptArr.size > 0)
			{
				a = self GetPlayerAngles();
				sp = self getEye();
				aff = sp + anglesToForward((a[0], a[1], a[2]+20))*36;
				afl = sp + anglesToForward((a[0], a[1]+45, a[2]+20))*36; //left
				afr = sp + anglesToForward((a[0], a[1]-45, a[2]+20))*36; //right
				
				btf = bulletTrace(sp, aff, true, self);
				btl = bulletTrace(sp, afl, true, self);
				btr = bulletTrace(sp, afr, true, self);
				
				posf = btf["position"];
				posl = btl["position"];
				posr = btr["position"];
		
				distf=distance(self getEye(),posf);
				distl=distance(self getEye(),posl);
				distr=distance(self getEye(),posr);
				dist = distance(sp, self getEye());
				
				if(distl < 32 && distr > 32)
				{ 
					//self thread _bot_look_at(posr);
					//cl("22" + self.name + " looking right");		
					//cl("22" + self.name + " moving right");			
					dist = distance(sp, self getEye());
					
					if(dist < 32)
					{ 
						self.wptArr[0].pos = posr; 
					}
					
					wait 2;
				}
				else if(distr < 32 && distl > 32)
				{ 
					//self thread _bot_look_at(posf);
					//cl("22" + self.name + " looking left");
					//cl("22" + self.name + " moving left");
					dist = distance(sp, self getEye());
					
					if(dist < 32)
					{ 
						self.wptArr[0].pos = posl; 
					}
					
					wait 2;
				}
			}
		}
		else
		{
			c = _c;
		}
		
		wait 0.1;
	}
}

_bot_lean() //bot trying avoid obstacles by strafing
{
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "death" );
	level endon( "game_ended" );
	
	if(!self.isbot) { return; }
	
	stop = undefined;
		
	while(isAlive(self) && !isDefined(stop))
	{
		
		a = self GetPlayerAngles();
		sp = self getEye();
		aff = sp + anglesToForward((0, a[1], 0))*128;
		afl = sp + anglesToForward((0, a[1]+45, 0))*128; //left
		afr = sp + anglesToForward((0, a[1]-45, 0))*128; //right
		afrr = sp + anglesToForward((0, a[1]+180, 0))*128; //back
		
		btf = bulletTrace(sp, aff, true, self);
		btl = bulletTrace(sp, afl, true, self);
		btr = bulletTrace(sp, afr, true, self);
		btrr = bulletTrace(sp, afrr, true, self);
		
		posf = btf["position"];
		posl = btl["position"];
		posr = btr["position"];
		posrr = btrr["position"];

		distf=distance(self getEye(),posf);
		distl=distance(self getEye(),posl);
		distr=distance(self getEye(),posr);
		
		if(distl < 48 && distr < 48)
		{ 
			//self _bot_look_at(posrr);
		 	//cl(self.name + " turning 180 degrees");
			wait 3;
		}
		else if(distl < 48 && distr > 48)
		{ 
			//cl(self.name + " leaning right");
			
			self botAction("+leanright");
			wait 1;
			self botAction("-leanright");
			wait 1;
		}
		else if(distr < 48 && distl > 48)
		{ 
			//cl(self.name + " leaning left");
			
			self botAction("+leanleft");
			wait 1;
			self botAction("-leanleft");
			wait 1;
		}
		
		wait 0.5;
	}
}

_bot_nav_around_walls(to, direction, iterations)
{
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "death" );
	level endon( "game_ended" );
	
	if(!self.isbot) { return; }
	if(!isDefined(to)){ return; }
	if(!isDefined(iterations)){ iterations = 99; }
		
	stop = undefined;
	self.calculatingPath = true;
	
	self thread _bot_look_at(to.pos);
	self.gridArr = [];
	self.wptArr = [];
	
	wait 1;
	
	fromPos = self getEye();
	toPos = to.pos;
	
	for(i = 0; i < iterations; i++)
	{
		if(!isDefined(self.calculatingPath))
		{
			//cl(self.name + " has stopped calc path thread!");
			break; 
		}
		
		a = VectorToAngles(toPos - fromPos);
		
		if(isDefined(direction) && i == 0){ a = direction; }
		
		sp = fromPos;
		aff = sp + anglesToForward((a[0], a[1], a[2]))*48;
		afl = sp + anglesToForward((a[0], a[1]+75, a[2]))*48; //left
		afr = sp + anglesToForward((a[0], a[1]-75, a[2]))*48; //right
		btf = bulletTrace(sp, aff, true, self);
		btl = bulletTrace(sp, afl, true, self);
		btr = bulletTrace(sp, afr, true, self);
		btp = bulletTracePassed(sp, toPos, true, self);
		posf = btf["position"];
		posl = btl["position"];
		posr = btr["position"];
		
		posf = _calc_indents(posf);
		posl = _calc_indents(posl);
		posr = _calc_indents(posr);
					
		if(btp)
		{
			cl(self.name + " has btp!");
			self.calculatingPath = undefined;
			//self.gridArr = [];
			//node = _construct_node(posf);
			self _bot_push_node(to);
			break;
		}
		else
		{
			distf = distance(sp, posf);
			distl = distance(sp, posl);
			distr = distance(sp, posr);
			
			pos = posf;
			
			if(distf < 48 && distl < 48)
			{
				pos = posr;
			}
			else if(distf < 48 && distr < 48)
			{
				pos = posl;
			}

			node = _construct_node(pos);
			
			if(distance(fromPos, pos) >= 48)
			{
				self.gridArr[self.gridArr.size] = node;
				self _bot_push_node(node);
				//cl(self.name + " node added");
			}

			fromPos = pos;
		}
		
		//wait 0.05;
	}
}

_bot_get_bt_data(pos)
{
	data = spawnStruct();
	
	a = self GetPlayerAngles();
	sp = self getEye();
	aff = sp + anglesToForward((0, a[1], a[2]))*64;
	affu = sp + anglesToForward((a[0]-40, a[1], 0))*64;
	affd = sp + anglesToForward((a[0]+40, a[1], 0))*64;
	afl = sp + anglesToForward((0, a[1]+12, 0))*64; //left
	afr = sp + anglesToForward((0, a[1]-12, 0))*64; //right
	afl90 = sp + anglesToForward((0, a[1]+90, 0))*64; //left
	afr90 = sp + anglesToForward((0, a[1]-90, 0))*64; //right
	afrr = sp + anglesToForward((0, a[1]+180, 0))*64;
	
	btf = bulletTrace(sp, aff, true, self);
	btfu = bulletTrace(sp, affu, true, self);
	btfd = bulletTrace(sp, affd, true, self);
	btl = bulletTrace(sp, afl, true, self);
	btr = bulletTrace(sp, afr, true, self);
	btl90 = bulletTrace(sp, afl90, true, self);
	btr90 = bulletTrace(sp, afr90, true, self);
	btrr = bulletTrace(sp, afrr, true, self);
	
	data.posf = btf["position"];
	data.posfu = btfu["position"];
	data.posfd = btfd["position"];
	data.posl = btl["position"];
	data.posr = btr["position"];
	data.posl90 = btl90["position"];
	data.posr90 = btr90["position"];
	data.posrr = btrr["position"];
	data.entf = btf["entity"];
	data.entl = btl["entity"];
	data.entr = btr["entity"];	
	
	//data.posf = _calc_ground(data.posf);
	
	data.posf = _calc_indents(data.posf);
	data.posl = _calc_indents(data.posl);
	data.posr = _calc_indents(data.posr);
	data.posl90 = _calc_indents(data.posl90);
	data.posr90 = _calc_indents(data.posr90);

	data.distf = distance(self getEye(),data.posf);
	data.distfu = distance(self getEye(),data.posfu);
	data.distfd = distance(self getEye(),data.posfd);
	data.distl = distance(self getEye(),data.posl);
	data.distr = distance(self getEye(),data.posr);
	data.distl90 = distance(self getEye(),data.posl90);
	data.distr90 = distance(self getEye(),data.posr90);
	
	data.btp = bulletTracePassed(self getEye(), pos, false, self);
	bt = bulletTrace(self getEye(), pos, false, self);
	data.bt = bt["position"];
	
	data.distd = distance(self getEye(), pos);
	
	return data;
}

_bot_self_nav(to)  //bot trying avoid obstacles by turning, not strafing
{
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "death" );
	level endon( "game_ended" );
	
	if(!self.isbot) { return; }
	if(!isDefined(to)){ return; }
	if(!isDefined(to.pos)){ return; }
	if(isDefined(self.isSelfNavigating)){ return; }
	
	maxDist = 500;
		
	self.isSelfNavigating = true;
	
	self _bot_look_at(to.pos);
	
	//cl(self.name + " is self navigating to " + to.pos);
		
	while(isAlive(self) && isDefined(self.isSelfNavigating))
	{
	
		if(!isDefined(self.isSelfNavigating))
		{ 
			cl(self.name + " stopped self navigating");
			break; 
		}
		
		btp = bulletTracePassed(self getEye(), to.pos, false, self);
		if(btp)
		{ 
			//cl(self.name + " btp");
			//self _bot_look_at(to);
			self _bot_push_node(to);
			self.isSelfNavigating = undefined;
		}
		
		if(distance(self getEye(), to.pos) > maxDist)
		{
			//cl(self.name + " self nav stopped due to distance!");
			self _bot_look_at(to.pos);
			self.isSelfNavigating = undefined;
			break;
		}
	
		data = self _bot_get_bt_data(to.pos);
		
		self botAction( "+gocrouch"); 
				
		if(data.btp)
		{ 
			self botAction( "-gocrouch"); 
			//cl(self.name + " found bt: " + data.bt);			
			
			if(distance(data.bt, self getEye()) < 64)
			{
				//self _bot_look_at(self getEye());
				self.isSelfNavigating = undefined;
				//cl(self.name + " _bot_self_nav() stopped!");	
				break;
			}
			else
			{
				self _bot_look_at(to.pos);
				self botMoveTo(to.pos);	 
			}
		}
		else if(data.distf < 32 && data.distl < 32)
		{
			self _bot_look_at(data.posr90);
			self botMoveTo(data.posr90);
		}
		else if(data.distf < 32 && data.distr < 32)
		{
			self _bot_look_at(data.posl90);
			self botMoveTo(data.posl90);
		}
		else if(data.distl < 32)
		{
		 	self _bot_look_at(data.posr);
			self botMoveTo(data.posr);
		 	//cl(self.name + " going right");
			//level waittill("next");
			
			while(1)
			{
				if(!isDefined(self.isSelfNavigating)){ break; }
				
				data = self _bot_get_bt_data(to.pos);
				//cl(self.name + " data.distl90: " + data.distl90);
				
				if(data.distl90 < 64)
				{
					//cl(self.name + " left turn");
					self thread _bot_look_at(data.posf);
					self botMoveTo(data.posf);
				}
				else if(data.distl90 >= 64)
				{
					//cl(self.name + " left break");
					self _bot_look_at(data.posl90);
					self botMoveTo(data.posl90);
					break;
				}
				
				//self _bot_look_at(data.posr);
				//self botMoveTo(data.posr);
				//level waittill("next");
				wait 0.1;
			}
			
			//cl(self.name + " left timedout");
		}
		else if(data.distr < 32)
		{
		 	self _bot_look_at(data.posl);
			self botMoveTo(data.posl);
		 	//cl(self.name + " going left");
			//level waittill("next");
			
			while(1)
			{
				if(!isDefined(self.isSelfNavigating)){ break; }
				
				data = self _bot_get_bt_data(to.pos);
				//cl(self.name + " data.distr90: " + data.distr90);
				
				if(data.distr90 < 64)
				{
					//cl(self.name + " right turn");
					self thread _bot_look_at(data.posf);
					self botMoveTo(data.posf);
				}
				else if(data.distr90 >= 64)
				{
					//cl(self.name + " right break");
					self _bot_look_at(data.posr90);
					self botMoveTo(data.posr90);
					break;
				}
				
				//self _bot_look_at(data.posr);
				//self botMoveTo(data.posr);
				//level waittill("next");
				
				wait 0.1;
			}
			
			//cl(self.name + " right timedout");
		}
		/*else if(data.distf < 16 && data.distr < 16 && data.distl < 16)
		{
		 	self _bot_look_at(data.posrr, 0.1);
			self botMoveTo(self getEye());
		 	cl(self.name + " turning 180 degrees");
		 	wait 0.5;
		}
		else if(data.distd > 500 && data.distf > 16 && data.distr > 16 && data.distl > 16)
		{
		 	break;
		}	
		*/
		else if(data.distf >= 32)
		{
			//self _bot_look_at(data.posf);
			//node = _construct_node(posf);
			//self _bot_push_node(node);
			self botMoveTo(data.posf);
			//cl(self.name + " going forward");
			//level waittill("next");
		}
		
		wait 0.1;
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
	//self endon( "death" );
	level endon( "game_ended" );
	
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
	
	//pos = _calc_ground(pos, 40);

	btn = bulletTrace(pos,(pos[0]+minDist,pos[1],pos[2]), false, self); // + north, - south
	btn = btn["position"];
	bte = bulletTrace(pos,(pos[0],pos[1]+minDist,pos[2]), false, self); // + west - east 
	bte = bte["position"];
	bts = bulletTrace(pos,(pos[0]-minDist,pos[1],pos[2]), false, self);
	bts = bts["position"];
	btw = bulletTrace(pos,(pos[0],pos[1]-minDist,pos[2]), false, self);
	btw = btw["position"];
	//btu = bulletTrace(pos,(pos[0],pos[1],pos[2]+minDist), false, self);
	//btu = btu["position"];
	//btd = bulletTrace(pos,(pos[0],pos[1],pos[2]-minDist), false, self);
	//btd = btd["position"];
	
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
	//dist5 = distance(pos,btu);
	//dist6 = distance(pos,btd);
	
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
	//distz=dist5-dist6;
		
	pos = (pos[0] + disty, pos[1] + distx, pos[2]);
	//pos = (pos[0]+disty,pos[1]+distx,pos[2]+distz);
		
	return pos;
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

_dev_player_spawn_near_bomb()
{
	p = level.sabBomb.curOrigin;
	self SetOrigin((p[0]-128,p[1]-128,p[2]));
}

_dev_nodes_plant()
{
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "death" );
	level endon( "game_ended" );
	
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
				
				//bt = BulletTrace(self getEye(), bot getEye(), false, self);
				//from = _construct_node(bt["position"]);

				from = _construct_node(self getEye(), self);
				to = _construct_node(bot getEye(), bot);
				bot _grid_create(from, to);
				//bot = create_ring_grid(from, to);
			}
		}
		
		while (self LeanRightButtonPressed()){ wait 0.05; }
		wait 0.05;
	}
}

_grid_node_props(pos, angles, parent)
{
	node = spawnstruct();
	node.pos = pos;
	node.angles = angles;
	node.gCost = 0;
	node.hCost = 0;
	node.fCost = 0;
	node.score = 0;
	node.parent = parent;
	node.passed = false;
	
	return node;
}

_grid_check_dest_visible(node, dest)
{
	stp = BulletTracePassed(node.pos, dest, false, self);
	
	return stp;
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

_grid_check_nearby_nodes(bot, pos, minDist)
{
	if(!isDefined(minDist)){ minDist = 32; }
		
	for(i = 0; i < bot.gridArr.size; i++)
	{
		//if(bot.gridArr[i].pos == pos){ continue; }
		
		dist = distance(bot.gridArr[i].pos, pos);
		
		if(isDefined(dist) && dist < minDist)
		{
			//cl("dist: " + dist);
			//bot.gridArr = scripts\main::_arr_remove(bot.gridArr, bot.gridArr[j]);
			//cl("not creating node at: " + pos);
			return true;
		}
	}
	
	return false;
}

_get_bullettrace_pos(pos, a, interval)
{
	af = pos + anglesToForward(a) * interval;
	
	bt = bulletTrace(pos, af, false, self);
	bt = bt["position"];
	bt = _calc_indents(bt);
	bt = _calc_ground(bt, 20);

	return bt;
}

_calc_node_cost(node, from, to)
{
	node.gCost = distance(node.pos, from.pos); //from start point
	node.hCost = distance(node.pos, to.pos); //from end point
	node.fCost = node.gCost + node.hCost;	
}

_grid_plant_node(ent, pos, interval, from, to)
{
	if(!_grid_check_nearby_nodes(ent, pos, interval))
	{
		node = _grid_node_props(pos, (270,0,0), from);
		_calc_node_cost(node, from, to); 
		self.gridArr[self.gridArr.size] = node;
		//cl("gcost: " + node.gCost);
		//cl("hcost: " + node.hCost);
		//cl("fcost: " + node.fCost);
		
		//level waittill("next");
	}
}

_grid_nodes_plant(from, to, interval, parent)
{
	if(!isDefined(interval)){ interval = 32; }

	//pos = from.pos;
	pos = _calc_ground(from.pos, 20);
	a = VectorToAngles(to.pos - from.pos);
	aff = pos + anglesToForward(( a[0], a[1], a[2] )) * interval;
	//aff = _calc_ground(aff);

	btf = _get_bullettrace_pos(pos, a, interval);

	/*btf = bulletTrace(pos, aff, false, self);
	btf = btf["position"];
	btf = _calc_indents(btf);
	btf = _calc_ground(btf, 16);*/
	distf = distance(btf, aff);
		
	/*if(distf < interval * 0.9)
	{
		angles = VectorToAngles(pos - btf);
		_grid_plant_node(self, btf, interval * 0.9, from, to);	
	}
	else
	{*/
		
		btf = _get_bullettrace_pos(pos, (0, 0, 0), interval);
		btl = _get_bullettrace_pos(pos, (0, 90, 0), interval);
		btb = _get_bullettrace_pos(pos, (0, 180, 0), interval);
		btr = _get_bullettrace_pos(pos, (0, 270, 0), interval);
		
		_grid_plant_node(self, btf, interval * 0.9, from, to);
		_grid_plant_node(self, btl, interval * 0.9, from, to);
		_grid_plant_node(self, btb, interval * 0.9, from, to);
		_grid_plant_node(self, btr, interval * 0.9, from, to);
		
		//calc_node_score(from, to);
	//}
	
	//level waittill("next");
}

_grid_create(from, to) //from self to bot
{
	self endon("disconnect");
	self endon("intermission");
	self endon("death");
	level endon("game_ended");
	
	//if (getDvar("v01d_dev") != "nav"){ return; }
	//if (!self.isbot){ return; }
	
	if(!isDefined(from)){ return; }
	//if(!isDefined(to)){ return; }
	
	self.gridArr = [];
	self.wptArr = [];
	self.moveToPos = undefined;

	btp = BulletTracePassed(self getEye(), from.pos, false, self);
	
	if(btp)
	{
		self _bot_push_node(from); //from = destination
		//cl(self.name + " got grid btp");
		return false;
	}
	
	cl(self.name + " grid thread started");
	stop = undefined;
	score = 0;
	interval = 64;
	iterations = 16;
	
	//self _grid_nodes_plant(from, to, interval);
	pos = _calc_ground(from.pos, 20);
	_grid_plant_node(self, pos, 0, from, to);

	gridSize = self.gridArr.size;
	closest = undefined;

	for(i1 = 0; i1 <= iterations; i1++)
	{
		if(isDefined(stop))
		{ 
			cl(self.name + " node planting stopped"); 
			break;
		}
		
		//cl(self.name + " iterations nr.: " + i1);

		if(i1 >= iterations)
		{ 
			cl(self.name + " iterations limit: " + iterations); 
			return false;
		}
		
		score++;

		for(i2 = 0; i2 < gridSize; i2++)
		{				
			//if(self.gridArr[i2].passed){ continue; }

			closest = self.gridArr[i2];

			//if(_grid_check_bot_nearby(self, to, interval))
			if(_grid_check_dest_visible(self.gridArr[i2], to.pos))
			{
				cl(self.name + " stopping node planting"); 
				stop = true;
				break;
			}			
			
			self _grid_nodes_plant(self.gridArr[i2], to, interval);
			//self.gridArr[i2].passed = true;
			self.gridArr[i2].score = score;
			
			//wait 0.05;
			//if(i2 % 2 == 0){ wait 0.05; }
			//level waittill("next");
		}
		
		gridSize = self.gridArr.size;
					
		//if(i1 % 5 == 0){ wait 0.05; }
		wait 0.05;
		
		//level waittill("next");
	}

	//self.gridArr = self _bot_grid_calc_path(closest, to);
	self.gridArr = self _bot_grid_calc_path(closest, to);
	
	for(i = 0; i < self.gridArr.size; i++)
	{
		self.gridArr[i].pos = _calc_indents(self.gridArr[i].pos);
		self.gridArr[i].pos = _calc_ground(self.gridArr[i].pos);
		//self.gridArr[i].pos = _calc_ground(self.gridArr[i].pos);
		self _bot_push_node(self.gridArr[i]);
	}
	
	//cl("self.gridArr.size:" + self.gridArr.size);
	cl(self.name + " grid thread ended");
	
	if(self.gridArr.size > 0)
	{
		return true;
	}
	
	return false;
}

_bot_grid_calc_path(from, to, maxScore) //from self to bot
{
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "death" );
	level endon( "game_ended" );
	
	if (!self.isbot){ return; }

	if(!isDefined(from)){ return; }
	if(!isDefined(to)){ return; }
	if(!isDefined(self.gridArr)){ return; }
	
	cl(self.name + " calculating grid path from " + from.pos + " to " + to.pos);
	
	nr = undefined;
	stop = undefined;
	gridArr = [];
	closest = from;
	
	gridArr[gridArr.size] = closest;
	
	for(i1 = 0; i1 < gridArr.size; i1++)
	{		
		if(isDefined(closest.parent))
		{
			closest = closest.parent;
			//cl("parent.fCost: " + closest.fCost);
			//gridArr[gridArr.size] = closest;
			gridArr[gridArr.size] = closest;
			//cl("closest.parent: " + i1);
			//level waittill("next");
		}
		
		//if(i1 % 15 == 0){ wait 0.05; }
		//level waittill("next");
	}
	
	return gridArr;
}

_bot_nodes_acm() //bot nodes accumulation
{
	self endon("disconnect");
	self endon("intermission");
	self endon("death");
	level endon("game_ended");
	
	if(!self.isbot){ return; }
		
	nr = undefined;
	prevPos = self getEye();
	
	while(isAlive(self))
	{
		//cl(self.name + " wptArr size: "+self.wptArr.size);

		wptPassed = [];

		while(isDefined(self.isPlantingBomb)){ wait 1; }
		while(isDefined(self.isDefusingBomb)){ wait 1; }
		while(self.wptArr.size < 1){ wait 1; }
		
		for(i = 0; i < self.wptArr.size; i++)
		{
			if(!isDefined(self.wptArr[i]))
			{
				self.wptArr = scripts\main::_arr_remove(self.wptArr, self.wptArr[i]);
			}
		}
					
		for(i = 0; i < self.wptArr.size; i++)
		{
			nr = i;
			break;
		}
		
		while
		(
			isAlive(self) 
			&& self.wptArr.size > 0 
			&& isDefined(nr) 
			&& isDefined(self.wptArr[nr])
		)
		{
			eye = self getEye();
			//eye = (eye[0],eye[1],eye[2]+64);
			dist1 = distance(eye, self.wptArr[nr].pos); 
			
			bt = bulletTrace(eye, self.wptArr[nr].pos, false, self);
			bt = bt["position"];
			btp = bulletTracePassed(eye, self.wptArr[nr].pos, false, self);
			
			dist2 = dist1 - distance(bt, self.wptArr[nr].pos);
			
			if(!btp)
			{ 
				//cl(self.name + " wall!"); 
				wait 1;
				//self _grid_create(self.wptArr[nr], self getEye()); 
				break;
			}
			
			self.moveToPos = self.wptArr[nr].pos;
			
			if(!isDefined(self.moveToPos))
			{ 
				cl("undefined self.moveToPos");
				
				continue; 
			} 
			
			self botMoveTo(self.moveToPos);

			/*if
			(
				self.wptArr.size - 1 > 0 
				&& isDefined(self.wptArr[self.wptArr.size-1])
			)
			{ 
				if(isDefined(self.hasEnemyTarget))
				{
					self thread _bot_look_at(self.hasEnemyTarget getEye()); //pos,aimspeed,c1,c2
					//while(isDefined(self.hasEnemyTarget)){ wait 1; }
				}
				else
				{
					self thread _bot_look_at(self.moveToPos); //pos,aimspeed,c1,c2
					//self thread _bot_look_at(self.wptArr[self.wptArr.size-1].pos); //pos,aimspeed,c1,c2
				}
			}*/
			
			if(isDefined(self.hasEnemyTarget))
			{
				self thread _bot_look_at(self.moveToPos);
			}
			else
			{
				self thread _bot_look_at(self.moveToPos);
			}
				
			dist1 = distance(self getEye(), self.wptArr[nr].pos);
				
			c=0;
			while
			(
				isAlive(self) 
				&& isDefined(self.moveToPos) 
				&& isDefined(self.wptArr[nr])
			)
			{ 
				//if(!isDefined(self.wptArr[nr]){ continue; }
				
				dist1 = distance(self getEye(), self.wptArr[nr].pos);  
				dist2 = distance(self getEye(), self.wptArr[self.wptArr.size - 1].pos);  
								
				if
				(
					self.wptArr.size == 1 
					&& isDefined(dist2) 
					&& dist2 < 48
				)
				{
					//cl(self.name+" destination reached!");
										
					wptPassed[wptPassed.size] = self.wptArr[nr];
					//self.wptPassed[self.wptPassed.size] = self.wptArr[nr];
					self.wptArr = scripts\main::_arr_remove(self.wptArr,self.wptArr[nr]);
					self.moveToPos = undefined;
					self.gridArr = [];
					//self.wptPassed = [];
					
					if
					(
						isDefined(self.nodeStance) 
						&& !isDefined(self.isJumping) 
						&& self.nodeStance != "any"
					)
					{ 
						self botAction( "+go"+ self.nodeStance); 
					}
					else 
					{ 
						self botAction( "+gocrouch"); 
					}
					
					nr = undefined;
					break;
				}
				else if(isDefined(dist1) && dist1 < 64)
				{ 
					//self.wptPassed[self.wptPassed.size] = self.wptArr[nr];
					//cl(self.name+" node reached!");
					self.moveToPos = undefined;
					break;
				}
				else if(isDefined(dist2) && dist2 < 128)
				{ 
					//self botAction( "+gocrouch"); 
					a = self.wptArr[nr].angles;
					aff = self.wptArr[nr].pos + anglesToForward((a[0], a[1], a[2])) * 32;
					vd = self scripts\main::_dp(self getEye(), level.objectivePos, a);
					
					if(vd > 0 && !isDefined(self.hasEnemyTarget))
					{
						self thread _bot_look_at(aff, 0.5);
						//cl(self.name + " vd: " + vd);
						//cl(self.name + " _bot_look_at(aff)");
					}
					else
					{
						self thread _bot_look_at(level.objectivePos);
						//pos,aimspeed,c1,c2
					}

				}
				else
				{ 
					self botAction("-gocrouch");
					self botAction("-goprone"); 
				}
				 
				dist2 = distance(prevPos, self getEye()); 
				
				if(isDefined(dist2) && dist2 < 5) 
				{ 
					c++; 
				}
				else
				{ 
					c=0; 
				}
				
				if(c >= 100)
				{ 
					//cl(self.name + " destination approach timed out"); 
		
					//self.wptArr = [];
					//self.gridArr = [];
					//self.wptPassed = [];
					//self botMoveTo(self getEye());
					//self.moveToPos = undefined;
					break;
				}
				
				prevPos = self getEye();
				
				wait 0.05;
			}
			
			for(i = 0; i < self.wptArr.size; i++)
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
	
	pos = _calc_indents(node.pos);
	node = _construct_node(pos, self);
	
	self.wptArr[self.wptArr.size] = node;
}

_bot_push_nodes(nodes) //adding nodes to bot wptArr
{ 
	if(!self.isbot){ return; }
	if(!isDefined(nodes)){ return; }
	
	for(i = 0; i < nodes.size; i++)
	{
		self _bot_push_node(nodes[i]);
		//thread _ping_marked_node(nodes[i]);
		//cl("nodes[i]: " + nodes[i].pos);
		//wait 1;
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

_node_info()
{
	self endon ( "disconnect" );
	self endon( "intermission" );
	level endon( "game_ended" );
	
	if (getDvar("v01d_dev") != "nav"){ return; }
	if (self.isbot) { return; }
	
	for(;;)
	{
		self waittill("showNodeInfo");
		
		node = self.nodecatch;
		
		if(isDefined(node))
		{
			self pl("Node params: nr " + node.id + ", pos " + node.pos + ",  stance:" + node.type + ",angles:" + node.angles + ", cover:" + node.cover);
		}
		
		wait 0.5;
	}
}

_add_node(node)
{
	//level.nodes_quantity++;
	level.nodes[level.nodes.size] = node;
}

_teleport(player, to)
{
	 player SetOrigin(to);
	 cl("player teleported: " +player.name );
}

_add_remove_nodes(){
	self endon ( "disconnect" );
	self endon( "intermission" );
	level endon( "game_ended" );
	
	if (getDvar("v01d_dev") != "nav"){ return; }
	if (getdvarint("bots_main_debug")>0) { return; }  
	if (self.isbot) { return; }
	
	cl("^3_add_nodes started on "+self.name);
	
	use=false;
	hbr=false;
	rmb=false;

	for(;;){
		_c = 10; c=_c;
		
		while (!self AdsButtonPressed() && !self UseButtonPressed() && !self HoldBreathButtonPressed()){ wait 0.05; }		
		
		while ( self AdsButtonPressed() ){ rmb=true; wait 0.05; }
		while ( self HoldBreathButtonPressed() ){ hbr=true; wait 0.05; }
		
		while ( self UseButtonPressed() && c>0)
		{ 
			if(c < 1){ c = _c; break; }
			use=true; 
			c--; 
			wait 0.05; 
		}
		
		
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
						vd = self scripts\main::_dp(self getEye(), objs[i].pos, self.angles);

						if(objs[i].marked)
						{ 
							nr=i; 
							closest=dist; 
						}
					}
				}
				
				if (isDefined(nr))
				{
					if(rmb)
					{
						cl("rmb pos: " + objs[nr].pos);
						players = getentarray("player", "classname");
						
						for(i1=0;i1<players.size;i1++)
						{
							if(!players[i1].isbot){ continue; }
							bot = players[i1];
							//_teleport(bot, objs[nr].pos);
							
							//from = bot _construct_node(bot getEye());
							//to = bot _construct_node(objs[nr].pos);				
							
							//bot.isGoingToPoint = objs[nr].pos;
							//thread _ping_marked_node(objs[nr]);
						}
					}
					else if(hbr == true)
					{					
						cl("hbr pos: " + objs[nr].pos);
						players = getentarray("player", "classname");
						
						for(i1=0;i1<players.size;i1++)
						{
							if(!players[i1].isbot){ continue; }
							bot = players[i1];
							from = bot _construct_node(bot getEye());
							to = bot _construct_node(objs[nr].pos);
							
							//bot _grid_create(to, from);
							
							//nodes = bot _bot_calc_path(from, to, 0, 64, -1, 40, false);
							//from, to, indent, minDist, sector, distzMax, ignoreVis, ignoreNodes
							
							//bot _bot_push_nodes(nodes);
						}
					}
					else if(isDefined(objs[nr].cover)) 
					{ 
						if(use == true)
						{
							for(i=0;i<level.node_types.size;i++)
							{
								if(objs[nr].cover == level.node_types[i])
								{
									change = true; 
									
									if(i + 1 > level.node_types.size - 1)
									{
										objs[nr].cover = level.node_types[0]; 
									}
									else
									{
										objs[nr].cover = level.node_types[i+1]; 
									}
									
									cl("^3Node changed to type "+objs[nr].cover);
									pl("^3Node changed to type "+objs[nr].cover);
									self notify("showNodeInfo");
									break;
								}
							}
						} 
					} 
					
					if (use == true && c < 1){
						self iprintln("^3deleting:"+nr);
						delete = true;
						level.nodes = scripts\main::_arr_remove(objs,objs[nr]);
						//level.nodes_quantity=level.nodes.size;
						objs = undefined;
						self iprintln("^3Node deleted with ID: " + nr);
					}
				}
			} 
			
			if (use == true && delete == false && change == false)
			{ 
				pos = _calc_indents(self getEye(), 40);
				//pos = _get_head_pos(self);
				
				if(!isAlive(self))
				{
					a = self GetPlayerAngles();
					aff = self getEye() + anglesToForward((a[0], a[1], a[2])) * 999;
					btf = bulletTrace(self getEye(), aff, false, self);
					pos = _calc_indents(btf["position"]);
					pos = _calc_ground(pos, 40);
					cl("pos: " + pos);
				}
				
				node = _construct_node(pos, self); 
				self _add_node(node);
				delete = false; change = false; 
				self iprintln("^3Node added with ID: " + node.id);
			}
			
			wait 0.05;	
		}
		
		while(self AdsButtonPressed() || self UseButtonPressed() || self HoldBreathButtonPressed()){ wait 0.05; }
		
		use=false; 
		hbr=false;
		rmb=false;
		
		wait 0.05;
	}
}

_bot_get_weapon_class()
{
	self endon("disconnect");
	level endon( "game_ended" );
	
	if (!self.isbot){ return; }
	
	weapons = self GetWeaponsList();
	
	if(!isDefined(weapons)){ return "none"; }
	if(!isDefined(weapons[0])){ return "none"; }
	
	class = scripts\main::_get_weapon_class(weapons[0]);
	//cl(self.name + " has class: " + class);
	return class;		
}

_ping_marked_node(node, times, freq)
{
	if(!isDefined(level.nodes)){ return; }
	if(!isDefined(node)){ return; }
	if(!isDefined(times)){ times = 5; }
	if(!isDefined(freq)){ freq = 0.25; }
	
	for(i = 0; i < times; i++)
	{
		if(!isDefined(level.nodes)){ return; }
		if(!isDefined(node)){ return; }
		if(!isDefined(node.id)){ return; }
		if(!isDefined(level.nodes[node.id])){ return; }
		if(level.nodes[node.id].marked){ return; }
		wait freq * 0.5;
		if(!isDefined(level.nodes)){ return; }
		if(!isDefined(node)){ return; }
		if(!isDefined(node.id)){ return; }
		if(!isDefined(level.nodes[node.id])){ return; }
		level.nodes[node.id].marked = false;
		wait freq * 0.5;
	}
}

_marked_nodes(){
	self endon ( "disconnect" );
	self endon( "intermission" );
	level endon( "game_ended" );
	
	if (getDvar("v01d_dev") != "nav"){ return; }
	if (self.isbot) { return; }
	
	//cl("^3_marked_nodes started on "+self.name);
	
	maxDist = 555;

	for(;;)
	{
		a = self GetPlayerAngles();
		startPos = self getEye();
		startPosForward = startPos + anglesToForward( ( a[0], a[1], a[2] ) ) * 1200;
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
					vd = self scripts\main::_dp(self getEye(), objs[i].pos, a);
					dist = distance( self getEye(), objs[i].pos ); 
					objs[i].marked = false;
					
					if(dist < maxDist && vd > 0.99)
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

_hud_draw_nodes()
{
	self endon ( "disconnect" );
	self endon( "intermission" );
	level endon( "game_ended" );
		
	if (getDvar("v01d_dev") != "nav"){ return; }
	if (self.isbot) {return;}
	
	//cl("^3starting _hud_draw_nodes thread "+self.name);
	dist = 0; size=0; threshold=99;
	hud_q=0;
	drawDistance = 555;
	drawModelDistance = 255;
	
	for(;;)
	{
		objs = level.nodes;	
		devModels = [];
		
		if (isDefined(objs))
		{
			closest = 999;
			
			for( i = 0 ; i < objs.size ; i++ )
			{
				if(isDefined(objs[i]))
				{
					dist = distance( self.origin, objs[i].pos );
					
					if(dist < drawDistance && hud_q <= threshold)
					{
						self.hudwpt[hud_q] = newClientHudElem( self ); 
						if(objs[i].marked)
						{ 
							self.hudwpt[hud_q] setShader( "compass_waypoint_target", 15, 15 ); 
						}
						else if(isDefined(objs[i].cover) && objs[i].cover != "any") 
						{ 
							self.hudwpt[hud_q] setShader( "compass_waypoint_bomb", 15, 15 ); 
						}
						else 
						{ 
							self.hudwpt[hud_q] setShader( "compass_waypoint_defend", 15, 15 ); 
						}
						
						self.hudwpt[hud_q].alpha = 0.5;
						self.hudwpt[hud_q].x = objs[i].pos[0]; self.hudwpt[hud_q].y = objs[i].pos[1]; self.hudwpt[hud_q].z = objs[i].pos[2]+20;
						
						if(objs[i].marked) 
						{ 
							self.hudwpt[hud_q] SetWayPoint(true, "compass_waypoint_target"); 
						}
						else if(isDefined(objs[i].cover) && objs[i].cover != "any") 
						{ 
							self.hudwpt[hud_q] SetWayPoint(true, "compass_waypoint_bomb"); 
						}
						else 
						{ 
							self.hudwpt[hud_q] SetWayPoint(true, "compass_waypoint_defend"); 
						}
						
						self notify("showNodeInfo");
						hud_q++;
					}
					
					if(dist < drawModelDistance)
					{
						devModels[devModels.size] = _dev_spawn_model(objs[i].pos, level.dm1, objs[i].angles);
					}
				}
			}
			//self iprintln("^3level.nodes.size:"+objs.size);
		}
		
		wait 0.1;
		
		if(isDefined(self.hudwpt))
		{
			for(i = 0 ; i < self.hudwpt.size; i++)
			{ 
				if(isDefined(self.hudwpt[i])) 
				{ 
					self.hudwpt[i] Destroy(); 
				}
			}
		}
		
		for(i = 0 ; i < devModels.size; i++)
		{ 
			if(isDefined(devModels[i])) 
			{ 
				devModels[i] delete(); 
			}
		}
		
		hud_q=0;
	}
}

_hud_draw_grid()
{
	self endon ( "disconnect" );
	self endon( "intermission" );
	level endon( "game_ended" );
		
	if (getDvar("v01d_dev") != "nav"){ return; }
	if(self.isbot) { return; }
	
	cl("starting _draw_grid thread "+self.name);
	dist = 0; size=0; threshold=999; draw_dist=1500;
	hud_q = 0;
	grid = undefined;
	
	drawModelDistance = 255;

	for(;;)
	{
		devModels = [];
		
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
		if (isDefined(objs))
		{
			//cl("objs.size: "+objs.size);
			closest = 2147483647;
			
			for(i=0;i<objs.size;i++)
			{
				if(isDefined(objs[i]))
				{
					dist = distance( self.origin, objs[i].pos );
					if(dist<draw_dist)
					{
						self.hudgrid[hud_q] = newClientHudElem( self ); 
						self.hudgrid[hud_q] setShader( "compass_waypoint_target", 15, 15 );
						self.hudgrid[hud_q].alpha = 0.5;
						self.hudgrid[hud_q].x = objs[i].pos[0]; self.hudgrid[hud_q].y = objs[i].pos[1]; self.hudgrid[hud_q].z = objs[i].pos[2];
						self.hudgrid[hud_q] SetWayPoint(true, "compass_waypoint_target");
						//self notify("showNodeInfo");
						hud_q++;
					}
					
					if(dist < drawModelDistance)
					{
						devModels[devModels.size] = _dev_spawn_model(objs[i].pos, level.dm2, objs[i].angles);
					}
				}
			}
			//self iprintln("^3level.nodes.size:"+objs.size);
		}	
		
		wait 0.1;
		
		if(isDefined(self.hudgrid))
		{
			for( i2 = 0 ; i2 < self.hudgrid.size; i2++ )
			{ 
				if(isDefined(self.hudgrid[i2]))
				{ 
					self.hudgrid[i2] Destroy(); 
				}
			}
		}
		
		for(i3 = 0 ; i3 < devModels.size; i3++)
		{ 
			if(isDefined(devModels[i3])) 
			{ 
				devModels[i3] delete(); 
			}
		}
		
		hud_q=0;
	}
}

_read_nodes_file(filename)
{
	nodes = [];
	lines = _read_text_file(filename);
	
	if(!isDefined(lines))
	{ 
		cl("Error reading file: " + filename); 
		return nodes;
	}
	else if(isSubStr(filename, ".csv"))
	{
		cl( "processing BotWarfare waypoints from " + filename);
		for(i = 1; i < lines.size; i++ )
		{
			line = lines[i];
			token = tokenizeLine(line, ",");
			converted = _convert_bw_token(token);
			tokenized = parseTokensIntoNodes(converted);
			pos = _calc_indents(tokenized.pos);
			pos = _calc_ground(pos, 48);
			node = _construct_node(pos);
			nodes[nodes.size] = node;
		}	
	}
	else
	{
		cl( "processing nodes from " + filename);
		//pl( "Attempting to read nodes from " + filename );
			
		for(i = 0; i < lines.size; i++ )
		{
			line = lines[i];
			tokens = tokenizeLine(line, ",");
			node = parseTokensIntoNodes(tokens);
			nodes[nodes.size] = node;
		}
	}
	
	return nodes;
}

_convert_bw_token(token)
{	
	converted = [];
	
	converted[0] = token[0];
	converted[1] = token[2];
	converted[2] = token[3];
	converted[3] = "any";
	
	return converted;
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

_check_if_no_nodes()
{
	if(!isDefined(level.nodes))
	{ 
		cl( "No nodes to load from file" ); 
		return true; 
	}
	else if(level.nodes.size < 1) 
	{ 
		cl( "No nodes available in this map" ); 
		return true; 
	}
	
	return false;
}

_load_nodes()
{
	mapname = getDvar( "mapname" );
	//level.nodes_quantity = 0;
	level.nodes = [];
	filename = "nodes/" + mapname + ".nodes";
	nodes = _read_nodes_file(filename);
	level.nodes = nodes;
	
	if(_check_if_no_nodes())
	{  
		filename = "waypoints/" + getdvar( "mapname" ) + "_wp.csv";
		nodes = _read_nodes_file(filename);
				
		if(nodes.size < 1){ return true; }
		
		level.nodes = nodes;
	}
	
	cl( "Loaded " + nodes.size + " nodes from file." );
	//pl( "Loaded " + nodes.size + " nodes from file." );
	//level.nodes_quantity = level.nodes.size;

	for ( i = 0; i < level.nodes.size; i++ )
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
	self endon( "disconnect" );
	self endon( "intermission" );
	level endon( "game_ended" );
		
	if(getDvar("v01d_dev") != "nav"){ return; }
	if(self.isbot){ return; }
	
	while(1)
	{
		c = 20;
		
		while(!self HoldBreathButtonPressed())
		{ 
			wait 0.05;
		}
		
		while(self HoldBreathButtonPressed() && c > 0)
		{ 
			c--; 
			wait 0.05;
		}
		
		if(c < 1)
		{ 
			level.nodes = [];
			pl("level.nodes cleared!");
			cl("level.nodes cleared!");
			wait 0.2;
		}
		
		wait 0.05;
	}
}

_save_nodes()
{
	self endon ( "disconnect" );
	self endon( "intermission" );
	level endon( "game_ended" );
		
	if(getDvar("v01d_dev") != "nav"){ return; }
	if(self.isbot){ return; }

	for(;;)
	{
		c=10;
		
		while(!self meleeButtonPressed()){ wait 0.05; }
		
		while(self meleeButtonPressed()&& c > 0)
		{ 
			c--; 
			wait 0.05;
		}

		if(c < 1)
		{ 
			mpnm = getdvar( "mapname" );
			
			if(level.nodes.size > 0) 
			{
				arr = [];
				
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
		
					arr[arr.size] = str;
				}
		
				cl("Saving nodes...");
				
				filename = "nodes/" + getdvar( "mapname" ) + ".nodes";
				_write_text_file(arr, filename);

				cl(arr.size + " nodes saved!!! to " + filename );
				pl(arr.size + " nodes saved!!! to " + filename );
			}
			else 
			{
				cl("No nodes to save!");
				pl("No nodes to save!");
			}
		}
		
		while(self meleeButtonPressed()){ wait 0.05; }
		
		wait 0.05;
	}
}
