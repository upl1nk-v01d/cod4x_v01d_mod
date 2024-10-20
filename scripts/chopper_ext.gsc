#include scripts\cl;
init()
{
	//if (getdvarint("developer")<1){ return; }
	//exec("v01d_dev 1");

	precacheShader("compass_waypoint_defend");
	precacheShader("compass_waypoint_target");
	precacheShader("compass_waypoint_bomb");
	
	setDvar( "scr_heli_missile_max", 0 );
	
	//level thread _add_choppers();
	level thread _fire_on_enemies();
	
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
	self endon ( "game_ended" );
	self endon ( "intermission" );
	
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
	self endon( "game_ended" );
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

_fire_on_enemies(){
	level endon ( "disconnect" );
	level endon( "intermission" );
	level endon( "game_ended" );
	
	//cl("33_fire_on_enemies");

	for(;;){
		choppers = GetEntArray( "script_vehicle", "classname" );
		players = GetEntArray( "player", "classname" );
		//models = GetEntArray( "vehicle_mi24p_hind_desert", "targetname" );
		axis_choppers = GetEntArray( "vehicle_mi24p_hind_desert", "model" );
		allies_choppers = GetEntArray( "vehicle_cobra_helicopter_fly", "model" );
		if(isDefined(axis_choppers)){ cl("axis_choppers.size:"+axis_choppers.size); }
		if(isDefined(allies_choppers)){ cl("allies_choppers.size:"+allies_choppers.size); }
		if(isDefined(choppers)){
			for(i=0;i<choppers.size;i++){ 
				if(isDefined(choppers[i].model) && (choppers[i].model == "vehicle_cobra_helicopter_fly" || choppers[i].model == "vehicle_mi24p_hind_desert")){
					choppers[i] thread _chopper_damage_monitor();
					closest = 2147483647;
					choppers[i].hasTarget=undefined;
					//choppers[i].maxhealth=100;
					//choppers[i].heli_armor=100;
					//choppers[i] settargetyaw(choppers[i].angles[1]+90);
					for(j=0;j<choppers.size;j++){ 
						if(!isDefined(choppers[j])){ continue; }
						if(choppers[i].team != choppers[j].team && choppers[i] != choppers[j]){
							dist = distance( choppers[i].origin, choppers[j].origin );
							if(dist<closest){ 
								closest = dist; 
								choppers[i].hasTarget=choppers[j];
								choppers[i].primaryTarget = choppers[i].hasTarget;
								choppers[i].secondaryTarget = choppers[i].hasTarget;
								//target=choppers[i].hasTarget;
								//choppers[i] setVehWeapon( "cobra_20mm_mp" );
								//choppers[i] fireWeapon( "tag_flash" );
								//choppers[i] SetLookAtEnt(choppers[j]);
								//choppers[i] thread _fire_missile_loop();
								//vis = choppers[i] SightConeTrace(choppers[j].origin, choppers[i]);
								//cl("11"+vis);
							}
						}
					}
					if(!isDefined(choppers[i].primaryTarget)){
						closest = 2147483647;
						for(j=0;j<players.size;j++){ 
							if(!isDefined(players[j])){ continue; }
							if(players[j].team != choppers[i].team){
								dist = distance( choppers[i].origin, players[j].origin );
								if(dist<closest){ 
									closest = dist; 
									choppers[i].hasTarget = players[j];
									choppers[i].primaryTarget = choppers[i].hasTarget;
									choppers[i].secondaryTarget = choppers[i].hasTarget;
									//choppers[i] SetLookAtEnt(players[j]);
									//choppers[i] setVehWeapon( "cobra_20mm_mp" );
									//choppers[i] fireWeapon( "tag_flash" );
									if(isAlive(players[j]) && players[j].isbot){ 
										players[j].bot.script_target=choppers[i]; 
									}
								}
							}
						}
					}
					//cl(choppers[i].origin);
					if(!isDefined(choppers[i].hasTarget)){ continue; }
					if(!isDefined(choppers[i].hasTarget.origin)){ continue; }
					//vis = choppers[i] SightConeTrace(choppers[i].hasTarget.origin, choppers[i]);
					//if(!vis){ choppers[i].hasTarget=undefined; }
					//while(isDefined(choppers[i].hasTarget) && isAlive(choppers[i].hasTarget)){
					//for(j=0;j<30;j++){
						if(!isDefined(choppers[i].hasTarget)){ break; }
						if(!isDefined(choppers[i].hasTarget.origin)){ break; }
						choppers[i] SetLookAtEnt(choppers[i].hasTarget);
						choppers[i] SetTurretTargetVec(choppers[i].hasTarget.origin);
						choppers[i] thread _fire_bullets_loop();
						choppers[i] thread _fire_missile_loop();
						vis = choppers[i] SightConeTrace(choppers[i].hasTarget.origin, choppers[i]);
						if(!vis){ choppers[i].hasTarget=undefined; break; }
						wait 0.1;
					//}
					choppers[i].hasTarget=undefined;
				}
			}
		//cl("models.size:"+models.size);
		//cl("choppers.size:"+choppers.size);
		}
		wait 0.1;	
	}
}

_chopper_damage_monitor(){
	self endon( "death" );
	//self endon( "crashing" );
	//self endon( "leaving" );
	
	if(isDefined(self.isMonitored)){ return; }
	self.isMonitored = true;
	
	for(;;){
		self waittill( "damage", damage, attacker, direction_vec, P, type );
		self.hasTarget = attacker;
		self.primaryTarget = self.hasTarget;
		//cl("damaged by " + attacker.name);
		wait 0.1;
	}
}

_fire_bullets_loop(){
	self endon ( "death" );
	level endon( "intermission" );
	level endon( "game_ended" );
	
	if(isDefined(self.isFiringBullets)){ return; }
	
	self.isFiringBullets = true;
	wait 1;
	for(i=0;i<30;i++){
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
	for(i=0;i<5;i++){
		if (isDefined(self)){
			self _fire_missile( "ffar", 1, self.primaryTarget, self.owner.pers["team"] ); wait 0.3;
		}
	}
	wait (randomIntRange(10,15));
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
