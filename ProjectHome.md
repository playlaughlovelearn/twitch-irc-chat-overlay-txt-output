![http://i.imgur.com/vfv6gvV.png](http://i.imgur.com/vfv6gvV.png)

<<< NEWEST VERSION 3.06

### Overview ###
> My electric bill is already high enough and using a 2nd monitor just to screen capture twitch chat and interact with viewers didn't justify itself. So I forced myself to use only 1 monitor and develop some tools that hopefully other streamers will find interesting.

> I'm the -do it once and do it right- kind of guy, so it took me quite of time but in the end I guess the script surpass my initial expectations and I guess is easy to setup. If you like my work:
  * Optionally, you are welcome to invite me a beer... real beer!, paypal me $1 and I'll do the rest.
  * Forcefully, follow my twitch channel http://twitch.tv/gamerfamily
  * Both :D

### Main Features ###
  1. Chat log @ $mircdir/scripts/fullchatlines.txt ; saves N # of chat lines, mainly used for OBS Text source
  1. Chat logs @ $mircdir/scripts/chatline?.txt ;  saves single chat line, mainly used for XSplit Titles source
  1. Chat Overlay (F7) ; Always on TOP resizable trasparent window; used to easily interact with viewers or just see the chat while gaming.
  1. last.fm current song @ $mircdir/scripts/nowplaying.txt
  1. Current Viewers Count @ $mircdir/scripts/viewers.txt
> Many more, see the CHANGELOG.TXT for details.

### Install Instructions ###
  1. Download and install mIRC ( http://www.mirc.com/ )
  1. Open mIRC and type: //run $mircdir/scripts
  1. Download the script and unzip the files (twitchat.mrc) inside that folder.
  1. At mIRC type: /load -rs scripts/twitchat.mrc
  1. Click YES at the 'run initialization commands' warning popup and configure to your needs.

### Upgrade Instructions (if needed) ###
  1. Open mIRC and type: /unload -rs twitchat.mrc
  1. Just follow the install Instructions above and overwrite any previous file.

### Support ###
> Feel free to send me any issues, feedback or requests to bartoruiz at gmail