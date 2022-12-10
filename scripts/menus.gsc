#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include scripts\cl;

init()
{
	//if (!getdvarint("developer")>0){ return; }
	if (getdvarint("bots_main_debug")>0){ return; }
	
	if (!isDefined(game["hasReadMOTD"])){ game["hasReadMOTD"]=[]; }
	if (!isDefined(game["hasReadHintMessage"])){ game["hasReadHintMessage"]=[]; }

	level thread _connecting_loop();
	level thread _connected_loop();
}

_connecting_loop(){
	//level endon ( "disconnect" );
	//level endon( "intermission" );
	//level endon( "game_ended" );
	//if (getdvarint("developer")>0){ return; }
	//if(self.isbot){ return; }
	
	for(;;){
		level waittill( "connecting", player );
		wait 0.05;
	}
}

_connected_loop(){
	//level endon ( "disconnect" );
	//level endon( "intermission" );
	//level endon( "game_ended" );
	//if (getdvarint("developer")>0){ return; }
	//if(self.isbot){ return; }
		
	for(;;){
		level waittill("connected", player);
		player thread _money_menu();
		player thread _welcome_msg();
		player thread _spawn_loop();
		player thread _map_datetime_menu();
		//player thread _show_message(3,"TEST TEST TEST",1,1,1,0,1,-200,-80);
		//player thread _keystrokes();
		//wait 0.1;
		//player setClientDvar( "ui_lobbypopup", "summary" );
	}
}

_spawn_loop(){
	self endon ( "disconnect" );
	//self endon ( "death" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	if (!isDefined(game["hasReadMOTD"][self.name])){ game["hasReadMOTD"][self.name]=false; }
	if (!isDefined(game["hasReadHintMessage"][self.name])){ game["hasReadHintMessage"][self.name]=false; }
	
	for(;;){
		self waittill("spawned_player");
		while(level.inPrematchPeriod){ wait 0.1; }
		
		self thread _buy_menu_main();
		//self thread _buy_menu_iterate();
			
		wait 1;
		if(game["hasReadHintMessage"][self.name]==false){
			//self thread _show_message(0,"TEST TEST TEST",1,1,1,0,1,-200,-80);
			//self _show_hint_msg(0,"press FIRE button to select",1,1,1,0,1,-200,-80);
			//self _show_hint_msg(0,"press ADS button to return",1,1,1,0,1,-200,-70);
			//self _show_hint_msg(0,"buy ammo choosing weapon",1,1,1,0,1,-200,-70);
			//delay,txt,dur,r,g,b,a,ox,oy
			game["hasReadHintMessage"][self.name]=true;
		}
	}
}

_keystrokes(){
	self endon ( "disconnect" );
	self endon ( "death" );
	self endon( "intermission" );
	self endon( "game_ended" );
	if(self.isbot){ return; }
	
	for(;;){
		while (self ForwardButtonPressed()){ cl(self.name+" pressed UP key"); wait 0.5; }
		while (self BackButtonPressed()){ cl(self.name+" pressed DOWN key"); wait 0.5; }
		while (self MoveLeftButtonPressed()){ cl(self.name+" pressed LEFT key"); wait 0.5; }
		while (self MoveRightButtonPressed()){ cl(self.name+" pressed RIGHT key"); wait 0.5; }
		while (self SprintButtonPressed()){ cl(self.name+" pressed SPRINT key"); wait 0.5; }
		while (self ReloadButtonPressed()){ cl(self.name+" pressed RELOAD key"); wait 0.5; }
		while (self LeanLeftButtonPressed()){ cl(self.name+" pressed LEAN LEFT key"); wait 0.5; }
		while (self LeanRightButtonPressed()){ cl(self.name+" pressed LEAN RIGHT key"); wait 0.5; }
		while (self LeanRightButtonPressed()){ cl(self.name+" pressed LEAN RIGHT key"); wait 0.5; }
		while (self HoldBreathButtonPressed()){ cl(self.name+" pressed HOLD BREATH key"); wait 0.5; }
		while (self AimButtonPressed()){ cl(self.name+" pressed AIM key"); wait 0.5; }
		wait 0.05;
		//waittillframeend;
	}
}

_create_menu(align,relative,x,y,width,height,color,sort,alpha,shader){
	self.Menu = undefined;
	self.Menu = self createRectangle(align,relative,x,y,width,height,color,sort,alpha,shader);
}

_create_menu_text(hud,arr,ft,fsz,fsc,color,glow,ax,ay,w,h,a,sort,selector,scolor,div,skip){
	self endon ( "disconnect" );
	self endon ( "death" );
	self endon( "intermission" );
	self endon( "game_ended" );
	if(self.isbot){ return; }
	//if(!isAlive(self)){ return; }

	self.money[hud]=[]; size=arr.size;
	if(!isDefined(scolor)){ scolor=(0,0,0); }
	if(!isDefined(div)){ div=1; }
	if(!isDefined(a)){ a=1; }
	if(div>1){ size=arr.size/div; }
	if(!isDefined(skip)){ skip=0; }
	
	//cl("^3hud:"+hud);
	//cl("^3arr.size:"+arr.size);
	//cl("^3size:"+size);
	//cl("^3div:"+div);
	for(i=0;i<size;i++){
		//cl("i:"+i);
		self.money[hud][i] = undefined;
		self.money[hud][i] = self createfontstring(ft, fsz);
		self.money[hud][i] setpoint(ax, ay, w, h+i*10);
		if(div>1){ 
			//txt=arr[i*div]; 
			txt=arr[i*div+1]+"$ - "+arr[i*div]; 
			if(isDefined(txt)){
				//cl("txt:"+txt);
				self.money[hud][i] settext(txt);
			}
		}
		else { self.money[hud][i] settext(arr[i]); }
		self.money[hud][i].alpha = a;
		self.money[hud][i].sort = sort;
		self.money[hud][i].fontscale = fsc;
		self.money[hud][i].color = color;
		if(isDefined(selector) && selector-1 == i) { self.money[hud][i].color=scolor; }
		self.money[hud][i].glowAlpha = glow;
		//if(div>0){ i+=div; }
	}
}

