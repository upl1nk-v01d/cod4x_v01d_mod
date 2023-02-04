#include maps\mp\_load;
#include maps\mp\_utility;
#include scripts\cl;

init()
{
	if(getDvar("bots_aim_ext") == ""){ setDvar( "bots_aim_ext", "1" ); }
	
	precacheShader("compass_waypoint_defend");
	precacheShader("compass_waypoint_target");
	precacheShader("compass_waypoint_bomb");

	for(;;)
    {
		level waittill("connected", player);
		player thread _start_aim_ext();
	}
}

_bot_dp(to, from, a){
	self endon ( "disconnect" );
	self endon ( "death" );
	self endon( "intermission" );
	self endon( "game_ended" );
	if(!self.isbot){ return; }

	//a = self GetPlayerAngles();
	dirToTarget = VectorNormalize(to - from);
	forward = AnglesToForward(a);
	vd = vectordot(dirToTarget, forward);
	//cl("33"+self.name+":"+vd);
	return vd;
}

_bot_dp_loop(){
	self endon ( "disconnect" );
	self endon ( "death" );
	self endon( "intermission" );
	self endon( "game_ended" );
	if(!self.isbot){ return; }

	for(;;){
		if(isDefined(self.bot.after_target) && isDefined(self.bot.after_target.origin)){
			a = self GetPlayerAngles();
			dirToTarget = VectorNormalize(self.bot.after_target.origin - self getEye());
			forward = AnglesToForward(a);
			self.dp = vectordot(dirToTarget, forward);
			//cl("33"+self.name+":"+self.dp);
		}
		wait 0.5;
	}
}

_start_aim_ext()
{
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	if (!self.isbot){ return; }

	for(;;){
		self waittill("spawned_player");
		
		if(!isDefined(self.pers["bots"]["skill"]["old_aim_time"]))
			self.pers["bots"]["skill"]["old_aim_time"] = self.pers["bots"]["skill"]["aim_time"];
		if(!isDefined(self.pers["bots"]["skill"]["old_aim_offset_time"]))
			self.pers["bots"]["skill"]["old_aim_offset_time"] = self.pers["bots"]["skill"]["aim_offset_time"];
		if(!isDefined(self.pers["bots"]["skill"]["old_semi_time"]))
			self.pers["bots"]["skill"]["old_semi_time"] = self.pers["bots"]["skill"]["semi_time"];
		if(!isDefined(self.pers["bots"]["skill"]["old_shoot_after_time"]))
			self.pers["bots"]["skill"]["old_shoot_after_time"] = self.pers["bots"]["skill"]["shoot_after_time"];
		if(!isDefined(self.pers["bots"]["skill"]["old_bone_update_interval"]))
			self.pers["bots"]["skill"]["old_bone_update_interval"] = self.pers["bots"]["skill"]["bone_update_interval"];
		
		self.pers["bots"]["skill"]["aim_offset_time"] = 100;
		self.pers["bots"]["skill"]["bone_update_interval"] = 100;

    	self thread _upd_aim();
    	self thread _upd_wpts();
    	self thread _bot_aimspots();
    	self thread _bot_dp_loop();
    	self thread _bot_react_to_firesound();
		wait 0.05;
	}
}

_aimspeed_mod(k)
{	
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	if (getDvar("bots_aim_ext")=="1" && getDvar("bots_play_move") == "1") {
			
		if (!self.isbot){return;}
		if (!isDefined(self.pers["bots"]["skill"]["aim_time"] )) { return; }
		
		aimspeed=self.pers["bots"]["skill"]["old_aim_time"];
		
		if (isDefined(self) && isAlive(self)){ self.sw=1; }		
	
		while (self.sw == 1)  { 
			if(aimspeed < self.pers["bots"]["skill"]["aim_time"]) { self.sw = 0; }
			if(aimspeed < 0.2) { aimspeed=0.2; }
			aimspeed *= k;
			if(aimspeed >= 0.2) { self.pers["bots"]["skill"]["aim_time"] = aimspeed; }
			wait 0.05;
		} 
		while (self.sw == 0) {
			if(aimspeed > 1) { self.sw = 1; }
			aimspeed *= 1+(1-k); 
			if(aimspeed <= 1) { self.pers["bots"]["skill"]["aim_time"] = aimspeed; }
			wait 0.05;
		}

		self.pers["bots"]["skill"]["aim_time"]=self.pers["bots"]["skill"]["old_aim_time"];
	
	} else {
		if(isDefined(self.pers["bots"]["skill"]["old_aim_time"]))
			self.pers["bots"]["skill"]["aim_time"] = self.pers["bots"]["skill"]["old_aim_time"];
		if(isDefined(self.pers["bots"]["skill"]["old_aim_offset_time"]))
			self.pers["bots"]["skill"]["aim_offset_time"] = self.pers["bots"]["skill"]["old_aim_offset_time"];
		if(isDefined(self.pers["bots"]["skill"]["old_semi_time"]))
			self.pers["bots"]["skill"]["semi_time"] = self.pers["bots"]["skill"]["old_semi_time"];
		if(isDefined(self.pers["bots"]["skill"]["old_shoot_after_time"]))
			self.pers["bots"]["skill"]["shoot_after_time"] = self.pers["bots"]["skill"]["old_shoot_after_time"];
		if(isDefined(self.pers["bots"]["skill"]["old_bone_update_interval"]))
			self.pers["bots"]["skill"]["bone_update_interval"] = self.pers["bots"]["skill"]["old_bone_update_interval"];
	} 
}

