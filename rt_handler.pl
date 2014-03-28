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

sub do_cmd {
    my $tkt = shift;
    my $cmd = shift;

    my $resp;

    my @result=`rt $cmd $tkt`;
    $resp = $result[1];

    return $resp;
}

sub handler {
    my ($server, $msg, $nick, $addr, $target, $priv) = @_;

    use utf8;

    my $send = "";
    $msg = decode_utf8 $msg;
    if ($target eq '#ksucis-dudes') {
        if (($msg =~ /^!del\s/)||($msg =~ /^!delete\s/)||
                ($msg =~ /^!res\s/)||($msg =~ /^!resolve\s/)) {
            my @parts = split(/\s+/, $msg);
            my $cmd = $parts[0];
            $cmd =~ s/!//;
            $send = encode_utf8(do_cmd($parts[1], $cmd));
        } elsif ($msg =~ m/#(\d+)\b/) {
            $send = encode_utf8(do_lookup($1));
        }
        if ($send ne "") {
            if ($priv) {
                $server->command ("msg $nick $send");
            } else {
                $server->command ("msg $target $send");
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

