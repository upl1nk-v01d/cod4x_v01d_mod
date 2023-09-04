#include common_scripts\utility;
#include maps\mp\_load;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include scripts\cl;
#include scripts\pl;

init(){
	precacheShader("waypoint_bomb");
	precacheShader("waypoint_kill");
	precacheShader("waypoint_bomb_enemy");
	precacheShader("waypoint_defend");
	precacheShader("waypoint_defuse");
	precacheShader("waypoint_target");
	precacheShader("compass_waypoint_bomb");
	precacheShader("compass_waypoint_defend");
	precacheShader("compass_waypoint_defuse");
	precacheShader("compass_waypoint_target");
	precacheShader("hud_suitcase_bomb");
	precacheShader("headicon_allies");
	precacheShader("objpoint_default");
	precacheShader("hud_status_head");
	precacheShader("hud_icon_mm1");
	precacheShader("hud_icon_mors");
	precacheShader("hud_icon_striker");
	//precacheShader("hud_icon_law");
	precacheShader("hud_icon_ump45");
	
	game["menu_clientdvar"] = "clientdvar";
    precacheMenu(game["menu_clientdvar"]);
	precacheMenu("v01d_qm");
	precacheMenu("v01d_coms");
	precacheMenu("v01d_ct_taunts_main");
	precacheMenu("v01d_ct_taunts_1");
	precacheMenu("v01d_ct_taunts_2");
	precacheMenu("v01d_ct_taunts_3");
	precacheMenu("v01d_tools");

	level thread maps\mp\bots\_bot::init();
	level thread maps\mp\bots\_bot_chat::init();
	level thread maps\mp\bots\_menu::init();
	//level thread maps\mp\bots\_wp_editor::init();

	level thread scripts\bots_aim_ext::init();
	level thread scripts\bots_fire_ext::init();
	level thread scripts\chopper_ext::init();
	level thread scripts\money::init();
	level thread scripts\menus::init();
	//level thread scripts\bots_nav::init();
	//level thread scripts\tactical::init();

	if(getDvar("v01d_version") == ""){ setDvar("v01d_version", "v2.17"); }
	if(getDvar("v01d_dev") == ""){ setDvar("v01d_dev","0"); } //enabe v01d mod dev mode args: "nav", "weap"
	if(getDvar("v01d_bots_inbalance_feature") == ""){ setDvar("v01d_bots_inbalance_feature",1); } //round loosing team gets one bot: 1=on, 0=off
	if(getDvar("v01d_bots_recoil_spicyness") == ""){ setDvar("v01d_bots_recoil_spicyness",0.2); } //bot recoil coefficient must be greater than 0.00
	if(getDvar("v01d_log_players") == ""){ setDvar("v01d_log_players",1); } //logging real players into fs_homepath: 1=on, 0=off
	if(getDvar("v01d_motd") == ""){ setDvar("v01d_motd",1); } //enabling playershowing MOTD when connected to server: 1=on, 0=off
	if(getDvar("v01d_item_pickup_mode") == ""){ setDvar("v01d_item_pickup_mode",1); } //picking up weapons from ground takes time: 1=on, 0=off
	if(getDvar("v01d_item_pickup_time") == ""){ setDvar("v01d_item_pickup_time",0.7); } //picking up weapons time in seconds
	if(getDvar("v01d_item_remove_time") == ""){ setDvar("v01d_item_remove_time",10); } //weapon burrying in ground time in seconds
	if(getDvar("v01d_maps_randomizer") == ""){ setDvar("v01d_maps_randomizer",1); } //random map loading on match end: 1=on, 0=off
	if(getDvar("v01d_suicide_sfx") == ""){ setDvar("v01d_suicide_sfx",1); } //suicide screaming sounds: 1=on, 0=off
	if(getDvar("v01d_knifed_sfx") == ""){ setDvar("v01d_knifed_sfx",1); } //knifed screaming sounds: 1=on, 0=off
	if(getDvar("v01d_full_ammo_clip_at_round_start") == ""){ setDvar("v01d_full_ammo_clip_at_round_start",1); } //give player full weapon ammo clip at round start: 1=on, 0=off
		
	setDvar("pl",""); //in terminal argument a = show all players, r = real players, b = bot players
	setDvar("m",""); //in terminal argument i = show current map and team score, f = fast restart, r = brutal restart
	setDvar("timescale", 1);
	setDvar("sl",0); //set dvar scr_sab_scorelimit to args val
	setDvar("tl",0); //set dvar scr_sab_timelimit of round to args val
	setDvar("nl",0); //set dvar scr_sab_numlives of player to args val
	setDvar("ab",""); //add 1 bot to desired team
	setDvar("kb",""); //add 1 bot to desired team
	setDvar("tr",""); //transfer 1 bot to desired team (args: ax, al)
	
	if (getDvar("v01d_dev")!="0") { //set this arg to enable waypoint/node mode
		setDvar("scr_game_spectatetype", "2"); 
		setDvar("scr_game_matchstarttime", "0"); 
		setDvar("scr_"+getDvar("g_gametype")+"_timelimit", "0"); 
		setDvar("scr_"+getDvar("g_gametype")+"_roundlimit", "0"); 
		setDvar("scr_"+getDvar("g_gametype")+"_scorelimit", "999"); 
		setDvar("scr_"+getDvar("g_gametype")+"_numlives", "0"); 
		//setDvar("scr_sab_numlives",3);
	}

	if (getDvar("g_gametype") == "") { setDvar("g_gametype","sab"); }
	
	if (!isDefined(game["waypointless_map"])){ game["waypointless_map"]="off"; }
	if (!isDefined(game["realPlayers"])){ game["realPlayers"]=0; }
	if (!isDefined(game["botPlayers"])){ game["botPlayers"]=0; }
	if (!isDefined(game["isConnecting"])){ game["isConnecting"]=[]; }
	if (!isDefined(game["isJoinedSpectators"])){ game["isJoinedSpectators"]=[]; }
	if (!isDefined(game["nextMap"])){ game["nextMap"]=""; }
	if (!isDefined(game["nextMapIndex"])){ game["nextMapIndex"]=0; }
	if (!isDefined(game["prevMap"])){ game["prevMap"]=""; }
	if (!isDefined(game["mapList"])){ game["mapList"]=[]; }
	if (!isDefined(game["teamWonRound"])){ game["teamWonRound"]=""; }
	if (!isDefined(game["devmode"])){ game["devmode"]="off"; }
	
	if(!isDefined(game["_t_m_static"])){game["_t_m_static"] = randomIntRange(1, 15);}
	if(!isDefined(game["_ct_m_static"])){game["_ct_m_static"] = randomIntRange(1, 5);}
	if(!isDefined(game["_t_m_"])){game["_t_m_"] = game["_t_m_static"];}
	if(!isDefined(game["_ct_m_"])){game["_ct_m_"] = game["_t_m_static"];}
	
	level._maps = StrTok("mp_ancient_ultimate,12,mp_carentan,14,mp_rasalem,12,mp_efa_lake,8,mp_bo2carrier,12,mp_bog,16,mp_summit,18,mp_backlot,16,mp_harbor_v2,16,mp_sugarcane,8,mp_csgo_assault,12,mp_csgo_inferno,12,mp_csgo_office,12,mp_csgo_overpass,12,mp_csgo_mirage,12,mp_finca,12,mp_csgo_safehouse,10,mp_csgo_cbble,12,mp_csgo_shortdust,12,mp_csgo_stmarc,8,mp_ins_panj,10,mp_creek,12,mp_csgo_mirage,12,mp_csgo_overpass,12,mp_ins_heights,12,mp_ins_peak,12", "," );
	level._weapons = StrTok("knife_mp", "," );
	//level._gametypes = StrTok("mp_csgo_assault,war,mp_csgo_inferno,war,mp_vil_blops,war,mp_bo2carrier,war", "," );
	for (i=0;i<level._weapons.size;i++){
		PrecacheItem(level._weapons[i]);
		if(isDefined(level.precachedItemsNum)){ level.precachedItemsNum++; } //forth precache
	}
	
	level.hudMarkers = [];
	level.slowMo=false;
	level.gracePeriod = 60;
	level.screams_sfx=false;
	
	/*
	level.classSniper = StrTok("svg100,dragunov,m21", "," );
	level.classRPG = StrTok("law,at4,rpg,skorpion_acog,skorpion_reflex", "," );
	level.classGL = StrTok("mm1,barrett_acog", "," );
	level.classRifle = StrTok("m14,m4,m1014,m16,g3", "," );
	level.classMG = StrTok("m60e4,saw,rpd,", "," );
	level.classSMG = StrTok("ak47,g36,ak74u,mp44,uzi,mp5,p90,mp44", "," );
	level.classPistol = StrTok("colt45,usp,beretta,deserteagle,rw1,winchester1200_grip", "," );
	level.classBoltSniper = StrTok("m40a3,remington700,tac330,aw50", "," );
	*/
	
	level.classSniper = StrTok("svg100,dragunov,m21", "," );
	level.classRPG = StrTok("law,at4,rpg,skorpion_acog,skorpion_reflex", "," );
	level.classGL = StrTok("mm1,barrett_acog", "," );
	level.classRifle = StrTok("m14,m4,m1014,m16,g3", "," );
	level.classMG = StrTok("m60e4,saw,rpd,", "," );
	level.classSMG = StrTok("ak47,g36,ak74u,mp44,uzi,mp5,p90,mp44", "," );
	level.classPistol = StrTok("colt45,usp,beretta,deserteagle,rw1,winchester1200_grip", "," );
	level.classBoltSniper = StrTok("m40a3,remington700,ak47_acog_mp,ak47_silencer_mp", "," );
	
	level.fx_m203_gl = loadfx("explosions/grenadeexp_default");

	level.st = gettime();
	level.tp=0;
	level.playedStartingMusic=true;
	level.kickOneBot=undefined;
	level.addOneBot=undefined;

	if (level.waypointCount == 0) {
		game["waypointless_map"]="on";
	} else {
		game["waypointless_map"]="off";
	}

	level.originalcallbackPlayerKilled = level.callbackPlayerKilled;
    level.callbackPlayerKilled = ::_killed;
	level.originalcallbackPlayerDamage = level.callbackPlayerDamage;
    level.callbackPlayerDamage = ::_damaged;
    
    level thread _t1();
	level thread _t2();
	//level thread _t2();
	//level thread _t3();
	//level thread _t4();
	//level thread _t5();
	
	//level thread _dev_waittillframeend_test();
	
 	level thread _precache_info(1);
	level thread _dev_start();
	level thread _dev_round_time_passed();
    level thread _player_connecting_loop();
	level thread _prematch();
	level thread _tiebreaker();
	level thread _sleepers();
	level thread _init_bots_dvars();
	level thread _dvar_players();
	level thread _dvar_map_restart();
	level thread _dvar_sab();
	level thread _server_send_update();
	//level thread _fast_restart_on_join();
	level thread _sab_bomb_visibility();
	level thread _randomize_bomb_pos();
	level thread _artillery_monitor();
	level thread _bc();
	level thread _player_collision(24);
	level thread _maps_randomizer();
	level thread _slowMo();
	level thread _get_team_score();
	level thread _bomb_exploded();
	level thread _bot_balance_manage();
	level thread _dvar_add_bots();
	level thread _dvar_remove_bots();
	level thread _dvar_transfer_bots();
	level thread _explosives_array();
	level thread _last_allie_taunting();
	//level thread _bomb_objective_blink();
				
	for(;;)
    {
        level waittill("connected", player);
 		
 		if(!player.isbot && getDvarInt("v01d_log_players")==1) { player thread _player_info(1,player.name); }
		if(!isDefined(game["isJoinedSpectators"][player.name])){ game["isJoinedSpectators"][player.name]=true; }
        
        player thread _welcome();
        player thread _info();
		player thread _player_spawn_loop();
		player thread _disconnected();
		player thread _fs();
		player thread _check_sleepers();
		player thread _botScriptGoal();
		player thread _grenade_owner();
		player thread _projectiles_owner();
		player thread _menu_response();
		player thread _player_spectate();
	} 
}

/* \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

-----------------------------server utils--------------------------------

\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/ */

_t1(){
	wait 0.05;
	while (1){
		level notify("timers");
		wait 0.05;
	}
}

_t2(){
	wait 0.075;
	while (1){
		level notify("timers");
		wait 0.05;
	}
}

/*
_t2(){
	wait 0.06;
	while (1){
		level notify("timers");
		wait 0.05;
	}
}


_t3(){
	wait 0.07;
	while (1){
		level notify("timers");
		wait 0.05;
	}
}

_t4(){
	wait 0.08;
	while (1){
		level notify("timers");
		wait 0.05;
	}
}

_t5(){
	wait 0.09;
	while (1){
		level notify("timers");
		wait 0.05;
	}
}
*/

_arr_add(arr,adder,idx){
	new_arr = []; shift=0;
	for (i=0;i<arr.size;i++){
		index = arr[i+shift];
		if(isDefined(index)){
			if(isDefined(adder) && i == idx){ 
				new_arr[i]=adder;
				shift+=1;
			}
			else{ new_arr[new_arr.size]=index; }
		}
	}
	return new_arr;
}

_arr_remove(arr,remover){
	new_arr = [];
	for (i=0;i<arr.size;i++){
		index = arr[i];
		if(isDefined(index)){
			if (index != remover)
				new_arr[new_arr.size]=index;
		}
	}
	return new_arr;
}

_arr_sort(arr,steps){
	if(!isDefined(arr)){ return; }
	if(!isDefined(steps)){ steps=1; }

	new_arr = [];
	max = 0;
	for (i1=arr.size-1;i1>0;i1-=steps){
		for (i2=arr.size-1;i2>i1;i2-=steps){
			if(isDefined(arr[i1]) && arr[i2] > max){
				max = arr[i2];
				new_arr[i1]=arr[i2];
			}
		}
	}
	return new_arr;
}

_playSoundInSpace(alias,origin,delay,listener){
	org = spawn( "script_origin", origin );
	org.origin = origin;
	if(!isDefined(alias)){ cl("11no alias defined in _playSoundInSpace()"); return; }
	if(!isDefined(origin)){ cl("11no origin defined in _playSoundInSpace()"); return; }
	if(!isDefined(delay)){ delay=0; }
	wait delay;
	if(isDefined(listener)){ org playSoundToPlayer(alias,listener); }
	else { org playSound(alias); }
	wait 0.05; // MP doesn't have "sounddone" notifies =(
	org delete();
}

_chk_players(opts)
{
	players = getentarray( "player", "classname" );
	playersCount=0;
	playersCountAxis=0;
	playersCountAllies=0;
	if(isDefined(opts)){
		if(opts == "alive"){ 
			for( i = 0 ; i < players.size ; i++ ){
				if(players[i].pers["lives"]>0) { 
					playersCount++;
					if(isDefined(players[i].pers["team"]) && (players[i].pers["team"] == "axis")){
						playersCountAxis++;
					}
					else if(isDefined(players[i].pers["team"]) && (players[i].pers["team"] == "allies")){
						playersCountAllies++;
					}
				}
			}
		}
		else if(opts == "real"){
			for( i = 0 ; i < players.size ; i++ ){
				if(!players[i].isbot && players[i].pers["team"] != "spectator"){
					playersCount++;
				}
			}
			game["realPlayers"]=playersCount;
		}
	}

	players["all"] = playersCount;
	players["axis"] = playersCountAxis;
	players["allies"] = playersCountAllies;
	return players;
}

_classCheck(weapon,class){
	if(isDefined(class)){
		for (i=0;i<class.size;i++){
			if (isSubStr(weapon, class[i])){ 
				return true;
 			}
		}
	} else {
		classes[0] = level.classSniper;
		classes[1] = level.classRPG;
		classes[2] = level.classGL;
		classes[3] = level.classRifle;
		classes[4] = level.classMG;
		classes[5] = level.classSMG;
		classes[6] = level.classPistol;
		classes[7] = level.classBoltSniper;
		wc = StrTok("sniper,rpg,gl,rifle,mg,smg,pistol,bolt",","); 
		for (i=0;i<classes.size;i++){
			for (j=0;j<classes[i].size;j++){
				if (isSubStr(weapon,classes[i][j])){ 
					return wc[i];
 				}
 			}
		}
	}
}

_server_send_update(){
	level endon ( "disconnect" );
	
	if (getDvarInt("v01d_log_players")!=1){ return; }
	
	for(;;){
		realTime = getRealTime();
		realDate = TimeToString(realTime, 0, "%F");
		dateTime = TimeToString(realTime, 0, "%F %T");
		filename = "update.log";
		mapname = getDvar("mapname");
		teamscores["axis"] = [[level._getTeamScore]]( "axis" );
		teamscores["allies"] = [[level._getTeamScore]]( "allies" );
		
		if (FS_TestFile(filename)){
			fd = FS_FOpen( filename, "append" );
		} else {
			fd = FS_FOpen( filename, "write" );
		}
		
		FS_WriteLine(fd, "datetime: "+dateTime+" map: "+mapname+" teamscores: axis["+teamscores["axis"]+"] | allies ["+teamscores["allies"]+"]");
		FS_FClose( fd ); 
		wait 15;
	}
}

_player_info(n,pname){
	realTime = getRealTime();
	realDate = TimeToString(realTime, 0, "%F");
	dateTime = TimeToString(realTime, 0, "%F %T");
	playername = StrRepl(pname, "/", "_");
	playername = StrRepl(playername, "\\", "_");
	playername = StrRepl(playername, ":", "_");
	playername = StrRepl(playername, ".", "_");
	playername = StrRepl(playername, "?", "_");
	playername = StrRepl(playername, "!", "_");
	filename = "playerlogs/" + realDate + " " + playername + ".log";
	
	if (FS_TestFile(filename)){
		fd = FS_FOpen( filename, "append" );
	} else {
		fd = FS_FOpen( filename, "write" );
	}
	
	if (n == 1)
		FS_WriteLine( fd, "datetime: " + dateTime + ", player joined: " + pname );
	else if (n == 2)
		FS_WriteLine( fd, "datetime: " + dateTime + ", player spawned: " + pname );
	else if (n == 3)
		FS_WriteLine( fd, "datetime: " + dateTime + ", player left: " + pname );
	
	FS_FClose( fd );    
}

/* \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

---------------------------server debug----------------------------------

\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/ */

_waittillframesend(c){
	level endon("disconnect");
	for(;;){
		if(c > 0){ 
			//cl("33waittillframeend start");
			for(i=0;i<c;i++){ waittillframeend; }
			//cl("33waittillframeend end");
		}
	}
}

_dev_test_clcmds(){
	//self setClientDvar("ui_ShowMenuOnly", "none");
	//self scripts\menus::_create_menu_bg("hudWelcomeBG","CENTER","TOP",100,100,0,0,(1,1,1),1,1,"black",50,"fullscreen","fullscreen");
	self _film_tweaks(1,0.05,"1 0.6 0.6","1 0.6 0.6",0.6,1,1,0,1);
	//_film_tweaks(enable,blur,dtint,ltint,desat,glow,glowdesat,bright,contrast){
}

