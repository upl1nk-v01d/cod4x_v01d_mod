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
	level thread _last_allie_taunting();
}

_last_allie_taunting()
{
	level endon("disconnect");
	
	for(;;)
	{
		if(level.playerLives["allies"] < 3)
		{
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{
				if
				(
					isAlive(players[i]) 
					&& players[i].isbot 
					&& players[i].pers["team"] == "allies" 
					&& isDefined(self.ps_ended)
				)
				{
					players[i] playSound("stop_voice");
					v1 = randomIntRange(1,8);
					v2 = randomIntRange(1,9);
					players[i] playSound("ct_taunt" + v1 + "_" + v2);
					wait randomIntRange(5, 10);
				}
			}
		}
		
		wait 1;
	}
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
		//player thread _dev_bot_use_hp();
		//player thread _dev_bot_flashed();
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
		
		self thread _bot_search_target_player();
		self thread _bot_search_target_chopper();
		self thread _bot_hears_firing();
		self thread _bot_hears_explosion();
		self thread _bot_plant_bomb();
		self thread _bot_defuse_bomb();
		self thread _bot_look_at_enemy();
		self thread _bot_use_knife();
		self thread _bot_equip();
		self thread _bot_check_weapon_ammo();
		self thread _bot_prone_watcher();
		self thread _give_bot_hp();
		self thread _bot_use_hp();
		self thread _bot_flashed();
		self thread _bot_follow_player();
		self thread _bot_leader_monitor();
		
		//self thread _dev_bot_has_enemy();
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

_dev_switch_weapon()
{
	self endon ( "disconnect" );
	self endon( "intermission" );
	level endon( "game_ended" );
	
	if(self.isbot){ return; }
	
	for(;;)
	{
		while(!self ButtonPressed("BUTTON_A")){ wait 0.05; }
		
		cl("!!!");
		
		while(self ButtonPressed("BUTTON_A")){ wait 0.05; }
	
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

_dev_bot_use_hp()
{
	self endon ( "disconnect" );
	self endon( "intermission" );
	level endon( "game_ended" );
	
	if(self.isbot){ return; }

	cl("called thread _dev_bot_use_hp() on " + self.name);
	
	//item = "radar_mp";
	//item = "airstrike_mp";
	//item = "helicopter_mp";
	item = "artillery_mp";
	
	for(;;)
	{
		while (!self LeanLeftButtonPressed()){ wait 0.05; }
		
		players = getentarray( "player", "classname" );	
		for(i = 0; i < players.size; i++)
		{
			bot = players[i];
			bot notify("give_bot_hp", item);
		}
		
		while (self LeanLeftButtonPressed()){ wait 0.05; }
		
		wait 0.05;
	}
}

_give_bot_hp()
{
	self endon( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	level endon( "game_ended" );
	
	if(!self.isbot){ return; }
	
	wait randomFloatRange(15, 120);
	
	items = GetArrayKeys(level.hardpointItems);

	for(;;)
	{
		item = items[randomIntRange(0, items.size)];
		self notify("give_bot_hp", item); 
		wait randomFloatRange(60, 240);
	}
}

_bot_use_hp()
{
	self endon( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	level endon( "game_ended" );
	
	if(!self.isbot){ return; }

	for(;;)
	{
		self waittill("give_bot_hp", item);
		if(!self scripts\main::_construct_hp_item(item)){ continue; }
		//cl("bot " + self.name + " got item: " + item);

		wait 1;
		
		while(!isDefined(self.hasEnemyTarget)){ wait 1; }
		
		level notify("incoming", item);

		self _bot_do_airstrike(item);
		self scripts\main::_use_hp_item(item);
		//cl("bot " + self.name + " is using hp item: " + item);
	}
}

_bot_do_airstrike(item)
{
	pos = self.hasEnemyTarget.origin;
	
	if(!isDefined(pos)){ return; }
	
	if(item == "airstrike_mp")
	{
		//thread maps\mp\gametypes\_hardpoints::doArtillery(self getEye(), self, self.pers["team"]); //should be called doAirstike()
		
		self thread maps\mp\gametypes\_hardpoints::finishAirstrikeUsage(pos, maps\mp\gametypes\_hardpoints::useAirstrike);
	}
	else if(item == "artillery_mp")
	{
		self thread scripts\artillery::finishUsage(pos);
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
		aff = self getEye() + anglesToForward((a[0], a[1], a[2])) * 64;
		btf = bulletTrace(self getEye(), aff, true, self);
		//posf = btf["position"];
		ent = btf["entity"];
		
		if(isDefined(ent) && ent.classname == "player" && isAlive(ent) && ent.pers["team"] != self.pers["team"])
		{
			vd = scripts\main::_dp(self getEye(), ent getEye(), self.angles);

			if(vd > 0.5)
			{
				self botAction( "+melee" );
				wait 0.5;
				self botAction( "-melee" );
				//cl("bot " + self.name + " is knifing");
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
		if((isDefined(self.moveToPos) && !isDefined(self.hasEnemyTarget)) || isDefined(self.isCamping))
		{
			enemy = self scripts\bots_utilities::_get_nearest_entity("player","classname", "enemy", self getEye());
			
			if(isDefined(enemy))
			{
				self scripts\bots_navigation::_bot_look_at(enemy getEye());
				self scripts\bots_navigation::_bot_look_at(self.moveToPos);
				wait randomFloatRange(2, 7);	
			}				
		}
		
		wait 1;
	}
}

_bot_search_target_chopper()
{
	self endon("death");
	self endon("disconnect");
	self endon("intermission");
	level endon("game_ended");
	
	for(;;)
	{				
		wait randomFloatRange(0.05, 2);
		
		while(isDefined(self.hasEnemyTarget)){ wait 0.3; }

		if(isDefined(level.choppers))
		{
			for(i = 0; i < level.choppers.size; i++)
			{
				chopper = level.choppers[i];
				
				if(!isDefined(chopper)){ continue; }
				if(chopper.team == self.team){ continue; }
				
				btp = bulletTracePassed(self getEye(), chopper.origin, false, self);
				
				if(!btp){ continue; }
							
				self.hasEnemyTarget = chopper;
					
				//cl(self.name + " seen enemy chopper");

				self thread _bot_change_weapon_accordingly();
				self scripts\bots_navigation::_bot_look_at(chopper.origin);
				vd = scripts\main::_dp(self getEye(), chopper.origin, self.angles);

				if(vd > 0.50)
				{
					//cl(self.name + " targeting enemy chopper");
					self thread _bot_ads();
					self _bot_shoot();
				}
			}
		}
		
		while(isDefined(self.hasEnemyTarget)){ wait 0.3; }		

		wait 1;
	}
}

_bot_search_target_player()
{
	self endon( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	level endon( "game_ended" );
	
	self.hasEnemyTarget = undefined;
	self.enemyTargetLastPos = undefined;
	
	wait randomFloatRange(0.05, 5);
	
	for(;;)
	{
		self.enemyTargetLastPos = undefined;
		
		while(isDefined(self.hasEnemyTarget)){ wait 0.3; }		
		
		wait 0.1 + randomFloatRange(0, 0.5);
		
		self botAction( "-goprone" );
		self botAction("-ads");
		
		enemy = self _get_nearest_entity("player", "classname", "enemy");
		//class, key, team, sp, minDist, maxDist
		
		if(isDefined(enemy))
		{
			if(!isDefined(enemy.model)){ continue; } //not working
			if(enemy.model == ""){ continue; } //not working
			
			hs = _get_head_pos(self);
			he = _get_head_pos(enemy);
			
			if(!isDefined(hs)){ continue; }
			if(!isDefined(he)){ continue; }
			
			//btp = bulletTracePassed(self getEye(), enemy getEye(), false, self);
			btp = bulletTracePassed(hs, he, false, self);
			if(!btp){ continue;	}
			
			//cl(self.name + " seen: " + enemy.name);
			self.hasEnemyTarget = enemy;
			
			if(randomIntRange(0, 10) > 4)
			{
				self botAction( "+goprone" );
			}
			
			//h = self.hasEnemyTarget getEye();
			h = _get_head_pos(self.hasEnemyTarget);
			self thread _bot_change_weapon_accordingly();
			self scripts\bots_navigation::_bot_look_at((h[0], h[1], h[2]), 0.5);
			self thread _bot_ads();
			self _bot_shoot();
			wait 1;
		}
	}
}

_bot_shoot()
{
	self endon("disconnect");
	self endon("intermission");
	self endon("death");
	level endon("game_ended");
		
	while
	(
		isAlive(self) 
		&& isDefined(self.hasEnemyTarget) 
		&& isAlive(self.hasEnemyTarget)
	)
	{		
		h1 = self.hasEnemyTarget.origin;
		if(isPlayer(self.hasEnemyTarget))
		{ 
			h1 = _get_head_pos(self.hasEnemyTarget); 
		}
		
		h2 = _get_head_pos(self);

		btp = bulletTracePassed(h1, h2, false, self);
		if(!btp)
		{ 
			self.hasEnemyTarget = undefined; 
			break;
		}		
		
		a = self.hasEnemyTarget.angles;
		
		if(isDefined(self.hasEnemyTarget.prevPos) && isDefined(self.hasEnemyTarget.velocity))
		{
			ppos = self.hasEnemyTarget.prevPos;
			pos = self.hasEnemyTarget getEye();
			a = VectorToAngles(pos - ppos);
		}
		
		af = h1 + anglesToForward((a[0], a[1], a[2])) * 36;
		
		if(isDefined(self.hasEnemyTarget.velocity))
		{
			af = h1 + anglesToForward((a[0], a[1], a[2])) * (1 + self.hasEnemyTarget.velocity * 2);
		}
		
		self scripts\bots_navigation::_bot_look_at((af[0]+randomFloatRange(-5,5), af[1]+randomFloatRange(-5,5), af[2]+randomFloatRange(-5,5)), 0.3);
		vd = scripts\main::_dp(h2, h1, self.angles);
		dist = distance(h2, h1);
		
		if(vd > 0.75)
		{
			//cl(self.name + " targeting: " + self.hasEnemyTarget.name);
			if(self getStance() == "prone"){ self botMoveTo(self getEye()); }
			wait 0.05 + dist * 0.0002;
			
			if(!isDefined(self.hasEnemyTarget)){ break; }
			
			h1 = self.hasEnemyTarget.origin;
			self.enemyTargetLastPos = h1;
			
			if(isPlayer(self.hasEnemyTarget))
			{ 
				h1 = _get_head_pos(self.hasEnemyTarget); 
			}
			
			h2 = _get_head_pos(self);
			//h2 = self GetTagOrigin("j_head");
			vd = scripts\main::_dp(h2, h1, self.angles);
			btp = bulletTracePassed(h1, h2, false, self);
						
			if
			(
				!btp 
				|| !isAlive(self.hasEnemyTarget) 
			)
			{ 
				self.hasEnemyTarget = undefined; 
				break;
			}	
				
			if(btp && vd > 0.90)
			{ 
				class = scripts\main::_get_weapon_class(self GetCurrentWeapon());
				
				if(isDefined(class) && class == "sniper" || class == "bolt")
				{
					self thread _bot_press_fire(randomFloatRange(0.5, 1));
				}
				else
				{
					self thread _bot_press_fire(randomFloatRange(0.1, 0.3));
				}
			}
		}
		
		wait 0.05;
	}
	
	for(c = 0; c < randomIntRange(1, 3); c++)	
	{
		lp = self.enemyTargetLastPos;
		
		if(!isDefined(lp)){ break; }
		
		self scripts\bots_navigation::_bot_look_at((lp[0]+randomFloatRange(-5,5), lp[1]+randomFloatRange(-5,5), lp[2]+randomFloatRange(-5,5)), 0.3);
		
		vd = scripts\main::_dp(self getEye(), lp, self.angles);

		if(vd > 0.95)
		{
			self thread _bot_press_fire(randomFloatRange(0.1, 0.6));
		}

		wait randomFloatRange(0.3, 1);
	}
	
	self.hasEnemyTarget = undefined;
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
			pos = self.hasEnemyTarget.origin;
			
			if(isPlayer(self.hasEnemyTarget))
			{ 
				pos = self.hasEnemyTarget getEye(); 
			}
			
			dist = distance(self getEye(), pos);
			
			if(dist > 300)
			{
				self botAction("+ads");
			}
			else
			{
				self botAction("-ads");
			}
		}
	}

	self botAction("-ads");
	self.hasEnemyTarget = undefined;
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

_bot_check_weapon_ammo()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	level endon( "game_ended" );
	
	for(;;)
	{
		wait 1;
		
		if(isDefined(self.isPlantingBomb)){ continue; }
		if(isDefined(self.isDefusingBomb)){ continue; }
		
		currentWeapon = self GetCurrentWeapon();
		clipAmmo = self GetWeaponAmmoClip(currentWeapon);
		stockAmmo = self GetWeaponAmmoStock(currentWeapon);
	
		if(clipAmmo < 1 && stockAmmo < 1)
		{
			self takeWeapon(currentWeapon);

			weapons = self GetWeaponsList();
			
			if(isDefined(weapons))
			{
				self _bot_change_weapon(weapons[0]);
			}
		}
	}
}

_bot_check_weapon_class(class)
{
	weapons = self GetWeaponsList();
	weapon = self getCurrentWeapon(); 
	
	for(i = 0; i < weapons.size; i++)
	{		
		if(isSubStr(class, scripts\main::_get_weapon_class(weapon)))
		{
			clipAmmo = self GetWeaponAmmoClip(weapon);
			stockAmmo = self GetWeaponAmmoStock(weapon);
			
			if(clipAmmo < 1 && stockAmmo < 1){ continue; }
			
			weapon = weapons[i];
		}
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
	
	while(isAlive(self) && isDefined(self.hasEnemyTarget) && isAlive(self.hasEnemyTarget))
	{
		wait randomFloatRange(0.3, 0.7);
		
		if(isDefined(self.isPlantingBomb)){ continue; }
		if(isDefined(self.isDefusingBomb)){ continue; }
		
		weapon = self getCurrentWeapon(); 
		
		if(isDefined(self.hasEnemyTarget))
		{
			dist = distance(self getEye(), self.hasEnemyTarget getEye());
			
			if(dist < 500)
			{
				weapon = self _bot_check_weapon_class("pistol");
				weapon = self _bot_check_weapon_class("shotgun");				
				weapon = self _bot_check_weapon_class("rifle");
			}
			else if(dist < 1200)
			{
				weapon = self _bot_check_weapon_class("smg");
				weapon = self _bot_check_weapon_class("rifle");
				weapon = self _bot_check_weapon_class("mg");
				weapon = self _bot_check_weapon_class("rpg");
			}
			else if(dist < 2000)
			{
				weapon = self _bot_check_weapon_class("rifle");
				weapon = self _bot_check_weapon_class("mg");
				weapon = self _bot_check_weapon_class("rpg");
			}
			else if(dist < 3000)
			{
				weapon = self _bot_check_weapon_class("bolt");
				weapon = self _bot_check_weapon_class("sniper");
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
				self.isPlantingBomb = true;
				
				while(!level.bombPlanted && distance(level.bombCarrier getEye(), level.objectivePos) < 80)
				{ 
					wait 0.2; 
					cl(self.name + " is planting bomb"); 
				}
				
				self botAction("-activate");
				self.isPlantingBomb = undefined;
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
				self.isDefusingBomb = true;
				
				while(level.bombPlanted && distance(level.bombCarrier getEye(), level.objectivePos) < 80)
				{ 
					wait 0.2; 
					cl(self.name + " is defusing bomb"); 
				}
				
				self botAction("-activate");
				self.isDefusingBomb = undefined;
				self _bot_change_weapon(prevWeapon);
				wait 1.5;
				self takeWeapon("briefcase_bomb_defuse_mp");
			}
		}
		
		wait 1;
	}
}

_bot_equip()
{
	self endon("disconnect");
	self endon("intermission");
	self endon("death");
	level endon("game_ended");
	
	if(!self.isbot) { return; }
	if(!isDefined(level.botsWeapons)){ return; }

	self takeAllWeapons(); 
	wait 0.5;
	
	c = 0;
	weapon = "knife_mp";
	self GiveWeapon(weapon);

	while(c < 3) //give 3 weapons to bot
	{	
		index = randomIntRange(0, level.botsWeapons.size - 1);
		weapon = level.botsWeapons[index];					
		class = scripts\main::_get_weapon_class(weapon);
		
		if(class != "melee" && class != "grenade" && class != "explosive")
		{
			c++;
		}
		
		self GiveWeapon(weapon);
		self giveMaxAmmo(weapon);
	}
	
	self _bot_change_weapon(weapon);

}

_bot_prone_when_danger(distanceLimit, delay, origin)
{
	self endon("disconnect");
	self endon("intermission");
	self endon("death");
	level endon("game_ended");

	if(!self.isbot) { return; }
	if(!isDefined(distanceLimit) || distanceLimit<1){ distanceLimit=200; }
	if(!isDefined(delay) || delay<0){ delay=0; }
	if(!isDefined(origin)){ origin=self.origin; }
	if(!isDefined(origin)){ cl("no origin defined in _bot_prone_when_danger()", "red"); return; }
	
	wait delay;
	players = getentarray( "player", "classname" );
	for(i=0;i<players.size;i++){
		if(players[i].isbot){
			dist=distance(players[i].origin,self.origin);
			if(isDefined(dist) && dist<distanceLimit){
				self botAction( "+goprone" );
				self botAction( "-gocrouch" );
				self botAction( "-gostand" );
			} else {
				self botAction( "-goprone" );
				self botAction( "+gocrouch" );
				self botAction( "-gostand" );
			}
		}
	}
}

_bot_prone_watcher()
{
	self endon("disconnect");
	self endon("intermission");
	self endon("death");
	level endon("game_ended");

	if(!self.isbot) { return; }
	
	wait randomFloatRange(1, 2);
	
	for(;;)
	{
		
		if(isDefined(self.hasEnemyTarget))
		{
			vd = scripts\main::_dp(self getEye(), self.hasEnemyTarget getEye(), self.angles);
			
			if(vd < 0.95)
			{
				self botAction( "-goprone" );
				self botAction( "+gocrouch" );
			}
		}
			
		wait 1;
	}
}

_dev_bot_flashed()
{
	self endon("disconnect");
	self endon("intermission");
	level endon("game_ended");
	
	if(self.isbot){ return; }

	for(;;)
	{
		while (!self LeanLeftButtonPressed()){ wait 0.05; }
		
		players = getentarray( "player", "classname" );
		for(i = 0 ; i < players.size ; i++)
		{			
			player = players[i];
			if(!player.isbot){ continue; }
			
			player thread _bot_flashed();
			player notify("flashbang", 1, 1, self);
		}
		
		while (self LeanLeftButtonPressed()){ wait 0.05; }
		
		wait 0.05;
	}
}

_bot_flashed()
{
	self endon("disconnect");
	self endon("intermission");
	self endon("death");
	level endon("game_ended");
		
	for(;;)
	{
		self waittill("damaged", eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset);
		
		if(!IsSubStr(sWeapon, "grenade")){ continue; }
		
		self.hasEnemyTarget = undefined;
		
		dist = distance(vPoint, self getEye());
		dur = 1000 / dist;

		self thread _bot_randomly_shooting(dur * 0.5);

		wait dur;
	}
}

_bot_randomly_shooting(dur)
{
	self endon("disconnect");
	self endon("intermission");
	self endon("death");
	level endon("game_ended");

	for(c = 0; c < randomIntRange(1, int(dur) + 2); c++)
	{
		a = self GetPlayerAngles();
		sp = _get_head_pos(self);
		r0 = randomFloatRange(-20, 20);
		r1 = randomFloatRange(-180, 180);
		r2 = randomFloatRange(-20, 20);
		af = sp + anglesToForward((a[0]+r0, a[1]+r1, a[2]+r2))*64;
		
		self thread _bot_press_fire(randomFloatRange(0.1, 0.5), randomFloatRange(0.1, 0.7));
		self scripts\bots_navigation::_bot_look_at(af);
		
		wait randomFloatRange(0.3, 1);
	}
}

_bot_follow_player()
{
	self endon("death");
	self endon("disconnect");
	self endon("intermission");
	level endon("game_ended");

	for(;;)
	{
		level waittill("radio_chatter", message, sender);
		//cl(sender.name + ": message: " + message);
		
		if
		(
			isDefined(sender) 
			&& sender.team == self.team
			&& isSubStr(message, "followme")
			&& distance(self.origin, sender.origin) < 150
		)
		{
			
			self.leader = sender;
			self thread _bot_leader_monitor();
			self notify("bot_follow", self.leader);
		}
	}
}

_bot_leader_monitor()
{
	self endon("disconnect");
	self endon("intermission");
	//self endon("death");
	level endon("game_ended");
	
	if (!self.isbot){ return; }
	
	self.isFollowing = undefined;
	
	for(;;)
	{
		if(isDefined(self.leader))
		{
			if(!isAlive(self.leader))
			{
				self.leader = undefined;
				break;
			}
			else if(isAlive(self) && isAlive(self.leader))
			{
				self.isFollowing = true;
			}
			else if
			(
				!isAlive(self)
				&& isAlive(self.leader)
			)
			{ 
				self.leader iprintln("^1Your buddy "+self.name+" is KIA\n");
				self.leader = undefined;
				self.isFollowing = undefined;
				break;
			}
		}
		
		wait 1;
	}
}