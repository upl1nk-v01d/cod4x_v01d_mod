#include common_scripts\utility;
#include maps\mp\_utility;
#include scripts\cl;
#include scripts\bots_utilities;

init()
{	
	level.skipPrecacheItems=[];
	level.botsWeapons=[];	
	
	if(!isDefined(level.precachedItemsNum))
	{ 
		level.precachedItemsNum=0; 
	}
	
	if(isDefined(level.skipPrecacheItems))
	{
		level.skipPrecacheItems=StrTok("defaultweapon_mp,m16_mp,m16_gl_mp,m16_acog_mp,m16_silencer_mp,m16_reflex_mp,m4_mp,mp5_acog_mp,mp5_reflex_mp,skorpion_silencer_mp,uzi_reflex_mp,uzi_silencer_mp,uzi_acog_mp,p90_acog_mp,p90_reflex_mp,aw50_mp,aw50_acog_mp,g3_acog_mp,g3_silencer_mp,m1014_grip_mp,rpd_acog_mp,rpd_grip_mp,rpd_reflex_mp,saw_acog_mp,saw_grip_mp,saw_reflex_mp,m60e4_reflex_mp,m40a3_acog_mp,remington700_mp,m4_acog_mp,gl_mp,gl_ak47_mp,gl_g3_mp,gl_g36c_mp,gl_m4_mp,gl_m14_mp,gl_m16_mp", "," ); // those weapons will be not available in-game
		//level.skipPrecacheItems=StrTok("m16_mp,m16_reflex_mp,m16_silencer_mp,m16_acog_mp,m16_gl_mp,aw50_mp,aw50_acog_mp,barrett_mp,barrett_acog_mp,skorpion_silencer_mp,skorpion_acog_mp,skorpion_reflex_mp,uzi_reflex_mp,uzi_silencer_mp,uzi_acog_mp,ak74u_silencer_mp,ak74u_reflex_mp,ak74u_acog_mp,m14_reflex_mp,p90_reflex_mp,ak47_reflex_mp,g3_reflex_mp,g36c_reflex_mp,m4_reflex_mp,m1014_grip_mp,m1014_reflex_mp,winchester1200_grip_mp,winchester1200_reflex_mp,rpd_acog_mp,rpd_grip_mp,rpd_reflex_mp,saw_acog_mp,saw_grip_mp,saw_reflex_mp,m60e4_acog_mp,m60e4_grip_mp,m60e4_reflex_mp", "," ); // those weapons will be not available in-game
	}

	for ( index = 0; index < level.weaponList.size; index++ )
	{
		skip=undefined;
		
		for(j=0;j<level.skipPrecacheItems.size;j++){
			if(level.skipPrecacheItems[j] == level.weaponList[index]){ 
				skip=true;
				//cl("33Skipped item precache: " + level.skipPrecacheItems[j]);
				break;
			}
		}
		
		if(isDefined(skip)){ continue; }
		
		precacheItem( level.weaponList[index] );
		level.botsWeapons[level.botsWeapons.size]=level.weaponList[index];
		level.precachedItemsNum++;
		//cl("Precached nr "+level.precachedItemsNum+" weapon: " + level.weaponList[index]);
		//println( "Precached weapon: " + level.weaponList[index] );	
	}
		
	if(getDvar("v01d_item_pickup_mode") != "1"){ return; }
	
	level.droppedItems=[];
	level.droppedItemsCount=0;
	level.claymoreArray = []; 
	level.claymoreID = 0;
	
	level thread on_player_connect();
	level thread _bomb_pickup_init();
}

on_player_connect()
{
	for(;;)
	{
		level waittill("connecting", player);

		player thread on_player_spawned();
	}
}

on_player_spawned()
{
	self endon("disconnect");
	
	for(;;)
	{
		self waittill("spawned_player");
		
		self.gettingItem = undefined;
		
		self thread _disallow_old_drop_weapons_code();
		self thread _claymore_watcher();
		self thread _player_pickup_bomb();
		self thread _bot_pickup_bomb();
		self thread _bot_pickup_item();
		self thread _item_fire_sounds();
		
		//self thread _dev_claymore();
		//self thread _dev_player_spawn_near_bomb();
		//self thread _dev_player_drop_items();
		//self thread _dev_item_test();
	}
}

