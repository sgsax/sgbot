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
    my $len = length($name);
    my $pad = " " x ((10-$len)/2) . $name;
    $pad .= " " x ((10-$len)/2);
    if (($len % 2)==1) { $pad .= " "; }
    
    my $train='          ____                           
       _||____|  |  __________   __________ 
      (   FAIL   | |          | |**********|
      /-()-----() ~ ()------() ~ ()------()';
    
    $train =~ s/\*{10}/$pad/;
    
    return $train;
}

sub handler {
    my ($server, $msg, $nick, $addr, $target, $priv) = @_;

    use utf8;
    $msg = decode_utf8 $msg;
    if ($msg =~ m/^!train/) {
        my @data = split(/ /, $msg);
        $msg = encode_utf8(make_train($data[1]));
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

