/*
***********************************************************

Twitch Chat mIRC Script
By: bartoruiz (@gmail.com) ||  twitch.tv/gamerfamily
Original Idea: PhiberOptik & Co.

v 3.04

***********************************************************
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

    window -Bodaj[10]g[0]w[0]k[0] $+ %toggleolinter +L $+ %toggleoltb %olwintitle %twol.x %twol.y %twol.w %twol.h
    setlayer %oltrans %olwintitle
    if (%twviewersol == 1) {
      updateviewerstimer
    }
    if (%twviewerstxt == 1) {
      if ($isproc(viewers2txt.exe) == $false) {
        run -p $mircdir $+ scripts\viewers2txt.exe
      }     
    }
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
    run -p $mircdir $+ scripts\viewers2txt.exe
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
  aline -p %twolcolor %olwintitle %twol.line
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

alias twlastfm {
  if ($1 == on) {
    timerlastfm 0 8 /nowplaying
  }
  if ($1 == off) {
    timerlastfm off
  }
}

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

alias killprocess {
  var %e = echo -ac info * /killprocess:
  if ($version < 6.16) { %e snippet requires mIRC 6.16 or higher | return }
  if ($1 !isnum 0-) || ($0 < 2) { %e <N> <process> with N zero or higher | return }
  var %a = a $+ $ticks, %b = b $+ %a, %c
  .comopen %a WbemScripting.SWbemLocator 
  if ($comerr) { %e error connecting to WMI | return }
  .comclose %a $com(%a,ConnectServer,1,dispatch* %b) 
  if ($com(%b)) .comclose %b $com(%b,ExecQuery,1,bstr*,SELECT $&
    Name FROM Win32_Process WHERE Name = $+(",$2-,"),dispatch* %a) 
  if (!$com(%a)) { %e error retrieving collection | return }
  %c = $comval(%a,0)
  if (!%c) { %e no such process $2 | return }
  if (!$1) {
    while (%c) {
      !.echo -q $comval(%a,%c,Terminate) 
      dec %c 
    } 
  }
  else !.echo -q $comval(%a,$1,Terminate) 
  :error
  if ($com(%a)) .comclose %a
  if ($com(%b)) .comclose %b
}

alias lfmuser { 
  set %last.fm.username $1 
  echo -a last.fm username was set to: %last.fm.username
}

alias -l lastfm { 
  return $replace($1,&gt;,>,&lt;,<,&amp;,&) 
}

alias nowplaying { 
  if (%last.fm.username == $null) {
    echo -a Error, no last.fm username found.  Please set your username use: /lfmuser username
    halt
  }
  var %lastfm $+(lastfm,$r(1,9999),$ticks,$network,$cid) 
  $+(sock,$iif($sock(%lastfm),close,open)) %lastfm ws.audioscrobbler.com 80
  sockmark %lastfm $+(%last.fm.username,`,$iif($isid,.describe $iif(#,#,$nick),echo -at *),`,6fa70647e42ed7b765e823047273352d,`,$!bvar(&lastfm,1-).text,`,sockwrite -nt %lastfm)
}

alias twcheckver {
  sockclose twver | sockopen twver code.google.com 80
}

/*
>>>>>>>>> T R I G G E R S <<<<<<<<
*/

on *:SOCKOPEN:twver: {
  sockwrite -n twver GET /p/twitch-irc-chat-overlay-txt-output/downloads/list HTTP/1.1
  sockwrite -n twver Host: code.google.com
  sockwrite -n twver Connection: Keep-Alive
  sockwrite -n twver $crlf
}
on *:SOCKREAD:twver: {
  var %t Twitch IRC Chat v
  sockread %tmp
  if (%t isin %tmp) {
    if (%twver < $right($gettok(%tmp,4,32),-1)) {
      echo -a ************************* 
      echo -a New Twitch IRC Chat Script $gettok(%tmp,4,32) released. Please visit https://code.google.com/p/twitch-irc-chat-overlay-txt-output/ for details and upgrade instructions
      echo -a *************************
      sockclose twver  
    }
    sockclose twver
  }
}

on *:sockread:lastfm*:{ 
  tokenize 96 $sock($sockname).mark 
  var %lf = $sockname
  if ($sockerr) { 
    echo -s Can not connect to last.fm 
    halt 
  } 
  sockread &lastfm 
  if ($regex([ [ $4 ] ],/<error code="6">(.*)</error></lfm>)) { 
    $2 $+($regml(1),!) 
    halt 
  }
  elseif (nowplaying !isin [ [ $4 ] ]) { 
    write -c %nowplaying no playing music right now ∎
    sockclose %lf 
  }
  else { 
    set %currentsong $& $lastfm($gettok($gettok([ [ $4 ] ],6,62),1,60))) - $+($& $lastfm($gettok($gettok([ [ $4 ] ],8,62),1,60))) ►♫
    sockclose %lf
    write -c %nowplaying %currentsong 
  }
}

