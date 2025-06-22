#include maps\mp\_load;
#include maps\mp\_utility;
#include scripts\cl;

init()
{
	if(getDvar("bots_fire_ext") == ""){ setDvar( "bots_fire_ext", "1" ); }
	if(getDvar("bots_play_fire") == "1"){ setDvar( "bots_play_fire", "0" ); }
	
	precacheShader("compass_waypoint_defend");
	precacheShader("compass_waypoint_target");
	precacheShader("compass_waypoint_bomb");
	
	if(getDvar("bots_fire_ext") != "1"){ return; }
	
	for(;;)
    {
		level waittill("connected", player);
		
		player thread _spawn_loop();
	}
}

_spawn_loop()
{
	self endon ( "disconnect" );
	self endon( "intermission" );
	level endon( "game_ended" );
	
	if (!self.isbot){ return; }

	for(;;)
	{
		self waittill("spawned_player");  
	
    	self thread _bot_fire();
    	self thread _bot_stop_when_prone();
    	
		wait 0.05;
	}
}

_bot_fire(){
	self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	level endon( "game_ended" );
	
	if(!self.isbot){ return; }
	
	stances=strTok("stand,crouch,prone",",");
	stance=undefined;
	
	for(;;){
		if (getDvar("bots_fire_ext") == "1" && getDvar("bots_play_fire") != "1"){
			if(isAlive(self) && isDefined(self.dp) && self.dp>0.95){
				if (isDefined(self.bot.script_target)){
					//cl("33"+self.name+" target model: "+self.bot.script_target.model);
					if (self.bot.script_target.model == "c4_mp" || self.bot.script_target.model == "claymore_mp") { 
					//if (self.bot.script_target.model == "c4_mp") { 
						self.bot.script_target=undefined;
					}
					if (self.bot.script_target.model == "vehicle_mi24p_hind_desert" || self.bot.script_target.model == "vehicle_cobra_helicopter_fly") { 
						vis = self SightConeTrace(self getEye(), self.bot.script_target);
						cl("vis:" + vis);
						if(vis > 0)
						{
							//cl("33"+self.bot.script_target.model);
							self _bot_press_fire(0.3,self.bot.script_target);
						}
					}
				}				
				if (isDefined(self.bot.after_target)) { 
					//cl("33"+self.bot.after_target.model);
					//isSubStr
					//vehicle_mi24p_hind_desert
					//vehicle_cobra_helicopter_fly
					stance=self getStance();
					dist=distance(self.bot.after_target.origin,self.origin);
					//self.bot.isfrozen=true;
					//self.bot.stop_move=true;
					//self notify( "kill_goal" );
					//if (stance == "stand" || stance == "crouch"){ self.bot.stop_move=false; }
					//else { self.bot.stop_move=true; }
					if (isDefined(level.classBoltSniper)) { 
						for (i=0;i<level.classBoltSniper.size;i++){
							if (isSubStr( self GetCurrentWeapon(), level.classBoltSniper[i])){ 
								stance=stances[randomIntRange(1,3)]; 
								self botAction("+go"+stance);
								//self botAction("-ads");
								self.bot.stop_move=true; 
								break;
 							}
						}
					} 
					if(dist>600){
						stance=stances[randomIntRange(1,3)]; 
						//self setMoveSpeedScale(0);
						//self botAction("+go"+stance);
						//self botAction( "-gostand" );
						self.bot.stop_move=true;
						self botMoveTo(self.origin);
						//cl("33"+self.name+" stance:"+stance);
					} else {
						self setMoveSpeedScale(1);
					}
					//self botAction( "-gocrouch" );
					//self botAction( "-goprone" );
					delay=randomFloatRange(0.1,0.2)+(dist/4*0.001);
					self _bot_press_fire(delay,self.bot.after_target);
				} else {
					wait 1;
					if(isDefined(stance)) { 
						self.bot.stop_move=false;
						self botAction("-go"+stance);
					}
				}
			}
		}
		wait 0.1;
	}
}

_bot_stop_when_prone(){
	self endon("death");
	
	while(isAlive(self)){
		stance=self getStance();
		if (stance == "prone")
		{ 
			self botMoveTo(self.origin); 
			self.bot.stop_move=true;
		}
		else
		{
			self.bot.stop_move=false;
		}
		wait 0.05;
	}
}

_bot_press_fire(delay,target)
{
	self endon("death");
	self endon("disconnect");
	//self notify("bot_fire");
	//self endon("bot_fire");
	
	if(!isDefined(delay)) { delay = 0.3; }
	
	point = target.origin;

	wait delay;

	if(isDefined(target)){
		stance=self getStance();
		if (stance == "stand" || stance == "crouch"){ self.bot.stop_move=true; }
		if (stance == "prone"){ self.bot.stop_move=true; }
		//if (isDefined(self.isProning) && isDefined(self.isFiring)){ self.bot.stop_move=true; }
		dist=distance(target.origin,self.origin);
		duration=randomFloatRange(0.05,0.3)+(1/(dist*2));
		self botAction("+fire");
		//self.pers["bots"]["skill"]["aim_time"] = 5;
		if(duration) { wait duration; }
		self botAction("-fire");
		if(duration) { wait duration/2; }
		target = undefined;
		//self.bot.stop_move=false;
	}
	
	wait delay;
	target = self.bot.after_target;
	if(!isDefined(target)){
		dist=distance(point,self.origin);
		duration=randomFloatRange(0.05,0.3)+(1/(dist*2));
		self botAction("+fire");
		if(duration) { wait duration; }
		self botAction("-fire");
	}
	//self.pers["bots"]["skill"]["aim_time"] = 0.5;
}
