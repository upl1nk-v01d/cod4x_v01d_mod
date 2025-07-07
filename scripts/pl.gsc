#include scripts\cl;

pl(txt, color)
{		
	if(isDefined(txt) && txt != "" && txt.size > 0)
	{ 
		if(!isDefined(color)){ color = color(); }
		
		iprintln(color + "-- " + txt + " -- \n"); 
	}
}