_item_fire_sounds()
{
	self endon("death");
	self endon("disconnect");
	self endon("intermission");
	level endon("game_ended");
		
	for(;;)
	{		
			self waittill("weapon_fired");
			
			weapon = self GetCurrentWeapon();
			//cl(self.name + " fired " + weapon);
			
			wclass = self scripts\main::_get_weapon_class(weapon);
			
			if(isDefined(wclass)) 
			{
				//cl(self.name + " wclass " + wclass);
				if(wclass=="sniper" && isSubStr(weapon, "sil"))
				{ 
					thread scripts\main::_playSoundInSpace("distshot_silenced_sniper", self getEye());
				}
				if(wclass=="sniper") 
				{ 
					thread scripts\main::_playSoundInSpace("distshot_sniper_medium", self getEye());
				}
				else if(wclass=="rifle" && isSubStr(weapon, "sil"))
				{ 
					thread scripts\main::_playSoundInSpace("distshot_silenced_rifle", self getEye());
				}
				else if(wclass=="rifle")
				{ 
					thread scripts\main::_playSoundInSpace("distshot_rifle_medium", self getEye());
				}
				else if(wclass=="mg")
				{ 
					thread scripts\main::_playSoundInSpace("distshot_rifle_small", self getEye());
				}
				else if(wclass=="smg")
				{ 
					thread scripts\main::_playSoundInSpace("distshot_smg_small", self getEye());
				}
				else if(wclass=="shotgun")
				{ 
					thread scripts\main::_playSoundInSpace("distshot_shotgun", self getEye());
				}
				else if(wclass=="pistol" && isSubStr(weapon, "sil"))
				{ 
					thread scripts\main::_playSoundInSpace("distshot_silenced_pistol", self getEye());
				}
				else if(wclass=="pistol")
				{ 
					thread scripts\main::_playSoundInSpace("distshot_pistol_medium", self getEye());
				}
				else if(wclass=="bolt" && isSubStr(weapon, "sil"))
				{ 
					thread scripts\main::_playSoundInSpace("distshot_silenced_sniper", self getEye());
				}
				else if(wclass=="bolt")
				{ 
					thread scripts\main::_playSoundInSpace("distshot_sniper_small", self getEye());
				}
			}
	}
}

_get_damageable_ents(pos, radius) //from _weapons.gsc
{
	ents = [];
	
	// players
	players = level.players;
	for (i = 0; i < players.size; i++)
	{
		if (!isalive(players[i]) || players[i].sessionstate != "playing")
			continue;
		
		playerpos = players[i].origin + (0,0,32);
		dist = distance(pos, playerpos);
		if (dist < radius)
		{
			newent = spawnstruct();
			newent.isPlayer = true;
			newent.isADestructable = false;
			newent.entity = players[i];
			newent.damageCenter = playerpos;
			ents[ents.size] = newent;
		}
	}
	
	// grenades
	grenades = getentarray("grenade", "classname");
	for (i = 0; i < grenades.size; i++)
	{
		entpos = grenades[i].origin;
		dist = distance(pos, entpos);
		if (dist < radius)
		{
			newent = spawnstruct();
			newent.isPlayer = false;
			newent.isADestructable = false;
			newent.entity = grenades[i];
			newent.damageCenter = entpos;
			ents[ents.size] = newent;
		}
	}

	destructibles = getentarray("destructible", "targetname");
	for (i = 0; i < destructibles.size; i++)
	{
		entpos = destructibles[i].origin;
		dist = distance(pos, entpos);
		if (dist < radius)
		{
			newent = spawnstruct();
			newent.isPlayer = false;
			newent.isADestructable = false;
			newent.entity = destructibles[i];
			newent.damageCenter = entpos;
			ents[ents.size] = newent;
		}
	}

	destructables = getentarray("destructable", "targetname");
	for (i = 0; i < destructables.size; i++)
	{
		entpos = destructables[i].origin;
		dist = distance(pos, entpos);
		if (dist < radius)
		{
			newent = spawnstruct();
			newent.isPlayer = false;
			newent.isADestructable = true;
			newent.entity = destructables[i];
			newent.damageCenter = entpos;
			ents[ents.size] = newent;
		}
	}
	
	return ents;
}

