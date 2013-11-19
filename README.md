rline
=====

Random line bot for irssi, originally developed for IRCNet #peta

Introduction
-------------

This script has been written for the IRCnet #peta community
to enjoy random quotes submitted by themselves.

Installation
-------------

1. $ mv rline.pl ~/.irssi/scripts/
2. $ cd ~/.irssi/scripts/autorun; ln -s ../rline.pl .
3. /script load rline.pl
4. ENJOY!

Settings
-------------

/set rline_file path_to_source_file #defaults to randomfile.txt
/set rline_delay 10 #delay in seconds, defaults to 10

Usage
-------------

/rline start #it will start to work on the active channel
/rline stop #it will stop to work on the active channel
/rline version #it will tell the others what script it uses

Features
-------------

- It works on multiple channels, but the delay cannot be set
  separately.
- If you want to change the delay, you have to restart rline
  on the channel after it is set.
- If anyone types "!q", it will say a random quote.
- If anyone types "!addqd text", the quote will be stored in the
  rline_file in the format "text" - anyone
