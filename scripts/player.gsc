#include maps\mp\_load;
#include maps\mp\_utility;
#include scripts\cl;

/*
SetupCallbacks()
{
	level.onScriptCommand = level.callbackScriptCommand;
}

Callback_ScriptCommand(command, arguments)
{
    waittillframeend;

    //if(isDefined(self.name))
    if(isDefined(self))
	{
        //print("Executed by: " + self.name + " Command: " + command + " Args: " + arguments + "\n");
		if(command == "player_switch_weapon")
		{
			self thread _player_switch_weapon(arguments);
		}
	}
    else
        print("Executed by: Rcon Command: " + command + " Args: " + arguments + "\n");
}
*/
init()
{	
	//addScriptCommand("player_switch_weapon", 1);
	
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
		
		player thread _player_spawn_loop();
		//player thread _dev_test_button();
	}
}

_player_spawn_loop()
{
	//self endon("death");
	self endon("disconnect");
	self endon("intermission");
	level endon("game_ended");
	
	for(;;)
	{
		self waittill("spawned_player");
		
		self thread _player_picked_weapon();
		self thread _player_killed();
		self thread _player_watch_change_items();	
		self thread _ensure_body_model_loaded();
		self thread _player_moving();
		self thread _player_firing_weapon();
		self thread _player_stop_moving_when_prone();
		self thread _player_breathe();
		
		if(!self.isbot)
		{
			self thread _player_spawn_init();
			self thread _player_switch_weapons();
			self thread _player_use_button_watcher();
			self thread _player_is_proning();
			self thread _player_cg_cmds();
			self thread _player_mouse();
			
			//self thread _dev_iterate_weapons();
			self thread _dev_player_changed_weapon();
		}
		
		//f = testfunction(123); //function has to be called without on self
		//m = self testmethod(3.4); //method has to be called on self

		//cl("f: " + f);
		//cl("m: " + m);
	}
}

_player_cg_cmds()
{
	if(self.isbot){ return; }
	
	self setClientDvar("cg_blood", 0); 
	self setClientDvar("cg_friendlyNameFadeIn", 100000);
	self setClientDvar("cg_enemyNameFadeIn", 100000);
	self setClientDvar("cg_centertime", 0);
	/*self setClientDvar("r_blur", 0);
	self setClientDvar("r_filmUseTweaks", 0);
	self setClientDvar("r_filmTweakEnable", 1);
	self setClientDvar("r_filmTweakBrightness", 0);
	self setClientDvar("r_filmTweakContrast", 1.4);
	self setClientDvar("r_filmTweakDarkTint", "1 1 1");
	self setClientDvar("r_filmTweakLightTint", "1 1 1");
	self setClientDvar("r_filmTweakDesaturation", 0.4);
	self setClientDvar("r_glowTweakEnable", 1);
	self setClientDvar("r_glowUseTweaks", 1);
	self setClientDvar("r_glowTweakBloomDesaturation", 1);*/
	self setClientDvar("m_pitch",0.022);
	self setClientDvar("m_yaw",0.022);
	self setClientDvar("stopSpeed",100);
	self setClientDvar("ui_showmap",1);
	//self setClientDvar("perk_weapReloadMultiplier", 0.1);
}

_player_mouse()
{
	self endon("disconnect");
	self endon("intermission");
	level endon("game_ended");
	
	ma=0.022;
	
	for(;;)
	{
		while(level.slowMo==false){ wait 0.05; }
		
		ts = float(getDvar("timescale"));
		
		if(isDefined(ts) && !self.isbot && self.sessionstate == "playing")
		{
			self setClientDvars("m_pitch", ma * ts, "m_yaw", ma * ts);
		}
		
    	wait 0.05;
    }
}

