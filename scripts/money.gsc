#include maps\mp\_load;
#include maps\mp\_utility;
#include scripts\cl;

init()
{
	setDvar( "v01d_money", 1 );
	//if (!getdvarint("developer")>0){ return; }
	if (getdvarint("bots_main_debug")>0){ return; }

	if(!isDefined(game["money"])) { game["money"]=[]; }
	if(!isDefined(game["loot"])) { game["loot"]=[]; }
	if(!isDefined(game["wasConnected"])) { game["wasConnected"]=[]; }
	if(!isDefined(game["wasKilled"])) { game["wasKilled"]=[]; }
	if(!isDefined(game["firstRound"])) { game["firstRound"]=[]; }
	if(!isDefined(game["id"])) { game["id"]=[]; }
	
	level.onEndGame = ::_onEndGame;
	level.playersData = [];
	level.moneyMultiplier = 1;
	
	level thread _game_start_weapons();
	level thread _game_store_update_data();
	
	for(;;){
		level waittill("connected", player);
		
		player thread _player_read_id();
		player thread _start();
		player thread _player_spawn_loop();
		player thread _kills();
		player thread _player_start_inventory();
		//player thread _game_end_weapons();
		player thread _disconnected();
		//player thread _ownersAttacker();
		//wait 0.1;
	}
}

_player_read_id(){
	if(self.isbot){ return; }
	if(!isDefined(game["wasConnected"][self.name])){
		game["wasConnected"][self.name]=true; 
		name=self.name; id=1; found=false;
		//cl("^3name: " + name);
		filename = "players.db";
		if ( !FS_TestFile( filename ) ) { cl("^1No db file available, creating new one!"); } 
		else {
			csv = FS_FOpen(filename, "read");
			line = FS_ReadLine(csv);
			while (isDefined(line) && line != ""){
				//cl("^3line: " + line);
				//if (!isDefined(line) || line == "") { continue; }
				tokens = tokenizeLine(line, ":",1);
				//cl("^3tokens[1]: " + tokens[1]);
				if (name == tokens[1]){ 
					cl("^4found player "+name+" with ID "+id); 
					found=true;
					game["id"][self.name]=id; 
					self _player_read_data(id);
					break;
				}
				id++;
				line = FS_ReadLine(csv);
			}
			FS_FClose(csv);
		}
		game["wasKilled"][self.name]=false;
		if(found==true) { 
			game["firstRound"][self.name]=false;
			//cl("^3firstRound=false");
		} else {
			self _player_store_id(self.name, id);
			game["id"][self.name]=id; 
			game["firstRound"][self.name]=true;
			//cl("^3firstRound=true");
		}
		level.playersData[id] = spawnStruct();
		level.playersData[id].id = id;
		level.playersData[id].name = self.name;
		//if(found==false){ self _player_store_id(self.name, id); }
	}
}

_player_read_data(id){
	if(self.isbot){ return; }
	filename = "playersdata/"+id;
	if ( !FS_TestFile( filename ) ) { cl("^1No ID file available for "+self.name+"!"); return; } 
	
	data=[];
	csv = FS_FOpen(filename, "read");
	line = FS_ReadLine(csv);
	while (isDefined(line) && line != ""){
		//cl("^3line: " + line);
		//if (!isDefined(line) || line == "") { continue; }
		tokens = tokenizeLine(line, ":",1);
		//cl("^3tokens[1]: " + tokens[1]);
		if (isDefined(tokens[1])){ 
			data[data.size]=tokens[1];
			//cl("^3data: " + data[data.size-1]);
		}
		line = FS_ReadLine(csv);
	}
	FS_FClose(csv);
	
	//game["firstRound"][self.name]=true;
	game["money"][self.name] = int(data[1]);
	if(game["money"][self.name]<1){ game["money"][self.name]=3000; }
	self _set_player_weapons_ammo_list(data[2],data[3]);
	//game["loot"][self.name]=data[2];
	//self setSpawnWeapon(data[3]);
	//cl("^data[2]: " + data[2]);
}

