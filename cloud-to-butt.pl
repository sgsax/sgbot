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

    if ($msg =~ m/the\ cloud/i) {
        $msg =~ s/the\ cloud/my\ butt/ig;
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