_create_menu_bg(bg,align,relative,x,y,w,h,color,sort,alpha,sh,aperc,ha,va){
	self endon ( "disconnect" );
	self endon ( "death" );
	self endon( "intermission" );
	self endon( "game_ended" );
	if(self.isbot){ return; }
	
	alpha=alpha*(aperc/100);
	self.money[bg] = undefined;
	self.money[bg] = self createRectangle(align,relative,x,y,w,h,color,sort,alpha,sh,ha,va);
}

_destroy_menu(menu,size,delay){
	//self endon ( "disconnect" );
	//self endon ( "death" );
	//self endon( "intermission" );
	//self endon( "game_ended" );
	
	if(!isDefined(self.money)){ return; }
	if(!isDefined(menu)){ return; }
	if(!isDefined(delay)){ delay=1; }

	c=0; size=menu.size;

	if(isDefined(self.money) && isArray(self.money)){		
		for(i=0;i<size;i++){
			if(isDefined(self.money[menu][i])){
				self.money[menu][i] destroy();
				//self.money[menu][i] = undefined;
				c++;
			}
		}
		//cl("^3menu.size:"+c);
	}

}

_destroy_bg(menu,size,delay){
	if(!isDefined(self.money)){ return; }
	if(!isDefined(menu)){ return; }
	if(!isDefined(delay)){ delay=1; }

	c=0; size=menu.size;

	if(isDefined(self.money) && isArray(self.money)){		
		for(i=0;i<size;i++){
			if(isDefined(self.money[menu])){
				self.money[menu] destroy();
				//self.money[menu][i] = undefined;
				c++;
			}
		}
		//cl("^3menu.size:"+c);
	}

}

initHudElem(txt, xl, yl)
{
	hud = NewClientHudElem( self );
	hud setText(txt);
	hud.alignX = "center";
	hud.alignY = "bottom";
	hud.horzAlign = "center";
	hud.vertAlign = "bottom";
	hud.x = xl;
	hud.y = yl;
	hud.foreground = true;
	hud.fontScale = 1.4;
	hud.font = "objective";
	hud.alpha = 1;
	hud.glow = 0;
	hud.glowColor = ( 0, 0, 0 );
	hud.glowAlpha = 1;
	hud.color = ( 1.0, 1.0, 1.0 );
	return hud;
}

createRectangle(align,relative,x,y,width,height,color,sort,alpha,shader,ha,va)
{
	barElemBG = newClientHudElem( self );
	barElemBG.elemType = "bar_";
	barElemBG.width = width;
	barElemBG.height = height;
	barElemBG.align = align;
	barElemBG.relative = relative;
	barElemBG.xOffset = 0;
	barElemBG.yOffset = 0;
	barElemBG.children = [];
	barElemBG.sort = sort;
	barElemBG.color = color;
	barElemBG.alpha = alpha;
	barElemBG.horzAlign = ha;
    barElemBG.vertAlign = va;	
    barElemBG setParent( level.uiParent );
	if(isDefined(shader)){ barElemBG setShader( shader, width , height ); }
	barElemBG.hidden = false;
	barElemBG setPoint(align,relative,x,y);
	return barElemBG;
}

_get_motd_txt(d){
	if(!isDefined(self.readDay)){ self.readDay=0; }
	if(!isDefined(self.prevReadDay)){ self.prevReadDay=-1; }
	realTime = getRealTime()-(86400*self.readDay);
	realDate = TimeToString(realTime, 0, "%F");
	dateTime = TimeToString(realTime, 0, "%F %T");
	//dateTime = StrRepl(playername, ":", "_");
	filename = "motd/"+realDate+".log";
	line="";
	lines=[];
	chars=[];
	dates=[];
	//cl("^3realDate: " + realDate);
	
	//lines[0]="^2"+realDate+"\n";
	while (!FS_TestFile(filename) && self.readDay>=0){ 
		cl("^1No log file on date "+realDate+" available!"); 
		//lines[1]="^1\n\n\nNo Report";
		realTime = getRealTime()-(86400*self.readDay);
		realDate = TimeToString(realTime, 0, "%F");
		dateTime = TimeToString(realTime, 0, "%F %T");
		lines[0]="^2"+realDate+"\n";
		filename = "motd/"+realDate+".log";
		if(self.readDay>self.prevReadDay){ self.readDay++; }
		else if(self.ReadDay<self.prevReadDay){ self.readDay--; }
		if(self.readDay<=0){ self.readDay=0; break; }
		level waittill("timers");
	}
	self.prevReadDay=self.readDay;

	csv = FS_FOpen(filename, "read");
	line = FS_ReadLine(csv);
	lines[0]="^2"+realDate+"\n";
	lines[1]="\n";
	while (isDefined(line) && line != ""){
		cl("^3line: " + line);
		if (line == "") { continue; }
		lines[1]+=line+"\n";
		line = FS_ReadLine(csv);
	}
	FS_FClose(csv);
		
	//return lines;
	/*div=lines.size/256; c=0;
	for(d=0;d<div;d++){
		for(i=0;i<lines;i++){
			chars[d]+=lines[c]; 
		}
	}
	return chars;*/

	lines[2]="\n\n\n\n\n\n\n\n^2Press LEFT or RIGHT button to navigate\n";
	lines[2]+="^1Press JUMP button to destroy this message\n";
	return lines;
}

