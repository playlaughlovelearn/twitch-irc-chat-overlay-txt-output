/*
***********************************************************

Twitch Chat mIRC Script
By: bartoruiz (@gmail.com) ||  twitch.tv/gamerfamily
Original Idea: PhiberOptik & Co.


- CHANGELOG

ver 3.03
- Commands that start with . or / won't display at overlay or txt-output
- Auto clear chatline*.txt at every mirc startup.
- Opens a new server window @connecting
- last.fm current song txt-output every 10 secs: $mircdir/scritps/nowplaying.txt
- Viewers count for Chat Overlay and txt-output; only works for X-Split since it grabs it from its window title: $mircdir/scritps/nowplaying.txt
- Output the 5 lines to a single file: $mircdir/scripts/chatlines1-5.txt
ver 3.02
- Auto /initfiles when activate Write to Disk (deprecated)
ver 3.01
- Initial release

************************************************************
*/


on *:LOAD: {  
  initol
  initfiles
  twsettings
}


/*
>>>>>>>>> A L I A S E S <<<<<<<<
*/

alias F7 {
  if (%olwintitle == $null) {
    initol
  }
  set %oltitlebarcheck %oltitlebar
  set %olinteractivecheck %olinteractive
  if ($window(%olwintitle)) {
    closeol
  }
  else {
    if (%oltitlebar == 0) {
      set %toggleoltb d
    }
    else {
      unset %toggleoltb
    }
    if (%olinteractive == 1) {
      set %toggleolinter e
    }
    else {
      unset %toggleolinter
    }    

    window -Bodaj[10]g[0]w[0]k[0] $+ %toggleolinter +L $+ %toggleoltb %olwintitle %twol.x %twol.y %twol.w %twol.h scripts/olpopup.txt
    setlayer %oltrans %olwintitle
    updateviewerstimer
  }
}

alias updateviewers {
  if ($exists(scripts\viewers.txt) && $window(%olwintitle)) {
    titlebar %olwintitle $read(scripts\viewers.txt,t)  
  }
  else {
    if ($timer(updateviewers)) {
      timerupdateviewers off
    }
  }
}

alias updateviewerstimer {
  if ($timer(updateviewers)) {
    timerupdateviewers off
  }
  if ($isproc(viewers2txt.exe) == $false) {
    run -p $$mircdir $+ scripts\viewers2txt.exe
    timerrunonce_viewers2txt 1 5 timerupdateviewers 0 2 updateviewers
  }
  else {
    timerupdateviewers 0 2 updateviewers
  }
}

alias closeol {
  set %twol.x $window(%olwintitle).x
  set %twol.y $window(%olwintitle).y
  set %twol.w $window(%olwintitle).w
  set %twol.h $window(%olwintitle).h
  window -c %olwintitle
}

alias twol {
  aline -p %olwintitle %twol.line
}

alias initol {
  set %oltitlebar 1
  set %olinteractive 1
  set %olwintitle @Right_Click_For_Settings
  set %oltrans 180
  set %twol.x 100
  set %twol.y 100
  set %twol.w 200
  set %twol.h 300
}

alias initfiles {
  var %twlcount 1
  set %nowplaying scripts/nowplaying.txt
  set %fullchatlines scripts/fullchatlines.txt
  unset %twline*
  while (%twlcount <= %twtotallines) {
    set %singlechatline $+ %twlcount scripts/singlechatline $+ %twlcount $+ .txt
    var %singlechatlineactual singlechatline $+ %twlcount
    write -c % [ $+ [ %singlechatlineactual ] ]
    inc %twlcount
  }
  write -c %fullchatlines
  write -c %nowplaying
}

alias twad {
  if ($1 == on) {
    timertwad 0 %twaddelay /msg %twchan %twad
  }
  if ($1 == off) {
    timertwad off
  }
}

alias xsettings twsettings

alias newline {
  var %twlcount %twtotallines
  var %twlinsert 1
  while (%twlcount > 0) { 
    var %twlcountless = %twlcount - 1
    var %linebefore twline $+ %twlcountless
    var %lineactual twline $+ %twlcount
    set %twline $+ %twlcount % [ $+ [ %linebefore ] ]
    if (%twlcount == 1) {
      set %twline1 %twol.line
    }
    write -c scripts/singlechatline $+ %twlcount $+ .txt % [ $+ [ %lineactual ] ]
    if (%twlcount == %twtotallines) {
      write -c %fullchatlines % [ $+ [ %lineactual ] ]
    }
    else {
      inc %twlinsert
      if (% [ $+ [ %lineactual ] ]) {
        write -l $+ %twlinsert %fullchatlines % [ $+ [ %lineactual ] ]
      }
    }
    dec %twlcount
  }   
}

