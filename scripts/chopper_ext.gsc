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

_dev_chopper_test()
{
	self endon ( "disconnect" );
	self endon ( "intermission" );
	level endon ( "game_ended" );
	
	if(self.isbot){ return; }
	
	cl("_dev_chopper_test");
	
	for(;;)
	{
		while
		(
			!self LeanLeftButtonPressed() 
			&& !self LeanRightButtonPressed()
		)
		{ 
			wait 0.05; 
		}
		
		team = "none";
		random_path = randomint( level.heli_paths[0].size );
		startnode = level.heli_paths[0][random_path];
		
		if(self LeanLeftButtonPressed())
		{ 
			team = "axis"; 
		}
		
		if(self LeanRightButtonPressed())
		{ 
			team = "allies";
		}
				
		thread maps\mp\_helicopter::heli_think(self, startnode, team); 
		cl("adding " + team + " chopper");
		
		while
		(
			self LeanLeftButtonPressed() 
			|| self LeanRightButtonPressed()
		)
		{ 
			wait 0.05; 
		}
		
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

_get_all_choppers()
{
	level endon ( "disconnect" );
	level endon( "intermission" );
	level endon( "game_ended" );

	for(;;)
	{
		choppers = GetEntArray( "script_vehicle", "classname" );
		level.choppers = choppers;
		
		//models = GetEntArray( "vehicle_mi24p_hind_desert", "targetname" );
		level.choppersAxis = GetEntArray( "vehicle_mi24p_hind_desert", "model" );
		level.choppersAllies = GetEntArray( "vehicle_cobra_helicopter_fly", "model" );
				
		if(isDefined(level.choppersAxis))
		{ 
			cl("level.choppersAxis.size:" + level.choppersAxis.size);
		}
		if(isDefined(level.choppersAllies))
		{ 
			cl("level.choppersAllies.size:"+level.choppersAllies.size);
		}
		
		if(isDefined(choppers))
		{
			for(i=0;i<choppers.size;i++)
			{ 	
				if
				(
					isDefined(choppers[i].model) 
					&& (choppers[i].model == "vehicle_cobra_helicopter_fly" 
					|| choppers[i].model == "vehicle_mi24p_hind_desert")
				)
				{
					choppers[i] _chopper_set_team();
					choppers[i] thread _chopper_damage_monitor();
					choppers[i] thread _chopper_killed_monitor();
					choppers[i] thread _chopper_targets();
				}
			}
			
			//cl("level.choppers.size:" + level.choppers.size);
		}
		
		wait 1;	
	}
}

_chopper_targets()
{
	self endon("death");
	
	if(isDefined(self.isActive)){ return; }
	
	self.isActive = true;
	self.maxhealth = 1000;
	self.heli_armor = 1000;
	//self settargetyaw(choppers[i].angles[1]+90);
	for(;;)
	{
		closest = 2147483647;
		self.hasTarget = undefined;
		
		for(j = 0; j < level.choppers.size; j++)
		{ 
			if(level.choppers[j] == self){ continue; }
			if(!isDefined(level.choppers[j])){ continue; }
			if(!isDefined(level.choppers[j].origin)){ continue; }
			
			if(self.team != level.choppers[j].team)
			{
				dist = distance(self.origin, level.choppers[j].origin);
				btp = bulletTracePassed(self.origin, level.choppers[j].origin, false, self);
				
				if(dist < closest && btp){ 
					closest = dist; 
					self.hasTarget = level.choppers[j];
					//self.primaryTarget = level.choppers[j].hasTarget;
					//self.secondaryTarget = level.choppers[j].hasTarget;
				}
			}
		}
		
		if(!isDefined(self.primaryTarget))
		{
			players = GetEntArray( "player", "classname" );
			closest = 2147483647;
			for(j=0;j<players.size;j++)
			{
				if(isAlive(players[j]) && players[j].team != self.team && players[j] != self.owner)
				{
					dist = distance(self.origin, players[j].origin );
					btp = bulletTracePassed(self.origin, players[j] getEye(), false, self);
					
					if(dist < closest && btp)
					{ 
						closest = dist; 
						self.hasTarget = players[j];
					}
				}
			}
		}
			
		while(isDefined(self.hasTarget))
		{
			vd = scripts\main::_dp(self.origin, self.hasTarget.origin, self.angles);
			//vis = self SightConeTrace(self.origin, self.hasTarget);
			if(isDefined(vd) && vd < 0.80)
			{ 
				self.hasTarget = undefined; 
				break; 
			}

			self SetLookAtEnt(self.hasTarget);
			self SetTurretTargetVec(self.hasTarget.origin);
			self thread _fire_bullets();
			wait randomFloatRange(3, 5);
			self thread _fire_missiles();
			wait 1;
		}
		
		wait 1;
	}
}

_chopper_damage_monitor()
{
	self endon("death");
	//self endon("crashing");
	//self endon("leaving");
	
	if(isDefined(self.isMonitored)){ return; }
	self.isMonitored = true;
		
	for(;;)
	{
		self waittill("damage", damage, attacker, direction_vec, P, type );
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
	
	self thread _chopper_crashing();
	
	level.aliveCount[team] -= 1;
		
	if
	(
		isDefined(self.attacker) 
		&& isDefined(self.attacker.name) 
		&& isDefined(game["money"][self.attacker.name]) 
		&& self.attacker.pers["team"] != self.team
	)
	{
		bonus=2000;
		self.attacker.money["acc"] += bonus; 
		self.attacker thread scripts\menus::_show_hint_msg("You got "+bonus+"$ for destroying a helicopter!",0,3,0,300,0,0,"left","middle",0,0,"default",1.6,1.6,(0,1,0),1,(0,1,0),0.5,1,undefined,undefined);
	}
}

_fire_bullets()
{
	self endon("death");
	level endon("intermission");
	level endon("game_ended");
	
	if(isDefined(self.isFiringBullets)){ return; }
	
	self.isFiringBullets = true;
		
	for(i = 0; i < 60; i++)
	{
		self setVehWeapon("cobra_20mm_mp");
		self fireWeapon("tag_flash");
		wait 0.1;
	}
	
	wait randomIntRange(15, 20);
	
	self.isFiringBullets = undefined;
}

_fire_missiles()
{
	self endon("death");
	level endon("intermission");
	level endon("game_ended");
	
	if(isDefined(self.isFiringMissiles)){ return; }

	//level.chopper setgoalyaw (level.chopper.angles[0]+40);
	//target.attractor = Missile_CreateAttractorEnt( target, 10000, 6000 );;
	
	self.isFiringMissiles = true;
	//wait 1;
	for(i = 0; i < 5; i++)
	{
		if (isDefined(self) && isDefined(self.owner))
		{
			self _fire_missile("ffar", 1, self.primaryTarget, self.owner.pers["team"]); wait 0.3;
		}
	}
	
	wait randomIntRange(30, 40);
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

_chopper_crashing()
{
	self endon ( "death" );
	level endon( "intermission" );
	level endon( "game_ended" );
		
	//wait 0.5;
		
	self thread _chopper_crash_fly(_chopper_crash_site());
	self thread _chopper_crash_land();
	
	if(randomIntRange(0,5)>2)
	{ 
		wait 0.3; 
		self thread maps\mp\_helicopter::heli_explode();
		return; 
	}
}

_chopper_crash_fly(pos)
{
	self endon ( "death" );
	
	// only one thread instance allowed
	//self notify( "flying");
	//self endon( "flying" );
	
	//self.reached_dest = false;
	self thread maps\mp\_helicopter::heli_reset();
	
	//self setgoalyaw(self.angles[1]+randomFloatRange(-100,100));
	self setvehgoalpos((pos), 0);

}

_chopper_crash_site()
{
		a = self.angles;
		sp = self.origin;
		affd = sp + anglesToForward((a[0]+40, a[1], a[2]))*9999;
		btfd = bulletTrace(sp, affd, true, self);
		posfd = btfd["position"];
		
		return posfd;
}

_chopper_crash_land()
{
	while(isDefined(self))
	{
		a = self.angles;
		sp = self.origin;
		aff = sp + anglesToForward((a[0], a[1], a[2]))*256;
		affd = sp + anglesToForward((a[0]+40, a[1], a[2]))*256;
		btf = bulletTrace(sp, aff, true, self);
		btfd = bulletTrace(sp, affd, true, self);
		posf = btf["position"];
		posfd = btfd["position"];
		distf=distance(sp,posf);
		distfd=distance(sp,posfd);
		
		//cl("distf: "+distf);
		//cl("distfd: "+distfd);
	
		if(distf<99 || distfd<99)
		{
			self thread maps\mp\_helicopter::heli_explode();
		}
		
		wait 0.05;
	}
}