//---------------------------------------------------------------------------------------------------


_show_message(delay,txt,dur,r,g,b,a,ox,oy){
	self endon ( "disconnect" );
	//self endon ( "death" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	if (self.isbot){ return; }
	if (!isDefined(delay)){ delay=1; }
	if (!isDefined(dur)){ dur=5; }
	if (!isDefined(r)){ r=1; }
	if (!isDefined(g)){ g=1; }
	if (!isDefined(b)){ b=1; }
	if (!isDefined(a)){ a=1; }
	if (!isDefined(ox)){ ox=0; }
	if (!isDefined(oy)){ oy=0; }
	
	_a=1;
	_ox=ox;
	_oy=oy;
	self.showMessage=true;
	size=0;
	blob="asdfghjklqwertyuiopzxcvbnm";
	c=0; cm=-1; ch=[];
	m=0;
	_m=8;
	ntxt=txt;
	exit=false;

	wait delay;
	cl("33show_message");
	for(i=0;i<txt.size;i++){ ch[i]=0; }
	while(1){
		hudMessage[m]=[];
		hudMessage[m][0]="";
		skip=false;
		
		for(i=0;i<txt.size;i++){
			r=randomIntRange(0,blob.size);
			if(ch[i]==0){ hudMessage[m][0]=blob[r]; }
			//if(cm>-1 && cm<txt.size && cm>i && skip==false){ 
			//if(cm>-1 && cm<txt.size && ch[cm]==0 && skip==false){ 
			if(cm>-1 && cm<txt.size && ch[cm]==0 && skip==false){ 
				hudMessage[m][0]=txt[i]; 
				ch[i]=1;
				//skip=true;
				//cm++;
			}
			self _create_menu_text("hudMessage"+i,hudMessage[m],"default", 1.6,1.4,(r,g,b),0,"CENTER","CENTER",ox,oy,_a,1);
			self playLocalSound("mouse_click");
			ox+=8;
			m++;
			wait 0.5;
		}
		if(cm>=txt.size-1){ wait dur; exit=true; }
		//cl("33cm:"+cm);
		wait 0.5;
		for(i=0;i<hudMessage.size;i++){
			self _destroy_menu("hudMessage"+i); 
		}
		ox=_ox;
		m=0;
		
		//for(i=0;i<txt.size;i++){ cl("33ch["+i+"]="+ch[i]); 
		if(c<1){ c++; }
		else{ c=0; if(cm<txt.size){ cm++; }}
		//else{ c=0; }
		//wait 0.1;
		if(exit==true){ break; }
	}
}

_show_hint_msg(delay,txt,dur,r,g,b,a,ox,oy){
	self endon ( "disconnect" );
	//self endon ( "death" );
	self endon( "intermission" );
	self endon( "game_ended" );
	if (self.isbot){ return; }
	//if (!isDefined(txt)){ return; }
	if (!isDefined(dur)){ dur=5; }
	if (!isDefined(r)){ r=1; }
	if (!isDefined(g)){ g=1; }
	if (!isDefined(b)){ b=1; }
	if (!isDefined(a)){ a=1; }
	if (!isDefined(ox)){ ox=0; }
	if (!isDefined(oy)){ oy=0; }
	
	_a=1;
	hudHint=[];
	hudHint[0]="";
	self.showHint=true;
	wait delay;
	size=0;
	blob="asdfghjklqwertyuiopzxcvbnm";
	c=3;
	ntxt=txt;
	//cl("^3_show_hint_msg");
	//cl("33"+size);
	
	//while(_a<a){
	while(size<txt.size){
		r=randomIntRange(0,blob.size);
		//blob[size]=rarr[r];
		//while(txt[r] == " " && r>0){ r--; }
		//blob = StrRepl(txt,txt[size],rarr[r]); 
		//if(c<0){ txt = StrRepl(txt,txt[size-2],txt[size]); }
		if(c<0){ size++; c=1; }
		//hudHint[0]="";
		ntxt="";
		//txt[size]=blob[r];
		for(i=0;i<size;i++){ ntxt+=txt[i]; }
		if(size<txt.size){ hudHint[0]=ntxt+blob[r]; } else { hudHint[0]=ntxt; }
		self _create_menu_text("hudHint",hudHint,"default", 1.6,1.4,(r,g,b),0,"CENTER","CENTER",ox,oy,_a,1);
		self playLocalSound("mouse_click");
		if(_a<a){ _a+=0.1; }
		wait 0.05;
		c--;
		if(size == txt.size){ wait 2; }
		self _destroy_menu("hudHint"); 
	}
	//wait 1;
	//while(_a>0){
	self playLocalSound("ui_camera_whoosh_in");
	while(size>0){
		r=randomIntRange(0,blob.size);
		//for(i=0;i<txt.size;i++){ if(txt[i] != " "){ txt[i]=" "; }}
		//while(txt[r] == " " && r>0){ r--; }
		txt = StrRepl(txt,txt[r],blob[r]);
		hudHint[0]=txt;
		self _create_menu_text("hudHint",hudHint,"default", 1.6,1.4,(r,g,b),0,"CENTER","CENTER",ox,oy,_a,1);
		//self playLocalSound("mouse_click");
		if(_a==a){ wait dur; }
		if(_a>0){ _a-=0.1; }
		wait 0.05;
		size--;
		//if(size == txt.size){ wait 1; }
		self _destroy_menu("hudHint"); 
	}
	//cl("33"+self.name+" hud ended");
}

