use strict;
use Encode;
use vars qw($VERSION %IRSSI);
use Irssi;

our $VERSION = '0.1';
our %IRSSI = (
    authors     => 'Seth Galitzer',
    contact     => 'sethgali@gmail.com',
    name        => 'train',
    description => 'all aboard the Fail Train',
    license     => 'Public Domain',
);

sub make_train {
    my $name = shift;
    my @train=();
    my $len = length($name);
    my $pad = " " x ((10-$len)/2) . $name;
    $pad .= " " x ((10-$len)/2);
    if (($len % 2)==1) { $pad .= " "; }
    
    $train[0]='              ____';
    $train[1]='       _||____|  |  __________   __________';
    $train[2]='      (   FAIL   | |          | |**********|';
    $train[3]='      /-()-----() ~ ()------() ~ ()------()';
    
    $train[2] =~ s/\*{10}/$pad/;
    
    return \@train;
}

sub handler {
    my ($server, $msg, $nick, $addr, $target, $priv) = @_;

    use utf8;
    $msg = decode_utf8 $msg;
    if ($msg =~ m/^!train/) {
        my @data = split(/ /, $msg);
        my $train = make_train($data[1]);
        my $i;
        if ($priv) {
            for ($i=0; $i<4; $i++) {
                $msg = "msg $nick " . encode_utf8($$train[$i]);
                $server->command ($msg);
            }
        } else {
            for ($i=0; $i<4; $i++) {
                $msg = "msg $target " . encode_utf8($$train[$i]);
                $server->command ($msg);
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

