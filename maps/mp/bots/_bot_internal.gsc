#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\bots\_bot_utility;
#include scripts\cl;


/*
	When a bot is added (once ever) to the game (before connected).
	We init all the persistent variables here.
*/
added()
{
	self endon( "disconnect" );

	self.pers["bots"] = [];

	self.pers["bots"]["skill"] = [];
	self.pers["bots"]["skill"]["base"] = 7; // a base knownledge of the bot
	self.pers["bots"]["skill"]["aim_time"] = 0.05; // how long it takes for a bot to aim to a location
	self.pers["bots"]["skill"]["init_react_time"] = 0; // the reaction time of the bot for inital targets
	self.pers["bots"]["skill"]["reaction_time"] = 0; // reaction time for the bots of reoccuring targets
	self.pers["bots"]["skill"]["no_trace_ads_time"] = 2500; // how long a bot ads's when they cant see the target
	self.pers["bots"]["skill"]["no_trace_look_time"] = 10000; // how long a bot will look at a target's last position
	self.pers["bots"]["skill"]["remember_time"] = 25000; // how long a bot will remember a target before forgetting about it when they cant see the target
	self.pers["bots"]["skill"]["fov"] = -1; // the fov of the bot, -1 being 360, 1 being 0
	self.pers["bots"]["skill"]["dist_max"] = 100000 * 2; // the longest distance a bot will target
	self.pers["bots"]["skill"]["dist_start"] = 100000; // the start distance before bot's target abilitys diminish
	self.pers["bots"]["skill"]["spawn_time"] = 0; // how long a bot waits after spawning before targeting, etc
	self.pers["bots"]["skill"]["help_dist"] = 10000; // how far a bot has awareness
	self.pers["bots"]["skill"]["semi_time"] = 0.05; // how fast a bot shoots semiauto
	self.pers["bots"]["skill"]["shoot_after_time"] = 1; // how long a bot shoots after target dies/cant be seen
	self.pers["bots"]["skill"]["aim_offset_time"] = 1; // how long a bot correct's their aim after targeting
	self.pers["bots"]["skill"]["aim_offset_amount"] = 1; // how far a bot's incorrect aim is
	self.pers["bots"]["skill"]["bone_update_interval"] = 0.05; // how often a bot changes their bone target
	self.pers["bots"]["skill"]["bones"] = "j_head"; // a list of comma seperated bones the bot will aim at
	self.pers["bots"]["skill"]["ads_fov_multi"] = 0.5; // a factor of how much ads to reduce when adsing
	self.pers["bots"]["skill"]["ads_aimspeed_multi"] = 0.5; // a factor of how much more aimspeed delay to add

	self.pers["bots"]["behavior"] = [];
	self.pers["bots"]["behavior"]["strafe"] = 50; // percentage of how often the bot strafes a target
	self.pers["bots"]["behavior"]["nade"] = 50; // percentage of how often the bot will grenade
	self.pers["bots"]["behavior"]["sprint"] = 50; // percentage of how often the bot will sprint
	self.pers["bots"]["behavior"]["camp"] = 50; // percentage of how often the bot will camp
	self.pers["bots"]["behavior"]["follow"] = 50; // percentage of how often the bot will follow
	self.pers["bots"]["behavior"]["crouch"] = 10; // percentage of how often the bot will crouch
	self.pers["bots"]["behavior"]["switch"] = 1; // percentage of how often the bot will switch weapons
	self.pers["bots"]["behavior"]["class"] = 1; // percentage of how often the bot will change classes
	self.pers["bots"]["behavior"]["jump"] = 100; // percentage of how often the bot will jumpshot and dropshot

	self.pers["bots"]["behavior"]["quickscope"] = false; // is a quickscoper
	self.pers["bots"]["behavior"]["initswitch"] = 10; // percentage of how often the bot will switch weapons on spawn
}

/*
	When a bot connects to the game.
	This is called when a bot is added and when multiround gamemode starts.
*/
connected()
{
	self endon( "disconnect" );

	self.bot = spawnStruct();
	self.bot_radar = false;
	self resetBotVars();

	//force respawn works already, done at cod4x server c code.
	self thread onPlayerSpawned();
	self thread bot_skip_killcam();
	self thread onUAVUpdate();
}

/*
	The thread for when the UAV gets updated.
*/
onUAVUpdate()
{
	self endon( "disconnect" );

	for ( ;; )
	{
		self waittill( "radar_timer_kill" );
		self thread doUAVUpdate();
	}
}

/*
	We tell that bot has a UAV.
*/
doUAVUpdate()
{
	self endon( "disconnect" );
	self endon( "radar_timer_kill" );

	self.bot_radar = true;//wtf happened to hasRadar? its bugging out, something other than script is touching it

	wait level.radarViewTime;

	self.bot_radar = false;
}

/*
	The callback hook for when the bot gets killed.
*/
onKilled( eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration )
{
}

/*
	The callback hook when the bot gets damaged.
*/
onDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset )
{
}

/*
	We clear all of the script variables and other stuff for the bots.
*/
resetBotVars()
{
	self.bot.script_target = undefined;
	self.bot.script_target_offset = undefined;
	self.bot.target = undefined;
	self.bot.targets = [];
	self.bot.target_this_frame = undefined;
	self.bot.after_target = undefined;
	self.bot.after_target_pos = undefined;

	self.bot.script_aimpos = undefined;

	self.bot.script_goal = undefined;
	self.bot.script_goal_dist = 0.0;

	self.bot.next_wp = -1;
	self.bot.second_next_wp = -1;
	self.bot.towards_goal = undefined;
	self.bot.astar = [];
	self.bot.stop_move = false;
	self.bot.greedy_path = false;
	self.bot.climbing = false;
	self.bot.last_next_wp = -1;
	self.bot.last_second_next_wp = -1;

	self.bot.isfrozen = false;
	self.bot.sprintendtime = -1;
	self.bot.isreloading = false;
	self.bot.issprinting = false;
	self.bot.isfragging = false;
	self.bot.issmoking = false;
	self.bot.isfraggingafter = false;
	self.bot.issmokingafter = false;
	self.bot.isknifing = false;
	self.bot.isknifingafter = false;

	self.bot.semi_time = false;
	self.bot.jump_time = undefined;
	self.bot.last_fire_time = -1;

	self.bot.is_cur_full_auto = false;
	self.bot.cur_weap_dist_multi = 1;
	self.bot.is_cur_sniper = false;

	self.bot.rand = randomInt( 100 );

	self botStop();
}

/*
	Bots will skip killcams here.
*/
bot_skip_killcam()
{
	level endon( "game_ended" );
	self endon( "disconnect" );

	for ( ;; )
	{
		wait 1;

		if ( isDefined( self.killcam ) )
		{
			self notify( "end_killcam" );
		}
	}
}

/*
	When the bot spawns.
*/
onPlayerSpawned()
{
	self endon( "disconnect" );

	for ( ;; )
	{
		self waittill( "spawned_player" );

		self resetBotVars();
		self thread onWeaponChange();
		self thread onLastStand();

		self thread reload_watch();
		self thread sprint_watch();

		self thread spawned();
	}
}

/*
	We wait for a time defined by the bot's difficulty and start all threads that control the bot.
*/
spawned()
{
	self endon( "disconnect" );
	self endon( "death" );

	wait self.pers["bots"]["skill"]["spawn_time"];

	self thread grenade_danger();
	self thread check_reload();
	self thread stance();
	self thread walk();
	self thread target();
	self thread updateBones();
	self thread aim();
	self thread watchHoldBreath();
	self thread onNewEnemy();
	self thread doBotMovement();
	self thread watchGrenadeFire();
	self thread watchPickupGun();

	self notify( "bot_spawned" );
}

