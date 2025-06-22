#include scripts\cl;
init()
{
	//if (getdvarint("developer")<1){ return; }
	//exec("v01d_dev 1");

	precacheShader("compass_waypoint_defend");
	precacheShader("compass_waypoint_target");
	precacheShader("compass_waypoint_bomb");
	
	setDvar( "scr_heli_missile_max", 0 );
	
	level.choppers = undefined;
	level.choppersAxis = undefined;
	level.choppersAllies = undefined;
	
	//level thread _add_choppers();
	level thread _get_all_choppers();
	
	for(;;)
    {
		level waittill("connected", player);
		//player thread _give_chopper_hardpoint();
		//player thread _dev_chopper_test();
	}
}


_add_choppers(){
	wait 2;
	random_path = randomint( level.heli_paths[0].size );
	startnode = level.heli_paths[0][random_path];
	thread maps\mp\_helicopter::heli_think(undefined, startnode, "axis"); 
	wait 5;
	thread maps\mp\_helicopter::heli_think(undefined, startnode, "allies"); 
}

_dev_chopper_test(){
	self endon ( "disconnect" );
	self endon ( "intermission" );
	level endon ( "game_ended" );
	
	if(self.isbot){ return; }
	
	wait 2;
	cl("11_dev_chopper_test");
	for(;;){
		while(!self LeanLeftButtonPressed() && !self LeanRightButtonPressed()){ wait 0.05; }
		random_path = randomint( level.heli_paths[0].size );
		startnode = level.heli_paths[0][random_path];
		if(self LeanLeftButtonPressed()){ 
			thread maps\mp\_helicopter::heli_think(self, startnode, "axis"); 
		}
		if(self LeanRightButtonPressed()){ 
			thread maps\mp\_helicopter::heli_think(self, startnode, "allies"); 
			//level.chopper thread maps\mp\_helicopter::heli_crash(); 
		}
				
		while(self LeanLeftButtonPressed() || self LeanRightButtonPressed()){ wait 0.05; }
		wait 0.05;
	}
}


_give_chopper_hardpoint()
{
	self endon ( "disconnect" );
	self endon( "intermission" );
	level endon ( "game_ended" );
	//self endon( "death" );
	
	if (self.isbot){ return; }
	
	for(;;){
	
		//self waittill("spawned_player");
		if(isAlive(self)){
			self maps\mp\gametypes\_hardpoints::giveHardpointItem( "helicopter_mp" );
			//self giveWeapon("helicopter_mp");
			//self SetWeaponAmmoStock("helicopter_mp",1);
			cl(self.name+" is given hardpoint "+self.pers["hardPointItem"]);
			while (isDefined(self.pers["hardPointItem"])) { wait 1; }
			cl(self.name+" used hardpoint");
			
		}
		wait 1;
	}
}

_chopper_set_team()
{
	if(self.model == "vehicle_mi24p_hind_desert")
	{
		self.team = "axis";
	}
	
	if(self.model == "vehicle_cobra_helicopter_fly")
	{
		self.team = "allies";
	}
}

_get_all_choppers(){
	level endon ( "disconnect" );
	level endon( "intermission" );
	level endon( "game_ended" );
	
	//cl("33_fire_on_enemies");

	for(;;){
		choppers = GetEntArray( "script_vehicle", "classname" );
		level.choppers = choppers;
		
		//models = GetEntArray( "vehicle_mi24p_hind_desert", "targetname" );
		level.choppersAxis = GetEntArray( "vehicle_mi24p_hind_desert", "model" );
		level.choppersAllies = GetEntArray( "vehicle_cobra_helicopter_fly", "model" );
				
		if(isDefined(level.choppersAxis)){ cl("level.choppersAxis.size:"+level.choppersAxis.size); }
		if(isDefined(level.choppersAllies)){ cl("level.choppersAllies.size:"+level.choppersAllies.size); }
		
		if(isDefined(choppers))
		{
			for(i=0;i<choppers.size;i++)
			{ 	
				if(isDefined(choppers[i].model) && (choppers[i].model == "vehicle_cobra_helicopter_fly" || choppers[i].model == "vehicle_mi24p_hind_desert")){
					choppers[i] _chopper_set_team();
					choppers[i] thread _chopper_damage_monitor();
					choppers[i] thread _chopper_killed_monitor();
					choppers[i] thread _chopper_targets();
				}
			}
		//cl("models.size:"+models.size);
		//cl("choppers.size:"+choppers.size);
		}
		
		wait 1;	
	}
}

_chopper_targets()
{
	self endon( "death" );
	
	if(isDefined(self.isActive)){ return; }
	self.isActive = true;
		
	//choppers[i].maxhealth=100;
	//choppers[i].heli_armor=100;
	//choppers[i] settargetyaw(choppers[i].angles[1]+90);
	while(1)
	{
		closest = 2147483647;
		self.hasTarget=undefined;
		
		for(j=0;j<level.choppers.size;j++)
		{ 
			if(level.choppers[j] == self){ continue; }
			if(self.team != level.choppers[j].team)
			{
				dist = distance(self.origin, level.choppers[j].origin);
				vis = self SightConeTrace(level.choppers[j].origin, self);
				
				if(dist < closest && vis > 0){ 
					closest = dist; 
					self.hasTarget = level.choppers[j];
					//self.primaryTarget = choppers[j].hasTarget;
					//self.secondaryTarget = choppers[j].hasTarget;
				}
			}
		}
		
		if(!isDefined(self.primaryTarget))
		{
			players = GetEntArray( "player", "classname" );
			closest = 2147483647;
			for(j=0;j<players.size;j++)
			{
				if(players[j].team != self.team && players[j] != self.owner)
				{
					dist = distance( self.origin, players[j].origin );
					vis = self SightConeTrace(players[j] getEye(), self);
					if(dist < closest && vis > 0)
					{ 
						closest = dist; 
						self.hasTarget = players[j];
					}
				}
			}
		}
			
		while(isDefined(self.hasTarget))
		{
			vis = self SightConeTrace(self.origin, self.hasTarget);
			if(vis == 0)
			{ 
				self.hasTarget=undefined; break; 
			}

			self SetLookAtEnt(self.hasTarget);
			self SetTurretTargetVec(self.hasTarget.origin);
			self thread _fire_bullets_loop();
			self thread _fire_missile_loop();
			wait 1;
		}
		
		wait 1;
	}
}