_welcome_msg(){
	self endon ( "disconnect" );
	//self endon ( "death" );
	self endon( "intermission" );
	self endon( "game_ended" );
	if (self.isbot){ return; }
	
	//if(!isDefined(self.readDay)){ self.readDay=0; };
	//if(!isDefined(self.prevReadDay)){ self.prevReadDay=-1; };

	self closeMenu();
	self closeInGameMenu();
	//self freezeControls(true);
	
	wait 0.3;
		
	hudWelcome=[]; hudWelcomeBG=[];
	hudWelcome[0]="Welcome to my -=sabotage=- server! :)";
	c=0;r=0;g=0;b=0;a=0;
	w=1;h=1;
	//while(!isDefined(self.money)) { wait 0.5; }
	
	while(r<1){
		//self _create_menu_bg("hudWelcomeBG","CENTER","CENTER",0,0,400,400,(r,g,b),1001,a,"black",50);
		self _create_menu_text("hudWelcome",hudWelcome,"default", 1.6,1.4,(r,g,b),0,"CENTER","CENTER",0,-70,a,1);
		if(r<1){ r+=0.1;g+=0.1;b+=0.1;a+=0.1; }
		level waittill("timers");
		//wait 0.05;
		//self _destroy_menu(self.money["hudWelcomeBG"]);
		self _destroy_menu("hudWelcome");
		//self _destroy_bg("hudWelcomeBG");
		c++;
		//wait 0.05;
	}
	while(r>0){
		//self _create_menu_bg("hudWelcomeBG","CENTER","CENTER",0,0,400,400,(r,g,b),1001,a,"black",50);
		self _create_menu_text("hudWelcome",hudWelcome,"default", 1.6,1.4,(r,g,b),0,"CENTER","CENTER",0,-70,a,1);
		if(r==1){ wait 1; }
		//self _create_menu_text("hudWelcome",txt,"default", 1.6,1.4,(1,1,1),0,"CENTER","CENTER",0,0,1,1);
		if(r>0){ r-=0.1;g-=0.1;b-=0.1;a-=0.1; }
		level waittill("timers");
		//wait 0.05;
		self _destroy_menu(self.money["hudWelcomeBG"]);
		self _destroy_menu("hudWelcome");
		//self _destroy_bg("hudWelcomeBG");
		c++;
		//wait 0.05;
	}
	
	self notify("hasReadWelcomeMsg");
	cl("^2before waittill hasReadMOTD");
	//self waittill("spawned_player");
	wait 0.05;

	if(getDvarInt("log_motd") != 1){ game["hasReadMOTD"][self.name]=true; }

	if (game["hasReadMOTD"][self.name]==false){
		self thread _accept();
		motd=_get_motd_txt();
		self.hudMOTD[0]=motd;
		
		if(isDefined(self.hudMOTD) && isDefined(motd)){
			while(h<300){
				self _create_menu_text("hudWelcome",self.hudMOTD[0],"default", 1.6,1.4,(r,g,b),0,"CENTER","CENTER",0,-70,a,2);
				self _create_menu_bg("hudWelcomeBG","CENTER","CENTER",0,0,w,h,(r,g,b),1,a,"black",50,"fullscreen","fullscreen");
				if(r<1){ r+=0.1;g+=0.1;b+=0.1;a+=0.1; }
				if(w<400){ w+=30; }
				if(h<300){ h+=20; }
				//level waittill("timers");
				wait 0.05;
				//self _destroy_menu(self.money["hudWelcomeBG"]);
				self _destroy_menu("hudWelcome");
				self _destroy_bg("hudWelcomeBG");
				c++;
				//wait 0.05;
			}
			
			self notify("readyToPressAccept");
			self thread _nav_motd();

			while(h>1){
				self _create_menu_text("hudWelcome",self.hudMOTD[0],"default", 1.6,1.4,(r,g,b),0,"CENTER","CENTER",0,-70,a,2);
				self _create_menu_bg("hudWelcomeBG","CENTER","CENTER",0,0,w,h,(r,g,b),1,a,"black",50,"fullscreen","fullscreen");
				//if(r==1){ wait 2; }
				//self _create_menu_text("hudWelcome",txt,"default", 1.6,1.4,(1,1,1),0,"CENTER","CENTER",0,0,1,1);
				if(game["hasReadMOTD"][self.name]==true){
					if(r>0){ r-=0.1;g-=0.1;b-=0.1;a-=0.1; }
					if(w>1){ w-=30; }
					if(h>1){ h-=20; }
				}
				//level waittill("timers");
				wait 0.05;
				//self _destroy_menu(self.money["hudWelcomeBG"]);
				self _destroy_menu("hudWelcome");
				self _destroy_bg("hudWelcomeBG");
				c++;
				//wait 0.05;
			}
		}
	}
	self notify("hasReadMOTD");
	cl("22hasReadMOTD");
	while(level.inPrematchPeriod){ wait 0.1; }
	self freezeControls(false);
}