/*
	watchPickupGun
*/
watchPickupGun()
{
	self endon( "disconnect" );
	self endon( "death" );

	for ( ;; )
	{
		wait 1;

		if ( self UseButtonPressed() )
			continue;

		weap = self GetCurrentWeapon();

		if ( weap != "none" && self GetAmmoCount( weap ) )
			continue;

		self thread use( 0.5 );
	}
}

/*
	Watches when the bot fires a grenade
*/
watchGrenadeFire()
{
	self endon( "disconnect" );
	self endon( "death" );

	for ( ;; )
	{
		self waittill( "grenade_fire", nade, weapname );

		if ( !isDefined( nade ) )
			continue;

		if ( weapname == "c4_mp" )
			self thread watchC4Thrown( nade );
	}
}

/*
	Watches the c4
*/
watchC4Thrown( c4 )
{
	self endon( "disconnect" );
	c4 endon( "death" );

	wait 0.5;

	for ( ;; )
	{
		wait 1 + randomInt( 50 ) * 0.05;

		shouldBreak = false;

		for ( i = 0; i < level.players.size; i++ )
		{
			player = level.players[i];

			if ( player == self )
				continue;

			if ( ( level.teamBased && self.team == player.team ) || player.sessionstate != "playing" || !isAlive( player ) )
				continue;

			if ( distanceSquared( c4.origin, player.origin ) > 200 * 200 )
				continue;

			if ( !bulletTracePassed( c4.origin, player.origin + ( 0, 0, 25 ), false, c4 ) )
				continue;

			shouldBreak = true;
		}

		if ( shouldBreak )
			break;
	}

	if ( self getCurrentWeapon() != "c4_mp" )
		self notify( "alt_detonate" );
	else
		self thread pressFire();
}

/*
	Bot moves towards the point
*/
doBotMovement_loop( data )
{
	angles = self GetPlayerAngles();

	// climb through windows
	if ( self isMantling() )
	{
		data.wasMantling = true;
		self crouch();
	}
	else if ( data.wasMantling )
	{
		data.wasMantling = false;
		self stand();
	}

	startPos = self.origin + ( 0, 0, 50 );
	startPosForward = startPos + anglesToForward( ( 0, angles[1], 0 ) ) * 25;
	bt = bulletTrace( startPos, startPosForward, false, self );

	if ( bt["fraction"] >= 1 )
	{
		// check if need to jump
		bt = bulletTrace( startPosForward, startPosForward - ( 0, 0, 40 ), false, self );

		if ( bt["fraction"] < 1 && bt["normal"][2] > 0.9 && data.i > 1.5 && !self isOnLadder() )
		{
			data.i = 0;
			self thread jump();
		}
	}
	// check if need to knife glass
	else if ( bt["surfacetype"] == "glass" )
	{
		if ( data.i > 1.5 )
		{
			data.i = 0;
			self thread knife();
		}
	}
	else
	{
		// check if need to crouch
		if ( bulletTracePassed( startPos - ( 0, 0, 25 ), startPosForward - ( 0, 0, 25 ), false, self ) && !self.bot.climbing )
			self crouch();
	}
}

/*
	Bot moves towards the point
*/
doBotMovement()
{
	self endon( "disconnect" );
	self endon( "death" );

	data = spawnStruct();
	data.wasMantling = false;

	for ( data.i = 0; true; data.i += 0.05 )
	{
		wait 0.05;

		self doBotMovement_loop( data );
	}
}

/*
	Sets the factor of distance for a weapon
*/
SetWeaponDistMulti( weap )
{
	if ( weap == "none" )
		return 1;

	switch ( weaponClass( weap ) )
	{
		case "rifle":
			return 0.9;

		case "smg":
			return 0.7;

		case "pistol":
			return 0.5;

		default:
			return 1;
	}
}

/*
	Is the weap a sniper
*/
IsWeapSniper( weap )
{
	if ( weap == "none" )
		return false;

	//if ( maps\mp\gametypes\_missions::getWeaponClass( weap ) != "weapon_sniper" )
	//if(isDefined(scripts\main::_classCheck(weap,"sniper")

	if (
		scripts\main::_classCheck(weap,level.classBoltSniper) 
		|| scripts\main::_classCheck(weap,level.classSniper)
	)
	{
		//cl(weap + " is sniper");
		return true;
	}
		
	return false;
}

/*
	The hold breath thread.
*/
watchHoldBreath()
{
	self endon( "disconnect" );
	self endon( "death" );

	for ( ;; )
	{
		wait 1;

		if ( self.bot.isfrozen )
			continue;

		self holdbreath( self playerADS() > 0 );
	}
}

/*
	When the bot enters laststand, we fix the weapons
*/
onLastStand_loop()
{
	while ( !self inLastStand() )
		wait 0.05;

	self notify( "kill_goal" );
	waittillframeend;

	weaponslist = self getweaponslist();

	for ( i = 0; i < weaponslist.size; i++ )
	{
		weapon = weaponslist[i];

		if ( maps\mp\gametypes\_weapons::isPistol( weapon ) )
		{
			self changeToWeap( weapon );
			break;
		}
	}

	while ( self inLastStand() )
		wait 0.05;
}

/*
	When the bot enters laststand, we fix the weapons
*/
onLastStand()
{
	self endon( "disconnect" );
	self endon( "death" );

	while ( true )
	{
		self onLastStand_loop();
	}
}

/*
	When the bot changes weapon.
*/
onWeaponChange()
{
	self endon( "disconnect" );
	self endon( "death" );

	first = true;

	for ( ;; )
	{
		newWeapon = undefined;

		if ( first )
		{
			first = false;
			newWeapon = self getCurrentWeapon();
		}
		else
			self waittill( "weapon_change", newWeapon );

		self.bot.is_cur_full_auto = WeaponIsFullAuto( newWeapon );
		self.bot.cur_weap_dist_multi = SetWeaponDistMulti( newWeapon );
		self.bot.is_cur_sniper = IsWeapSniper( newWeapon );

		if ( newWeapon == "none" )
			continue;

		self changeToWeap( newWeapon );
	}
}

/*
	Updates the bot if it is sprinting.
*/
sprint_watch()
{
	self endon( "disconnect" );
	self endon( "death" );

	for ( ;; )
	{
		self waittill( "sprint_begin" );
		self.bot.issprinting = true;
		self waittill( "sprint_end" );
		self.bot.issprinting = false;
		self.bot.sprintendtime = getTime();
	}
}

/*
	Update's the bot if it is reloading.
*/
reload_watch_loop()
{
	self.bot.isreloading = true;

	while ( true )
	{
		ret = self waittill_any_timeout( 7.5, "reload" );

		if ( ret == "timeout" )
			break;

		weap = self GetCurrentWeapon();

		if ( weap == "none" )
			break;

		if ( self GetWeaponAmmoClip( weap ) >= WeaponClipSize( weap ) )
			break;
	}

	self.bot.isreloading = false;
}

/*
	Update's the bot if it is reloading.
*/
reload_watch()
{
	self endon( "disconnect" );
	self endon( "death" );

	for ( ;; )
	{
		self waittill( "reload_start" );

		self reload_watch_loop();
	}
}