_dev_test_dp(to, from, dir){
	self endon ( "disconnect" );
	self endon ( "death" );
	self endon( "intermission" );
	self endon( "game_ended" );
	if(self.isbot){ return; }
	for(;;){
		a = self GetPlayerAngles();
		dirToTarget = VectorNormalize(level.sabBomb.curOrigin - self getEye());
		forward = AnglesToForward(a);
		vd = vectordot(dirToTarget, forward);
		cl("33"+self.name+":"+vd);
		wait 0.5;
	}
}

_dev_test_fx(){
	self endon ( "disconnect" );
	self endon ( "death" );
	self endon( "intermission" );
	self endon( "game_ended" );
	if(self.isbot){ return; }
	
	fx = loadfx ("explosions/artilleryExp_dirt_brown");
	
	for(;;){
		while(!self UseButtonPressed()){ wait 0.05; }
		//self setClientDvar("mp_QuickMessage","");
		myAngles = self GetPlayerAngles();
		startPos = self getEye();
		startPosForward = startPos + anglesToForward((myAngles[0],myAngles[1],0))*1200;
		trace = bulletTrace(startPos,startPosForward,true,self);
		pos = trace["position"];
		//ent = trace["entity"];
		if(isDefined(pos)){
			playfx (fx, pos);
			self thread _playSoundInSpace("rocket_explode_default",pos,0,self);		
		}
		while(self UseButtonPressed()){	wait 0.05; }
		wait 0.05;
	}
}

_dev_ent_test(){
	self endon ( "disconnect" );
	self endon ( "death" );
	if(self.isbot){ return; }

	for(;;){
		angles = self GetPlayerAngles();
		startPos = self getEye();
		startPosForward = startPos + anglesToForward( ( angles[0], angles[1], 0 ) ) * 64;
		trace = bulletTrace( startPos, startPosForward, true, self );
		ent = trace["entity"];
		
		if(isDefined(ent)){
			cl("33"+self.name+" is pointing at "+ent.model);
			//visuals[0] = getEnt( ent, "targetname" );
			//org = spawn("script_model", ent.origin);
			//org = spawn( "script_origin", ent.origin );
			//org.targetname = "test1";
			//v[0] = getEnt( "test1", "targetname" );
			//v[0] setModel( ent.model );
			//v[0] StartRagdoll(0);
			wait 0.5;
		}
		wait 0.2;
	}
}

_dev_tag_angles(){
	self endon ( "disconnect" );
	self endon ( "death" );
	if(self.isbot){ return; }
	level.disableLinkTo = true;
	
	wait 0.5;

	cl("33"+self.model);
	ent = GetEnt(self.model,"model");
	//ent = GetEntArray(self.model,"model");
	//ent = self getEntityNumber();
	self waittill("death");
	self freezeControls(true);
	
	while(1){
	//while(self.sessionteam != "spectator"){
		
		level waittill("timers");
		cl("33"+self.model);
		headAngles = self GetTagAngles("j_head");
		headOrigin = self GetTagOrigin("j_head");
		self SetPlayerAngles((headAngles[0],headAngles[1],headAngles[2]) - (headAngles[0],self.angles[1]+45,self.angles[2]));
		//self SetOrigin(self.origin - headOrigin);
		//cl("33ent"+ent[0].origin[1]);
		cl("33ang"+headAngles[1]);
		cl("33org:"+headOrigin[1]);
		//level.tp = (gettime() - level.st)/1000;
		cl("^2level.tp "+level.tp);
		//self linkTo(self, "j_head", (0,0,0), (0,0,0));
		//wait 0.05;
		//self unlink();
	}
}

_dev_round_time_passed(){
	level endon("disconnect");
	level endon("intermission");
	level endon("game_ended");
	for(;;){
		level.tp = int((gettime() - level.st)/1000);
		//cl("22level.tp:"+level.tp);
		wait 1;
	}
}

_dev_getClientDvar(dvar){
	self endon ( "disconnect" );
	self endon ( "death" );
	self endon( "intermission" );
	self endon( "game_ended" );

    self setClientDvar("getting_dvar",dvar);
    self openMenu(game["menu_clientdvar"]);   
    
    for(;;)
    {
        self waittill("menuresponse", menu, response);
        if(menu==game["menu_clientdvar"])
        {
        	cl("^4response:"+response);
            return response;
        }
    }
}

_dev_timescale(){
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	if(self.isbot){ return; }

	while(isAlive(self)){
		self setClientDvar("m_pitch",0.022);
		self setClientDvar("m_yaw",0.022);
		SetDvar("timescale", 0.3);
		wait 1;
	}
}

_dev_waittillframeend_test(){
	level endon("disconnect");
	
	for(;;){
		c = int(getDvar("fr"));
		if(c > 0){ 
			wait 1;
			cl("33waittillframeend start");
			for(i=0;i<c;i++){ waittillframeend; }
			cl("33waittillframeend end");
			wait 1;
		}
		setDvar("fr",0);
		wait 0.1;
	}
}

_dev_start(){
	if (!getdvarint("developer")>0){ return; }
	
	wait 1;
	
	game["teamScores"]["axis"]=0;
	game["teamScores"]["allies"]=0;
	[[level._setTeamScore]]( "axis", 0 ); 
	[[level._setTeamScore]]( "allies", 0 ); 
}

_dev_sound_test(){
	self endon ( "disconnect" );
	self endon ( "game_ended" );
	self endon ( "intermission" );
	
	if(self.isbot){ return; }
	
	s = StrTok("clusterbomb_explode_default,clusterbomb_explode_layer,clusterbomb_explode_layer_2,grenade_explode_default,grenade_explode_bark,grenade_explode_brick,grenade_explode_carpet,grenade_explode_cloth,grenade_explode_concrete,grenade_explode_dirt,grenade_explode_layer,grenade_explode_layer_2",","); i=0;
	
	cl("33_dev_sound_test");
	for(;;){
		while(!self LeanLeftButtonPressed() && !self LeanRightButtonPressed()){ wait 0.05; }
		if(self LeanLeftButtonPressed()){ i--; }
		if(self LeanRightButtonPressed()){ i++; }
		if(i>s.size){ i=s.size; }
		if(i<0){ i=0; }
		self playLocalSound(s[i]);
		cl("33sound: "+s[i]);
		while(self LeanLeftButtonPressed() || self LeanRightButtonPressed()){ wait 0.05; }
		wait 0.05;
	}
}

_dev_weapon_test(){
	self endon ( "disconnect" );

	if (getdvarint("bots_main_debug") != 0) { return; }  
	if(self.isbot){ return; }
	
	cl("33_dev_weapon_test on "+self.name);
	level.doNotAddBots=true;
	self.bodyModel=0;
	self.weaponModel=0;

	weapons=strTok("barrett_acog_mp",",");
	//weapons=strTok("barrett_acog_mp,ak47_gl_mp",",");
	//weapons=strTok("ak74u_reflex_mp,ak74u_acog_mp,ak74u_silencer_mp,g36c_reflex_mp",",");
	//weapons=strTok("m4_reflex_mp,m14_reflex_mp",",");
	//weapons=strTok("m60e4_grip_mp,m60e4_acog_mp",",");
	models=strTok("body_mp_arab_regular_assault,body_mp_usmc_assault,body_mp_usmc_sniper",",");
	start=undefined; llb=undefined; lrb=undefined; hbb=undefined;
	wait 1;
	self.thirdPerson=false;

	level thread _add_some_bots(1);
	
	for(;;){
		if(!isDefined(self.bodyModel)){ self.bodyModel=0; }
		if(!isDefined(self.weaponModel)){ self.weaponModel=0; }
		if(self LeanLeftButtonPressed()){ llb=true; start=true; }
		if(self LeanRightButtonPressed()){ lrb=true; start=true; }
		if(self HoldBreathButtonPressed()){ hbb=true; start=true; }
		players = getentarray( "player", "classname" );
		if(isDefined(start)){
			if(isDefined(lrb)){
				if(self.thirdPerson==false){ self setClientDvars("cg_thirdperson", 1); self.thirdPerson=true; }
				else{ self setClientDvars("cg_thirdperson", 0); self.thirdPerson=false; }
				
				hbb=undefined;
			}
			for(i=0;i<players.size;i++){
				if (isAlive(self) && !isDefined(self.buyMenuShow)){
					if(players[i].isbot){ players[i].bot.stop_move=true; }
					weapon = players[i] GetCurrentWeapon();
		 			if (isDefined(weapons) && weapon != weapons[self.weaponModel]){
						if(isDefined(llb)){ 
							players[i] maps\mp\gametypes\_weapons::detach_all_weapons();
							players[i] giveWeapon(weapons[self.weaponModel]);
							players[i] giveMaxAmmo(weapons[self.weaponModel]);
							players[i] switchToWeapon(weapons[self.weaponModel]);
							cl(players[i].name+" weapon "+weapons[self.weaponModel]);
						}
						if(isDefined(lrb)){ 
							players[i] setModel(models[self.bodyModel]);
							cl(players[i].name+" model "+models[self.bodyModel]);
						}
					}
				}
			}
			start=undefined; llb=undefined; lrb=undefined;
			self.bodyModel++;
			self.weaponModel++;
			if(self.bodyModel>=models.size){ self.bodyModel=0; }
			if(self.weaponModel>=weapons.size){ self.weaponModel=0; }
			wait 0.5;
		}
		wait 0.05;
	}
}

_dev_hp_test(){
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );

	if(self.isbot){ return; }

	wait 1;
	
	hp="radar_mp";
	
	for(;;){
		self maps\mp\gametypes\_hardpoints::giveHardpointItem( hp );
		cl(self.name+" is given hardpoint "+self.pers["hardPointItem"]);
		while (isDefined(self.pers["hardPointItem"])) { wait 1; }
		cl("^3"+self.name+" used "+hp);
	}	
}

_dev_coords(){
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	if (!getdvarint("developer")>0){ return; }
	if(self.isbot){ return; }
	if(getDvar("g_gametype") != "sab"){ return; }
	
	for(;;){
		while (!self UseButtonPressed()){ wait 0.05; }
	
		//level.sabBomb.trigger.origin = (-2777,-59,72);
		//level.sabBomb.curOrigin = (-2777,-59,72);
		//level.sabBomb.visuals[0].origin=(-2777,-59,72);
		
		cl(self.origin);
		//cl(level.sabBomb.visuals[0].origin);
		//cl(level.sabBomb.curOrigin);
		
		filename = "coords/" + getDvar("mapname") + ".bomb";
	
		if (FS_TestFile(filename)){	fd = FS_FOpen( filename, "append" ); } 
		else { fd = FS_FOpen( filename, "write" ); }
		
		FS_WriteLine( fd, self.origin );
		FS_FClose( fd );
		
		while(self UseButtonPressed()) { wait 0.05; }
		
		wait 0.05;
	}
}

_marker(){
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	if (getdvarint("developer")>0){ return; }
	if (self.isbot) { return; }
	
	wait 0.5;

	for(;;){
		while (isDefined(self.ent)) { wait 0.1; }
		if (isAlive(self)){
			myAngles = self GetPlayerAngles();
			startPos = self getTagOrigin( "j_head" );
			startPosForward = startPos + anglesToForward( ( myAngles[0], myAngles[1], 0 ) ) * 1200;
			af = AnglesToForward(self GetPlayerAngles());
			trace = bulletTrace( startPos, startPosForward, true, self );
			pos = undefined;
			self.ent = trace["entity"]; 
			
			if (isDefined(self.ent) && isPlayer(self.ent) && self.ent.isbot && self.ent.team == self.team) {
	          		self thread _set_hud_wpt("markers","compass_waypoint_bomb", 8,8,0.1,undefined,undefined,undefined,self.ent);
	          		wait 0.5;
			}
		}
	self.ent=undefined;
	wait 0.05;
	}
}

_hudMarkers_create_hud_elem(hud, i, icon, sx, sy, a, px, py, pz, ent, dur, freq){
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );

	if(!isDefined(level.hudMarkers)) { return; } 
	if(!isDefined(level.hudMarkers[hud])) { return; } 
	if (!isDefined(icon)){ icon = "compass_waypoint_bomb"; }
	if (!isDefined(sx) || !isDefined(sy)){ sx = 15; sy = 15; }
	if (!isDefined(a) || a < 0.1){ a = 0.5; }
	
	level.hudMarkers[hud][i] = newClientHudElem( self );
	level.hudMarkers[hud][i] setShader( icon, sx, sy );
	level.hudMarkers[hud][i] SetWayPoint(false, icon);
	level.hudMarkers[hud][i].alpha = a;
	
	if (isDefined(px) && isDefined(py) && isDefined(pz)){ level.hudMarkers[hud][i].x = px; level.hudMarkers[hud][i].y = py; level.hudMarkers[hud][i].z = pz; }
}

_hudMarkers_hud_destroy(hud,i){
	self endon("disconnect");
    self endon("death");
    
	if(isDefined(hud) && isDefined(level.hudMarkers[hud][i])){ 
		level.hudMarkers[hud][i] Destroy(); 
	}
}


_hudMarkers_show(){
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	if (getdvarint("developer") == 0){ return; }
	if (getdvarint("bots_main_debug") == 0) { return; }
	if (self.isbot) { return; }
	
	level.hudMarkers["markers"] = [];
	
	cl("hudMarkers_show");
	
	while(1){
		if(isDefined(level.hudMarkers) && isDefined(level.hudMarkers["pos"])){
			for( i = 0 ; i < level.hudMarkers["pos"].size ; i++ ){
				if(isDefined(level.hudMarkers["pos"][i])){
					self _hudMarkers_create_hud_elem("markers", i, "compass_waypoint_target", 8, 8, 0.5, level.hudMarkers["pos"][i][0], level.hudMarkers["pos"][i][1], level.hudMarkers["pos"][i][2]);
					//cl("^3"+level.hudMarkers["pos"][i]);
				}
				//cl("^3"+i);
				//self _set_hud_wpt (hud, icon, sx, sy, a, px, py, pz, ent, dur, freq)
			}
			//cl("level.hudMarkers[pos].size:"+level.hudMarkers["pos"].size);
			//cl("level.hudMarkers[markers].size:"+level.hudMarkers["markers"].size);
		}
		wait 0.5;
		//if(isDefined(self.hudwpt) && isDefined(self.hudwpt["hudMarkers"])){
		//	cl("self.hudwpt[hudMarkers].size:"+self.hudwpt["hudMarkers"].size);
		//}
		if(isDefined(level.hudMarkers) && isDefined(level.hudMarkers["markers"]) && level.hudMarkers["markers"].size>0){
			//self _hudMarkers_hud_destroy("markers");
			for( i = 0 ; i < level.hudMarkers["markers"].size ; i++ ){
				if(isDefined(level.hudMarkers["markers"][i])){
					self _hudMarkers_hud_destroy("markers",i);
					//level.hudMarkers["markers"] = _arr_remove(level.hudMarkers["markers"],level.hudMarkers["markers"][i]);
				}
				//cl("destroying hud: "+i);
			}
		}
	}
}

_hudMarkers_add_remove(name,index,data,delete){
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	if (self.isbot) { return; }
	
	cl("hudMarkers_add_remove");
	if(isDefined(name)){ level.hudMarkers[name] = []; } else { return; }
	level.hudMarkersQuantity = 0;
	
	if(isDefined(name)){
		//for( i = 0 ; i < level.hudMarkers[name].size ; i++ ){
			if (isDefined(delete) && isDefined(index)){
				//level.hudMarkers[name] = _arr_remove(level.hudMarkers[name],level.hudMarkers[name][index]);
				cl("^1deleted:"+index);
			} else if (isDefined(index) && index>-1 && isDefined(data)){
				level.hudMarkers[name][index] = data;
				cl("^4data:"+data);
			}
		//}
		cl("^5level.hudMarkers["+name+"].size: "+level.hudMarkers[name].size);
	}
}

_dev_wpt_helpers_add_remove(){
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	if (getdvarint("bots_main_debug") == 0) { return; }  
	if (getdvarint("developer") == 0){ return; }
	if (self.isbot) { return; }
	
	cl("_dev_wpt_helpers_add_remove");
	
	level.hudMarkers["pos"] = [];

	for(;;){
		while (!self useButtonPressed()){ wait 0.1;	}
		c=10;
		while (self UseButtonPressed() && c>=0){ c--; wait 0.05; }
		
		if (self.pers["team"] != "spectator" && c<0)  {
			myAngles = self GetPlayerAngles();
			startPos = self getEye();
			//startPos = self.origin + ( 0, 0, 50 );
			startPosForward = startPos + anglesToForward( ( myAngles[0], myAngles[1], myAngles[2] ) ) * 1200;
			af = AnglesToForward(self GetPlayerAngles());
			trace = bulletTrace( startPos, startPosForward, true, self );
			pos = undefined;
			index = undefined;
			delete = false;
			if (isAlive(self) && isDefined(level.hudMarkers["pos"])){
			
				for( i = 0 ; i < level.hudMarkers["pos"].size ; i++ ){
					//if (isDefined(level.hudMarkers["pos"][i])){ 
					//	dist = distance(self.origin, level.hudMarkers["pos"][i]); 
					//}
					if (isDefined(level.hudMarkers["pos"][i]) && distance(self.origin, level.hudMarkers["pos"][i]) < 200){
						index=i;
						cl("^1index:"+index);
						delete = true;
					}
				}
				if(isDefined(index) && delete){
					//self _hudMarkers_add_remove("pos",index,undefined,true);
					level.hudMarkers["pos"] = _arr_remove(level.hudMarkers["pos"],level.hudMarkers["pos"][index]);
					cl("^1deleted:"+index);
				}
				if(!delete){
					pos = trace["position"];
					//self.ent = trace["entity"]; 
					index = level.hudMarkers["pos"].size;
					level.hudMarkers["pos"][index] = pos;
					cl("^2index:"+index);
					//self _hudMarkers_add_remove("pos",index,pos);
					
					//level.hudMarkers["markers"][level.hudMarkers["markers"].size] = pos;
					//level.hudMarkersQuantity++;
					//level.hudMarkers[level.hudMarkers.size].targetname = "hudMarkers";
					//cl("^1level.hudMarkers[pos].size: "+level.hudMarkers["pos"].size);
					//cl("^5level.hudMarkers[markers].size: "+level.hudMarkers["markers"].size);
					//cl("^5level.hudMarkersQuantity: "+level.hudMarkersQuantity);
				}
			}	
		wait 0.5;
		} 
			
		while(self useButtonPressed())
		{
			wait 0.1;
		}
		wait 0.05;
	}
}

/* \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

---------------------------server start----------------------------------

\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/ */