_disallow_old_drop_weapons_code()
{
	wait 0.05;
	self.droppedDeathWeapon = true;	//prevent old item dropping code execution
	//self notify( "killed_player" ); //prevent weapon stowing due to 128 bone errors
	self notify("spawned");
}

_drop_item(attacker, weapon, fullammo)
{
	if(!isDefined(self)){ return; }
	if(!_validate_before_drop(weapon)){ return; }
	
	//cl("self.lastDroppableWeapon: " + self.lastDroppableWeapon);
		
	stockAmmo = self GetWeaponAmmoStock( weapon );
	stockMax = WeaponMaxAmmo( weapon );
	clipSize = WeaponClipSize(weapon);
	clipAmmo = self GetWeaponAmmoClip(weapon); //ammo left in clip
	
	if (stockAmmo > stockMax)
	{
		stockAmmo = stockMax;
	}
	
	item = self dropItem(weapon);
	if(!isDefined(item)){ return; }
	
	if(isAlive(self))
	{
		//self takeWeapon(weapon);
		cl(self.name + " dropped item: " + weapon);
	}
	
	/*if(isDefined(fullAmmo))
	{ 
		item ItemWeaponSetAmmo(clipSize, 0); 
	}
	else
	{ 
		item ItemWeaponSetAmmo(clipAmmo, 0); 
	}*/
		
	item.data = spawnStruct();
	item.data.owner = self;
	item.data.attacker = attacker;
	item.data.weaponItemName = weapon;
	item.data.clipAmmo = clipAmmo;
	item.data.stockAmmo = stockAmmo;
	
	item thread _watch_dropped_item();
}

_validate_before_drop(item)
{
	if(!isDefined(item)){ return false; }
	if(item == "none"){ return false; }
	if(item == "knife_mp"){ return false; }
	if(!self hasWeapon(item)){ return false; }
	if(scripts\main::_get_weapon_class(item) == "none"){ return false; }
	
	return true;
}

_watch_dropped_item()
{
	self endon("death");
				
	//player = attacker;
	droppedItem = self.data.weaponItemName;
	droppedItemsLimit = 5;
	itemNewPos = self.origin;
	itemOldPos = (0,0,0);
	
	while(isDefined(droppedItem) && isDefined(itemNewPos))
	{ 
		if(itemNewPos != itemOldPos)
		{ 
			itemOldPos = itemNewPos; 
		}
		else
		{ 
			break; 
		}
		
		wait 0.3;
		
		itemNewPos = self.origin;
	}
	
	if(!isDefined(droppedItem)){ return; }	
	if(!isDefined(self)){ return; }	
	if(!isDefined(self.origin)){ return; }	
	
	//cl("level.droppedItemsCount");

	level.droppedItemsCount++;
	level.droppedItems[level.droppedItemsCount] = spawnStruct();
	level.droppedItems[level.droppedItemsCount].ent = spawn("script_model", self.origin);
	level.droppedItems[level.droppedItemsCount].ent.targetname = "droppedItem"+level.droppedItemsCount;
	level.droppedItems[level.droppedItemsCount].vis = getEnt("droppedItem"+level.droppedItemsCount, "targetname");
	level.droppedItems[level.droppedItemsCount].vis setModel(self.model);
	level.droppedItems[level.droppedItemsCount].vis.angles = self.angles;
	level.droppedItems[level.droppedItemsCount].ent.waitTimerUnits = 0;
	level.droppedItems[level.droppedItemsCount].ent.data=self.data;
	
	level.droppedItems[level.droppedItemsCount].ent thread _dropped_item_timer();
	
	if(level.droppedItemsCount > droppedItemsLimit)
	{ 
		if(isDefined(level.droppedItems[level.droppedItemsCount - droppedItemsLimit].ent))
		{
			ent = level.droppedItems[level.droppedItemsCount - (droppedItemsLimit-1)].ent;
			index = level.droppedItemsCount - (droppedItemsLimit-1);

			if(isDefined(ent)){ ent delete(); }
		}
	}
	
	self delete(); // remove original dropped item
}

