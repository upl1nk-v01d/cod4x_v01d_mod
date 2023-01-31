#include common_scripts\utility;
#include maps\mp\_load;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include scripts\cl;

// var = !var

_template(){
	self endon ( "disconnect" );
	self endon ( "death" );
	self endon( "intermission" );
	self endon( "game_ended" );
	//if (!getdvarint("developer")>0){ return; }
	//if(self.isbot){ return; }
	
	for(;;){
	
		wait 0.05;
	}
}

init()
{

	level thread scripts\bots_aim_ext::init();
	level thread scripts\bots_fire_ext::init();
	level thread scripts\chopper_ext::init();
	level thread scripts\money::init();
	level thread scripts\menus::init();
	level thread scripts\tactical::init();
	//level thread scripts\bots_nav::init();

	if (getDvar("v01d_version") == "") { setDvar("v01d_version", "v2.00"); }

	//if (!getdvarint("developer")>0) { return; }
	
	if (getDvar("g_gametype") == "") { setDvar("g_gametype","sab"); }
	//if (getDvar("g_gametype") != "sab") { return; }
	
	level._maps = StrTok("mp_ancient_ultimate,12,mp_carentan,14,mp_rasalem,12,mp_efa_lake,10,mp_bo2carrier,12,mp_bog,16,mp_summit,18,mp_backlot,16,mp_harbor_v2,16,mp_sugarcane,12,mp_csgo_assault,12,mp_csgo_inferno,12,mp_csgo_office,12,mp_csgo_overpass,12,mp_csgo_mirage,12,mp_finca,12,mp_csgo_safehouse,10,mp_csgo_cbble,12,mp_csgo_shortdust,12,mp_csgo_stmarc,12,mp_ins_panj,10,mp_creek,12,mp_csgo_mirage,12,mp_csgo_overpass,12,mp_ins_heights,12,mp_ins_peak,12", "," );
	level._weapons = StrTok("knife_mp", "," );
	//level._weapons = StrTok("knife_mp,m16_mp,m16_reflex_mp,barret_mp,barret_acog_mp,winchester_reflex_mp,winchester_grip_mp,skorpion_acog_mp,skorpion_reflex_mp", "," );
	level._gametypes = StrTok("mp_csgo_assault,war,mp_csgo_inferno,dm", "," );
	//level._weapons = StrTok("knife_mp,tac330_mp,tac330_sil_mp,svg100_mp,rw1_mp,law_mp,at4_bo_mp,mm1_mp,striker_mp", "," );
	for (i=0;i<level._weapons.size;i++){
		PrecacheItem(level._weapons[i]);
		if(isDefined(level.precachedItemsNum)){ level.precachedItemsNum++; } //forth precache
		//cl ("Weapon precached: " + level._weapons[i]);
	}
	level.hudMarkers = [];
	level.slowMo=false;
	level.gracePeriod = 30;
	
	//for(i=0;i<level._gametypes;i+=2){ 
	//	if(level._gametypes[i]==getDvar("mapname")){ setDvar("g_gametype",level._gametypes[i+1]); break; }
	//	else{ setDvar("g_gametype","sab"); }
	//}
	
	/*
	level.classSniper = StrTok("tac330_mp,tac330_sil_mp,svg100_mp,barrett_mp,dragunov_mp,m40a3_mp,remington700_mp", "," );
	level.classRPG = StrTok("law_mp,at4_mp,rpg_mp", "," );
	level.classGL = StrTok("mm1_mp", "," );
	level.classRifle = StrTok("rw1_mp,m14_mp,m4_mp,remington700_mp,m1014_mp", "," );
	level.classMG = StrTok("m60a1_mp", "," );
	level.classSMG = StrTok("ak74u_mp,g3_mp,mp44_mp,skorpion_mp,uzi_mp", "," );
	level.classPistol = StrTok("colt45_mp,colt45_silencer_mp,beretta_mp,beretta_silencer_mp,deserteagle_mp,deserteaglegold_mp", "," );
	*/
	
	level.classSniper = StrTok("svg100,dragunov,m21", "," );
	level.classRPG = StrTok("law,at4,rpg,skorpion_acog,skorpion_reflex", "," );
	level.classGL = StrTok("mm1,barrett_acog", "," );
	level.classRifle = StrTok("m14,m4,m1014,m16,g3", "," );
	level.classMG = StrTok("m60e4,saw,rpd,", "," );
	level.classSMG = StrTok("ak47,g36,ak74u,mp44,uzi,mp5,p90,mp44", "," );
	level.classPistol = StrTok("colt45,usp,beretta,deserteagle,rw1,winchester1200_grip", "," );
	level.classBoltSniper = StrTok("m40a3,remington700,tac330,aw50", "," );
	
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
	
	game["menu_clientdvar"] = "clientdvar";
    precachemenu(game["menu_clientdvar"]);
	precacheMenu("v01d_qm");
	precacheMenu("v01d_coms");
	precacheMenu("v01d_ct_taunts_main");
	precacheMenu("v01d_ct_taunts_1");
	precacheMenu("v01d_ct_taunts_2");
	precacheMenu("v01d_ct_taunts_3");
	precacheMenu("v01d_tools");

	level.st = gettime();
	level.tp=0;
	level.playedStartingMusic=true;
	level.kickOneBot=undefined;
	level.addOneBot=undefined;
	
    setDvar( "scr_intermission_time", 10.0 );
	//setDvar("bots_play_fire", false);
	//setDvar("bots_play_knife", false);
	//setDvar("bots_play_nade", false);
	//setDvar("bots_manage_fill", 4);
	setDvar("bots_main_menu", false);
	//setDvar("bots_play_fire",0);
	
	if(getDvar("dev") == ""){ setDvar("dev",0); }
	if(getDvar("bots_inbalance_feature") == ""){ setDvar("bots_inbalance_feature",0); }
	if(getDvar("bots_recoil_spicyness") == ""){ setDvar("bots_recoil_spicyness",0.2); }
	if(getDvar("log_players") == ""){ setDvar("log_players",1); }
	if(getDvar("log_motd") == ""){ setDvar("log_motd",1); }
	if(getDvar("log_server_con") == ""){ setDvar("log_server_con",1); }
	
	setDvar("pl",""); //in terminal argument a = show all players, r = real players, b = bot players
	setDvar("m",""); //in terminal argument i = show current map and team score, f = fast restart, r = brutal restart
	SetDvar("timescale", 1);
	SetDvar("sl",0); //set dvar scr_sab_scorelimit to args val
	SetDvar("tl",0); //set dvar scr_sab_timelimit of round to args val
	SetDvar("nl",0); //set dvar scr_sab_numlives of player to args val
	SetDvar("ab",""); //add 1 bot to desired team
	SetDvar("kb",""); //kick 1 bot from desired team
	
	if (getDvar("dev")=="nav") { 
		setDvar("scr_game_spectatetype", "2"); 
		setDvar("scr_game_matchstarttime", "0"); 
		setDvar("scr_"+getDvar("g_gametype")+"_timelimit", "0"); 
		setDvar("scr_sab_numlives",1);
	}
	
	if (!isDefined(game["nm"])){ game["nm"]="on"; setDvar("_newmode_", game["nm"]); }
	if (!isDefined(game["waypointless_map"])){ game["waypointless_map"]="off"; }
	if (!isDefined(game["realPlayers"])){ game["realPlayers"]=0; }
	if (!isDefined(game["botPlayers"])){ game["botPlayers"]=0; }
	if (!isDefined(game["isConnecting"])){ game["isConnecting"]=[]; }
	if (!isDefined(game["isJoinedSpectators"])){ game["isJoinedSpectators"]=[]; }
	if (!isDefined(game["nextMap"])){ game["nextMap"]=""; }
	if (!isDefined(game["prevMap"])){ game["prevMap"]=""; }
	if (!isDefined(game["mapList"])){ game["mapList"]=[]; }
	if (!isDefined(game["teamWonRound"])){ game["teamWonRound"]=""; }

	if (level.waypointCount == 0) {
		game["waypointless_map"]="on";
	} else {
		game["waypointless_map"]="off";
	}

	level.originalcallbackPlayerKilled = level.callbackPlayerKilled;
    level.callbackPlayerKilled = ::_killed;
	level.originalcallbackPlayerDamage = level.callbackPlayerDamage;
    level.callbackPlayerDamage = ::_damaged;
	
    level thread _dev_start();
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
	//level thread _teamWatcher();
	//level thread _dev_waittillframeend_test();
	//level thread _grenades_monitor();
	//level thread _projectiles_monitor();
	level thread _bomb_exploded();
	level thread _bot_balance_manage();
	level thread _dvar_add_bots();
	level thread _dvar_remove_bots();
	level thread _explosives_array();
	level thread _last_allie_taunting();
	level thread _round_time_passed();
	//level thread _bomb_objective_blink();
	level thread _precache_info(1);
	
	level thread _t1();
	level thread _t2();
	//level thread _t2();
	//level thread _t3();
	//level thread _t4();
	//level thread _t5();
	
	if(!isDefined(game["_t_m_static"])){game["_t_m_static"] = randomIntRange(1, 15);}
	if(!isDefined(game["_ct_m_static"])){game["_ct_m_static"] = randomIntRange(1, 5);}
	if(!isDefined(game["_t_m_"])){game["_t_m_"] = game["_t_m_static"];}
	if(!isDefined(game["_ct_m_"])){game["_ct_m_"] = game["_t_m_static"];}
		
	for(;;)
    {
    	//level waittill( "connecting", player );
		//player thread _connecting();
        
        level waittill("connected", player);
 		if(!player.isbot && getDvarInt("log_players")==1) { player thread _player_info(1,player.name); }
		if(!isDefined(game["isJoinedSpectators"][player.name])){ game["isJoinedSpectators"][player.name]=true; }
        
        player thread _welcome();
        player thread _info();
		player thread _player_spawn_loop();
		player thread _disconnected();
		player thread _fs();
		player thread _check_sleepers();
		//player thread _damaged();
		player thread _botScriptGoal();
		player thread _grenade_owner();
		player thread _projectiles_owner();
		player thread _menu_response();
		
		//player thread _dev_sound_test();
		//player thread _dev_weapon_test();

		//tm++;  ctm++;
		//if (tm > 13) { tm=1; }
		//if (ctm > 5) { ctm=1; }
		
		//if(isDefined(game["botPlayers"])){ setDvar("bots_manage_fill", game["botPlayers"]+1-game["realPlayers"]); }
	} 
}

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

_cancel_reload_when_jumping(){
	self endon ( "disconnect" );
	self endon ( "death" );
	self endon( "intermission" );
	self endon( "game_ended" );
	//if(self.isbot){ return; }
		
	for(;;){
		while(!self JumpButtonPressed()){ wait 0.05; }
		self DisableWeapons();
		wait 0.4;
		self EnableWeapons();
		//wait 0.05;
	}
}

_precache_info(delay){
	wait delay;
	if(isDefined(level.precachedItemsNum)){ cl("33Totally precached "+level.precachedItemsNum+" items!"); }
}

