#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include scripts\cl;

init(){
	//if (!getdvarint("developer")>0){ return; }
	if (getdvarint("bots_main_debug")>0){ return; }
	if (getdvarint("v01d_dev")>0){ return; }
	
	if (!isDefined(game["MOTD"])){ game["MOTD"]=[]; }
	if (!isDefined(game["MOTD"]["dateTimes"])){ game["MOTD"]["dateTimes"]=[]; }
	if (!isDefined(game["MOTD"]["reports"])){ game["MOTD"]["reports"]=[]; }
	if (!isDefined(game["hasReadMOTD"])){ game["hasReadMOTD"]=[]; }
	if (!isDefined(game["hasReadHintMessage"])){ game["hasReadHintMessage"]=[]; }
	
	level.msgID=0;

	level thread _connecting_loop();
	level thread _connected_loop();
	level thread _get_motd_txt(1);
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
		
		player.hudmsg = [];
		player.hudmsgID = 0;

		player thread _money_menu();
		player thread _welcome_msg();
		player thread _spawn_loop();
		player thread _map_datetime_menu();
		//player thread _dev_test_hud();
		//player _show_message(1,"test test test test",2,(1,1,0),1,(1,1,0),1,"center","middle",-200,-80,"default",1.4,1.6,0);
		//wait 0.5;
		//player _show_message(1,"test test test test",2,(1,1,0),1,(1,1,0),1,"center","middle",-200,-60,"default",1.4,1.6,0);
		//_show_message(delay,txt,dur,color,a,gc,ga,ax,ay,ox,oy,ft,fsz,fsc,sort){
		//player thread _keystrokes();
		//wait 0.1;
		//player setClientDvar( "ui_lobbypopup", "summary" );
	}
}

_dev_test_hud(){
	if(!self.isbot){
		wait 0.5;
		
		//self _show_hint_msg(txt,delay,dur,x,y,w,h,ax,ay,ox,oy,ft,fsz,fsc,color,a,gc,ga,sort,cx,cy,override,chrs,chre){
		self thread _show_hint_msg("press FIRE button to select",0,3,0,300,0,0,"left","middle",0,0,"default",1.6,1.6,(1,1,0),1,(1,1,0),0.5,1,undefined,undefined);
		wait 0.5;
		self thread _show_hint_msg("press ADS button to return",0.3,3,0,318,0,0,"left","middle",0,0,"default",1.6,1.6,(1,1,0),1,(1,1,0),0.5,1,undefined,undefined,true);
		wait 1;
		//self.hudmsg[1]=true;
		
		//_show_hint_msg(txt,delay,dur,x,y,w,h,ax,ay,ox,oy,ft,fsz,fsc,color,a,gc,ga,sort,cx,cy,override){
		//self thread scripts\menus::_show_hint_msg("GAME WINNING KILL",0,3,320,50,0,0,"left","middle",0,0,"objective",1.6,3.6,(1,1,1),1,(0.2,0.3,0.7),1,1,true,undefined);
		//str=game["strings"]["roundend"];
		//self thread scripts\menus::_show_hint_msg(str,1.7,2,320,70,0,0,"left","middle",0,0,"objective",1.6,2.6,(1,0.5,0.5),1,(0.2,0.3,0.7),1,1,true,true);
		//iPrintLn( &"MP_EXPLOSIVES_PLANTED_BY", self );
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
			//self _show_message("press FIRE button to select",1,2,60,80,0,0,"center","middle",0,0,(1,1,0),1,(1,1,0),1,"default",1.6,1.6,2);
			//self _show_message("press ADS button to return",1,2,60,80,0,0,"center","middle",0,0,(1,1,0),1,(1,1,0),1,"default",1.6,1.6,2);
			
			//self _show_message(1,"press ADS button to return",2,(1,1,0),1,(1,1,0),1,"center","middle",-200,-80,"default",1.4,1.6,1);
			//self thread _show_message(0,"TEST TEST TEST",1,1,1,0,1,-200,-80);
			
			//wait 2;
			self thread _show_hint_msg("press FIRE button to select",0,3,0,300,0,0,"left","middle",0,0,"default",1.6,1.6,(1,1,0),1,(1,1,0),0.5,1,undefined,undefined);
			wait 0.05;
			self thread _show_hint_msg("press ADS button to return",0.3,3,0,318,0,0,"left","middle",0,0,"default",1.6,1.6,(1,1,0),1,(1,1,0),0.5,1,undefined,undefined);
			//_show_hint_msg(txt,delay,dur,x,y,w,h,ax,ay,ox,oy,ft,fsz,fsc,color,a,gc,ga,sort,cx,cy,override){
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
		while (self MoveLeftButtonPressed()){ cl(self.name+" pressed left key"); wait 0.5; }
		while (self MoveRightButtonPressed()){ cl(self.name+" pressed RIGHT key"); wait 0.5; }
		while (self SprintButtonPressed()){ cl(self.name+" pressed SPRINT key"); wait 0.5; }
		while (self ReloadButtonPressed()){ cl(self.name+" pressed RELOAD key"); wait 0.5; }
		while (self LeanLeftButtonPressed()){ cl(self.name+" pressed LEAN left key"); wait 0.5; }
		while (self LeanRightButtonPressed()){ cl(self.name+" pressed LEAN RIGHT key"); wait 0.5; }
		while (self HoldBreathButtonPressed()){ cl(self.name+" pressed HOLD BREATH key"); wait 0.5; }
		while (self AimButtonPressed()){ cl(self.name+" pressed AIM key"); wait 0.5; }
		wait 0.05;
		//waittillframeend;
	}
}

/*
_create_menu(align,relative,x,y,width,height,color,sort,alpha,shader){
	self.Menu = undefined;
	self.Menu = self createRectangle(align,relative,x,y,width,height,color,sort,alpha,shader);
}
*/