tokenizeLine(line,tok,br,div){
	tokens = [];
	token = "";
	occurence=0;
	if(!isDefined(br)){ br=line.size; }
	if(!isDefined(div)){ div=1; }
	for ( i = 0; i < line.size; i++ )
	{
		c = line[i];
		if(occurence<br){
			if ( c == tok )
			{
				tokens[tokens.size] = token;
				token = ""; occurence++;
				continue;
			}
		}
		token += c;
	}
	tokens[tokens.size] = token;
	return tokens;
}

_player_store_id(name,id){
	level endon ( "disconnect" );
	filename = "players.db";
	
	if (FS_TestFile(filename)){
		fd = FS_FOpen(filename, "append");
	} else {
		fd = FS_FOpen( filename,"write");
	}
	
	FS_WriteLine(fd, id+":"+name);
	FS_FClose(fd); 
} 

_player_store_data(id,name,money,weapons,cw,tools)
{
	level endon ( "disconnect" );
	filename = "playersdata/"+id;
	fd = FS_FOpen( filename, "write" );
	FS_WriteLine(fd, id+":"+name);
	FS_WriteLine(fd, "money:"+money);
	FS_WriteLine(fd, "weapons:"+weapons);
	//FS_WriteLine(fd, "ammo:"+ammo);
	FS_WriteLine(fd, "cw:"+cw);
	FS_WriteLine(fd, "tools:"+tools);
	FS_FClose(fd); 
	cl("^3disconnect money: "+money);
}

_player_force_data()
{
	if(self.isbot){ return; }
	name = self.name;
	id=game["id"][name];
	money=game["money"][name];
	wlist=game["loot"][name]["weaponsList"];
	alist=game["loot"][name]["ammoList"];
	cw=game["loot"][name]["currentWeapon"];
	weapons=_get_player_weapons_ammo_list(undefined,wlist,alist);
	tools=_get_player_tools_list();
	_player_store_data(id,name,money,weapons,cw,tools);
}

_disconnected()
{
	if(self.isbot){ return; }
	
	name = self.name;
	
	self waittill("disconnect");
	
	id=game["id"][name];
	money=game["money"][name];
	wlist=game["loot"][name]["weaponsList"];
	alist=game["loot"][name]["ammoList"];
	cw=game["loot"][name]["currentWeapon"];
	weapons=_get_player_weapons_ammo_list(undefined,wlist,alist);
	tools=_get_player_tools_list();
	
	if
	(
		isDefined(id) 
		&& isDefined(name) 
		&& isDefined(money) 
		&& isDefined(weapons) 
		&& isDefined(cw) 
		&& isDefined(tools)
	)
	{
			_player_store_data(id,name,money,weapons,cw,tools);
	}
	
	game["wasConnected"][name]=undefined; 
}

_player_spawn_loop(){
	self endon ( "disconnect" );
	//self endon ( "death" );
	self endon( "intermission" );
	level endon( "game_ended" );
	
	//if (!getdvarint("developer")>0){ return; }
	if(self.isbot){ return; }
	
	for(;;){
		self waittill("spawned_player");
		//cl("^3"+self.name+" spawned");
		self thread _player_start_inventory_after_killed();
		self thread _buy();
		
		//wait 0.1;
	}
}

_start()
{
	self endon ( "disconnect" );
	self endon( "intermission" );
	//self endon( "death" );
	level endon( "game_ended" );
	
	if (self.isbot){ return; }
	
	self.money=[];
	if(!isDefined(game["money"][self.name])) { game["money"][self.name]=0; }
	if(!isDefined(game["loot"][self.name])) { game["loot"][self.name]=[]; }
	if(!isDefined(game["wasKilled"][self.name])) { game["wasKilled"][self.name]=false; }
	if(!isDefined(game["firstRound"][self.name])) { game["firstRound"][self.name]=false; }
	
	self.money["acc"] = game["money"][self.name];
	//self.pers["summary"]["match"]=0;
	//cl("^3money started on "+game["money"][self.name]);
	//cl("^5acc on "+self.name+":"+self.money["acc"]);
}

