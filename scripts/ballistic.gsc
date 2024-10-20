//

_proj_m40a3_weap()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	level endon( "game_ended" );
	
	self.m40a3clip = 5;
	self.m40a3stock = 40;
	
	for(;;){
		self waittill("weapon_fired");
		weapon = self GetCurrentWeapon();
		
		if(isSubStr(weapon, "m40a3"))
		{
			self SetWeaponAmmoClip(weapon, 0);
			//self SetWeaponAmmoStock( "m16", 300 );
			self AllowAds(false);
			
			self.m40a3clip -= 1;
			if(self.m40a3clip <= 0)
			{	
				//self SetWeaponAmmoClip(weapon, WeaponClipSize(weapon));
				self DisableWeapons();
				wait 1;
				self playSound("weap_m40a3sniper_start_plr");
				wait 2;
				self playSound("weap_m40a3sniper_loop_plr");
				wait 1;
				self playSound("weap_m40a3sniper_end_plr");
				wait 1;
				self EnableWeapons();
				self.m40a3clip = 5;
				self.m40a3stock -= 5;
				self SetWeaponAmmoStock(weapon, self.m40a3stock);
			}
			else
			{
				wait 1.5;
				//self SetWeaponAmmoClip(weapon, WeaponClipSize(weapon));
			}
		}
	}
}

_proj_tac330_weap()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	level endon( "game_ended" );
	
	self.m40a3clip = 5;
	self.m40a3stock = 40;
	
	for(;;){
		self waittill("weapon_fired");
		weapon = self GetCurrentWeapon();
		
		if(isSubStr(weapon, "ak47_acog") || isSubStr(weapon, "ak47_silencer"))
		{
			self SetWeaponAmmoClip(weapon, 0);
			//self SetWeaponAmmoStock( "m16", 300 );
			self AllowAds(false);
			
			self.m40a3clip -= 1;
			if(self.m40a3clip <= 0)
			{	
				//self SetWeaponAmmoClip(weapon, WeaponClipSize(weapon));
				self DisableWeapons();
				wait 1;
				//self playSound("weap_m40a3sniper_start_plr");
				wait 2;
				//self playSound("weap_m40a3sniper_loop_plr");
				wait 1;
				//self playSound("weap_m40a3sniper_end_plr");
				wait 1;
				self EnableWeapons();
				self.m40a3clip = 5;
				self.m40a3stock -= 5;
				self SetWeaponAmmoStock(weapon, self.m40a3stock);
			}
			else
			{
				wait 1.5;
				//self SetWeaponAmmoClip(weapon, WeaponClipSize(weapon));
			}
		}
	}
}



_ballistic_start(startPosition, destination, angles)
{
	if(!isDefined(level.ballisticBullet))
	{
		level.ballisticBullet = [];
		level.ballisticBulletCounter = 0;
	}
	else
	{
	
		level.ballisticBullet[ level.ballisticBulletCounter ] = spawn( "script_model", startPosition );
		level.ballisticBullet[ level.ballisticBulletCounter ] setModel( "projectile_hellfire_missile" );
		level.ballisticBullet[ level.ballisticBulletCounter ].angles = angles;
		
		level.ballisticBullet[ level.ballisticBulletCounter ] MoveTo( destination, 5, 0, 0);
		level.ballisticBullet RotatePitch( -5, 0.26, 0.15, 0.1 );
		//level.ballisticBullet[ level.ballisticBulletCounter ] MoveX( 15, randomFloatRange(1,2), randomFloatRange(0,0.5), randomFloatRange(0,0.5) );
		//level.ballisticBullet[ level.ballisticBulletCounter ] MoveY( 15, randomFloatRange(1,2), randomFloatRange(0,0.5), randomFloatRange(0,0.5) );
		//level.ballisticBullet[ level.ballisticBulletCounter ] MoveZ( 15, randomFloatRange(1,2), randomFloatRange(0,0.5), randomFloatRange(0,0.5) );
		//level.ballisticBullet[ level.ballisticBulletCounter ] MoveGravity( startPosition, 4);
		//level.ballisticBullet[ level.ballisticBullet.size ].fireTime = getTime();
		
		//thread roundThink( level.ballisticBullet[ level.ballisticBullet.size ] );	
		level.ballisticBulletCounter++;
	}
		
}

roundThink( ent )
{
	self endon( "disconnect" );
	
	while( isDefined( ent ) )
	{
		start = ent.origin;
		
		if( getTime() - ent.fireTime > 1900 && !isDefined( ent.incomingSound ) )
		{
			ent.incomingSound = true;
			ent playSound( "fast_artillery_round" );
		}
		
		if( getTime() - ent.fireTime > 500 )
		{
			vector = anglesToForward( ent.angles );
			forward = ent.origin + ( vector[ 0 ] * 100, vector[ 1 ] * 100, vector[ 2 ] * 100 );
			collision = bulletTrace( ent.origin, forward, false, ent );
			
			if( collision[ "surfacetype" ] != "default" && collision[ "fraction" ] < 1 ) 
			{
				playFx( level.hardEffects[ "artilleryExp" ], collision[ "position" ]  );
				ents = maps\mp\gametypes\_weapons::getDamageableents( collision[ "position" ], 540 );
			
				for( i = 0; i < ents.size; i++ )
				{
					if ( !ents[ i ].isPlayer || isAlive( ents[ i ].entity ) )
					{
						if( !isDefined( ents[ i ] ) )
							continue;
							
						if( isPlayer( ents[ i ].entity ) )
							ents[ i ].entity.sWeaponForKillcam = "artillery";

						ents[ i ] maps\mp\gametypes\_weapons::damageEnt(
							ent, 
							self, 
							1000, 
							"MOD_PROJECTILE_SPLASH", 
							"artillery_mp", 
							collision[ "position" ], 
							vectornormalize( collision[ "position" ] - ents[ i ].entity.origin ) 
						);
					}
				}
				
				//earthquake( 3.4, 0.7, collision[ "position" ], 580 );
				//earthquake( 0.1, 3.7, collision[ "position" ], 6800 );
				maps\mp\gametypes\_hardpoints::playSoundinSpace( "exp_suitcase_bomb_main", collision[ "position" ] );
				
				if( isDefined( ent ) )
					ent delete();
				
				break;
			}
		}
		
		wait .05;
		
		if( !isDefined( ent ) )
			break;
		
		end = ent.origin;
		ent.angles = vectorToAngles( end - start );
	}
}