_accept(){
	self endon ( "disconnect" );
	//self endon ( "death" );
	//self endon( "intermission" );
	//self endon( "game_ended" );
	//if (!getdvarint("developer")>0){ return; }
	if(self.isbot){ return; }
	self waittill("readyToPressAccept");
	while (!game["hasReadMOTD"][self.name] && !self JumpButtonPressed()){ wait 0.05; }
	self notify("hasPressedFButton");
	game["hasReadMOTD"][self.name]=true;
	self playLocalSound("mp_last_stand");
	cl("^2"+self.name+" has read MOTD");
	//while (self UseButtonPressed()){ wait 0.05; }
	if(isDefined(game["id"])){ self iprintln("^5your ID is "+game["id"][self.name]+" in players database"); }
}

_nav_motd(){
	self endon ( "disconnect" );
	//self endon ( "death" );
	//self endon( "intermission" );
	//self endon( "game_ended" );
	//if (!getdvarint("developer")>0){ return; }
	if(self.isbot){ return; }
	
	while(game["hasReadMOTD"][self.name]==false){
		if (self MoveLeftButtonPressed()){ 
			//cl(self.name+" pressed LEFT key");
			self notify("hasPressedMoveLeftButton");
			self.readDay++;
			motd=_get_motd_txt(self.readDay);
			if(isDefined(motd)){ self.hudMOTD[0]=motd; }
			self playLocalSound("mouse_click");
			while (self MoveLeftButtonPressed()){ wait 0.05; }
		}
		
		if (self MoveRightButtonPressed()){ 
			//cl(self.name+" pressed RIGHT key"); 
			self notify("hasPressedMoveRightButton");
			if(self.readDay>0){ self.readDay--; }
			motd=_get_motd_txt(self.readDay);
			if(isDefined(motd)){ self.hudMOTD[0]=motd; }
			self playLocalSound("mouse_click");
			while (self MoveRightButtonPressed()){ wait 0.05; }
		}
		wait 0.05;
	}
}

_map_datetime_menu(){
	self endon ( "disconnect" );
	if(self.isbot){ return; }
	
	map=[]; dateTime=[];
	
	wait 1;
	for(;;){
		version[0]=getDvar("v01d_version");
		map[0]=getDvar("mapname");
		realTime = getRealTime();
		realDate = TimeToString(realTime, 0, "%F");
		dateTime[0] = TimeToString(realTime, 0, "%F %T");

		if (getDvar("v01d_version") == "") { setDvar("v01d_version", " "); }
		
		if(isDefined(dateTime) && isDefined(dateTime)){
			self _create_menu_text("hudModVersion",version,"default", 1.6,1.4,(1,1,1),0,"LEFT","CENTER",-420,200,0.5,1);
			self _create_menu_text("hudMap",map,"default", 1.6,1.4,(1,1,1),0,"LEFT","CENTER",-420,210,0.5,1);
			self _create_menu_text("hudDateTime",dateTime,"default", 1.6,1.4,(1,1,1),0,"LEFT","CENTER",-420,224,0.5,1);
			wait 1;
			self _destroy_menu("hudModVersion");
			self _destroy_menu("hudMap");
			self _destroy_menu("hudDateTime");
		}
	}
}

_money_menu(){
	self endon ( "disconnect" );
	//self endon ( "death" );
	self endon( "intermission" );
	self endon( "game_ended" );
	if (self.isbot){ return; }
	
	self waittill("spawned_player");

	r=1;g=1;b=1;a=1;c=0;
	money=[];
	while(1){
		while(!isDefined(self.money)) { wait 0.5; }
		while (game["state"] == "postgame" || level.gameEnded || !isAlive(self)) { wait 1; }
		if(isDefined(self.money["acc"])){
			money[0]=self.money["acc"]+"$";
			if(isDefined(self.notEnoughMoney)){
				if(c<10){
					if(c%2==0){	self _create_menu_text("hudMoney",money,"default", 1.6,1.4,(1,0,0),0,"CENTER","CENTER",400,200,a,1); }
					else { self _create_menu_text("hudMoney",money,"default", 1.6,1.4,(1,1,1),0,"CENTER","CENTER",400,200,a,1); }
					c++;
				} else { self.notEnoughMoney=undefined; c=0; }
			} else {
				self _create_menu_text("hudMoney",money,"default", 1.6,1.4,(r,g,b),0,"CENTER","CENTER",400,200,a,1);
			}
			wait 0.1;
			self _destroy_menu("hudMoney");
		}
		//wait 0.05;
	}
}