_player_start_inventory()
{
	self endon ( "disconnect" );
	//self endon ( "death" );
	self endon( "intermission" );
	level endon( "game_ended" );
	
	if(self.isbot){ return; }
	
	self waittill("spawned_player");
	
	self takeAllWeapons();
	/*self.haveC4=0;
	self.haveClaymores=0;
	self.haveFragGrenades=0;
	self.haveConcussionGrenades=0;
	self.haveFlashGrenades=0;
	self.haveSmokeGrenades=0;*/
	self SetWeaponAmmoClip("c4_mp",0);
	self SetWeaponAmmoClip("claymore_mp",0);
	self SetWeaponAmmoClip("frag_grenade_mp",0);
	self SetWeaponAmmoClip("concussion_grenade_mp",0);
	self SetWeaponAmmoClip("flash_grenade_mp",0);
	self SetWeaponAmmoClip("smoke_grenade_mp",0);
	self SetWeaponAmmoStock("c4_mp",0);
	self SetWeaponAmmoStock("claymore_mp",0);
	self SetWeaponAmmoStock("frag_grenade_mp",0);
	self SetWeaponAmmoStock("concussion_grenade_mp",0);
	self SetWeaponAmmoStock("flash_grenade_mp",0);
	self SetWeaponAmmoStock("smoke_grenade_mp",0);
	
	wait 0.2;

	while
	(
		game["state"] == "postgame" 
		|| level.gameEnded || !isAlive(self) 
		|| self.sessionstate == "spectator"
	) 
	{ 
		wait 0.1; 
	}
	
	if
	(
		isDefined(game["wasKilled"][self.name]) 
		&& game["wasKilled"][self.name]==false 
		&& isDefined(game["firstRound"][self.name]) 
		&& game["firstRound"][self.name]==false
	)
	{
		id=game["id"][self.name];
		weaponsList=game["loot"][self.name]["weaponsList"];
		ammoList=game["loot"][self.name]["ammoList"];
		cw=game["loot"][self.name]["currentWeapon"];
		if(isDefined(weaponsList))
		{
			for( i = 0; i < weaponsList.size; i++ )
			{
				self giveWeapon(weaponsList[i]);
				self notify("picked_weapon", weaponsList[i]);
				//cl("weaponsList[i]:" + weaponsList[i]);
				self setWeaponAmmoStock(weaponsList[i],int(ammoList[i]));

				if(isDefined(cw)) 
				{ 
					self setSpawnWeapon(cw); 
					self notify("picked_weapon", cw);
				}
				else 
				{ 
					self setSpawnWeapon(weaponsList[0]); 
				}
				
				if(weaponsList[i] == "c4_mp"){ self.haveC4=ammoList[i]; }
				if(weaponsList[i] == "claymore_mp"){ self.haveClaymores=ammoList[i]; }
				if(weaponsList[i] == "frag_grenade_mp"){ self.haveFragGrenades=ammoList[i]; }
				if(weaponsList[i] == "concussion_grenade_mp"){ self.haveConcussionGrenades=ammoList[i]; }
				if(weaponsList[i] == "flash_grenade_mp"){ self.haveFlashGrenades=ammoList[i]; }
				if(weaponsList[i] == "smoke_grenade_mp"){ self.haveSmokeGrenades=ammoList[i]; }	
				
				waittillframeend; //due to notify issues
			}
		} 
		else 
		{
			cl("22"+self.name+" has undefined weaponsList");
			weapon="colt45_mp";
			//self takeAllWeapons();
			self giveWeapon(weapon);
			self notify("picked_weapon", weapon);
			self SetWeaponAmmoClip(weapon,0);
			if(getDvarInt("v01d_full_ammo_clip_at_round_start") == 1)
			{
				clip = WeaponClipSize(weapon);
				self SetWeaponAmmoClip(weapon,clip);
			}
			
			self SetWeaponAmmoStock(weapon,36);
			self SetSpawnWeapon(weapon);
			game["wasKilled"][self.name]=false;
		}
	} 
	else if
	(
		isDefined(game["wasKilled"][self.name]) 
		&& game["wasKilled"][self.name]==true)
	{
		//cl("^3wasKilled=true");
		weapon="colt45_mp";
		if(self.pers["team"] == "axis"){ weapon="beretta_mp"; }
		if(self.pers["team"] == "allies"){ weapon="colt45_mp"; }
		//self takeAllWeapons();
		self giveWeapon(weapon);
		self notify("picked_weapon", weapon);
		self SetWeaponAmmoClip(weapon,0);
		
		if(getDvarInt("v01d_full_ammo_clip_at_round_start") == 1){
			clip = WeaponClipSize(weapon);
			self SetWeaponAmmoClip(weapon,clip);
		}
		
		self SetWeaponAmmoStock(weapon,12);
		self SetSpawnWeapon(weapon);
		game["wasKilled"][self.name]=false;
		//cl("^3killed to false");
	} 
	else if 
	(
		isDefined(game["firstRound"][self.name]) 
		&& game["firstRound"][self.name]==true)
	{
		//cl("^3firstRound=true");
		weapon="colt45_mp";
		
		if(self.pers["team"] == "axis"){ weapon="beretta_mp"; }
		if(self.pers["team"] == "allies"){ weapon="colt45_mp"; }
		//self takeAllWeapons();
		self giveWeapon(weapon);
		self notify("picked_weapon", weapon);
		self SetWeaponAmmoClip(weapon,0);
		
		if(getDvarInt("v01d_full_ammo_clip_at_round_start") == 1)
		{
			clip = WeaponClipSize(weapon);
			self SetWeaponAmmoClip(weapon,clip);
		}
		
		self SetWeaponAmmoStock(weapon,36);
		self SetSpawnWeapon(weapon);
		game["wasKilled"][self.name]=false;
		game["firstRound"][self.name]=false;
		//cl("^3firstRound");
	}
}

