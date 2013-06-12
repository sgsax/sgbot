use strict;
use Encode;
use vars qw($VERSION %IRSSI);
use Irssi;

our $VERSION = '0.1';
our %IRSSI = (
    authors     => 'Seth Galitzer',
    contact     => 'sethgali@gmail.com',
    name        => 'calc',
    description => 'simple, in-line calculator',
    license     => 'Public Domain',
);

sub calc {
    my $fig = shift;
    return eval($fig);
}

sub handler {
    my ($server, $msg, $nick, $addr, $target, $priv) = @_;

    use utf8;
    $msg = decode_utf8 $msg;
    if ($msg =~ m/^!calc/) {
        my @data = split(/ /, $msg);
        $msg = calc($data[1]);
        if (!(defined $msg)) { 
            $msg = "error running command";
        } else {
            $msg = encode_utf8($msg);
        }
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

