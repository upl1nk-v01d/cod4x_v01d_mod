color(color)
{
	color = "^3";
	
	if(!isDefined(color)){ color = "^3"; }
	
	if(color == "white"){ color = "^0"; }
	if(color == "red"){ color = "^1"; }
	if(color == "green"){ color = "^2"; }
	if(color == "yellow"){ color = "^3"; }
	if(color == "darkblue"){ color = "^4"; }
	if(color == "blue"){ color = "^5"; }
	if(color == "violet"){ color = "^6"; }
	if(color == "grey"){ color = "^7"; }
	if(color == "darkgrey"){ color = "^8"; }
	
	return color;
}

cl(txt, color)
{		
	if(isDefined(txt) && txt != "" && txt.size > 0)
	{ 
		c = "^3";
		
		if(!isDefined(color)){ c = color(); }
		else{ c = color(color); }
				
		print(c + "-- " + txt + " -- \n"); 
	}
}
