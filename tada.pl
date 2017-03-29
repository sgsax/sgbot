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
        # http://www.wavsource.com/snds_2016-10-30_1570758759693582/tv/simpsons/homer/doh1_y.wav
        $ret = "http://bit.ly/2fs0lsi";
    } elsif ($input =~ m/^!rimshot/) {
        # http://instantrimshot.com/index.php?sound=rimshot&play=true
        $ret = "http://bit.ly/1eUzUFm";
    } elsif ($input =~ m/^!tada/) {
        # http://www.orangefreesounds.com/wp-content/uploads/2014/12/Ta-da-sound.mp3?_=1
        $ret = "http://bit.ly/2fJhdde";
    } elsif ($input =~ m/^!trombone/) {
        # http://www.freesound.org/data/previews/73/73581_634166-lq.mp3
        $ret = "http://bit.ly/1Y3wXaV";
    } elsif ($input =~ m/^!khan/) {
        # http://www.wavsource.com/snds_2016-10-30_1570758759693582/movies/star_trek/2khan.wav
        $ret = "http://bit.ly/2fXX0FP";
    } elsif ($input =~ m/^!supplies/) {
        # UHF super racist SUPPLIES scene
        $ret = "https://youtu.be/RB2GboGOuTI";
    } elsif ($input =~ m/^!google/) {
        # Taryn Southern - Google That Shit
        $ret = "https://youtu.be/4knAlxMzp0s";
    } elsif ($input =~ m/^!USA/) {
        $ret = "I got nothin";
    } elsif ($input =~ m/^!freedom/) {
        # Team America - Freedom isn't Free
        $ret = "https://youtu.be/tzW2ybYFboQ";
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