_precache_info(delay){
	wait delay;
	if(isDefined(level.precachedItemsNum)){ cl("33Totally precached "+level.precachedItemsNum+" items!"); }
}

_prematch(){
	self endon ( "death" );
	self endon ( "intermission" );
	self endon ( "game_ended" );
	
	self waittill("spawned_player");
	for(;;){
		self freezeControls(true);
		level waittill("prematch_over");
		cl("prematch is over");
		self freezeControls(false);
	}
}

_bot_balance_manage(){
	level endon ( "disconnect" );

	if(getDvarInt("v01d_bots_inbalance_feature") == 1 && !isDefined(level.doNotAddBots)){
		wait 1;
		axisScore = [[level._getTeamScore]]( "axis" );
		alliesScore = [[level._getTeamScore]]( "allies" );
		_axisScore = axisScore;
		_alliesScore = alliesScore;
		while(axisScore==_axisScore && alliesScore==_alliesScore){ 
			wait 1;
			axisScore = [[level._getTeamScore]]( "axis" );
			alliesScore = [[level._getTeamScore]]( "allies" );
		}
		
		if(maps\mp\gametypes\_globallogic::hitScoreLimit()){ return; }

		if(axisScore>_axisScore){ game["teamWonRound"]="axis"; }
		if(alliesScore>_alliesScore){ game["teamWonRound"]="allies"; }
		
		wait 3;
		axisCount=0;
		alliesCount=0;
		players = getentarray( "player", "classname" );
		for(i=0;i<players.size;i++){
			if(players[i].isbot){
				if(players[i].pers["team"] == "axis"){ axisCount++; }
				if(players[i].pers["team"] == "allies"){ alliesCount++; }
			}
		}

		if(isDefined(game["teamWonRound"])){			
			if(game["teamWonRound"]=="axis"){ 
				if(axisCount>=4){ exec("tr ax"); }
				wait 0.3;
			} else if(game["teamWonRound"]=="allies"){ 
				if(alliesCount>=4){ exec("tr al"); }
				wait 0.3;
			}
		}
	}
}

_init_bots_dvars(){
	level endon("disconnect");
	
	if (getdvarint("bots_main_debug") != 0) { return; }  
	if (getdvarint("developer") != 0){
		setDvar("bots_manage_fill", 6);
	} else {
		if(game["roundsplayed"]<1){
			wait 0.5;
			realPlayers=_chk_players("real");
			bots=18-int(realPlayers["all"]);
			for(i=0;i<level._maps.size;i++){
				mapname = getDvar("mapname");
				if(mapname == level._maps[i]){ 
					game["botPlayers"]=int(level._maps[i+1]);
					bots=int(game["botPlayers"]-realPlayers["all"]);
					break;
				}
			}
			level thread _add_some_bots(bots);
		}
	}
}

_add_some_bots(bots){
	wait 0.5;
	if(isDefined(level.doNotAddBots)){ return; }
	setDvar( "testclients_doreload", true );
	if(isDefined(level.botsAdded)){ cl("resetting bots"); }
	wait 0.5;
	setDvar( "testclients_doreload", false );
	level.botsAdded=true;
	if(!isDefined(bots)){ bots=10; }
	for(i=0;i<bots/2;i++){
		if(isDefined(level.doNotAddBots)){ break; }
		setDvar("ab","ax");
		wait 1.5;
		setDvar("ab","al");
		wait 1.5;
	}
}

_kick_some_bots(bots){
	wait 0.5;
	level.botsKicked=true;
	if(!isDefined(bots)){ bots=1; }
	
	for(i=0;i<bots/2;i++){
		setDvar("kb","ax");
		wait 1.5;
		setDvar("kb","al");
		wait 1.5;
	}
}

_get_team_score(){
    cl("^1axis:"+[[level._getTeamScore]]( "axis" )+" ^7| ^5allies:"+[[level._getTeamScore]]( "allies" )); 
    cl("map:"+getDvar("mapname")); 
}

_check_sleepers(){
	self endon("disconnect");
	self endon("game_ended");
	self endon("intermission");
	self endon ("death");
	
	if (getdvarint("developer")>0){ return; }
	if (self.isbot) { return; }
	
	self waittill("spawned_player");

	if(isAlive(self)){
		self.sleeping = 0;
		sleepTime = 7;
		self.pers["sleeping"] = false;
		distance=0;
		max_distance = 20;
		currentweapon = self GetCurrentWeapon();
		wait 1;
		old_position = self.origin;
		wait 30;
				
		if(self.pers["sleeping"] != true && isAlive(self))
		{
			while( distance < max_distance ){
				new_position = self.origin;
				distance = distance2d( old_position, new_position );
				if( distance < max_distance ){
					self.sleeping++;
					self.pers["sleeping"] = true;
				} else {
					if (self.pers["team"] != "spectator") { 
						self.pers["sleeping"] = false; 
						self.sleeping = 0;
					}
					continue; // is this allowed in cod4? (if not, just remove this as it's not needed)
				}
			
				if(self.sleeping == sleepTime && self.pers["sleeping"])
				{
					str1="No sleeping allowed";
					str2="You have "+(sleepTime-2)+" seconds to move";
					self thread scripts\menus::_show_hint_msg(str1,0,2,320,70,0,0,"left","middle",0,0,"objective",1.6,3.6,(0.2,1,0.2),1,(0.2,0.3,0.7),1,1,true,undefined);
					self thread scripts\menus::_show_hint_msg(str2,0.3,2,320,110,0,0,"left","middle",0,0,"objective",1.6,2.6,(1,0.2,0.2),1,(0.2,0.3,0.7),1,1,true,undefined);
					self playLocalSound(game["voice"][self.pers["team"]]+"new_positions");		
				}
				else if(self.sleeping == (sleepTime*2) && self.pers["sleeping"])
				{
					self.pers["lives"] = 0;
					self notify("menuresponse", game["menu_team"], "spectator");
					wait 0.1;
					cl("^1"+self.name + " is kicked to spectators for sleeping");
					self closeMenu();
					self closeInGameMenu();
					wait 0.1;
				}
				wait 1;
			}
		}
	}
}

_sleepers(){
	level endon("disconnect");
	level endon("game_ended");
	if (!isDefined(level._sleepers)) { level._sleepers=""; }
	
	level._sleepers="";
	players = getentarray( "player", "classname" );
	for( i = 0 ; i < players.size ; i++ ){
		if(!players[i].isbot && isdefined(players[i].pers["sleeping"]) && players[i].pers["sleeping"] == true) 
			level._sleepers += players[i].name+",";
	}
	
	return level._sleepers;
}

/* \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

-----------------------server map management----------------------------

\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/ */

_next_map_index(){
	nextmapindex="maps\nextmapindex";
	if(FS_TestFile(nextmapindex)){
		fd = FS_FOpen(nextmapindex, "read");
		index = FS_ReadLine(fd);
		game["nextMapIndex"]=int(index);
		game["nextMapIndex"]++;
		if(game["nextMapIndex"] >= level.mapList.size){ game["nextMapIndex"]=0; }
		FS_FClose(fd);
		fd = FS_FOpen( nextmapindex, "write");
		FS_WriteLine(fd, game["nextMapIndex"]);
		FS_FClose(fd);
	} else {
		fd = FS_FOpen( nextmapindex, "write");
		FS_WriteLine(fd, game["nextMapIndex"]);
		game["nextMapIndex"]++;
		FS_FClose(fd);
	}
}

_maps_randomizer(){
	level endon ( "disconnect" );
	
	wait 2;
	
	filename="sv_maps.cfg";
			
	if(FS_TestFile(filename) && game["mapList"].size<1){ 
		csv = FS_FOpen(filename, "read");
		line = FS_ReadLine(csv);
		while (isDefined(line) && line != ""){
			if (line == "") { continue; }
			if (isSubStr(line,"map")){ break; }
			line = FS_ReadLine(csv);
		}
		FS_FClose(csv);
		line = StrRepl(line, "set sv_mapRotation ", "");
		line = StrRepl(line, "\"", "");
		line = StrRepl(line, "map ", "");
		game["mapList"] = strTok(line," ");
	}
		
	level.mapList = game["mapList"];
	if(isDefined(level.mapList)){
		if(getDvar("v01d_maps_randomizer") == "1"){
			n=randomIntRange(0,level.mapList.size);
			level.nextMap = level.mapList[n];
			if (game["nextMap"] == game["prevMap"]){ game["nextMap"]=level.nextMap; }
			game["nextMapIndex"]=n;
			cl("22next map: "+game["nextMap"]);
			level waittill("game_ended");
			if(level.teamBased && (maps\mp\gametypes\_globallogic::hitRoundLimit() || maps\mp\gametypes\_globallogic::hitScoreLimit())){
				cl("33_maps_randomizer-hitScoreLimit");
				game["prevMap"]=game["nextMap"];
				cl("33_maps_randomizer-waiting for end_killcam");
				//level waittill("end_killcam"); 
				wait 20;
				cl("33_maps_randomizer-fk ended");			
				cl("22next map: "+game["nextMap"]);
				if(getDvar("g_gametype")!="sab"){ setDvar("g_gametype","sab"); }
				if(isDefined(level._gametypes)){
					for(i=0;i<level._gametypes.size;i+=2){ 
						if(level._gametypes[i]==game["nextMap"]){ 
							setDvar("g_gametype",level._gametypes[i+1]); 
							cl("33g_gametype will be \""+level._gametypes[i+1]+"\"");
							break; 
						}
					}
				}
				wait getDvarFloat( "scr_intermission_time" )-1.5;
				exec("map " + game["nextMap"]+" 0");
				game["nextMap"]="";
			}
		} else {
			level.nextMap = level.mapList[game["nextMapIndex"]];
			game["nextMap"]=level.nextMap;
			cl("22next map: "+game["nextMap"]);
			level waittill("game_ended");
			if(level.teamBased && (maps\mp\gametypes\_globallogic::hitRoundLimit() || maps\mp\gametypes\_globallogic::hitScoreLimit())){
				level thread _next_map_index();
				level waittill("end_killcam");
				cl("22next map: "+game["nextMap"]);
				wait getDvarFloat( "scr_intermission_time" )-1.5;
				exec("map " + game["nextMap"]+" 0");
				game["nextMap"]="";
			}
		}
	}
}

/*player_settings(id){
	level endon ( "disconnect" );
	filename = "playersdata/"+id;
	fd = FS_FOpen( filename, "write" );
	line = FS_ReadLine(csv);
	i=0;
	while (isDefined(line) && line != ""){ line = FS_ReadLine(csv); i++; }
	FS_WriteLine(fd, "3rd:"+3rd);
	FS_FClose(fd); 
	cl("^3disconnect money: "+money);
}*/

mp_efa_bingoland(){
	mapname = getDvar( "mapname" );
	if(mapname == "mp_efa_bingoland")
		cl(mapname);
	else 
		return;
	
	//spawn("mp_sab_spawn_allies", (-341.395, -1482.38, 808.836));
	//spawn("mp_sab_spawn_axis", (-341.395, -1482.38, 808.836));
	_sab_bomb = spawn("script_model", (-341.395, -1482.38, 808.836));
	_sab_bomb.targetname = "sab_bomb";
	_sab_bomb_trig = spawn("trigger_radius", (-341.395, -1482.38, 808.836), 0, 48, 148);
	_sab_bomb_trig.targetname = "sab_bomb_pickup_trig";
	//_sab_bomb_axis = spawn("trigger_radius", (-1770.45, -1471.6, 354.619), 0, 48, 148);
	//_sab_bomb_axis.targetname = "sab_bomb_axis";
	//_sab_bomb_allies = spawn("trigger_radius", (1214.6, -1487.14, 441.027), 0, 48, 148);
	//_sab_bomb_allies.targetname = "sab_bomb_allies";
	precacheModel( "prop_suitcase_bomb" );	
	visuals[0] = getEnt( "sab_bomb", "targetname" );
	visuals[0] setModel( "prop_suitcase_bomb" );
	
	wait 1;
	
}

_bomb_file(mapname)
{
	pos = [];
	filename = "coords/" + mapname + ".bomb";
	if ( !FS_TestFile( filename ) ) { cl("No bomb file to read"); return pos; }
	f = FS_FOpen( filename, "read" );
	p = FS_ReadLine(f);
	while (isDefined(p) && p != "")
	{
		pos[pos.size] = p;
		p = FS_ReadLine(f);
	}
	FS_FClose(f);
	return pos;
}

_sab_bomb_visibility(){
	level endon ( "disconnect" );
	level endon ( "intermission" );
	level endon ( "game_ended" );
	
	if(getDvar("g_gametype") != "sab"){ return; }
	
	axisGotRadar=false;
	alliesGotRadar=false;
	level.sabBomb.objPoints["axis"].alpha=0;
	level.sabBomb.objPoints["allies"].alpha=0;
	level.sabBomb maps\mp\gametypes\_gameobjects::setVisibleTeam( "none" );
	level.bombZones["axis"] maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
	level.bombZones["allies"] maps\mp\gametypes\_gameobjects::setVisibleTeam( "any" );
	level.bombZones["axis"].objPoints["axis"].alpha=0;
	level.bombZones["axis"].objPoints["allies"].alpha=0;
	level.bombZones["allies"].objPoints["allies"].alpha=0;
	level.bombZones["allies"].objPoints["axis"].alpha=0;
	for(;;){
		//cl("sabBomb: axis = "+level.sabBomb.objPoints["axis"].alpha);
		//cl("sabBomb: allies = "+level.sabBomb.objPoints["allies"].alpha);
		//cl("bombZones: axis|allies = "+level.bombZones["axis"].objPoints["allies"].alpha);
		//cl("bombZones: axis|axis = "+level.bombZones["axis"].objPoints["axis"].alpha);
		//cl("bombZones: allies|axis = "+level.bombZones["allies"].objPoints["axis"].alpha);
		//cl("bombZones: allies|allies = "+level.bombZones["allies"].objPoints["allies"].alpha);

		players = getentarray( "player", "classname" );
		bombPos = level.sabBomb.curOrigin;
		//cl(bombPos);
		
		//if (getTeamRadar("axis") && axisGotRadar==false) {
		if (getTeamRadar("axis")) {
			//if(level.sabBomb.objPoints["axis"].alpha<0.5){ level.sabBomb.objPoints["axis"].alpha+=0.05; }
			//if(level.bombZones["axis"].objPoints["axis"].alpha<0.5) { level.bombZones["axis"].objPoints["axis"].alpha+=0.05; }
			//if(level.bombZones["axis"].objPoints["allies"].alpha<0.5) { level.bombZones["axis"].objPoints["allies"].alpha+=0.05; }
			//cl("^2axis bombZones alpha 1");
			for( i = 0 ; i < players.size ; i++ ){
				if(players[i].isbot){ continue; }
				if(players[i].pers["team"] == "axis") {
					//players[i] _set_hud_wpt("hudBomb", "waypoint_bomb", 8, 8, 1, 1, 0.5, bombPos[0], bombPos[1], bombPos[2], 2);
					//players[i] thread _set_hud_wpt("hudBomb", "waypoint_bomb", 8, 8, 0.5, bombPos[0], bombPos[1], bombPos[2], level.sabBomb);
					//players[i] _set_hud_wpt(hud, icon, sx, sy, a, px, py, pz, ent, dur, freq)
					//cl("^2axis hud defined");
					if(isDefined(players[i].hudwpt)) {
						//cl("^2axis hud defined");
						//players[i] thread _hud_wpt_dim("hudBomb",0.5,1,level.sabBomb);
						//if(isDefined(players[i].hudwpt["hudBomb"].alpha) && players[i].hudwpt["hudBomb"].alpha<0.5) { players[i].hudwpt["hudBomb"].alpha+=0.05; cl(players[i].hudwpt["hudBomb"].alpha); }
					}
				}
			}
			axisGotRadar=true;
		//} else if (!getTeamRadar("axis") && axisGotRadar==true){
		} else if (!getTeamRadar("axis")){
			//if(level.sabBomb.objPoints["axis"].alpha>0){ level.sabBomb.objPoints["axis"].alpha-=0.05; }
			//if(level.bombZones["axis"].objPoints["axis"].alpha>0) { level.bombZones["axis"].objPoints["axis"].alpha-=0.05; }
			//if(level.bombZones["axis"].objPoints["allies"].alpha>0) { level.bombZones["axis"].objPoints["allies"].alpha-=0.05; }
			//cl("^2axis bombZones alpha 0");
			for( i = 0 ; i < players.size ; i++ ){
				if(players[i].isbot){ continue; }
				//players[i] thread _set_hud_wpt("hudBomb", "waypoint_bomb", 8, 8, 0.5, bombPos[0], bombPos[1], bombPos[2], level.sabBomb);
				//if(isDefined(players[i]) && isDefined(players[i].hudwpt) && isPlayer(players[i]) && isAlive(players[i]) && !players[i].isbot && players[i].pers["team"] == "axis") {
				//if(isDefined(players[i].hudwpt) && isDefined(players[i].hudwpt["hudBomb"]) && !players[i].isbot && players[i].pers["team"] == "axis") {
					//players[i] _hud_destroy("hudBomb");
				//	cl("^1axis hud destroyed");
				//}
			}
			axisGotRadar=false;
		}
			
		//if (getTeamRadar("allies") && alliesGotRadar==false) {
		if (getTeamRadar("allies")) {
			//if(level.sabBomb.objPoints["allies"].alpha<0.5){ level.sabBomb.objPoints["allies"].alpha+=0.05; }
			//if(level.bombZones["allies"].objPoints["axis"].alpha<0.5) { level.bombZones["allies"].objPoints["axis"].alpha+=0.05; }
			//if(level.bombZones["allies"].objPoints["allies"].alpha<0.5) { level.bombZones["allies"].objPoints["allies"].alpha+=0.05; }
			//cl("^2allies bombZones alpha 1");
			/*for( i = 0 ; i < players.size ; i++ ){
				if(players[i].isbot){ continue; }
				if(!players[i].isbot && players[i].pers["team"] == "allies") {
					//players[i] _set_hud_wpt("hudBomb", "waypoint_bomb", 8, 8, 1, 1, 0.5, bombPos[0], bombPos[1], bombPos[2]);
					//players[i] _set_hud_wpt("hudBomb", "waypoint_bomb", 8, 8, 0.5, bombPos[0], bombPos[1], bombPos[2], level.sabBomb);
					if(isDefined(players[i].hudwpt)) {
						cl("^2allies hud defined");
						//players[i] thread _hud_wpt_dim("hudBomb",0.5,1,level.sabBomb);
						//if(isDefined(players[i].hudwpt["hudBomb"].alpha) && players[i].hudwpt["hudBomb"].alpha<0.5) { players[i].hudwpt["hudBomb"].alpha+=0.05; cl(players[i].hudwpt["hudBomb"].alpha); }
					}
				}
			}*/
			alliesGotRadar=true;
		//} else if (!getTeamRadar("allies") && alliesGotRadar==true){
		} else if (!getTeamRadar("allies")){
			//if(level.sabBomb.objPoints["allies"].alpha>0){ level.sabBomb.objPoints["allies"].alpha-=0.05; }
			//if(level.bombZones["allies"].objPoints["axis"].alpha>0) { level.bombZones["allies"].objPoints["axis"].alpha-=0.05; }
			//if(level.bombZones["allies"].objPoints["allies"].alpha>0) { level.bombZones["allies"].objPoints["allies"].alpha-=0.05; }
			//cl("^2allies bombZones alpha 0");
			/*for( i = 0 ; i < players.size ; i++ ){
				if(players[i].isbot){ continue; }
				//if(isDefined(players[i]) && isDefined(players[i].hudwpt) && isPlayer(players[i]) && isAlive(players[i]) && !players[i].isbot && players[i].pers["team"] == "allies") {
				if(isDefined(players[i].hudwpt) && isDefined(players[i].hudwpt["hudBomb"]) && !players[i].isbot && players[i].pers["team"] == "allies") {
					//players[i] _hud_destroy("hudBomb");
					cl("^1allies hud destroyed");
				}
			}*/
			alliesGotRadar=false;
		}
		
		/*if (getTeamRadar("axis")) {
			if(level.sabBomb.objPoints["axis"].alpha<0.5){ level.sabBomb.objPoints["axis"].alpha+=0.05; }
			if(level.bombZones["axis"].objPoints["allies"].alpha<0.5) { level.bombZones["axis"].objPoints["allies"].alpha+=0.05; }
			if(level.bombZones["allies"].objPoints["allies"].alpha<0.5) { level.bombZones["allies"].objPoints["allies"].alpha+=0.05; }
		} else {
			if(level.sabBomb.objPoints["axis"].alpha>0){ level.sabBomb.objPoints["axis"].alpha-=0.05; }
			if(level.bombZones["axis"].objPoints["allies"].alpha>0) { level.bombZones["axis"].objPoints["allies"].alpha-=0.05; }
			if(level.bombZones["allies"].objPoints["allies"].alpha>0) { level.bombZones["allies"].objPoints["allies"].alpha-=0.05; }
		} 
		if (getTeamRadar("allies")) {
			if(level.sabBomb.objPoints["allies"].alpha<0.5){ level.sabBomb.objPoints["allies"].alpha+=0.05; }
			if(level.bombZones["allies"].objPoints["axis"].alpha<0.5) { level.bombZones["allies"].objPoints["axis"].alpha+=0.05; }
			if(level.bombZones["axis"].objPoints["axis"].alpha<0.5) { level.bombZones["axis"].objPoints["axis"].alpha+=0.05; }
		} else {
			if(level.sabBomb.objPoints["allies"].alpha>0){ level.sabBomb.objPoints["allies"].alpha-=0.05; }
			if(level.bombZones["allies"].objPoints["axis"].alpha>0) { level.bombZones["allies"].objPoints["axis"].alpha-=0.05; }
			if(level.bombZones["axis"].objPoints["axis"].alpha>0) { level.bombZones["axis"].objPoints["axis"].alpha-=0.05; }
		} */
		
		wait 0.05;
	}
}