_player_mouse_accel(t1, t2)
{
	self endon("death");
	self endon("disconnect");
	self endon("intermission");
	level endon("game_ended");
	
	ma=0.022; t1*=0.2; t2*=0.2;
	
	while(ma>0.001)
	{
		if(!self.isbot && self.sessionstate == "playing")
		{
			self setClientDvars("m_pitch", ma, "m_yaw", ma);
		}

    	ma -= 0.002; 
		wait 0.05;
    }
	
    while(ma<0.022)
	{
		if(!self.isbot && self.sessionstate == "playing")
		{
			self setClientDvars("m_pitch", ma, "m_yaw", ma);
		}
		
    	ma+=0.002; 
		wait 0.05;
    }
}

_player_breathe(){
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	level endon( "game_ended" );
	
	if (getDvar("v01d_dev") != "0"){ return; }
	if (getDvarInt("bots_main_debug") != 0){ return; }

	offsetY = 0.1; s2=0;
	offsetX = 0.1; s1=0;
	offsetZ = 0; s3=0;; 
	k=1;

	for(;;){
		if(isAlive(self) && !isDefined(self.buyMenuShow)){
			if(isDefined(self.aimWobling)){ k=self.aimWobling; }
			if (s1==0){ offsetY+=0.02; if (offsetY>=0.2) { s1=1; } }
			if (s1==1) { offsetY-=0.02; if (offsetY<=-0.2) { s1=0; } }	
			if (s2==0){ offsetX+=0.01; if (offsetX>=0.1) { s2=1; } }
			if (s2==1) { offsetX-=0.01; if (offsetX<=-0.1) { s2=0; } }	
			curView = self getPlayerAngles();
			if(self HoldBreathButtonPressed()) { k=0.05; } 
			else if(self PlayerADS()) { k=0.2; } 
			else { k=1; }
			self setPlayerAngles((curView[0]+offsetY*k, curView[1]+offsetX*k, curView[2]+offsetZ*k)); 
		}
		wait 0.05;
	}
}

_player_is_proning()
{
	self endon("disconnect");
	self endon("intermission");
	level endon("game_ended");
	self endon("death");

	while(isAlive(self))
	{
		if(self getStance() == "prone")
		{ 
			self.isProning = true; 
		}
		else
		{ 
			self.isProning = undefined; 
		}
		
		wait 0.05;
	}
	
	self.isProning = undefined;
}

_player_firing_weapon()
{
	self endon("death");
	self endon("disconnect");
	self endon("intermission");
	level endon("game_ended");
	
	for(;;)
	{
		self waittill("weapon_fired");
		self.isFiring = true;
		//self thread _delay_after_firing();
		weapon = self GetCurrentWeapon();

		if
		(
			isSubStr(weapon,"grenade") 
			|| isSubStr(weapon,"claymore") 
			|| isSubStr(weapon,"knife")
		)
		{ 
			continue; 
		}
		
		self thread _player_firing_sound(2);
		
		thread scripts\main::_bullet_fired(weapon);
	}
}

_player_firing_sound(duration)
{
	if(!isDefined(duration)){ duration = 1; }
	if(isDefined(self.hasMadeFiringSound)){ return; }
	
	self.hasMadeFiringSound = true;
	wait duration;
	self.hasMadeFiringSound = undefined;
}

_player_moving()
{
	self endon("death");
	self endon("disconnect");
	self endon("intermission");
	level endon("game_ended");
	
	self.velocity = 0;
	self.aimWobling = 0.5;
	
	for(;;)
	{
		if(isAlive(self))
		{
			self.prevPos = self getEye(); 
			wait 0.1;
			self.velocity = distance( self getEye(), self.prevPos ); 

			if(self.velocity > 25)
			{
				curView = self getPlayerAngles();
				self setPlayerAngles((curView[0]+randomFloatRange(-0.5, 0.5), curView[1]+randomFloatRange(-0.5, 0.5), curView[2]+randomFloatRange(-3.5, 3.5))); 
				wait 0.05;
				curView = self getPlayerAngles();
				if(self.aimWobling<2){ self.aimWobling+=0.05; }
				self setPlayerAngles((curView[0], curView[1], 0));
			} 
			else if(self.velocity < 25 && self.velocity > 0.1)
			{
				curView = self getPlayerAngles();
				self setPlayerAngles((curView[0]+randomFloatRange(-0.35, 0.35), curView[1]+randomFloatRange(-0.35, 0.35), curView[2]+randomFloatRange(-0.7, 0.7))); 
				if(self.aimWobling>0.5){ self.aimWobling-=0.05; }
				wait 0.05;
				curView = self getPlayerAngles();
				self setPlayerAngles((curView[0], curView[1], 0));
			}
		}
		
		wait 0.05;
	}
}

