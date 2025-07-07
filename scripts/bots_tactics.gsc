#include maps\mp\_load;
#include maps\mp\_utility;
#include scripts\cl;
#include scripts\pl;
#include scripts\bots_utilities;

init()
{
	if (getDvar("v01d_bots") != "1"){ return; }
	
	if(scripts\bots_navigation::_check_if_no_nodes())
	{ 
		return true; 
	}
	
    level thread _player_connected();
}

_player_connected()
{
	level endon ( "disconnect" );
	level endon( "intermission" );
	level endon( "game_ended" );
	
	for(;;)
	{
		level waittill("connected", player);
		
		player thread _bot_spawn_loop();
		//player thread _dev_weapons();
		//player thread _dev_bot_weapons();
	}
}

_dev_bot_weapons()
{
	self endon ( "disconnect" );
	self endon( "intermission" );
	level endon( "game_ended" );
	
	if(self.isbot){ return; }

	for(;;)
	{
		while (!self LeanLeftButtonPressed()){ wait 0.05; }
		
		players = getentarray( "player", "classname" );
		for(i1 = 0 ; i1 < players.size ; i1++)
		{
			weapons = players[i1] GetWeaponsList();
			
			if(isDefined(weapons))
			{
				for(i2 = 0 ; i2 < players.size ; i2++)
				{
					if(isDefined(weapons[i2]))
					{
						cl(players[i1].name + " weapon: " + weapons[i2]);
						//players[i1] switchToWeapon(weapons[i2]);
						players[i1] _bot_change_weapon_accordingly(weapons[i2]);
						//cl(players[i1] GetCurrentWeapon());
					}
				}
			}
		}
		
		while (self LeanLeftButtonPressed()){ wait 0.05; }
		
		wait 0.05;
	}
}

_dev_weapons()
{
	self endon ( "disconnect" );
	self endon( "intermission" );
	level endon( "game_ended" );
	
	if(self.isbot){ return; }

	cl("called thread _dev_weapons() on " + self.name);
	
	classes = StrTok("pistol,mg,smg,rpg,sniper", ",");
	pistols = StrTok("aaa,bb,cc", ",");
	snipers = StrTok("111,22,33", ",");
	
	c1 = [];
	
	for(;;)
	{
		while (!self LeanLeftButtonPressed()){ wait 0.05; }
		
		for(i = 0; i < classes.size; i++)
		{
			c1[classes[i]] = i;
		}
		
		r = GetArrayKeys( c1 );
		for(i = 0; i < r.size; i++)
		{
			cl(r[i]);
		}
		
		while (self LeanLeftButtonPressed()){ wait 0.05; }
		
		wait 0.05;
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
		
		self thread _bot_search_target();
		self thread _bot_hears_firing();
		self thread _bot_hears_explosion();
		//self thread _bot_search_enemy_choppers();
		self thread _bot_plant_bomb();
		self thread _bot_defuse_bomb();
		self thread _bot_look_at_enemy();
		self thread _bot_use_knife();
		
		//self thread _dev_bot_has_enemy();
	}
}