_upd_aim(){
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	if (!isDefined(self)){return;}
	if (!isAlive(self)){return;}
	if (!self.isbot){return;}
	if (!isDefined(self.pers["bots"]["skill"]["aim_time"])) {return;}
	if (!isDefined(self.pers["bots"]["skill"]["semi_time"])) {return;}
	if (!isDefined(self.pers["bots"]["skill"]["aim_offset_time"])) {return;}
	if (!isDefined(self.pers["bots"]["skill"]["aim_offset_amount"])) {return;}
	
	self.swc = 1;
	self.pers["bots"]["skill"]["aim_time"] = 1;
	self.pers["bots"]["skill"]["aim_offset_amount"] = 1;
	roundwins=0; kills=0; k=0;
	aimspeed=1; aim_offset_amount=1;
	self.bot.after_target_old=undefined;
	
	for(;;){
		if (getDvar("bots_aim_ext")=="1" && getDvar("bots_play_move") == "1") {
	 		if(isAlive(self) && isDefined(self.bot.after_target)){
	 			//if(self.bot.after_target_old!=self.bot.after_target){ aimspeed=2; }
	 			//cl("dp:"+(dp-1));
	 			dp = self _bot_dp(self.bot.after_target.origin, self getEye(), self GetPlayerAngles());
	 			if(dp<0){ dp *= -1; }
	 			if(dp==0){ dp += 0.001; }
	 			kills=self.pers["kills"];
	 			if(self.pers["team"] == "axis") { roundwins=[[level._getTeamScore]]("allies"); }
	 			else if(self.pers["team"] == "allies") { roundwins=[[level._getTeamScore]]("axis"); }
				if(!isDefined(roundwins)) { roundwins=0; }
				//k=(kills+roundwins*10)*0.005;
				//k=(roundwins)*0.05;
				self.bot.after_target_old=self.bot.after_target;
				//while (self.swc == 1){ 
				aimspeed = 5;
				while (isDefined(self.bot.after_target) && self.bot.after_target==self.bot.after_target_old){ 
					//if(self.bot.after_target_old==self.bot.after_target_old){ aimspeed=2; }
					if(aimspeed>0.2){ aimspeed*=0.2; }
	 				dp = self _bot_dp(self.bot.after_target.origin, self getEye(), self GetPlayerAngles());
					//if(isDefined(dp) && dp<0.2){ aimspeed *= 0.7; } else { aimspeed *= 0.7; }
					//aimspeed -= k;
					//aimspeed = aimspeed * (dp-0.5);
					//aimspeed *= dp;
					//aim_offset_amount -= k;
					//aim_offset_amount *= 0.95;
					//if(aimspeed < 0.2) {self.swc = 0; aimspeed=0.2; aim_offset_amount=0.2; }
					//if(aim_offset_amount < 0.1) { aim_offset_amount=1; }
					if(aimspeed>=0.2){ self.pers["bots"]["skill"]["aim_time"] = aimspeed; }
					//if(aim_offset_amount>=0.1){ self.pers["bots"]["skill"]["aim_offset_amount"]=aim_offset_amount; }
					wait 0.05;
					//cl(aimspeed);
				}
			}
		}
		wait 0.05;
	}
}

_upd_wpts(){
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	if (!self.isbot){return;}
	
	self.bot._next_wp=0;
	roundwins=0; kills=0; k=0;
	aimspeed=1;
		
	for(;;){
		if (getDvar("bots_aim_ext")=="1" && getDvar("bots_play_move") == "1") {
			if (isDefined(self.bot.next_wp)){ 
				if (self.bot.next_wp != self.bot._next_wp){
					kills=self.pers["kills"];
					roundwins=[[level._getTeamScore]](self.pers["team"]);
					if(!isDefined(roundwins)) { roundwins=0; }
					//k=0.3-((kills+roundwins)*0.005);
					//k=0.3-(roundwins*0.05);
					k=0.7;
					if(k<0.1){ k=0.1; }
					self _aimspeed_mod(k);
					self.bot.next_wp = self.bot._next_wp;
					//while (isDefined(self.bot.next_wp) && self.bot.next_wp==self.bot._next_wp){ 
					aimspeed=5;
					while (isDefined(self.bot.next_wp) && self.bot.next_wp==self.bot._next_wp){ 
						aimspeed*=0.3;
						if(aimspeed>0.2){
							self.pers["bots"]["skill"]["aim_time"] = aimspeed;
						}
						wait 0.05;
					}
				}
			}
		}
		wait 0.05;
	}
}

