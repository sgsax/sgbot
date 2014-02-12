use strict;
use Encode;
use vars qw($VERSION %IRSSI);
use Irssi;

our $VERSION = '0.1';
our %IRSSI = (
    authors     => 'Seth Galitzer',
    contact     => 'sethgali@gmail.com',
    name        => 'whisky',
    description => 'some days are harder than others',
    license     => 'Public Domain',
);

sub make_mine {
    my @mine = ( "double",
                 "vodka",
                 "tequila",
                 "bourbon",
                 "xanax" );

    return $mine[ rand(@mine) ];

}

sub get_ans {
    my @answers = ( "Looks like you picked the wrong week to stop drinking",
                    "It's 5:00 somewhere",
                    "The sun does appear to be just past the yardarm",
                    "Are you sure?",
                    "You take the bottle out of your desk and take a nice, long pull",
                    "Why the hell not?",
                    "It's that kind of day",
                    "http://kan.st/188",
                    "http://kan.st/189",
                    "Mmmmm... booze...",
                    "Make mine a " . make_mine(),
                    "I'll drink to that!",
                    "I can't reach my drink from under the table",
                    "Be wary of strong drink. It can make you shoot at tax collectors... and miss. -- Robert A. Heinlein",
                    "I aint' drunk, I'm just drinking" );

    return $answers[ rand @answers ]; 
}

sub pick_booze {
    my $booze = shift;
    my $ret = "";

    if ($booze =~ /^!whiskey/) {
        $ret = get_ans();
    } elsif ($booze =~ /^!rum/) {
        $ret = "arrrrrrr!";
    } elsif ($booze =~ /^!tequila/) {
        $ret = "What happens is Tijuana, stays in Tijuana.";
    } elsif ($booze =~ /^!vodka/) {
        $ret = "Drink up, my little friend!";
    }

    return $ret;
}

sub handler {
    my ($server, $msg, $nick, $addr, $target, $priv) = @_;

#    use utf8;
    $msg = decode_utf8($msg);
    $msg = pick_booze($msg);
    if ($msg ne "") {
        $msg = encode_utf8($msg);
        if ($priv) {
            $server->command ("msg $nick $msg");
        } else {
            $server->command ("msg $target $msg");
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
    handler($server, $msg, $nick, $addr, $target, 1);
});