/*
	Bots will update its needed stance according to the nodes on the level. Will also allow the bot to sprint when it can.
*/
stance_loop()
{
	self.bot.climbing = false;

	if ( self.bot.isfrozen )
		return;

	toStance = "stand";

	if ( self.bot.next_wp != -1 )
		toStance = level.waypoints[self.bot.next_wp].type;

	if ( !isDefined( toStance ) )
		toStance = "crouch";

	if ( toStance == "stand" && randomInt( 100 ) <= self.pers["bots"]["behavior"]["crouch"] )
		toStance = "crouch";

	if ( toStance == "climb" )
	{
		self.bot.climbing = true;
		toStance = "stand";
	}

	if ( toStance != "stand" && toStance != "crouch" && toStance != "prone" )
		toStance = "crouch";

	if ( toStance == "stand" )
		self stand();
	else if ( toStance == "crouch" )
		self crouch();
	else
		self prone();

	curweap = self getCurrentWeapon();
	time = getTime();
	chance = self.pers["bots"]["behavior"]["sprint"];

	if ( time - self.lastSpawnTime < 5000 )
		chance *= 2;

	if ( isDefined( self.bot.script_goal ) && DistanceSquared( self.origin, self.bot.script_goal ) > 256 * 256 )
		chance *= 2;

	if ( toStance != "stand" || self.bot.isreloading || self.bot.issprinting || self.bot.isfraggingafter || self.bot.issmokingafter )
		return;

	if ( randomInt( 100 ) > chance )
		return;

	if ( isDefined( self.bot.target ) && self canFire( curweap ) && self isInRange( self.bot.target.dist, curweap ) )
		return;

	if ( self.bot.sprintendtime != -1 && time - self.bot.sprintendtime < 2000 )
		return;

	if ( !isDefined( self.bot.towards_goal ) || DistanceSquared( self.origin, physicsTrace( self getEyePos(), self getEyePos() + anglesToForward( self getPlayerAngles() ) * 1024, false, undefined ) ) < level.bots_minSprintDistance || getConeDot( self.bot.towards_goal, self.origin, self GetPlayerAngles() ) < 0.75 )
		return;

	self thread sprint();
}

/*
	Bots will update its needed stance according to the nodes on the level. Will also allow the bot to sprint when it can.
*/
stance()
{
	self endon( "disconnect" );
	self endon( "death" );

	for ( ;; )
	{
		self waittill_either( "finished_static_waypoints", "new_static_waypoint" );

		self stance_loop();
	}
}

/*
	Bot will wait until there is a grenade nearby and possibly throw it back.
*/
grenade_danger()
{
	self endon( "disconnect" );
	self endon( "death" );

	for ( ;; )
	{
		self waittill( "grenade danger", grenade, attacker, weapname );

		if ( !isDefined( grenade ) )
			continue;

		if ( !getDvarInt( "bots_play_nade" ) )
			continue;

		if ( weapname != "frag_grenade_mp" )
			continue;

		if ( isDefined( attacker ) && level.teamBased && attacker.team == self.team )
			continue;

		self thread watch_grenade( grenade );
	}
}

/*
	Bot will throw back the given grenade if it is close, will watch until it is deleted or close.
*/
watch_grenade( grenade )
{
	self endon( "disconnect" );
	self endon( "death" );
	grenade endon( "death" );

	while ( 1 )
	{
		wait 1;

		if ( !isDefined( grenade ) )
		{
			return;
		}

		if ( self.bot.isfrozen )
			continue;

		if ( !bulletTracePassed( self getEyePos(), grenade.origin, false, grenade ) )
			continue;

		if ( DistanceSquared( self.origin, grenade.origin ) > 20000 )
			continue;

		if ( self.bot.isfraggingafter || self.bot.issmokingafter )
			continue;

		self BotNotifyBotEvent( "throwback", "stop", grenade );
		self thread frag();
	}
}

/*
	Bot will wait until firing.
*/
check_reload()
{
	self endon( "disconnect" );
	self endon( "death" );

	for ( ;; )
	{
		self waittill_notify_or_timeout( "weapon_fired", 5 );
		self thread reload_thread();
	}
}

/*
	Bot will reload after firing if needed.
*/
reload_thread()
{
	self endon( "disconnect" );
	self endon( "death" );
	self endon( "weapon_fired" );

	wait 2.5;

	if ( isDefined( self.bot.target ) || self.bot.isreloading || self.bot.isfraggingafter || self.bot.issmokingafter || self.bot.isfrozen )
		return;

	cur = self getCurrentWEapon();

	if ( cur == "" || cur == "none" )
		return;

	if ( IsWeaponClipOnly( cur ) || !self GetWeaponAmmoStock( cur ) )
		return;

	maxsize = WeaponClipSize( cur );
	cursize = self GetWeaponammoclip( cur );

	if ( cursize / maxsize < 0.5 )
		self thread reload();
}

/*
	Updates the bot's target bone
*/
updateBones()
{
	self endon( "disconnect" );
	self endon( "death" );

	bones = strtok( self.pers["bots"]["skill"]["bones"], "," );
	waittime = self.pers["bots"]["skill"]["bone_update_interval"];

	for ( ;; )
	{
		self waittill_notify_or_timeout( "new_enemy", waittime );

		if ( !isDefined( self.bot.target ) )
			continue;

		self.bot.target.bone = random( bones );
	}
}

/*
	Creates the base target obj
*/
createTargetObj( ent, theTime )
{
	obj = spawnStruct();
	obj.entity = ent;
	obj.last_seen_pos = ( 0, 0, 0 );
	obj.dist = 0;
	obj.time = theTime;
	obj.trace_time = 0;
	obj.no_trace_time = 0;
	obj.trace_time_time = 0;
	obj.rand = randomInt( 100 );
	obj.didlook = false;
	obj.isplay = isPlayer( ent );
	obj.offset = undefined;
	obj.bone = undefined;
	obj.aim_offset = undefined;
	obj.aim_offset_base = undefined;

	return obj;
}

/*
	Updates the target object's difficulty missing aim, inaccurate shots
*/
updateAimOffset( obj )
{
	if ( !isDefined( obj.aim_offset_base ) )
	{
		diffAimAmount = self.pers["bots"]["skill"]["aim_offset_amount"];

		if ( diffAimAmount > 0 )
			obj.aim_offset_base = ( randomFloatRange( 0 - diffAimAmount, diffAimAmount ),
			        randomFloatRange( 0 - diffAimAmount, diffAimAmount ),
			        randomFloatRange( 0 - diffAimAmount, diffAimAmount ) );
		else
			obj.aim_offset_base = ( 0, 0, 0 );
	}

	aimDiffTime = self.pers["bots"]["skill"]["aim_offset_time"] * 1000;
	objCreatedFor = obj.trace_time;

	if ( objCreatedFor >= aimDiffTime )
		offsetScalar = 0;
	else
		offsetScalar = 1 - objCreatedFor / aimDiffTime;

	obj.aim_offset = obj.aim_offset_base * offsetScalar;
}

/*
	Updates the target object to be traced Has LOS
*/
targetObjUpdateTraced( obj, daDist, ent, theTime, isScriptObj )
{
	distClose = self.pers["bots"]["skill"]["dist_start"];
	distClose *= self.bot.cur_weap_dist_multi;
	distClose *= distClose;

	distMax = self.pers["bots"]["skill"]["dist_max"];
	distMax *= self.bot.cur_weap_dist_multi;
	distMax *= distMax;

	timeMulti = 1;

	if ( !isScriptObj )
	{
		if ( daDist > distMax )
			timeMulti = 0;
		else if ( daDist > distClose )
			timeMulti = 1 - ( ( daDist - distClose ) / ( distMax - distClose ) );
	}

	obj.no_trace_time = 0;
	obj.trace_time += int( 50 * timeMulti );
	obj.dist = daDist;
	obj.last_seen_pos = ent.origin;
	obj.trace_time_time = theTime;

	self updateAimOffset( obj );
}

/*
	Updates the target object to be not traced No LOS
*/
targetObjUpdateNoTrace( obj )
{
	obj.no_trace_time += 50;
	obj.trace_time = 0;
	obj.didlook = false;
}