on *:sockopen:lastfm*:{ 
  tokenize 96 $sock($sockname).mark
  if ($sockerr) { 
    echo -s Can not connect to last.fm 
    halt 
  }
  $5 GET $+(/2.0/?method=user.getrecenttracks&limit=1&user=,$1,&api_key=,$3) HTTP/1.1
  $5 Host: $sock($sockname).addr 
  $5 Connection: close 
  $5
}

on *:START: { 
  initfiles
  set %twver 3.04
  twcheckver
}

on *:TEXT:*:%twchan: {
  if ($nick == $me) {
    set %twol.line << $+ $nick $+ >> $1-
  }
  else {
    set %twol.line < $+ $nick $+ > $1-
  }
  if (%twchats == 1 && $window(%olwintitle)) {
    twol
  }
  if (%twchatstxt == 1) {
    newline
  }
}


on *:INPUT:%twchan: {
  if ($left($1-,1) != / && $left($1-,1) != .) {
    set %twol.line << $+ $nick $+ >> $1-
  }
  if (%twownmsg == 1 && $window(%olwintitle)) {
    twol
  }
  if (%twownmsgtxt == 1) {
    newline
  }
}

on *:INPUT:%olwintitle: {
  if ($left($1-,1) != / && $left($1-,1) != .) {  
    msg %twchan $1-
    set %twol.line << $+ $nick $+ >> $1-
  }
  if (%twownmsg == 1 && $window(%olwintitle)) {
    twol
  }
  if (%twownmsgtxt == 1) {
    newline
  }
}

on *:JOIN:%twchan: {
  set %twol.line + $nick has joined
  if (%twjoins == 1 && $window(%olwintitle)) {
    twol
  }
  if (%twjoinstxt == 1) {
    newline
  }
}

on *:PART:%twchan: {
  set %twol.line - $nick has parted
  if (%twparts == 1 && $window(%olwintitle)) {
    twol
  }
  if (%twpartstxt == 1) {
    newline
  }    
}

on *:ACTION:*:%twchan: {
  set %twol.line * $nick $1-
  if (%twact == 1 && $window(%olwintitle)) {
    twol
  }
  if (%twacttxt == 1) {
    newline
  }
}