_player_start_inventory_after_killed()
{
	self endon ( "disconnect" );
	
	if(self.isbot){ return; }
	
	if(game["wasKilled"][self.name]==true)
	{
		wait 0.1;
		weapon="colt45_mp";
		if(self.pers["team"] == "axis"){ weapon="beretta_mp"; }
		if(self.pers["team"] == "allies"){ weapon="colt45_mp"; }
		self takeAllWeapons();
		self.haveC4=0;
		self.haveClaymores=0;
		self.haveFragGrenades=0;
		self.haveConcussionGrenades=0;
		self.haveFlashGrenades=0;
		self.haveSmokeGrenades=0;
		self SetWeaponAmmoClip("frag_grenade_mp",0);
		self SetWeaponAmmoClip("concussion_grenade_mp",0);
		self SetWeaponAmmoClip("flash_grenade_mp",0);
		self SetWeaponAmmoClip("smoke_grenade_mp",0);
			
		self giveWeapon(weapon);
		self notify("picked_weapon", weapon);
		self SetWeaponAmmoClip(weapon,0);
		
		if(getDvarInt("v01d_full_ammo_clip_at_round_start") == 1){
			clip = WeaponClipSize(weapon);
			self SetWeaponAmmoClip(weapon,clip);
		}
		
		self SetWeaponAmmoStock(weapon,12);
		self SetSpawnWeapon(weapon);
		wait 0.2;
		game["wasKilled"][self.name]=false;		
	}
}

_get_player_weapons_ammo_list(player,wlist,alist){
	list="";
	if(isDefined(player)){
		weapons = player GetWeaponsList();
		ammo=[];
		for( j = 0; j < weapons.size; j++ )
		{
			ammo[j] = player getAmmoCount(weapons[j]);
			if(j==weapons.size-1){ list += weapons[j]+","+ammo[j]; }
			else { list += weapons[j]+","+ammo[j] + ","; }
		}
	} else {
		if(isDefined(wlist)){
			for( j = 0; j < wlist.size; j++ )
			{
				if(j==wlist.size-1){ list += wlist[j]+","+alist[j]; }
				else { list += wlist[j]+","+alist[j] + ","; }
			}
		}
	}
	return list;
}