alias isproc {
  if $isid {
    var %a = isproc.vbs, %i = $shortfn($mircdirisproc.1)

    write -c %a $+(Dim x,$chr(44) fso,$chr(44) fl,$lf,Set ProcessSet = GetObject("winmgmts:{impersonationLevel=impersonate}").ExecQuery("select * from Win32_Process WHERE NAME=' $+ $1- $+ '"))
    write %a $+(For each Process in ProcessSet,$lf,If lcase(Process.Name)=" $+ $1- $+ " Then,$lf,Set fso = CreateObject("Scripting.FileSystemObject"),$lf,Set f1 = fso.CreateTextFile(" $+ %i $+ ", True),$lf,Exit For,$lf,End If,$lf,Next)
    ;; write vbs script that looks through running processes for $1-, then writes the footprint file on match

    .comopen %a WScript.Shell
    .comclose %a $com(%a,Run,3,bstr,$+(",$mircdir,%a,"),uint,0,bool,true)
    ;; run vbs file

    .remove %a
    ;; remove vbs file

    if $exists(%i) {
      .remove $shortfn($mircdirisproc.1)
      ;; mirc doesnt correctly return %i in this instance - remove footprint

      return $true
    }
    else { return $false }
  }
}

alias nowplaying {
  if ($sock(lastfm)) {  
    .sockclose lastfm
  }
  if (%last.fm.username) {
    sockopen lastfm www.last.fm 80
    ;set -u10 %last.fm.active $active
  }
  else {
    echo $active Error, no last.fm username found.  Please set your username use /lastfm username
  }
}

alias lastfm { set %last.fm.username $1 }

on *:SOCKOPEN:lastfm: {
  sockwrite -nt $sockname GET /user/ $+ %last.fm.username HTTP/1.1
  sockwrite -nt $sockname Host: www.last.fm
  sockwrite -nt $sockname $crlf
}
on *:SOCKREAD:lastfm: {
  var %last.fm
  sockread %last.fm
  if (imageMedium isin %last.fm) {
    sockread %last.fm | sockread %last.fm | sockread %last.fm
    set %currentsong $regsubex(%last.fm,/(?:<(?:.*?)>)([^<]+)(?:<(?:.*?)>)(?:[^<]+)(?:<(?:.*?)>)([^<]+).+/,\2 - \1) ►♫
    ;echo -a %currentsong
    sockclose lastfm
    if (!$exists(%nowplaying)) {
      initfiles
    }
    write -l1 %nowplaying %currentsong
  }
}



/*
>>>>>>>>> T R I G G E R S <<<<<<<<
*/

ON *:START: { 
  initfiles 
}

on *:TEXT:*:%twchan: {
  if (%twchats == 1) {
    if ($nick == $me) {
      set %twol.line << $+ $nick $+ >> $1-
    } 
    else {
      set %twol.line < $+ $nick $+ > $1-
    }
    if (%writedisk == 1) {
      newline
    }
    if ($window(%olwintitle)) {
      twol
    }
  }
}


on *:INPUT:%twchan: {
  if (%twownmsg == 1) {
    if ($left($1-,1) != / && $left($1-,1) != .) {
      set %twol.line << $+ $nick $+ >> $1-
      if (%writedisk == 1) {
        newline
      }
      if ($window(%olwintitle)) {
        twol
      }
    }
  }
}

on *:INPUT:%olwintitle: {
  msg %twchan $1-
  if (%twownmsg == 1) {
    set %twol.line << $+ $nick $+ >> $1-
    if (%writedisk == 1) {
      newline
    }
    if ($window(%olwintitle)) {
      twol
    }
  }
}

on *:JOIN:%twchan: {
  if (%twjoins == 1) {
    set %twol.line + $nick has joined.
    if (%writedisk == 1) {
      newline
    }
    if ($window(%olwintitle)) {
      twol
    }
  }
}

on *:PART:%twchan: {
  if (%twparts == 1) {
    set %twol.line - $nick has parted.
    if (%writedisk == 1) {
      newline
    }
    if ($window(%olwintitle)) {
      twol
    }
  }
}

on *:ACTION:*:%twchan: {
  if (%twact == 1) {
    set %twol.line * $nick $1-
    if (%writedisk == 1) {
      newline
    }
    if ($window(%olwintitle)) {
      twol
    }
  }
}

