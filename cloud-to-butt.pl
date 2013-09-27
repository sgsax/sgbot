use strict;
use Encode;
use vars qw($VERSION %IRSSI);
use Irssi;

our $VERSION = '0.2';
our %IRSSI = (
    authors     => 'Seth Galitzer',
    contact     => 'sethgali@gmail.com',
    name        => 'cloud-to-butt',
    description => 'This juvenile script preforms a regex replacement of the word "cloud" with the word "butt"' ,
    license     => 'Public Domain',
);

sub handler {
    my ($server, $msg, $nick, $addr, $target) = @_;

    use utf8;
    $msg = decode_utf8 $msg;

my @butt = (
    "caboose",
    "happy walrus with no tusks",
    "Jar Jar Binks",
    "John Madden",
    "jump-pump",
    "Minneapolis and St. Paul",
    "Moscow",
    "Ollie vs. Frasier",
    "rump-hump",
    "smiley bulldog",
    "that freckle-muffin",
    "closer",
    "crock pot",
    "jiggle twins",
    "Outback",
    "place where all burritos go",
    "turkey stuffin",
    "airbags",
    "air balloons",
    "backside",
    "badonk-a-donk",
    "bottom",
    "bounce house",
    "bubble pop",
    "bum cakes",
    "buns ",
    "buttercup",
    "buttocks",
    "chocolate cluster",
    "dinner with André",
    "double-slug",
    "Elvis Aaron Presley",
    "fanny",
    "flesh pot",
    "Frodo",
    "fun-cooker",
    "George Foreman grill",
    "giant fluffy bears",
    "heiny",
    "hind-quarters",
    "horn section",
    "jumbo-tron",
    "junk-in-the-trunk",
    "keister",
    "launch pad",
    "life's work",
    "magnese",
    "medicine ball",
    "moneymaker",
    "monster truck",
    "mud flaps",
    "mumbler",
    "posterior",
    "rock tumbler",
    "rotunda",
    "rump",
    "rump rockets",
    "second face",
    "sit-biscuit",
    "skin smurf",
    "sonic boom",
    "squash tart",
    "subwoofer",
    "tush",
    "two boneless friends",
    "waffle iron",
    "wiggle bags",
    "wiggle cloud",
);

    my $sayit = $butt[ rand @butt ];

    if ($msg =~ m/the\ cloud/i) {
        $msg =~ s/the\ cloud/my\ $sayit/ig;
        $msg = encode_utf8($msg);
        $server->command ("msg $target $nick meant to say: $msg");
    }
}

Irssi::signal_add_last('message public', sub {
    my ($server, $msg, $nick, $addr, $target) = @_;
    Irssi::signal_continue($server, $msg, $nick, $addr, $target);
    handler($server, $msg, $nick, $addr, $target);
});

Irssi::signal_add_last('message irc action', sub {
    my ($server, $msg, $nick, $addr, $target) = @_;
    Irssi::signal_continue($server, $msg, $nick, $addr, $target);
    handler($server, "* $nick $msg", $nick, $addr, $target);
});