_set_player_weapons_ammo_list(weapons,cw,div)
{
	if(!isDefined(div)){ div=1; }

	list="";
	wlist = tokenizeLine(weapons,",");
	weaponsList=[];
	ammoList=[];

	if(isDefined(wlist) && wlist.size>1)
	{
		for( j = 0; j < wlist.size; j+=2 )
		{
			weaponsList[weaponsList.size] = wlist[j];
			ammoList[ammoList.size] = int(wlist[j+1]);
		}
		
		game["loot"][self.name]["weaponsList"]=weaponsList;
		game["loot"][self.name]["ammoList"]=ammoList;
		self setSpawnWeapon(cw);
	}
}

_get_player_tools_list(player)
{
	list="";
	
	if(isDefined(player) && isDefined(player.tools))
	{
		keys = GetArrayKeys(player.tools);
		
		for( j = 0; j < keys.size; j++ )
		{
			if(j == keys.size - 1)
			{ 
				list += keys[j] + "," + player.tools[keys[j]]; 
			}
			else 
			{ 
				list += player.tools[j] + "," + player.tools[keys[j]] + ","; 
			}
		}
	}
	
	return list;
}

_game_start_weapons()
{
	while (game["state"] == "postgame" || level.gameEnded) 
	{ 
		wait 0.1; 
	}

	players = getentarray( "player", "classname" );
	for( i = 0 ; i < players.size ; i++ )
	{
		if(players[i].isbot){ continue; }
		
		weaponsList=game["loot"][players[i].name]["weaponsList"];
		ammoList=game["loot"][players[i].name]["ammoList"];
		
		if(isDefined(weaponsList))
		{
			for( j = 0; j < weaponsList.size; j++ )
			{
				players[i] giveWeapon(weaponsList[j]);
				self notify("picked_weapon", weaponsList[j]);
				players[i] setWeaponAmmoStock(weaponsList[j],int(ammoList[j]));
				players[i] setSpawnWeapon(weaponsList[0]);
				
				waittillframeend; //due to notify issues
			}
		} 
		else 
		{
			weapon="colt45_mp";
			//self takeAllWeapons();
			if(self.pers["team"] == "axis"){ weapon="beretta_mp"; }
			if(self.pers["team"] == "allies"){ weapon="colt45_mp"; }
			self giveWeapon(weapon);
			self notify("picked_weapon", weapon);
			self SetSpawnWeapon(weapon);
		}
	}
}


_game_end_weapons(){
	//self endon ( "disconnect" );
	//self endon ( "death" );
	//self endon( "intermission" );
	//self endon( "game_ended" );
	//if (!getdvarint("developer")>0){ return; }
	//if(self.isbot){ return; }
	
	//while ( game["state"] == "postgame" || level.gameEnded || !isAlive(self)) { wait 0.1; }
	players = getentarray( "player", "classname" );
	for( i = 0 ; i < players.size ; i++ ){
		if(players[i].isbot){ continue; }
		//if(players[i].isbot || players[i].sessionstate == "spectator"){ 
		if(players[i].sessionstate == "spectator"){ 
			//game["wasKilled"][players[i].name]=true; 
			//cl("^3"+players[i].name+" is spectator");
			continue; 
		}
		cw=players[i] GetCurrentWeapon();
		weaponsList = players[i] GetWeaponsList();
		ammoList=[];
		for( j = 0; j < weaponsList.size; j++ )
		{
			if(isDefined(weaponsList[i]) && isSubStr(weaponsList[i], "briefcase"))
			{
				players[i] takeWeapon(weaponsList[i]);
				continue;
			}
			
			ammoList[j] = players[i] getAmmoCount(weaponsList[j]);
			//cl("^3"+players[i].name+" weaponsList "+weaponsList[j]+":"+ammoList[j]);
		}
		game["loot"][players[i].name]["weaponsList"]=weaponsList;
		game["loot"][players[i].name]["ammoList"]=ammoList;
		game["loot"][players[i].name]["currentWeapon"]=cw;
		
		players[i] _player_force_data();
	}
	//cl("^3end inv");
	//wait 0.5;

}