_bomb_objective_blink(){
	//level endon( "disconnect" );
	//level endon( "game_ended" );
	//level endon( "intermission" );
	if(getDvar("g_gametype") != "sab"){ return; }
	
	a=1; s="active";
	cl("33_bomb_objective_blink started");
	while(level.bombPlanted != true){ wait 0.5; }
	cl("33Bomb planted!");
	while(level.tp>5){
		if(isDefined(level.bombPlantedBy)){
			players = getentarray( "player", "classname" );
			for(i=0;i<players.size;i++){ 
				if(!players[i].isbot && players[i].pers["team"]=="axis"){
					objective_state(players[i].objIDAxis, s);
					objective_state(players[i].objIDAllies, s);
					//cl("players[i].objIDAxis:"+players[i].objIDAllies);
				}
			}
			if(level.bombPlantedBy == "axis"){
				//cl("11axis bomb blinking!");
			} else if(level.bombPlantedBy == "allies"){
				//cl("44allies bomb blinking!");
			}
			wait 0.5;
			if(a==1){ a=0; } else { a=1; }
			if(s=="active"){ s="invisible"; } else { s="active"; }
			//cl("11a:"+a);
		}
	}
	cl("33_bomb_objective_blink ended");
}

_randomize_bomb_pos(){
	level endon( "disconnect" );
	level endon( "game_ended" );
	if (getdvarint("developer") == 0){ return; }
	if (getdvarint("bots_main_debug") != 0) { return; }
	if(getDvar("g_gametype") != "sab"){ return; }

	if(game["roundsplayed"]>0){
		pos=_bomb_file(getDvar("mapname"));
		if(pos.size>0){
			s=pos[randomIntRange(0,pos.size)];
			s = StrRepl(s, "(", "");
			s = StrRepl(s, ")", "");
			s = StrRepl(s, ",", " ");
			r = strTok(s," ");
			
			level.sabBomb.trigger.origin = (float(r[0]),float(r[1]),float(r[2]));
			level.sabBomb.curOrigin = (float(r[0]),float(r[1]),float(r[2]));
			level.sabBomb.visuals[0].origin= (float(r[0]),float(r[1]),float(r[2]));
		}
	}
}

/* \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

----------------------server round management----------------------------

\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/ */

_last_allie_taunting(){
	level endon( "disconnect" );
	for(;;){
		if(level.playerLives["allies"]==1){
			players = getentarray( "player", "classname" );
			for(i=0;i<players.size;i++){
				if (isAlive(players[i]) && players[i].isbot && players[i].pers["team"]=="allies"){
					players[i] playSound("stop_voice");
					v1=randomIntRange(1,4);
					v2=randomIntRange(1,10);
					players[i] playSound("ct_taunt"+v1+"_"+v2);
					wait randomIntRange(5, 10);
				}
			}
		}
		wait 0.5;
	}
}

_player_collision(timer){
	while (isDefined(level.inPrematchPeriod) && level.inPrematchPeriod==true){ wait 1; }
	setDvar("g_friendlyplayercanblock",0);
	wait timer;
	setDvar("g_friendlyplayercanblock",1);
}

_teamWatcher(){
	level endon("disconnect");
	level endon("game_ended");

	while(level._teamEliminated != true){ wait 0.5; }
	if(level.playerLives["axis"]<1){ [[level._setTeamScore]]( "allies", [[level._getTeamScore]]( "allies" ) + 1 ); } 
	else if(level.playerLives["allies"]<1){	[[level._setTeamScore]]( "axis", [[level._getTeamScore]]( "axis" ) + 1 ); }
}

_tiebreaker(){
	level endon("disconnect");
	level endon("game_ended");
	while (!level.inOvertime) { wait 1; }
	players = getentarray( "player", "classname" );
	for(i=0;i<players.size;i++){ players[i].pers["lives"]=0; }
	while (level.inOvertime && !level.stopScore){ 
		while(level.bombPlanted == true){ wait 1; }
		
		if(level.playerLives["axis"]<1){
			[[level._setTeamScore]]( "allies", [[level._getTeamScore]]( "allies" ) + 1 );
			thread maps\mp\gametypes\_finalkillcam::endGame( "allies", game["strings"]["axis_eliminated"] );
			break;
		} else if(level.playerLives["allies"]<1){
			[[level._setTeamScore]]( "axis", [[level._getTeamScore]]( "axis" ) + 1 );
			thread maps\mp\gametypes\_finalkillcam::endGame( "axis", game["strings"]["allies_eliminated"] );
			break;
		}
		wait 1;
	}
}

_fast_restart_on_join(){
	level endon("disconnect");
	
	wait 1;
	
	for(;;){
		while(isDefined(game["realPlayers"]) && game["realPlayers"]>0){ wait 1; level _chk_players("real"); /* cl("players"); */ }
		if(isDefined(game["realPlayers"]) && game["realPlayers"]<1){ cl("no real players on current map, standing by..."); }
		while(isDefined(game["realPlayers"]) && game["realPlayers"]<1){ wait 1; level _chk_players("real"); /* cl("!players"); */  }
		if(isDefined(game["realPlayers"]) && game["realPlayers"]>0){
			cl("zeroing team scores"); 
			game["teamScores"]["axis"]=0;
			game["teamScores"]["allies"]=0;
		}
		wait 5;
	}
}

_dvar_players(){
	level endon("disconnect");
	
	for(;;){
		pl = getDvar( "pl" );
		if(pl != ""){
			cl("-------------------"); 
			players = getentarray( "player", "classname" );  c=0; names="";
			for(i=0;i<players.size;i++){
				color="77";
				if(players[i].pers["team"]=="axis"){ color="11"; }
				if(players[i].pers["team"]=="allies"){ color="55"; }
				input=color+"player: "+players[i].name;
				if(!players[i].isbot && pl == "r"){
					cl(input); c++;
				}
				else if(players[i].isbot && pl == "b"){
					cl(input); c++;
				}
				else if(pl == "a"){
					cl(input); c++;
				}
			}
			cl("-------------------"); 
			if(pl == "r"){ cl("real players: "+ c); }
			if(pl == "b"){ cl("bot players: "+ c); }
			if(pl == "a"){ cl("all players: "+ c); }
			setDvar("pl","");
		}
		wait 0.1;
	}
}

_dvar_sab(){
	level endon("disconnect");
	
	dvars=strTok("sl tl nl"," ");
	
	for(;;){
		for(i=0;i<dvars.size;i++){
			dvar = dvars[i];
			val = getDvarInt(dvar);
			if(val > 0){
				if(dvar == "sl"){ cl("setting sab score limit to "+val); setDvar("scr_sab_scorelimit", val); }
				else if(dvar == "tl"){ cl("setting sab round time to "+val); setDvar("scr_sab_timelimit", val); }
				else if(dvar == "nl"){ cl("setting sab player lives to "+val); setDvar("scr_sab_numlives", val); }
				setDvar(dvar,0);
			}
		}
		wait 0.5;
	}
}

_dvar_map_restart(){
	level endon("disconnect");
	
	for(;;){
		dvar = getDvar("m");
		m=getDvar("mapname");
		if(dvar != ""){
			if(dvar == "r"){ cl("restarting map "+m); exec("map " + m+" 1"); }
			if(dvar == "rr"){ 
				cl("33checking nextMap before map forced rotate...");
				level thread _next_map_index();
				game["nextMap"] = level.mapList[game["nextMapIndex"]];
				if(getDvar("g_gametype")!="sab"){ setDvar("g_gametype","sab"); }
				if(isDefined(level._gametypes)){
					for(i=0;i<level._gametypes.size;i+=2){ 
						if(level._gametypes[i]==game["nextMap"]){ 
							setDvar("g_gametype",level._gametypes[i+1]);
							cl("33g_gametype will be \""+level._gametypes[i+1]+"\"");
							break;
						} else {
							setDvar("g_gametype","sab");
						}
					}
				}
				cl("33rotating map to \""+game["nextMap"]+"\"");
				wait 1;
				exec("map " + game["nextMap"]+" 1"); 
			}
			else if(dvar == "f"){ 
				cl("fast restarting map"); 
				cl("11sorry, this command doesn't work anymore!"); 
				cl("22in terminal use 'm r' command"); 
				//Map_Restart(false); //doesn't work anymore, cannot find a bug
			}
			else if(dvar == "i"){ 
				cl("current map: "+getDvar("mapname")); 
				thread _get_team_score(); 
			}
			setDvar("m","");
		}
		wait 0.1;
	}
}

_dvar_add_bots(){
	level endon("disconnect");
	
	cl("33_dvar_add_bots");
	
	for(;;){
		dvar = getDvar("ab"); team=undefined;
		if(dvar != ""){
			if(dvar == "ax"){ level maps\mp\bots\_bot::add_bot("axis"); team="axis"; }
			else if(dvar == "al"){ level maps\mp\bots\_bot::add_bot("allies"); team="allies"; }
			else if(int(dvar) > 0){ thread _add_some_bots(int(dvar)); team=undefined; }
			else if(dvar == "r"){
				axis=0;
				allies=0;
				players = getentarray("player", "classname"); 
				for(i=0;i<players.size;i++){
					if(players[i].pers["team"]=="axis"){ axis+=1; }
					if(players[i].pers["team"]=="allies"){ allies+=1; }
				}
				if(axis<allies){ team = "axis"; }
				else{ team = "allies"; }
				level maps\mp\bots\_bot::add_bot(team);
			}
			if(isDefined(team)) { cl("22adding bot to "+team+" team"); }
			setDvar("ab","");
			wait 1;
		}
		wait 0.05;
	}
}

_dvar_remove_bots(){
	level endon("disconnect");
	
	cl("33_dvar_remove_bots");
	
	for(;;){
		dvar = getDvar("kb");
		botname="";
		kicked=undefined;
		axis=0;
		allies=0;
		if(dvar!="" && !isDefined(kicked)){
			players = getentarray("player", "classname"); 
			for(i=0;i<players.size;i++){
				if(players[i].pers["team"]=="axis"){ axis+=1; }
				if(players[i].pers["team"]=="allies"){ allies+=1; }
				
				if(dvar=="ax" && players[i].pers["team"]=="axis" && players[i].isbot && !isDefined(kicked)){
					botname=StrRepl(players[i].name, "/", "");
					exec("kick " + botname);
					cl("11kicking bot "+botname+" from axis team");
					kicked=true;
					break;
				}	
				else if(dvar=="al" && players[i].pers["team"]=="allies" && players[i].isbot && !isDefined(kicked)){
					botname=StrRepl(players[i].name, "/", "");
					exec("kick " + botname);
					cl("11kicking bot "+botname+" from allies team");
					kicked=true;
					break;
				}
				else if(dvar == "r"  && players[i].isbot && !isDefined(kicked)){ 
					if(axis<allies){ team = "axis"; }
					else{ team = "allies"; }
					if(players[i].pers["team"]==team){ botname=StrRepl(players[i].name, "/", ""); }
					exec("kick " + botname);
					kicked=true;
					break;
				}	
			}
			setDvar("kb","");
			wait 0.1;
		}
		wait 0.05;
	}
}

_dvar_transfer_bots(){
	level endon("disconnect");
	
	cl("_dvar_transfer_bots");
	
	for(;;){
		dvar = getDvar("tr");
		botname="";
		transfered=undefined;
		if(dvar!="" && !isDefined(transfered)){
			players = getentarray("player", "classname"); 
			for(i=0;i<players.size;i++){
				if(dvar=="ax" && players[i].pers["team"]=="axis" && players[i].isbot && !isDefined(transfered)){
					botname=players[i].name;
					players[i].pers["team"] = "allies";
					players[i].sessionteam = "allies";
					cl("transferring bot "+botname+" to allies team");
					transfered=true;
				}	
				else if(dvar=="al" && players[i].pers["team"]=="allies" && players[i].isbot && !isDefined(transfered)){
					botname=players[i].name;
					players[i].pers["team"] = "axis";
					players[i].sessionteam = "axis";
					cl("transferring bot "+botname+" to axis team");
					transfered=true;
				}	
			setDvar("tr","");
			wait 0.1;
			}
		}
		wait 0.05;
	}
}

_bomb_exploded(){
	level endon("disconnect");
	level endon("game_ended");
	
	if(getDvar("g_gametype") != "sab"){ return; }
	
	while(!level.bombExploded){ wait 0.5; }
	if(isDefined(game["money"][level.bombowner.name])){ game["money"][level.bombowner.name] += 5000; }
}

_slowMo(){
	level endon("disconnect");
	
	wait 20;
	while (game["state"] == "postgame" || level.gameEnded) { wait 0.1; }
	while (level.players.size<1){ wait 1; }
	while (level.playerLives["allies"]>0 && level.playerLives["axis"]>0){ wait 0.2; }
	level.slowMo=true;

	level thread _get_team_score();
	level thread _ts();
}

_ts(){
	level endon("disconnect");
	
	ts=1;
	players = getentarray( "player", "classname" );
	
	for(i=0;i<players.size;i++){
		if(!players[i].isbot){
			players[i] playLocalSound("slowmo");
			players[i] thread _vfx(0.3,0.5);
        }
    }
	while(ts>0.5){ SetDvar("timescale", ts); ts-=0.05; wait 0.05; }	
	wait randomFloatRange(0,0.5);
	while(ts<1){ SetDvar("timescale", ts); ts+=0.02; wait 0.05; }	
	SetDvar("timescale", 1);
}

_vfx(t1,t2){
	self endon("disconnect");
	
	sat=0.4; blur=0; t1*=0.2; t2*=0.2;
	self setClientDvar("r_filmUseTweaks", 1);
	while(blur<2){ 
		self setClientDvar("r_blur", blur);
		self setClientDvar("r_filmTweakDesaturation", sat);
		sat-=0.025; blur+=0.2; wait t1; 
	}	
	wait randomFloatRange(0,0.5);
	while(blur>0){ 
		self setClientDvar("r_blur", blur);
		self setClientDvar("r_filmTweakDesaturation", sat); 
		sat+=0.025; blur-=0.2; wait t2; 
	}	
	self setClientDvar("r_filmUseTweaks", 0);
}

/* \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

---------------------------player start----------------------------------

\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/ */

_welcome(tm,ctm)
{
    self endon("disconnect");
	
	self closeMenu();
	self closeInGameMenu();
	
	self waittill("spawned_player");
	
	self.pers["lives"] = getdvarint("scr_sab_numlives")-1;
	self.pers["deaths"] = 0;
	self.deaths = 0;
	self.pers["kills"] = 0;
	self.kills = 0;
	self.pers["assists"] = 0;
	self.assists = 0;
	self notify( "bots_kill_menu" );
	self.ps_ended = true;
	
	angles = self getPlayerAngles();
	self setPlayerAngles((angles[0], 0, angles[2])); 

	if (self.isbot) { 
		wait 0.05;
	} else {	
		self playLocalSound( "hello1" );
		wait 0.1;
		self scripts\main::_film_tweaks(0,0,"1 1 1","1 1 1",0.4,1,1,0,1.4);
	}
			
	switch ( self.pers["team"] ) {
		case "allies":
			self.ps = "ct_damage";
			self.ds = "ct_death";
			self.bc = "ct_bc";
			game["_ct_m_"]++;
			break;
		case "axis":
			self.ps = "t_m" + game["_t_m_"] + "_damage";
			self.ds = "t_m" + game["_t_m_"] + "_death";
			self.bc = "t_m" + game["_t_m_"] + "_bc";
			game["_t_m_"]++;
			break;
		default:
			break;
	}
	
	self thread _ds();
	self thread _ps();
	
	if (game["_t_m_"] > 13) { game["_t_m_"]=1; }
	if (game["_ct_m_"] > 5) { game["_ct_m_"]=1; }

    
    wait 1;
    if (self.pers["lives"] > 0 && self.pers["team"] != "spectator" ) { self iprintln("^2You have " + (self.pers["lives"]+1) + " lives\n"); }
}

