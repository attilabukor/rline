# r1pp3rj4ck's rline script v1.1.0
#
# @author r1pp3rj4ck <attila.bukor@gmail.com>
#
# DOCUMENTATION
# =============
#
# Introduction
# -------------
# This script has been written for the IRCnet #peta community
# to enjoy random quotes submitted by themselves.
#
# Installation
# -------------
# 1. $ mv rline.pl ~/.irssi/scripts/
# 2. $ cd ~/.irssi/scripts/autorun; ln -s ../rline.pl .
# 3. /script load rline.pl
# 4. ENJOY!
# 
# Settings
# -------------
# /set rline_file path_to_source_file #defaults to randomfile.txt
# /set rline_delay 10 #delay in seconds, defaults to 10
# /set rline_author ON/OFF # decides if the author should be printed
#
# Usage
# -------------
# /rline start #it will start to work on the active channel
# /rline stop #it will stop to work on the active channel
# /rline version #it will tell the others what script it uses
#
# Features
# -------------
# - It works on multiple channels, but the delay cannot be set
#   separately.
# - If you want to change the delay, you have to restart rline
#   on the channel after it is set.
# - If anyone types "!q", it will say a random quote.
# - If anyone types "!addqd text", the quote will be stored in the
#   rline_file in the format "text" - anyone

use strict;
use vars qw($VERSION %IRSSI);

use Irssi;
use IPC::Open3;

$VERSION = '1.0.1';
%IRSSI = (
  authors => 'r1pp3rj4ck <attila.bukor@gmail.com>',
  contact => 'IRC: irc.atw.hu #peta',
  name => 'Rline',
  description => 'Prints random line from a file on regular timeouts and when someone says "!q" on a channel',
  license => 'MIT',
  url => 'http://r1pp3rj4ck.wordpress.com',
  changed => 'Wed May 15 22:07 CEST 2012',
);

my %rline;

sub cmd_rline_version {
  my ($data, $server, $witem) = @_;
  if ($witem && ($witem->{type} eq "CHANNEL")) {
    $witem->command("/me is running: r1pp3rj4ck's rline script v$VERSION");
  }
  else {
    Irssi::print("You are not connected to a channel");
  }
  return 1;
}

sub cmd_rline {
  my ($data, $server, $witem) = @_;
  if ($data =~ m/^[(version|start|stop)]/i) {
    Irssi::command_runsub('rline', $data, $server, $witem);
  }
  else {
    Irssi::print("Use /rline <option> or check /help rline for the complete list");
  }
}

sub cmd_rline_randline {
  my $delay = Irssi::settings_get_int('rline_delay');

  my ($data, $server, $witem) = @_;

  cmd_rline_randline_write($witem);
  $rline{'timer' . $witem->{'name'}} = Irssi::timeout_add($delay * 1000, 'cmd_rline_randline_write', $witem);
}

sub cmd_rline_randline_query {
  my ($server, $msg, $nick, $address, $target) = @_;

  my $witem = Irssi::window_item_find($target);
  $_ = $msg;
  if (/^!q$/i) {
    cmd_rline_randline_write($witem);
  }
}

sub cmd_rline_randline_write {

  my $witem = $_[0];
  my $file = Irssi::settings_get_str('rline_file');
  my $delay = Irssi::settings_get_int('rline_delay');
  my $author = Irssi::settings_get_bool('rline_author');

  if (open FILE, "$file") {
    srand;
    my $line = '';
    rand($.)<1 and ($line=$_) while <FILE>;
    close FILE;
    $line = substr($line, 0, index($line, "\n"));
    $line =~ /^\"(.*)\" - ([^"]*)$/;
    $rline{'who' . $witem->{'name'}} = $2;
    if (!$author) {
      $line = $1;
    }
    $witem->command("/say $line");
  }
  else {
    Irssi::print("File $file does not exist");
  }
}

sub cmd_rline_randline_who {
  my ($server, $msg, $nick, $address, $target) = @_;

  my $witem = Irssi::window_item_find($target);
  $_ = $msg;
  if (/^!who$/i) {
    $witem->command("/say $rline{'who' . $witem->{'name'}}");
  }
}

sub cmd_rline_randline_stop {
  my ($data, $server, $witem) = @_;
  Irssi::timeout_remove($rline{'timer' . $witem->{'name'}});
}

sub cmd_rline_submit {
  my ($server, $msg, $nick, $address, $target) = @_;

  $_ = $msg;

  if (/^!addq\ .*$/i) {
    my $file = Irssi::settings_get_str('rline_file');
    open (FILE, ">>$file");
    print FILE "\"" . substr($msg, 6) . "\" - $nick\n";
    close (FILE);
  }
}

Irssi::settings_add_str('misc', 'rline_file', 'randomfile.txt');
Irssi::settings_add_int('misc', 'rline_delay', 10);
Irssi::settings_add_bool('misc', 'rline_author', 1);

Irssi::command_bind ('rline stop', 'cmd_rline_randline_stop');
Irssi::command_bind ('rline start', 'cmd_rline_randline');
Irssi::command_bind ('rline version', 'cmd_rline_version');
Irssi::command_bind ('rline', 'cmd_rline');

Irssi::signal_add('message public', 'cmd_rline_randline_query');
Irssi::signal_add('message public', 'cmd_rline_submit');
Irssi::signal_add('message public', 'cmd_rline_randline_who');

Irssi::print("r1pp3rj4ck's rline script v$VERSION is loaded successfully");