_game_end_money()
{
	players = getentarray( "player", "classname" );
	for( i = 0 ; i < players.size ; i++ )
	{
		if(players[i].isbot){ continue; }
		
		game["money"][players[i].name]=players[i].money["acc"];
	}
}

_game_store_update_data()
{
	for(;;)
	{
		while ( game["state"] == "postgame" || level.gameEnded) 
		{ 
			wait 1; 
		}

		players = getentarray( "player", "classname" );
		for( i = 0 ; i < players.size ; i++ )
		{
			if(players[i].isbot){ continue; }
			
			game["money"][players[i].name]=players[i].money["acc"];;
			cw=players[i] GetCurrentWeapon();
			game["loot"][players[i].name]["currentWeapon"]=cw;
		}
		
		wait 1;
	}
}

_kills(){
	for(;;){
		self waittill("death",attacker);
		//cl("^3attacker "+attacker.name+" killed "+self.name);
		//if(isDefined(game["inventory"][self.name])) { game["inventory"][self.name]["weaponsList"]=undefined; }
		game["wasKilled"][self.name]=true;
		//cl("^3killed true");
		if(isPlayer(attacker) && !attacker.isbot && attacker != self){
			if(attacker.pers["team"] == self.team){
				attacker.money["acc"] -= 1000 * level.moneyMultiplier;
				//game["money"][attacker.name]=attacker.money["acc"];
				//cl("^1attacker "+attacker.name+" has money: "+attacker.money["acc"]);
				//cl("^1"+attacker.name+" has money: "+game["money"][attacker.name]);
			}
			else {
				attacker.money["acc"] += 100 * level.moneyMultiplier;
			}
		}
	}
}

_check_weapon_in_list(weapon){
	if(self.isbot){ return; }
	if(!isDefined(weapon)){ return; }
	if(isAlive(self)){
		weaponsList = self GetWeaponsList();
		if(isDefined(weaponsList)){
			for(i=0;i<weaponsList.size;i++){
				//cl("33"+weaponsList[i]);
				if(isDefined(weaponsList[i])){
					if (isSubStr(weaponsList[i], weapon)){ return weapon; }
				}
			}
		}
	}
}