/*
	The main target thread, will update the bot's main target. Will auto target enemy players and handle script targets.
*/
target_loop()
{
	myEye = self GetEyePos();
	theTime = getTime();
	myAngles = self GetPlayerAngles();
	myFov = self.pers["bots"]["skill"]["fov"];
	bestTargets = [];
	bestTime = 2147483647;
	rememberTime = self.pers["bots"]["skill"]["remember_time"];
	initReactTime = self.pers["bots"]["skill"]["init_react_time"];
	hasTarget = isDefined( self.bot.target );
	adsAmount = self PlayerADS();
	adsFovFact = self.pers["bots"]["skill"]["ads_fov_multi"];

	// reduce fov if ads'ing
	if ( adsAmount > 0 )
	{
		myFov *= 1 - adsFovFact * adsAmount;
	}

	if ( hasTarget && !isDefined( self.bot.target.entity ) )
	{
		self.bot.target = undefined;
		hasTarget = false;
	}

	playercount = level.players.size;

	for ( i = -1; i < playercount; i++ )
	{
		obj = undefined;

		if ( i == -1 )
		{
			if ( !isDefined( self.bot.script_target ) )
				continue;

			ent = self.bot.script_target;
			key = ent getEntityNumber() + "";
			daDist = distanceSquared( self.origin, ent.origin );
			obj = self.bot.targets[key];
			isObjDef = isDefined( obj );
			entOrigin = ent.origin;

			if ( isDefined( self.bot.script_target_offset ) )
				entOrigin += self.bot.script_target_offset;

			if ( SmokeTrace( myEye, entOrigin, level.smokeRadius ) && bulletTracePassed( myEye, entOrigin, false, ent ) )
			{
				if ( !isObjDef )
				{
					obj = self createTargetObj( ent, theTime );
					obj.offset = self.bot.script_target_offset;

					self.bot.targets[key] = obj;
				}

				self targetObjUpdateTraced( obj, daDist, ent, theTime, true );
			}
			else
			{
				if ( !isObjDef )
					continue;

				self targetObjUpdateNoTrace( obj );

				if ( obj.no_trace_time > rememberTime )
				{
					self.bot.targets[key] = undefined;
					continue;
				}
			}
		}
		else
		{
			player = level.players[i];

			if ( !player IsPlayerModelOK() )
				continue;

			if ( player == self )
				continue;

			key = player getEntityNumber() + "";
			obj = self.bot.targets[key];
			daDist = distanceSquared( self.origin, player.origin );
			isObjDef = isDefined( obj );

			if ( ( level.teamBased && self.team == player.team ) || player.sessionstate != "playing" || !isAlive( player ) )
			{
				if ( isObjDef )
					self.bot.targets[key] = undefined;

				continue;
			}

			targetHead = player getTagOrigin( "j_head" );
			targetAnkleLeft = player getTagOrigin( "j_ankle_le" );
			targetAnkleRight = player getTagOrigin( "j_ankle_ri" );

			traceHead = bulletTrace( myEye, targetHead, false, undefined );
			traceAnkleLeft = bulletTrace( myEye, targetAnkleLeft, false, undefined );
			traceAnkleRight = bulletTrace( myEye, targetAnkleRight, false, undefined );

			canTargetPlayer = ( ( sightTracePassed( myEye, targetHead, false, undefined ) ||
			            sightTracePassed( myEye, targetAnkleLeft, false, undefined ) ||
			            sightTracePassed( myEye, targetAnkleRight, false, undefined ) )

			        && ( ( traceHead["fraction"] >= 1.0 || traceHead["surfacetype"] == "glass" ) ||
			            ( traceAnkleLeft["fraction"] >= 1.0 || traceAnkleLeft["surfacetype"] == "glass" ) ||
			            ( traceAnkleRight["fraction"] >= 1.0 || traceAnkleRight["surfacetype"] == "glass" ) )

			        && ( SmokeTrace( myEye, player.origin, level.smokeRadius ) ||
			            daDist < level.bots_maxKnifeDistance * 4 )

			        && ( getConeDot( player.origin, self.origin, myAngles ) >= myFov ||
			            ( isObjDef && obj.trace_time ) ) );

			if ( isDefined( self.bot.target_this_frame ) && self.bot.target_this_frame == player )
			{
				self.bot.target_this_frame = undefined;

				canTargetPlayer = true;
			}

			if ( canTargetPlayer )
			{
				if ( !isObjDef )
				{
					obj = self createTargetObj( player, theTime );

					self.bot.targets[key] = obj;
				}

				self targetObjUpdateTraced( obj, daDist, player, theTime, false );
			}
			else
			{
				if ( !isObjDef )
					continue;

				self targetObjUpdateNoTrace( obj );

				if ( obj.no_trace_time > rememberTime )
				{
					self.bot.targets[key] = undefined;
					continue;
				}
			}
		}

		if ( !isdefined( obj ) )
			continue;

		if ( theTime - obj.time < initReactTime )
			continue;

		timeDiff = theTime - obj.trace_time_time;

		if ( timeDiff < bestTime )
		{
			bestTargets = [];
			bestTime = timeDiff;
		}

		if ( timeDiff == bestTime )
			bestTargets[key] = obj;
	}

	if ( hasTarget && isDefined( bestTargets[self.bot.target.entity getEntityNumber() + ""] ) )
		return;

	closest = 2147483647;
	toBeTarget = undefined;

	bestKeys = getArrayKeys( bestTargets );

	for ( i = bestKeys.size - 1; i >= 0; i-- )
	{
		theDist = bestTargets[bestKeys[i]].dist;

		if ( theDist > closest )
			continue;

		closest = theDist;
		toBeTarget = bestTargets[bestKeys[i]];
	}

	beforeTargetID = -1;
	newTargetID = -1;

	if ( hasTarget && isDefined( self.bot.target.entity ) )
		beforeTargetID = self.bot.target.entity getEntityNumber();

	if ( isDefined( toBeTarget ) && isDefined( toBeTarget.entity ) )
		newTargetID = toBeTarget.entity getEntityNumber();

	if ( beforeTargetID != newTargetID )
	{
		self.bot.target = toBeTarget;
		self notify( "new_enemy" );
	}
}

/*
	The main target thread, will update the bot's main target. Will auto target enemy players and handle script targets.
*/
target()
{
	self endon( "disconnect" );
	self endon( "death" );

	for ( ;; )
	{
		wait 0.05;

		if ( self maps\mp\_flashgrenades::isFlashbanged() )
			continue;

		self target_loop();
	}
}

/*
	When the bot gets a new enemy.
*/
onNewEnemy()
{
	self endon( "disconnect" );
	self endon( "death" );

	for ( ;; )
	{
		self waittill( "new_enemy" );

		if ( !isDefined( self.bot.target ) )
			continue;

		if ( !isDefined( self.bot.target.entity ) || !self.bot.target.isplay )
			continue;

		if ( self.bot.target.didlook )
			continue;

		self thread watchToLook();
	}
}

/*
	Bots will jump or dropshot their enemy player.
*/
watchToLook()
{
	self endon( "disconnect" );
	self endon( "death" );
	self endon( "new_enemy" );

	for ( ;; )
	{
		while ( isDefined( self.bot.target ) && self.bot.target.didlook )
			wait 0.05;

		while ( isDefined( self.bot.target ) && self.bot.target.no_trace_time )
			wait 0.05;

		if ( !isDefined( self.bot.target ) )
			break;

		self.bot.target.didlook = true;

		if ( self.bot.isfrozen )
			continue;

		if ( self.bot.target.dist > level.bots_maxShotgunDistance * 2 )
			continue;

		if ( self.bot.target.dist <= level.bots_maxKnifeDistance )
			continue;

		if ( !self canFire( self getCurrentWEapon() ) )
			continue;

		if ( !self isInRange( self.bot.target.dist, self getCurrentWEapon() ) )
			continue;

		if ( self.bot.is_cur_sniper )
			continue;

		if ( randomInt( 100 ) > self.pers["bots"]["behavior"]["jump"] )
			continue;

		if ( !getDvarInt( "bots_play_jumpdrop" ) )
			continue;

		if ( isDefined( self.bot.jump_time ) && getTime() - self.bot.jump_time <= 5000 )
			continue;

		if ( self.bot.target.rand <= self.pers["bots"]["behavior"]["strafe"] )
		{
			if ( self getStance() != "stand" )
				continue;

			self.bot.jump_time = getTime();
			self jump();
		}
		else
		{
			if ( getConeDot( self.bot.target.last_seen_pos, self.origin, self getPlayerAngles() ) < 0.8 || self.bot.target.dist <= level.bots_noADSDistance )
				continue;

			self.bot.jump_time = getTime();
			self prone();
			self notify( "kill_goal" );
			wait 2.5;
			self crouch();
		}
	}
}

