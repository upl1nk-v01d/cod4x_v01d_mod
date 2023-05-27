# cod4x v01d mod files

the mod files for cod4x provided by v01d

-------------------------------------------

updated 2023.05.26 v01d mod.ff, iwd and other mod files at https://drive.google.com/drive/folders/186GyQw-vKV_bFqAfxdYtRPXcxtaSnoCb

-------------------------------------------

important notes:

please add additional args to your cod4x server and client executable:
+set r_xassetnum xmodel=2300 material=4096 weapon=256 loaded_sound=2400

-------------------------------------------

dvars:

v01d_bots_inbalance_feature 1 //round loosing team gets one bot: 1=on, 0=off

v01d_bots_recoil_spicyness 0.2 //bot recoil coefficient must be greater than 0.00

v01d_log_players 1 //logging real players into fs_homepath: 1=on, 0=off

v01d_motd 1 //enabling playershowing MOTD when connected to server: 1=on, 0=off

v01d_item_pickup_mode 1 //picking up weapons from ground takes time: 1=on, 0=off

v01d_item_pickup_time 0.7 //picking up weapons time in seconds

v01d_item_remove_time 10 //weapon burrying in ground time in seconds

v01d_maps_randomizer 1 //random map loading on match end: 1=on, 0=off

v01d_suicide_sfx 1 // //suicide screaming sounds: 1=on, 0=off

v01d_knifed_sfx 1 // //knifed screaming sounds: 1=on, 0=off

-------------------------------------------

updates log:

2023 05 26
converted mm1 to projectile type weapon; 
fixed em1 flyby and hit sound; 
fixed swaping at4 issue.

2023 05 21
added 4 new weapons: 
remington r5, svu, ump45 & pytaek.

2023 05 19
added 4 new weapons: 
ak12, arx160, cz805 & honeybadge.

2023 05 16
fixed gametype change on new loading level

2023 04 22
fixing item pickup issues;

2023 03 14
fixed hint messages overlaying;

2023 02 27
managed dvars for new item pickup mode;
fixed damage bug on falling;
fixed hud removing when player not alive;
fixed viewhands appearing without weapon.

2023 02 24
code cleanup and dvars management in main.gsc

2023 02 22
added distbooms for mm1 and alt gl weapons;
tweaked hint messages to cypher faster;
in lastStand weapons can be picked up.

2023 02 21
added defuse kit in menu for defusing bomb faster.

2023 02 19
added dvar v01d_maps_randomizer to turn on/off 
map randomizer, set default to 1.

2023 02 12
made workaround with item pickup;
fixed bot starring on c4 and claymore.

2023 02 08
fixed bots stop moving after a while.

2023 02 04
adjusted bots fire interval with dp;
drop weapon on devastating hit;
bots are reacting to fire sounds.

2023 02 03
weapons interruption on blast wave and push;
slowed down mouse speed on buymenu.

2023 02 01
fixing overlaying hint messages.

2023 01 31
after a long research looks like
that 128 bone error is fixed by
disabling players weapons stow. :)
to my understanding the cause was
that player entity has been added 
bone by attaching stow weapon.

2023 01 25
all MOTD reports stored in motd.log file;
fixed navigation in MOTD thread.

2023 01 22
slowed down TAC330 reload anim;
improved bot inbalance feat.

2023 01 11
weapons removed:
GPAS 12 from Marines;

fixed:
dobj 128 bones error;

tweaked explosion sounds.

2023 01 10
new weapons added:
GPAS 12 Marines;

fixed:
dobj 128 bones error and 128 weapon asset error.

2023 01 04
new weapons added:
PSG1 to Terrorists as rifles;
CheyTac to Marines as rifles.

2023 01 03
replaced stock weapons with new due limitation.
bots don't push anybody within 60.sec time;
returned team selection in game menu.

2022 12 30
drastically removed unused weapons 
due an limitation error;
increased bots weapon arsenal;

2022 12 29
added new cypher hud calls into stock scripts.

2022 12 27
reduced weapons because of 128 weapons limit;
added new in game text notifications huds;
calibrated hud text centering;

2022 12 26
added realistic earthquake on explosions;
bots moving and aiming more tactical;
reduced bots aiming when killed enemy;