on *:CONNECT {
  if ($server == tmi.twitch.tv) {
    join %twchan
  }
}


/*
>>>>>>>>> D I A L O G S <<<<<<<<
*/

dialog olsettings {
  title "Overlay Settings"
  size -1 -1 280 153
  option pixels
  scroll "Transparency", 1, 11 28 254 16, range 0 255 horizontal bottom
  check "Titlebar/Move/Size", 2, 9 105 120 20
  edit "", 4, 7 82 266 20
  button "Apply", 5, 194 119 74 24, ok
  check "Interactive chat", 3, 9 125 100 20
  box "Transparency", 7, 6 12 267 41
  text "Titlebar Text (no spaces)", 8, 7 65 179 16
}

on *:dialog:olsettings:scroll:1:{
  set %oltrans $did(olsettings,1).sel
  setlayer $did(olsettings,1).sel %olwintitle
}  

on *:dialog:olsettings:sclick:5:{
  if (%olwintitlenew != $null) && (%olwintitle != %olwintitlenew) {  
    renwin %olwintitle %olwintitlenew
    set %olwintitle %olwintitlenew
    updateviewerstimer
    unset %olwintitlenew
  }
  if (%oltitlebar != %oltitlebarcheck) || (%olinteractive != %olinteractivecheck) {
    closeol
    F7
  }
}

on *:dialog:olsettings:sclick:2:{
  if ($did(olsettings,2).state == 1) { set %oltitlebar 1 }
  else { set %oltitlebar 0 }
}

on *:dialog:olsettings:sclick:3:{
  if ($did(olsettings,3).state == 1) { set %olinteractive 1 }
  else { set %olinteractive 0 }
}

on *:dialog:olsettings:edit:4: {
  set %olwintitlenew @ $+ $replace($did(olsettings,4).text,$chr(32),_)  
}

on *:dialog:olsettings:init:0: {
  %olwintitlesize = $len(%olwintitle) - 1
  did -c olsettings 1 %oltrans
  did -ra olsettings 4 $right(%olwintitle,%olwintitlesize)
  if (%oltitlebar == 1) { did -c olsettings 2 }
  if (%oltitlebar == 0) { did -u olsettings 2 }
  if (%olinteractive == 1) { did -c olsettings 3 }
  if (%olinteractive == 0) { did -u olsettings 3 }
}

alias olsettings { 
  if (!$dialog(olsettings)) {
    dialog -mdro olsettings olsettings 
  }
}

dialog twsettings {
  title "Twitch IRC Chat Settings"
  size -1 -1 319 497
  option pixels
  edit "username", 1, 21 50 113 20, autohs
  edit "password", 24, 161 50 121 20, pass autohs
  edit "Your ad here", 3, 20 110 277 20, autohs
  text "Advert message every:", 4, 22 141 115 17
  check "", 6, 48 230 14 17
  check "", 7, 48 255 19 17
  check "", 8, 48 280 19 17
  check "", 9, 48 305 18 17
  check "", 12, 48 330 21 17
  link "Donate", 15, 18 465 40 17
  button "Apply", 20, 224 459 79 25, ok
  edit "120", 22, 141 138 32 20
  text "secs", 23, 176 141 37 17
  text "twitch username", 19, 21 32 104 16
  text "twitch password", 2, 161 32 109 16
  button "Chat Overlay (F7)", 10, 103 459 108 25
  check "enable", 11, 227 140 60 20
  box "Auto Advertising", 16, 12 96 295 76
  box "twitch.tv", 17, 12 8 295 72
  box "Overlay and Txt-Output Options", 5, 12 187 295 261
  text "-- Chats", 13, 168 232 50 16
  box "Txt-Output", 14, 87 212 67 196
  check "", 18, 114 230 22 20
  box "Overlay", 21, 28 212 52 196
  check "", 25, 114 280 21 20
  text "-- User Joins", 26, 168 282 79 16
  text "-- User Leaves", 27, 168 307 76 16
  check "", 28, 114 305 16 20
  text "-- Own Chat", 29, 168 257 59 16
  check "", 30, 114 255 20 20
  text "-- User Actions /me", 31, 168 332 105 16
  check "", 32, 114 330 21 20
  check "", 33, 48 355 20 20
  text "-- Current Viewers, X-Split", 34, 168 357 128 18
  check "", 35, 114 380 19 20
  text "-- last.fm current song", 36, 169 382 117 16
  button "Flush TXTs", 37, 167 413 72 23
  check "", 38, 114 355 19 20
  edit "", 39, 127 415 26 21
  text "# lines:", 40, 86 420 39 16
}

