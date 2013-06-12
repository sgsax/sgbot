use strict;
use Encode;
use vars qw($VERSION %IRSSI);
use Irssi;

our $VERSION = '0.1';
our %IRSSI = (
    authors     => 'Seth Galitzer',
    contact     => 'sethgali@gmail.com',
    name        => 'http-title',
    description => 'captures a URL pasted in a channel and returns the title tag from that page',
    license     => 'Public Domain',
);

sub get_title {
    use LWP::Simple;
    use HTML::HeadParser;

    my $msg = shift;
    my @data = split(/ /, $msg);
    my $ret;
    foreach my $text (@data) {
        if ($text =~ /https?:\/\//) {
            my $raw = get($text);
            my $parser = HTML::HeadParser->new;
            $parser->parse($raw);
            $ret = $parser->header('Title');
            last;
        }
    }
    return $ret;
}

sub handler {
    my ($server, $msg, $nick, $addr, $target, $priv) = @_;

    use utf8;
    $msg = decode_utf8 $msg;
    if ($msg =~ /https?:\/\//) {
        $msg = encode_utf8(get_title($msg));
        if ($priv) {
            $server->command ("msg $nick your url is \"$msg\"");
        } else {
            $server->command ("msg $target $nick\'s url is \"$msg\"");
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

Irssi::signal_add_last('message irc action', sub {
    my ($server, $msg, $nick, $addr, $target) = @_;
    Irssi::signal_continue($server, $msg, $nick, $addr, $target);
    handler($server, "* $nick $msg", $nick, $addr, $target);
});

