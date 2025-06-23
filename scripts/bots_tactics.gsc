#include maps\mp\_load;
#include maps\mp\_utility;
#include scripts\cl;
#include scripts\pl;
#include scripts\bots_utilities;

init()
{
	if (getDvar("v01d_bots") == "1")
	{
		
	}
	
	if(scripts\bots_navigation::_check_if_no_nodes(level.nodes)){ return; }
	
    //level thread _player_connecting();
	
	for(;;)
    {
		level waittill("connected", bot);
		
		bot thread _bot_spawn_loop();
		
	}
}

_bot_spawn_loop()
{
	//self endon( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	level endon( "game_ended" );
	
	if(!self.isbot){ return; }

	for(;;)
	{
		self waittill("spawned_player");
		//cl("spawned bot: " + self.name);
		
		self thread _bot_search_target();
		self thread _bot_hears_firing();
		self thread _bot_hears_explosion();
		self thread _bot_search_enemy_choppers();
	}
}

_bot_search_enemy_choppers()
{
	self endon( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	level endon( "game_ended" );

	if(!isDefined(level.choppers)){ return; }
	
	for(;;)
	{
		if(!isDefined(self.hasEnemyTarget))
		{
			for(i = 0; i < level.choppers.size; i++)
			{
				chopper = level.choppers[i];
				
				if(chopper.team == self.team){ continue; }
				
				btp = bulletTracePassed(self getEye(), chopper.origin, false, self);
				
				if(!btp){ continue; }

				self scripts\bots_navigation::_bot_look_at(chopper.origin);
				vd = scripts\bots_utilities::_dp(self getEye(), chopper.origin, self.angles);

				if(vd > 0.90)
				{
					self thread _bot_change_weapon();
					self thread _bot_ads();
					self _bot_shoot();
				}
			}
		}
		
		wait 1;
	}
}

_bot_search_target()
{
	self endon( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	level endon( "game_ended" );
	
	for(;;)
	{
		wait 0.1 + randomFloatRange(0, 0.5);
		
		self.hasEnemyTarget = undefined;
		
		players = getentarray( "player", "classname" );
		for(i = 0; i < players.size; i++)
		{
			if(!isAlive(players[i])){ continue; }
			if(players[i] == self){ continue; }
			if(players[i].pers["team"] == self.pers["team"]){ continue; }
			
			bt = bulletTrace(self getEye(), players[i] getEye(), true, self);
			btp = bulletTracePassed(self getEye(), players[i] getEye(), true, self);
			pos = bt["position"];
			ent = bt["entity"];
			
			if(isDefined(ent) && ent.classname == "player" && isAlive(ent) && ent.pers["team"] != self.pers["team"])
			{
				//cl(self.name + " seen: " + ent.name);
				self.hasEnemyTarget = ent;
				
				if(randomIntRange(0, 10) > 4)
				{
					self botAction( "+goprone" );
					//self botMoveTo(self getEye());
				}
				
				h = self.hasEnemyTarget getEye();
				self scripts\bots_navigation::_bot_look_at((h[0], h[1], h[2]-5));
				//h = self.hasEnemyTarget GetTagOrigin("j_head");
				//self scripts\bots_nav::_bot_look_at((h[0], h[1], h[2]+5));
				self thread _bot_change_weapon();
				self thread _bot_ads();
				self _bot_shoot();
				wait 1;
				self botAction( "-goprone" );
			}
		}
	}
}

_bot_shoot()
{
	self endon ( "disconnect" );
	self endon( "intermission" );
	level endon( "game_ended" );
		
	while(isAlive(self) && isDefined(self.hasEnemyTarget) && isAlive(self.hasEnemyTarget))
	{
		h1 = _get_head_pos(self.hasEnemyTarget);
		h2 = _get_head_pos(self);
		//h2 = self GetTagOrigin("j_head");
		btp = bulletTracePassed(h1, h2, false, self);
		//btp = bulletTracePassed((h2[0], h2[1], h2[2]+5), (h1[0],h1[1],h1[2]+5), false, self);
		
		if(!btp)
		{ 
			self.hasEnemyTarget = undefined; 
			break;
		}	
		
		self scripts\bots_navigation::_bot_look_at((h1[0]+randomFloatRange(-5,5), h1[1]+randomFloatRange(-5,5), h1[2]+randomFloatRange(-5,5)), 0.5);
		vd = scripts\bots_utilities::_dp(h2, h1, self.angles);
		dist = distance(h2, h1);
		
		if(vd > 0.90)
		{
			//cl(self.name + " targeting: " + self.hasEnemyTarget.name);
			if(self getStance() == "prone"){ self botMoveTo(self getEye()); }
			wait 0.05 + dist * 0.0005;
			
			h1 = _get_head_pos(self.hasEnemyTarget);
			h2 = _get_head_pos(self);
			//h2 = self GetTagOrigin("j_head");
			btp = bulletTracePassed(h1, h2, false, self);
			vd = scripts\bots_utilities::_dp(h2, h1, self.angles);
			
			if(btp){ self thread _bot_press_fire(0.1); }
		}
		
		wait 0.05;
	}
}

_bot_press_fire(delay, duration)
{
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	level endon( "game_ended" );
		
	if(!isDefined(delay)) { delay = 0.3; }
	if(!isDefined(duration)) { duration = randomFloatRange(0.05, 0.3); }
	
	wait delay;
	
	self botAction("+fire");
	if(duration) { wait duration; }
	self botAction("-fire");
	if(duration) { wait duration / 2; }
	
	
	wait delay;
}

_bot_hears_firing()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	level endon( "game_ended" );
	
	for(;;)
	{
		if(isDefined(self.hasEnemyTarget))
		{
			wait 1;
			continue;
		}
		
		players = getentarray( "player", "classname" );
		for(i = 0; i < players.size; i++)
		{
			if(players[i] == self){ continue; }
			dist = distance(self getEye(), players[i] getEye());
			if(isDefined(players[i].hasMadeFiringSound))
			{
				//cl(self.name + " heard firing from " + players[i].name);
				self thread scripts\bots_navigation::_bot_look_at(players[i] getEye());
				wait 0.5;
			}
		}
		
		wait 0.5;
	}
}

_bot_hears_explosion()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	level endon( "game_ended" );
	
	for(;;)
	{
		if(isDefined(level.explosion))
		{
			pos = level.explosion;
			dist = distance(self getEye(), pos);
			wait 0.4 + dist * 0.0005;
			
			//cl(self.name + " heard explosion from " + pos);
			self thread scripts\bots_navigation::_bot_look_at(pos);
		}
		
		wait 0.5;
	}
}