on *:DIALOG:twsettings:sclick:6:{
  if ($did(twsettings,6).state == 1) { set %twchats 1 }
  else { set %twchats 0 }
}

on *:DIALOG:twsettings:sclick:7:{
  if ($did(twsettings,7).state == 1) { set %twownmsg 1 }
  else { set %twownmsg 0 }
}

on *:DIALOG:twsettings:sclick:8:{
  if ($did(twsettings,8).state == 1) { set %twjoins 1 }
  else { set %twjoins 0 }
}

on *:DIALOG:twsettings:sclick:9:{
  if ($did(twsettings,9).state == 1) { set %twparts 1 }
  else { set %twparts 0 }
}

on *:DIALOG:twsettings:sclick:33:{
  if ($did(twsettings,33).state == 1) { 
    set %twviewersol 1
    set %twviewerstxt 1
    did -c twsettings 38
  }
  else { 
    set %twviewersol 0
  }
}

on *:DIALOG:twsettings:sclick:38:{
  if ($did(twsettings,38).state == 1) { set %twviewerstxt 1 }
  else { set %twviewerstxt 0 }
}

On *:DIALOG:twsettings:sclick:11:{
  if ($did(twsettings,11).state == 1) {
    set %twadenable 1
    twad on
  }
  else {
    set %twadenable 0
    twad off
  }
}

on *:DIALOG:twsettings:sclick:12:{
  if ($did(twsettings,12).state == 1) { set %twact 1 }
  else { set %twact 0 }
}

on *:DIALOG:twsettings:sclick:13:{
  if ($did(twsettings,13).state == 1) {
    set %writedisk 1
    initfiles
  }
  else {
    set %writedisk 0
  }
}

on *:dialog:twsettings:edit:1: { 
  set %twuser $did(twsettings,1).text 
  set %twchan $chr(35) $+ %twuser
}

on *:dialog:twsettings:edit:3: { 
  set %twad $did(twsettings,3).text 
}

on *:dialog:twsettings:edit:22: { 
  if ($did(twsettings,22).text !isnum) {
    echo -a Error: Only numbers (seconds) can be entered here.
  }
  else {
    set %twaddelay $did(twsettings,22).text 
  }
}

on *:dialog:twsettings:edit:24: { 
  set %twpass $did(twsettings,24).text 
}

on *:dialog:twsettings:sclick:20: {
  if ($status != connected) || ($server != tmi.twitch.tv) {
    server -m %twuser $+ .jtvirc.com:6667  %twpass -i %twuser -j %twchan
  }
}

on *:DIALOG:twsettings:sclick:10:{
  F7
}

on *:DIALOG:twsettings:sclick:15:{
  run https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=XVHHN7X576DH6
}

on *:dialog:twsettings:init:0: {
  if (%twuser == $null) {
    set %twuser username 
  }
  if (%twad == $null) {
    set %twad Your ad here!
  }
  if (%twaddelay == $null) {
    set %twaddelay 120
  }
  did -ra twsettings 1 %twuser
  did -ra twsettings 3 %twad
  did -ra twsettings 22 %twaddelay
  if (%twchats == 1) { did -c twsettings 6 }
  if (%twchats == 0) { did -u twsettings 6 }
  if (%twownmsg == 1) { did -c twsettings 7 }
  if (%twownmsg == 0) { did -u twsettings 7 }
  if (%twjoins == 1) { did -c twsettings 8 }
  if (%twjoins == 0) { did -u twsettings 8 }
  if (%twparts == 1) { did -c twsettings 9 }
  if (%twparts == 0) { did -u twsettings 9 }
  if (%twadenable == 1) { did -c twsettings 11 }
  if (%twadenable == 0) { did -u twsettings 11 }
  if (%twact == 1) { did -c twsettings 12 }
  if (%twact == 0) { did -u twsettings 12 }
  if (%writedisk == 1) { did -c twsettings 13 }
  if (%writedisk == 0) { did -u twsettings 13 }
  if (%twviewerstxt == 1) { did -c twsettings 38 }
  if (%twviewerstxt == 0) { did -u twsettings 38 }
  if (%twviewersol == 1) { 
    did -c twsettings 33
    did -c twsettings 38
    set %twviewerstxt 1
  }
  if (%twviewersol == 0) { did -u twsettings 33 }
}

alias twsettings { 
  if (!$dialog(twsettings)) {
    dialog -mdro twsettings twsettings 
  }
}

Menu Channel,Status,Menubar,Query {
  Twitch IRC Chat Settings:twsettings
}