_last_allie_taunting(){
	level endon( "disconnect" );
	for(;;){
		//players = _chk_players("alive");
		//allies = players["allies"];
		//if(isDefined(allies) && allies==1){
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

_bot_balance_manage(){
	level endon ( "disconnect" );
	//level endon( "intermission" );
	//level endon( "game_ended" );

	if(getDvarInt("bots_inbalance_feature") == 1 && !isDefined(level.doNotAddBots)){
		wait 1;
		if(isDefined(game["teamWonRound"])){			
			if(game["teamWonRound"]=="axis"){ 
				exec("ab allies");
				wait 0.5;
				if(level.playerLives["axis"]>4){ exec("kb axis"); }
				//exec("kb axis");
			} else if(game["teamWonRound"]=="allies"){ 
				exec("ab axis");
				wait 0.5;
				if(level.playerLives["allies"]>4){ exec("kb allies"); }
				//exec("kb allies");
			}
		}
		
		axisScore = [[level._getTeamScore]]( "axis" );
		alliesScore = [[level._getTeamScore]]( "allies" );
		_axisScore = axisScore;
		_alliesScore = alliesScore;
		cl("33waiting... team score diff");
		while(axisScore==_axisScore && alliesScore==_alliesScore){ 
			wait 1;
			axisScore = [[level._getTeamScore]]( "axis" );
			alliesScore = [[level._getTeamScore]]( "allies" );
		}
		if(axisScore>_axisScore){ game["teamWonRound"]="axis"; }
		if(alliesScore>_alliesScore){ game["teamWonRound"]="allies"; }
		//cl("33level.playerLives[axis]:"+level.playerLives["axis"]);
		//cl("33level.playerLives[allies]:"+level.playerLives["allies"]);
		cl("33waiting... game[state] == postgame");
		while (level.gameEnded) { wait 0.5; }
		cl("33game[teamWonRound]="+game["teamWonRound"]);
	}
}

_player_collision(timer){
	//level waittill("prematch_over");
	while (isDefined(level.inPrematchPeriod) && level.inPrematchPeriod==true){ wait 1; }
	//players = getentarray( "player", "classname" );
	//for( i = 0 ; i < players.size ; i++ ){ players[i] setClientDvar( "g_friendlyplayercanblock", 0 ); }
	setDvar("g_friendlyplayercanblock",0);
	wait timer;
	//for( i = 0 ; i < players.size ; i++ ){ players[i] setClientDvar( "g_friendlyplayercanblock", 1 ); }
	setDvar("g_friendlyplayercanblock",1);
}

_player_connecting_loop(){
	level endon ( "disconnect" );
	level endon( "intermission" );
	level endon( "game_ended" );	
	
	//if (getdvarint("developer")>0){ return; }
	//if(self.isbot){ return; }
	
	for(;;){
		level waittill( "connecting", player );
		player thread _connecting();
		wait 0.05;
	}
}

_player_spawn_loop(){
	self endon ( "disconnect" );
	//self endon ( "death" );
	self endon( "intermission" );
	self endon( "game_ended" );
	//if (!getdvarint("developer")>0){ return; }
	//if(self.isbot){ return; }
	
	self.bombPing=undefined;
	self setClientDvar( "v01d_tools_bp", 1 );
	self.firingXP=0;
	self.isBlurrying=undefined;
	
	for(;;){
		self waittill("spawned_player");	

		//cl("^3"+self.name+" spawned");

		self thread _useSoldier();
		self thread _changeBotWeapon();
		//self thread _bots_use_artillery();
		self thread _hudMarkers_show();
        //self thread _sco_marker_add();
        //self thread _sco_marker_remove();
        //self thread _sco_show_markers();
        //self thread _marker();
        self thread _reload_monitor();
        self thread _recoil();
        self thread _aim_mod();
        self thread _moving();
		//self thread _suicide(5);
		//self thread _law_pickup();
		self thread _m16_pickup();
		self thread _mobile_phone();
		self thread _push();
		self thread _stopADS();
		self thread _cg_cmds();
		self thread _use_disable_weapons();
		self thread _movement_accel_decel();
		self thread _give_knife(0.5);
		self thread _knife_hit();
		self thread _explosives_pickup();
		//self thread _bot_explosives_pickup();
		self thread _weapon_cock_sound();
		self thread _player_mouse();
		self thread _hp_weapons_list();
		self thread _cancel_reload_when_jumping();
		
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
		
		//if(isDefined(game["botPlayers"])){ setDvar("bots_manage_fill", game["botPlayers"]+1-game["realPlayers"]); }
		//self.alpha=0;
		//wait 20;
		//self.alpha=1;
		self takeWeapon("briefcase_bomb_mp");
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
			//thread playsoundinspace( "artillery_impact", traceHit );		
		}
		while(self UseButtonPressed()){	wait 0.05; }
		wait 0.05;
	}
}

_dev_test_clcmds(){
	//self setClientDvar("ui_ShowMenuOnly", "none");
	//self scripts\menus::_create_menu_bg("hudWelcomeBG","CENTER","TOP",100,100,0,0,(1,1,1),1,1,"black",50,"fullscreen","fullscreen");
	self _film_tweaks(1,0.05,"1 0.6 0.6","1 0.6 0.6",0.6,1,1,0,1);
	//self _film_tweaks(0,0,"1 1 1","1 1 1",0.4,1,1,0,1.4);
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
		//return vd;
	}
}

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
		//cl("11self.proxBar ended");
	}
}

_explosives_pickup(){
	self endon ( "disconnect" );
	self endon ( "death" );
	self endon( "intermission" );
	self endon( "game_ended" );
	//if (!getdvarint("developer")>0){ return; }
	
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
	//cl("33self.haveClaymores:"+self.haveClaymores);
	//cl("33clays max ammo:"+weaponMaxAmmo("claymore_mp"));
	//cl("33getAmmoCount:"+self getAmmoCount("claymore_mp")); 

	//self SetWeaponAmmoClip("claymore_mp",self.haveClaymores);
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
			}
			if (c>0 && pickedUp==false){ 
				self.inUse = false;
				//cl("11not picked up"); 
				c=20; wait 0.2;
			}
		}
		while( self UseButtonPressed() ){ wait 0.05; }
		wait 0.05;
	}
}

_explosives_array(){
	level endon ( "disconnect" );
	level endon( "intermission" );
	level endon( "game_ended" );
	//if (!getdvarint("developer")>0){ return; }
	
	for(;;){
		c=0;
		for(i=0;i<level.claymoreArray.size;i++){
			if (isDefined(level.claymoreArray[i]) && !isDefined(level.claymoreArray[i].detonated)){ 
				//_arr_remove(level.claymoreArray,level.claymoreArray[i]); break; 
				c++;
			}
		}
		//cl("33clayarr size:"+c);
		wait 1;
	}
}

_bot_explosives_pickup(){
	self endon ( "disconnect" );
	self endon ( "death" );
	self endon( "intermission" );
	self endon( "game_ended" );
	//if (!getdvarint("developer")>0){ return; }
	
	if(!self.isbot){ return; }
	
	wait 0.5; delay=0.5; pickedUp=false;
	//cl("33self.haveClaymores:"+self.haveClaymores);
	//cl("33clays max ammo:"+weaponMaxAmmo("claymore_mp"));
	//cl("33getAmmoCount:"+self getAmmoCount("claymore_mp")); 

	//self SetWeaponAmmoClip("claymore_mp",self.haveClaymores);
	for(;;){
		c=20;
		if(self.pers["team"] != "spectator"){
			//pickedUp=false;
			botAngles = self GetPlayerAngles();
			startPos = self getEye();
			startPosForward = startPos + anglesToForward((botAngles[0],botAngles[1],0))*1200;
			trace = bulletTrace(startPos,startPosForward,true,self);
			pos = trace["position"];
			//ent = trace["entity"];
			if(isDefined(pos)){
				//cl("33c:"+c);
				delay=0.05;
				closest = 2147483647; nr=undefined; dist=undefined;
				for(i=0;i<level.claymoreArray.size;i++){
					if(isDefined(level.claymoreArray[i].origin)){
						dist = distance(pos,level.claymoreArray[i].origin); 
					}
					if(isDefined(dist) && dist<32){ 
						nr=i; 
						if(c>=20){ self thread _progress_bar(1000,0,1); }
					}
				}
				if(isDefined(nr) && c<=0){ 
					//self.claymorearray[nr] notify("death");
					self.claymorearray[nr] delete();
					wait 0.05;
					level.claymoreArray = _arr_remove(level.claymoreArray,level.claymoreArray[nr]);
					self.inUse = false;
					self GiveWeapon("claymore_mp");
					self SwitchToWeapon("claymore_mp");
					self playSound("weap_pickup");
					wait 0.1;
					//self.haveClaymores+=1;
					//self SetWeaponAmmoClip("claymore_mp",self.haveClaymores);
					//self SetWeaponAmmoStock("claymore_mp",self.haveClaymores);
					//cl("55claymore arr size:"+self.claymorearray.size); 
					//cl("55closest claymore nr:"+nr); 
					//cl("55getAmmoCount:"+self getAmmoCount("claymore_mp")); 
					pickedUp=true;
					c=20;
					delay=0.5;
					wait 0.5;
				}
			}	
			c--; wait 0.05; 
		}
		if (c>0 && pickedUp==false){ 
			self.inUse = false;
			//cl("11bot not picking up explosive"); 
			c=20; wait 0.2;
		}
		wait delay;
	}
}

_hp_weapons_list(){
	self endon ( "disconnect" );
	self endon ( "death" );
	self endon ( "game_ended" );
	self endon ( "intermission" );

	if(self.isbot){ return; }
	while(1){
		if(isDefined(self.pers["hardPointItem"])){
			if(self.pers["hardPointItem"] == "radar_mp"){ self setClientDvar( "ui_uav_client", 1 ); } else { self setClientDvar( "ui_uav_client", 0 ); }
			if(self.pers["hardPointItem"] == "airstrike_mp"){ self setClientDvar( "ui_airstrike_client", 1 ); } else { self setClientDvar( "ui_airstrike_client", 0 ); }
			if(self.pers["hardPointItem"] == "helicopter_mp"){ self setClientDvar( "ui_helicopter_client", 1 ); } else { self setClientDvar( "ui_helicopter_client", 0 ); }
			if(self.pers["hardPointItem"] == "artillery_mp"){ self setClientDvar( "ui_artillery_client", 1 ); } else { self setClientDvar( "ui_artillery_client", 0 ); }
		}
		//if (self getAmmoCount("radar_mp")>0){ self setClientDvar( "ui_uav_client", 1 ); } else { self setClientDvar( "ui_uav_client", 0 ); }
		//if (self getAmmoCount("airstrike_mp")>0){ self setClientDvar( "ui_airstrike_client", 1 ); } else { self setClientDvar( "ui_airstrike_client", 0 ); }
		//if (self getAmmoCount("helicopter_mp")>0){ self setClientDvar( "ui_helicopter_client", 1 ); } else { self setClientDvar( "ui_helicopter_client", 0 ); }
		//if (self getAmmoCount("artillery_mp")>0){ self setClientDvar( "ui_artillery_client", 1 ); } else { self setClientDvar( "ui_artillery_client", 0 ); }
		wait 0.5;
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

_round_time_passed(){
	level endon("disconnect");
	level endon("intermission");
	level endon("game_ended");
	for(;;){
		level.tp = int((gettime() - level.st)/1000);
		//cl("22level.tp:"+level.tp);
		wait 1;
	}
}

_give_knife(delay){
	self endon ( "disconnect" );
	self endon ( "death" );
	self endon( "intermission" );
	self endon( "game_ended" );
	if(self.isbot){ return; }
	
	if(!isDefined(delay)){ delay=1; }
	wait 1;
	//self takeAllWeapons();
	while(1){
		wait delay;
		giveKnife=true;
		weaponsList = self GetWeaponsList();
		ammoList=[];
		cw=self GetCurrentWeapon();
		//cl("44"+cw);
		if(isDefined(weaponsList) && !self IsOnLadder() && !self IsMantling() && !isDefined(self.buyMenuShow)){
			for(i=0;i<weaponsList.size;i++){
				//if(weaponsList[i]==cw){ break; }
				ammoList[i] = self getAmmoCount(weaponsList[i]);
				if(ammoList[i]>0 && cw != "knife_mp"){ self takeWeapon("knife_mp"); giveKnife=false; break; }
			}
			if(giveKnife || cw == "none"){
				self GiveWeapon("knife_mp");
				//self SwitchToWeapon("knife_mp"); 
				//cl("33switched"); 
				while(self GetCurrentWeapon()=="knife_mp"){ 
					wait 0.3; 
					//cl("33"+self GetCurrentWeapon()); 
				}
				giveKnife=false;
			}
		}
	}
}

_knife_hit(){
	self endon ( "disconnect" );
	self endon ( "death" );
	self endon( "intermission" );
	self endon( "game_ended" );
	if(self.isbot){ return; }

	for(;;){
		if(isAlive(self)){
			self waittill("weapon_fired");
			//cl("11fired");
			wait 0.2;
			weapon = self GetCurrentWeapon();
			if(weapon != "knife_mp"){ return; }
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
				ent FinishPlayerDamage(self, self, 150, 0, "MOD_MELEE", "knife_mp",(0,0,0),(0,0,0),"j_torso",0);
				cl("11"+self.name+" knifed "+ent.name);
			}
			wait 0.5;
		}
		wait 0.05;
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
			else{ 
				//self playLocalSound("rifle_cock"); 
			} 
			//cl("11fired");
		}
		wait 0.1;
	}
}