_player_stop_moving_when_prone()
{
	self endon("disconnect");
	self endon("intermission");
	level endon("game_ended");
	self endon ("death");

	while(isAlive(self))
	{
		if(isDefined(self.isProning) && isDefined(self.isReloading))
		{
			self setMoveSpeedScale(0);
		}
		
		wait 0.2;
	}
	
	self.isProning = undefined;
}

_player_sliding()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	level endon( "game_ended" );
	
	for(;;){
		self waittill("damage",amount,attacker);
		
		wait 0.05;
	}
}

_ensure_body_model_loaded()
{
	self endon( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	level endon( "game_ended" );
	
	self.modelLoaded = undefined;
	wait 3;
	self.modelLoaded = true;
}

_dev_player_changed_weapon()
{
	self endon ( "disconnect" );
	self endon( "intermission" );
	level endon( "game_ended" );
		
	//cl(self.name + " thread _dev_test_notify()!"); 
	
	for(;;)
	{
		self waittill("weapon_change", weapon);
		
		weapon = self GetCurrentWeapon();
		//m = GetWeaponAmmoName(weapon);
		
		//cl(self.name + " called GetWeaponAmmoName(): " + m);

	}
}

_player_switch_weapons()
{
	self endon ( "disconnect" );
	self endon( "intermission" );
	level endon( "game_ended" );
		
	//cl(self.name + " thread _dev_test_notify()!"); 
	
	for(;;)
	{
		self waittill("weaponslot", arg1, arg2);
		
		//if(isDefined(arg1)){ cl(self.name + " weaponslot arg1: " + arg1); }
		//if(isDefined(arg2)){ cl(self.name + " weaponslot arg2: " + arg2); }
		
		if(isDefined(arg1) && arg1 == "1")
		{
			self thread _player_switch_weapon("primary");
		}
		else if(isDefined(arg1) && arg1 == "2")
		{
			self thread _player_switch_weapon("secondary");
		}
		else if(isDefined(arg1) && arg1 == "3")
		{
			self thread _player_switch_weapon("sidearms");
		}
		/*else if(isDefined(arg1) && arg1 == "3")
		{
			self thread _player_switch_weapon("sidearms");
		}*/

		wait 0.05;
	}
}

_dev_test_button()
{
	self endon ( "disconnect" );
	self endon( "intermission" );
	level endon( "game_ended" );
	
	if(self.isbot){ return; }
	
	cl(self.name + " thread button _dev_test_button()!");
	
	for(;;)
	{
		//while(!self testbutton()){ wait 0.05; };
		cl(self.name + " test button pressed!");
		//while(self testbutton()){ wait 0.05; };

		wait 0.05;
	}
}

_player_spawn_init()
{	
	self.inventory = [];
	
	self.inventory[0] = "none";
	self.inventory[1] = "none";
	self.inventory[2] = "none";
	self.inventory[3] = "none";
	
	self.weaponSlotSelected = 0;
	
	self _player_switch_weapon("primary");
}

_player_use_button_watcher()
{
	self endon("disconnect");
	self endon("death");
	self endon("intermission");
	level endon("game_ended");
	
	self.useButtonPressed = false;
			
	for(;;)
	{
		while(!self UseButtonPressed()){ wait 0.05; }
		
		self.useButtonPressed = true;
		self notify("use_button_pressed");
		
		while(self UseButtonPressed()){	wait 0.05; }
		
		self.useButtonPressed = false;
		self notify("use_button_released");

		wait 0.05;
	}
}

_dev_iterate_weapons()
{
	self endon ( "disconnect" );
	self endon ( "death" );
	self endon( "intermission" );
	level endon( "game_ended" );
		
	for(;;)
	{
		while(!self HoldBreathButtonPressed()){ wait 0.05; }
		
		weapon = "ak74u_silencer_mp";
		
		self GiveWeapon(weapon);
		self switchToWeapon(weapon);
		
		for(i =0; i < level.weaponList.size; i++)
		{
			weapon = level.weaponList[i];
			self _dev_check_weapon_class(weapon);
		}
		
		while(self HoldBreathButtonPressed()){ wait 0.05; }
		
	}
}

_dev_check_weapon_class(weapon)
{	
	//sniper,bolt,rpg,gl,rifle,shotgun,mg,smg,
	//pistol,grenade,explosive,melee

	if
	(
		scripts\main::_get_weapon_class(weapon) == "sniper"
		|| scripts\main::_get_weapon_class(weapon) == "bolt"
		|| scripts\main::_get_weapon_class(weapon) == "rpg"
		|| scripts\main::_get_weapon_class(weapon) == "gl"
		|| scripts\main::_get_weapon_class(weapon) == "rifle"
		|| scripts\main::_get_weapon_class(weapon) == "shotgun"
		|| scripts\main::_get_weapon_class(weapon) == "mg"
		|| scripts\main::_get_weapon_class(weapon) == "smg"
		|| scripts\main::_get_weapon_class(weapon) == "pistol"
		|| scripts\main::_get_weapon_class(weapon) == "grenade"
		|| scripts\main::_get_weapon_class(weapon) == "explosive"
		|| scripts\main::_get_weapon_class(weapon) == "melee"
	)
	{
	}		
	else
	{
		cl("unclassified weapon: " + weapon);
	}
}

_extract_weapon_name(str)
{
	r = "";
	
	for(i = 0; i < str.size; i++)
	{
		if
		(
			str[i] == "_" 
			&& str[i+1] == "m" 
			&& str[i+2] == "p"
		)
		{ 
			break; 
		}

		r += str[i];
	}
	
	return r;
}

_player_picked_weapon()
{
	self endon("disconnect");
	self endon("intermission");
	self endon("death");
	level endon("game_ended");	
	
	if(self.isbot){ return; }
	
	for(;;)
	{
		self waittill("picked_weapon", weapon);		
		//cl(self.name + " picked weapon: " + weapon);
		//sniper,bolt,rpg,gl,rifle,shotgun,mg,smg,pistol,grenade,explosive,melee
		
		found = undefined;
		gotClass = undefined;
		
		for(i = 0; i < self.inventory.size; i++)
		{
			if(self.inventory[i] == weapon)
			{
				found = true;
				break;
			}
		}
		
		if(isDefined(found)){ continue; }
		//if(weapon[0] == "g" && weapon[1] == "l"){ continue; }
		//weaponName = _extract_weapon_name(weapon);
		weaponName = weapon;
		cl("weaponName: " + weaponName);
		
		//IsSubStr( <string>, <substring> )
		
		if(scripts\main::_get_weapon_class(weaponName) == "grenade")
		{
			cl(self.name + " picked grenade: " + weapon);
		}
		else if
		(
			scripts\main::_get_weapon_class(weaponName) == "sniper"
			|| scripts\main::_get_weapon_class(weaponName) == "bolt"
			|| scripts\main::_get_weapon_class(weaponName) == "rpg"
			|| scripts\main::_get_weapon_class(weaponName) == "rifle"
			|| scripts\main::_get_weapon_class(weaponName) == "shotgun"
			|| scripts\main::_get_weapon_class(weaponName) == "mg"
			|| scripts\main::_get_weapon_class(weaponName) == "smg"
		)
		{
			gotClass = true;
			
			if
			(
				self.inventory[0] != "none"
				&& self.inventory[1] != "none"
			)
			{
				droppable = self.inventory[self.weaponSlotSelected];
				self thread scripts\items::_drop_item(self, droppable);
				cl(self.name + " dropped: " + droppable);
				self.inventory[self.weaponSlotSelected] = weapon;
				cl(self.name + " picked: " + weapon);
			}
			else if
			(
				self.inventory[0] != "none"
				&& self.inventory[1] == "none"
			)
			{
				self.inventory[1] = weapon;
				cl(self.name + " picked secondary: " + weapon);
			}
			else if(self.inventory[0] == "none")
			{
				self.inventory[0] = weapon;
				cl(self.name + " picked primary: " + weapon);
			}
		}		
		else if
		(
			scripts\main::_get_weapon_class(weaponName) == "pistol"
		)
		{
			if(self.inventory[2] != "none")
			{
				droppable = self.inventory[2];
				self thread scripts\items::_drop_item(self, droppable);
			}
			
			self.inventory[2] = weapon;
			cl(self.name + " picked sidearms: " + weapon);
		}
		else if
		(
			scripts\main::_get_weapon_class(weaponName) == "explosive"
		)
		{
			if(self.inventory[3] != "none")
			{
				droppable = self.inventory[3];
				self thread scripts\items::_drop_item(self, droppable);
			}
			
			self.inventory[3] = weapon;
			self setActionSlot(4, "weapon", weapon);
			cl(self.name + " picked explosives: " + weapon);
		}
		else if
		(
			!isDefined(gotClass)
		)
		{
			self.inventory[3] = weapon;
			cl(self.name + " picked unclassified weapon: " + weapon);
			self setActionSlot(4, "weapon", weapon);
		}
	}
}

_player_switch_weapon(type)
{
	if(isAlive(self))
	{
		weapon = self getCurrentWeapon(); 
		
		if(type == "primary")
		{
			weapon = self.inventory[0];
			self.weaponSlotSelected = 0;
		}
		
		if(type == "secondary")
		{
			weapon = self.inventory[1];
			self.weaponSlotSelected = 1;
		}
		
		if(type == "sidearms")
		{
			weapon = self.inventory[2];
			self.weaponSlotSelected = 2;
		}
		
		if(type == "explosives")
		{
			weapon = self.inventory[3];
			self.weaponSlotSelected = 3;
		}
		
		if(!isDefined(weapon) || weapon == "none"){ return; }
				
		self switchToWeapon(weapon);
	}
}

_player_check_weapon_class(class)
{
	weapons = self GetWeaponsList();
	weapon = self getCurrentWeapon(); 
	
	for(i = 0; i < weapons.size; i++)
	{
		cl("weapons[i]: " + weapons[i]);
		if(isSubStr(class, scripts\main::_get_weapon_class(weapons[i])))
		{
			cl(self.name + " returned weapon: " + weapons[i]);
			return weapons[i];
		}
	
	}
	
	return weapon;
}

_player_watch_change_items()
{
	self endon("disconnect");
	self endon("intermission");
	self endon("death");
	level endon("game_ended");	
	
	self.lastDroppableWeapon = self getCurrentWeapon();
	
	for(;;)
	{
		self waittill("weapon_change", weapon);
	
		if(isDefined(weapon))
		{
			self.lastDroppableWeapon = weapon;
		}
	}
}

_player_killed()
{	
	self endon("disconnect");
	self endon("intermission");
	level endon("game_ended");	
		
	self waittill("death", attacker);
			
	self thread scripts\items::_player_drop_all_items(attacker);
}
