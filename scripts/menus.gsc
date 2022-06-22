#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include scripts\cl;

init()
{
	//if (!getdvarint("developer")>0){ return; }
	if (getdvarint("bots_main_debug")>0){ return; }
	
	if (!isDefined(game["hasReadMOTD"])){ game["hasReadMOTD"]=[]; }

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
		player thread _welcome_msg();
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
		player thread _spawn_loop();

		//wait 0.1;
		//player setClientDvar( "ui_lobbypopup", "summary" );
	}
}

_spawn_loop(){
	self endon ( "disconnect" );
	//self endon ( "death" );
	self endon( "intermission" );
	self endon( "game_ended" );

	for(;;){
		self waittill("spawned_player");
		while(level.inPrematchPeriod){ wait 0.1; }
		self thread _buy_menu_main();
		wait 1;
		self _show_hint_msg(0,"press FIRE button to select",1,1,1,0,1,-200,-80);
		self _show_hint_msg(0,"press ADS button to return",1,1,1,0,1,-200,-70);
		//delay,txt,dur,r,g,b,a,ox,oy
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
	if(!isDefined(scolor)){ scolor=(0,1,0); }
	if(!isDefined(div)){ div=1; }
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

_create_menu_bg(bg,align,relative,x,y,w,h,color,sort,alpha,sh,aperc){
	self endon ( "disconnect" );
	self endon ( "death" );
	self endon( "intermission" );
	self endon( "game_ended" );
	if(self.isbot){ return; }
	
	alpha=alpha*(aperc/100);
	self.money[bg] = undefined;
	self.money[bg] = self createRectangle(align,relative,x,y,w,h,color,sort,alpha,sh);
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

createRectangle(align,relative,x,y,width,height,color,sort,alpha,shader)
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
	barElemBG setParent( level.uiParent );
	if(isDefined(shader)){ barElemBG setShader( shader, width , height ); }
	barElemBG.hidden = false;
	barElemBG setPoint(align, relative, x, y);
	return barElemBG;
}

_get_motd_txt(){
	realTime = getRealTime();
	realDate = TimeToString(realTime, 0, "%F");
	dateTime = TimeToString(realTime, 0, "%F %T");
	//dateTime = StrRepl(playername, ":", "_");
	filename = "motd/"+realDate+".log";
	line="";
	lines="";
	chars=[];
	//cl("^3realDate: " + realDate);
	
	if ( !FS_TestFile( filename ) ) { cl("^1No log file available!"); } 
	else {
		csv = FS_FOpen(filename, "read");
		line = FS_ReadLine(csv);
		while (isDefined(line) && line != ""){
			cl("^3line: " + line);
			if (line == "") { continue; }
			lines+=line+"\n";
			line = FS_ReadLine(csv);
		}
		FS_FClose(csv);
		
		lines+="\n\n\n^1Press USE button to destroy this message\n";
		
		return lines;
		/*div=lines.size/256; c=0;
		for(d=0;d<div;d++){
			for(i=0;i<lines;i++){
				chars[d]+=lines[c]; 
			}
		}
		
		return chars;*/
	}
}

//---------------------------------------------------------------------------------------------------


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
	
	_a=0;
	hudHint=[];
	hudHint[0]=txt;
	self.showHint=true;
	wait delay;
	//cl("^3_show_hint_msg");
	
	while(_a<a){
		self _create_menu_text("hudHint",hudHint,"default", 1.6,1.4,(r,g,b),0,"CENTER","CENTER",ox,oy,_a,1);
		if(_a<a){ _a+=0.1; }
		wait 0.05;
		self _destroy_menu("hudHint");
	}
	while(_a>0){
		self _create_menu_text("hudHint",hudHint,"default", 1.6,1.4,(r,g,b),0,"CENTER","CENTER",ox,oy,_a,1);
		if(_a==a){ wait dur; }
		if(_a>0){ _a-=0.1; }
		wait 0.05;
		self _destroy_menu("hudHint");
	}
}

_welcome_msg(){
	self endon ( "disconnect" );
	//self endon ( "death" );
	self endon( "intermission" );
	self endon( "game_ended" );
	if (self.isbot){ return; }
	
	if (!isDefined(game["hasReadMOTD"][self.name])){ game["hasReadMOTD"][self.name]=false; }
	
	hudWelcome=[]; hudWelcomeBG=[];
	hudWelcome[0]="Welcome to my -=sabotage=- server! :)";
	c=0;r=0;g=0;b=0;a=0;
	//while(!isDefined(self.money)) { wait 0.5; }
	
	//cl("^2before waittill ReadWelcomeMsg");
	self waittill("ReadWelcomeMsg");
	//cl("^3ReadWelcomeMsg");
	//self waittill("spawned_player");
	wait 1;
	//self freezeControls(true);

	while(r<1){
		//self _create_menu_bg("hudWelcomeBG","CENTER","CENTER",0,0,400,400,(r,g,b),1,a,"black",50);
		self _create_menu_text("hudWelcome",hudWelcome,"default", 1.6,1.4,(r,g,b),0,"CENTER","CENTER",0,-70,a,1);
		if(r<1){ r+=0.1;g+=0.1;b+=0.1;a+=0.1; }
		wait 0.05;
		//self _destroy_menu(self.money["hudWelcomeBG"]);
		self _destroy_menu("hudWelcome");
		//self _destroy_bg("hudWelcomeBG");
		c++;
		//wait 0.05;
	}
	while(r>0){
		//self _create_menu_bg("hudWelcomeBG","CENTER","CENTER",0,0,400,400,(r,g,b),1,a,"black",50);
		self _create_menu_text("hudWelcome",hudWelcome,"default", 1.6,1.4,(r,g,b),0,"CENTER","CENTER",0,-70,a,1);
		if(r==1){ wait 1; }
		//self _create_menu_text("hudWelcome",txt,"default", 1.6,1.4,(1,1,1),0,"CENTER","CENTER",0,0,1,1);
		if(r>0){ r-=0.1;g-=0.1;b-=0.1;a-=0.1; }
		wait 0.05;
		//self _destroy_menu(self.money["hudWelcomeBG"]);
		self _destroy_menu("hudWelcome");
		//self _destroy_bg("hudWelcomeBG");
		c++;
		//wait 0.05;
	}
	
	if (game["hasReadMOTD"][self.name]==false){
		self thread _use_accept();
		hudWelcome[0]=_get_motd_txt();	
		
		if(isDefined(hudWelcome[0])){
			while(r<1){
				self _create_menu_text("hudWelcome",hudWelcome,"default", 1.6,1.4,(r,g,b),0,"CENTER","CENTER",0,-70,a,1);
				self _create_menu_bg("hudWelcomeBG","CENTER","CENTER",0,0,400,400,(r,g,b),1,a,"black",50);
				if(r<1){ r+=0.1;g+=0.1;b+=0.1;a+=0.1; }
				wait 0.05;
				//self _destroy_menu(self.money["hudWelcomeBG"]);
				self _destroy_menu("hudWelcome");
				self _destroy_bg("hudWelcomeBG");
				c++;
				//wait 0.05;
			}
			
			while(r>0){
				self _create_menu_text("hudWelcome",hudWelcome,"default", 1.6,1.4,(r,g,b),0,"CENTER","CENTER",0,-70,a,1);
				self _create_menu_bg("hudWelcomeBG","CENTER","CENTER",0,0,400,400,(r,g,b),1,a,"black",50);
				//if(r==1){ wait 2; }
				if(r==1){ 
					self notify("readyToPressFButton");
					self waittill("hasPressedFButton"); 
				}
		
				//self _create_menu_text("hudWelcome",txt,"default", 1.6,1.4,(1,1,1),0,"CENTER","CENTER",0,0,1,1);
				if(r>0){ r-=0.1;g-=0.1;b-=0.1;a-=0.1; }
				wait 0.05;
				//self _destroy_menu(self.money["hudWelcomeBG"]);
				self _destroy_menu("hudWelcome");
				self _destroy_bg("hudWelcomeBG");
				c++;
				//wait 0.05;
			}
		}
	}
	self notify("hasReadWelcomeMsg");
	self freezeControls(false);
}

_use_accept(){
	self endon ( "disconnect" );
	//self endon ( "death" );
	//self endon( "intermission" );
	//self endon( "game_ended" );
	//if (!getdvarint("developer")>0){ return; }
	if(self.isbot){ return; }
	self waittill("readyToPressFButton");
	while (!self UseButtonPressed()){ wait 0.05; }
	self notify("hasPressedFButton");
	if (game["hasReadMOTD"][self.name]==false){ game["hasReadMOTD"][self.name]=true; }
	self playLocalSound("mp_last_stand");
	cl("^2"+self.name+" has read MOTD");
	//while (self UseButtonPressed()){ wait 0.05; }
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
	size=arr.size/div;
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
			if(AttackButtonPressed==false){
				if(selector>0 && selector<=size) {
					if(pitch>curView[0]+5) { selector--; pitch=curView[0]; }
					else if(pitch<curView[0]-5) { selector++; pitch=curView[0]; }
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
					if(next){ self.buyMenuShow=undefined; }
					//self.buyMenuShowNext=next; 
					AttackButtonPressed=false;
					//cl("^3selector:"+selector);
					for(i=0;i<div;i++){
						self.hasChosen[i]=arr[(selector-1)*div+i];
						//cl("^3self.hasChosen:"+self.hasChosen[i]);
					}
					self notify("isBuying");
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
				//self _create_menu_text("hudBuyMenu",arr,"default", 1.6,1.4,(r,g,b),0,"CENTER","CENTER",100,0,a,1,selector,scolor);
				self _create_menu_text("hudBuyMenu",arr,"default", 1.6,1.4,(r,g,b),0,"LEFT","CENTER",-300,0,a,1,selector,scolor,div);				
				wait 0.05;
				curView = self getPlayerAngles();
				if(sw==1){sw=0;wait 0.5;}
				self _destroy_menu("hudBuyMenu",arr.size,div);
			}								//hud,txt,ft,fsz,fsc,color,glow,ax,ay,w,h,a,sort,selector,scolor
		}
		wait 0.1;
	}
	//self.hasChosen=undefined;
	//self _destroy_menu("hudBuyMenu",arr.size,div); 
	self EnableWeapons();
	//cl("^3hud destroyed");
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
		buyMenuPistols = StrTok("Beretta Silenced,138,beretta_silencer_mp,Desert Eagle,230,deserteagle_mp,Desert Eagle Gold,400,deserteaglegold_mp,RW1,450,rw1_mp",",");
		buyMenuSMGs = StrTok("Uzi,320,uzi_mp,Skorpion,440,skorpion_mp,AK74U,580,ak74u_mp",",");
		buyMenuMGs = StrTok("SAW,1200,saw_mp,RPD,1300,rpd_mp",",");
		buyMenuRifles = StrTok("AK47,640,ak47_mp,AK47 GL,800,ak47_gl_mp",",");
		buyMenuSnipers = StrTok("Dragunov,640,dragunov_mp",",");
		buyMenuRPGs = StrTok("RPG,1200,rpg_mp",",");
		//buyMenuRPGs = StrTok("RPG,2300,rpg_mp,LAW,2500,law_mp,AT4,2600,at4_mp",",");
		buyMenuGLs = StrTok("MM1,2400,mm1_mp",",");
		buyMenuGrenades = StrTok("Frag Grenade,15,frag_grenade_mp",",");
		//buyMenuGrenades = StrTok("Smoke Grenade,10,smoke_grenade_mp,Flash Grenade,20,flash_grenade_mp,Concussion Grenade,30,concussion_grenade_mp,Frag Grenade,40,frag_grenade_mp",",");
		//buyMenuAmmo = StrTok("",",");
	} else if (self.pers["team"] == "allies") {
		buyMenuMain = StrTok("Pistols,SMGs,MGs,Rifles,Snipers,RPGs,GLs,Grenades,Explosives",",");
		buyMenuPistols = StrTok("Colt 45 Silenced,155,colt45_silencer_mp,USP Silenced,167,usp_silencer_mp",",");
		buyMenuSMGs = StrTok("MP5,550,mp5_silencer_mp,P90,900,p90_silencer_mp",",");
		buyMenuMGs = StrTok("M60E4,1600,m60e4_mp",",");
		buyMenuRifles = StrTok("M16 GL,1200,m16_gl_mp,M21,1650,m21_mp,Striker,1800,striker_mp",",");
		buyMenuSnipers = StrTok("TAC330,2000,tac330_mp,TAC330 Silenced,2300,tac330_sil_mp",",");
		//buyMenuRPGs = StrTok("AT4,2600,at4_mp",",");
		buyMenuRPGs = StrTok("LAW,2200,law_mp,AT4,3200,at4_mp",",");
		buyMenuGLs = StrTok("MM1,3000,mm1_mp",",");
		buyMenuGrenades = StrTok("Concussion Grenade,20,concussion_grenade_mp,Frag Grenade,35,frag_grenade_mp",",");
		buyMenuExplosives = StrTok("Claymore,100,claymore_mp",",");
	}
	while(!isAlive(self) || self.sessionstate == "spectator"){ wait 0.1; }
	//cl("^3self.spawnStartOrigin");
	//while(isAlive(self) && !self UseButtonPressed()){ wait 0.05; }
	wait 0.3;
	self.spawnStartOrigin=self.origin;
	self.hasChosen[0]="buyMenuMain";
	while(isAlive(self) && distance(self.spawnStartOrigin,self.origin)<32){
		//if(!isDefined(self.hasChosen)){ self _buy_menu_show(buyMenuMain); cl("^3self.buyMenuMain"); }
		if(isDefined(self.hasChosen)){
			for(i=0;i<self.hasChosen.size;i++){
				//cl("^3isDefined(self.hasChosen)");
				if (self.hasChosen[i]=="buyMenuMain"){ self _buy_menu_show(buyMenuMain,"buyMenuMain",true,1); }
				else if (self.hasChosen[i]=="Pistols"){ self _buy_menu_show(buyMenuPistols,"buyMenuMain",false,3); }
				else if (self.hasChosen[i]=="SMGs"){ self _buy_menu_show(buyMenuSMGs,"buyMenuMain",false,3); }
				else if (self.hasChosen[i]=="MGs"){ self _buy_menu_show(buyMenuMGs,"buyMenuMain",false,3); }
				else if (self.hasChosen[i]=="Rifles"){ self _buy_menu_show(buyMenuRifles,"buyMenuMain",false,3); }
				else if (self.hasChosen[i]=="Snipers"){ self _buy_menu_show(buyMenuSnipers,"buyMenuMain",false,3); }
				else if (self.hasChosen[i]=="RPGs"){ self _buy_menu_show(buyMenuRPGs,"buyMenuMain",false,3); }
				else if (self.hasChosen[i]=="GLs"){ self _buy_menu_show(buyMenuGLs,"buyMenuMain",false,3); }
				else if (self.hasChosen[i]=="Grenades"){ self _buy_menu_show(buyMenuGrenades,"buyMenuMain",false,3); }
				else if (self.hasChosen[i]=="Explosives"){ self _buy_menu_show(buyMenuExplosives,"buyMenuMain",false,3); }
				//else if (self.hasChosen[i]=="Ammo"){ self _buy_menu_show(buyMenuAmmo,"buyMenuMain",false,3); }
			}
		}
		while(isDefined(self.buyMenuShow) && isDefined(self.hasChosen) && isAlive(self)){ 
			if(distance(self.spawnStartOrigin,self.origin)>=16){ self.buyMenuShow=undefined; }
			//cl("^3self.spawnStartOrigin");
			wait 0.05; 
		}
		//cl("^3self.buyMenuShowNext");
		wait 0.1;
		//while(isAlive(self) && self UseButtonPressed()){ wait 0.05; }

	}
}