_buy_menu_show(arr,prev,next,div){
	//self endon ( "disconnect" );
	//self endon ( "death" );
	//self endon( "intermission" );
	//self endon( "game_ended" );

	if (self.isbot){ return; }
	self.buyMenuShowNext=undefined;
	self.buyMenuSelector=1;
	self.buyMenuShow=arr; 
	self.hasChosen=[];
	sw=1; c=0;
	AttackButtonPressed=false;
	AdsButtonPressed=false;
	r=1;g=1;b=1;a=1;
	scolor=(0,1,0);
	if(self.pers["team"] == "axis"){ r=1;g=0;b=0;a=1; }
	if(self.pers["team"] == "allies"){ r=0;g=0;b=1;a=1; }
	if(!isDefined(div)) { div=1; }
	size=self.buyMenuShow.size/div;
	//cl("^3_buy_menu_show div:"+div);
	while(!isDefined(self.money)) { wait 0.5; }
		
	if(isAlive(self) && isDefined(self.buyMenuShow)){
		sw=0; selector=1; selected=1;
		curView = self getPlayerAngles();
		pitch=curView[0];
		self DisableWeapons();
		//sens = self getClientDvar("cl_mouseAccel");
		//cl("^4cl_mouseAccel:"+sens);
		//self setClientDvars("cl_mouseAccel", 0);
		//self _create_menu_bg("hudBuyMenuBG","CENTER","CENTER",0,0,200,100,(r,g,b),1,a,"white");
				
		while(isAlive(self) && isDefined(self.buyMenuShow)){
			//cl("^4pitch:"+pitch);
			if(isDefined(self.spawnStartOrigin) && distance(self.spawnStartOrigin,self.origin)>=16){ self.buyMenuShow=undefined; }
			if(isDefined(self.buyMenuShow)){
				//cl(self.buyMenuShow[1]);
				for(i=0;i<self.buyMenuShow.size;i+=3){
					if(isDefined(self.buyMenuShow[i]) && isDefined(self.buyMenuShow[i+2])){
						if(isSubStr(self.buyMenuShow[i+2],"_mp") && !isSubStr(self.buyMenuShow[i+2],"c4") && !isSubStr(self.buyMenuShow[i+2],"claymore") && !isSubStr(self.buyMenuShow[i+2],"grenade") && !isSubStr(self.buyMenuShow[i],"1 CLIP") && isDefined(self _check_weapon_in_list(self.buyMenuShow[i+2]))){ 
							//clipSize=WeaponClipSize(self.buyMenuShow[i+2]);
							//self.buyMenuShow[i]+=" [AMMO | 1 CLIP = "+(clipSize*1.5)+"$]"; 
							self.buyMenuShow[i]+=" [AMMO | 1 CLIP = "+(int(self.buyMenuShow[i+1])/10)+"$]"; 
						}
						//cl(self.buyMenuShow[i]);
					}
				}
			}
			if(AttackButtonPressed==false){
				if(selector>0 && selector<=size) {
					if(pitch>curView[0]+5 || self LeanLeftButtonPressed()) { selector--; pitch=curView[0]; }
					else if(pitch<curView[0]-5 || self LeanRightButtonPressed()) { selector++; pitch=curView[0]; }
					//self playLocalSound( "mouse_click" );
				}
				if (selector<1) { selector=int(size); } 
				if (selector>size) { selector=1; }
				if (selected!=selector){ self playLocalSound( "mouse_click" ); selected=selector; }
			}
			if (self AttackButtonPressed() && AttackButtonPressed==false){ 
				AttackButtonPressed=true;
			}
			else if (self AdsButtonPressed() && AdsButtonPressed==false){ 
				AdsButtonPressed=true;
			}
			if(AttackButtonPressed==true){
				//if(scolor[0]==0){ scolor=(1,0,0); }
				//else { scolor=(0,1,0); }
				//if(c>=10){ 
					//if(next){ self.buyMenuShow=undefined; }
					//self.buyMenuShowNext=next; 
					AttackButtonPressed=false;
					//cl("^3selector:"+selector);
					for(i=0;i<div;i++){
						self.hasChosen[i]=self.buyMenuShow[(selector-1)*div+i];
						//cl("^3self.hasChosen:"+self.hasChosen[i]);
					}
					self notify("isBuying");
					//self thread _check_ammo_buy_menu();
					if(next==true){ self.buyMenuShow=undefined; }
					//self.buyMenuShow=undefined;
					//self.hasChosen=arr[(selector-1)*div];
					//cl("^3self.hasChosen:"+self.hasChosen);
					//cl("^3c: size:"+size);
					while (self AttackButtonPressed()){ wait 0.05; }
					wait 0.05;
					//if(isDefined(self.money["acc"]) && self.money["acc"]<arr[(selector-1)*div] && div>1){ self.notEnoughMoney=true; }
				//}
				//c++;
			}
			else if(AdsButtonPressed==true){
				//if(isDefined(prev)){ self.hasChosen=prev; }
				//else { self.hasChosen="buyMenuMain"; }
				self allowADS(0);
				self.hasChosen[0]="buyMenuMain";
				self.buyMenuShow=undefined;
				//self.buyMenuShowNext=next; 
				//self.hasChosen="Main";
				AdsButtonPressed=false;
				//cl("^3self.hasChosen:"+self.hasChosen[0]);
				//cl("^3c: size:"+size);
				wait 0.05;
				self allowADS(1);
			}
			if(isDefined(self.buyMenuShow)) {
				/*weapon = self _check_weapon_in_list(arr[2]);
				if (isDefined(weapon) && arr[2] == weapon){
					cl("11!!!!!!");
					for(i=0;i<arr.size;i++){
						if(arr[i]==weapon){ 
							//arr[i]=arr[i]+" Ammo = "+ WeaponClipSize(weapon); 
							arr[i+1]=int(arr[i+1]/10); 
						}
					}
				}*/
				//self _create_menu_text("hudBuyMenu",arr,"default", 1.6,1.4,(r,g,b),0,"CENTER","CENTER",100,0,a,1,selector,scolor);
				self _create_menu_text("hudBuyMenu",self.buyMenuShow,"default", 1.6,1.4,(r,g,b),0,"LEFT","CENTER",-300,0,a,1,selector,scolor,div);				
				wait 0.1;
				curView = self getPlayerAngles();
				if(sw==1){sw=0;wait 0.5;}
				self _destroy_menu("hudBuyMenu",self.buyMenuShow.size,div);
			}								//hud,txt,ft,fsz,fsc,color,glow,ax,ay,w,h,a,sort,selector,scolor
		}
		wait 0.05;
	}
	//self.hasChosen=undefined;
	//self _destroy_menu("hudBuyMenu",arr.size,div); 
	self EnableWeapons();
	//cl("^3hud destroyed");
}

