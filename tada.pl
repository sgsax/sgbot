use strict;
use Encode;
use vars qw($VERSION %IRSSI);
use Irssi;

our $VERSION = '0.1';
our %IRSSI = (
    authors     => 'Seth Galitzer',
    contact     => 'sethgali@gmail.com',
    name        => 'tada',
    description => 'return links to silly sound effects',
    license     => 'Public Domain',
);

sub select_sound {
    my $input = shift;
    my $ret = "";

    if ($input =~ m/^!doh/) {
        $ret = "http://kan.st/10M";
    } elsif ($input =~ m/^!rimshot/) {
        $ret = "http://kan.st/10L";
    } elsif ($input =~ m/^!tada/) {
        $ret = "http://kan.st/10K";
    } elsif ($input =~ m/^!trombone/) {
        $ret = "http://kan.st/XV";
    } elsif ($input =~ m/^!khan/) {
        $ret = "http://kan.st/13p http://kan.st/13o";
    }

    return $ret;
}

sub handler {
    my ($server, $msg, $nick, $addr, $target, $priv) = @_;

    use utf8;
    $msg = decode_utf8 $msg;

    $msg = select_sound($msg);
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