_info(){
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );

	self setClientDvars("pl", "");
	
	if(isDefined(level.nextMap)){ 
		wait 5; self iprintln("^3Next map will be "+game["nextMap"]);
	}
	if(game["waypointless_map"]=="on"){ 
		wait 5; self iprintln("^3This map is waypointless, soon waypoints will be added");
		wait 5; self iprintln("^3Bots can navigate without waypoints");
	}
	wait 5; self iprintln("^3You can regroup teammate by aiming and holding USE key");
	wait 5; self iprintln("^3You can send commanded teammate by aiming and holding USE key");
	wait 5; self iprintln("^3Your kill, death & assist points will reset every round");
	wait 5; self iprintln("^3Reloading partial clips will drop remaining clip bullets");
	wait 5; self iprintln("^3You can push anybody with USE key");
	wait 5; self iprintln("^3You can access hardpoints with B button");

}

_fs(){
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	if (self.isbot) { return; }
	
	else {
		self waittill("hasReadWelcomeMsg");
		if (isDefined(game["hasReadMOTD"][self.name])){
			if (game["hasReadMOTD"][self.name]==false){					
				self waittill("hasReadMOTD");
				if(self.hasSpawned!=true){ self notify("player_spawned"); }
				game["isJoinedSpectators"][self.name]=false;
				self [[level.autoassign]]();
				if(level.tp>level.gracePeriod){ self.pers["lives"]=1; }
			}
		}

		if(isDefined(level._sleepers)){
			level._foundSleepers = StrTok(_sleepers(),",");
			for (i=0;i<level._foundSleepers.size;i++){
				if (self.name == level._foundSleepers[i]){
					print ("--found sleeper: " + level._foundSleepers[i] + "--\n");
				}
			}
		}

		cl("22level.tp "+level.tp);
		
		if (game["isJoinedSpectators"][self.name]==false){
			self [[level.class]]("custom1");
			if(level.tp<level.gracePeriod){ 
				self.pers["lives"]=getDvarInt("scr_sab_numlives")-1;
				self.isInTeam=self.pers["team"];
			} else if(level.tp>level.gracePeriod+(level.gracePeriod/2) && self.hasSpawned!=true){ 
				//self [[level.spawnPlayer]]();
				self.pers["lives"]=1;
				cl("44forcespawned "+self.name);
			}
		} else {
			self.sessionstate = "spectator";
			self thread maps\mp\gametypes\_spectating::setSpectatePermissions();
		}
		
		self freezeControls(true);
		while (level.inPrematchPeriod){	wait 0.1; };
		self freezeControls(false);
	}
}

_player_connecting(){
	if (!self.isbot) { 
		if(!isDefined(game["isConnecting"])){ return; }
		name = self.name;
		if(!isDefined(game["isJoinedSpectators"][self.name])){ game["isJoinedSpectators"][self.name]=true; }
		if(!isDefined(game["isConnecting"][name])){ game["isConnecting"][name]=false; }
		if(game["isConnecting"][name]!=true){ cl("^3"+name+" connecting"); }
		game["realPlayers"]++;
		game["isConnecting"][name]=true; 
		
		self setClientDvar("ui_ShowMenuOnly", "");
		
		self waittill("disconnect");
		if(!isDefined(game["isConnecting"])){ return; }
		cl("^1"+name+" disconnected");
		game["isConnecting"][name]=false; 
	}
}

_player_connecting_loop(){
	level endon ( "disconnect" );
	level endon( "intermission" );
	level endon( "game_ended" );	
	
	for(;;){
		level waittill( "connecting", player );
		player thread _player_connecting();
		wait 0.05;
	}
}

_player_spawn_loop(){
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	self.bombPing=undefined;
	self setClientDvar( "v01d_tools_bp", 1 );
	self.firingXP=0;
	self.isBlurrying=undefined;
		
	for(;;){
		self waittill("spawned_player");	

		self thread _useSoldier();
		self thread _changeBotWeapon();
		self thread _hudMarkers_show();
        self thread _reload_monitor();
        self thread _recoil();
        self thread _aim_mod();
        self thread _moving();
		self thread _m16_pickup();
		self thread _mobile_phone();
		self thread _push();
		self thread _stopADS();
		self thread _player_cg_cmds();
		self thread _disable_weapons_on_use();
		self thread _disable_weapons_on_jump();
		self thread _movement_accel_decel();
		self thread _give_knife(10);
		self thread _knife_hit();
		self thread _explosives_pickup();
		self thread _bot_explosives_pickup();
		self thread _weapon_cock_sound();
		self thread _player_mouse();
		self thread _hp_weapons_list();
		self thread _player_fired_weapon();
		self thread _bot_restart_movement();
		self thread _player_is_proning();
		self thread _player_stop_moving();
		
		//self thread _dev_coords();
		//self thread _dev_weapon_test();
		//self thread _dev_hp_test();
		//self thread _dev_wpt_helpers_add_remove();
		//self thread _dev_timescale();		
		//self thread _dev_tag_angles();
		//self thread _dev_test_dp();
		//self thread _dev_ent_test();
		//self thread _dev_test_clcmds();
		//self thread _dev_test_fx();
		
		self takeWeapon("briefcase_bomb_mp");
		self takeWeapon("briefcase_bomb_defuse_mp");
		self thread scripts\main::_flash("bright",1,0,0.1,1);
	}
}

_player_spectate(delay,team){
	if(self.isbot){ return; }
	if(!isDefined(delay) || delay < 0.05){ delay=10; }
	wait delay;
	//self thread maps\mp\gametypes\_spectating::setSpectatePermissions();
	if(isDefined(team)){ self AllowSpectateTeam("axis",true); }
	else {
		self AllowSpectateTeam("axis",true);
		self AllowSpectateTeam("allies",true);
	}
}

_player_cg_cmds(){
	if(self.isbot){ return; }
	self setClientDvar("cg_blood", 0); 
	self setClientDvar("cg_friendlyNameFadeIn", 100000);
	self setClientDvar("cg_enemyNameFadeIn", 100000);
	self setClientDvar("cg_centertime", 0);
	self setClientDvar("r_blur", 0);
	self setClientDvar("r_filmUseTweaks", 0);
	self setClientDvar("r_filmTweakEnable", 1);
	self setClientDvar("r_filmTweakBrightness", 0);
	self setClientDvar("r_filmTweakContrast", 1.4);
	self setClientDvar("r_filmTweakDarkTint", "1 1 1");
	self setClientDvar("r_filmTweakLightTint", "1 1 1");
	self setClientDvar("r_filmTweakDesaturation", 0.4);
	self setClientDvar("r_glowTweakEnable", 1);
	self setClientDvar("r_glowUseTweaks", 1);
	self setClientDvar("r_glowTweakBloomDesaturation", 1);
	self setClientDvar("m_pitch",0.022);
	self setClientDvar("m_yaw",0.022);
	self setClientDvar("stopSpeed",100);
	self setClientDvar("ui_showmap",1);
	//self setClientDvar("perk_weapReloadMultiplier", 0.1);
}

_film_tweaks(enable,blur,dtint,ltint,desat,glow,glowdesat,bright,contrast){
	self setClientDvar("r_blur", blur);
	self setClientDvar("r_filmTweakBrightness", bright);
	self setClientDvar("r_filmTweakContrast", contrast);
	self setClientDvar("r_filmUseTweaks", enable);
	self setClientDvar("r_filmTweakEnable", enable);
	self setClientDvar("r_filmTweakDarkTint", dtint);
	self setClientDvar("r_filmTweakLightTint", ltint);
	self setClientDvar("r_filmTweakDesaturation", desat);
	self setClientDvar("r_glowTweakEnable", glow);
	self setClientDvar("r_glowUseTweaks", enable);
	self setClientDvar("r_glowTweakBloomDesaturation", glowdesat);
}

/*_player_3rd_person(){
	setClientDvars("cg_thirdperson", 1); self.thirdPerson=false;
}*/

/* \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

-----------------------------player left---------------------------------

\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/ */

_disconnected(){
	if (self.isbot) { return; }
	disconnected = self.name;
	self waittill("disconnect");
	thread _player_info(3,disconnected);
}

/* \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

---------------------------player physics--------------------------------

\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/ */

_movement_accel_decel(){
	self endon ( "disconnect" );
	self endon ( "death" );
	self endon( "intermission" );
	self endon( "game_ended" );

	if (self.isbot) { return; }

	c=0.3;
	
	for(;;){
		while(isAlive(self)){
			while((isDefined(self.isFiring) || isDefined(self.isReloading)) && isDefined(self.isProning)){ wait 0.05; }
			mss=0.1;
			self setMoveSpeedScale(mss);
			while (self ForwardButtonPressed() || self BackButtonPressed() || self MoveLeftButtonPressed() || self MoveRightButtonPressed()){ self setMoveSpeedScale(mss); wait 0.05; if(mss<1){ mss+=0.10; }}
			wait 0.05;
		}
		wait 0.05;
	}
}

_moveSpeed(){
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	if (self.isbot) { return; }

	while(self.health<self.maxhealth){
		while((isDefined(self.isFiring) || isDefined(self.isReloading)) && isDefined(self.isProning)){ wait 0.05; }
		mss=self.health/self.maxhealth;
		self setMoveSpeedScale(mss);
		wait 0.05;
	}
}

_disable_weapons_on_use(){
	self endon ( "disconnect" );
	self endon ( "death" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	if(self.isbot){ return; }
	if(getDvar("g_gametype") != "sab"){ return; }
	
	axisBombSite=getEnt("sab_bomb_axis", "targetname");
	alliesBombSite=getEnt("sab_bomb_allies", "targetname");
	
	for(;;){
		while (!self UseButtonPressed()){ wait 0.05; }
		if(distance(axisBombSite.origin,self.origin)<64 || distance(alliesBombSite.origin,self.origin)<64){ wait 0.05; }
		else{ self _disable_weapons(0.05); }
		while (self UseButtonPressed()){ wait 0.05; }
	}
}

_disable_weapons_on_jump(){
	self endon ( "disconnect" );
	self endon ( "death" );
	self endon( "intermission" );
	self endon( "game_ended" );

	if(self.isbot){ return; }
	
	for(;;){
		while (!self JumpButtonPressed()){ wait 0.05; }
		self _disable_weapons(0.2);
		while (self JumpButtonPressed()){ wait 0.05; }
	}
}

_player_mouse(){
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	ma=0.022;
	
	for(;;){
		while(level.slowMo==false){ wait 0.05; }
		ts=float(getDvar("timescale"));
		if(isDefined(ts) && !self.isbot && self.sessionstate == "playing"){
			self setClientDvars("m_pitch",ma*ts,"m_yaw",ma*ts);
		}
    	wait 0.05;
    }

}


_player_mouse_accel(t1,t2){
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	ma=0.022; t1*=0.2; t2*=0.2;
	
	while(ma>0.001){
		if(!self.isbot && self.sessionstate == "playing"){
			self setClientDvars("m_pitch",ma,"m_yaw",ma);
		}

    	ma-=0.002; wait 0.05;
    }
    while(ma<0.022){
		if(!self.isbot && self.sessionstate == "playing"){
			self setClientDvars("m_pitch",ma,"m_yaw",ma);
		}
    	ma+=0.002; wait 0.05;
    }
}

_reload_monitor()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	if(self.isbot){ return; }
	
	level.weapons_clip_strict = StrTok("none,artillery,binoculars,cell", "," );
	level.weapons_partial_reload = StrTok("m1014,m40a3,remington700,winchester1200,striker", "," );
	self.isReloading=undefined;
	
	for(;;){
		self waittill( "reload_start" );
		self.isReloading=true;

		weapon = self GetCurrentWeapon();
		if(weapon == "none"){ return; }
		clipsize = WeaponClipSize( weapon );
		ammoclip = self GetWeaponAmmoClip( weapon );
		ammocount = self getAmmoCount(weapon);	
		c=0; k=1;
		
		for (i=0;i<level.weapons_clip_strict.size;i++){
			if (isSubStr( weapon, level.weapons_clip_strict[i])){ 
				self.restrict = weapon;	return;
 			}
		}
		
		if (isDefined(self.restrict)){
			self.restrict = undefined; continue;
		} else {
			for (i=0;i<level.weapons_partial_reload.size;i++){
				if (isSubStr( weapon, level.weapons_partial_reload[i])){ 
					self.partial = weapon; break;
 				}
			}
			if(isDefined(self.partial)) { self.partial = undefined; } else { self SetWeaponAmmoClip( weapon, 0 ); }
			while(c<10 && !self sprintButtonPressed() && !isDefined(self.isProning)) { k-=0.05; self setMoveSpeedScale(k); c++; wait 0.05; }
			while(self GetCurrentWeapon() == weapon && (self GetWeaponAmmoClip(weapon) == ammoclip || self GetWeaponAmmoClip(weapon) == 0)) { 
				if(isDefined(self.isProning) && isDefined(self.isReloading)){ self setMoveSpeedScale(0); } 
				else { self setMoveSpeedScale(k); }
				wait 0.05; 
			}
			wait randomFloat(0.5);
			while(c>0) { k+=0.05; self setMoveSpeedScale(k); c--; wait 0.05; }
		}
		self setMoveSpeedScale(1);
		self.isReloading=undefined;
	}
}

_player_is_proning(){
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	self endon ( "death" );

	while(isAlive(self)){
		if(self getStance() == "prone"){ self.isProning=true; }
		else{ self.isProning=undefined; }
		wait 0.05;
	}
	self.isProning=undefined;
}

_player_stop_moving(){
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	self endon ( "death" );

	while(isAlive(self) && isDefined(self.isReloading)){
		if(isDefined(self.isReloading) && isDefined(self.isProning)){
			self setMoveSpeedScale(0);
		}
		wait 0.05;
	}
	self.isProning=undefined;
}