_check_weapon_in_list(weapon){
	if(self.isbot){ return; }
	if(!isDefined(weapon)){ return; }
	if(isAlive(self)){
		weaponsList = self GetWeaponsList();
		if(isDefined(weaponsList)){
			for(i=0;i<weaponsList.size;i++){
				//cl("33"+weaponsList[i]);
				if(isDefined(weaponsList[i])){
					if (weaponsList[i] == weapon){
						//cl("33returning: "+ weaponsList[i]);
						return weapon; 
					}
				}
			}
		}
	}
}

/*
_check_ammo_buy_menu(){
		if(isDefined(self.buyMenuShow)){
			for(i=0;i<self.buyMenuShow.size;i+=3){
				if(isSubStr(self.buyMenuShow[i+2],"_mp") && !isSubStr(self.buyMenuShow[i],"1 CLIP") && isDefined(self _check_weapon_in_list(self.buyMenuShow[i+2]))){ 
					self.buyMenuShow[i]+=" [1 CLIP | "+int(int(self.buyMenuShow[i+1])/10)+"$]";
				}
				//cl(self.buyMenuShow[i]);
			}
		}	
}
*/

_buy_weapons_ammo(weapon){
	wait 0.3;
	weapons = self GetWeaponsList();
	strTok="";
	
	for(i=0;i<weapons.size;i++){
		if(isSubStr(weapons[i],"grenade") || isSubStr(weapons[i],"claymore") || isSubStr(weapons[i],"c4") || isSubStr(weapons[i],"briefcase") || isSubStr(weapons[i],"radar") || isSubStr(weapons[i],"airstrike") || isSubStr(weapons[i],"artillery") || isSubStr(weapons[i],"helicopter")){ continue; }
		else {
			ammoCount = self getAmmoCount(weapons[i]);
			weaponClipSize = WeaponClipSize(weapons[i]);
			maxWeaponAmmo = weaponMaxAmmo(weapons[i])+weaponClipSize;
			getWeaponAmmoStock = self getWeaponAmmoStock( weapons[i] );
			fillAmmo = int(maxWeaponAmmo - ammoCount);
			clipsToGive = int(fillAmmo / weaponClipSize);
			
			//cl("33ammoCount:"+ammoCount);
			//cl("33maxWeaponAmmo:"+maxWeaponAmmo);
			//cl("33getWeaponAmmoStock:"+getWeaponAmmoStock);
			//cl("33fillAmmo:"+fillAmmo);
			//cl("33clipsToGive:"+clipsToGive);
			
			strTok += weapons[i] + ",";
			strTok += int(fillAmmo*5) + ",";
			strTok += "ammo_mp,";
			//self giveMaxAmmo(weapon);
			//self.hasChosen[0]="ammo_mp";
			//self.hasChosen[1]="50";
			//self.hasChosen[2]="ammo_mp";
			//cl("33self.hasChosen.size:"+self.hasChosen.size);
		}
	}
	return strTok;
}

_match_weapon_name(arr,name){
	for(i=0;i<arr.size;i++){
		if(isSubStr(arr[i],name)){ 
			return name;
		}
	}
}

