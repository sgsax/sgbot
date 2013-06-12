use strict;
use Encode;
use vars qw($VERSION %IRSSI);
use Irssi;

our $VERSION = '0.1';
our %IRSSI = (
    authors     => 'Seth Galitzer',
    contact     => 'sethgali@gmail.com',
    name        => 'spellcheck',
    description => 'simple spellchecker, looks up a single word and suggests corrections',
    license     => 'Public Domain',
);

sub spellcheck {
    use Lingua::Ispell;

    my $word = shift;
    my $resp = "";
    my @ret = Lingua::Ispell::spellcheck($word);
    if (@ret > 0) {
        $resp = "Perhaps you mean:";
        if (defined @{$ret[0]->{'misses'}}) {
            foreach my $sug (@{$ret[0]->{'misses'}}) {
                $resp .= " $sug";
            }
        } else {
            $resp .= " (no suggestions)";
        }
    } else {
        $resp = "\'$word\' is correct";
    }

    return $resp;
}

sub handler {
    my ($server, $msg, $nick, $addr, $target, $priv) = @_;

    use utf8;
    $msg = decode_utf8 $msg;
    if ($msg =~ m/^!spell/) {
        my @data = split(/ /, $msg);
        $msg = encode_utf8(spellcheck($data[1]));
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