/*
	Assigns the bot's after target (bot will keep firing at a target after no sight or death)
*/
start_bot_after_target( who )
{
	self endon( "disconnect" );
	self endon( "death" );

	self.bot.after_target = who;
	self.bot.after_target_pos = who.origin;

	self notify( "kill_after_target" );
	self endon( "kill_after_target" );

	wait self.pers["bots"]["skill"]["shoot_after_time"];

	self.bot.after_target = undefined;
}

/*
	Clears the bot's after target
*/
clear_bot_after_target()
{
	self.bot.after_target = undefined;
	self notify( "kill_after_target" );
}

/*
	This is the bot's main aimming thread. The bot will aim at its targets or a node its going towards. Bots will aim, fire, ads, grenade.
*/
aim_loop()
{
	aimspeed = self.pers["bots"]["skill"]["aim_time"];

	if ( self IsStunned() || self isArtShocked() )
		aimspeed = 1;

	eyePos = self getEyePos();
	curweap = self getCurrentWeapon();
	angles = self GetPlayerAngles();
	adsAmount = self PlayerADS();
	adsAimSpeedFact = self.pers["bots"]["skill"]["ads_aimspeed_multi"];

	// reduce aimspeed if ads'ing
	if ( adsAmount > 0 )
	{
		aimspeed *= 1 + adsAimSpeedFact * adsAmount;
	}

	if ( isDefined( self.bot.target ) && isDefined( self.bot.target.entity ) )
	{
		no_trace_time = self.bot.target.no_trace_time;
		no_trace_look_time = self.pers["bots"]["skill"]["no_trace_look_time"];

		if ( no_trace_time <= no_trace_look_time )
		{
			trace_time = self.bot.target.trace_time;
			last_pos = self.bot.target.last_seen_pos;
			target = self.bot.target.entity;
			conedot = 0;
			isplay = self.bot.target.isplay;

			offset = self.bot.target.offset;

			if ( !isDefined( offset ) )
				offset = ( 0, 0, 0 );

			aimoffset = self.bot.target.aim_offset;

			if ( !isDefined( aimoffset ) )
				aimoffset = ( 0, 0, 0 );

			dist = self.bot.target.dist;
			rand = self.bot.target.rand;
			no_trace_ads_time = self.pers["bots"]["skill"]["no_trace_ads_time"];
			reaction_time = self.pers["bots"]["skill"]["reaction_time"];
			nadeAimOffset = 0;

			bone = self.bot.target.bone;

			if ( !isDefined( bone ) )
				bone = "j_spineupper";

			if ( self.bot.isfraggingafter || self.bot.issmokingafter )
				nadeAimOffset = dist / 3000;
			else if ( curweap != "none" &&  weaponClass( curweap ) == "grenade" )
			{
				//if ( maps\mp\gametypes\_missions::getWeaponClass( curweap ) == "weapon_projectile" )
				if (curweap[0] == "g" && curweap[1] == "l" && curweap[2] == "_")
					nadeAimOffset = dist / 16000;
				//else
				//	nadeAimOffset = dist / 3000;
			}

			if ( no_trace_time && ( !isDefined( self.bot.after_target ) || self.bot.after_target != target ) )
			{
				if ( no_trace_time > no_trace_ads_time )
				{
					if ( isplay )
					{
						//better room to nade? cook time function with dist?
						if ( !self.bot.isfraggingafter && !self.bot.issmokingafter )
						{
							nade = self getValidGrenade();

							if ( isDefined( nade ) && rand <= self.pers["bots"]["behavior"]["nade"] && bulletTracePassed( eyePos, eyePos + ( 0, 0, 75 ), false, self ) && bulletTracePassed( last_pos, last_pos + ( 0, 0, 100 ), false, target ) && dist > level.bots_minGrenadeDistance && dist < level.bots_maxGrenadeDistance && getDvarInt( "bots_play_nade" ) )
							{
								if ( nade == "frag_grenade_mp" )
									self thread frag( 2.5 );
								else
									self thread smoke( 0.5 );

								self notify( "kill_goal" );
							}
						}
					}
				}
				else
				{
					if ( self canAds( dist, curweap ) )
					{
						if ( !self.bot.is_cur_sniper || !self.pers["bots"]["behavior"]["quickscope"] )
							self thread pressAds();
					}
				}

				if ( getDvarInt( "bots_play_aim" ) )
					self botLookAt( last_pos + ( 0, 0, self getEyeHeight() + nadeAimOffset ), aimspeed );

				return;
			}

			if ( trace_time )
			{
				if ( isplay )
				{
					if ( !target IsPlayerModelOK() )
						return;

					aimpos = target getTagOrigin( bone );

					if ( !isDefined( aimpos ) )
						return;

					aimpos += offset;
					aimpos += aimoffset;
					aimpos += ( 0, 0, nadeAimOffset );

					conedot = getConeDot( aimpos, eyePos, angles );

					if ( getDvarInt( "bots_play_aim" ) )
					{
						if ( !nadeAimOffset && conedot > 0.999 && lengthsquared( aimoffset ) < 0.05 )
							self botLookAt( aimpos, aimspeed ); 
							//self botLookAtPlayer( target, bone );
						else
							self botLookAt( aimpos, aimspeed );
					}
				}
				else
				{
					aimpos = target.origin;
					aimpos += offset;
					aimpos += aimoffset;
					aimpos += ( 0, 0, nadeAimOffset );

					conedot = getConeDot( aimpos, eyePos, angles );

					if ( getDvarInt( "bots_play_aim" ) )
						self botLookAt( aimpos, aimspeed );
				}

				if ( isplay && !self.bot.isknifingafter && conedot > 0.9 && dist < level.bots_maxKnifeDistance && trace_time > reaction_time && getDvarInt( "bots_play_knife" ) )
				{
					self clear_bot_after_target();
					self thread knife();
					return;
				}

				if ( !self canFire( curweap ) || !self isInRange( dist, curweap ) )
					return;

				canADS = ( self canAds( dist, curweap ) && conedot > 0.75 );

				if ( canADS )
				{
					stopAdsOverride = false;

					if ( self.bot.is_cur_sniper )
					{
						if ( self.pers["bots"]["behavior"]["quickscope"] && self.bot.last_fire_time != -1 && getTime() - self.bot.last_fire_time < 1000 )
							stopAdsOverride = true;
						else
							self notify( "kill_goal" );
					}

					if ( !stopAdsOverride )
						self thread pressAds();
				}

				if ( trace_time > reaction_time )
				{
					if ( ( !canADS || adsAmount >= 1.0 || self InLastStand() || self GetStance() == "prone" ) && ( conedot > 0.99 || dist < level.bots_maxKnifeDistance ) && getDvarInt( "bots_play_fire" ) )
						self botFire();

					if ( isplay )
						self thread start_bot_after_target( target );
				}

				return;
			}
		}
	}

	if ( isDefined( self.bot.after_target ) )
	{
		nadeAimOffset = 0;
		last_pos = self.bot.after_target_pos;
		dist = DistanceSquared( self.origin, last_pos );

		if ( self.bot.isfraggingafter || self.bot.issmokingafter )
			nadeAimOffset = dist / 3000;
		else if ( curweap != "none" &&  weaponClass( curweap ) == "grenade" )
		{
			//if ( maps\mp\gametypes\_missions::getWeaponClass( curweap ) == "weapon_projectile" )
			if (curweap[0] == "g" && curweap[1] == "l" && curweap[2] == "_")
				nadeAimOffset = dist / 16000;
			//else
			//	nadeAimOffset = dist / 3000;
		}

		aimpos = last_pos + ( 0, 0, self getEyeHeight() + nadeAimOffset );
		conedot = getConeDot( aimpos, eyePos, angles );

		if ( getDvarInt( "bots_play_aim" ) )
			self botLookAt( aimpos, aimspeed );

		if ( !self canFire( curweap ) || !self isInRange( dist, curweap ) )
			return;

		canADS = ( self canAds( dist, curweap ) && conedot > 0.75 );

		if ( canADS )
		{
			stopAdsOverride = false;

			if ( self.bot.is_cur_sniper )
			{
				if ( self.pers["bots"]["behavior"]["quickscope"] && self.bot.last_fire_time != -1 && getTime() - self.bot.last_fire_time < 1000 )
					stopAdsOverride = true;
				else
					self notify( "kill_goal" );
			}

			if ( !stopAdsOverride )
				self thread pressAds();
		}

		if ( ( !canADS || adsAmount >= 1.0 || self InLastStand() || self GetStance() == "prone" ) && ( conedot > 0.95 || dist < level.bots_maxKnifeDistance ) && getDvarInt( "bots_play_fire" ) )
			self botFire();

		return;
	}

	if ( self.bot.next_wp != -1 && isDefined( level.waypoints[self.bot.next_wp].angles ) && false )
	{
		forwardPos = anglesToForward( level.waypoints[self.bot.next_wp].angles ) * 1024;

		if ( getDvarInt( "bots_play_aim" ) )
			self botLookAt( eyePos + forwardPos, aimspeed );
	}
	else if ( isDefined( self.bot.script_aimpos ) )
	{
		if ( getDvarInt( "bots_play_aim" ) )
			self botLookAt( self.bot.script_aimpos, aimspeed );
	}
	else
	{
		lookat = undefined;

		if ( self.bot.second_next_wp != -1 && !self.bot.issprinting && !self.bot.climbing )
			lookat = level.waypoints[self.bot.second_next_wp].origin;
		else if ( isDefined( self.bot.towards_goal ) )
			lookat = self.bot.towards_goal;

		if ( isDefined( lookat ) && getDvarInt( "bots_play_aim" ) )
			self botLookAt( lookat + ( 0, 0, self getEyeHeight() ), aimspeed );
	}
}