_buy()
{
	self endon ( "disconnect" );
	self endon ( "death" );
	self endon( "intermission" );
	level endon( "game_ended" );
		
	if(self.isbot){ return; }
	
	wait 0.5;
	
	for(;;)
	{
		currentWeaponClass = scripts\main::_get_weapon_class(self GetCurrentWeapon());
		currentWeapon = self GetCurrentWeapon();
		self waittill("isBuying");
		
		if(isDefined(self.hasChosen) && self.hasChosen.size>0)
		{
			for(i=1;i<self.hasChosen.size;i++)
			{				
				if
				(
					isSubStr(self.hasChosen[i],"tools_") 
					&& isDefined(self.money) 
					&& self.money["acc"] >= int(self.hasChosen[i-1])
				)
				{
					tool=StrRepl(self.hasChosen[i], "tools_", "");
					//cl(tool);
					
					if(isDefined(self.tools) && isDefined(tool))
					{
						if(isSubStr(self.hasChosen[i],"_defkit"))
						{
							self.tools["defkit"]++;
							self playSound("tools_defkit_buy");
						}
						else if(isSubStr(self.hasChosen[i],"_uav"))
						{
							self.tools["radar_mp"]++;
							self scripts\main::_construct_hp_item("radar_mp");
							self thread maps\mp\gametypes\_hardpoints::hardpointNotify("radar_mp", 1);
						}
						else if(isSubStr(self.hasChosen[i],"_airstrike"))
						{
							self.tools["airstrike_mp"]++;
							self scripts\main::_construct_hp_item("airstrike_mp");
							self thread maps\mp\gametypes\_hardpoints::hardpointNotify("airstrike_mp", 1);
						}
						else if(isSubStr(self.hasChosen[i],"_helicopter"))
						{
							self.tools["helicopter_mp"]++;
							self scripts\main::_construct_hp_item("helicopter_mp");
							self thread maps\mp\gametypes\_hardpoints::hardpointNotify("helicopter_mp", 1);
						}
						else if(isSubStr(self.hasChosen[i],"_artillery"))
						{
							self.tools["artillery_mp"]++;
							self scripts\main::_construct_hp_item("artillery_mp");
							self thread maps\mp\gametypes\_hardpoints::hardpointNotify("artillery_mp", 1);
						}
						
						self.money["acc"]-=int(self.hasChosen[i-1]);
						self.spentMoney=true;
						
						self notify( "playerKilledChallengesProcessed" );
					}
				}
				
				if (isSubStr(self.hasChosen[i],"_mp"))
				{ 
					//cl("^4found weapon: "+self.hasChosen[i]); 
					weapon = self _check_weapon_in_list(self.hasChosen[i]);
					
					if(isDefined(weapon) && self.hasChosen[i] == weapon && !isSubStr(self.hasChosen[i],"c4") && !isSubStr(self.hasChosen[i],"claymore") && !isSubStr(self.hasChosen[i],"grenade"))
					{ 
						self.hasChosen[i-1] = int(int(self.hasChosen[i-1])/10);
					}
					
					if(isDefined(self.money) && self.money["acc"]>=int(self.hasChosen[i-1]))
					{ 
						if (FS_TestFile("/scripts/main.gsc"))
						{
							chosenWeaponClass = scripts\main::_get_weapon_class(self.hasChosen[i]);
							
							if(isDefined(currentWeaponClass) && isDefined(chosenWeaponClass))
							{
								if(currentWeaponClass == chosenWeaponClass)
								{ 
									self takeWeapon(currentWeapon); 
								}
							}
						}

						ammo = self getAmmoCount(self.hasChosen[i]);
						clip = WeaponClipSize(self.hasChosen[i]);
						maxAmmo = weaponMaxAmmo(self.hasChosen[i]);
						
						if(ammo >= maxAmmo)
						{ 
							cl("33max ammo reached to "+self.hasChosen[i]); 
							wait 0.05; 
						}
						else
						{
							pickedExplosives=true;
							//droppable = self GetCurrentWeapon();
							//cl("droppable: " + droppable);
							self giveWeapon(self.hasChosen[i]);
							self notify("picked_weapon", self.hasChosen[i]);
							
							if (isSubStr(self.hasChosen[i],"claymore"))
							{ 
								self.haveClaymores+=1;
								self SetWeaponAmmoClip(self.hasChosen[i],self.haveClaymores); 
								self playSound("weap_pickup");
								//self.money["acc"]-=int(self.hasChosen[i-1]);
							} 
							else if (isSubStr(self.hasChosen[i],"c4"))
							{ 
								self.haveC4+=1;
								self SetWeaponAmmoClip(self.hasChosen[i],self.haveC4); 
								self playSound("weap_pickup");
								//self.money["acc"]-=int(self.hasChosen[i-1]);
							} 
							else if (isSubStr(self.hasChosen[i],"frag_grenade"))
							{ 
								self.haveFragGrenades+=1;
								self SetWeaponAmmoClip(self.hasChosen[i],self.haveFragGrenades); 
								self playSound("grenade_pickup");
								//self.money["acc"]-=int(self.hasChosen[i-1]);
							} 
							else if (isSubStr(self.hasChosen[i],"concussion_grenade"))
							{ 
								self.haveConcussionGrenades+=1;
								self SetWeaponAmmoClip(self.hasChosen[i],self.haveConcussionGrenades); 
								self playSound("grenade_pickup");
								//self.money["acc"]-=int(self.hasChosen[i-1]);
							} 
							else if (isSubStr(self.hasChosen[i],"flash_grenade"))
							{ 
								self.haveFlashGrenades+=1;
								self SetWeaponAmmoClip(self.hasChosen[i],self.haveFlashGrenades); 
								self playSound("grenade_pickup");
								//self.money["acc"]-=int(self.hasChosen[i-1]);
							} 
							else if (isSubStr(self.hasChosen[i],"smoke_grenade"))
							{ 
								self.haveSmokeGrenades+=1;
								self SetWeaponAmmoClip(self.hasChosen[i],self.haveSmokeGrenades); 
								self playSound("grenade_pickup");
								//.money["acc"]-=int(self.hasChosen[i-1]); 
							} 
							else 
							{
								if (isDefined(weapon) && self.hasChosen[i] == weapon)
								{
									self.money["acc"]-=int(int(self.hasChosen[i-1]));
									//self.money["acc"]-=int(int(self.hasChosen[i-1])/10);
									self SetWeaponAmmoStock(self.hasChosen[i], ammo+clip);
									//cl("GetWeaponClipModel: " + GetWeaponClipModel(weapon));
									//cl("33"+self.name+" bought ammo "+clip);
									//cl("33"+self.name+" has ammo "+self getAmmoCount(self.hasChosen[i]));
								} 
								else 
								{
									//self giveWeapon(self.hasChosen[i]);
									//self giveMaxAmmo(self.hasChosen[i]);
									self SetWeaponAmmoStock(self.hasChosen[i],clip);
									self SetWeaponAmmoClip(self.hasChosen[i],0);
									self.money["acc"]-=int(self.hasChosen[i-1]);
									if(getDvarInt("v01d_full_ammo_clip_at_round_start") == 1)
									{
										clip = WeaponClipSize(self.hasChosen[i]);
										self SetWeaponAmmoClip(self.hasChosen[i],clip);
									}

									//cl("33"+self.name+" bought weapon "+self.hasChosen[i]);
								}
								
								self playSound("weap_pickup");
								pickedExplosives=false;
							}
							
							if(pickedExplosives==true)
							{ 
								self.money["acc"]-=int(self.hasChosen[i-1]);
							}
						}
						
						self.hasChosen[i-1] = "" + self.hasChosen[i-1];
						self.spentMoney=true;
						
						while(self AttackButtonPressed()){ wait 0.05; } 
					} 
					else 
					{
						self.notEnoughMoney=true;
						//cl("^1self.notEnoughMoney"); 
					}
				}
			}
			
			wait 0.05;
		}
		
		wait 0.05;
	}
}