2022 12 19
tweaked buy menu hint message showing;
fixed double force spawn;
adjusted bots aiming realism;
airstrike selector switching off when hit;
redefined knife damage based on distance.

2022 12 11
tweaked hud.menu elements visibility;

2022 12 10
added hs sounds for allies;
dizziness is calculated on damage fx;
reduced bullet damage velocity;
reduced chopper missile sound amp;
modified bots aiming.

2022 12 07
added bots recoil amp dvar;

2022 12 02
airstrike includes only one plane;
artillery is more scattered.

2022 11 29
fixed missing image files;
fixed ammo buying is buy menu;
added airstrike bombing fx.

2022 11 25
killcam has red tint effect and only killer name.
upgraded bots aiming smoothness.
tweaked screen colors.

2022 11 24
killcam text beneath shows killer name;
hit chopper sometimes will explode in the air.

2022 11 20
added weapon firing cock sound.

2022 11 19
added hint for buying ammo for weapon;
add gamemodes def array for seperate maps;
added distant earthquake for barrages;
replaced m16 burst with m4 auto in buymenu;
fixed kicking bot //ur||ban\;
added some console colors.

2022 11 18
fixed grid smoke issue.

2022 11 12
fixed headshot sound.

2022 11 09
last allie bot survivor is taunting enemies.
added version info in bottom left corner.

2022 11 01
2022.10.31 fixed claymore ammo count,
adjusted mm1 raise and drop anim.
2022.11.01 added new explosion sounds

2022 10 30
updated claymore pickup code.
updated some weapon anim speed.

2022 10 29
anybody should now be able to pick any clays from ground.
fixed aimspot error and self.commanded issue.

2022 10 28
updated bots aiming to be more realistic.
added my own hud transition.
messed up claymore ammo count.

2022 09 09
bots picking explosives (wip).
when out of ammo, knife_mp is given and vise versa.

2022 09 05
claymores are picked with progress bar.
claymores/grenade count on buy and pickup is corrected.
recoil adjustments.
bomb owner gets some money on bombing success.

2022 08 27
claymores can be picked up instantly for now.

2022 08 26
instead for improving messed up MOTD system.
claymores now activates on delay and
detonates on anybody's movement

2022 08 16
fixed endGame issue, but
still fixing spawning issues,
added knife as last resort when no ammo.

2022 08 12
updated recoil system:
when crouch firing acc is better
when prone   almost perfect

2022 07 23
v01d made true map randomizer.

2022 07 13
v01d added map randomization.
v01d removed MoveSpeedScale modification.
v01d added Ammo section in Buy menu (alpha).

2022 07 11
v01d fixed some bugs with hardpoints,
hitching and collision.

2022 07 08
v01d changed button names in main menudef.
v01d adjusted in game info about map and dateTime.
v01d is working on hud section on giving ammo for every weapon.

2022 07 03
v01d fixed some bugs with final killcam.
v01d added map and datetime stamp info.

2022 06 30
v01d added visibility to menu tools.

2022 06 29
v01d made realistic movement accel and decel.
v01d made animated MOTD.
v01d messed up bomb waypoint hud marker system :D

2022 06 26
v01d fixed player controls in prematch timeframe.
v01d fixed player buying weepon with full ammo.
v01d added 12 sec. no player collision in round start.
v01d inspected too many triangles pic, no worries.

2022 06 25
v01d accidentally found unknown cod4x server functions.
v01d made correction with bots filling server.
on hold breath player wouldn't wobble.
with lean buttons spawned player can choose in buy menu.

2022 06 24
nothing new

2022 06 23
v01d was playing with sound curves

2022 06 22
v01d was fixing that issue with spawning and recoil today :D
please report any issues at 'cod4x_v01d_mod' github repo.

2022 06 21
v01d again just fixed a MOTD bug :D:D

2022 06 20
v01d just fixed a MOTD bug :D
v01d accidentally left some
unnecessary code in script file.
big thanks to Dax for alarming this!

2022 06 19
v01d has something done today:
1. dynamic airstrike planes intervals
2. changed scoreboard colors
3. menuresponse fix (team selection)

2022 06 18
nothing is done

2022 06 17
hello and welcome to v01d's first log!
today v01d made some improvements like this message.
v01d has done also cod4x backend things with console.
v01d included smoke_trail02.iwi
Ok, enough talkin', let's war!