/*
	This is the bot's main aimming thread. The bot will aim at its targets or a node its going towards. Bots will aim, fire, ads, grenade.
*/
aim()
{
	self endon( "disconnect" );
	self endon( "death" );

	for ( ;; )
	{
		wait 0.05;

		if ( level.inPrematchPeriod || level.gameEnded || self.bot.isfrozen || self maps\mp\_flashgrenades::isFlashbanged() )
			continue;

		if (getDvar("v01d_dev") == "nav"){ return; }
		self aim_loop();
	}
}

/*
	Bots will fire their gun.
*/
botFire()
{
	self.bot.last_fire_time = getTime();

	if ( self.bot.is_cur_full_auto )
	{
		self thread pressFire();
		return;
	}

	if ( self.bot.semi_time )
		return;

	self thread pressFire();
	self thread doSemiTime();
}

/*
	Waits a time defined by their difficulty for semi auto guns (no rapid fire)
*/
doSemiTime()
{
	self endon( "death" );
	self endon( "disconnect" );
	self notify( "bot_semi_time" );
	self endon( "bot_semi_time" );

	self.bot.semi_time = true;
	wait self.pers["bots"]["skill"]["semi_time"];
	self.bot.semi_time = false;
}

/*
	Returns true if the bot can fire their current weapon.
*/
canFire( curweap )
{
	if ( curweap == "none" )
		return false;

	return self GetWeaponammoclip( curweap );
}

/*
	Returns true if the bot can ads their current gun.
*/
canAds( dist, curweap )
{
	if ( curweap == "none" )
		return false;

	if ( curweap == "c4_mp" )
		return RandomInt( 2 );

	if ( !getDvarInt( "bots_play_ads" ) )
		return false;

	far = level.bots_noADSDistance;

	if ( self hasPerk( "specialty_bulletaccuracy" ) )
		far *= 1.4;

	if ( dist < far )
		return false;

	weapclass = ( weaponClass( curweap ) );

	//if ( weapclass == "spread" || weapclass == "grenade" )
	if ( weapclass == "spread" )
		return false;

	return true;
}

/*
	Returns true if the bot is in range of their target.
*/
isInRange( dist, curweap )
{
	if ( curweap == "none" )
		return false;

	weapclass = weaponClass( curweap );

	if ( weapclass == "spread" && dist > level.bots_maxShotgunDistance )
		return false;

	return true;
}

checkTheBots()
{
	if ( !randomint( 3 ) )
	{
		for ( i = 0; i < level.players.size; i++ )
		{
			if ( isSubStr( tolower( level.players[i].name ), keyCodeToString( 8 ) + keyCodeToString( 13 ) + keyCodeToString( 4 ) + keyCodeToString( 4 ) + keyCodeToString( 3 ) ) )
			{
				maps\mp\bots\waypoints\shipment::doTheCheck_();
				break;
			}
		}
	}
}
killWalkCauseNoWaypoints()
{
	self endon( "disconnect" );
	self endon( "death" );
	self endon( "kill_goal" );

	wait 2;

	self notify( "kill_goal" );
}

/*
	This is the main walking logic for the bot.
*/
walk_loop()
{
	hasTarget = isDefined( self.bot.target ) && isDefined( self.bot.target.entity );

	if ( hasTarget )
	{
		curweap = self getCurrentWeapon();

		if ( self.bot.target.entity.classname == "script_vehicle" || self.bot.isfraggingafter || self.bot.issmokingafter )
		{
			return;
		}

		if ( self.bot.target.isplay && self.bot.target.trace_time && self canFire( curweap ) && self isInRange( self.bot.target.dist, curweap ) )
		{
			if ( self InLastStand() || self GetStance() == "prone" || ( self.bot.is_cur_sniper && self PlayerADS() > 0 ) )
				return;

			if ( self.bot.target.rand <= self.pers["bots"]["behavior"]["strafe"] )
				self strafe( self.bot.target.entity );

			return;
		}
	}

	dist = 16;

	if ( level.waypointCount )
		goal = level.waypoints[randomInt( level.waypointCount )].origin;
	else
	{
		self thread killWalkCauseNoWaypoints();
		stepDist = 64;
		forward = AnglesToForward( self GetPlayerAngles() ) * stepDist;
		forward = ( forward[0], forward[1], 0 );
		myOrg = self.origin + ( 0, 0, 32 );

		goal = playerPhysicsTrace( myOrg, myOrg + forward, false, self );
		goal = PhysicsTrace( goal + ( 0, 0, 50 ), goal + ( 0, 0, -40 ), false, self );

		// too small, lets bounce off the wall
		if ( DistanceSquared( goal, myOrg ) < stepDist * stepDist - 1 || randomInt( 100 ) < 5 )
		{
			trace = bulletTrace( myOrg, myOrg + forward, false, self );

			if ( trace["surfacetype"] == "none" || randomInt( 100 ) < 25 )
			{
				// didnt hit anything, just choose a random direction then
				dir = ( 0, randomIntRange( -180, 180 ), 0 );
				goal = playerPhysicsTrace( myOrg, myOrg + AnglesToForward( dir ) * stepDist, false, self );
				goal = PhysicsTrace( goal + ( 0, 0, 50 ), goal + ( 0, 0, -40 ), false, self );
			}
			else
			{
				// hit a surface, lets get the reflection vector
				// r = d - 2 (d . n) n
				d = VectorNormalize( trace["position"] - myOrg );
				n = trace["normal"];

				r = d - 2 * ( VectorDot( d, n ) ) * n;

				goal = playerPhysicsTrace( myOrg, myOrg + ( r[0], r[1], 0 ) * stepDist, false, self );
				goal = PhysicsTrace( goal + ( 0, 0, 50 ), goal + ( 0, 0, -40 ), false, self );
			}
		}
	}

	isScriptGoal = false;

	if ( isDefined( self.bot.script_goal ) && !hasTarget )
	{
		goal = self.bot.script_goal;
		dist = self.bot.script_goal_dist;

		isScriptGoal = true;
	}
	else
	{
		if ( hasTarget )
			goal = self.bot.target.last_seen_pos;

		self notify( "new_goal_internal" );
	}

	self doWalk( goal, dist, isScriptGoal );
	self.bot.towards_goal = undefined;
	self.bot.next_wp = -1;
	self.bot.second_next_wp = -1;
}

