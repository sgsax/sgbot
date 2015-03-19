use strict;
use Encode;
use vars qw($VERSION %IRSSI);
use Irssi;

our $VERSION = '0.1';
our %IRSSI = (
    authors     => 'Seth Galitzer',
    contact     => 'sethgali@gmail.com',
    name        => 'rt_lookup',
    description => 'looks up a ticket in RT by a provided number and returns the subject and url',
    license     => 'Public Domain',
);

sub do_lookup {
    my $tkt = shift;
    my $ret;
    my @result=`rt show -t ticket -f subject ticket/$tkt`;
    my $subj = $result[1];
    if (!($subj =~ m/^$/)) {
        chomp($subj);
        $subj =~ s/Subject/\#$tkt/;
        $ret = "$subj - https://rt4.cis.ksu.edu/rt/Ticket/Display.html?id=$tkt";
    } else {
        $ret = "Ticket \#$tkt not found";
    }

    return $ret;
}

sub handler {
    my ($server, $msg, $nick, $addr, $target, $priv) = @_;

    use utf8;
    $msg = decode_utf8 $msg;
    if (($msg =~ m/#(\d+)\b/) && ($target eq '#ksucis-dudes')) {
        $msg = encode_utf8(do_lookup($1));
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

