use strict;
use Encode;
use vars qw($VERSION %IRSSI);
use Irssi;

our $VERSION = '0.1';
our %IRSSI = (
    authors     => 'Seth Galitzer',
    contact     => 'sethgali@gmail.com',
    name        => 'help',
    description => 'canonical help for all bot commands',
    license     => 'Public Domain',
);
sub list_help {

    my @commands = ( "Available commands for sgbot follow (prefix with !):",
                     "8ball: The Magic 8 Ball",
                     "bofh: Display witty fortunes for sysadmins",
                     "calc <formula>: Simple, in-line calculator, evaluates <formula> and returns the answer",
                     "cool: silly response to this statement",
                     "doh: play Homer sound",
                     "donut <name>: tell <name> to go and take a flying fuck at a rolling donut (FOAAS)",
                     "everything: fuck everything (FOAAS)",
                     "everyone: everyone can go and fuck off (FOAAS)",
                     "flip: flip a coin",
                     "google: google that shit",
                     "gtfo: time to go",
                     "help: Display this help",
                     "holy: holy fuck (FOAAS)",
                     "idm: When is it IDM time?",
                     "kahn: play Khan sound",
                     "linus: witty fuck off that only Linus Torvalds could say (FOAAS)",
                     "no: fuck no (FOAAS)",
                     "off <name>: tell <name> to fuck off (FOAAS)",
                     "rfo [<name>]: random FOAAS selection (FOAAS)",
                     "rimshot: print url for rimshot sound",
                     "roll: roll the dice, choose d4, d6 (default), d8, d10, d12, or d20",
                     "roy: every tech support call ever",
                     "rum: say something piratey",
                     "spell <word>: Simple spellchecker, looks up <word> and suggests replacements if needed",
                     "tada: print url for tada sound",
                     "tequila: drinks are on me",
                     "this: fuck this (FOAAS)",
                     "that: fuck that (FOAAS)",
                     "train <name>: all aboard the fail train",
                     "trombone: print url for sad trombone sound",
                     "up <name>: <name> really fucked up (FOAAS)",
                     "USA: wouldn't it be great?",
                     "vodka: just like from the old country",
                     "weather [<location>]: Display weather report for <location> or MHK if not indicated",
                     "whiskey: for those really difficult days",
                     "woot [img] [buy]: Display today's Woot.com special, optionally include image and/or \"buy now\" URL",
                     "yeah <name>: fuck yeah! (FOAAS)",
                     "you <name>: tell <name>, fuck you (FOAAS)",
                     );

    return @commands;
}

sub handler {
    my ($server, $msg, $nick, $addr, $target, $priv) = @_;

    use utf8;

    $msg = decode_utf8 $msg;
    if ($msg =~ m/^!help$/) {
        foreach my $command (list_help()) {
            $server->command (encode_utf8("msg $nick $command"));
        }
    }
}

Irssi::signal_add_last('message public', sub {
    my ($server, $msg, $nick, $addr, $target) = @_;
    Irssi::signal_continue($server, $msg, $nick, $addr, $target);
    handler($server, $msg, $nick, $addr, $target);
});

Irssi::signal_add_last('message private', sub {
    my ($server, $msg, $nick, $addr, $target) = @_;
    Irssi::signal_continue($server, $msg, $nick, $addr, $target);
    handler($server, $msg, $nick, $addr, $target);
});

