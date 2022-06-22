init()
{
	level.originalcallbackStreak = level.callbackStreak;
    level.callbackStreak = ::giveHardpointItemForStreak;
    //level.giveHardpointItemForStreak = ::giveHardpointItemForStreak;
    level.streakNotify = maps\mp\gametypes\_hardpoints::streakNotify;
    level.giveHardpoint = maps\mp\gametypes\_hardpoints::giveHardpoint;
    print("hp_mod init\n");
}

_giveHardpointItemForStreak()
{
	streak = self.cur_kill_streak;
	
	//if ( streak < 3 )
	//	return;

	if ( !getDvarInt( "scr_game_forceuav" ) )
	{
		if ( streak == 1 ){
			self [[level.giveHardpoint]]( "radar_mp", streak );
			print(self.name+":"+streak+":called UAV\n");
		}
		else if ( streak == 5 )
			self [[level.giveHardpoint]]( "airstrike_mp", streak );
		else if ( streak == 7 )
			self [[level.giveHardpoint]]( "helicopter_mp", streak );
		else if ( streak >= 10 )
		{
			if ( (streak % 5) == 0 )
				self [[level.streakNotify]]( streak );
		}
	}
	else
	{
		if ( streak == 3 )
		{
			self [[level.giveHardpoint]]( "airstrike_mp", streak );
		}
		else if ( streak == 5 )
		{
			self [[level.giveHardpoint]]( "helicopter_mp", streak );
		}
		else if ( streak >= 10 )
		{
			if ( (streak % 5) == 0 )
				self [[level.streakNotify]]( streak );
		}
	}
	self [[level.originalcallbackStreak]]();
}
