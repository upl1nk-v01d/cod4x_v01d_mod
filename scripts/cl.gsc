//
cl(txt){
	//if (!getdvarint("developer")>0) { return; }
	_txt="";
	if (isDefined(txt)){ 
		if(txt[0]!=txt[1]){
			print("-- "+txt+" -- \n"); 
		} else if (txt[0]==txt[1]){
			for(i=2;i<txt.size;i++){
				_txt+=txt[i];
			}
			print("^"+txt[0]+"-- "+_txt+" -- \n"); 
		}
	}
	else { print("!! undefined !! \n"); }
}
