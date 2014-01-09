use strict;
use Encode;
use vars qw($VERSION %IRSSI);
use Irssi;

our $VERSION = '0.1';
our %IRSSI = (
    authors     => 'Seth Galitzer',
    contact     => 'sethgali@gmail.com',
    name        => 'roll',
    description => 'A roll of the dice',
    license     => 'Public Domain',
);

sub roll_it {
    my $sides = shift;

    $sides =~ s/\D//g;
    my $roll = int(rand($sides)) + 1;
    return "You rolled a $roll";
}

sub flip_it {
    my $flip = int(rand(2));

    if ($flip eq 0) {
        return "Heads";
    } else {
        return "Tails";
    }
}

sub roll_or_flip {
    my $cmd = shift;
    my $ret = "";
    
    if ($cmd =~ m/^!roll/) {
        my @parts = split(/\s+/, $cmd);
        my $sides = $parts[1];
        if ($sides eq "") { $sides = "d6"; }
        my @valid = ( "d4", "d6", "d8", "d10", "d12", "d20" );
        if (grep {$_ eq $sides} @valid) { 
            $ret = roll_it($sides);
        } else {
            $ret = "n00b";
        }
    } elsif ($cmd =~ m/^!flip/) {
        $ret = flip_it();
    }

    return $ret;
}
sub handler {
    my ($server, $msg, $nick, $addr, $target, $priv) = @_;

#    use utf8;
    $msg = decode_utf8($msg);
    $msg = roll_or_flip($msg);
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

