use strict;
use Encode;
use vars qw($VERSION %IRSSI);
use Irssi;

use Date::Simple ('today');

our $VERSION = '0.1';
our %IRSSI = (
    authors     => 'Seth Galitzer',
    contact     => 'sethgali@gmail.com',
    name        => 'friday',
    description => 'Is it Friday yet?',
    license     => 'Public Domain',
);

sub is_it_friday {
    my $today = today();
    my $ret = "Nope";
    if ($today->day_of_week == 5) {
        $ret = "Yep";
    }
    return $ret;
}

sub handler {
    my ($server, $msg, $nick, $addr, $target, $priv) = @_;

#    use utf8;
    $msg = decode_utf8($msg);
    if ($msg =~ m/^!friday/) {
        $msg = encode_utf8(is_it_friday());
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