_chopper_damage_monitor(){
	self endon( "death" );
	//self endon( "crashing" );
	//self endon( "leaving" );
	
	if(isDefined(self.isMonitored)){ return; }
	self.isMonitored = true;
		
	for(;;)
	{
		self waittill( "damage", damage, attacker, direction_vec, P, type );
		self.hasTarget = attacker;
		self.primaryTarget = self.hasTarget;
		//cl("damaged by " + attacker.name);
		wait 0.1;
	}
}

_chopper_killed_monitor()
{
	level endon("disconnect");
	
	//if(!isDefined(chopper)){ return; }
	
	if(isDefined(self.isMonitoredOnBeingKilled)){ return; }
	self.isMonitoredOnBeingKilled = true;
	
	if(!isDefined(self.team)){ return; }
	
	team = self.team;
	
	level.aliveCount[team] += 1;
		
	self waittill( "crashing" );
	
	level.aliveCount[team] -= 1;
		
	if(isDefined(self.attacker) && self.attacker.pers["team"] != self.team && isDefined(game["money"][self.attacker.name]))
	{
		bonus=2000;
		game["money"][self.attacker.name] += bonus; 
		self.attacker thread scripts\menus::_show_hint_msg("You got "+bonus+"$ for destroying a helicopter!",0,3,0,300,0,0,"left","middle",0,0,"default",1.6,1.6,(0,1,0),1,(0,1,0),0.5,1,undefined,undefined);
	}
	
	//self.hasTarget = attacker;
	//self.primaryTarget = self.hasTarget;
	//cl("33" + team + " chopper has been destroyed!");
}

_fire_bullets_loop(){
	self endon ( "death" );
	level endon( "intermission" );
	level endon( "game_ended" );
	
	if(isDefined(self.isFiringBullets)){ return; }
	
	self.isFiringBullets = true;
	
	wait randomIntRange(5,7);
	
	for(i=0;i<60;i++)
	{
		self setVehWeapon( "cobra_20mm_mp" );
		self fireWeapon( "tag_flash" );
		wait 0.1;
	}
	
	self.isFiringBullets = undefined;
}

_fire_missile_loop(){
	self endon ( "death" );
	level endon( "intermission" );
	level endon( "game_ended" );
	
	if(isDefined(self.isFiringMissiles)){ return; }

	//level.chopper setgoalyaw (level.chopper.angles[0]+40);
	//target.attractor = Missile_CreateAttractorEnt( target, 10000, 6000 );;
	
	self.isFiringMissiles = true;
	wait 1;
	for(i=0;i<5;i++)
	{
		if (isDefined(self) && isDefined(self.owner))
		{
			self _fire_missile( "ffar", 1, self.primaryTarget, self.owner.pers["team"] ); wait 0.3;
		}
	}
	
	wait randomIntRange(10,15);
	self.isFiringMissiles = undefined;
}

_fire_missile( sMissileType, iShots, eTarget, team ){
	if (!isDefined(iShots))	{ iShots = 1; }
	assert( self.health > 0 );
	
	weaponName = "cobra_FFAR_mp";
	weaponShootTime = undefined;
	defaultWeapon = "cobra_20mm_mp";
	tags = [];
	if (!isDefined(team)) { team = "allies"; }
	switch( sMissileType )
	{
		case "ffar":
			if ( team == "allies" )
				weaponName = "cobra_FFAR_mp";
			else
				weaponName = "hind_FFAR_mp";
				
			tags[ 0 ] = "tag_store_r_2";
			break;
		default:
			assertMsg( "Invalid missile type specified. Must be ffar" );
			break;
	}
	assert( isdefined( weaponName ) );
	assert( tags.size > 0 );
	
	weaponShootTime = weaponfiretime( weaponName );
	assert( isdefined( weaponShootTime ) );
	
	self setVehWeapon( weaponName );
	nextMissileTag = -1;
	for( i = 0 ; i < iShots ; i++ ) // I don't believe iShots > 1 is properly supported; we don't set the weapon each time
	{
		nextMissileTag++;
		if ( nextMissileTag >= tags.size )
			nextMissileTag = 0;
		
		//self playSound("at4_df4_fire");
		
		if ( isdefined( eTarget ) )
		{
			eMissile = self fireWeapon( tags[ nextMissileTag ], eTarget );
		}
		else
		{
			eMissile = self fireWeapon( tags[ nextMissileTag ] );
		}
		self.lastRocketFireTime = gettime();
		
		if ( i < iShots - 1 )
			wait weaponShootTime;
	}
}