_dropped_item_timer()
{	
	self endon("death");

	//cl("thread _watch_dropped_item()");
	
	if(!isDefined(self.data)){ return; }
	
	self.deleteTimerUnits=100;
	
	if(getDvarFloat("v01d_item_remove_time") > 0)
	{ 
		self.deleteTimerUnits = getDvarFloat("v01d_item_remove_time") * 10; 
	}
	
	maxItemPickupDist = 64;
	self MoveZ(-2, self.deleteTimerUnits * 0.1);
	
	for(;;)
	{
	
		//level waittill("dropped_item");
		//if(!isDefined(self)){ return; }
		
		if(!isDefined(self.waitTimerUnits) || !isDefined(self.deleteTimerUnits))
		{ 
			return; 
		}
		
		if(self.waitTimerUnits > self.deleteTimerUnits)
		{ 
			self delete(); 
			return;
		}
		else
		{ 
			self.waitTimerUnits++; 
		}
		
		if(isDefined(self.origin))
		{
			players = getentarray( "player", "classname" );
			for(i = 0; i < players.size; i++)
			{
				dist = distance(players[i].origin, self.origin);
				
				if(dist < maxItemPickupDist && !isDefined(players[i].gettingItem))
				{
					players[i] thread _item_destroy_timer(self, maxItemPickupDist);
				}
			}
		}
		
		wait 0.1;
	}
}

_player_drop_all_items(attacker)
{
	//self waittill("buymenu_ended");
	
	weapons = self GetWeaponsList();
	
	a = self.angles;
	ca = a;
	
	for(i = 0; i < weapons.size; i++)
	{
		item = weapons[i];
		
		if(!isDefined(item)){ continue; }

		self SetPlayerAngles(ca);
		self _drop_item(attacker, item);
		ca = (ca[0], ca[1]+randomIntRange(30, 90), ca[2]); // for spreading dropped items
	}
	
	self SetPlayerAngles(a);
}

_get_item_nearby(pos, maxItemPickupDist)
{
	h = self.origin;
	//h = self getEye();
	//h = _get_head_pos(self, true);
	a = self.angles;
	aff = h + anglesToForward((a[0], a[1], a[2])) * maxItemPickupDist;
	bt = BulletTrace(h, aff, false, self);
	bt = bt["position"];
	dist = distance(bt, pos);
	
	/*vd = scripts\main::_dp(head, pos, a);

	if(vd > 0.5)
	{
		cl(self.name + " _get_item_nearby() vd:" + vd);
		return true;
	}*/
		
	if(dist < maxItemPickupDist)
	{
		//cl(self.name + " _get_item_nearby() bt:" + bt);
		//cl(self.name + " _get_item_nearby() head:" + head);
		//cl(self.name + " _get_item_nearby() dist:" + dist);
		return true;
	}
	
	return false;
}