/*_buy_weapons_ammo(weapon){
	//weapons = self GetWeaponsList();
	val=[];
	ammoCount = self getAmmoCount(weapon);
	weaponClipSize = WeaponClipSize(weapon);
	maxWeaponAmmo = weaponMaxAmmo(weapon);
	val[0] = int(maxWeaponAmmo - ammoCount);
	val[1] = int(fillAmmo / weaponClipSize);
	
	for(i=0;j<weapons.size;i++)
	{
		ammoCount = self getAmmoCount(weapons[i]);
		weaponClipSize = WeaponClipSize(weapons[i]);
		maxWeaponAmmo = weaponMaxAmmo(weapons[i]);
		val["fillAmmo"] = maxWeaponAmmo - ammoCount;
		val["clipsToGive"] = fillAmmo / weaponClipSize;
	}
	
	return val;
}*/

_game_end_bonuses(){
	players = getentarray( "player", "classname" );
	for( i = 0 ; i < players.size ; i++ ){
		if(players[i].isbot){ continue; }
		kills = players[i].pers["kills"];
		assists = players[i].pers["assists"];
		match=players[i].pers["summary"]["match"];
		game["money"][players[i].name] += kills*10 + assists*5 + match*10;
		money=game["money"][players[i].name];
		players[i].pers["summary"]["match"]=0;
		//players[i].pers["summary"]["match"]=money;
		players[i].setPromotion=undefined;
		//cl("^2match kills: "+players[i].pers["kills"]);
		//cl("^2match assists: "+players[i].pers["assists"]);
	}
}

_onEndGame(w,r){
	level thread _game_end_money();
	level thread _game_end_weapons();
	level thread _game_end_bonuses();
	
	//wait 0.1; 
	//cl("^3onEndGame");
}

_ownersAttacker(){
	if(self.isbot){ return; }
	while(1){
		if(isDefined(self.droppedDeathWeapon)){ cl("^1"+self.droppedDeathWeapon); }
		assert(isdefined(self.tookWeaponFrom));
		wait 0.5;
	}
}