_create_menu_text(hud,arr,x,y,w,h,ax,ay,ox,oy,ft,fsz,fsc,color,a,gc,ga,sort,selector,scolor,div,skip,override){
	self endon ( "disconnect" );
	self endon ( "death" );
	self endon( "intermission" );
	self endon( "game_ended" );
	if(self.isbot){ return; }
	//if(!isAlive(self)){ return; }
	if(!isDefined(hud)){ cl("11no hud defined!"); return; }
	if(!isDefined(arr)){ cl("11no arr defined!"); return; }

	self.money[hud]=[];
	size=arr.size;
	if(!isDefined(x)){ x=320; } //max width = 640;
	if(!isDefined(y)){ y=240; } //max height = 480;
	if(!isDefined(w)){ w=0; }
	if(!isDefined(h)){ h=0; }
	if(!isDefined(ox)){ ox=0; }
	if(!isDefined(oy)){ oy=0; }
	if(!isDefined(ax)){ ax="left"; } //left center right
	if(!isDefined(ay)){ ay="top"; } //top middle bottom
	if(!isDefined(color)){ color=(1,1,1); }
	if(!isDefined(a)){ a=1; }
	if(!isDefined(ft)){ ft="default"; }
	if(!isDefined(fsz)){ fsz=1.4; }
	if(!isDefined(fsc)){ fsc=1.6; }
	if(!isDefined(gc)){ gc=(1,1,1); }
	if(!isDefined(ga)){ ga=0; }
	if(!isDefined(sort)){ sort=1; }
	if(!isDefined(scolor)){ scolor=(0,0,0); }
	if(!isDefined(div)){ div=1; }
	if(div>1){ size=arr.size/div; }
	if(!isDefined(skip)){ skip=0; }
		
	//cl("^3hud:"+hud);
	//cl("^3arr.size:"+arr.size);
	//cl("^3size:"+size);
	//cl("^3div:"+div);
	
	x+=ox; y+=oy;
	for(i=0;i<size;i++){
		//cl("33i:"+i);
		self.money[hud][i] = undefined;
		self.money[hud][i] = newClientHudElem(self);
		self.money[hud][i].x = x;
		self.money[hud][i].y = y;
		self.money[hud][i].width = w;
		self.money[hud][i].height = h;
		//self.money[hud][i].xOffset = ox;
		//self.money[hud][i].yOffset = oy;
		self.money[hud][i].alignX = ax; //left center right
		self.money[hud][i].alignY = ay; //top middle bottom
	
		//self.money[hud][i] = self createfontstring(ft, fsz);
		if(div>1){ 
			//txt=arr[i*div]; 
			txt=arr[i*div+1]+"$ - "+arr[i*div]; 
			if(isDefined(txt)){
				self.money[hud][i] settext(txt);
			}
		}
		else { 
			self.money[hud][i] settext(arr[i]); 
			//cl("txt:"+arr[i]);
		}
		y+=10;
		self.money[hud][i].alpha = a;
		if(isDefined(override)){ a-=0.01; }
		self.money[hud][i].glowColor = gc;
		self.money[hud][i].glowAlpha = ga;
		self.money[hud][i].sort = sort;
		self.money[hud][i].fontscale = fsc;
		self.money[hud][i].font = ft;
		self.money[hud][i].color = color;
		self.money[hud][i].archived = false; //this was a pain to find out why in killcam no text alpha
		//self.money[hud][i].children = [];		
		//self.money[hud][i] setParent(level.uiParent);
		self.money[hud][i].hidden = false;
		self.money[hud][i].hideWhenInMenu = false;
		//self.money[hud][i] setpoint(ax, ay, ox, oy+i*10);
		//self.money[hud][i] setSize( 640, 480 );
		if(isDefined(selector) && selector-1 == i) { 
			self.money[hud][i].color=scolor; 
		}
		//if(div>0){ i+=div; }
	}
}