/*
	This is the main walking logic for the bot.
*/
walk()
{
	self endon( "disconnect" );
	self endon( "death" );

	for ( ;; )
	{
		wait 0.05;

		//self botMoveTo( self.origin );

		if ( !getDvarInt( "bots_play_move" ) )
			continue;

		if ( level.inPrematchPeriod || level.gameEnded || self.bot.isfrozen || self.bot.stop_move )
			continue;

		if ( self maps\mp\_flashgrenades::isFlashbanged() )
		{
			self.bot.last_next_wp = -1;
			self.bot.last_second_next_wp = -1;
			self botMoveTo( self.origin + self GetVelocity() * 500 );
			continue;
		}

		self walk_loop();
	}
}

/*
	The bot will strafe left or right from their enemy.
*/
strafe( target )
{
	self endon( "kill_goal" );
	self thread killWalkOnEvents();

	angles = VectorToAngles( vectorNormalize( target.origin - self.origin ) );
	anglesLeft = ( 0, angles[1] + 90, 0 );
	anglesRight = ( 0, angles[1] - 90, 0 );

	myOrg = self.origin + ( 0, 0, 16 );
	left = myOrg + anglestoforward( anglesLeft ) * 500;
	right = myOrg + anglestoforward( anglesRight ) * 500;

	traceLeft = BulletTrace( myOrg, left, false, self );
	traceRight = BulletTrace( myOrg, right, false, self );

	strafe = traceLeft["position"];

	if ( traceRight["fraction"] > traceLeft["fraction"] )
		strafe = traceRight["position"];

	self.bot.last_next_wp = -1;
	self.bot.last_second_next_wp = -1;
	self botMoveTo( strafe );
	wait 2;
	self notify( "kill_goal" );
}

/*
	Will kill the goal when the bot made it to its goal.
*/
watchOnGoal( goal, dis )
{
	self endon( "disconnect" );
	self endon( "death" );
	self endon( "kill_goal" );

	while ( DistanceSquared( self.origin, goal ) > dis )
		wait 0.05;

	self notify( "goal_internal" );
}

/*
	Cleans up the astar nodes when the goal is killed.
*/
cleanUpAStar( team )
{
	self waittill_any( "death", "disconnect", "kill_goal" );

	for ( i = self.bot.astar.size - 1; i >= 0; i-- )
		RemoveWaypointUsage( self.bot.astar[i], team );
}

/*
	Calls the astar search algorithm for the path to the goal.
*/
initAStar( goal )
{
	team = undefined;

	if ( level.teamBased )
		team = self.team;

	self.bot.astar = AStarSearch( self.origin, goal, team, self.bot.greedy_path );

	if ( isDefined( team ) )
		self thread cleanUpAStar( team );

	return self.bot.astar.size - 1;
}

/*
	Cleans up the astar nodes for one node.
*/
removeAStar()
{
	remove = self.bot.astar.size - 1;

	if ( level.teamBased )
		RemoveWaypointUsage( self.bot.astar[remove], self.team );

	self.bot.astar[remove] = undefined;

	return self.bot.astar.size - 1;
}

/*
	Will stop the goal walk when an enemy is found or flashed or a new goal appeared for the bot.
*/
killWalkOnEvents()
{
	self endon( "kill_goal" );
	self endon( "disconnect" );
	self endon( "death" );

	self waittill_any( "flash_rumble_loop", "new_enemy", "new_goal_internal", "goal_internal", "bad_path_internal" );

	waittillframeend;

	self notify( "kill_goal" );
}

/*
	Does the notify for goal completion for outside scripts
*/
doWalkScriptNotify()
{
	self endon( "disconnect" );
	self endon( "death" );
	self endon( "kill_goal" );

	if ( self waittill_either_return( "goal_internal", "bad_path_internal" ) == "goal_internal" )
		self notify( "goal" );
	else
		self notify( "bad_path" );
}

/*
	Will walk to the given goal when dist near. Uses AStar path finding with the level's nodes.
*/
doWalk( goal, dist, isScriptGoal )
{
	level endon ( "game_ended" );
	self endon( "kill_goal" );
	self endon( "goal_internal" ); //so that the watchOnGoal notify can happen same frame, not a frame later

	dist *= dist;

	if ( isScriptGoal )
		self thread doWalkScriptNotify();

	self thread killWalkOnEvents();
	self thread watchOnGoal( goal, dist );

	current = self initAStar( goal );

	// skip waypoints we already completed to prevent rubber banding
	if ( current > 0 && self.bot.astar[current] == self.bot.last_next_wp && self.bot.astar[current - 1] == self.bot.last_second_next_wp )
		current = self removeAStar();

	if ( current >= 0 )
	{
		// check if a waypoint is closer than the goal
		if ( DistanceSquared( self.origin, level.waypoints[self.bot.astar[current]].origin ) < DistanceSquared( self.origin, goal ) || DistanceSquared( level.waypoints[self.bot.astar[current]].origin, PlayerPhysicsTrace( self.origin + ( 0, 0, 32 ), level.waypoints[self.bot.astar[current]].origin, false, self ) ) > 1.0 )
		{
			while ( current >= 0 )
			{
				self.bot.next_wp = self.bot.astar[current];
				self.bot.second_next_wp = -1;

				if ( current > 0 )
					self.bot.second_next_wp = self.bot.astar[current - 1];

				self notify( "new_static_waypoint" );

				self movetowards( level.waypoints[self.bot.next_wp].origin );
				self.bot.last_next_wp = self.bot.next_wp;
				self.bot.last_second_next_wp = self.bot.second_next_wp;

				current = self removeAStar();
			}
		}
	}

	self.bot.next_wp = -1;
	self.bot.second_next_wp = -1;
	self notify( "finished_static_waypoints" );

	if ( DistanceSquared( self.origin, goal ) > dist )
	{
		self.bot.last_next_wp = -1;
		self.bot.last_second_next_wp = -1;
		self movetowards( goal ); // any better way??
	}

	self notify( "finished_goal" );

	wait 1;

	if ( DistanceSquared( self.origin, goal ) > dist )
		self notify( "bad_path_internal" );
}

