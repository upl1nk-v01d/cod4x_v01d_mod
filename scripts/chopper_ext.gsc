#include scripts\cl;
init()
{
	//if (getdvarint("developer")<1){ return; }

	precacheShader("compass_waypoint_defend");
	precacheShader("compass_waypoint_target");
	precacheShader("compass_waypoint_bomb");
	
	setDvar( "scr_heli_missile_max", 0 );
	
	level thread _fire_missile_loop();
	level thread _fire_on_enemies();
	
	for(;;)
    {
		level waittill("connected", player);
		//player thread _give_chopper_hardpoint();
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
	
		self waittill("spawned_player");
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
	
	target=undefined;

	for(;;){
		closest = 2147483647; dist=0;
		choppers = GetEntArray( "script_vehicle", "classname" );
		players = GetEntArray( "player", "classname" );
		//models = GetEntArray( "vehicle_mi24p_hind_desert", "targetname" );
		axis_choppers = GetEntArray( "vehicle_mi24p_hind_desert", "model" );
		allies_choppers = GetEntArray( "vehicle_cobra_helicopter_fly", "model" );
		if(isDefined(axis_choppers)){ cl("axis_choppers.size:"+axis_choppers.size); }
		if(isDefined(allies_choppers)){ cl("allies_choppers.size:"+allies_choppers.size); }
		if(isDefined(choppers)){
			for(i=0;i<choppers.size;i++){ 
				//choppers[i].maxhealth=100;
				//choppers[i].heli_armor=100;
				//choppers[i] settargetyaw(choppers[i].angles[1]+90);
				for(j=0;j<choppers.size;j++){ 
					if(choppers[i] != choppers[j] && choppers[i].team != choppers[j].team ){
						dist = distance( choppers[i].origin, choppers[j].origin );
						if(dist<closest){ 
							closest = dist; 
							choppers[i].primaryTarget = choppers[j];
							choppers[i].secondaryTarget = choppers[j];
							choppers[i].hasTarget=choppers[j];
							target=choppers[i].hasTarget;
							choppers[i] setVehWeapon( "cobra_20mm_mp" );
							choppers[i] fireWeapon( "tag_flash" );
						}
					}
				}
				
				if(isDefined(choppers[i].hasTarget) && isPlayer(choppers[i].hasTarget)){
					player=choppers[i].hasTarget;
					if(isAlive(player) && player.isbot){ 
						player.bot.script_target=choppers[i]; 
					}
					cl("11"+player.name);
					//choppers[i] setgoalyaw (target.angles[1]);
				}
				
				/*if(!isDefined(target)){
					for(i=0;i<players.size;i++){ 
						dist = distance( choppers[i].origin, players[i].origin );
						if(choppers[i].team != players[i].team){
							if(dist<closest){ 
								closest = dist; target = players[i];
								choppers[i].primaryTarget = target;
								choppers[i].secondaryTarget = target;
								if(isPlayer(target) && isAlive(target) && target.isbot){ target.bot.script_target=choppers[i]; }
								//choppers[i] setgoalyaw (choppers[i].angles[0]+40);
								//cl("chopper.primaryTarget:"+choppers[i].primaryTarget.name);
								//cl("chopper.secondaryTarget:"+choppers[i].secondaryTarget.name);
							}
						}
					}
				}*/
			}
		}
		if(isDefined(target)){
			//cl("target.maxhealth:"+target.maxhealth);
		}
		wait 0.1;
		
		//cl("models.size:"+models.size);
		//cl("choppers.size:"+choppers.size);
				
	}
}

_fire_missile_loop(target,team){
	level endon ( "disconnect" );
	level endon( "intermission" );
	level endon( "game_ended" );

	for(;;){
		while(isDefined(level.chopper)){
			level.chopper setgoalyaw (level.chopper.angles[0]+40);
			//target.attractor = Missile_CreateAttractorEnt( target, 10000, 6000 );;
			wait 3;
			for(i=0;i<5;i++){
				if (isDefined(level.chopper)){
					level.chopper _fire_missile( "ffar", 1, target, team ); wait 0.3;
				}
			}
			wait (randomIntRange(10,15));
		}
		wait 5;
	}
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
