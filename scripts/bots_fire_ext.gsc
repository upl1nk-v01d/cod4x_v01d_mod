#include maps\mp\_load;
#include maps\mp\_utility;

init()
{
	if(getDvar("bots_fire_ext") == ""){ setDvar( "bots_fire_ext", "1" ); }
	if(getDvar("bots_play_fire") == "1"){ setDvar( "bots_play_fire", "0" ); }
	
	precacheShader("compass_waypoint_defend");
	precacheShader("compass_waypoint_target");
	precacheShader("compass_waypoint_bomb");
	
	for(;;)
    {
		level waittill("connected", player);
		player thread _start_fire_ext();
	}
}

_start_fire_ext()
{
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	if (!self.isbot){ return; }

	self waittill("spawned_player");  

    self thread _bot_fire();
	wait 0.05;
}

_bot_fire(){
	//self endon ( "death" );
	self endon ( "disconnect" );
	self endon( "intermission" );
	self endon( "game_ended" );
	if(!self.isbot){ return; }
	
	stances=strTok("crouch,prone,stand",",");
	stance=undefined;
	
	for(;;){
		if (getDvarInt("bots_fire_ext")>0 && getDvar("bots_play_fire") != "1" && getDvar("bots_play_move") == "1"){
			if(isAlive(self)){
				if (isDefined(self.bot.script_target)){
					//cl("^1"+self.bot.script_target.name);
					if (self.bot.script_target.model == "vehicle_mi24p_hind_desert" || self.bot.script_target.model == "vehicle_cobra_helicopter_fly") { 
						//cl("^3"+self.bot.script_target.model);
						self _bot_press_fire(0.3,self.bot.script_target);
					}
				}				
				if (isDefined(self.bot.after_target)) { 
					//cl("^3"+self.bot.after_target.model);
					//isSubStr
					//vehicle_mi24p_hind_desert
					//vehicle_cobra_helicopter_fly
					stance=self getStance();
					dist=distance(self.bot.after_target.origin,self.origin);
					if (stance == "stand" || stance == "crouch"){ self.bot.stop_move=true; }
					else { self.bot.stop_move=false; }
					if (isDefined(level.classBoltSniper)) { 
						for (i=0;i<level.classBoltSniper.size;i++){
							if (isSubStr( self GetCurrentWeapon(), level.classBoltSniper[i])){ 
								if(!isDefined(stance)) { 
									stance=stances[randomIntRange(0,3)]; 
									self botAction("+go"+stance);
									self botAction("-ads");
								}
								self.bot.stop_move=true; break;
 							}
						}
					}
					self botAction( "-gocrouch" );
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

_bot_press_fire(delay,target)
{
	self endon("death");
	self endon("disconnect");
	self notify("bot_fire");
	self endon("bot_fire");
	
	if(!isDefined(delay)) { delay = 0.3; }
		
	wait delay;

	dist=distance(target.origin,self.origin);
	duration=randomFloatRange(0.05,0.3)+(1/(dist*2));
	self botAction("+fire");
	self.pers["bots"]["skill"]["aim_time"] = 5;
	if(duration) { wait duration; }
	self botAction("-fire");
	if(duration) { wait duration/2; }
	target = undefined;
}

cl(txt){
	if (isDefined(txt)){ print("^2-- "+txt+" -- \n"); }
	else { print("^3!! undefined !! \n"); }
}