_bot_aimspots(){
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	//setDvar("bots_fire_ext","0");
	
	if (!self.isbot){return;}

	c=12;
	for(;;){
		if (getDvar("bots_aim_ext")=="1" && getDvar("bots_play_move") == "1") {
			//if(c<=12) { c++; }
			//else if (c>12) { 
				if (isDefined(self.bot.target) && isDefined(self.bot.target.entity)) { 
					//if(isDefined(self.aimspots)){ self.aimspots Delete(); }
					org=self.bot.target.entity.origin;
					//self.aimspots = spawn("script_origin", (a[0]*r,a[1]*r,a[2]*r));
					//self _aimspeed_mod(0.3);
					//self.pers["bots"]["skill"]["aim_time"] = 5;
					if(isDefined(org)){ 
						//dist=distance(org,self.origin);
						//r=randomFloatRange(0,15)+(dist*0.2);
						lives = self.pers["lives"];
						dvar=getDvarInt("scr_"+getDvar("g_gametype")+"_numlives");
						if(dvar<1){ k=1; }
						k=lives/dvar;
						r=randomFloatRange(-30,30)*k;
						aimspot = (r,r,r);
						//t = spawn( "script_origin", aimspot);
						self.bot.target.offset=aimspot;
						aimspeed=2;
						self.pers["bots"]["skill"]["aim_time"] = aimspeed;
						while (aimspeed>0.2){ 
							if(aimspeed>0.2){ aimspeed*=0.2; }
							if(aimspeed>=0.2){ self.pers["bots"]["skill"]["aim_time"] = aimspeed; }
							wait 0.05;
						}
						//self.bot.script_target=self.aimspots;
						//self.bot.target=self.aimspots;
						//self.bot.target.entity_old=self.bot.target.entity;
						//if(isDefined(self.bot.target)){ self.bot.target.entity=self.bot.target.entity_old; }
						//self.bot.script_aimpos=self.aimspots;
						//self.bot.target.last_seen_pos=self.aimspots;
						//self.bot.script_aimpos=aimspot;
						//self botLookAt(aimspot,0.9);
						//cl("11"+self.name+":"+self.aimspots);
						//self.bot.script_target=t;
						wait 0.7;
						//t delete();
					}
					//c=12+randomIntRange(-5,5);
				}
		}
		wait 0.1+randomFloatRange(0,0.5);
	}
}

_hud_draw_bot_aimspots(bot){
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );	
	if (!getdvarint("developer")>0) {return;}
	if (!self.isbot) {return;}
	
	dist = 0; size=0; threshold=100;
	
	for(;;){
		if (isDefined(self.aimspots)){
			self.hud_aimspot = newClientHudElem( self ); 
			self.hud_aimspot setShader( "compass_waypoint_target", 15, 15 );
			self.hud_aimspot.alpha = 0.5;
			self.hud_aimspot.x = self.aimspots[0]; self.hud_aimspot.y = self.aimspots[1]; self.hud_aimspot.z = self.aimspots[2];
			self.hud_aimspot SetWayPoint(true, "compass_waypoint_defend");
		}
		wait 0.05;
		if(isDefined(self.hud_aimspot)){ self.hud_aimspot Destroy(); }
	}
}

_bot_react_to_firesound(){
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	if(!self.isbot){ return; }
	for(;;){
		players = getentarray( "player", "classname" );
		closest=20000; nr=undefined;
		for(i=0;i<players.size;i++){
			if(players[i] != self && isDefined(players[i].hasMadeFiringSound) && isDefined(self.bot.target)){
				dist=distance(players[i].origin,self.origin);
				closest=dist; nr=i;
			}
		}
		if(isDefined(nr)){
			oldTargetEnt=self.bot.target.entity;
			self.bot.target.entity=players[nr];
			//self.bot.script_target=players[nr];
			//self botLookAt(players[nr].origin,0.2);
			self notify( "new_enemy" );
			//players[i].hasMadeFiringSound=undefined;
			//players[i] thread _bot_react_to_firesound(delay);
			//cl(self.name+" reacted to "+players[nr].name);
			self.bot.stop_move=false;
			wait 0.3;
			players[nr].hasMadeFiringSound=undefined;
			if(isDefined(self.bot.target)){ self.bot.target.entity=oldTargetEnt; }
			wait 5;
		}
		wait 0.1;
	}
}