_aim_mod(){
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
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

_push(){
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	for(;;){
		if(isAlive(self) && level.tp>level.gracePeriod){
			if(self useButtonPressed()) { 
				angles = self GetPlayerAngles();
				startPos = self getEye();
				startPosForward = startPos + anglesToForward( ( angles[0], angles[1], 0 ) ) * 64;
				trace = bulletTrace( startPos, startPosForward, true, self );
				ent = trace["entity"];
				
				if(isDefined(ent) && ent.classname == "player"){
					dist=distance(self.origin,ent.origin);
					x = ent.origin[0]-self.origin[0];
					y = ent.origin[1]-self.origin[1];
					z = ent.origin[2]-self.origin[2];
					ent setVelocity((x*(64/(dist+1)),y*(64/(dist+1)),100));
					ent thread _disable_weapons(0.1);
				}
				wait 0.05;
			}
		}
		wait 0.05;
	}
}

_player_fired_weapon(){
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	for(;;){
		self waittill("weapon_fired");
		self.isFiring=true;
		self thread _delay_after_firing();
		weapon = self GetCurrentWeapon();
		self.hasMadeFiringSound=true;
	}
}

_recoil(){
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	self.hasFiredInterval = gettime();
	self.hasFiredIntervalPrev = gettime();
	ms=0.022;
	
	for(;;){
		if(isAlive(self)){
			weapon = self GetCurrentWeapon();
			ammocount_old = self getAmmoCount(weapon);
			ammocount = ammocount_old;

			curView = self getPlayerAngles();
			wclass = self _classCheck(weapon);
			k=1;
			if(self.isbot && getDvarFloat("v01d_bots_recoil_spicyness")>0){ 
				k*=getDvarFloat("v01d_bots_recoil_spicyness"); 
			}
			if(isDefined(wclass)) { 
				if(wclass=="sniper") { k=3; }
				else if(wclass=="rpg") { k=1.3; }
				else if(wclass=="gl") { k=0.7; }
				else if(wclass=="rifle") { k=1.9; }
				else if(wclass=="mg") { k=0.6; }
				else if(wclass=="smg") { k=1.5; }
				else if(wclass=="pistol") { k=2.7; }
				else if(wclass=="bolt") { k=1.7; }
				else { k=1; }
			}
			
			ammosize = self GetWeaponAmmoClip(weapon);
			wait 0.05; 
			ammocount = self getAmmoCount(weapon);

			if(ammocount == ammocount_old) { continue; }
			else if (isDefined(wclass) && (wclass == "pistol" || wclass == "bolt")){
				ammocount_old = ammocount;
				self.hasFiredInterval = 1000/((gettime() - self.hasFiredIntervalPrev)+0.1);
				self.hasFiredIntervalPrev = gettime();
				k+=self.hasFiredInterval-self.firingXP;
				self.firingXP+=0.01;
			}
			else { 
				ammocount_old = ammocount;
				self.hasFiredInterval = 1000/((gettime() - self.hasFiredIntervalPrev)+0.1);
				self.hasFiredIntervalPrev = gettime();
				k+=self.hasFiredInterval;
			}
			
			if(self getstance() == "crouch"){ k*=0.4; }
			else if(self getstance() == "prone"){ k*=0.2; }
			
			curView = self getPlayerAngles();
			self setPlayerAngles((curView[0]-randomFloatRange(0.6, 0.9)*k, curView[1]-randomFloatRange(-0.5, 0.8)*k, curView[2])); 
		}
		wait 0.05;
	}
}

_delay_after_firing(delay,log){
	self endon ( "weapon_fired" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	if(!isDefined(delay)){ delay = 1; }

	for(;;){
		if(isAlive(self)){
			c=20*delay;
			if(isDefined(self.isFiring)){ 
				while(isAlive(self) && !isDefined(self.isFiring) && c>0){
					c--;
					wait 0.05;
				}
				self.isFiring = undefined;
				if(isDefined(log)){ cl(self.name+" has fired weapon"); }
			}
		}
		wait 0.05;
	}
}

_firing(k){
	if(self.isbot){ return; }
	if(!isDefined(k)){ k=1; }
	ms=0.000;

	while(ms<0.022){
		self setClientDvar("m_pitch",ms);
		self setClientDvar("m_yaw",ms);
		ms+=0.001;
		wait 0.05*k;
	}
}

_stopADS(){
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
		
	for(;;){
		if(isAlive(self)){
			self waittill("weapon_fired");
			weapon = self GetCurrentWeapon();
			hasBoltSniper = self _classCheck(weapon,level.classBoltSniper);
			if(isDefined(hasBoltSniper) && hasBoltSniper){ 
 
				self allowADS(0); wait 0.5; self allowADS(1);
			}
			self botAction("-ads");
		}
		wait 0.05;
	}
}

_moving(){
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	//if(self.isbot){ return; }
	
	self.aimWobling = 0.5;
	
	for(;;){
		if(isAlive(self)){
			self.prevOrigin = self.origin; 
			wait 0.1;
			self.velocity = distance( self.origin, self.prevOrigin ); 

			if(self.velocity > 25) {
				curView = self getPlayerAngles();
				self setPlayerAngles((curView[0]+randomFloatRange(-0.5, 0.5), curView[1]+randomFloatRange(-0.5, 0.5), curView[2]+randomFloatRange(-3.5, 3.5))); 
				wait 0.05;
				curView = self getPlayerAngles();
				if(self.aimWobling<2){ self.aimWobling+=0.05; }
				self setPlayerAngles((curView[0], curView[1], 0));
			} 
			else if(self.velocity < 25 && self.velocity > 0.1) {
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

_sliding(){
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	for(;;){
		self waittill("damage",amount,attacker);
		
		wait 0.05;
	}
}

/* \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

---------------------------player damage---------------------------------

\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/ */

_damaged(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset){
	k=1; seconds=10;
 
	if (isPlayer(self) && isAlive(self) && isDefined(iDamage) && iDamage>0){
		self thread _bot_prone_when_danger(300);
		self endLocationSelection();
		if(iDamage>self.health*0.7){ self maps\mp\gametypes\_weapons::dropWeaponForDeath( eAttacker,true ); }
		if (isDefined(eAttacker) && isPlayer(eAttacker)){ 
			if(isDefined(eAttacker.isbot) && eAttacker.isbot){ eAttacker.pers["bots"]["skill"]["aim_time"]=3; }
			weapon=eAttacker GetCurrentWeapon();
			dist=distance(self.origin, eAttacker.origin);
			if(sMeansOfDeath=="MOD_MELEE"){
				if(dist<100){ iDamage=100/(dist/15); }
				else{ iDamage=1; }
			}
		}
		if(iDamage<self.maxhealth){ k=iDamage*0.05; } else { k=1; }
		curView = self getPlayerAngles();
		self setPlayerAngles(curView * (randomFloatRange(0.1, 1.9) * k)); 
		self shellshock("frag_grenade_mp", seconds * k);
		if(randomFloatRange(0, 2)>1){
			self thread _disable_weapons(0.1);
		}

		x=undefined;
		y=undefined;	
		if(isDefined(eAttacker)){
			x = self.origin[0]-eAttacker.origin[0];
			y = self.origin[1]-eAttacker.origin[1];
		}
		z = 100;
		
		if(isDefined(x) && isDefined(y)){
			if (isDefined(self.velocity) && isDefined(self.prevOrigin)){ 
				if (sMeansOfDeath == "MOD_PROJECTILE_SPLASH" || sMeansOfDeath == "MOD_GRENADE_SPLASH" || sMeansOfDeath == "MOD_EXPLOSIVE"){
					self setVelocity((x,y,z));
				}
				else if (sMeansOfDeath == "MOD_PROJECTILE"){
					self setVelocity((x/2,y/2,z/4));
					iDamage=1;
				}
				else if (isSubStr(sMeansOfDeath,"_BULLET")){
					self setVelocity((x/2,y/2,z/2));
				}
				else { self setVelocity((x,y,z)); }
			} else {
				self setVelocity((x/2,y/2,z/2));
			}
		}
		
		if (sMeansOfDeath == "MOD_FALLING"){
			iDamage*=0.5;
		}
		
		if (self GetStance() == "prone"){
			iDamage=int(iDamage/3);
		}

		self thread _suicide_pd(5);
		
		if(self.isbot){ self botAction("-ads"); }
		else { self allowADS(0); self allowADS(1); }
		
		lives=level.playerLives["allies"];
		k=lives*0.5;
		iDamage=int(iDamage*k);
	}
	
	if(isDefined(level.originalcallbackPlayerDamage)){ self [[level.originalcallbackPlayerDamage]](eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset); }
}

_killed(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration){
	
	//cl(self.name + ":" + sMeansOfDeath);
	
	self setClientDvar("m_pitch",0.022);
	self setClientDvar("m_yaw",0.022);
	self SetClientDvar("ui_ShowMenuOnly", "");
	
	self setMoveSpeedScale(1);
	
	self endLocationSelection();
	self.selectingLocation = undefined;
	
	self.haveC4=0;
	self.haveClaymores=0;
	self.haveFragGrenades=0;
	self.haveConcussionGrenades=0;
	self.haveFlashGrenades=0;
	self.haveSmokeGrenades=0;
	
	self thread _unlink_veh();
	
	self thread _flash("bright",1,0,0,1);
	
	self thread _bot_prone_when_danger();
	
	//cl("^2"+eAttacker.name+" killed ^3"+self.name+" with MOD: ^1"+sMeansOfDeath);
	
	if(isDefined(eInflictor)){	
		dist = distance(self.origin,eInflictor.origin)+1;
		x = self.origin[0]-eInflictor.origin[0];
		y = self.origin[1]-eInflictor.origin[1];
		z = 100;
		
		
		if (sMeansOfDeath == "MOD_PROJECTILE" || sMeansOfDeath == "MOD_GRENADE" || sMeansOfDeath == "MOD_IMPACT"){
			self setVelocity((x/4,y/4,z/4));
		}
		else if (isSubStr(sMeansOfDeath,"_BULLET")){
			self setVelocity((x/4,y/4,z/4));
		}
		else if (isSubStr(sMeansOfDeath,"_TRIGGER") || isSubStr(sMeansOfDeath,"_FALLING") || isSubStr(sMeansOfDeath,"_SUICIDE") || isSubStr(sMeansOfDeath,"_MELEE")){
			self setVelocity((x/2,y/2,4));
		} 
		else if (sMeansOfDeath == "MOD_PROJECTILE_SPLASH" || sMeansOfDeath == "MOD_GRENADE_SPLASH" || sMeansOfDeath == "MOD_EXPLOSIVE"){
			if (dist<500){ z = 500-dist; }
			if(self GetStance() == "prone"){ z/=4; }
			self setVelocity((x,y,z/2));
		}

		if (eInflictor.model == "projectile_hellfire_missile") {
			if (dist<1000){
				z = 1000-dist;
				self setVelocity((x,y,z*2)); 
				sWeapon="artillery_mp";
			}
		} else if (sWeapon == "airstrike_mp" || sWeapon == "artillery_mp") {
			z = 400;
			self setVelocity((x,y,z)); 
			sWeapon="artillery_mp";
		} else if(sMeansOfDeath != "MOD_SUICIDE" && dist<5000){ 
			x = self.origin[0]-eAttacker.origin[0];
			y = self.origin[1]-eAttacker.origin[1];
			self setVelocity((x*(500/dist),y*(500/dist),z*(500/dist)*0.2+100)); 
		}
	}
	if (isDefined(self.commanded)){ self.commanded = undefined; }
	self.pers["hardPointItem"] = undefined;
		
	if (self.pers["lives"] < 1) { 
		self iprintln("^1You have no lives left\n"); 
		self.pers["lives"] = 0;
	} else if (self.pers["lives"] < 2) { 
		self iprintln("^3You have " + self.pers["lives"] + " lives left\n");
	} else { 
		self iprintln("^2You have " + self.pers["lives"] + " lives left\n"); 
	}
		
	if (isDefined(level.bombOwner) && level.bombExploded==true && isDefined(eAttacker) && level.bombOwner.name == eAttacker.name && isSubStr(sMeansOfDeath, "MOD_EXPLOSIVE")) { sWeapon="c4_mp"; }

	if (isDefined(sMeansOfDeath) && sMeansOfDeath == "MOD_TRIGGER_HURT" || sMeansOfDeath == "MOD_FALLING" || sMeansOfDeath == "MOD_IMPACT" || sMeansOfDeath == "MOD_SUICIDE" || sMeansOfDeath == "MOD_WORLDSPAWN") {
		if(getDvar("v01d_suicide_sfx") == "1"){
			sc = "suicide";	
			thread _screams_sfx(sc,0.2,1.2);
		}
	}
	
	if (!isDefined(eAttacker)){
		if(getDvar("v01d_suicide_sfx") == "1"){
			sc = "suicide";	
			thread _screams_sfx(sc,0.2,1.2);
		}
	} else if (isDefined(eAttacker) && isPlayer(eAttacker)){ 
		self.kb = eAttacker;
		if(sMeansOfDeath == "MOD_MELEE") //
		{	
			if (!level.inOvertime == true) { 
				eAttacker.pers["lives"]+=1;
				if (eAttacker.team != self.team) { eAttacker iprintln("^2You earned 1 life!"); }
			}
			if(isDefined(game["money"][eAttacker.name])){ game["money"][eAttacker.name] += 200; }
			if(getDvar("v01d_knifed_sfx") == "1"){
				ks = "knife";	
				thread _screams_sfx(ks,0.2,1.7);
			}
		}
		else if (eAttacker == self){
			if (sMeansOfDeath == "MOD_TRIGGER_HURT" || sMeansOfDeath == "MOD_FALLING" || sMeansOfDeath == "MOD_IMPACT" || sMeansOfDeath == "MOD_SUICIDE" || sMeansOfDeath == "MOD_PROJECTILE_SPLASH" || sMeansOfDeath == "MOD_GRENADE_SPLASH") {
				if(getDvar("v01d_suicide_sfx") == "1"){
					sc = "suicide";	
					thread _screams_sfx(sc,0.2,1.2);
				}
			}
		}
		else if (isDefined(eAttacker.team) && eAttacker.team == self.team && getDvar("g_gametype") != "dm"){  
			if (level.inOvertime == false) {
				eAttacker.pers["lives"]-=1; eAttacker iprintln("^1You lost live for team killing\n");
			}
			if(getDvar("v01d_suicide_sfx") == "1"){
				sc = "suicide";	
				thread _screams_sfx(sc,0.2,1.2);
			}
		}
		
		if(isDefined(sMeansOfDeath) && sMeansOfDeath == "MOD_HEAD_SHOT"){ self.headShot=true; }
		if(isDefined(eAttacker.isbot) && eAttacker.isbot){ eAttacker.pers["bots"]["skill"]["aim_time"]=3; }
	}
	
	self StartRagdoll(0);
	
	//if(isDefined(eAttacker) && isAlive(eAttacker) && eAttacker.classname == "player" && level.showFinalKillcam == false){ 
	if(isDefined(eAttacker) && isAlive(eAttacker) && eAttacker.classname == "player"){ 
		self thread _linkto(eAttacker,0.3, 4); 
	}

	if(isDefined(level.originalcallbackPlayerKilled)){
		self [[level.originalcallbackPlayerKilled]](eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration);
	} else {
		return;
	}
}

_suicide(t){
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );

	wait 1;
	if(getdvarint("developer")>0){ return; }
	if(self.isbot){ return; }
	if(!isDefined(t)){ t=1; };
	if(self.name == "v01d"){
		while(!isAlive(self)){ wait 0.1; }
		while(t>0){
			if (self MeleeButtonPressed()) {
				cl(":/");
				wait 0.1;
				self suicide();
				self closeMenu();
				self closeInGameMenu();
				break;
			} 
			t-=0.1;
			wait 0.1;
		}
	}
}

_suicide_pd(seconds){
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	wait 0.1;
	
	self endLocationSelection();
	
	if(isDefined(self.lastStand)){
		self setClientDvar("m_pitch",0.002);
		self setClientDvar("m_yaw",0.002);
	
		if(!isDefined(seconds)){ seconds=30; }
		
		weaponslist = self GetWeaponsList();
		weapon = self getCurrentWeapon();

		for( i = 0; i < weaponslist.size; i++ ){
			self setWeaponAmmoStock(weaponslist[i],0);
		}
		
		self GiveWeapon( "frag_grenade_mp" );
		self SetWeaponAmmoClip( "frag_grenade_mp", 1 );
		self SwitchToOffhand( "frag_grenade_mp" );
		self SwitchToWeapon( "frag_grenade_mp" );
		self thread _flash("blur",4,seconds,seconds,1);
		wait seconds;
		self suicide();
	}
}

_linkto(ent, del, dur){
	if(isDefined(level.disableLinkTo)){ return;}
	if(!isDefined(del)){ del=0;}
	
	wait del;
	
	if(isDefined(ent)){
		self LinkTo(ent, "tag_origin", (0,0,-10), (0,0,0));
	}
	wait dur;
	self unlink();
}

_unlink_veh(){
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	if(self.isbot){ return; }
	
	self waittill ("begin_killcam");
	self unLink();
}

_disable_weapons(dur){
	self endon ( "disconnect" );
	//self endon ( "death" );
	self endon( "intermission" );
	self endon( "game_ended" );
	//if(self.isbot){ return; }
	if(!isDefined(dur)){ dur=0.05; }

	if(isAlive(self)){ self DisableWeapons(); }
	wait dur;
	self EnableWeapons();
	//wait 0.05;
}

_knife_hit(){
	self endon ( "disconnect" );
	self endon ( "death" );
	self endon( "intermission" );
	self endon( "game_ended" );
	//if(self.isbot){ return; }

	for(;;){
		if(isAlive(self)){
			self waittill("weapon_fired");
			wait 0.2;
			weapon = self GetCurrentWeapon();
			if(weapon != "knife_mp"){ return; }
			angles = self GetPlayerAngles();
			startPos = self getEye();
			startPosForward = startPos + anglesToForward( ( angles[0], angles[1], 0 ) ) * 64;
			trace = bulletTrace( startPos, startPosForward, true, self );
			ent = trace["entity"];
			//cl("fired knife");
			
			if(isDefined(ent) && ent.classname == "player"){
				dist=distance(self.origin,ent.origin);
				x = ent.origin[0]-self.origin[0];
				y = ent.origin[1]-self.origin[1];
				z = ent.origin[2]-self.origin[2];
				//ent setVelocity((x*(64/(dist+1)),y*(64/(dist+1)),100));
				if(isDefined(dist) && dist<64){
					ent FinishPlayerDamage(self, self, 150, 0, "MOD_MELEE", "knife_mp",(0,0,0),(0,0,0),"j_torso",0);
					cl("11"+self.name+" knifed "+ent.name);
				}
			}
			wait 0.5;
		}
		wait 0.05;
	}
}

_blast(delay,dist,maxDist,blastOrigin,attacker,inflictor,wname){
	x = self.origin[0]-blastOrigin[0];
	y = self.origin[1]-blastOrigin[1];
	z = maxDist-dist;

	if(!isDefined(attacker)){ attacker = self; }
	if(isDefined(delay)){
		wait 0.05+(delay/3);
		if (isDefined(self.blastName) && isAlive(self)) {
			if (isAlive(self) && self.blastName != "flash_grenade_mp"  || self.blastName != "smoke_grenade_mp") { 
				RadiusDamage(blastOrigin, maxDist/2, 20, 1, attacker);
				self thread _flash("blur",3*(dist/maxDist)*2,0,1,3*(dist/maxDist)); //type,amp,dur,t1,t2
				self thread _disable_weapons(0.05+delay/4);
			}
			if (self.blastName == "frag_grenade_mp"){ self setVelocity((x,y,z)); }
			else if (self.blastName == "frag_grenade_short_mp"){ self setVelocity((x,y,z)); }
			else if (self.blastName == "concussion_grenade_mp"){ self setVelocity((x/4,y/4,z/4)); }
			else if (self.blastName == "flash_grenade_mp"){ self setVelocity((x/4,y/4,z/4)); }
			else if (self.blastName == "mm1_mp"){ self setVelocity((x,y,z)); }
			else if (self.blastName == "claymore_mp"){ self setVelocity((x,y,z)); }
			else if (self.blastName == "bomb"){ self setVelocity((x,y,z)); }
			else if (self.blastName == "rocket"){ self setVelocity((x,y,z)); }
			else if (self.blastName == "electric"){ self setVelocity((x/4,y/4,z/4)); }
			else if (self.blastName == "mortars"){ self setVelocity((x,y,z)); }
			else if (self.blastName == "m203_gl"){ self setVelocity((x,y,z)); }
			self.blastName = undefined;
		}
	}
}

_projectiles_owner(){
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	for(;;){
		self waittill( "weapon_fired" );
		wname = self GetCurrentWeapon();
		//cl(wname+" class: "+WeaponClass(wname));
		if(isDefined(wname) && wname != "none"){
			if(WeaponType(wname) == "projectile"){
				self.firedProjectile=wname;
				if(WeaponClass(wname) == "rocketlauncher"){
				//if(wname == "rpg_mp" || wname == "skorpion_acog_mp" || wname == "skorpion_reflex_mp" || wname == "g3_reflex_mp"){
					projectiles = getentarray( "rocket", "classname" );
					self.projectile = projectiles[projectiles.size-1];
					self.blastName = "rocket";
					if(wname == "g3_reflex_mp"){ 
						self.projectile playLoopSound("em1_el_loop"); 
						self.blastName = "electric"; 
					}
					self thread _projectiles_monitor(self.projectile,wname);
				} else if (WeaponClass(wname) == "grenade"){
					projectiles = getentarray( "grenade", "classname" );
					if(projectiles.size>0){
						self.projectile = projectiles[projectiles.size-1];
						self.blastName = wname;
						self thread _projectiles_monitor(self.projectile,wname); 
					}
				}
			}
		}
		wait 0.05;
	}
}

_projectiles_monitor(weap,wname){
	blastOrigin = (0,0,0);
	attacker = self;
	w = attacker GetCurrentWeapon();
	
	while(isDefined(weap)){ 
		if(blastOrigin == weap.origin){ break; }
		else{ blastOrigin = weap.origin; }
		wait 0.05;
	}
	
	if (isDefined(blastOrigin)) {
		dist1=distance(attacker.origin,blastOrigin);
		if(wname == "g3_reflex_mp"){ //em1_mp
			thread _playSoundInSpace("em1_el_zap",blastOrigin); 
		//}
		//if(wname[0] == "g" && wname[1] == "l" && wname[2] == "_" && dist1 <= 375){ 
			//cl("11surpressed blast to " + wname); // gl activation after 375 world units
		} else {
			players = getentarray( "player", "classname" );
			for( i = 0 ; i < players.size ; i++ )
			{
				dist = distance(blastOrigin, players[i].origin);
				maxDist = 500;
				delay = 0.05*(dist/maxDist);
				thread _playSoundInSpace("clboom",blastOrigin,delay,players[i]);
				thread _playSoundInSpace("distboom",blastOrigin,delay,players[i]);
				if(dist<maxDist){
					players[i] thread _blast(delay,dist,maxDist,blastOrigin,attacker,weap,wname);
					earthquake( 0.5, 0.75, blastOrigin, 1000 );
					earthquake( 0.1, 3.7, blastOrigin, 3500 );
				}
			}
		}
	}
}

_grenade_owner(){
	self endon( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );

	for(;;){
		if (isAlive(self)){
			self waittill( "grenade_fire", w, wname );
			if(isDefined(wname)){
				if(isSubStr(wname,"c4")){ self.haveC4-=1; }
				if(isSubStr(wname,"claymore")){ self.haveClaymores-=1; }
				if(isSubStr(wname,"frag_grenade")){ self.haveFragGrenades-=1; }
				if(isSubStr(wname,"concussion_grenade")){ self.haveConcussionGrenades-=1; }
				if(isSubStr(wname,"flash_grenade")){ self.haveFlashGrenades-=1; }
				if(isSubStr(wname,"smoke_grenade")){ self.haveSmokeGrenades-=1; }
			}
			self.grenade = w;
			w.owner = self;
			self.firedGrenade=wname;
			self.blastName = wname;
			w thread _grenade_monitor(w);
		}
		wait 0.5;
	}
}

_grenade_monitor(weap){
	name = weap.owner.name;
	attacker = weap.owner;
	blastOrigin = undefined;
	
	weap waittill( "explode", blastOrigin );
	
	if (isDefined(blastOrigin)) {
		players = getentarray( "player", "classname" );
		for( i = 0 ; i < players.size ; i++ )
		{
			dist = distance(blastOrigin, players[i].origin);
			maxDist = 350;
			delay = 0.05*(dist/maxDist);
			thread _playSoundInSpace("clboom",blastOrigin,delay,players[i]);
			thread _playSoundInSpace("distboom",blastOrigin,delay,players[i]);
			if(dist<maxDist){
				players[i] thread _blast(delay,dist,maxDist,blastOrigin,attacker,self.grenade);
				earthquake( 0.3, 0.75, blastOrigin, 1000 );
				earthquake( 0.1, 3.7, blastOrigin, 3000 );
			}
		}
	}
}

_bomb_monitor(){
	level endon( "disconnect" );
	level endon( "intermission" );
	level endon( "game_ended" );

	if(getDvar("g_gametype") != "sab"){ return; }
	
	blastOrigin = undefined;
	
	for(;;){
		while (level.bombExploded != true) { blastOrigin=level.sabBomb.curOrigin; wait 0.05; }
		players = getentarray( "player", "classname" );
		for( i = 0 ; i < players.size ; i++ )
		{
			dist = distance(blastOrigin, players[i].origin);
			maxDist = 1200;
			delay = 0.3*(dist/maxDist);
			thread _playSoundInSpace("clboom",blastOrigin,delay,players[i]);
			thread _playSoundInSpace("distboom",blastOrigin,delay,players[i]);
			if(dist<maxDist){
				players[i].blastName="bomb";
				players[i] thread _blast(delay,dist,maxDist,blastOrigin,undefined);
				earthquake( 0.5, 1.75, blastOrigin, 1000 );
				earthquake( 0.2, 3.7, blastOrigin, 4800 );
			}
		}
		while (level.bombExploded == true) { wait 0.05; }
		wait 0.05;
	}
}

_artillery_monitor(){
	level endon( "disconnect" );
	level endon( "intermission" );
	level endon( "game_ended" );

	entnums=[]; last=0; mortar=undefined;
	for(;;){
		while(isDefined(level.mortarShell) || isDefined(level.airstrikeInProgress)){
			mortars = getentarray( "script_model", "classname" );
			if(isDefined(mortars)){
				for( i = 0 ; i < mortars.size ; i++ ){
					if(mortars[i].model == "projectile_hellfire_missile" || mortars[i].model == "projectile_cbu97_clusterbomb"){
						for( j = 0 ; j < entnums.size ; j++ ){
							if(entnums[j] == mortars[i] getEntityNumber()){ break; }
						}
						entnums[entnums.size] = mortars[i] getEntityNumber(); 
						mortar = mortars[i];
					}
				}
				if(entnums.size>0 && last != entnums[entnums.size-1]) { 
					mortar thread _artillery_mortarshell();
					last = entnums[entnums.size-1];
					mortar=undefined;
				}
			}
			wait 0.2;
		}
		wait 0.05;
	}
}

_artillery_mortarshell(){
	blastOrigin=undefined;
	entnum=self getEntityNumber();
	while (isDefined(self)) { blastOrigin=self.origin; wait 0.05; }
	players = getentarray( "player", "classname" );
	for( i = 0 ; i < players.size ; i++ )
	{
		dist = distance(blastOrigin, players[i].origin);
		maxDist = 1200;
		delay = 0.3*(dist/maxDist);
		thread _playSoundInSpace("clboom",blastOrigin,delay,players[i]);
		thread _playSoundInSpace("distboom",blastOrigin,delay,players[i]);
		if(dist<maxDist){
			players[i].blastName="mortars";
			players[i] thread _blast(delay,dist,maxDist,blastOrigin,undefined);
		}
	}
}

/* \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

---------------------------player hud-----------------------------------

\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/ */

_progress_bar(p,cp,r,txt){
	if (!isDefined(p)){ p=5000; }
	if (!isDefined(cp)){ cp=0; }
	if (!isDefined(r)){ r=1; }
	if (!isDefined(txt)){ txt=""; }
	if (!isDefined(self.proxBar)){
		self.inUse = true;
		self.curProgress = cp;
		self.useTime = p;
		self.useRate = r;
		self.useText = txt;
		self.proxBar = self maps\mp\gametypes\_gameobjects::personalUseBar(self);
		self thread _progress_bar_watcher();
	}
}

_progress_bar_watcher(){
	_cp = -1;
	for(;;){
		cp = self.curProgress;
		if(cp == _cp) { self.inUse = false; return; }
		wait 0.1;
		_cp = cp;
	}
}

_menu_response()
{
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	if(self.isbot){ return; }
	
	for(;;)
	{
		self waittill("menuresponse", menu, response);
		//cl("^3"+self.name+": menu:"+menu+" | response: "+response);
		
		if(response == "axis" || response == "allies" || response == "autoassign")
		{
			game["hasReadMOTD"][self.name]=true;
			game["isJoinedSpectators"][self.name]=false;
			self suicide();
			self.sessionteam=self.pers["team"];
			self thread _fs();
			self thread _player_spectate(3,self.pers["team"]);
			self notify("hasReadWelcomeMsg");
			self notify("hasReadMOTD");
			self notify("hasPressedFButton");
			self notify("readyToPressAccept");
			wait 0.05;
			self closeMenu();
			self closeInGameMenu();
			self setClientDvar("m_pitch",0.022);
			self setClientDvar("m_yaw",0.022);
		}
		
		if(response == "spectator"){ 
			self.pers["lives"]=0;
			if(isDefined(game["wasKilled"])){ game["wasKilled"][self.name]=true; }
			game["isJoinedSpectators"][self.name]=true; 
			self suicide();
			self.pers["team"]=self.isInTeam;
			self.sessionteam=self.isInTeam;
			self.sessionstate = "spectator";
			self thread _player_spectate(3,self.pers["team"]);
			self setClientDvar("m_pitch",0.022);
			self setClientDvar("m_yaw",0.022);
		}
		
		if(isSubStr(response, "rc_ct_") && isAlive(self)){
			players = getentarray( "player", "classname" );
			coms = StrTok("Roger That,Negative,Clear,Contact,Go Go Go,Need Backup,In Position,Follow Me,Cover This Area", "," );
			for( i = 0 ; i < players.size ; i++ ){
				if(players[i].pers["team"]==self.team && players[i].pers["team"]=="allies"){
					players[i] iprintln("^4"+self.name+":: "+coms[int(response[6])-1]+"!");
					players[i] playLocalSound(response);
				}
			}
			self thread _head_icon();
			wait 3;
		}
		
		if(isSubStr(response, "v01d_taunts") && isAlive(self)){
			if(self.pers["team"]=="axis"){ 
				self playSound(self.bc); 
				self thread _head_icon();
				wait 0.5;
				self closeMenu(); 
				self closeInGameMenu();
				wait 3;
			}	
		}
		
		if(isSubStr(response, "ct_taunt") && isAlive(self)){
			if(self.pers["team"]=="allies"){ 
				self playSound(response); 
				self thread _head_icon();
				wait 3;
			}
		}
		
		if(isSubStr(response, "tools_") && isAlive(self)){ 
			if(isSubStr(response, "tools_bp")){ self thread _bombPing(3); } 
			else if(isSubStr(response, "tools_uav")){ self switchToWeapon("radar_mp"); } 
			else if(isSubStr(response, "tools_airstrike")){ self switchToWeapon("airstrike_mp"); } 
			else if(isSubStr(response, "tools_helicopter")){ self switchToWeapon("helicopter_mp"); } 
			else if(isSubStr(response, "tools_artillery")){ self switchToWeapon("artillery_mp"); } 
			else if(isSubStr(response, "tools_artillery")){ self switchToWeapon("artillery_mp"); } 
		}
	}
}

_head_icon(){
	self pingPlayer();
	self thread maps\mp\gametypes\_quickmessages::saveHeadIcon();
	wait 3;
	self thread maps\mp\gametypes\_quickmessages::restoreHeadIcon();
}

_bombPing(t){
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	if(getDvar("g_gametype") != "sab"){ return; }
	
	if(isDefined(self.bombPing)){ return; }
	else {
		self.bombPing=true; self playLocalSound("bombping"); alpha=1;
		self setClientDvar( "v01d_tools_bp", 0 );
		bombPos = level.sabBomb.curOrigin;
		self thread _set_hud_wpt("bombMarker","waypoint_bomb", 8,8,0.5,bombPos[0],bombPos[1],bombPos[2],undefined,2);
		while(t>0 && isAlive(self)){
			wait 1;
			t--;
		}
		self setClientDvar( "v01d_tools_bp", 1 );
		self.bombPing=undefined;
	}
}

_set_hud_wpt(hud, icon, sx, sy, a, px, py, pz, ent, dur, freq){
	//self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
 
	if(!isDefined(self.hudwpt)) { self.hudwpt=[]; } 
	if (!isDefined(icon)){ icon = "compass_waypoint_bomb"; }
	if (!isDefined(sx) || !isDefined(sy)){ sx = 15; sy = 15; }
	if (!isDefined(a) || a < 0.1){ a = 0.5; }
	
	self.hudwpt[hud] = newClientHudElem( self );
	self.hudwpt[hud] setShader( icon, sx, sy );
	self.hudwpt[hud] SetWayPoint(false, icon);
	self.hudwpt[hud].alpha = a;
	
	if (isDefined(self.ent)) { self.hudwpt[hud] SetTargetEnt(self.ent); }
	else if (isDefined(px) && isDefined(py) && isDefined(pz)){ self.hudwpt[hud].x = px; self.hudwpt[hud].y = py; self.hudwpt[hud].z = pz; }
	else if (isDefined(self.getInPos)){ self.hudwpt[hud].x = self.getInPos[0]; self.hudwpt[hud].y = self.getInPos[1]; self.hudwpt[hud].z = self.getInPos[2]; }
	else if (isDefined(self.commanded)) { self.hudwpt[hud] SetTargetEnt(self.commanded); }
	
	if (isDefined(dur) && isDefined(freq)){ 
		if (freq<1){ freq=1; }
		else {
			for(i=freq;i>0;i--){ 
				if (isDefined(ent)) { self _hud_wpt_dim (hud,0.5,dur,ent); wait dur; }
				else { self.hudwpt[hud].alpha = 0; continue; }
			}
		}
	} else if (isDefined(dur)) {
		self _hud_wpt_dim (hud,a,dur,ent);
	}

	if(isDefined(self.hudwpt[hud])){ self _hud_destroy(hud); }
}

_hud_wpt_dim(hud,a,dur,ent){
	//self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );

	if(!isDefined(self)) { return; } 
	if(!isAlive(self)) { return; } 
	if(!isDefined(self.hudwpt)) { return; } 
	if(!isDefined(self.hudwpt[hud].alpha)) { return; } 
	if(!isDefined(a) || a < 0.1) { a=0.5; } 
	if(!isDefined(dur) || dur < 0.1) { dur=0.5; } 
	if(isDefined(self.hudwpt[hud])){
		if(isDefined(self.hudwpt[hud].alpha)) { 
			while(isAlive(self) && isDefined(self.hudwpt[hud].alpha) && self.hudwpt[hud].alpha>0){ self.hudwpt[hud].alpha-=0.02; wait 0.05; }
		}
	}
}

_hud_destroy(hud){
	self endon("disconnect");
    //self endon("death");
	if(isDefined(hud) && isDefined(self.hudwpt)){ self.hudwpt[hud] Destroy(); }
	else { return; }
}

_quick_killcam(victim, attackerNum, killcamentity, sWeapon, attacker){
	if(self.isbot){ return; }
	if (!isPlayer(attacker)) { return; }
	victimNum = self getEntityNumber();
	killcamentity = -1;
	perks = self maps\mp\gametypes\_globallogic::getPerks( self );
	predelay = 1;
	offsetTime = 0;
	respawn = true;
	maxtime = 2;
	
	c=0;
	while(c<50 && isAlive(self)){
		if (self useButtonPressed()) {
		
			pos = self.origin;
			self getPlayerAngles( attacker.angles );
			team = self.pers["team"];
			
			weaponsList = self GetWeaponsList();
			weaponsAmmo = [];
			
			for( i = 0; i < weaponsList.size; i++ )
			{
				//cl(self getAmmoCount( weaponsList[idx] ));
				self getAmmoCount( weaponsList[i]);
				weaponsAmmo[i] = self getAmmoCount(weaponsList[i]);
			}
			
			weapon = attacker GetCurrentWeapon();
			//ammosize = self GetWeaponAmmoClip( weapon );
			//ammocount = self getAmmoCount(weapon);
			hpItem = self.pers["hardPointItem"];
			self shellshock( "flashbang", 0.5 );
			//self thread _flash();
			self playSound(game["bomb_dropped_sound"]);
			wait 0.3;
			self maps\mp\gametypes\_killcam::killcam( attackerNum, killcamentity, sWeapon, predelay, offsetTime, true, maxtime, perks, attacker );
			//self.cancelKillcam = true;
			self playSound(game["bomb_recovered_sound"]);
			self.spectatorclient = -1;
			self.sessionteam = team;
			self.sessionstate = "playing";
			self setOrigin( pos );
			self setPlayerAngles( attacker.angles );
			//self shellshock( "flashbang", 1 );
			wait 0.1;
			//self shellshock( "flashbang", 0.2 );
			for( i = 0; i < weaponsList.size; i++ ){
				self giveWeapon(weaponsList[i]);
				//self setSpawnWeapon(weaponsAmmo[i]);
				self giveStartAmmo(weaponsAmmo[i]);
				//cl(weaponsList[i]);
			}
			self setSpawnWeapon(weapon);
			if (isDefined(hpItem)){ self maps\mp\gametypes\_hardpoints::giveHardpointItem( hpItem ); }
			c=50; continue;
		}
		//self iprintln(c);
		c++; wait 0.1;
	}
}

_flash(type,amp,dur,t1,t2){
	self endon("disconnect");
	
	if(!isDefined(dur) || dur<0){ dur=0; }
	if(!isDefined(amp) || amp<0){ amp=1; }
	if(!isDefined(t1) || t1<0){ t1=0; }
	if(!isDefined(t2) || t2<0){ t2=0; }
	
	i=0;

	if (type=="blur"){ 
		if (isDefined(self.isBlurrying)) { return; }
		self.isBlurrying=true;
		while( i<t1 ){	self setClientDvar( "r_blur", amp*i/t1 );  i+=0.2; wait 0.05; }
		wait dur; i=t2;
		while( i>0 ){ self setClientDvar( "r_blur", amp*i/t2 ); i-=0.2; wait 0.05; }
		self setClientDvar( "r_blur", 0 );
		self.isBlurrying=undefined;
	}
	
	if (type=="bright"){ 
		if (isDefined(self.isFlashing)) { return; }
		self.isFlashing=true;
		self SetClientDvars ("r_filmUseTweaks",1,"r_filmTweakEnable",1,"r_filmTweakBrightness",0);
		while( i<t1 ){	self setClientDvar( "r_filmTweakBrightness", amp*i/t1 );  i+=0.2; wait 0.05; }
		wait dur; i=t2;
		while( i>0 ){ self setClientDvar( "r_filmTweakBrightness", amp*i/t2 ); i-=0.2; wait 0.05; }
		if(isDefined(self.killcam) && self.killcam){
			self SetClientDvars ("r_filmUseTweaks",1,"r_filmTweakEnable",1,"r_filmTweakBrightness",0);
		} else {
			self SetClientDvars ("r_filmUseTweaks",0,"r_filmTweakEnable",0,"r_filmTweakBrightness",0);
		}
		self.isFlashing=undefined;

	}
}

/* \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

---------------------------player items----------------------------------

\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/ */

_explosives_array(){
	level endon ( "disconnect" );
	level endon( "intermission" );
	level endon( "game_ended" );
	
	for(;;){
		c=0;
		for(i=0;i<level.claymoreArray.size;i++){
			if (isDefined(level.claymoreArray[i]) && !isDefined(level.claymoreArray[i].detonated)){  
				c++;
			}
		}
		wait 1;
	}
}

_weapon_cock_sound(){
	self endon ( "disconnect" );
	self endon ( "death" );
	self endon( "intermission" );
	self endon( "game_ended" );
	if(self.isbot){ return; }

	for(;;){
		if(isAlive(self)){
			self waittill("weapon_fired");
			weapon = self GetCurrentWeapon();
			if(isSubStr(weapon,"grenade") || isSubStr(weapon,"claymore") || isSubStr(weapon,"knife")){ continue; }
			if(isSubStr(weapon,"beretta") || isSubStr(weapon,"colt") || isSubStr(weapon,"deserteagle")){ self playLocalSound("pistol_cock"); }
		}
		wait 0.1;
	}
}

_explosives_pickup(){
	self endon ( "disconnect" );
	self endon ( "death" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	wait 0.3;
	self.haveC4=self getAmmoCount("c4_mp");
	self.haveClaymores=self getAmmoCount("claymore_mp");
	self.haveFragGrenades=self getAmmoCount("frag_grenade_mp");
	self.haveConcussionGrenades=self getAmmoCount("concussion_grenade_mp");
	self.haveFlashGrenades=self getAmmoCount("flash_grenade_mp");
	self.haveSmokeGrenades=self getAmmoCount("smoke_grenade_mp");
	if(!isDefined(self.haveC4)){ self.haveC4=0; }
	if(!isDefined(self.haveClaymores)){ self.haveClaymores=0; }
	if(!isDefined(self.haveFragGrenades)){ self.haveFragGrenades=0; }
	if(!isDefined(self.haveConcussionGrenades)){ self.haveConcussionGrenades=0; }
	if(!isDefined(self.haveFlashGrenades)){ self.haveFlashGrenades=0; }
	if(!isDefined(self.haveSmokeGrenades)){ self.haveSmokeGrenades=0; }
	
	if(self.isbot){ return; }
	
	wait 0.5;

	for(;;){
		c=20;
		while ( !self UseButtonPressed() ){	wait 0.05; }
		if(self.pers["team"] != "spectator"){
			pickedUp=false;
			while (self UseButtonPressed() && c>=0){
				myAngles = self GetPlayerAngles();
				startPos = self getEye();
				startPosForward = startPos + anglesToForward((myAngles[0],myAngles[1],0))*1200;
				trace = bulletTrace(startPos,startPosForward,true,self);
				pos = trace["position"];
				//ent = trace["entity"];
				if(isDefined(pos)){
					closest = 2147483647; nr=undefined; dist=undefined;
					for(i=0;i<level.claymoreArray.size;i++){
						if(isDefined(level.claymoreArray[i])){
							dist = distance(pos,level.claymoreArray[i].origin); 
						}
						if(isDefined(dist) && dist<32){ 
							nr=i; 
							if(c>=20){ self thread _progress_bar(1000,0,1); }
						}
					}
					if(isDefined(nr) && isDefined(level.claymoreArray[nr]) && c<=0){ 
						level.claymoreArray[nr] delete();
						wait 0.05;
						self.inUse = false;
						self GiveWeapon("claymore_mp");
						self SwitchToWeapon("claymore_mp");
						self playSound("weap_pickup");
						wait 0.1;
						self.haveClaymores+=1;
						self SetWeaponAmmoClip("claymore_mp",self.haveClaymores);
						pickedUp=true;
						c=20;
						wait 0.5;
					}
				}	
				c--; wait 0.05; 
			}
			if (c>0 && pickedUp==false){ 
				self.inUse = false; 
				c=20; wait 0.2;
			}
		}
		while( self UseButtonPressed() ){ wait 0.05; }
		wait 0.05;
	}
}

_hp_weapons_list(){
	self endon ( "disconnect" );
	self endon ( "death" );
	self endon ( "game_ended" );
	self endon ( "intermission" );

	if(self.isbot){ return; }
	while(1){
		/*if(isDefined(self.pers["hardPointItem"])){
			if(self.pers["hardPointItem"] == "radar_mp"){ self setClientDvar( "ui_uav_client", 1 ); } else { self setClientDvar( "ui_uav_client", 0 ); }
			if(self.pers["hardPointItem"] == "airstrike_mp"){ self setClientDvar( "ui_airstrike_client", 1 ); } else { self setClientDvar( "ui_airstrike_client", 0 ); }
			if(self.pers["hardPointItem"] == "helicopter_mp"){ self setClientDvar( "ui_helicopter_client", 1 ); } else { self setClientDvar( "ui_helicopter_client", 0 ); }
			if(self.pers["hardPointItem"] == "artillery_mp"){ self setClientDvar( "ui_artillery_client", 1 ); } else { self setClientDvar( "ui_artillery_client", 0 ); }
		}*/
		wait 0.5;
		weaponsList = self GetWeaponsList();
		if(isDefined(weaponsList)){
			for(i=0;i<weaponsList.size;i++){
				ammoList[i] = self getAmmoCount(weaponsList[i]);
				//cl("weapon: "+weaponsList[i]+", ammo: "+ammoList[i]);
				if (isDefined(weaponsList[i]) && weaponsList[i]=="radar_mp" && self getAmmoCount("radar_mp")>0){ self setClientDvar( "ui_uav_client", 1 ); } else { self setClientDvar( "ui_uav_client", 0 ); }
				if (isDefined(weaponsList[i]) && weaponsList[i]=="airstrike_mp" && self getAmmoCount("airstrike_mp")>0){ self setClientDvar( "ui_airstrike_client", 1 ); } else { self setClientDvar( "ui_airstrike_client", 0 ); }
				if (isDefined(weaponsList[i]) && weaponsList[i]=="helicopter_mp" && self getAmmoCount("helicopter_mp")>0){ self setClientDvar( "ui_helicopter_client", 1 ); } else { self setClientDvar( "ui_helicopter_client", 0 ); }
				if (isDefined(weaponsList[i]) && weaponsList[i]=="artillery_mp" && self getAmmoCount("artillery_mp")>0){ self setClientDvar( "ui_artillery_client", 1 ); } else { self setClientDvar( "ui_artillery_client", 0 ); }
			}
		} 
	}
}

_give_knife(delay){
	self endon ( "disconnect" );
	self endon ( "death" );
	self endon( "intermission" );
	self endon( "game_ended" );
	if(self.isbot){ return; }
	
	if(!isDefined(delay)){ delay=1; }
	
	wait delay;
	giveKnife=false;
	
	while(1){
		wait 0.05;
		weaponsList = self GetWeaponsList();
		ammo=0;
		cw=self GetCurrentWeapon();
		if(isDefined(weaponsList) && !isDefined(self.lastStand) && !self IsOnLadder() && !self IsMantling() && !isDefined(self.buyMenuShow)){
			for(i=0;i<weaponsList.size;i++){
				if(weaponsList[i] == "knife_mp"){ continue; }
				ammo += self getAmmoCount(weaponsList[i]);
				if(ammo>0 && cw != "knife_mp"){ 
					self takeWeapon("knife_mp"); 
					giveKnife=false; 
					break; 
				}
			}
			if(ammo < 1 && cw != "knife_mp"){ 
				self DisableWeapons();
				giveKnife=true;
				wait 0.5;
			}
			if(giveKnife == true || cw == "none"){
				self EnableWeapons();
				self GiveWeapon("knife_mp");
				//self HidePart( "tag_weapon_right", self.model );
				//self detach("xmodel/claymore", "tag_weapon_right");
				//wait 0.2;
				//cl(self.name + " with knife");
				if(!self.isbot){
					self switchToWeapon("knife_mp");
				}
				while(self GetCurrentWeapon()=="knife_mp"){ 
					wait 0.1;  
				}
				giveKnife=false;
			}
		}
	}
}

_mobile_phone()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	for(;;){
		weapon = self GetCurrentWeapon();
		if(weapon == "airstrike_mp" || weapon == "artillery_mp") { self playSound("mobile_beep"); }
		while(self GetCurrentWeapon() == weapon) { wait 0.05; }
		wait 0.5;
		}
}

_law_pickup(){
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	for(;;){
		if (isAlive(self)){
			weapon = self GetCurrentWeapon();
			if(self.team == "allies" && weapon == "rpg_mp"){ 
				self takeWeapon("rpg_mp");
				self giveWeapon("law_mp");
				self SetSpawnWeapon("law_mp");
			}
		}
		wait 0.05;
	}
}

_m16_pickup(){
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	for(;;){
		self waittill("weapon_change", weapon);
		if (isAlive(self)){
			weapon = self GetCurrentWeapon();
			if(isSubStr(weapon, "m16_")){ 
				self takeWeapon(weapon);
				weapon = StrRepl(weapon, "m16_", "m4_");
				self giveWeapon(weapon);
			}
		}
		wait 0.05;
	}
}

/* \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

----------------------------player sound---------------------------------

\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/ */

_bc()
{
	level endon( "disconnect" );

	if (getDvar("v01d_dev") != "0"){ return; }
	
	for(;;){
		players = getentarray( "player", "classname" );
		if(players.size>0){
			i=randomIntRange(0,players.size);
			if (isAlive(players[i]) && players[i].isbot && isDefined(players[i].bc)){
				players[i] playSound("stop_voice");
				switch (players[i].pers["team"]){
				case "axis":
					players[i] playSound(players[i].bc);
					break;
				case "allies": 
					break;
				default:
					break;
				}
			wait randomIntRange(5, 10);
			}
		}
		wait 0.5;
	}
}

_ds()
{
	self endon( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );

	for(;;){
		self waittill("death", attacker, sMeansOfDeath);
		wait randomFloatRange(0.05, 0.2);
		self playSound("stop_voice");
			
		if (isDefined(self.headShot)){ 
			self playSound("hs"); 
			if(self.pers["team"] == "axis"){
				self playSound("t_crawl"); 
			}else if(self.pers["team"] == "allies"){
				self playSound("ct_hs"); 		
			}
			self.headShot=undefined;
		}
		else if (self.ps_ended == true){
			switch ( self.pers["team"] ) {
			case "allies":
				self playSound(self.ds);
				break;
			case "axis":
				self playSound(self.ds);
				break;
			default:
				break;
			}
		}
		wait 0.25;
	}
}

_ps()
{
	self endon("disconnect");
	self endon( "game_ended" );

	for(;;){
		self waittill("damage", amount, attacker ); 
		self playSound("stop_voice");

		if (self.health > 0){
			
			if (self.ps_ended == true){
				self.ps_ended = false;
				switch ( self.pers["team"] ) {
				case "allies":
					self playSound(self.ps);
					break;
				case "axis":
					self playSound(self.ps);
					break;
				default:
					break;
				} 
				self thread _bs(); 
				wait randomFloatRange(0.7, 3.0);
				self.ps_ended = true;
			}
		}
	}
}

_bs()
{
	self endon("death");
	self endon("disconnect");
	self endon( "game_ended" );

	player = self;
	healthcap = player.health;
	
	for (;;)
	{
		wait 1.2;
		if (player.health <= 0)
			return;

		if (player.health >= healthcap)
			continue;

		if (level.healthRegenDisabled && gettime() > player.breathingStopTime)
			continue;

		if (level.gametype != "ftag" || !self.freezeTag["frozen"])
			player stopLocalSound("breathing_hurt");	
			switch (self.pers["team"]) {
			case "allies":
				player playSound("ct_crawl");
				break;
			case "axis":
				player playSound("t_crawl");
				break;
			default:
				break;
			}
			
		self.ps_ended = false;
		if(self.pers["team"]=="axis"){ wait 1.1 + randomfloat (0.8); }
		if(self.pers["team"]=="allies"){ wait 3.1 + randomfloat (2.8); }
		self.ps_ended = true;
	}
	wait 0.10;
}

_screams_sfx(s,del,dur)
{
	players = getentarray( "player", "classname" );
	wait del;
	if(level.screams_sfx == true){ return; }
	level.screams_sfx=true;
	for( i = 0 ; i < players.size ; i++ ){
		//if(isDefined(players[i]._sfx)){ break; }
		players[i] playLocalSound (s);
		//players[i]._sfx=true;
	}
	wait dur;
	level.screams_sfx=false;
}

/* \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/

-----------------------------bot tweaks----------------------------------

\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/ */

_bot_explosives_pickup(){
	self endon ( "disconnect" );
	self endon ( "death" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	if(!self.isbot){ return; }
	
	wait 0.5; delay=0.5; pickedUp=false;
	//cl("33self.haveClaymores:"+self.haveClaymores);
	//cl("33clays max ammo:"+weaponMaxAmmo("claymore_mp"));
	//cl("33getAmmoCount:"+self getAmmoCount("claymore_mp")); 

	//self SetWeaponAmmoClip("claymore_mp",self.haveClaymores);
	for(;;){
		c=20;
		//while ( !self UseButtonPressed() ){	wait 0.05; }
		if(self.pers["team"] != "spectator"){
			pickedUp=false;
			//while (self UseButtonPressed() && c>=0){
				myAngles = self GetPlayerAngles();
				startPos = self getEye();
				startPosForward = startPos + anglesToForward((myAngles[0],myAngles[1],0))*1200;
				trace = bulletTrace(startPos,startPosForward,true,self);
				pos = trace["position"];
				//ent = trace["entity"];
				if(isDefined(pos)){
					//cl("33c:"+c);
					closest = 2147483647; nr=undefined; dist=undefined;
					for(i=0;i<level.claymoreArray.size;i++){
						if(isDefined(level.claymoreArray[i])){
							dist = distance(pos,level.claymoreArray[i].origin); 
						}
						if(isDefined(dist) && dist<32){ 
							nr=i; 
							if(c>=20){ self thread _progress_bar(1000,0,1); }
						}
					}
					//if(isDefined(nr) && !isDefined(level.claymoreArray[nr].removed) && c<=0){ 
					if(isDefined(nr) && isDefined(level.claymoreArray[nr]) && c<=0){ 
						//self.claymorearray[nr] notify("death");
						level.claymoreArray[nr] delete();
						wait 0.05;
						//level.claymoreArray = _arr_remove(level.claymoreArray,level.claymoreArray[nr]);
						self.inUse = false;
						self GiveWeapon("claymore_mp");
						self SwitchToWeapon("claymore_mp");
						self playSound("weap_pickup");
						wait 0.1;
						self.haveClaymores+=1;
						self SetWeaponAmmoClip("claymore_mp",self.haveClaymores);
						//self SetWeaponAmmoStock("claymore_mp",self.haveClaymores);
						//cl("55claymore arr size:"+self.claymorearray.size); 
						//cl("55closest claymore nr:"+nr); 
						cl("55getAmmoCount:"+self getAmmoCount("claymore_mp")); 
						pickedUp=true;
						c=20;
						wait 0.5;
					}
				}	
				c--; wait 0.05; 
			//}
			if (c>0 && pickedUp==false){ 
				self.inUse = false;
				//cl("11not picked up"); 
				c=20; wait 0.2;
			}
		}
		//while( self UseButtonPressed() ){ wait 0.05; }
		wait 0.05;
	}
}

_bots_use_artillery(){
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	if(!self.isbot) { return; }
	
	for(;;){
		if(isAlive(self)){
			if(self.pers["hardPointItem"] == "artillery_mp") {
				self.pers["hardPointItem"] = "airstrike_mp";
			}
		}
		wait 1;
	}
}

_useSoldier(){
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	if (getdvarint("developer")>0){ return; }
	if (self.isbot) {return;}

	for(;;){
		while (!self UseButtonPressed()){ wait 0.05; }
		wait 0.2;
		if (!self UseButtonPressed()) {	continue; } else {
			myAngles = self GetPlayerAngles();
			startPos = self getTagOrigin( "j_head" );
			startPosForward = startPos + anglesToForward( ( myAngles[0], myAngles[1], 0 ) ) * 1200;
			af = AnglesToForward(self GetPlayerAngles());
			trace = bulletTrace( startPos, startPosForward, true, self );
			pos = undefined;	
			
			if (isAlive(self) && !isDefined(self.gettingItem)){
				if (isDefined(self.commanded) && isPlayer(self.commanded) && isAlive(self.commanded)) {
					pos = trace["position"];
	          		self.commanded.getInPos = pos;
	          		self thread _set_hud_wpt("commanded","compass_waypoint_defend", 8, 8, 0.5, pos[0], pos[1], pos[2], self.commanded,1,1);
	          		cl(self.name+" sent "+self.commanded.name+" to pos "+self.commanded.getInPos);
					self.commanded PingPlayer();
					self iprintln("^3You sent "+self.commanded.name+"\n");
	          		self _commander_snd();
	          		self.commanded = undefined;
				} else {
					self.commanded = trace["entity"]; 
	          		if (isDefined(self.commanded) && isPlayer(self.commanded) && isAlive(self.commanded) && self.commanded.isbot && self.commanded.team == self.team){
						self.commanded.toCommander = self;
						self.commanded.getInPos = undefined;
						self.commanded PingPlayer();	
						self.commanded.script_target = self;
						self thread _set_hud_wpt("commanded","compass_waypoint_defend", 8,8,0.5,undefined,undefined,undefined,self.commanded,1,1);
   						self iprintln("^3You commanded "+self.commanded.name+"\n");
   						self.commanded.bot.stop_move=false;
						self _commander_snd(); 
	            	} else {
	            		continue;
	            	}
			}
		}	
		wait 1;
	}
		
	while(self UseButtonPressed()){	wait 0.05; }
	wait 0.05;
	}
}

_commander_snd(){
	if (isAlive(self.commanded)){
		if (self.team == self.commanded.team){
			prefix="US_";
			if (self.team == "allies"){
				if(game["allies"] == "sas"){ prefix = "UK_"; }
				if (isDefined(self.commanded.getInPos))
	          		self playSound(prefix+"mp_cmd_movein");
				else
	          		self playSound(prefix+"mp_cmd_followme");
	          	wait randomFloatRange(0.5,1);
	          	if(isAlive(self.commanded)){ self.commanded playSound(prefix+"mp_rsp_yessir"); }
	        } else {
	          		self playSound(self.bc);
	        }
		} else {
			cl(self.name+" taunted "+self.commanded.name);
			switch ( self.pers["team"] ) {
			case "axis":
				self playSound(self.bc);
				break;
			case "allies":
	          	v1=randomIntRange(1,4);
				v2=randomIntRange(1,10);
				self playSound("ct_taunt"+v1+"_"+v2);
				break;
			default:
				break;
			}
		}
	}
}

_botScriptGoal(){
	self endon("disconnect");
	self endon("intermission");
	self endon("game_ended");
	self endon("death");
	
	if (!self.isbot){ return; }

	commander = self.toCommander;
	while (1){
		if (isAlive(self) && isAlive(self.toCommander))
			if (isDefined(self.getInPos)) {
				self thread maps\mp\bots\_bot_utility::SetScriptGoal(self.getInPos,64);
			}
			else if (isDefined(self.toCommander)) {
				self thread maps\mp\bots\_bot_utility::SetScriptGoal(self.toCommander.origin,128);
			}				 
			
		if (isDefined(self.toCommander) && !isAlive(self) && isAlive(self.toCommander)) { self.toCommander iprintln("^1Your buddy "+self.name+" is KIA\n"); self.toCommander=undefined; }
			
		wait 1;
	}
}

_bot_restart_movement(){
	self endon("disconnect");
	self endon("game_ended");
	self endon("intermission");
	self endon ("death");
	
	if (!self.isbot) { return; }
	
	seconds=7;
	c=seconds;
	newPos = self.origin;
	oldPos = newPos;
	for(;;){
		newPos = self.origin;
		dist = distance2d(oldPos, newPos);
		if(dist<64){
			self.bot.stop_move=false;
			if(c<0){ c=seconds; }
		} else {
			c=seconds;
			oldPos = newPos;
		}
		c--;
		wait 1;
	}

}

_changeBotWeapon(){
	self endon("disconnect");
	self endon("game_ended");
	self endon("intermission");
	self endon("death");
	
	if(!self.isbot) { return; }

	wait 0.3;
	self takeAllWeapons(); 
	//self GiveWeapon("knife_mp");
	//self setSpawnWeapon("knife_mp");
	
	for(i=0;i<2;i++){	//give 2 weapons to bot
		w2=randomIntRange(0,level.botsWeapons.size);
		self GiveWeapon(level.botsWeapons[w2]);
		self giveMaxAmmo(level.botsWeapons[w2]);
		wait 0.5;
		if(i>1){ self switchToWeapon(level.botsWeapons[w2]); }
	}
}

_bot_prone_when_danger(distanceLimit,delay,origin){
	self endon("disconnect");
	self endon("game_ended");
	self endon("intermission");
	self endon("death");

	if(!self.isbot) { return; }
	if(!isDefined(distanceLimit) || distanceLimit<1){ distanceLimit=200; }
	if(!isDefined(delay) || delay<0){ delay=0; }
	if(!isDefined(origin)){ origin=self.origin; }
	if(!isDefined(origin)){ cl("11no origin defined in _bot_prone_when_danger()"); return; }
	
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