_bot_ads()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	level endon( "game_ended" );

	while(isAlive(self) && isDefined(self.hasEnemyTarget) && isAlive(self.hasEnemyTarget))
	{
		wait randomFloatRange(0.1, 0.3);
		
		if(isDefined(self.hasEnemyTarget))
		{
			dist = distance(self getEye(), self.hasEnemyTarget getEye());
			
			if(dist > 300)
			{
				self botAction( "+ads" );
			}
			
			while(isDefined(self.hasEnemyTarget)){ wait 0.5; }
			
			self botAction( "-ads" );
		}
	}
}

_bot_check_explosive_weapon(explosive)
{
	weapons = self GetWeaponsList();
	weapon = "knife_mp";
	
	for(i = 0; i < weapons.size; i++)
	{
		if(self getAmmoCount(weapons[i]) < 1)
		{
			self takeWeapon(weapons[i]);
		}
		
		weapon = weapons[i];
		
		if(explosive)
		{
			if(isSubStr("c4", weapons[i])
			|| isSubStr("claymore", weapons[i])
			|| isSubStr("grenade", weapons[i])
			|| isSubStr("rpg", weapons[i])
			|| isSubStr("skorpion_acog_mp", weapons[i])
			|| isSubStr("skorpion_reflex_mp", weapons[i]))
			{
				weapon = weapons[i];
				break;
			}
		}
	}
	
	//cl(self.name + " returned weapon: " + weapon);
	
	return weapon;
}

_bot_change_weapon()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	level endon( "game_ended" );
	
	weapon = "knife_mp";

	while(isAlive(self) && isDefined(self.hasEnemyTarget) && isAlive(self.hasEnemyTarget))
	{
		wait randomFloatRange(0.3, 7);
		
		if(isDefined(self.hasEnemyTarget))
		{
			dist = distance(self getEye(), self.hasEnemyTarget getEye());
			
			if(dist < 300)
			{
				weapon = self _bot_check_explosive_weapon(false);
			}
			else
			{
				weapon = self _bot_check_explosive_weapon(true);
			}
			
			self switchToWeapon(weapon);
		}
	}
}