_item_destroy_timer(item, maxItemPickupDist)
{
	self endon("death");

	if(!isDefined(item.data)){ return; }
	if(isDefined(self.gettingItem)){ return; }
	
	pickupItemTime = 1;
	
	if(getDvarFloat("v01d_item_pickup_time") > 0)
	{ 
		pickupItemTime = getDvarFloat("v01d_item_pickup_time"); 
	}
	
	while(isAlive(self) && isDefined(item.data))
	{
		weapon = item.data.weaponItemName;
		ammo = item.data.clipAmmo;
		dist = undefined;
		droppable = self GetCurrentWeapon();

		if(isDefined(item.origin))
		{
			dist = distance(self.origin, item.origin);
		}
		
		if(isDefined(dist) && isDefined(weapon) && (self UseButtonPressed() || self.useButtonPressed) && !isSubStr(weapon,"briefcase_bomb"))
		{
			success = false;
			
			if(dist < maxItemPickupDist && item.waitTimerUnits < item.deleteTimerUnits && !isDefined(self.gettingItem))
			{ 
				r = self _get_item_nearby(item.origin, maxItemPickupDist);
				
				if(r)
				{
					self.gettingItem = true;
					success = self scripts\main::_progress_bar(1000,0,1,"");
					self.gettingItem = undefined;
				}
			}
			
			
			if(success)
			{
				if(!isDefined(self)){ return; }
				if(!isDefined(item)){ return; }
				
				self giveWeapon(weapon);
				self notify("picked_weapon", weapon, droppable);
				self switchToWeapon(weapon);
				self SetWeaponAmmoClip(weapon, ammo);
				self setWeaponAmmoStock(weapon, 0);
				self playSound("weap_pickup");
				item.waitTimerUnits=undefined;
				item delete();
			}
			
			if
			(
				dist >= maxItemPickupDist 
				|| !isDefined(item) 
				|| !isAlive(self) 
				|| item.waitTimerUnits > item.deleteTimerUnits
			)
			{
				self.inUse = false;
				
				break;
			}
		} 
		else 
		{
			self.inUse = false;
			
			break;
		}
		
		wait 0.1;
	}
}

_dev_claymore()
{
	wait 1;
	
	self GiveWeapon("claymore_mp");
	self notify("picked_weapon", "claymore_mp");
}

_claymore_watcher()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	level endon( "game_ended" );
	
	for(;;)
	{
		self waittill("grenade_fire", claymore_old, weapname);
		
		if (weapname == "claymore" || weapname == "claymore_mp")
		{
			wait 0.05;
			
			if(isDefined(claymore_old))
			{
				claymore = spawnStruct();
				claymore.ent = spawn("script_model", claymore_old.origin);
				claymore.ent setModel(claymore_old.model);
				claymore.ent.angles = claymore_old.angles;
				
				claymore_old delete();
				
				//claymore maps\mp\_entityheadicons::setEntityHeadIcon("none");
				claymore.trigger = claymore.origin;
				claymore.activated = false;
				claymore.owner = self;
				
				claymore thread _explosives_hit();
				claymore thread _claymore_detonation();
			}
		}
	}
}

_explosives_hit()
{	
	self endon("claymore_explode");

	if(isDefined(self.isMonitored)){ return; }
	self.isMonitored = true;
		
	sp = self.ent.origin;
	
	cl("claymore origin: " + sp);

	for(;;)
	{
		level waittill("bullet_hit_pos", pos);
		
		dist = distance(sp, pos);
		
		if(isDefined(dist) && dist < 8)
		{
			//cl("claymore damaged");
			self _claymore_explode();
		}
	}
}

_claymore_detonation()
{	
	self endon("claymore_explode");

	if(isDefined(self.isPlanted)){ return; }
	self.isPlanted = true;
		
	wait 3;
					
	self.activated = true;
	
	self.ent thread maps\mp\gametypes\_weapons::playClaymoreEffects();
	//self maps\mp\gametypes\_weapons::waitTillNotMoving();

	thread scripts\main::_playSoundInSpace("claymore_activated", self.ent.origin);
				
	damagearea = spawn("trigger_radius", self.ent.origin + (0,0,0-level.claymoreDetonateRadius), 0, level.claymoreDetonateRadius, level.claymoreDetonateRadius*2);

	for(;;)
	{
		damagearea waittill("trigger", player);
		
		if (lengthsquared(player getVelocity()) < 10)
		{
			continue;
		}
		
		if (!player maps\mp\gametypes\_weapons::shouldAffectClaymore(self.ent))
		{
			continue;
		}

		if (player damageConeTrace(self.ent.origin, self.ent) > 0)
		{
			break;
		}
	}
	
	thread scripts\main::_playSoundInSpace("claymore_activated", self.ent.origin);

	wait 0.7;
	
	self _claymore_explode();
}