_bot_use_knife()
{
	self endon( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	level endon( "game_ended" );
			
	for(;;)
	{
		a = self.angles;
		aff = self getEye() + anglesToForward((a[0], a[1], a[2])) * 80;
		btf = bulletTrace(self getEye(), aff, true, self);
		//posf = btf["position"];
		ent = btf["entity"];
		
		if(isDefined(ent) && ent.classname == "player" && isAlive(ent) && ent.pers["team"] != self.pers["team"])
		{
			vd = scripts\bots_utilities::_dp(self getEye(), ent getEye(), self.angles);

			if(vd > 0.5)
			{
				self botAction( "+melee" );
				wait 0.5;
				self botAction( "-melee" );
				cl("bot " + self.name + " is knifing");
			}
		}
		
		wait 0.5;
	}
}

_bot_look_at_enemy()
{
	self endon( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	level endon( "game_ended" );
	
	wait 5;
		
	for(;;)
	{
		if(isDefined(self.moveToPos) && !isDefined(self.hasEnemyTarget))
		{
			enemy = self scripts\bots_utilities::_find_nearest_enemy(self getEye());
			self scripts\bots_navigation::_bot_look_at(enemy getEye());
			self scripts\bots_navigation::_bot_look_at(self.moveToPos);
			wait randomFloatRange(2, 7);			
		}
		
		wait 1;
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
		if(!isDefined(self.isPlanting))
		{
			for(i = 0; i < level.choppers.size; i++)
			{
				chopper = level.choppers[i];
				
				if(chopper.team == self.team){ continue; }
				
				btp = bulletTracePassed(self getEye(), chopper.origin, false, self);
				
				if(!btp){ continue; }

				self scripts\bots_navigation::_bot_look_at(chopper.origin);
				vd = scripts\bots_utilities::_dp(self getEye(), chopper.origin, self.angles);
				self thread _bot_change_weapon_accordingly();

				if(vd > 0.75)
				{
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
				self scripts\bots_navigation::_bot_look_at((h[0], h[1], h[2]-5), 0.5);
				//h = self.hasEnemyTarget GetTagOrigin("j_head");
				//self scripts\bots_nav::_bot_look_at((h[0], h[1], h[2]+5));
				self thread _bot_change_weapon_accordingly();
				self thread _bot_ads();
				self _bot_shoot();
				wait 1;
				self botAction( "-goprone" );
				self botAction("-ads");
			}
		}
	}
}

_dev_bot_has_enemy()
{
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "death" );
	level endon( "game_ended" );
	
	for(;;)
	{
		if(isDefined(self.hasEnemyTarget))
		{
			//cl(self.name + " has enemy: " + self.hasEnemyTarget.name);
		}
		
		wait 1;
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
				self botAction("+ads");
			}
			
			while(isDefined(self.hasEnemyTarget)){ wait 0.5; }
			
			self botAction("-ads");
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
		
		a = self.hasEnemyTarget.angles;
		
		if(isDefined(self.hasEnemyTarget.prevPos))
		{
			ppos = self.hasEnemyTarget.prevPos;
			pos = self.hasEnemyTarget getEye();
			a = VectorToAngles(pos - ppos);
		}
		
		af = h1 + anglesToForward((a[0], a[1], a[2])) * (1 + self.hasEnemyTarget.velocity * 2);
		self scripts\bots_navigation::_bot_look_at((af[0]+randomFloatRange(-5,5), af[1]+randomFloatRange(-5,5), af[2]+randomFloatRange(-5,5)), 0.3);
		vd = scripts\bots_utilities::_dp(h2, h1, self.angles);
		dist = distance(h2, h1);
		
		if(vd > 0.75)
		{
			//cl(self.name + " targeting: " + self.hasEnemyTarget.name);
			if(self getStance() == "prone"){ self botMoveTo(self getEye()); }
			wait 0.05 + dist * 0.0002;
			
			if(!isDefined(self.hasEnemyTarget)){ break; }
			
			h1 = _get_head_pos(self.hasEnemyTarget);
			h2 = _get_head_pos(self);
			//h2 = self GetTagOrigin("j_head");
			btp = bulletTracePassed(h1, h2, false, self);
			vd = scripts\bots_utilities::_dp(h2, h1, self.angles);
			
			if(btp && vd > 0.95)
			{ 
				class = scripts\main::_classCheck(self GetCurrentWeapon());
				
				if(isDefined(class) && class == "sniper")
				{
					self thread _bot_press_fire(randomFloatRange(0.5, 1));
				}
				else
				{
					self thread _bot_press_fire(randomFloatRange(0.2, 0.8));
				}
			}
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
		
	if(!isDefined(delay)) { delay = 0.05; }
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
		
		if(explosive)
		{
			if(
				isSubStr("rpg", weapons[i])
				|| isSubStr("skorpion_acog_mp", weapons[i])
				|| isSubStr("skorpion_reflex_mp", weapons[i])
				|| isSubStr("barrett_acog_mp", weapons[i])
				&& !isSubStr("c4", weapons[i])
				&& !isSubStr("claymore", weapons[i])
			)
			{
				weapon = weapons[i];
				break;
			}
		}
		
		weapon = weapons[0];
	}
	
	//cl(self.name + " returned weapon: " + weapon);
	
	return weapon;
}

_bot_change_weapon_accordingly()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	level endon( "game_ended" );
	
	weapon = "knife_mp";

	while(isAlive(self) && isDefined(self.hasEnemyTarget) && isAlive(self.hasEnemyTarget))
	{
		wait randomFloatRange(0.3, 0.7);
		
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
			
			self _bot_change_weapon(weapon);
		}
	}
}

_bot_plant_bomb()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	level endon( "game_ended" );
	
	for(;;)
	{
		if(isDefined(level.bombCarrier) && level.bombCarrier == self)
		{
			if(distance(level.bombCarrier getEye(), level.objectivePos) < 80)
			{
				prevWeapon = self GetCurrentWeapon();
				self GiveWeapon("briefcase_bomb_mp");
				self _bot_change_weapon("briefcase_bomb_mp");
				self botAction("+activate");
				while(!level.bombPlanted)
				{ 
					wait 0.2; 
					cl(self.name + " is planting bomb"); 
				}
				self botAction("-activate");
				self _bot_change_weapon(prevWeapon);
				wait 1.5;
				self takeWeapon("briefcase_bomb_mp");
			}
		}
		
		wait 1;
	}
}

_bot_defuse_bomb()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	level endon( "game_ended" );
		
	for(;;)
	{
		if(!isDefined(level.bombCarrier) && level.bombPlanted && level.bombPlantedBy!= self.pers["team"])
		{
			if(distance(self getEye(), level.objectivePos) < 80)
			{
				prevWeapon = self GetCurrentWeapon();
				self GiveWeapon("briefcase_bomb_defuse_mp");
				self _bot_change_weapon("briefcase_bomb_defuse_mp");
				self botAction("+activate");
				while(level.bombPlanted)
				{ 
					wait 0.2; 
					cl(self.name + " is defusing bomb"); 
				}
				self botAction("-activate");
				self _bot_change_weapon(prevWeapon);
				wait 1.5;
				self takeWeapon("briefcase_bomb_defuse_mp");
			}
		}
		
		wait 1;
	}
}
