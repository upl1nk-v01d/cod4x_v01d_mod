#include scripts\cl;
#include scripts\pl;

_dp(from, to, angles)
{
	dirToTarget = VectorNormalize(to - from);
	forward = AnglesToForward(angles);
	vectorDot = vectordot(dirToTarget, forward);
	//cl(self.name + ":" + vectorDot);
	
	return vectorDot;
}

_get_head_pos(player)
{
	head = player GetTagOrigin("j_head");
	//head = player getEye();
	
	if(player getStance() == "prone")
	{
		head = (head[0], head[1], head[2]-20);
	}
	
	if(isDefined(player.lastStand))
	{
		head = (head[0], head[1], head[2]-20);
	}
	
	return head;
}
