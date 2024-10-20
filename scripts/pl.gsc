//
pl(txt){
	color = "";
	if (isDefined(txt)){
		if(txt[0]=="^")	{ color="^"+txt[1]; }
		iprintln(color+"-- "+txt+" -- \n"); 
	} else { iprintln("!! undefined !! \n"); }
}