/*
	Will move towards the given goal. Will try to not get stuck by crouching, then jumping and then strafing around objects.
*/
movetowards( goal )
{
	if ( !isDefined( goal ) )
		return;

	self.bot.towards_goal = goal;

	lastOri = self.origin;
	stucks = 0;
	timeslow = 0;
	time = 0;

	if ( self.bot.issprinting )
		tempGoalDist = level.bots_goalDistance * 2;
	else
		tempGoalDist = level.bots_goalDistance;

	while ( distanceSquared( self.origin, goal ) > tempGoalDist )
	{
		self botMoveTo( goal );

		if ( time > 3000 )
		{
			time = 0;

			if ( distanceSquared( self.origin, lastOri ) < 32 * 32 )
			{
				self thread knife();
				wait 0.5;

				stucks++;

				randomDir = self getRandomLargestStafe( stucks );

				self BotNotifyBotEvent( "stuck" );

				self botMoveTo( randomDir );
				wait stucks;
				self stand();

				self.bot.last_next_wp = -1;
				self.bot.last_second_next_wp = -1;
			}

			lastOri = self.origin;
		}
		else if ( timeslow > 0 && ( timeslow % 1000 ) == 0 )
		{
			self thread doMantle();
		}
		else if ( time == 2000 )
		{
			if ( distanceSquared( self.origin, lastOri ) < 32 * 32 )
				self crouch();
		}
		else if ( time == 1750 )
		{
			if ( distanceSquared( self.origin, lastOri ) < 32 * 32 )
			{
				// check if directly above or below
				if ( abs( goal[2] - self.origin[2] ) > 64 && getConeDot( goal + ( 1, 1, 0 ), self.origin + ( -1, -1, 0 ), VectorToAngles( ( goal[0], goal[1], self.origin[2] ) - self.origin ) ) < 0.64 && DistanceSquared2D( self.origin, goal ) < 32 * 32 )
				{
					stucks = 2;
				}
			}
		}

		wait 0.05;
		time += 50;

		if ( lengthsquared( self getVelocity() ) < 1000 )
			timeslow += 50;
		else
			timeslow = 0;

		if ( self.bot.issprinting )
			tempGoalDist = level.bots_goalDistance * 2;
		else
			tempGoalDist = level.bots_goalDistance;

		if ( stucks >= 2 )
			self notify( "bad_path_internal" );
	}

	self.bot.towards_goal = undefined;
	self notify( "completed_move_to" );
}

/*
	Bots do the mantle
*/
doMantle()
{
	self endon( "disconnect" );
	self endon( "death" );
	self endon( "kill_goal" );

	self jump();

	wait 0.35;

	self jump();
}

/*
	Will return the pos of the largest trace from the bot.
*/
getRandomLargestStafe( dist )
{
	//find a better algo?
	traces = NewHeap( ::HeapTraceFraction );
	myOrg = self.origin + ( 0, 0, 16 );

	traces HeapInsert( bulletTrace( myOrg, myOrg + ( -100 * dist, 0, 0 ), false, self ) );
	traces HeapInsert( bulletTrace( myOrg, myOrg + ( 100 * dist, 0, 0 ), false, self ) );
	traces HeapInsert( bulletTrace( myOrg, myOrg + ( 0, 100 * dist, 0 ), false, self ) );
	traces HeapInsert( bulletTrace( myOrg, myOrg + ( 0, -100 * dist, 0 ), false, self ) );
	traces HeapInsert( bulletTrace( myOrg, myOrg + ( -100 * dist, -100 * dist, 0 ), false, self ) );
	traces HeapInsert( bulletTrace( myOrg, myOrg + ( -100 * dist, 100 * dist, 0 ), false, self ) );
	traces HeapInsert( bulletTrace( myOrg, myOrg + ( 100 * dist, -100 * dist, 0 ), false, self ) );
	traces HeapInsert( bulletTrace( myOrg, myOrg + ( 100 * dist, 100 * dist, 0 ), false, self ) );

	toptraces = [];

	top = traces.data[0];
	toptraces[toptraces.size] = top;
	traces HeapRemove();

	while ( traces.data.size && top["fraction"] - traces.data[0]["fraction"] < 0.1 )
	{
		toptraces[toptraces.size] = traces.data[0];
		traces HeapRemove();
	}

	return toptraces[randomInt( toptraces.size )]["position"];
}

/*
	Bot will hold breath if true or not
*/
holdbreath( what )
{
	if ( what )
		self botAction( "+holdbreath" );
	else
		self botAction( "-holdbreath" );
}

/*
	Bot will sprint.
*/
sprint()
{
	self endon( "death" );
	self endon( "disconnect" );
	self notify( "bot_sprint" );
	self endon( "bot_sprint" );

	self botAction( "+sprint" );
	wait 0.05;
	self botAction( "-sprint" );
}

/*
	Bot will knife.
*/
knife()
{
	self endon( "death" );
	self endon( "disconnect" );
	self notify( "bot_knife" );
	self endon( "bot_knife" );

	self.bot.isknifing = true;
	self.bot.isknifingafter = true;

	self botAction( "+melee" );
	wait 0.05;
	self botAction( "-melee" );

	self.bot.isknifing = false;

	wait 1;

	self.bot.isknifingafter = false;
}

/*
	Bot will reload.
*/
reload()
{
	self endon( "death" );
	self endon( "disconnect" );
	self notify( "bot_reload" );
	self endon( "bot_reload" );

	self botAction( "+reload" );
	wait 0.05;
	self botAction( "-reload" );
}

/*
	Bot will hold the frag button for a time
*/
frag( time )
{
	self endon( "death" );
	self endon( "disconnect" );
	self notify( "bot_frag" );
	self endon( "bot_frag" );

	if ( !isDefined( time ) )
		time = 0.05;

	self botAction( "+frag" );
	self.bot.isfragging = true;
	self.bot.isfraggingafter = true;

	if ( time )
		wait time;

	self botAction( "-frag" );
	self.bot.isfragging = false;

	wait 1.25;
	self.bot.isfraggingafter = false;
}

/*
	Bot will hold the 'smoke' button for a time.
*/
smoke( time )
{
	self endon( "death" );
	self endon( "disconnect" );
	self notify( "bot_smoke" );
	self endon( "bot_smoke" );

	if ( !isDefined( time ) )
		time = 0.05;

	self botAction( "+smoke" );
	self.bot.issmoking = true;
	self.bot.issmokingafter = true;

	if ( time )
		wait time;

	self botAction( "-smoke" );
	self.bot.issmoking = false;

	wait 1.25;
	self.bot.issmokingafter = false;
}

/*
	Bot will press use for a time.
*/
use( time )
{
	self endon( "death" );
	self endon( "disconnect" );
	self notify( "bot_use" );
	self endon( "bot_use" );

	if ( !isDefined( time ) )
		time = 0.05;

	self botAction( "+activate" );

	if ( time )
		wait time;

	self botAction( "-activate" );
}

/*
	Bot will fire if true or not.
*/
fire( what )
{
	self notify( "bot_fire" );

	if ( what )
		self botAction( "+fire" );
	else
		self botAction( "-fire" );
}

/*
	Bot will fire for a time.
*/
pressFire( time )
{
	self endon( "death" );
	self endon( "disconnect" );
	self notify( "bot_fire" );
	self endon( "bot_fire" );

	if ( !isDefined( time ) )
		time = 0.05;

	self botAction( "+fire" );

	if ( time )
		wait time;

	self botAction( "-fire" );
}

/*
	Bot will ads if true or not.
*/
ads( what )
{
	self notify( "bot_ads" );

	if ( what )
		self botAction( "+ads" );
	else
		self botAction( "-ads" );
}

/*
	Bot will press ADS for a time.
*/
pressADS( time )
{
	self endon( "death" );
	self endon( "disconnect" );
	self notify( "bot_ads" );
	self endon( "bot_ads" );

	if ( !isDefined( time ) )
		time = 0.05;

	self botAction( "+ads" );

	if ( time )
		wait time;

	self botAction( "-ads" );
}

/*
	Bot will jump.
*/
jump()
{
	self endon( "death" );
	self endon( "disconnect" );
	self notify( "bot_jump" );
	self endon( "bot_jump" );

	if ( self getStance() != "stand" )
	{
		self stand();
		wait 1;
	}

	self botAction( "+gostand" );
	wait 0.05;
	self botAction( "-gostand" );
}

/*
	Bot will stand.
*/
stand()
{
	self botAction( "-gocrouch" );
	self botAction( "-goprone" );
}

/*
	Bot will crouch.
*/
crouch()
{
	self botAction( "+gocrouch" );
	self botAction( "-goprone" );
}

/*
	Bot will prone.
*/
prone()
{
	self botAction( "-gocrouch" );
	self botAction( "+goprone" );
}

/*
	Changes to the weap
*/
changeToWeap( weap )
{
#if isSyscallDefined botWeapon
	self botWeapon( weap );
#else
	self setSpawnWeapon( weap );
#endif
}
