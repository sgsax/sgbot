use strict;
use Encode qw(encode_utf8);
use HTML::Entities qw(decode_entities);
use vars qw($VERSION %IRSSI);
use Irssi;

our $VERSION = '0.2';
our %IRSSI = (
    authors     => 'Seth Galitzer',
    contact     => 'sethgali@gmail.com',
    name        => 'http-title',
    description => 'captures a URL pasted in a channel and returns the title tag from that page',
    license     => 'Public Domain',
);

sub get_content {
    my $url = shift;

    my $uastring = 'Mozilla/5.0';
    my $retstr = "";

    use LWP::UserAgent;

    my $ua = LWP::UserAgent->new;
    $ua->agent($uastring);
    my $res = $ua->get($url);
    if ($res->is_success) {
       $retstr = $res->content;
    }

    return $retstr;
}

sub get_title {
    use HTML::HeadParser;

    my $msg = shift;
    my @data = split(/ /, $msg);
    my $ret;
    foreach my $text (@data) {
        if ($text =~ /https?:\/\//) {
            my $parser = HTML::HeadParser->new;
            my $content = get_content($text);

            if (($text =~ /youtube\.com/) || ($text =~ /youtu\.be/)){
                if ($content =~ /<meta name="title" content="(.*)">/) {
                    $ret = $1;
                }
            } else {
                $parser->parse($content);
                if (defined $parser->header('Title')) {
                    $ret = $parser->header('Title');
                } else {
                    $ret = "";
                }
            }
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
        $msg = encode_utf8(decode_entities(get_title($msg)));
        if ($msg ne "") {
            if ($priv) {
                $server->command ("msg $nick your url is \"$msg\"");
            } else {
                $server->command ("msg $target $nick\'s url is \"$msg\"");
            }
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

