//
cl(txt)
{
	//if (!getdvarint("developer")>0) { return; }
	txt += "";
	
	if(isDefined(txt) && txt.size > 0)
	{ 
		_txt="";
		if(txt[0]!=txt[1])
		{
			print("^3-- "+txt+" -- \n"); 
		} 
		else if (txt[0]==txt[1])
		{
			for(i=2;i<txt.size;i++)
			{
				_txt+=txt[i];
			}
			print("^"+txt[0]+"-- "+_txt+" -- \n"); 
		} 
		else 
		{
			print("-- "+_txt+" -- \n"); 
		}
	}
	else 
	{ 
		print("^1!! undefined !! \n"); 
	}
}