_claymore_explode()
{
	maxDamage = 200;
	maxDist = 300;
	
	playfx(level.claymore_explosion, self.ent.origin);
	
	ents = _get_damageable_ents(self.ent.origin, maxDist);
	
	for(i = 0; i < ents.size; i++)
	{
		victim = ents[i];
		dist = distance(victim.damageCenter, self.ent.origin);
		
		if(isDefined(victim) && isDefined(dist) && dist < maxDist)
		{
			damage = int(maxDamage * (100 / dist));
			//cl("dist: " + dist);
			//cl("damage: " + damage);
			
			btp = bulletTracePassed(self.ent.origin, victim.damageCenter + (0,0,20), false, self);
			if(!btp){ damage = int(damage * 0.2); }
			
			victim maps\mp\gametypes\_weapons::damageEnt(
				self.ent, // eInflictor = the entity that causes the damage (e.g. a claymore)
				self.owner, // eAttacker = the player that is attacking
				damage, // iDamage = the amount of damage to do
				"MOD_EXPLOSIVE", // sMeansOfDeath = string specifying the method of death (e.g. "MOD_PROJECTILE_SPLASH")
				"claymore_mp", // sWeapon = string specifying the weapon used (e.g. "claymore_mp")
				self.ent.origin, // damagepos = the position damage is coming from
				vectornormalize(victim.damageCenter - self.ent.origin) // damagedir = the direction damage is moving in
			);
		}
	}

	thread scripts\main::_playSoundInSpace("detpack_explo_main",self.ent.origin);
	//thread scripts\main::_playSoundInSpace("close_expl",self.ent.origin);
	thread scripts\main::_playSoundInSpace("clboom",self.ent.origin);
	thread scripts\main::_playSoundInSpace("distboom",self.ent.origin);
	
	wait 0.05;
		
	if(isDefined(self.ent)){ self.ent delete(); }
		
	self notify("claymore_explode");
}

_dev_player_spawn_near_bomb()
{
	p = level.sabBomb.curOrigin;
	self SetOrigin((p[0]-128,p[1]-128,p[2]));
}

_bomb_pickup_init()
{	
	trigger = getEnt( "sab_bomb_pickup_trig", "targetname" );
	trigger delete();
	
	level.sabBomb.trigger = spawn("trigger_radius", level.sabBomb.curOrigin, 0, 0, 0); //solution for pickupObjectDelay()
	level.sabBomb.trigger.targetname = "sab_bomb_pickup_trig";
	level.sabBomb.trigger.baseOrigin = level.sabBomb.curOrigin;
}

_player_pickup_bomb()
{
	self endon("disconnect");
	self endon("death");
	self endon("intermission");
	level endon("game_ended");	
	
	if(self.isbot){ return; }
	
	wait 3;
	
	//cl("bombZones axis: " + level.bombZones["axis"].curOrigin);
	//cl("bombZones allies: " + level.bombZones["allies"].curOrigin);

	for(;;)
	{
		self waittill("use_button_pressed");

		self _pickup_bomb();
	}
}

_bot_pickup_bomb()
{
	self endon("disconnect");
	self endon("death");
	self endon("intermission");
	level endon("game_ended");	
	
	if(!self.isbot){ return; }
	
	for(;;)
	{
		if(!isDefined(level.bombCarrier) && !level.bombPlanted)
		{
			if(distance(self getEye(), level.sabBomb.curOrigin) < 64)
			{
				self scripts\bots_navigation::_bot_look_at(level.sabBomb.curOrigin);
				self.useButtonPressed = true;
				self _pickup_bomb();
				self.useButtonPressed = false;
			}
		}
		
		wait 0.3;
	}
}