_create_menu_bg(bg,x,y,w,h,ox,oy,ax,ay,color,a,sort,shader,aperc){
	self endon ( "disconnect" );
	self endon ( "death" );
	self endon( "intermission" );
	self endon( "game_ended" );
	if(self.isbot){ return; }

	if(!isDefined(x)){ x=160; } //max width = 640;
	if(!isDefined(y)){ y=120; } //max height = 480;
	if(!isDefined(w)){ w=0; }
	if(!isDefined(h)){ h=0; }
	if(!isDefined(ox)){ ox=0; }
	if(!isDefined(oy)){ oy=0; }
	if(!isDefined(ax)){ ax="center"; } //left center right
	if(!isDefined(ay)){ ay="middle"; } //top middle bottom
	if(!isDefined(color)){ color=(0,0,0); }
	if(!isDefined(a)){ a=1; }
	if(!isDefined(sort)){ sort=0; }
	if(!isDefined(shader)){ shader="black"; }
	if(!isDefined(aperc)){ aperc=100; }
	
	a=a*(aperc/100);
	self.money[bg] = undefined;
	//self.money[bg] = self createRectangle(align,relative,x,y,w,h,color,sort,alpha,sh,ha,va);
	self.money[bg] = newClientHudElem( self );
	self.money[bg].x = x;
	self.money[bg].y = y;
	self.money[bg].width = w;
	self.money[bg].height = h;
	self.money[bg].xOffset = ox;
	self.money[bg].yOffset = oy;
	//self.money[bg].elemType = "bar_";
	self.money[bg].sort = sort;
	self.money[bg].color = color;
	self.money[bg].alpha = a;
	//self.money[bg].align = align;
	//self.money[bg].relative = relative;
	//self.money[bg].children = [];
	self.money[bg].horzAlign = ax;
    self.money[bg].vertAlign = ay;	
    //self.money[bg] setParent( level.uiParent );
	if(isDefined(shader)){ self.money[bg] setShader(shader,w,h); }
	self.money[bg].hidden = false;
	//self.money[bg] setPoint(align,relative,x,y);
	//cl("33"+a);
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
	
	if(!isDefined(size) || menu.size<1){ return; }
	
	if(isDefined(self.money) && isArray(self.money) && isDefined(self.money[menu])){		
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

_change_menu(menu,arg,val){
	//self endon ( "disconnect" );
	//self endon ( "death" );
	//self endon( "intermission" );
	//self endon( "game_ended" );
	
	if(!isDefined(self.money)){ return; }
	if(!isDefined(menu)){ return; }
	if(!isDefined(arg)){ return; }

	c=0; size=menu.size;
	if(!isDefined(size) || menu.size<1){ return; }
	if(isDefined(self.money) && isArray(self.money) && isDefined(self.money[menu])){		
		for(i=0;i<size;i++){
			if(isDefined(self.money[menu][i])){
				if(arg=="x"){ self.money[menu][i].x=val; }
				if(arg=="y"){ self.money[menu][i].y=val; }
				if(arg=="w"){ self.money[menu][i].w=val; } //max width = 640;
				if(arg=="h"){ self.money[menu][i].h=val; } //max height = 480;
				if(arg=="ox"){ self.money[menu][i].ox=val; }
				if(arg=="oy"){ self.money[menu][i].oy=val; }
				if(arg=="ax"){ self.money[menu][i].ax=val; } //left center right
				if(arg=="ay"){ self.money[menu][i].ay=val; } //top middle bottom
				if(arg=="color"){ self.money[menu][i].color=val; } 
				if(arg=="a"){ self.money[menu][i].alpha=val; }
				if(arg=="ft"){ self.money[menu][i].ft=val; }
				if(arg=="fsz"){ self.money[menu][i].fsz=val; }
				if(arg=="fsc"){ self.money[menu][i].fsc=val; }
				if(arg=="gc"){ self.money[menu][i].gc=val; }
				if(arg=="ga"){ self.money[menu][i].gca=val; }
				if(arg=="sort"){ self.money[menu][i].sort=val; }
				if(arg=="override"){ self.money[menu][i].override=val; }
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

/*
_hud_arr(txt,x,y)
{
	hud = NewHudElem( self );
	hud setText(txt);
	hud.alignX = "left";
	hud.alignY = "middle";
	//hud.horzAlign = "middle";
	//hud.vertAlign = "bottom";
	hud.x = x;
	hud.y = y;
	hud.foreground = true;
	hud.fontScale = 1.4;
	hud.font = "default";
	hud.alpha = 1;
	hud.glow = 0;
	hud.glowColor = ( 0, 0, 0 );
	hud.glowAlpha = 1;
	hud.color = ( 1.0, 1.0, 1.0 );
	//hud.children = [];
	//hud setParent( level.uiParent );
	//hud setpoint(x, y, ox, oy);
	//return hud;
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
*/

_get_motd_txt(prevDay){
	if (isDefined(game["MOTD"]["dateTimes"]) && game["MOTD"]["dateTimes"].size<1){
		cl("game[MOTD][dateTimes].size: "+game["MOTD"]["dateTimes"].size);
		if(!isDefined(prevDay)){ prevDay=0; }
		realTime = getRealTime()-(86400*prevDay);
		realDate = TimeToString(realTime, 0, "%F");
		dateTime = TimeToString(realTime, 0, "%F %T");
		//dateTime = StrRepl(playername, ":", "_");
		filename = "motd/motd.log";
		line="";
		raw=[];
		lines=[];
		chars=[];
		dateTimes=[];
		reports=[];
		prevDatesLimit=180;
		//cl("^3realDate: " + realDate);
		
		//lines[0]="^2"+realDate+"\n";
		if (!FS_TestFile(filename)){ 
			cl("11No MOTD file available!"); 
		} else if(prevDay>=0){
			csv = FS_FOpen(filename, "read");
			line = FS_ReadLine(csv);
			while (isDefined(line)){
				//cl("33line: " + line);
				//if (line == "") { lines[1]+="\n"; }
				raw[raw.size]=line;
				line = FS_ReadLine(csv);
			}
			FS_FClose(csv);
			//level waittill("timers");
		}
		
		//for(i=0;i<raw.size;i++){ cl("raw: " + raw[i]); }
	
		c=0;
		stopAll=undefined;
		now=getRealTime();
		prevDatesLimitTime=getRealTime()-(86400*prevDatesLimit);
		if(isDefined(raw) && !isDefined(stopAll)){
			for(i=0;i<raw.size;i++){
				for(d=0;d<prevDatesLimit;d++){
					time=getRealTime()-(86400*d);
					date=strRepl(TimeToString(time, 0, "%F"),"-"," ");
					stop=undefined;
					//cl("date: "+date);
					
					if(isDefined(raw[i]) && raw[i]==date && !isDefined(stopAll)){
						dateTimes[c]=raw[i];
						//cl("11dateTimes["+c+"]: " + dateTimes[c]);
						game["MOTD"]["dateTimes"][c]=dateTimes[c];
						while(isDefined(raw[i])){ 
							i++;
							for(j=0;j<prevDatesLimit-c;j++){
								time=getRealTime()-(86400*j);
								date=strRepl(TimeToString(time, 0, "%F"),"-"," ");
								if(time<=prevDatesLimit){ stopAll=true; }
								if(isDefined(raw[i]) && raw[i]==date){ stop=true; break; }
							}
							if(isDefined(stop)){ break; }
							if(isDefined(raw[i]) && !isDefined(stopAll)){ 
								reports[c]=raw[i]; 
								//cl("22reports["+c+"]: " + reports[c]);
								if(isDefined(game["MOTD"]["reports"][c])){ game["MOTD"]["reports"][c]+="\n"+reports[c]; }
								else { game["MOTD"]["reports"][c]="\n\n"+reports[c]; }
							}
						}
						c++;
					}
				}
			}
		}
	}
}

//---------------------------------------------------------------------------------------------------


_show_message(txt,delay,dur,x,y,w,h,ax,ay,ox,oy,color,a,gc,ga,ft,fsz,fsc,sort){
	self endon ( "disconnect" );
	//self endon ( "death" );
	self endon( "intermission" );
	self endon( "game_ended" );
	
	if (self.isbot){ return; }
	if (!isDefined(self.buyMenuShow)){ return; }
	if (!isDefined(txt)){ cl("11no txt defined!"); return; }
	if (!isDefined(delay)){ delay=1; }
	if (!isDefined(dur)){ dur=5; }
	if (!isDefined(x)){ x=0; }
	if (!isDefined(y)){ y=0; }
	if (!isDefined(w)){ w=0; }
	if (!isDefined(h)){ h=0; }
	if (!isDefined(ax)){ ax="center"; }
	if (!isDefined(ay)){ ay="middle"; }
	if (!isDefined(ox)){ ox=0; }
	if (!isDefined(oy)){ oy=0; }
	if (!isDefined(color)){ color=(1,1,1); }
	if (!isDefined(a)){ a=1; }
	if (!isDefined(gc)){ gc=(1,1,1); }
	if (!isDefined(ga)){ ga=1; }
	if (!isDefined(ft)){ ft="default"; }
	if (!isDefined(fsz)){ fsz=1.6; }
	if (!isDefined(fsc)){ fsc=1.4; }
	if (!isDefined(sort)){ sort=1; }
	
	_a=a;
	_x=x;
	_y=y;
	self.showMessage=true;
	size=0;
	blob="asdfghjklqwertyuiopzxcvbnm";
	c1=0; _c1=4; c2=0; cm=-1; ch=[]; ph=0;
	//m=0;
	//_m=8;
	//ntxt=txt;
	exit=false;
	level.msgID++;
	wait delay;
	cl("33show_message");
	hudMessage[0]=[];
	hudMessage[0][0]="";
	for(i=0;i<txt.size;i++){ ch[i]=0; }
	while(1){
		//hudMessage[0]=[];
		//hudMessage[0][0]="";
		skip=false;
		
		for(i=0;i<txt.size;i++){
			r=randomIntRange(0,blob.size);
			if(ch[i]==0){ hudMessage[i]=blob[r]; }
			//if(ch[i]==0){ hudMessage[i]=""; }
			//if(cm>-1 && cm<txt.size && cm>i && skip==false){ 
			//if(cm>-1 && cm<txt.size && ch[cm]==0 && skip==false){ 
			/*if(cm>-1 && cm<txt.size && ch[cm]==0 && skip==false){ 
				hudMessage[i][0]=txt[i]; 
				ch[i]=1;
				//skip=true;
				//cm++;
			}*/
			if(cm>-1 && cm<txt.size && ch[cm]==0 && ph==0){ 
				hudMessage[i]=txt[i]; 
				ch[i]=1;
			}
			if(cm>-1 && cm<txt.size && ch[cm]==1 && ph==1){ 
				hudMessage[i]=txt[i]; 
				ch[cm]=0;
				//ch[randomIntRange(0,txt.size)]=0;
			}
			self _create_menu_text("hudMessage"+i,hudMessage[i],x,y,w,h,ax,ay,ox,oy,ft,fsz,fsc,color,a,gc,ga,sort);
			//_create_menu_text(hud,arr,x,y,w,h,ax,ay,ox,oy,ft,fsz,fsc,color,a,gc,ga,sort,selector,scolor,div,skip);
			//self playLocalSound("mouse_click");
			//self _hud_arr(hudMessage[i],x,y);
			x=x+10;
			//m++;
			//cl("33i:"+i);
			//cl("33x:"+x);
			//cl("33_x:"+_x);
			//wait 0.5;
		}
		//cl("33hudMessage.size:"+hudMessage.size);
		//for(i=0;i<hudMessage.size;i++){ cl("33hudMessage["+i+"]="+hudMessage[i]); } 
		self playLocalSound("mouse_click");
		//self playLocalSound("mp_suitcase_pickup");
		if(cm>=txt.size-1 && ph==0){ wait dur; }
		//cl("33ph"+ph);
		if(ph>=2){ exit=true; }
		//cl("33cm:"+cm);
		wait 0.05;
		for(i=0;i<hudMessage.size;i++){
			self _destroy_menu("hudMessage"+i);
			//wait 0.5;		
			//cl("33show_message");
		}
		x=_x;
		//m=0;
		
		//for(i=0;i<ch.size;i++){ cl("33ch["+i+"]="+ch[i]); } 
		//for(i=0;i<hudMessage.size;i++){ cl("33hudMessage["+i+"]="+hudMessage[i][0]); } 
		if(c1<_c1){ c1++; }
		if(ph==0){ cm++; if(cm>=txt.size){ ph=1; }}
		if(ph==1){ 
			arr=[]; c=0;
			for(j=0;j<ch.size;j++){	
				if(ch[j]==1){ 
					arr[c]=j; c++;
				}
			}
			/*c=0;
			while(1){ 
				if(ch[c]==1){ if(randomIntRange(0,2)>1){ ch[c]=0; }}
				if(c>ch.size){ c=0; } else { c++; }
				wait 0.05;
			}*/
			cm=arr[randomIntRange(0,arr.size)];
			//cl("33arr:"+arr.size);
			//cl("33ch.size:"+ch.size);
			//cl("33arr.size:"+arr.size);
			//cl("33c:"+c);
			//cl("33cm:"+cm);
			//for(i=0;i<arr.size;i++){ cl("33arr["+i+"]="+arr[i]); } 
			c2++;
			if(c2>=txt.size){ ph=2; }
		}
		if(ph==2){ exit=true; }
		//if(cm>txt.size-1){ ph=1; }	
		//else{ if(cm<txt.size){ cm++; }}
		//else{ c=0; }
		//wait 0.1;
		if(exit==true){ break; }
	}
	cl("33ended show_message");
}

_get_override_data(){
	if(!isDefined(self.hudmsg)){ self.hudmsg=[]; }
	//if(isDefined(self.hudmsg[self.hudmsgID])){ 
		//cl("11"+self.hudmsgID);
		//self.hudmsg[self.hudmsgID].alpha-=0.05;
		return self.hudmsg[self.hudmsgID-1];
	//}
}

_show_hint_msg(txt,delay,dur,x,y,w,h,ax,ay,ox,oy,ft,fsz,fsc,color,a,gc,ga,sort,cx,cy,override,chrs,chre){
	self endon ( "disconnect" );
	//self endon ( "death" );
	//self endon( "intermission" );
	//self endon( "game_ended" );
	if (self.isbot){ return; }
	//if (!isDefined(self.buyMenuShow)){ return; }
	//if (!isDefined(txt)){ return; }
	if (!isDefined(txt)){ cl("11no txt defined!"); return; }
	if (!isDefined(delay)){ delay=1; }
	if (!isDefined(dur)){ dur=5; }
	if (!isDefined(x)){ x=0; }
	if (!isDefined(y)){ y=0; }
	if (!isDefined(w)){ w=0; }
	if (!isDefined(h)){ h=0; }
	if (!isDefined(ax)){ ax="left"; }
	if (!isDefined(ay)){ ay="middle"; }
	if (!isDefined(ox)){ ox=0; }
	if (!isDefined(oy)){ oy=0; }
	if (!isDefined(color)){ color=(1,1,1); }
	if (!isDefined(a)){ a=1; }
	if (!isDefined(gc)){ gc=(1,1,1); }
	if (!isDefined(ga)){ ga=1; }
	if (!isDefined(ft)){ ft="default"; }
	if (!isDefined(fsz)){ fsz=1.6; }
	if (!isDefined(fsc)){ fsc=1.4; }
	if (!isDefined(sort)){ sort=1; }
	if (!isDefined(chrs)){ chrs=3; }
	if (!isDefined(chre)){ chre=3; }
	
	while(!isDefined(self.hudmsgID)){ wait 0.05; }
	self.hudmsgID++;
	//level.msgID++;
	//msgID_prev=self.hudmsg[player.hudmsg.size];
	_a=a;
	self.hudmsg[self.hudmsgID]=spawnStruct();
	//self.hudmsg[self.hudmsgID].override=override;
	self.hudmsg[self.hudmsgID].alpha=a;
	self.hudmsg[self.hudmsgID].override=override;
	self.hudmsg[self.hudmsgID].txt=txt;
	self.hudmsg[self.hudmsgID].stop=undefined;
	self.hudmsg[self.hudmsgID].dur=dur;
	//self.hudmsg[self.hudmsgID-1]=override;
	//cl("11override:"+self.hudmsg[self.hudmsgID-1]);
	msgID=self.hudmsgID;
	//msgID=level.msgID;
	aprev=1;
	hudHint=[];
	hudHint[0]="";
	//self.showHint=true;
	wait delay;
	size=0;
	blob="asdfghjklqwertyuiopzxcvbnm";
	c=3;
	ntxt=txt;
	//cl("55"+self.name+" : "+self.hudmsgID+": "+txt);
	stop=undefined;
	//cl("^3_show_hint_msg");
	//cl("33hintmsg:"+txt);
	//cl("33"+txt.size);
	
	if(isDefined(cx)){ x=x-(txt.size*fsc*6.45)/2; }
	if(isDefined(cy)){ y=y-(txt.size*fsc*6.45)/2; }
	
	while(size<txt.size && !isDefined(stop)){
		r=randomIntRange(0,blob.size);
		//blob[size]=rarr[r];
		//while(txt[r] == " " && r>0){ r--; }
		//blob = StrRepl(txt,txt[size],rarr[r]); 
		//if(c<0){ txt = StrRepl(txt,txt[size-2],txt[size]); }
		if(c<0){ size+=chrs; c=1; }
		//hudHint[0]="";
		ntxt="";
		//txt[size]=blob[r];
		if(size>txt.size){ size=txt.size; } //well... a couple of hours took me to solve faster cypher with this ;)
		for(i=0;i<size;i++){ ntxt+=txt[i]; }
		if(size<txt.size){ hudHint[0]=ntxt+blob[r]; } else { hudHint[0]=ntxt; }
		//data=self _get_override_data();
		//if(isDefined(self.hudmsg[self.hudmsgID-1])){ 
		if(isDefined(self.hudmsg[self.hudmsgID])){
			if(isDefined(self.hudmsg[self.hudmsgID].override)){ 
				if(self.hudmsg[self.hudmsgID].override==true){
					//data.alpha-=0.05; 
					//cl("data");
					cl("11stopped: "+self.hudmsg[self.hudmsgID-1].txt);
					dur=0;
					stop=true;
					//self.hudmsg[self.hudmsgID-1].stop=true;
					//self.hudmsg[self.hudmsgID-1].dur=0;
					//self.hudmsg[self.hudmsgID].alpha-=0.05;
					//a=self.hudmsg[self.hudmsgID].alpha;
					//self _create_menu_text("hudHint"+msgID,hudHint,x,y,w,h,ax,ay,ox,oy,ft,fsz,fsc,color,a,gc,ga,sort,undefined,undefined,undefined,undefined);
					//a-=0.05; dur=0; 
					//cl("override:"+override); 
					//self _change_menu("hudHint"+(msgID-1),"a",aprev);
					//aprev-=0.02;
				} else if(self.hudmsg[self.hudmsgID].override==false){
					//self _create_menu_text("hudHint"+msgID,hudHint,x,y,w,h,ax,ay,ox,oy,ft,fsz,fsc,color,a,gc,ga,sort,undefined,undefined,undefined,undefined);
					//a=_a;
				} else {
					//stop=true;
				}
			}
		} else {
			//self _create_menu_text("hudHint"+msgID,hudHint,x,y,w,h,ax,ay,ox,oy,ft,fsz,fsc,color,_a,gc,ga,sort,undefined,undefined,undefined,undefined);
		}
		self _create_menu_text("hudHint"+msgID,hudHint,x,y,w,h,ax,ay,ox,oy,ft,fsz,fsc,color,a,gc,ga,sort,undefined,undefined,undefined,undefined);
		//self _create_menu_text("hudHint",hudHint,"default", 1.6,1.4,(r,g,b),_a,(0,0,0),0,300,300,"center","middle",ox,oy,1);
		//_create_menu_text(hud,arr,x,y,w,h,ax,ay,ox,oy,ft,fsz,fsc,color,a,gc,ga,sort,selector,scolor,div,skip);		
		self playLocalSound("cypher1");
		//self playLocalSound("mouse_click");
		//if(a<_a){ _a+=0.1; }
		wait 0.05;
		c--;
		if(size == txt.size && !isDefined(stop)){ wait dur; }
		self _destroy_menu("hudHint"+msgID); 
		if(a<=0){ stop=true; }
	}
	//wait 1;
	//while(_a>0){
	//self playLocalSound("cypher_start");
	while(size>0 && !isDefined(stop)){
		r=randomIntRange(0,blob.size);
		//for(i=0;i<txt.size;i++){ if(txt[i] != " "){ txt[i]=" "; }}
		//while(txt[r] == " " && r>0){ r--; }
		//txt = StrRepl(txt,txt[r],blob[r]);
		ntxt="";
		for(i=0;i<size-1;i+=2){ ntxt+=txt[i]; ntxt+=txt[i+1]; }
		ntxt+=blob[r];
		hudHint[0]=ntxt;
		//if(isDefined(override)){ a-=0.1; }
		self _create_menu_text("hudHint"+msgID,hudHint,x,y,w,h,ax,ay,ox,oy,ft,fsz,fsc,color,a,gc,ga,sort);
		//_create_menu_text(hud,arr,ft,fsz,fsc,color,a,gc,ga,x,y,ax,ay,ox,oy,sort,selector,scolor,div,skip){		
		self playLocalSound("cypher1");
		//self playLocalSound("mouse_click");
		//if(ntxt.size==txt.size+3){ wait dur; }
		//if(a==_a){ wait dur; }
		//if(a>0){ a-=0.1; }
		wait 0.05;
		size-=chre;
		//if(size == txt.size){ wait 1; }
		self _destroy_menu("hudHint"+msgID); 
		if(a<=0){ stop=true; }
	}
	//cl("33"+self.name+" hud ended");
}

_welcome_msg(){
	self endon ( "disconnect" );
	//self endon ( "death" );
	self endon( "intermission" );
	self endon( "game_ended" );
	if (self.isbot){ return; }
	
	if(!isDefined(self.readDay)){ self.readDay=0; }
	if(!isDefined(self.prevReadDay)){ self.prevReadDay=-1; }

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
		//self _create_menu_bg("hudWelcomeBG","middle","middle",0,0,400,400,(r,g,b),1001,a,"black",50);
		self _create_menu_text("hudWelcome",hudWelcome,320,180,0,0,"center","middle",0,0,"default", 1.6,1.4,(r,g,b),a,(0,0,0),0,1);
		//_create_menu_text(hud,arr,x,y,w,h,ox,oy,ax,ay,ft,fsz,fsc,color,a,gc,ga,sort,selector,scolor,div,skip){		
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
		//self _create_menu_bg("hudWelcomeBG","middle","middle",0,0,400,400,(r,g,b),1001,a,"black",50);
		self _create_menu_text("hudWelcome",hudWelcome,320,180,0,0,"center","middle",0,0,"default", 1.6,1.4,(r,g,b),a,(0,0,0),0,1);
		//_create_menu_text(hud,arr,x,y,w,h,ax,ay,ox,oy,ft,fsz,fsc,color,a,gc,ga,sort,selector,scolor,div,skip){		
		if(r==1){ wait 1; }
		//self _create_menu_text("hudWelcome",txt,"default", 1.6,1.4,(1,1,1),0,"middle","middle",0,0,1,1);
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

	if(getDvarInt("v01d_motd") != 1){ game["hasReadMOTD"][self.name]=true; }

	if (game["hasReadMOTD"][self.name]==false){
		self thread _accept();
		//motd=game["MOTD"];
		//self.hudMOTD[0]=motd;
		
		self.hudMOTDdateTimes[0]="^1"+game["MOTD"]["dateTimes"][self.readDay];
		self.hudMOTDreports[0]="^7"+game["MOTD"]["reports"][self.readDay];
		self.hudMOTDfooter[0]="\n\n\n\n\n\n\n\n\n\n^2Press left or RIGHT button to navigate\n";
		self.hudMOTDfooter[0]+="^1Press JUMP button to destroy this message\n";
		
		if(isDefined(self.hudMOTDdateTimes) && isDefined(self.hudMOTDreports)){
		//if(isDefined(self.hudMOTD) && isDefined(motd)){
			while(h<300){
				//self _create_menu_text("hudWelcome",self.hudMOTD[0],"default", 1.6,1.4,(r,g,b),a,(0,0,0),0,"center","middle",0,-70,2);
				self _create_menu_text("hudMOTDdateTimes",self.hudMOTDdateTimes,320,155,0,0,"center","middle",0,0,"default", 1.6,1.4,(r,g,b),a,(0,0,0),0,1);
				self _create_menu_text("hudMOTDreports",self.hudMOTDreports,200,155,0,0,"left","middle",0,0,"default", 1.6,1.4,(r,g,b),a,(0,0,0),0,1);
				self _create_menu_text("hudMOTDfooter",self.hudMOTDfooter,200,155,0,0,"left","middle",0,0,"default", 1.6,1.4,(r,g,b),a,(0,0,0),0,1);
				//self _create_menu_bg("hudWelcomeBG","middle","middle",0,0,w,h,(r,g,b),1,a,"black",50,"fullscreen","fullscreen");
				self _create_menu_bg("hudWelcomeBG",-160,-120,320,240,0,0,"center","middle",(0,0,0),a,0,"black",50);
				//_create_menu_bg(bg,x,y,w,h,ox,oy,ax,ay,color,a,sort,shader,aperc){
				if(r<1){ r+=0.1;g+=0.1;b+=0.1;a+=0.1; }
				if(w<400){ w+=30; }
				if(h<300){ h+=20; }
				//level waittill("timers");
				wait 0.05;
				//self _destroy_menu(self.money["hudWelcomeBG"]);
				self _destroy_menu("hudMOTDdateTimes");
				self _destroy_menu("hudMOTDreports");
				self _destroy_menu("hudMOTDfooter");
				self _destroy_bg("hudWelcomeBG");
				c++;
				//wait 0.05;
			}
			
			self notify("readyToPressAccept");
			self thread _nav_motd();

			while(h>1){
				//self _create_menu_text("hudWelcome",self.hudMOTD[0],"default", 1.6,1.4,(r,g,b),a,(0,0,0),0,"center","middle",0,-70,2);
				self _create_menu_text("hudMOTDdateTimes",self.hudMOTDdateTimes,320,155,0,0,"center","middle",0,0,"default", 1.6,1.4,(r,g,b),a,(0,0,0),0,1);
				self _create_menu_text("hudMOTDreports",self.hudMOTDreports,200,155,0,0,"left","middle",0,0,"default", 1.6,1.4,(r,g,b),a,(0,0,0),0,1);
				self _create_menu_text("hudMOTDfooter",self.hudMOTDfooter,200,155,0,0,"left","middle",0,0,"default", 1.6,1.4,(r,g,b),a,(0,0,0),0,1);
				//self _create_menu_bg("hudWelcomeBG","middle","middle",0,0,w,h,(r,g,b),1,a,"black",50,"fullscreen","fullscreen");
				self _create_menu_bg("hudWelcomeBG",-160,-120,320,240,0,0,"center","middle",(0,0,0),a,0,"black",50);
				//_create_menu_bg(bg,x,y,w,h,ox,oy,ax,ay,color,a,sort,sh,aperc){
				//if(r==1){ wait 2; }
				//self _create_menu_text("hudWelcome",txt,"default", 1.6,1.4,(1,1,1),0,"middle","middle",0,0,1,1);
				if(level.gameEnded || game["hasReadMOTD"][self.name]==true){
					if(r>0){ r-=0.1;g-=0.1;b-=0.1;a-=0.1; }
					if(w>1){ w-=30; }
					if(h>1){ h-=20; }
				}
				//level waittill("timers");
				wait 0.05;
				//self _destroy_menu(self.money["hudWelcomeBG"]);
				self _destroy_menu("hudMOTDdateTimes");
				self _destroy_menu("hudMOTDreports");
				self _destroy_menu("hudMOTDfooter");
				self _destroy_bg("hudWelcomeBG");
				c++;
				//wait 0.05;
			}
		}
	}
	if(!level.gameEnded){ 
		self notify("hasReadMOTD");
		cl("22hasReadMOTD");
		while(level.inPrematchPeriod){ wait 0.1; }
		self freezeControls(false);
	}
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
		self.hudMOTDdateTimes[0]="^1"+game["MOTD"]["dateTimes"][self.readDay];
		self.hudMOTDreports[0]="^7"+game["MOTD"]["reports"][self.readDay];

		if (self MoveleftButtonPressed()){ 
			//cl(self.name+" pressed left key");
			self notify("hasPressedMoveleftButton");
			self.readDay++;
			if(!isDefined(game["MOTD"]["dateTimes"][self.readDay])){ self.readDay--; }
			//cl("self.readDay:"+game["MOTD"]["dateTimes"][self.readDay]);
			//cl("self.readDay:"+game["MOTD"]["reports"][self.readDay]);
			//motd=game["MOTD"]["dateTimes"][self.readDay];
			//motd+=game["MOTD"]["reports"][self.readDay];
			//if(isDefined(motd)){ self.hudMOTD[0]=motd; }
			self playLocalSound("mouse_click");
			while (self MoveleftButtonPressed()){ wait 0.05; }
		}
		
		if (self MoveRightButtonPressed()){ 
			//cl(self.name+" pressed RIGHT key"); 
			self notify("hasPressedMoveRightButton");
			if(self.readDay>0){ self.readDay--; }
			//cl("self.readDay:"+game["MOTD"]["dateTimes"][self.readDay]);
			//cl("self.readDay:"+game["MOTD"]["reports"][self.readDay]);
			//motd=game["MOTD"]["dateTimes"][self.readDay];
			//motd+=game["MOTD"]["reports"][self.readDay];
			//if(isDefined(motd)){ self.hudMOTD[0]=motd; }
			self playLocalSound("mouse_click");
			while (self MoveRightButtonPressed()){ wait 0.05; }
		}
		wait 0.05;
	}
}

_map_datetime_menu(){
	self endon ( "disconnect" );
	//if(self.isbot){ return; }
	
	map=[]; dateTime=[];
	x=-100; y=440; ax="left"; ay="bottom"; a=0.5; ft="default"; fsz=1.4; fsc=1.6; color=(1,1,1); a=0.3;
	
	wait 1;
	for(;;){
		version[0]=getDvar("v01d_version");
		map[0]=getDvar("mapname");
		realTime = getRealTime();
		realDate = TimeToString(realTime, 0, "%F");
		dateTime[0] = TimeToString(realTime, 0, "%F %T");

		if (getDvar("v01d_version") == "") { setDvar("v01d_version", " "); }
		
		if(isDefined(dateTime) && isDefined(dateTime)){
			self _create_menu_text("hudModVersion",version,x,y,0,0,ax,ay,0,0,ft,fsz,fsc,color,a);
			self _create_menu_text("hudMap",map,x,y+14,0,0,ax,ay,0,0,ft,fsz,fsc,color,a);
			self _create_menu_text("hudDateTime",dateTime,x,y+28,0,0,ax,ay,0,0,ft,fsz,fsc,color,a);
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
	x=740;y=460; ax="right";
	money=[];
	
	while(1){
		while(!isDefined(self.money)) { wait 0.5; }
		while (game["state"] == "postgame" || level.gameEnded || !isAlive(self)) { wait 1; }
		if(isDefined(self.money["acc"])){
			money[0]=self.money["acc"]+"$";
			if(isDefined(self.notEnoughMoney)){
				if(c<10){
					//_create_menu_text(hud,arr,x,y,w,h,ax,ay,ox,oy,ft,fsz,fsc,color,a,gc,ga,sort,selector,scolor,div,skip){
					if(c%2==0){ self _create_menu_text("hudMoney",money,x,y,undefined,undefined,ax,undefined,undefined,undefined,undefined,undefined,undefined,(1,0,0)); }
					else { self _create_menu_text("hudMoney",money,x,y,undefined,undefined,ax,undefined,undefined,undefined,undefined,undefined,undefined,(1,1,1)); }
					c++;
				} else { self.notEnoughMoney=undefined; c=0; }
			} else if(isDefined(self.spentMoney)){
				//_create_menu_text(hud,arr,x,y,w,h,ax,ay,ox,oy,ft,fsz,fsc,color,a,gc,ga,sort,selector,scolor,div,skip){
				self _create_menu_text("hudMoney",money,x,y,undefined,undefined,ax,undefined,undefined,undefined,undefined,undefined,undefined,(1,0,0));
				wait 0.1;
				self _destroy_menu("hudMoney");
				self _create_menu_text("hudMoney",money,x,y,undefined,undefined,ax,undefined,undefined,undefined,undefined,undefined,undefined,(1,1,1));
				self.spentMoney=undefined;
			} else {
				self _create_menu_text("hudMoney",money,x,y,undefined,undefined,ax,undefined,undefined,undefined,undefined,undefined,undefined,(1,1,1));;
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
		self setClientDvar("m_pitch",0.001);
		self setClientDvar("m_yaw",0.001);
		//sens = self getClientDvar("cl_mouseAccel");
		//cl("^4cl_mouseAccel:"+sens);
		//self setClientDvars("cl_mouseAccel", 0);
		//self _create_menu_bg("hudBuyMenuBG","middle","middle",0,0,200,100,(r,g,b),1,a,"white");
				
		while(isAlive(self) && isDefined(self.buyMenuShow)){
			//cl("^4pitch:"+pitch);
			if(isDefined(self.spawnStartOrigin) && distance(self.spawnStartOrigin,self.origin)>=16){ self.buyMenuShow=undefined; }
			if(isDefined(self.buyMenuShow)){
				//cl(self.buyMenuShow[1]);
				for(i=0;i<self.buyMenuShow.size;i+=3){
					if(isDefined(self.buyMenuShow[i]) && isDefined(self.buyMenuShow[i+2])){
						/*str="";
						for(j=0;self.buyMenuShow[i+2].size;j++){
							str+=self.buyMenuShow[i+2][j];
							if(self.buyMenuShow[i+2][j]=="_"){ break; }
						}*/
						if(isSubStr(self.buyMenuShow[i+2],"_mp") && !isSubStr(self.buyMenuShow[i+2],"c4") && !isSubStr(self.buyMenuShow[i+2],"claymore") && !isSubStr(self.buyMenuShow[i+2],"grenade") && !isSubStr(self.buyMenuShow[i],"1 CLIP") && isDefined(self _check_weapon_in_list(self.buyMenuShow[i+2]))){ 
						//if(isSubStr(self.buyMenuShow[i+2],"_mp") && !isSubStr(self.buyMenuShow[i+2],"c4") && !isSubStr(self.buyMenuShow[i+2],"claymore") && !isSubStr(self.buyMenuShow[i+2],"grenade") && !isSubStr(self.buyMenuShow[i],"1 CLIP") && isDefined(self _check_weapon_in_list(self.buyMenuShow[i+2]))){ 
							//clipSize=WeaponClipSize(self.buyMenuShow[i+2]);
							//self.buyMenuShow[i]+=" [AMMO | 1 CLIP = "+(clipSize*1.5)+"$]"; 
							self.buyMenuShow[i]+=" [AMMO | 1 CLIP = "+(int(self.buyMenuShow[i+1])/10)+"$]"; 
						}
						/*if(isSubStr(self.buyMenuShow[i+2],"tools_")){
							if(isDefined(self.haveTools)){
								if(isSubStr(self.buyMenuShow[i+2],"_defkit")){
									self.haveTools["defkit"]=1;
									//self playSound("weap_pickup");
								}
							}
						}*/

						//cl(self.buyMenuShow[i]);
					}
				}
			}
			if(AttackButtonPressed==false){
				if(selector>0 && selector<=size) {
					if(pitch>curView[0]+1 || self LeanleftButtonPressed()) { selector--; pitch=curView[0]; }
					else if(pitch<curView[0]-1 || self LeanRightButtonPressed()) { selector++; pitch=curView[0]; }
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
				//self _create_menu_text("hudBuyMenu",arr,"default", 1.6,1.4,(r,g,b),0,"middle","middle",100,0,a,1,selector,scolor);
				if(isDefined(self.buyMenuShow)){
					//_create_menu_text(hud,arr,x,y,w,h,ax,ay,ox,oy,ft,fsz,fsc,color,a,gc,ga,sort,selector,scolor,div,skip){
					self _create_menu_text("hudBuyMenu",self.buyMenuShow,0,200,0,0,"left","middle",0,0,"default",1.6,1.4,(r,g,b),a,(0,0,0),0,1,selector,scolor,div);				
				}
				wait 0.1;
				curView = self getPlayerAngles();
				if(sw==1){sw=0;wait 0.5;}
				if(isDefined(self.buyMenuShow)){
					self _destroy_menu("hudBuyMenu",self.buyMenuShow.size,div);
				}
			}								//hud,txt,ft,fsz,fsc,color,glow,ax,ay,w,h,a,sort,selector,scolor
		}
		wait 0.05;
	}
	//self.hasChosen=undefined;
	//self _destroy_menu("hudBuyMenu",arr.size,div); 
	self EnableWeapons();
	self setClientDvar("m_pitch",0.022);
	self setClientDvar("m_yaw",0.022);
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
	
	buyMenuMain = StrTok("Pistols,SMGs,MGs,Rifles,Snipers,RPGs,GLs,Grenades,Explosives,Tools",",");
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
	buyMenuTools = undefined;

	if(self.pers["team"] == "axis"){
		buyMenuMain = StrTok("Pistols,SMGs,MGs,Rifles,Snipers,RPGs,GLs,Grenades,Tools",",");
		buyMenuAmmo = StrTok(self _buy_weapons_ammo(),",");
		buyMenuPistols = StrTok("Beretta Silenced,138,beretta_silencer_mp,Desert Eagle,230,deserteagle_mp,Desert Eagle Gold,400,deserteaglegold_mp,RW1,450,winchester1200_grip_mp",",");
		//buyMenuPistols = StrTok("Beretta Silenced,138,beretta_silencer_mp,Desert Eagle,230,deserteagle_mp,Desert Eagle Gold,400,deserteaglegold_mp,RW1,450,rw1_mp",",");
		buyMenuSMGs = StrTok("Uzi,320,uzi_mp,Skorpion,440,skorpion_mp,AK74U,580,ak74u_mp",",");
		buyMenuMGs = StrTok("SAW,1200,saw_mp,RPD,1300,rpd_mp",",");
		buyMenuRifles = StrTok("AK47,640,ak47_mp,AK47 GL,800,ak47_gl_mp,G3 GL,1000,g3_gl_mp,",",");
		buyMenuSnipers = StrTok("Dragunov,640,dragunov_mp,SVG-100,1200,barrett_mp",",");
		buyMenuRPGs = StrTok("RPG,1200,rpg_mp",",");
		//buyMenuRPGs = StrTok("RPG,2300,rpg_mp,LAW,2500,law_mp,AT4,2600,at4_mp",",");
		buyMenuGLs = StrTok("MM1,2400,barrett_acog_mp",",");
		//buyMenuGLs = StrTok("MM1,2400,mm1_mp",",");
		buyMenuGrenades = StrTok("Frag Grenade,15,frag_grenade_mp",",");
		buyMenuExplosives = StrTok("Claymore,100,claymore_mp,C4,400,c4_mp",",");
		buyMenuTools = StrTok("Defuse Kit,75,tools_defkit",",");
		//buyMenuGrenades = StrTok("Smoke Grenade,10,smoke_grenade_mp,Flash Grenade,20,flash_grenade_mp,Concussion Grenade,30,concussion_grenade_mp,Frag Grenade,40,frag_grenade_mp",",");
	} else if (self.pers["team"] == "allies") {
		buyMenuMain = StrTok("Pistols,SMGs,MGs,Rifles,Snipers,RPGs,GLs,Grenades,Explosives,Tools",",");
		buyMenuAmmo = StrTok(self _buy_weapons_ammo(),",");
		buyMenuPistols = StrTok("Colt 45 Silenced,155,colt45_silencer_mp,USP Silenced,167,usp_silencer_mp",",");
		buyMenuSMGs = StrTok("MP5,550,mp5_silencer_mp,G36C GL,630,g36c_gl_mp,P90,900,p90_silencer_mp",",");
		buyMenuMGs = StrTok("M60E4,1600,m60e4_mp",",");
		buyMenuRifles = StrTok("M4 GL,1200,m4_gl_mp,M21,1650,m21_mp,Striker,1800,winchester1200_reflex_mp",","); //M4 is automatic
		//buyMenuRifles = StrTok("M4 GL,1200,m4_gl_mp,M21,1650,m21_mp,Striker,1800,striker_mp",","); //M4 is automatic
		buyMenuSnipers = StrTok("TAC330,2000,ak47_acog_mp,TAC330 Silenced,2300,ak47_silencer_mp",",");
		//buyMenuSnipers = StrTok("TAC330,2000,tac330_mp,TAC330 Silenced,2300,tac330_sil_mp",",");
		//buyMenuRPGs = StrTok("AT4,2600,at4_mp",",");
		buyMenuRPGs = StrTok("LAW,2200,skorpion_acog_mp,AT4,3200,skorpion_reflex_mp",",");
		//buyMenuRPGs = StrTok("LAW,2200,law_mp,AT4,3200,at4_mp",",");
		buyMenuGLs = StrTok("MM1,3000,barrett_acog_mp",",");
		//buyMenuGLs = StrTok("MM1,3000,mm1_mp",",");
		buyMenuGrenades = StrTok("Concussion Grenade,20,concussion_grenade_mp,Frag Grenade,35,frag_grenade_mp",",");
		buyMenuExplosives = StrTok("Claymore,100,claymore_mp,C4,400,c4_mp",",");
		buyMenuTools = StrTok("Defuse Kit,150,tools_defkit",",");
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
				else if (self.hasChosen[i]=="Tools"){ self _buy_menu_show(buyMenuTools,"buyMenuMain",false,3); }
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
		wait 0.05;
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