on *:CONNECT {
  if ($server == tmi.twitch.tv) {
    join %twchan
    if (%twlastfmtxt == 1) {
      timerlastfm 0 8 nowplaying
    }
    if (%twviewerstxt == 1) {
      if ($isproc(viewers2txt.exe) == $false) {
        run -p $mircdir $+ scripts\viewers2txt.exe
      }     
    }
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
  size -1 -1 319 538
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
  link "Donate", 15, 21 511 40 16
  button "Apply", 20, 227 505 79 24, ok
  edit "120", 22, 141 138 32 20
  text "secs", 23, 176 141 37 17
  text "twitch username", 19, 21 32 104 16
  text "twitch password", 2, 161 32 109 16
  button "Chat Overlay (F7)", 10, 106 505 108 24
  check "enable", 11, 227 140 60 20
  box "Auto Advertising", 16, 12 96 295 76
  box "twitch.tv", 17, 12 8 295 72
  box "Overlay and Txt-Output Options", 5, 12 190 295 303
  text "-- Chats", 13, 172 232 50 16
  box "Txt-Output", 14, 97 212 71 271
  check "", 18, 124 230 22 20
  box "Overlay", 21, 27 212 67 271
  check "", 25, 124 280 21 20
  text "-- User Joins", 26, 172 282 79 16
  text "-- User Leaves", 27, 172 307 76 16
  check "", 28, 124 305 16 20
  text "-- Own Chat", 29, 172 257 59 16
  check "", 30, 124 255 20 20
  text "-- User Actions /me", 31, 172 332 105 16
  check "", 32, 124 330 21 20
  check "", 33, 48 355 20 20
  text "-- Current Viewers, X-Split", 34, 172 357 128 18
  check "", 35, 124 380 19 20
  text "-- last.fm current song", 36, 173 382 117 18
  button "Flush TXTs", 37, 100 455 64 23
  check "", 38, 124 355 19 20
  edit "", 39, 120 428 25 20
  text "# lines:", 40, 114 410 39 16
  text "# color:", 41, 41 410 43 16
  edit "", 42, 47 428 25 20
  text "-- # color for the overlay accept values from 0->15; # lines for the files accept values from 1->99", 43, 172 410 128 52, center
}

on *:DIALOG:twsettings:sclick:18:{
  if ($did(twsettings,18).state == 1) { set %twchatstxt 1 }
  else { set %twchatstxt 0 }
}

on *:DIALOG:twsettings:sclick:6:{
  if ($did(twsettings,6).state == 1) { set %twchats 1 }
  else { set %twchats 0 }
}

on *:DIALOG:twsettings:sclick:7:{
  if ($did(twsettings,7).state == 1) { set %twownmsg 1 }
  else { set %twownmsg 0 }
}

on *:DIALOG:twsettings:sclick:30:{
  if ($did(twsettings,30).state == 1) { set %twownmsgtxt 1 }
  else { set %twownmsgtxt 0 }
}

on *:DIALOG:twsettings:sclick:8:{
  if ($did(twsettings,8).state == 1) { set %twjoins 1 }
  else { set %twjoins 0 }
}

on *:DIALOG:twsettings:sclick:25:{
  if ($did(twsettings,25).state == 1) { set %twjoinstxt 1 }
  else { set %twjoinstxt 0 }
}

on *:DIALOG:twsettings:sclick:9:{
  if ($did(twsettings,9).state == 1) { set %twparts 1 }
  else { set %twparts 0 }
}

on *:DIALOG:twsettings:sclick:28:{
  if ($did(twsettings,28).state == 1) { set %twpartstxt 1 }
  else { set %twpartstxt 0 }
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
  if ($did(twsettings,38).state == 1) { 
    set %twviewerstxt 1
    if ($isproc(viewers2txt.exe) == $false) {
      run -p $mircdir $+ scripts\viewers2txt.exe
    } 
  }
  else {
    set %twviewerstxt 0
    killprocess 1 viewers2txt.exe
  }
}

On *:DIALOG:twsettings:sclick:35:{
  if ($did(twsettings,35).state == 1) {
    set %twlastfmtxt 1
    twlastfm on
  }
  else {
    set %twlastfmtxt 0
    twlastfm off
  }
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

on *:DIALOG:twsettings:sclick:32:{
  if ($did(twsettings,32).state == 1) { set %twacttxt 1 }
  else { set %twacttxt 0 }
}

on *:DIALOG:twsettings:sclick:37:{
  initfiles
}

on *:dialog:twsettings:edit:1: { 
  set %twuser $did(twsettings,1).text 
  set %twchan $chr(35) $+ %twuser
}

on *:dialog:twsettings:edit:39: { 
  if ($did(twsettings,39).text !isnum) {
    echo -a Error: Only numbers (lines) can be entered here.
  }
  else {
    set %twtotallines $did(twsettings,39).text 
  }
}

on *:dialog:twsettings:edit:42: { 
  if ($did(twsettings,42).text !isnum) {
    echo -a Error: Only numbers (color) can be entered here.
  }
  else {
    set %twolcolor $did(twsettings,42).text 
  }
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
    set %twchats 1
    set %twownmsg 1
    set %twjoins 1
    set %twparts 1
    set %twact 1
    set %twchatstxt 1
    set %twownmsgtxt 1
    set %twjoinstxt 1
    set %twpartstxt 0
    set %twacttxt 1
  }
  if (%twad == $null) {
    set %twad Your ad here!
  }
  if (%twaddelay == $null) {
    set %twaddelay 120
  }
  if (%twtotallines == $null) {
    set %twtotallines 5
  }
  if (%twolcolor == $null) {
    set %twolcolor 1
  }

  did -ra twsettings 1 %twuser
  did -ra twsettings 3 %twad
  did -ra twsettings 22 %twaddelay
  did -ra twsettings 39 %twtotallines
  did -ra twsettings 42 %twolcolor
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
  if (%twviewerstxt == 1) { did -c twsettings 38 }
  if (%twviewerstxt == 0) { did -u twsettings 38 }
  if (%twviewersol == 1) { 
    did -c twsettings 33
    did -c twsettings 38
    set %twviewerstxt 1
  }
  if (%twviewersol == 0) { did -u twsettings 33 }
  if (%twchatstxt == 1) { did -c twsettings 18 }
  if (%twchatstxt == 0) { did -u twsettings 18 }  
  if (%twownmsgtxt == 1) { did -c twsettings 30 }
  if (%twownmsgtxt == 0) { did -u twsettings 30 }
  if (%twjoinstxt == 1) { did -c twsettings 25 }
  if (%twjoinstxt == 0) { did -u twsettings 25 }
  if (%twpartstxt == 1) { did -c twsettings 28 }
  if (%twpartstxt == 0) { did -u twsettings 28 }
  if (%twacttxt == 1) { did -c twsettings 32 }
  if (%twacttxt == 0) { did -u twsettings 32 }
  if (%twlastfmtxt == 1) { did -c twsettings 35 }
  if (%twlastfmtxt == 0) { did -u twsettings 35 }    
}

alias twsettings { 
  if (!$dialog(twsettings)) {
    dialog -mdro twsettings twsettings 
  }
}

Menu * {
  Twitch IRC Chat Settings: twsettings
  Overlay Settings: olsettings
}