_pickup_bomb()
{	
	if(isDefined(self.gettingItem)){ return; }
	if(level.bombPlanted){ return; }
	
	maxItemPickupDist = 64;
	dist = distance(self getEye(), level.sabBomb.curOrigin);
		
	if(dist > maxItemPickupDist)
	{
		return;
	}
	
	//cl("bomb pick dist: " + dist);

	success = false;
	r = self _get_item_nearby(level.sabBomb.curOrigin, maxItemPickupDist);
				
	if(r)
	{		
		self.gettingItem = true;
		success = self scripts\main::_progress_bar(1000,0,1,"");
		self.gettingItem = undefined;
	}

	if(!success){ return; }
	
	self maps\mp\gametypes\_gameobjects::giveObject(level.sabBomb);
	level.sabBomb maps\mp\gametypes\_gameobjects::setCarrier(self);
	level.sabBomb maps\mp\gametypes\sab::onPickup(self);
	level.sabBomb notify("pickup_object");
	level.sabBomb.visuals[0] = getEnt("sab_bomb", "targetname");
	level.sabBomb.visuals[0] hide();
	
	self.isBombCarrier = true;
	level.bombCarrier = self;
	
	level notify ("bomb_is_picked_up");

	//array is not an entity: (file 'scripts/items.gsc', line 663)
	//level.sabBomb.visuals hide();
	
	self thread _drop_bomb();
	self thread _plant_bomb();
}

_drop_bomb()
{
	self endon("disconnect");
	self endon("intermission");
	level endon("game_ended");	
	self endon("bomb_planted");
	
	self waittill("death");
	
	if(isDefined(level.sabBomb.carrier))
	{
		self notify("dropped_bomb");
		level notify ("bomb_is_dropped");
	
		level.sabBomb.carrier maps\mp\gametypes\_gameobjects::takeObject(level.sabBomb);
		level.sabBomb maps\mp\gametypes\sab::onDrop(self);
		level.sabBomb notify("dropped");
		level.sabBomb.visuals[0] show();
		
		self.isBombCarrier = false;
		level.bombCarrier = undefined;
	}
}

_plant_bomb()
{
	self endon("disconnect");
	self endon("intermission");
	level endon("game_ended");	
	self endon("dropped_bomb");
	
	self waittill("bomb_planted");
		
	if(isDefined(level.sabBomb) && isDefined(level.sabBomb.carrier))
	{
		level.sabBomb.carrier maps\mp\gametypes\_gameobjects::takeObject(level.sabBomb);
	}
	
	self.isBombCarrier = false;
	level.bombCarrier = undefined;
}

_dev_player_drop_items()
{
	if(self.isbot){ return; }
	
	self waittill("buymenu_ended");
	wait 1;
	self thread _player_drop_all_items(self);
}

_bot_pickup_item()
{
	self endon("disconnect");
	self endon("death");
	self endon("intermission");
	level endon("game_ended");	
	
	if(!self.isbot){ return; }
	
	self.useButtonPressed = false;
	
	//droppedItems = [];
	
	for(;;)
	{
		if(!isDefined(self.hasEnemyTarget))
		{
			for(i = 0; i < level.droppedItems.size; i++)
			{
				if(!isDefined(level.droppedItems[i])){ continue; }
				
				item = level.droppedItems[i].ent;
				
				if(!isDefined(item.origin)){ continue; }
				
				//cl("item.origin: " + item.origin);
				
				if(distance(self getEye(), item.origin) < 64)
				{
					self.useButtonPressed = true;
					self botAction("+gocrouch");
					
					self scripts\bots_navigation::_bot_look_at(item.origin);
					
					while(isDefined(item)){ wait 0.1; }
					
					self.useButtonPressed = false;
					self botAction("-gocrouch");
				}
				else if(distance(self getEye(), item.origin) < 200)
				{
					isGoingToPoint = self.isGoingToPoint;
					self botMoveTo(item.origin);
					wait 5;
					self.isGoingToPoint = isGoingToPoint;
				}
			}
		}
		
		wait 0.35;
	}
}

_dev_item_test()
{
	wait 3;
	
	cl(self.name + " _dev_item_test()");

	//self waittill("buymenu_ended");
	
	item = "beretta_mp";
	
	cl("item: " + item);
	
	//self GiveWeapon(item);
	//self notify("picked_weapon", item);
	//self SetViewModel( "viewmodel_hands_russian_vetrn" );
	
	for(;;)
	{
		//self ShowViewModel();
		wait 1;
		
		alias = "distshot_sniper_medium";
		thread scripts\main::_playSoundInSpace(alias, self getEye());
		//self playLocalSound(alias);

		cl("playing alias: " + alias);
	}
}