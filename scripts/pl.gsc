//
pl(txt)
{
	//if (!getdvarint("developer")>0) { return; }
	txt += "";
	
	if(isDefined(txt) && txt.size > 0)
	{ 
		_txt="";
		
		if(txt[0]!=txt[1])
		{ 
			iprintln("^3-- "+txt+" -- \n"); 
		} 
		else if (txt[0]==txt[1])
		{
			for(i=2;i<txt.size;i++)
			{
				_txt+=txt[i];
			}
			iprintln("^"+txt[0]+"-- "+_txt+" -- \n");  
		} 
		else 
		{ 
			iprintln("-- "+_txt+" -- \n"); 
		}
	}
	else 
	{ 
		iprintln("^1!! undefined !! \n"); 
	}
}