_cg_cmds(){
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
	//self setClientDvar("r_dof_tweak", 1);
	//self setClientDvar("ui_uav_client", 1); 
	self setClientDvar("m_pitch",0.022);
	self setClientDvar("m_yaw",0.022);
	self setClientDvar("stopSpeed",100);
	self setClientDvar("ui_showmap",1);
	//self setClientDvar("ui_uav_axis",1);
	//self setClientDvar("ui_uav_allies",1);
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

getClientDvar(dvar){
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

_maps_randomizer(){
	level endon ( "disconnect" );
	//level endon( "intermission" );
	//level endon( "game_ended" );
	wait 2;
	//setDvar("scr_sab_scorelimit",2);
	//setDvar("scr_sab_numlives",1);
	filename="sv_maps.cfg";
			
	if(FS_TestFile(filename) && game["mapList"].size<1){ 
		csv = FS_FOpen(filename, "read");
		line = FS_ReadLine(csv);
		while (isDefined(line) && line != ""){
			//cl("^3line: " + line);
			if (line == "") { continue; }
			if (isSubStr(line,"map")){ break; }
			line = FS_ReadLine(csv);
		}
		FS_FClose(csv);
		line = StrRepl(line, "set sv_mapRotation ", "");
		line = StrRepl(line, "\"", "");
		line = StrRepl(line, "map ", "");
		//cl("11"+line);
		game["mapList"] = strTok(line," ");
	}
	level.mapList = game["mapList"];
	if(isDefined(level.mapList)){
		//cl("33last map:"+level.mapList[level.mapList.size-1]);
		n=randomIntRange(0,level.mapList.size);
		level.nextMap = level.mapList[n];
		if (game["nextMap"] == game["prevMap"]){ game["nextMap"]=level.nextMap; }
		cl("22next map: "+game["nextMap"]);
		//wait 10;
		level waittill("game_ended");
		//cl("11_maps_randomizer-game_ended");
		if(level.teamBased && (maps\mp\gametypes\_globallogic::hitRoundLimit() || maps\mp\gametypes\_globallogic::hitScoreLimit())){
			cl("33_maps_randomizer-hitScoreLimit");
			game["prevMap"]=game["nextMap"];
			cl("33_maps_randomizer-waiting for end_killcam");
			level waittill("end_killcam"); 
			cl("33_maps_randomizer-fk ended");			
			cl("22next map: "+game["nextMap"]);
			if(getDvar("g_gametype")!="sab"){ setDvar("g_gametype","sab"); }
			for(i=0;i<level._gametypes.size;i+=2){ 
				if(level._gametypes[i]==game["nextMap"]){ 
					setDvar("g_gametype",level._gametypes[i+1]); 
					cl("33g_gametype will be \""+level._gametypes[i+1]+"\"");
					break; 
				}
				//else{ setDvar("g_gametype","sab"); }
			}
			//game["teamWonRound"]=undefined;
			wait getDvarFloat( "scr_intermission_time" )-1.5;
			exec("map " + game["nextMap"]+" 0");
			game["nextMap"]="";
		}
	}
}

_movement_accel_decel(){
	self endon ( "disconnect" );
	self endon ( "death" );
	self endon( "intermission" );
	self endon( "game_ended" );
	//if (!getdvarint("developer")>0){ return; }
	//if(self.isbot){ return; }
	c=0.3;
	for(;;){
		while(isAlive(self) && self.isReloading==false){
			mss=0.1;
			self setMoveSpeedScale(mss);
			while (self ForwardButtonPressed() || self BackButtonPressed() || self MoveLeftButtonPressed() || self MoveRightButtonPressed()){ self setMoveSpeedScale(mss); wait 0.05; if(mss<1){ mss+=0.10; }}
			//while (self ForwardButtonPressed()){ self setMoveSpeedScale(mss); wait 0.05; if(mss<1){ mss+=0.10; }}
			//while (self BackButtonPressed()){ self setMoveSpeedScale(mss); wait 0.05; if(mss<1){ mss+=0.10; }}
			//while (self MoveLeftButtonPressed()){ self setMoveSpeedScale(mss); wait 0.05; if(mss<1){ mss+=0.10; }}
			//while (self MoveRightButtonPressed()){ self setMoveSpeedScale(mss); wait 0.05; if(mss<1){ mss+=0.10; }}
			//else { self setMoveSpeedScale(mss); if(mss>0.1){ mss-=0.1; cl("^3"+self.name+" is decel"); }}
			wait 0.05;
			//waittillframeend;
		}
		wait 0.05;
	}
}

_use_disable_weapons(){
	self endon ( "disconnect" );
	self endon ( "death" );
	self endon( "intermission" );
	self endon( "game_ended" );
	//if (!getdvarint("developer")>0){ return; }
	if(self.isbot){ return; }
	if(getDvar("g_gametype") != "sab"){ return; }
	axisBombSite=getEnt("sab_bomb_axis", "targetname");
	alliesBombSite=getEnt("sab_bomb_allies", "targetname");
	for(;;){
		while (!self UseButtonPressed()){ wait 0.05; }
		//if(self GetCurrentWeapon() == "briefcase_bomb_mp" || self GetCurrentWeapon() == "briefcase_bomb_defuse_mp"){ cl("!"); continue; }
		if(distance(axisBombSite.origin,self.origin)<64 || distance(alliesBombSite.origin,self.origin)<64){ wait 0.05; }
		else{ self DisableWeapons(); }
		//cl(distance(axisBombSite.origin,self.origin));
		//cl(distance(alliesBombSite.origin,self.origin));
		while (self UseButtonPressed()){ wait 0.05; }
		self EnableWeapons();
	}
}

_menu_response()
{
	self endon ( "disconnect" );
	//self endon ( "death" );
	self endon( "intermission" );
	self endon( "game_ended" );
	if(self.isbot){ return; }
	
	for(;;)
	{
		self waittill("menuresponse", menu, response);
		//self getclientdvar("com_maxfps");
		cl("^3"+self.name+": menu:"+menu+" | response: "+response);
		//cl("^3"+self.name+": response:"+response);
		if(response == "axis" || response == "allies" || response == "autoassign")
		{
			//self notify("hasReadWelcomeMsg");
			game["hasReadMOTD"][self.name]=true;
			game["isJoinedSpectators"][self.name]=false;
			//cl("33game[isJoinedSpectators][self.name]: " + game["isJoinedSpectators"][self.name]);
			self suicide();
			self.sessionteam=self.pers["team"];
			self thread _fs();
			self thread maps\mp\gametypes\_spectating::setSpectatePermissions();
			self notify("hasReadWelcomeMsg");
			self notify("hasReadMOTD");
			self notify("hasPressedFButton");
			self notify("readyToPressAccept");
			//self notify("menuresponse", game["menu_changeclass"], "custom"+(1));
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
			//cl("33game[isJoinedSpectators][self.name]: " + game["isJoinedSpectators"][self.name]);
			self suicide();
			//self [[level.spectator]]();
			self.pers["team"]=self.isInTeam;
			self.sessionteam=self.isInTeam;
			self.sessionstate = "spectator";
			self thread maps\mp\gametypes\_spectating::setSpectatePermissions();
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
		
		//if(isSubStr(response, "v01d_taunts") && isAlive(self)){
		if(isSubStr(response, "v01d_taunts") && isAlive(self)){
			if(self.pers["team"]=="axis"){ 
				//self notify("menuresponse", "-1", "ESC");
				self playSound(self.bc); 
				self thread _head_icon();
				//cl("!!!");
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
	//self endon ( "death" );
	self endon( "intermission" );
	self endon( "game_ended" );
	if(getDvar("g_gametype") != "sab"){ return; }
	if(isDefined(self.bombPing)){ return; }
	else {
		self.bombPing=true; self playSound("bombping"); alpha=1;
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

_playSoundInSpace(alias,origin,delay,listener){
	org = spawn( "script_origin", origin );
	org.origin = origin;
	//cl("^2scr");
	wait delay;
	if(isDefined(listener)){ org playSoundToPlayer(alias,listener); }
	else { org playSound(alias); }
	wait 1; // MP doesn't have "sounddone" notifies =(
	org delete();
}

_blast(delay,dist,maxDist,blastOrigin,attacker,inflictor){
	x = self.origin[0]-blastOrigin[0];
	y = self.origin[1]-blastOrigin[1];
	z = maxDist-dist;
	//z = 100+10*(maxDist/dist);
	//cl("name:"+self.name+" x:"+x+" y:"+y);
	if(!isDefined(attacker)){ attacker = self; }
	if(isDefined(delay)){
		wait 0.05+(delay/2);
		//wait 0.05+(0.3*(dist/maxDist));
		if (isDefined(self.blastName) && isAlive(self)) {
			//cl("blastName: "+self.blastName); 
			if (isAlive(self) && self.blastName != "flash_grenade_mp"  || self.blastName != "smoke_grenade_mp") { 
				RadiusDamage(blastOrigin, maxDist/2, 20, 1, attacker); 
				//self FinishPlayerDamage(inflictor, attacker, int(z), 0, "MOD_GRENADE_SPLASH", self.blastName,(0,0,0),(0,0,0),"j_torso",0);
				//level thread _playSoundInSpace("distboom",blastOrigin,delay*2,self);
				self thread _flash("blur",3*(dist/maxDist)*2,0,1,3*(dist/maxDist)); //type,amp,dur,t1,t2
				//if(isDefined(inflictor)){ playSoundinSpace("distboom",blastOrigin); }
			}
			//self FinishPlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime );
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
			self.blastName = undefined;
		}
		//vectorToAngles
	}
}

_projectiles_owner(){
	self endon ( "disconnect" );
	//self endon ( "death" );
	self endon( "intermission" );
	self endon( "game_ended" );
	//if (!getdvarint("developer")>0){ return; }
	//if(self.isbot){ return; }
	
	for(;;){
		self waittill( "weapon_fired" );
		//self thread _flash("blur",2,0,1,0.1); //type,amp,dur,t1,t2
		wname = self GetCurrentWeapon();
		self.firedProjectile=wname;
		//self.grenade=w;
		if(wname == "rpg_mp" || wname == "law_mp" || wname == "at4_mp" || wname == "em1_mp"){
			//cl(self.name+" fired "+ wname);
			projectiles = getentarray( "rocket", "classname" );
			self.projectile = projectiles[projectiles.size-1];
			self.blastName = "rocket";
			if(wname == "em1_mp"){ 
				//self.projectile playLoopSound("em1_el_loop"); 
				self.blastName = "electric";
				self.projectile playSound("em1_el_zap"); 
			}
			self thread _projectiles_monitor(self.projectile,wname);
		}
		wait 0.05;
	}
}

_projectiles_monitor(weap,wname){
	//if(isDefined(self.projectile)) { cl(self.name+" has projectile: "+self.projectile.size); }
	
	blastOrigin = undefined;
	//name = self.name;
	attacker = self;
	w = attacker GetCurrentWeapon();
	
	while(isDefined(weap)){ blastOrigin = weap.origin; wait 0.05; }
	//cl("projectile ended");
	//weap waittill( "explode", blastOrigin );
	//cl("^1grenade owner released: "+name);
	//cl("^1projectile exploded by "+attacker.name);
	//cl("^1"+wname+" projectile exploded by "+attacker.name);
	
	if (isDefined(blastOrigin)) {
		//cl("^2"+origin);
		players = getentarray( "player", "classname" );
		//level thread _playSoundInSpace("distboom",blastOrigin,0.7);
		for( i = 0 ; i < players.size ; i++ )
		{
			dist = distance(blastOrigin, players[i].origin);
			maxDist = 800;
			if(dist<maxDist){
				//cl("^2"+players[i].blastName);
				delay = 0.1*(dist/maxDist);
				players[i] thread _playSoundInSpace("distboom",blastOrigin,0.05,players[i]);
				if(w == "em1_mp"){ 
					dist /= 4;
					maxDist /= 4;
					if(isDefined(weap)){ weap playSound("em1_el_zap"); }
				}
				players[i] thread _blast(delay,dist,maxDist,blastOrigin,attacker,weap);
				earthquake( 0.5, 0.75, blastOrigin, 1000 );
				earthquake( 0.1, 3.7, blastOrigin, 3500 );
				//players[i] setVelocity(0,0,400);
			}
		}
	}
}

/* _projectile_blast(delay,dist,maxDist,blastOrigin,attacker){
	x = self.origin[0]-blastOrigin[0];
	y = self.origin[1]-blastOrigin[1];
	z = maxDist-dist;
	//z = 100+10*(maxDist/dist);
	//cl("name:"+self.name+" x:"+x+" y:"+y);
	if(isDefined(delay)){
		wait 0.05+delay;
		//wait 0.05+(0.3*(dist/maxDist));
		if (isDefined(self.blastName)) {
			//cl("blastName: "+self.blastName); 
			RadiusDamage( blastOrigin, maxDist, 32, 1, attacker);
			//self FinishPlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime );
			if (self.blastName == "rocket"){ self setVelocity((x,y,z)); }
			self.blastName = undefined;
		}
		//vectorToAngles
	}
} */

_grenade_owner(){
	self endon( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	//self endon( "death" );
	//if(!self.isbot) {return;}

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
			//cl("health: "+self.health);
			//cl("maxhealth: "+self.maxhealth);
			//self waittill ( "missile_fire", missile, weaponName ); <----- ballistic knife, rpg
			//cl(self.name+" throwed "+ wname);
			self.grenade = w;
			w.owner = self;
			self.firedGrenade=wname;
			self.blastName = wname;
			//cl("^1blastName: "+weapname);
			w thread _grenade_monitor(w);
		}
		wait 0.5;
	}
}

_grenade_monitor(weap){
	name = weap.owner.name;
	attacker = weap.owner;
	blastOrigin = undefined;
	//cl("^1grenade owner: "+name);
	//while(isDefined(weap)){ blastOrigin = weap.origin; wait 0.1; }
	weap waittill( "explode", blastOrigin );
	//cl("^1grenade owner released: "+name);
	//cl("^1grenade exploded by "+attacker.name);
	
	if (isDefined(blastOrigin)) {
		//cl("^2"+origin);
		players = getentarray( "player", "classname" );
		//level thread _playSoundInSpace("distboom",blastOrigin,0.7);
		for( i = 0 ; i < players.size ; i++ )
		{
			dist = distance(blastOrigin, players[i].origin);
			maxDist = 600;
			delay = 0.3*(dist/maxDist);
			players[i] thread _playSoundInSpace("distboom",blastOrigin,0.05,players[i]);
			if(dist<maxDist){
				//cl("^2"+players[i].blastName);
				players[i] thread _blast(delay,dist,maxDist,blastOrigin,attacker,self.grenade);
				earthquake( 0.3, 0.75, blastOrigin, 1000 );
				earthquake( 0.1, 3.7, blastOrigin, 3000 );
				//players[i] setVelocity(0,0,400);
			}
		}
	}
}

_bomb_monitor(){
	level endon( "disconnect" );
	level endon( "intermission" );
	level endon( "game_ended" );
	//self endon( "death" );
	//if(!self.isbot) {return;}
	if(getDvar("g_gametype") != "sab"){ return; }
	blastOrigin = undefined;
	
	for(;;){
		while (level.bombExploded != true) { blastOrigin=level.sabBomb.curOrigin; wait 0.05; }
		//cl("^1bomb exploded");
		players = getentarray( "player", "classname" );
		for( i = 0 ; i < players.size ; i++ )
		{
			dist = distance(blastOrigin, players[i].origin);
			maxDist = 1200;
			delay = 0.3*(dist/maxDist);
			players[i] thread _playSoundInSpace("distboom",blastOrigin,0.05,players[i]);
			if(dist<maxDist){
				//cl("^2"+players[i].blastName);
				players[i].blastName="bomb";
				players[i] thread _blast(delay,dist,maxDist,blastOrigin,undefined);
				earthquake( 0.5, 1.75, blastOrigin, 1000 );
				earthquake( 0.2, 3.7, blastOrigin, 4800 );
				//players[i] setVelocity(0,0,400);
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
					//level thread _playSoundInSpace("distboom",mortar.origin,0.7);
					//cl("^1mortars last entry: "+entnums[entnums.size-1]); 
					last = entnums[entnums.size-1];
					mortar=undefined;
				}
			}
			wait 0.2;
		}
		//cl("^1no mortars"); entnums=[];
		wait 0.05;
	}
}

_artillery_mortarshell(){
	blastOrigin=undefined;
	entnum=self getEntityNumber();
	while (isDefined(self)) { blastOrigin=self.origin; wait 0.05; }
	//cl("^3incoming: "+entnum);
	players = getentarray( "player", "classname" );
	for( i = 0 ; i < players.size ; i++ )
	{
		dist = distance(blastOrigin, players[i].origin);
		maxDist = 1200;
		delay = 0.3*(dist/maxDist);
		players[i] thread _playSoundInSpace("distboom",blastOrigin,0.05,players[i]);
		if(dist<maxDist){
			//cl("^3blastOrigin: "+blastOrigin);
			players[i].blastName="mortars";
			players[i] thread _blast(delay,dist,maxDist,blastOrigin,undefined);
			//players[i] setVelocity(0,0,400);
		}
	}
}

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
	//self setPerk("specialty_specialgrenade");
	//self setPerk("specialty_specialgrenade");
	//self setClientDvar( "ui_uav_client", 1 );
	//self setClientDvar( "ui_airstrike_client", 1 );
	//self setClientDvar( "ui_helicopter_client", 1 );
	//self setClientDvar( "ui_artillery_client", 1 );
	
	if (self.isbot) { 
		wait 0.05;
	} else {	
		self playLocalSound( "hello1" );
		//cl("^3hello1");
		//self takeAllWeapons();
		//self GiveWeapon( "cell_mp" );	
		//self setSpawnWeapon("cell_mp");
	}
	
	//self setClientDvars("cg_thirdperson", 1); 
    //self iprintlnbold("Laipni lugts " + self.name); // Writes the welcome message bold and centered on the player's screen.
		
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
	//self thread _bc();
	
	if (game["_t_m_"] > 13) { game["_t_m_"]=1; }
	if (game["_ct_m_"] > 5) { game["_ct_m_"]=1; }

    
    wait 1;
    if (self.pers["lives"] > 0 && self.pers["team"] != "spectator" ) { self iprintln("^2You have " + (self.pers["lives"]+1) + " lives\n"); }	

	//wait 2; self openMenu( game["menu_eog_unlock"] );
}

_bc()
{
	level endon( "disconnect" );
	//self endon( "intermission" );
	//self endon( "game_ended" );
	//self endon( "death" );
	//if(!self.isbot) {return;}
	//wait randomIntRange(2, 120);

	for(;;){
		players = getentarray( "player", "classname" );
		if(players.size>0){
			i=randomIntRange(0,players.size);
			if (isAlive(players[i]) && players[i].isbot && isDefined(players[i].bc)){
				players[i] playSound("stop_voice");
				switch (players[i].pers["team"]){
				case "axis":
					players[i] playSound(players[i].bc);
					//players[i] playSound( players[i].bc + randomIntRange(1, 6)); 
					//cl("^2players[i].bc: "+i);
					break;
				case "allies":
					//players[i] playSound( players[i].bc + randomIntRange(1, 5)); 
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
	//self endon( "death" );
	self endon( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );

	for(;;){
		//self waittill("spawned_player");
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
				//self playSound( self.ds + randomIntRange(1, 14)); 
				break;
			case "axis":
				self playSound(self.ds);
				//self playSound( self.ds + randomIntRange(1, 5)); 
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
	//self endon( "death" );
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
					//self playSound( self.ps + randomIntRange(1, 10)); 
					break;
				case "axis":
					self playSound(self.ps);
					//self playSound( self.ps + randomIntRange(1, 4)); 
					break;
				default:
					break;
				} 
				self thread _bs(); 
				wait randomFloatRange(0.7, 2.0);
				self.ps_ended = true;
			}
		}
	}
}

_disable_weapons_on_hit(t){
	self DisableWeapons();
	wait t;
	self EnableWeapons();
}

_bs()
{
	self endon("death");
	self endon("disconnect");
	self endon( "game_ended" );

	player = self;
	healthcap = player.health;
	//print(healthcap + "\n");
	
	for (;;)
	{
		//self endon("death");
		wait 1.2;
		if (player.health <= 0)
			return;

		// Player still has a lot of health so no breathing sound
		if (player.health >= healthcap)
			continue;

		if ( level.healthRegenDisabled && gettime() > player.breathingStopTime )
			continue;

		if ( level.gametype != "ftag" || !self.freezeTag["frozen"] )
			player stopLocalSound("breathing_hurt");	
			switch ( self.pers["team"] ) {
			case "allies":
				player playSound("ct_crawl");
				//player playLocalSound("ct_crawl" + randomIntRange(1,4)); 
				//player playSound("ct_crawl" + randomIntRange(1,4)); 
				break;
			case "axis":
				player playSound("t_crawl");
				//player playLocalSound("t_crawl" + randomIntRange(1,4)); 
				//player playSound("t_crawl" + randomIntRange(1,4)); 
				break;
			default:
				break;
			}
		//wait .784;
		self.ps_ended = false;
		if(self.pers["team"]=="axis"){ wait 1.1 + randomfloat (0.8); }
		if(self.pers["team"]=="allies"){ wait 3.1 + randomfloat (2.8); }
		self.ps_ended = true;
	}

	//self [[level.originalplayerBreathingSound]](healthcap);
	wait 0.10;
}

_sfx(s)
{
	players = getentarray( "player", "classname" );
	wait (0.20);
	for( i = 0 ; i < players.size ; i++ )
	{
		//if( self != players[i] ){
			players[i] playLocalSound (s);
			//self playLocalSound ( s );
		//}
	}
	//print(s + "\n");
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
				//cl("alive: "+playersCountAllies);
			}
		}
		else if(opts == "real"){
			for( i = 0 ; i < players.size ; i++ ){
				if(!players[i].isbot && players[i].pers["team"] != "spectator"){
					playersCount++;
				}
			}
			game["realPlayers"]=playersCount;
			//level.realPlayers=game["realPlayers"];
			//cl("realPlayers: "+game["realPlayers"]);
		}
	}

	players["all"] = playersCount;
	players["axis"] = playersCountAxis;
	players["allies"] = playersCountAllies;
	return players;
}

_teamWatcher(){
	level endon("disconnect");
	level endon("game_ended");
	
	//level waittill("game_ended");
	cl("11_teamWatcher");
	//while(level.playerLives["axis"]>0 && level.playerLives["allies"]>0){ wait 0.5; }
	while(level._teamEliminated != true){ wait 0.5; }
	if(level.playerLives["axis"]<1){ [[level._setTeamScore]]( "allies", [[level._getTeamScore]]( "allies" ) + 1 ); } 
	else if(level.playerLives["allies"]<1){	[[level._setTeamScore]]( "axis", [[level._getTeamScore]]( "axis" ) + 1 ); }
}

_tiebreaker(){
	level endon("disconnect");
	level endon("game_ended");
	while (!level.inOvertime) { wait 1; }
	cl("^5watching alive players");
	players = getentarray( "player", "classname" );
	for(i=0;i<players.size;i++){ players[i].pers["lives"]=0; }
	while (level.inOvertime && !level.stopScore)  { 
		//alivePlayers=_chk_players("alive");
		//cl("11alive axis:"+alivePlayers["axis"]);
		//cl("55alive allies:"+alivePlayers["allies"]);
		//while (level.playerLives["allies"]>0 && level.playerLives["axis"]>0){ wait 0.5; }
		//level.noOneIsAlive=true;
		if(level.playerLives["axis"]<1){
		//if(alivePlayers["axis"]<1){
			[[level._setTeamScore]]( "allies", [[level._getTeamScore]]( "allies" ) + 1 );
			thread maps\mp\gametypes\_finalkillcam::endGame( "allies", game["strings"]["axis_eliminated"] );
			//thread maps\mp\gametypes\_globallogic::endGame( "allies", game["strings"]["axis_eliminated"] );
			//while (level.playerLives["axis"]<1) { wait 1; }
			break;
		} else if(level.playerLives["allies"]<1){
		//} else if(alivePlayers["allies"]<1){
			[[level._setTeamScore]]( "axis", [[level._getTeamScore]]( "axis" ) + 1 );
			thread maps\mp\gametypes\_finalkillcam::endGame( "axis", game["strings"]["allies_eliminated"] );
			//thread maps\mp\gametypes\_globallogic::endGame( "axis", game["strings"]["allies_eliminated"] );
			//while (level.playerLives["allies"]<1) { wait 1; }
			break;
		}
		wait 1;
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
	//if(!isAlive(self)){ return; }
	if(!isDefined(t)){ t=1; };
	if(self.name == "v01d"){
		while(!isAlive(self)){ wait 0.1; }
		while(t>0){
			if (self MeleeButtonPressed()) {
				cl(":/");
				//self notify("menuresponse", game["menu_team"], "spectator");
				wait 0.1;
				self suicide();
				//self [[level.autoassign]]();
				self closeMenu();
				self closeInGameMenu();
				break;
			} 
			t-=0.1;
			wait 0.1;
		}
	}
}

_killed(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration){

	//cl("33MOD: "+sMeansOfDeath);
	//cl("33sWeapon: "+sWeapon);
	//cl("33eInflictor: "+eInflictor.classname);
	
	self setClientDvar("m_pitch",0.022);
	self setClientDvar("m_yaw",0.022);
	self SetClientDvar("ui_ShowMenuOnly", "");
	
	self setMoveSpeedScale(1);
	
	self.haveC4=0;
	self.haveClaymores=0;
	self.haveFragGrenades=0;
	self.haveConcussionGrenades=0;
	self.haveFlashGrenades=0;
	self.haveSmokeGrenades=0;
	//self.firingXP=0;
	
	self thread _unlink_veh();

	if(isDefined(eInflictor)){	
		dist = distance(self.origin,eInflictor.origin)+1;
		x = self.origin[0]-eInflictor.origin[0];
		y = self.origin[1]-eInflictor.origin[1];
		z = 100;
		//if(isDefined(eInflictor.classname)){ cl("^5eInflictor.classname: "+eInflictor.classname); }
		//if(isDefined(eInflictor.name)){ cl("^5eInflictor.name: "+eInflictor.name); }
		//if(isDefined(eInflictor.model)){ cl("^5eInflictor.model: "+eInflictor.model); }
		//if(isDefined(sWeapon)){ cl("^5sWeapon: "+sWeapon); }
		//if(isDefined(sMeansOfDeath)){ cl("^5sMeansOfDeath: "+sMeansOfDeath); }
		
		//if (sMeansOfDeath != "MOD_PROJECTILE_SPLASH" || sMeansOfDeath != "MOD_GRENADE_SPLASH"){
		if (!isSubStr(sMeansOfDeath,"PROJECTILE") || !isSubStr(sMeansOfDeath,"GRENADE")){
			self setVelocity((x/2,y/2,10)); 
		} else if (eInflictor.classname == "grenade" || eInflictor.classname == "rocket" && self GetStance() != "prone") {
			if (dist<500){
				z = 500-dist;
				self setVelocity((x,y,z)); 
			}
		} else if (eInflictor.model == "projectile_hellfire_missile") {
			if (dist<1000){
				z = 1000-dist;
				self setVelocity((x,y,z*2)); 
				sWeapon="airstrike_mp";
			}
		//} else if (eInflictor.model == "tag_origin" || sWeapon == "artillery_mp") {
		} else if (sWeapon == "airstrike_mp" || sWeapon == "artillery_mp") {
			z = 400;
			self setVelocity((x,y,z)); 
		} else if(sMeansOfDeath != "MOD_SUICIDE" && dist<5000){ 
			x = self.origin[0]-eAttacker.origin[0];
			y = self.origin[1]-eAttacker.origin[1];
			self setVelocity((x*(500/dist),y*(500/dist),z*(500/dist)*0.2+100));
			//self setVelocity((1000/(1+x*0.1),1000/(1+y*0.1),200)); 
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
	
	//if (isSubStr("c4", sWeapon)){  }
	//if (isDefined(classname)) { sWeapon=eAttacker.firedGrenade; eAttacker.firedGrenade=undefined; }
	//if (isDefined(eAttacker.firedGrenade)) { sWeapon=eAttacker.firedGrenade; eAttacker.firedGrenade=undefined; }
	//else if (isDefined(eAttacker.firedProjectile)) { sWeapon=eAttacker.firedProjectile; eAttacker.firedProjectile=undefined; }
	//else { sWeapon="c4_mp"; }
	
	if (isDefined(level.bombOwner) && level.bombExploded==true && isDefined(eAttacker) && level.bombOwner.name == eAttacker.name && isSubStr(sMeansOfDeath, "MOD_EXPLOSIVE")) { sWeapon="c4_mp"; }
	//cl("^1sWeapon: "+sWeapon);

	if (!isDefined(eAttacker)){
		if (sMeansOfDeath == "MOD_FALLING" || sMeansOfDeath == "MOD_IMPACT" || sMeansOfDeath == "MOD_SUICIDE" || sMeansOfDeath == "MOD_PROJECTILE_SPLASH" || sMeansOfDeath == "MOD_GRENADE_SPLASH") {
			sc = "suicide";	
			//sc = sc + randomIntRange(1, 10);
			thread _sfx(sc);
		//} else if (sMeansOfDeath == "MOD_SUICIDE" && !isDefined(self.lastStand) && self hasPerk("specialty_pistoldeath") == false && !isDefined(eAttacker)) {
		}
	} else if (isDefined(eAttacker)){ 
		//if(eInflictor.classname == "player"){ eAttacker thread _quick_killcam(self, self getEntityNumber(), eInflictor, sWeapon, eAttacker); }
		//cl(sWeapon); //cobra_20mm_mp
		//cl(eInflictor.classname); //script_vehicle
		//cl(eInflictor.name); //
		//cl("^2"+vDir); //
				
		self.kb = eAttacker;
		
		if(isPlayer(eAttacker) && sMeansOfDeath == "MOD_MELEE") //
		{	
			cl("knifed");
			if (!level.inOvertime == true) { 
				eAttacker.pers["lives"]+=1;
				if (eAttacker.team != self.team) { eAttacker iprintln("^2You earned 1 life!"); }
			}
			if(isDefined(game["money"][eAttacker.name])){ game["money"][eAttacker.name] += 100; }
			ks = "knife";	
			//ks = ks + randomIntRange(1, 7);
			thread _sfx ( ks );
		}
		else if (eAttacker == self){
			if (sMeansOfDeath == "MOD_FALLING" || sMeansOfDeath == "MOD_IMPACT" || sMeansOfDeath == "MOD_SUICIDE" || sMeansOfDeath == "MOD_PROJECTILE_SPLASH" || sMeansOfDeath == "MOD_GRENADE_SPLASH") {
				sc = "suicide";	
				//sc = sc + randomIntRange(1, 10);
				thread _sfx(sc);
			}
		}
		else if (isDefined(eAttacker.team) && eAttacker.team == self.team){  
			if (level.inOvertime == false) {
				eAttacker.pers["lives"]-=1; eAttacker iprintln("^1You lost live for team killing\n");
			}
			
			sc = "suicide";	
			//sc = sc + randomIntRange(1, 10);
			thread _sfx(sc);
		}
		
		if(isDefined(sMeansOfDeath) && sMeansOfDeath == "MOD_HEAD_SHOT"){ self.headShot=true; }
		if(isDefined(eAttacker.isbot) && eAttacker.isbot){ eAttacker.pers["bots"]["skill"]["aim_time"]=3; }
	}
	
	self StartRagdoll(0);
	
	if(!self.isbot && isDefined(eAttacker) && isAlive(eAttacker) && eAttacker.classname == "player" && level.showFinalKillcam == false){ 
		self thread _linkto(eAttacker,0.3, 3); 
	}

	//self finishPlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime );
	if(isDefined(level.originalcallbackPlayerKilled)){
		self [[level.originalcallbackPlayerKilled]](eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, timeOffset, deathAnimDuration);
	}
	
	//wait (0.10);
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
	//self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	if(self.isbot){ return; }
	
	self waittill ("begin_killcam");
	self unLink();
	cl("unlinked");
}

_mobile_phone()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	//if (!getdvarint("developer")>0){ return; }
	//if(self.isbot){ return; }
	
	for(;;){
		//self maps\mp\gametypes\_hardpoints::giveHardpointItem( "airstrike_mp" );
		weapon = self GetCurrentWeapon();
		if(weapon == "airstrike_mp" || weapon == "artillery_mp") { self playSound("mobile_beep"); }
		while(self GetCurrentWeapon() == weapon) { wait 0.05; }
		wait 0.5;
		}
}

_server_send_update(){
	level endon ( "disconnect" );
	if (getDvarInt("log_players")!=1){ return; }
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

_connecting(){
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
		//game["isConnecting"][name] SetClientDvar("ui_ShowMenuOnly", "none");
		//cl("realPlayers: "+(game["realPlayers"]-1));
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
			//[[level._setTeamScore]]( "axis", 0 ); 
			//[[level._setTeamScore]]( "allies", 0 ); 
			//thread maps\mp\gametypes\_globallogic::endGame( "tie", game["strings"]["tie"] );
			//Map_Restart(false);
		}
		wait 5;
	}
}

_dev_timescale(){
	self endon ( "disconnect" );
	//self endon ( "death" );
	self endon( "intermission" );
	self endon( "game_ended" );
	//if (!getdvarint("developer")>0){ return; }
	if(self.isbot){ return; }

	while(isAlive(self)){
		//m_pitch = self getUserInfo("setu m_pitch 1");
		//cl("33"+self.name+" m_pitch: "+m_pitch);
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
	//if (!getdvarint("developer")>0){ return; }
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
	//self endon( "intermission" );
	//self endon( "game_ended" );

	//if (!getdvarint("developer")>0){ return; }
	if (getdvarint("bots_main_debug")>0) { return; }  
	if(self.isbot){ return; }
	
	cl("33_dev_weapon_test on "+self.name);
	//setDvar( "testclients_doreload", true );
	//setDvar( "testclients_doreload", false );
	level.doNotAddBots=true;
	self.bodyModel=0;
	self.weaponModel=0;
	//give = "m1014_reflex_mp";
	//give+="_mp";
	weapons=strTok("m1014_reflex_mp,g3_reflex_mp,ak47_reflex_mp",",");
	models=strTok("body_mp_arab_regular_assault,body_mp_usmc_assault,body_mp_usmc_sniper",",");
	start=undefined; llb=undefined; lrb=undefined; hbb=undefined;
	wait 1;
	self.thirdPerson=false;
	//setDvar("dev","weap");
	level thread _add_some_bots(1);
	
	for(;;){
		if(!isDefined(self.bodyModel)){ self.bodyModel=0; }
		if(!isDefined(self.weaponModel)){ self.weaponModel=0; }
		if(self LeanLeftButtonPressed()){ llb=true; start=true; }
		if(self LeanRightButtonPressed()){ lrb=true; start=true; }
		if(self HoldBreathButtonPressed()){ hbb=true; start=true; }
		players = getentarray( "player", "classname" );
		if(isDefined(start)){
			if(isDefined(hbb)){
				if(self.thirdPerson==false){ self setClientDvars("cg_thirdperson", 1); self.thirdPerson=true; }
				else{ self setClientDvars("cg_thirdperson", 0); self.thirdPerson=false; }
				
				hbb=undefined;
			}
			for(i=0;i<players.size;i++){
				if (isAlive(self) && !isDefined(self.buyMenuShow)){
					if(players[i].isbot){ players[i].bot.stop_move=true; }
					weapon = players[i] GetCurrentWeapon();
					//if(isDefined(llb)){ players[i].bodyModel++; }
					//if(isDefined(lrb)){ players[i].weaponModel++; }
		 			if (isDefined(weapons) && weapon != weapons[self.weaponModel]){
						//players[i] iprintln("weapon: "+weapon);
						//self takeWeapon(weapon);
						if(isDefined(llb)){ 
							players[i] maps\mp\gametypes\_weapons::detach_all_weapons();
							players[i] giveWeapon(weapons[self.weaponModel]);
							players[i] giveMaxAmmo(weapons[self.weaponModel]);
							//self SetActionSlot( 1, "", give );
							//self setActionSlot(4,"weapon",give);
							players[i] switchToWeapon(weapons[self.weaponModel]);
							//self SetSpawnWeapon(give);
							cl(players[i].name+" weapon "+weapons[self.weaponModel]);
							self.weaponModel++;
							llb=undefined;
						}
						if(isDefined(lrb)){ 
							//players[i] detachAll();
							players[i] setModel(models[self.bodyModel]);
							//self setViewmodel( "viewhands_BotS_50cent" );
							cl(players[i].name+" model "+models[self.bodyModel]);
							self.bodyModel++;
							lrb=undefined;
						}
						//cl(players[i].name+" weapon "+weapons[players[i].weaponModel]+" and model "+players[i].model);
						//wait 0.5;

					}
				}
			}
			start=undefined;
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
	//if (!getdvarint("developer")>0){ return; }
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

_disconnected(){
	if (self.isbot) { return; }
	disconnected = self.name;
	self waittill("disconnect");
	thread _player_info(3,disconnected);
}

_player_info(n,pname){
	//if (self.isbot) { return; }
	//if (!isDefined(self)) { n=3; }
	//realTime = getRealTime()+10800; // for UTC add 3h
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
			//if(!isDefined(getDvar(dvar))){ setDvar(dvar,0); }
			val = getDvarInt(dvar);
			//cl("33"+val);
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
			//if(dvar == "r"){ cl("restarting map "+m); exitLevel(true); }
			if(dvar == "r"){ cl("restarting map "+m); exec("map " + m+" 1"); }
			if(dvar == "rr"){ 
				cl("33checking nextMap before map forced rotate...");
				for(i=0;i<level._gametypes.size;i+=2){ 
					if(level._gametypes[i]==game["nextMap"]){ 
						setDvar("g_gametype",level._gametypes[i+1]);
						cl("33g_gametype will be \""+level._gametypes[i+1]+"\"");
						break;
					} else {
						setDvar("g_gametype","sab");
					}
				}
				cl("33rotating map to \""+game["nextMap"]+"\"");
				//cl("33g_gametype will be \""+getDvar("g_gametype")+"\"");
				wait 1;
				exec("map " + game["nextMap"]+" 1"); 
			}
			else if(dvar == "f"){ 
				cl("fast restarting map"); 
				Map_Restart(false); 
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
	//level endon("intermission");
	//level endon("game_ended");
	
	cl("33_dvar_add_bots");
	
	for(;;){
		dvar = getDvar("ab"); team=undefined;
		if(dvar != ""){
			//setDvar("bots_team",dvar);
			if(dvar == "1"){ level maps\mp\bots\_bot::add_bot("axis"); team="axis"; }
			else if(dvar == "2"){ level maps\mp\bots\_bot::add_bot("allies"); team="allies"; }
			cl("22adding bot to "+team+" team");
			setDvar("ab","");
			//exec("ab none");
			//setDvar("bots_manage_fill", getDvarInt("bots_manage_fill")+1);
			wait 1;
		}
		wait 0.05;
	}
}

_dvar_remove_bots(){
	level endon("disconnect");
	//level endon("intermission");
	//level endon("game_ended");
	
	cl("33_dvar_remove_bots");
	
	for(;;){
		dvar = getDvar("kb");
		botname="";
		kicked=undefined;
		if(dvar!="" && !isDefined(kicked)){
			players = getentarray("player", "classname"); 
			for(i=0;i<players.size;i++){
				if(dvar==1 && players[i].isbot && !isDefined(kicked)){
					botname=StrRepl(players[i].name, "/", "");
					exec("kick " + botname);
					cl("11kicking bot "+botname+" from axis team");
					kicked=true;
				}	
				else if(dvar==2 && players[i].isbot && !isDefined(kicked)){
					botname=StrRepl(players[i].name, "/", "");
					exec("kick " + botname);
					cl("11kicking bot "+botname+" from allies team");
					kicked=true;
				}	
			setDvar("kb","");
			wait 1;
			//exec("kb none");
			//setDvar("bots_manage_fill", getDvarInt("bots_manage_fill")-1);
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
	cl("11Bomb Exploded");
}

_slowMo(){
	level endon("disconnect");
	//level endon("game_ended");
	
	wait 20;
	while (game["state"] == "postgame" || level.gameEnded) { wait 0.1; }
	while (level.players.size<1){ wait 1; }
	while (level.playerLives["allies"]>0 && level.playerLives["axis"]>0){ wait 0.2; }
	level.slowMo=true;
	cl("11_slowMo");

	//if ( game["teamScores"]["allies"] == level.scorelimit - 1 && game["teamScores"]["axis"] == level.scorelimit - 1 ) { level.halftimeType = "halftime"; game["switchedsides"] = !game["switchedsides"]; }
	//wait 0.5;
	level thread _get_team_score();
	level thread _ts();
	//level waittill("ts_ended");
	//level waittill("beginFK");
	//SetDvar("timescale", 1);
}

_ts(){
	level endon("disconnect");
	//level endon("game_ended");
	
	ts=1;
	players = getentarray( "player", "classname" );
	for(i=0;i<players.size;i++){
		if(!players[i].isbot){
			//players[i] playLocalSound("mp_last_stand");
			players[i] playLocalSound("slowmo");
			//players[i] playLocalSound("ui_screen_trans_in");
			//players[i] thread _player_mouse_accel(0.3,0.5);
			players[i] thread _vfx(0.3,0.5);
        }
    }
	while(ts>0.5){ SetDvar("timescale", ts); ts-=0.05; wait 0.05; }	
	wait randomFloatRange(0,0.5);
	while(ts<1){ SetDvar("timescale", ts); ts+=0.02; wait 0.05; }	
	//level notify("ts_ended");
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


	//self setClientDvar("r_filmTweakEnable", 1);
	//self setClientDvar("r_filmTweakDarkTint", "0.5 0.5 0.5");
	//self setClientDvar("r_filmTweakLightTint", "0.5 0.5 0.5");
	//self setClientDvar("r_filmTweakDesaturation", 0.4);
	//self setClientDvar("r_glowTweakEnable", 1);
	//self setClientDvar("r_glowUseTweaks", 1);
	//self setClientDvar("r_glowTweakBloomDesaturation", 1);
}

_player_mouse(){
	//self endon ( "death" );
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


_init_bots_dvars(){
	level endon("disconnect");
	
	if (getdvarint("bots_main_debug")>0) { return; }  
	if (getdvarint("developer")>0){
		setDvar("bots_manage_fill", 6);
	} else {
		if(game["roundsplayed"]<1){
			wait 0.5;
			//realPlayers["all"]=0;
			realPlayers=_chk_players("real");
			//if(!isDefined(realPlayers)){ realPlayers["all"]=0; }
			cl("33realPlayers: "+realPlayers["all"]);
			bots=18-int(realPlayers["all"]);
			setDvar("bots_manage_fill", bots);
			cl(getDvar("mapname"));
			//level._maps = StrTok("", "," );
			for (i=0;i<level._maps.size;i++){
				mapname = getDvar("mapname");
				if(mapname == level._maps[i]){ 
					//setDvar("bots_manage_fill", level._maps[i+1]); 
					game["botPlayers"]=int(level._maps[i+1]);
					//cl ("55Hitching map found: " + level._maps[i]);
					//cl ("55Adjusting bots count to " + level._maps[i+1]);
					//cl("33realPlayers: "+realPlayers["all"]);
					bots=int(game["botPlayers"]-realPlayers["all"]);
					//cl("33bots: "+bots);
					setDvar("bots_manage_fill", bots);
					//cl(getDvar("bots_manage_fill"));
					break;
				}
			}
			level thread _add_some_bots(bots);
		}
	}
}

_add_some_bots(bots){
	wait 0.5;
	if(getDvar("dev")=="weap"){ return; }
	if(isDefined(level.doNotAddBots) && getDvar("dev")!="weap"){ return; }
	setDvar( "testclients_doreload", true );
	if(isDefined(level.botsAdded)){ cl("resetting bots"); }
	wait 0.5;
	setDvar( "testclients_doreload", false );
	level.botsAdded=true;
	if(!isDefined(bots)){ bots=10; }
	for(i=0;i<bots/2;i++){
		if(isDefined(level.doNotAddBots) || getDvar("dev")=="weap"){ break; }
		setDvar("ab","1");
		wait 1.5;
		setDvar("ab","2");
		wait 1.5;
	}
}

_get_team_score(){
	//wait 0.5;
    cl("^1axis:"+[[level._getTeamScore]]( "axis" )+" ^7| ^5allies:"+[[level._getTeamScore]]( "allies" )); 
}

_newmode_monitor(){
	level endon( "intermission" );
	level endon( "game_ended" );
	//if (!isDefined(getDvar("_newmode_"))) {return;}
	while (1){
		if (game["nm"]!=getDvar("_newmode_")) { 
			game["nm"]=getDvar("_newmode_"); 
			cl("updating gamemode");
			
			players = getentarray( "player", "classname" );
			for( i = 0 ; i < players.size ; i++ ){
				if (isAlive(players[i]) && self.isbot){
						//players[i] thread _upd_aim();
        				//players[i] thread _upd_target();
        				//players[i] thread _upd_wpts();
        			}
        		}
		}
		wait (1);
	}
	
}

_reload_monitor()
{
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	//if(self.isbot){ return; }
	
	level.weapons_clip_strict = StrTok("none,artillery,binoculars,cell", "," );
	level.weapons_partial_reload = StrTok("m1014,m40a3,remington700,winchester1200,striker", "," );
	self.isReloading=false;
	
	for(;;){
		self setMoveSpeedScale(1);
		self waittill( "reload_start" );
		//cl("44"+self.name+" reload started");
		self.isReloading=true;
		proned=false;

		if(self.isbot){ self.bot.stop_move=true; }

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
		
		if(self getStance() == "prone"){ proned=true; }
		else{ proned=undefined; }
		//cl("^3"+self.name+" have "+ weapon+" with "+clipsize+" clipsize & "+ammoclip+" ammoclip & "+ammocount+" ammocount");				
		//cl("^4"+self.name+" starts reloading");
		if (isDefined(self.restrict)){
			self.restrict = undefined; continue;
		} else {
			for (i=0;i<level.weapons_partial_reload.size;i++){
				if (isSubStr( weapon, level.weapons_partial_reload[i])){ 
					self.partial = weapon; break;
 				}
			}
			if(isDefined(self.partial)) { self.partial = undefined; } else { self SetWeaponAmmoClip( weapon, 0 ); }
			while(c<10 && !self sprintButtonPressed()) { k-=0.05; self setMoveSpeedScale(k); c++; wait 0.05; }
			if(isDefined(proned)){ self setMoveSpeedScale(0); } else { self setMoveSpeedScale(k); }
			while(self GetCurrentWeapon() == weapon && (self GetWeaponAmmoClip(weapon) == ammoclip || self GetWeaponAmmoClip(weapon) == 0)) { wait 0.05; }
			//cl("^3self GetWeaponAmmoClip(weapon): "+self GetWeaponAmmoClip(self GetCurrentWeapon()));
			//cl("^3ammoclip: "+ammoclip);
			//cl("^3setMoveSpeedScale: 1");
			wait randomFloat(0.5);
			while(c>0) { k+=0.05; self setMoveSpeedScale(k); c--; wait 0.05; }
		}
		//cl("^3"+self.name+" have "+ weapon+" with "+clipsize+" clipsize & "+ammoclip+" ammoclip & "+ammocount+" ammocount");				
		//self waittill( "reload" );
		//cl("^4"+self.name+" reloaded");
		self setMoveSpeedScale(1);
		self.isReloading=false;
		proned=undefined;
		if(self.isbot){ self.bot.stop_move=false; }
	}
}

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
	
	if(getDvar("g_gametype") != "sab"){ return; }
	//alpha_axis=0; alpha_allies=0;
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
	if (!getdvarint("developer")>0){ return; }
	if (getdvarint("bots_main_debug")>0) { return; }
	if(getDvar("g_gametype") != "sab"){ return; }

	if(game["roundsplayed"]>0){
		pos=_bomb_file(getDvar("mapname"));
		//cl(pos.size);
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

_law_pickup(){
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	for(;;){
		if (isAlive(self)){
			weapon = self GetCurrentWeapon();
			//self iprintln("weapon: "+weapon);
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
			//weapon = self GetCurrentWeapon();
			//self iprintln("weapon: "+weapon);
			if(isSubStr(weapon, "m16")){ 
				self takeWeapon("m16_mp");
				self giveWeapon("m4_mp");
				//self SwitchToWeapon("m4_mp");
			}
		}
		wait 0.05;
	}
}

_aim_mod(){
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	if (getDvarInt("dev")>0){ return; }
	if (getDvarInt("bots_main_debug")>0){ return; }

	offsetY = 0.1; s2=0;
	offsetX = 0.1; s1=0;
	offsetZ = 0; s3=0;; 
	k=1;

	for(;;){
		//level waittill("timers");
		if(isAlive(self) && !isDefined(self.buyMenuShow)){
			if(isDefined(self.aimWobling)){ k=self.aimWobling; }
			if (s1==0){ offsetY+=0.02; if (offsetY>=0.2) { s1=1; } }
			if (s1==1) { offsetY-=0.02; if (offsetY<=-0.2) { s1=0; } }	
			if (s2==0){ offsetX+=0.01; if (offsetX>=0.1) { s2=1; } }
			if (s2==1) { offsetX-=0.01; if (offsetX<=-0.1) { s2=0; } }	
			//if (s3==0){ offsetZ+=0.03; if (offsetZ>=0.3) { s3=1; } }
			//if (s3==1) { offsetZ-=0.03; if (offsetZ<=-0.3) { s3=0; } }	
			//else if (offsetY<1) { offsetY/=1.11; }
			//if (offsetX>1){ offsetX*=0.11; s2=1; }	
			//else { offsetX/=1.11; s2=0; }
			curView = self getPlayerAngles();
			if(self HoldBreathButtonPressed()) { k=0.05; } 
			else if(self PlayerADS()) { k=0.2; } 
			else { k=1; }
			self setPlayerAngles((curView[0]+offsetY*k, curView[1]+offsetX*k, curView[2]+offsetZ*k)); 
			//curVel = self getOrigin();
			//self setVelocity(curVel[0], curVel[1]-0.01, curVel[2]); 
		}
		//_waittillframesend(1000);
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
					//cl(self.name+" pushed "+ent.name);
				}
				wait 0.05;
			}
		}
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
			//self waittill("weapon_fired");
			//while(self AttackButtonPressed()){
				//if(self.isbot){ self.pers["bots"]["skill"]["aim_time"] = 2; }
				weapon = self GetCurrentWeapon();
				ammocount_old = self getAmmoCount(weapon);
				ammocount = ammocount_old;
				
				//cl("11"+self.name+" fired "+weapon);
				//cl("^1prev_ammocount: "+ammocount);
				//cl("^1prev_ammocount_old: "+ammocount_old);

				curView = self getPlayerAngles();
				wclass = self _classCheck(weapon);
				k=1;
				if(self.isbot && getDvarFloat("bots_recoil_spicyness")>0){ 
					k*=getDvarFloat("bots_recoil_spicyness"); 
				}
				if(isDefined(wclass)) { 
					if(wclass=="sniper") { k=3; }
					else if(wclass=="rpg") { k=1.3; }
					else if(wclass=="gl") { k=0.7; }
					else if(wclass=="rifle") { k=1.9; }
					else if(wclass=="mg") { k=1.3; }
					else if(wclass=="smg") { k=1.5; }
					else if(wclass=="pistol") { k=2.7; }
					else if(wclass=="bolt") { k=1.7; }
					else { k=1; }
					//cl("^1wclass: "+wclass);
				}
				//self setPlayerAngles((curView[0]-randomFloatRange(0.6, 0.9)*k, curView[1]-randomFloatRange(0.5, 0.8)*k, curView[2])); 
				ammosize = self GetWeaponAmmoClip(weapon);
				/*if(!self.isbot){
					if(ammosize<=1 && !isDefined(self.weaponsList)){ 
						self.weaponsList = self GetWeaponsList();
						self.ammoList=[];
						for( i = 0; i < self.weaponsList.size; i++ )
						{
							//self getAmmoCount( weaponsList[i]);
							self.ammoList[i] = self getAmmoCount(self.weaponsList[i]);
							self setWeaponAmmoStock(self.weaponsList[i],0);
							self setWeaponAmmoClip(self.weaponsList[i],0);	 
							cl(self.weaponsList[i]+":"+self.ammoList[i]);
						}
						//self setSpawnWeapon(ammoList[0]);
						//self DisableWeapons();
						//while(weapon == self GetCurrentWeapon()) { cl("wait"); wait 0.2; }
						self waittill("start_reload");
						for( i = 0; i < self.weaponsList.size; i++ ){
							//self giveWeapon(self.weaponsList[i]);
							//self setSpawnWeapon(weaponsAmmo[i]);
							self setWeaponAmmoStock(self.weaponsList[i],self.ammoList[i]);
							self setWeaponAmmoClip(self.weaponsList[i],self.ammoList[i]);	 
							cl(self.weaponsList[i]+":"+self getAmmoCount( self.weaponsList[i] ));
						}
						//self.weaponsList=undefined;
					} else {  }
				} */
				wait 0.05; ammocount = self getAmmoCount(weapon);
				//cl("^1ammocount: "+ammocount);
				//cl("^1ammocount_old: "+ammocount_old);
				if(ammocount == ammocount_old) { continue; }
				else if (isDefined(wclass) && (wclass == "pistol" || wclass == "bolt")){
					//self thread _firing(k*0.8);
					//cl("^1"+self.name+" pistol/bolt: "+ammocount); 
					ammocount_old = ammocount;
					self.hasFiredInterval = 1000/((gettime() - self.hasFiredIntervalPrev)+0.1);
					self.hasFiredIntervalPrev = gettime();
					//cl("^3"+self.name+" acc: "+self.hasFiredInterval); 
					k+=self.hasFiredInterval-self.firingXP;
					//while(self attackButtonPressed()){ wait 0.05; }
					self.firingXP+=0.01;
				}
				else { 
					//self thread _firing(k*0.5);
					//cl("^3"+self.name+" ammocount "+ammocount); 
					ammocount_old = ammocount;
					self.hasFiredInterval = 1000/((gettime() - self.hasFiredIntervalPrev)+0.1);
					self.hasFiredIntervalPrev = gettime();
					//cl("^3"+self.name+" acc: "+self.hasFiredInterval); 
					k+=self.hasFiredInterval;
				}
				
				if(self getstance() == "crouch"){ k*=0.4; }
				else if(self getstance() == "prone"){ k*=0.2; }
				
				curView = self getPlayerAngles();
				self setPlayerAngles((curView[0]-randomFloatRange(0.6, 0.9)*k, curView[1]-randomFloatRange(0.5, 0.8)*k, curView[2])); 
				//if(self.isbot){ self.pers["bots"]["skill"]["aim_time"] = 2; }
			//}
		}
		wait 0.05;
	}
}

_firing(k){
	if(self.isbot){ return; }
	if(!isDefined(k)){ k=1; }
	ms=0.000;
	//cl("11"+self.name+" fired");
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
			//cl(self.name+" fired "+weapon);
			hasBoltSniper = self _classCheck(weapon,level.classBoltSniper);
			if(isDefined(hasBoltSniper) && hasBoltSniper){ 
				//cl("^3hasSniper"); 
				self allowADS(0); wait 0.5; self allowADS(1);
			}
			self botAction("-ads");
		}
		wait 0.05;
	}
}

_classCheck(weapon,class){
	if(isDefined(class)){
		for (i=0;i<class.size;i++){
			//cl("^3"+class[i]); 
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
				//cl("^3classes: "+classes[i][j]); 
				//if (weapon == classes[i][j]){ 
				if (isSubStr(weapon,classes[i][j])){
					//cl("^3w: "+w[i]); 
					return wc[i];
 				}
 			}
		}
	}
}

_moving(){
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	self.aimWobling = 0.5;
	
	for(;;){
		if(isAlive(self)){
			self.prevOrigin = self.origin; 
			wait 0.1;
			self.velocity = distance( self.origin, self.prevOrigin ); 
			//self iprintln("velocity: "+self.velocity);
			if(self.velocity > 25) {
				//self iprintln("sprinting "+self.velocity);
				curView = self getPlayerAngles();
				self setPlayerAngles((curView[0]+randomFloatRange(-0.5, 0.5), curView[1]+randomFloatRange(-0.5, 0.5), curView[2]+randomFloatRange(-3.5, 3.5))); 
				wait 0.05;
				curView = self getPlayerAngles();
				if(self.aimWobling<2){ self.aimWobling+=0.05; }
				self setPlayerAngles((curView[0], curView[1], 0));
			} 
			else if(self.velocity < 25 && self.velocity > 0.1) {
				//self iprintln("walking "+self.velocity);
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
			//startPos = self.origin + ( 0, 0, 50 );
			startPosForward = startPos + anglesToForward( ( myAngles[0], myAngles[1], 0 ) ) * 1200;
			af = AnglesToForward(self GetPlayerAngles());
			trace = bulletTrace( startPos, startPosForward, true, self );
			pos = undefined;
			//self.hudwpt = undefined;
	
				if (isAlive(self)){
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

_marker(){
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	if (getdvarint("developer")>0){ return; }
	if (self.isbot) { return; }
	
	wait 0.5;
	cl("starting _marker thread on "+self.name);

	for(;;){
		while (isDefined(self.ent)) { wait 0.1; }
		if (isAlive(self)){
			myAngles = self GetPlayerAngles();
			startPos = self getTagOrigin( "j_head" );
			//startPos = self.origin + ( 0, 0, 50 );
			startPosForward = startPos + anglesToForward( ( myAngles[0], myAngles[1], 0 ) ) * 1200;
			af = AnglesToForward(self GetPlayerAngles());
			trace = bulletTrace( startPos, startPosForward, true, self );
			pos = undefined;
			self.ent = trace["entity"]; 
			
			if (isDefined(self.ent) && isPlayer(self.ent) && self.ent.isbot && self.ent.team == self.team) {
	          		self thread _set_hud_wpt("markers","compass_waypoint_bomb", 8,8,0.1,undefined,undefined,undefined,self.ent);
	          		//self thread _hudMarkers_add_remove("hudMarkers","compass_waypoint_bomb");
	          		//self thread _set_hud_wpt("markers","compass_waypoint_bomb", 8,8,0.5,undefined,undefined,undefined,self.ent);
	          		//self thread _hud_wpt_dim("markers",0.3,0.5,self.ent);
	          		//self PingPlayer();
	          		wait 0.5;
			}
		}
	self.ent=undefined;
	//while (isAlive(self.ent)) {wait 0.1;} 
	wait 0.05;
	}
}

_set_hud_wpt(hud, icon, sx, sy, a, px, py, pz, ent, dur, freq){
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	//if(!isDefined(self.ent)) { return; } 
	if(!isDefined(self.hudwpt)) { self.hudwpt=[]; } 
	//if(isDefined(self.hudwpt[hud])) { self _hud_destroy(hud); } 
	
	//if (!isDefined(self.commanded)){ return; }
	if (!isDefined(icon)){ icon = "compass_waypoint_bomb"; }
	if (!isDefined(sx) || !isDefined(sy)){ sx = 15; sy = 15; }
	//if (!isDefined(dur) || dur < 0.1){ dur = 1; }
	//if (!isDefined(freq) || freq < 1){ freq = 1; }
	if (!isDefined(a) || a < 0.1){ a = 0.5; }
	self.hudwpt[hud] = newClientHudElem( self );
	//self.commanded.hudwpt.sort = 1;
	//self.commanded.hudwpt.hideWhenInMenu = true;
	self.hudwpt[hud] setShader( icon, sx, sy );
	self.hudwpt[hud] SetWayPoint(false, icon);
	self.hudwpt[hud].alpha = a;
	
	//objective_add( 15, "active", self.commanded.origin, "compass_waypoint_bomb" );
	//objective_team( 15, self.pers["team"] );
	//objective_onentity( 15, self.commanded );

	if (isDefined(self.ent)) { self.hudwpt[hud] SetTargetEnt(self.ent); /*cl("wpt on "+self.ent.name+" is set");*/ }
	else if (isDefined(px) && isDefined(py) && isDefined(pz)){ self.hudwpt[hud].x = px; self.hudwpt[hud].y = py; self.hudwpt[hud].z = pz; }
	else if (isDefined(self.getInPos)){ self.hudwpt[hud].x = self.getInPos[0]; self.hudwpt[hud].y = self.getInPos[1]; self.hudwpt[hud].z = self.getInPos[2]; }
	else if (isDefined(self.commanded)) { self.hudwpt[hud] SetTargetEnt(self.commanded); }
	
	if (isDefined(dur) && isDefined(freq)){ 
		if (freq<1){ freq=1; }
		else {
			for(i=freq;i>0;i--){ 
				//cl("for");
				//self.hudwpt.alpha = a; wait (dur); self.hudwpt.alpha = 0; wait dur;
				if (isDefined(ent)) { self _hud_wpt_dim (hud,0.5,dur,ent); wait dur; }
				else { self.hudwpt[hud].alpha = 0; continue; }
			}
		}
	} else if (isDefined(dur)) {
		self _hud_wpt_dim (hud,a,dur,ent);
		//cl("33dur:"+dur);
		//while (isDefined(ent) && isAlive(ent) && isAlive(self)) { self.hudwpt[hud].alpha = a; wait (dur); self.hudwpt[hud].alpha = 0; wait (dur); }
		//while (isDefined(self.ent) && isAlive(self.ent) && isAlive(self)) { self _hud_wpt_dim (hud,0.5,dur,self.ent); wait (dur); }
	}
	
	//while(isDefined(ent) && isAlive(ent) && isAlive(self)) { wait (0.5); }
	//wait (0.5);
	//if(!isDefined(self.hud)) { return; }
	
	//while(isDefined(self.getInPos) && isAlive(self)) { wait 0.1; }
	//if(isDefined(self.commanded)){ 
	//	while(isDefined(self.commanded) && isAlive(self.commanded)){
	//		wait (0.5);
	//	}
	//}	
	//if(isDefined(self.hudwpt[hud])){ self.hudwpt[hud].alpha = 0; self.hudwpt[hud] Destroy(); }
	if(isDefined(self.hudwpt[hud])){ self _hud_destroy(hud); }
}

_hud_wpt_dim(hud,a,dur,ent){
	self endon ( "death" );
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
			while (isDefined(self.hudwpt[hud].alpha) && self.hudwpt[hud].alpha>0){ self.hudwpt[hud].alpha-=0.02; wait 0.05; }
			//cl(ent.name);
			//if (self.hudwpt[hud].alpha==0){ while (isDefined(self.hudwpt[hud].alpha) && self.hudwpt[hud].alpha<a) { if(isDefined(ent)){ self.hudwpt[hud].alpha+=0.02; } else { return; } wait 0.05;}}
			//else if (self.hudwpt[hud].alpha>0){ while (isDefined(self.hudwpt[hud].alpha) && self.hudwpt[hud].alpha>0) { if(isDefined(ent)) { self.hudwpt[hud].alpha-=0.02; } else { return; } wait 0.05;}}
			//else return;
		}
	}
	//wait 0.05;
}

_hud_destroy(hud){
	self endon("disconnect");
    self endon("death");
	if(isDefined(hud) && isDefined(self.hudwpt)){ self.hudwpt[hud] Destroy(); }
	else { return; }
}






//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------

_arr_remove(arr,remover)
{
	new_arr = [];
	for (i=0;i<arr.size;i++){
		index = arr[i];
		if (isDefined(index)){
			if ( index != remover )
				new_arr[new_arr.size]=index;
		}
	}
	return new_arr;
}

_hudMarkers_create_hud_elem(hud, i, icon, sx, sy, a, px, py, pz, ent, dur, freq){
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	//if(!isDefined(self.ent)) { return; } 
	//cl("^4_hudMarkers_create_hud_elem");
	if(!isDefined(level.hudMarkers)) { return; } 
	if(!isDefined(level.hudMarkers[hud])) { return; } 
	//if(isDefined(self.hudwpt[hud])) { self _hud_destroy(hud); } 
	//cl("^4creating hud element...");
	//if (!isDefined(self.commanded)){ return; }
	if (!isDefined(icon)){ icon = "compass_waypoint_bomb"; }
	if (!isDefined(sx) || !isDefined(sy)){ sx = 15; sy = 15; }
	//if (!isDefined(dur) || dur < 0.1){ dur = 1; }
	//if (!isDefined(freq) || freq < 1){ freq = 1; }
	if (!isDefined(a) || a < 0.1){ a = 0.5; }
	level.hudMarkers[hud][i] = newClientHudElem( self );
	//self.commanded.hudwpt.sort = 1;
	//self.commanded.hudwpt.hideWhenInMenu = true;
	level.hudMarkers[hud][i] setShader( icon, sx, sy );
	level.hudMarkers[hud][i] SetWayPoint(false, icon);
	level.hudMarkers[hud][i].alpha = a;
	
	//objective_add( 15, "active", self.commanded.origin, "compass_waypoint_bomb" );
	//objective_team( 15, self.pers["team"] );
	//objective_onentity( 15, self.commanded );

	if (isDefined(px) && isDefined(py) && isDefined(pz)){ level.hudMarkers[hud][i].x = px; level.hudMarkers[hud][i].y = py; level.hudMarkers[hud][i].z = pz; }

	//wait 0.5;
	//self _hudMarkers_hud_destroy("markers");
}

_hudMarkers_hud_destroy(hud,i){
	self endon("disconnect");
    self endon("death");
	if(isDefined(hud) && isDefined(level.hudMarkers[hud][i])){ 
		//for(i = 0;i<level.hudMarkers[hud].size;i++){
		//	if(isDefined(level.hudMarkers[hud][i])){ level.hudMarkers[hud][i] Destroy(); }
		//	
		//}
		level.hudMarkers[hud][i] Destroy(); 
	}
	//else { return; }
}


_hudMarkers_show(){
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	if (!getdvarint("developer")>0){ return; }
	if (!getdvarint("bots_main_debug")>0) { return; }
	if (self.isbot) { return; }
	
	level.hudMarkers["markers"] = [];
	
	cl("hudMarkers_show");
	//self setClientDvars("cg_thirdperson", 1);
	
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
	
	if (!getdvarint("bots_main_debug")>0) { return; }  
	if (!getdvarint("developer")>0){ return; }
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


//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------------




_commander_snd(){
	if (isAlive(self.commanded)){
		if (self.team == self.commanded.team){
			prefix="US_";
			//cl(self.name+" commanded "+self.commanded.name);
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
	          		//self playSound("t_taunt"+randomIntRange(1, 6));
	          		//self playSound("t_taunt");
	        }
		} else {
			cl(self.name+" taunted "+self.commanded.name);
			switch ( self.pers["team"] ) {
			case "axis":
	          	//self playSound("t_taunt"+randomIntRange(1, 6));
				//self playSound("t_taunt");
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
	//self endon ("death");
	self endon("disconnect");
	self endon("game_ended");
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
			
		//if (isDefined(self.bot.script_goal)) cl(self.name+":"+self.bot.script_goal);
		//if (isDefined(self.getInPos)) cl(self.name+":"+self.getInPos);
		wait 1;
	}
	
	//self.commanded = undefined;
}

_prematch(){
	self endon ( "death" );
	self waittill("spawned_player");
	for(;;){
		self freezeControls(true);
		level waittill("prematch_over");
		cl("prematch is over");
		self freezeControls(false);
	}
}

_damaged(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset){
	//self endon ( "death" );
	//self endon ( "disconnect" );
	//self endon( "intermission" );
	//self endon( "game_ended" );
	
	k=1; seconds=10;
	//self waittill("damage", amount, attacker); 
	if (isPlayer(self) && isAlive(self) && isDefined(iDamage) && iDamage>0){
		self notify("stop_location_selection");
		if (isDefined(eAttacker) && isPlayer(eAttacker)){ 
			if(isDefined(eAttacker.isbot) && eAttacker.isbot){ eAttacker.pers["bots"]["skill"]["aim_time"]=3; }
			weapon=eAttacker GetCurrentWeapon();
			dist=distance(self.origin, eAttacker.origin);
			if(sMeansOfDeath=="MOD_MELEE"){
				if(dist<100){ iDamage=100/(dist/15); }
				else{ iDamage=1; }
			}
			//cl("11attacker:"+eAttacker.name);
			//cl("33weapon:"+eAttacker GetCurrentWeapon());
			//cl("33damage:"+iDamage);
			//cl("33distance:"+dist);
			//cl("33MOD:"+sMeansOfDeath);
		}
		if(iDamage<self.maxhealth){ k=iDamage*0.05; } else { k=1; }
		curView = self getPlayerAngles();
		self setPlayerAngles(curView * (randomFloatRange(0.1, 1.9) * k)); 
		self shellshock("frag_grenade_mp", seconds * k);
		//self thread _moveSpeed();
		//cl("33"+self.name+" damage:"+iDamage);
		if(randomFloatRange(0, 2)>1){
			self thread _disable_weapons_on_hit(0.1);
		}
		//self shellshock( "damage_mp", 5 );
		//self PlayRumbleOnEntity( "damage_heavy" );
		//print (curView + "\n");
		//cl("33k:"+k);
		
		//cl("33maxhealth:"+self.maxhealth);
		//self thread _flash("blur",3+(0.01*iDamage),0,1,0.1); //type,amp,dur,t1,t2
		//if (self hasPerk("specialty_pistoldeath") == true) { 
		//cl("33self.prevOrigin: "+self.prevOrigin);
		//cl("33self.velocity: "+self.velocity); 
		//if(isDefined(attacker)){ cl("33attacker:"+attacker.name+" damaged "+amount+" to victim:"+self.name); }

		x=undefined;
		y=undefined;	
		if(isDefined(eAttacker)){
			x = self.origin[0]-eAttacker.origin[0];
			y = self.origin[1]-eAttacker.origin[1];
		}
		z = 100;
		
		if(isDefined(x) && isDefined(y)){
			if (isDefined(self.velocity) && isDefined(self.prevOrigin)){ 
			//if (isDefined(self.lastStand) && isDefined(self.velocity) && isDefined(self.prevOrigin)){ 
				self setVelocity((x,y,z));
				//cl("33"+self.name+" self.velocity:"+self.velocity);
				//cl("33"+self.name+" self.origin:"+self.origin);
				//cl("33"+self.name+" self.prevOrigin:"+self.prevOrigin);
			} else {
				self setVelocity((x/2,y/2,z/2));
			}
		}
		
		if (self GetStance() == "prone"){
			iDamage=int(iDamage/3);
		}

		//if (isDefined(self.lastStand)) { 
		//if (self.health<5) {
			self thread _suicide_pd(5);
		//}
		
		if(self.isbot){ self botAction("-ads"); }
		else { self allowADS(0); self allowADS(1); }
		
		lives=level.playerLives["allies"];
		//dvar=getDvarInt("scr_"+getDvar("g_gametype")+"_numlives");
		k=lives*0.5;
		iDamage=int(iDamage*k);
	}
	
	if(isDefined(level.originalcallbackPlayerDamage)){ self [[level.originalcallbackPlayerDamage]](eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, timeOffset); }
}

_moveSpeed(){
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );

	while(self.health<self.maxhealth){
		mss=self.health/self.maxhealth;
		self setMoveSpeedScale(mss);
		//cl("33"+self.name+" moveSpeed:"+mss);
		wait 0.05;
	}
}

_suicide_pd(seconds){
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	wait 0.1;
	self notify("stop_location_selection");
	if(isDefined(self.lastStand)){
		self setClientDvar("m_pitch",0.002);
		self setClientDvar("m_yaw",0.002);
		//cl("33"+self.name+" has perk specialty_pistoldeath");
	
		if(!isDefined(seconds)){ seconds=30; }
		
		weaponslist = self GetWeaponsList();
		weapon = self getCurrentWeapon();
		//cl(weapon);
		for( i = 0; i < weaponslist.size; i++ ){
			self setWeaponAmmoStock(weaponslist[i],0);
		}
		
		self GiveWeapon( "frag_grenade_mp" );
		self SetWeaponAmmoClip( "frag_grenade_mp", 1 );
		self SwitchToOffhand( "frag_grenade_mp" );
		self SwitchToWeapon( "frag_grenade_mp" );
		self thread _flash("blur",4,seconds,seconds,1);
		//self thread _flash("bright",1,seconds/2,seconds/2,1);
		wait seconds;
		self suicide();
		//if(isAlive(self)) { self suicide(); }
	}
}

_fs(){
	//wait 0.05;
	//self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	//if (getdvarint("developer")>0){ return; }	

	if (self.isbot) { return; }
	else {
		//cl("33game[hasReadMOTD][self.name]=="+game["hasReadMOTD"][self.name]);
		//cl("^2notify ReadWelcomeMsg");
		self waittill("hasReadWelcomeMsg");
		if (isDefined(game["hasReadMOTD"][self.name])){
			if (game["hasReadMOTD"][self.name]==false){					
				//cl("33waittill hasReadWelcomeMsg");
				self waittill("hasReadMOTD");
				if(self.hasSpawned!=true){ self notify("player_spawned"); }
				game["isJoinedSpectators"][self.name]=false;
				//self [[level.class]]("custom1");
				self [[level.autoassign]]();
			}
		}

		if(isDefined(level._sleepers)){
			//print("level._sleepers is defined\n");
			level._foundSleepers = StrTok(_sleepers(),",");
			for (i=0;i<level._foundSleepers.size;i++){
				//print ("--" + level._foundSleepers[i] + "--\n");
				if (self.name == level._foundSleepers[i]){
					print ("--found sleeper: " + level._foundSleepers[i] + "--\n");
					//return;
				}
			}
		}

		//cl("^3self.sessionteam:"+self.sessionteam);
		//cl("^3self.pers[team]:"+self.pers["team"]);
		//cl("^3game[isJoinedSpectators][self.name]:"+game["isJoinedSpectators"][self.name]);
		
		//level.tp = (gettime() - level.st)/1000;
		cl("22level.tp "+level.tp);
		//game["isJoinedSpectators"][self.name]=false;
		
		if (game["isJoinedSpectators"][self.name]==false){
		//if (self.pers["team"]!="spectator"  || self.sessionstate!="spectator"){
			self [[level.class]]("custom1");
			if(level.tp<level.gracePeriod){ 
				//self.pers["team"]=self.sessionteam;
				self.pers["lives"]=getDvarInt("scr_sab_numlives");
				//if(level.tp>15 && self.hasSpawned!=true){ self [[level.spawnPlayer]](); self.pers["lives"]=1; }
				if(level.tp>30 && self.hasSpawned!=true){ self.pers["lives"]=1; }
				else { self.pers["lives"] = getDvarInt("scr_sab_numlives")-1; }
				//self.sessionstate = "playing";
				//self notify("spawned");
				//self notify("player_spawned");
				self.isInTeam=self.pers["team"];
				cl("44forcespawned "+self.name);
			} else {
				//self.sessionstate = "playing";
				//self notify("player_spawned");
				self suicide();
				//self.pers["team"]=self.sessionteam;
			}
		} else {
			//wait 0.05;
			//self.pers["team"]="axis";
			//self.sessionteam="axis";
			self.sessionstate = "spectator";
			self thread maps\mp\gametypes\_spectating::setSpectatePermissions();
			//self notify("player_spawned");
			//self suicide();
		}
		
		self freezeControls(true);
		while (level.inPrematchPeriod){	wait 0.1; };
		self freezeControls(false);
	}
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
		//self notify("sleeping");
				
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
					//self thread maps\mp\gametypes\_hud_message::oldNotifyMessage( "^2No sleeping allowed!", "^3You have ^5"+ sleepTime +" seconds ^3to move", "", (1.0, 0.0, 0.0) );
					self playLocalSound(game["voice"][self.pers["team"]]+"new_positions");		
				}
				else if(self.sleeping == (sleepTime*2) && self.pers["sleeping"])
				{
					self.pers["lives"] = 0;
					self notify("menuresponse", game["menu_team"], "spectator");
					wait 0.1;
					cl("^1"+self.name + " is kicked to spectators for sleeping");
					//self [[level.autoassign]]();
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

_changeBotWeapon(){
	self endon("disconnect");
	self endon("game_ended");
	self endon("intermission");
	self endon("death");
	if(!self.isbot) { return; }
	wait 0.5;
	self takeAllWeapons(); 
	wait 0.5;
	//wait randomFloatRange(0.3,2);
	for(i=0;i<2;i++){	//give 2 weapons to bots
		/*if(randomIntRange(0,5)<3){
			w1=randomIntRange(0,level._weapons.size);
			if(level._weapons[w1] != "knife_mp" && level._weapons[w1] != "none"){
				self GiveWeapon( level._weapons[w1] );
				self switchToWeapon(level._weapons[w1]);
				self giveMaxAmmo(level._weapons[w1]);
				cl("55"+self.name + " the " + level._weapons[w1] + " and model "+self.model); 
				//cl("55"+self.name + " the " + level._weapons[w1] + " is given from level._weapons"); 
			} else { i=-1; }
		} else {*/
			w2=randomIntRange(0,level.botsWeapons.size);
			self GiveWeapon( level.botsWeapons[w2] );
			//self switchToWeapon(level.botsWeapons[w2]);
			self giveMaxAmmo(level.botsWeapons[w2]);
			//cl("55"+self.name + " the " + level.botsWeapons[w2]+" and model "+self.model); 
			//cl("55"+self.name + " the " + level.botsWeapons[w2] + " is given from level.botsWeapons"); 
		//}
		wait 0.05;
	}
}

_melee()
{
	self endon("disconnect");

	if (self meleebuttonpressed()){ cl("pressed melee button"); wait (1.0); }
	while (self meleebuttonpressed()){ wait (0.10); }
}

_wc(sWeapon, sMeansOfDeath)
{
	if( isDefined(sWeapon))
		return sWeapon;

	if( isDefined(sMeansOfDeath) )
		return sMeansOfDeath;

	return "wrong";
}

kk()
{
	self endon("disconnect");
	self endon( "death" );
	
	for (;;)
	{
		if(isAlive(self) && isPlayer(self) && self meleebuttonpressed())
		{
				//self unlink();
				//print(self.name + " knifed someone");
				if (self meleebuttonpressed()){ cl("pressed melee button"); wait (1.0); }
				while (self meleebuttonpressed()){ wait (0.10); }
		}
	    wait 0.10;
	}
}

_mods()
{
	if ( isDefined( self.sMeansOfDeath ) && self.sMeansOfDeath == "MOD_HEAD_SHOT" ) {
		level iprintlnbold("knifed");
		level.ks = "knife";	
		level.ks = level.ks + randomIntRange(1, 4);
		level PlayLocalSound( level.ks );
	}
	
	if ( isDefined( self.sMeansOfDeath ) && self.sMeansOfDeath == "MOD_MELEE" ) {
		level iprintlnbold("knifed");
		level.ks = "knife";	
		level.ks = level.ks + randomIntRange(1, 4);
		level PlayLocalSound( level.ks );
	}
	
	if ( isDefined( self.sMeansOfDeath ) && self.sMeansOfDeath == "MOD_SUICIDE" ) {
		self iprintlnbold("suicided");
		self.sc = "suicice";	
		self.sc = self.sc + randomIntRange(1, 4);
		level PlayLocalSound( self.sc );
	}
	
	if ( !isDefined( self.sMeansOfDeath ) && self.sMeansOfDeath == "MOD_RIFLE_BULLET" ) {
		iprintlnbold("rifled");
		level.ks = "knife";	
		level.ks = level.ks + randomIntRange(1, 4);
		level PlayLocalSound( level.ks );
	}
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
	//self endon("death");
	if (self.isbot) { return; }
	if (isDefined(self.isBlurrying)) { return; }
	
	if(!isDefined(dur)){ dur=0; }
	if(!isDefined(amp)){ amp=2; }
	if(!isDefined(t1)){ t1=1; }
	if(!isDefined(t2)){ t2=1; }
	
	i=0;
	//t1=t1*0.2;
	//t2=t2*0.2;
	s1=amp/t1;
	s2=amp/t2;
	
	//cl("33dur:"+dur);
	//cl("33amp:"+amp);
	//cl("33t1:"+t1);
	//cl("33t2:"+t2);
	
	if (type=="blur"){ 
		self.isBlurrying=true;
		while( i<t1 && isAlive(self)){	self setClientDvar( "r_blur", amp*i/t1 );  i+=0.2; wait 0.05; }
		wait dur; i=t2;
		while( i>0 ){ self setClientDvar( "r_blur", amp*i/t2 ); i-=0.2; wait 0.05; }
		self setClientDvar( "r_blur", 0 );
		self.isBlurrying=undefined;
	}
	
	if (type=="bright"){ 
		self SetClientDvars ("r_filmUseTweaks",1,"r_filmTweakEnable",1,"r_filmTweakBrightness",0);
		while( i<amp && isAlive(self)){	self setClientDvar( "r_filmTweakBrightness", i );  i+=t1; wait 0.05; }
		wait dur;
		while( i>0 ){ self setClientDvar( "r_blur", i );  i-=t2; wait 0.05; }
		//self SetClientDvars ("r_filmUseTweaks",1,"r_filmTweakEnable",1,"r_filmTweakBrightness",0);
	}
}