_buy_menu_main(){
	self endon ( "disconnect" );
	//self endon ( "death" );
	self endon( "intermission" );
	self endon( "game_ended" );
	if (self.isbot){ return; }
	//if (!getdvarint("developer")>0){ return; }
	
	self.buyMenuShow=undefined;
	self.hasChosen=[];
	while(!isDefined(self.money)) { wait 0.5; }
	while(level.inPrematchPeriod){ wait 0.1; }
	//wait 0.1;
	//cl("^2spawned");
	//while (game["state"] == "postgame" || level.gameEnded || !isAlive(self)) { wait 0.1; }
	
	buyMenuMain = StrTok("Pistols,SMGs,MGs,Rifles,Snipers,RPGs,GLs,Grenades,Explosives",",");
	buyMenuPistols = undefined;
	buyMenuSMGs = undefined;
	buyMenuMGs = undefined;
	buyMenuRifles = undefined;
	buyMenuSnipers = undefined;
	buyMenuRPGs = undefined;
	buyMenuGLs = undefined;
	buyMenuGrenades = undefined;
	buyMenuExplosives = undefined;
	buyMenuAmmo = undefined;

	if(self.pers["team"] == "axis"){
		buyMenuMain = StrTok("Pistols,SMGs,MGs,Rifles,Snipers,RPGs,GLs,Grenades",",");
		buyMenuAmmo = StrTok(self _buy_weapons_ammo(),",");
		buyMenuPistols = StrTok("Beretta Silenced,138,beretta_silencer_mp,Desert Eagle,230,deserteagle_mp,Desert Eagle Gold,400,deserteaglegold_mp,RW1,450,rw1_mp",",");
		buyMenuSMGs = StrTok("Uzi,320,uzi_mp,Skorpion,440,skorpion_mp,AK74U,580,ak74u_mp",",");
		buyMenuMGs = StrTok("SAW,1200,saw_mp,RPD,1300,rpd_mp",",");
		buyMenuRifles = StrTok("AK47,640,ak47_mp,AK47 GL,800,ak47_gl_mp",",");
		buyMenuSnipers = StrTok("G3,430,g3_acog_mp,Dragunov,640,dragunov_mp",",");
		buyMenuRPGs = StrTok("RPG,1200,rpg_mp",",");
		//buyMenuRPGs = StrTok("RPG,2300,rpg_mp,LAW,2500,law_mp,AT4,2600,at4_mp",",");
		buyMenuGLs = StrTok("MM1,2400,mm1_mp",",");
		buyMenuGrenades = StrTok("Frag Grenade,15,frag_grenade_mp",",");
		buyMenuExplosives = StrTok("Claymore,100,claymore_mp,C4,400,c4_mp",",");
		//buyMenuGrenades = StrTok("Smoke Grenade,10,smoke_grenade_mp,Flash Grenade,20,flash_grenade_mp,Concussion Grenade,30,concussion_grenade_mp,Frag Grenade,40,frag_grenade_mp",",");
	} else if (self.pers["team"] == "allies") {
		buyMenuMain = StrTok("Pistols,SMGs,MGs,Rifles,Snipers,RPGs,GLs,Grenades,Explosives",",");
		buyMenuAmmo = StrTok(self _buy_weapons_ammo(),",");
		buyMenuPistols = StrTok("Colt 45 Silenced,155,colt45_silencer_mp,USP Silenced,167,usp_silencer_mp",",");
		buyMenuSMGs = StrTok("MP5,550,mp5_silencer_mp,G36C GL,630,g36c_gl_mp,P90,900,p90_silencer_mp",",");
		buyMenuMGs = StrTok("M60E4,1600,m60e4_mp",",");
		buyMenuRifles = StrTok("M4 GL,1200,m4_gl_mp,M21,1650,m21_mp,Striker,1800,striker_mp",",");
		buyMenuSnipers = StrTok("TAC330,2000,tac330_mp,TAC330 Silenced,2300,tac330_sil_mp",",");
		//buyMenuRPGs = StrTok("AT4,2600,at4_mp",",");
		buyMenuRPGs = StrTok("LAW,2200,law_mp,AT4,3200,at4_mp",",");
		buyMenuGLs = StrTok("MM1,3000,mm1_mp",",");
		buyMenuGrenades = StrTok("Concussion Grenade,20,concussion_grenade_mp,Frag Grenade,35,frag_grenade_mp",",");
		buyMenuExplosives = StrTok("Claymore,100,claymore_mp,C4,400,c4_mp",",");
	}
	while(!isAlive(self) || self.sessionstate == "spectator"){ wait 0.1; }
	//cl("^3self.spawnStartOrigin");
	//while(isAlive(self) && !self UseButtonPressed()){ wait 0.05; }
	wait 0.3;
	
	self.spawnStartOrigin=self.origin;
	self.hasChosen[0]="buyMenuMain";
	while(!level.gameEnded && !level.slowMo && isAlive(self) && !isDefined(self.lastStand) && distance(self.spawnStartOrigin,self.origin)<32){
		//if(!isDefined(self.hasChosen)){ self _buy_menu_show(buyMenuMain); cl("^3self.buyMenuMain"); }
		if(isDefined(self.hasChosen)){
			for(i=0;i<self.hasChosen.size;i++){
				//cl("^3isDefined(self.hasChosen)");
				if (self.hasChosen[i]=="buyMenuMain"){ self _buy_menu_show(buyMenuMain,"buyMenuMain",true,1); }
				else if (self.hasChosen[i]=="Ammo"){ self _buy_menu_show(buyMenuAmmo,"buyMenuMain",false,3); }
				else if (self.hasChosen[i]=="Pistols"){ self _buy_menu_show(buyMenuPistols,"buyMenuMain",false,3); }
				else if (self.hasChosen[i]=="SMGs"){ self _buy_menu_show(buyMenuSMGs,"buyMenuMain",false,3); }
				else if (self.hasChosen[i]=="MGs"){ self _buy_menu_show(buyMenuMGs,"buyMenuMain",false,3); }
				else if (self.hasChosen[i]=="Rifles"){ self _buy_menu_show(buyMenuRifles,"buyMenuMain",false,3); }
				else if (self.hasChosen[i]=="Snipers"){ self _buy_menu_show(buyMenuSnipers,"buyMenuMain",false,3); }
				else if (self.hasChosen[i]=="RPGs"){ self _buy_menu_show(buyMenuRPGs,"buyMenuMain",false,3); }
				else if (self.hasChosen[i]=="GLs"){ self _buy_menu_show(buyMenuGLs,"buyMenuMain",false,3); }
				else if (self.hasChosen[i]=="Grenades"){ self _buy_menu_show(buyMenuGrenades,"buyMenuMain",false,3); }
				else if (self.hasChosen[i]=="Explosives"){ self _buy_menu_show(buyMenuExplosives,"buyMenuMain",false,3); }
			}
		}
		while(isDefined(self.buyMenuShow) && isDefined(self.hasChosen) && isAlive(self)){ 
			if(distance(self.spawnStartOrigin,self.origin)>=16){ 
				self.buyMenuShow=undefined; 
			}
			//cl("^3self.spawnStartOrigin");
			wait 0.05; 
		}
		//cl("^3self.buyMenuShowNext");
		wait 0.1;
		//while(isAlive(self) && self UseButtonPressed()){ wait 0.05; }
	}
}

_buy_menu_iterate(){
	self endon ( "disconnect" );
	self endon ( "death" );
	self endon( "intermission" );
	self endon( "game_ended" );

	for(;;){
		if(isDefined(self.buyMenuShow)){
			cl(self.buyMenuShow[0]);
		}
		if(isDefined(self.hasChosen)){
			cl(self.hasChosen[0]);
		}
		wait 1;
	}
}
