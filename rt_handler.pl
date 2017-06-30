use strict;
use Encode;
use vars qw($VERSION %IRSSI);
use Irssi;

our $VERSION = '0.1';
our %IRSSI = (
    authors     => 'Seth Galitzer',
    contact     => 'sethgali@gmail.com',
    name        => 'rt_lookup',
    description => 'looks up a ticket in RT by a provided number and returns the subject and url; can optionally delete or resolve a ticket; assumes you have the rt cli tool in your search path and a .rtrc file in your homedir; change the value of $rthost in do_lookup() for your own RT host',
    license     => 'Public Domain',
);

sub do_lookup {
    my $tkt = shift;
    my $ret;
    my @result=`rt show -t ticket -f subject ticket/$tkt`;
    my $subj = $result[1];
    my $rthost = "rt.cis.ksu.edu"; # change this for your own host
    if (!($subj =~ m/^$/)) {
        chomp($subj);
        $subj =~ s/Subject/\#$tkt/;
        $ret = "$subj - https://$rthost/Ticket/Display.html?id=$tkt";
    } else {
        $ret = "Ticket \#$tkt not found";
    }

    return $ret;
}

sub do_cmd {
# for most commands that only require a ticket number
    my $tkt = shift;
    my $cmd = shift;

    my $resp;

    # in case we accidentally included a pound, get rid of it
    if ($tkt =~ m/#/) { 
        $tkt =~ s/#//;
    }
    
    if ($tkt =~ /^\+?\d+$/) {
        my @result=`rt $cmd $tkt`;
        if (defined $result[1]) {
            # multiple rows returned, send back the second one
            $resp = $result[1];
        } else {
            # only one row returned, send it back
            $resp = $result[0];
        }
    } else {
        $resp = "Nincompoop! You forgot the ticket number!";
    }

    return $resp;
}

sub do_cmd_special {
# some special commands are assembled before passing here, so just run as provided
    my $cmd = shift;
	my $resp = "";

    my @result=`rt $cmd`;
    if (defined $result[1]) {
        # more than one row returned
        if ($result[1] =~ /Ticket/) {
            $resp = $result[1];
        } else {
            # edit commands with "add" return a bunch of extra ticket info,
            #   only return the row with relevant info
            $resp = $result[3];
        }
    } else {
        # only one row returned
        $resp = $result[0];
    }
    
    return $resp;
}

sub parse_cmd {
    my $input = shift;

    my $ret = "";

    my @parts = split(/\s+/, $input);
    my $cmd = $parts[0];
    $cmd =~ s/!rt//;

    if (($cmd eq "del") || ($cmd eq "delete") ||
        ($cmd eq "res") || ($cmd eq "resolve") ||
        ($cmd eq "take") || ($cmd eq "steal") ||
        ($cmd eq "untake")) {
        $ret = do_cmd($parts[1], $cmd);
    } elsif ($cmd eq "give") {
        $cmd .= " $parts[1] $parts[2]";
        $ret = do_cmd_special($cmd);
        if ($ret =~ /updated/) {
            $cmd = "comment -m \'this ticket has been assigned to $parts[2]\' $parts[1]";
            $ret = do_cmd_special($cmd);
        }
    } elsif ($cmd eq "comment") {
        my $comment = join(" ", @parts[2..($#parts)]);
        $cmd = "comment -m \'$comment\' $parts[1]";
        $ret = do_cmd($parts[1], $cmd);
    } elsif (($cmd eq "cc") || ($cmd eq "admincc")) {
        $cmd = "edit ticket/$parts[1] add $cmd=$parts[2]";
        $ret = do_cmd_special($cmd);
    } elsif ($cmd eq "req") {
        $cmd = "edit ticket/$parts[1] set requestors=$parts[2]";
        $ret = do_cmd_special($cmd);
    } else {
        $ret = "$cmd is an invalid command for rt";
    }

    return $ret;

}

sub handler {
    my ($server, $msg, $nick, $addr, $target, $priv) = @_;

    use utf8;

    my $send = "";
    $msg = decode_utf8 $msg;
    if ($target eq '#ksucis-dudes') {
        if ($msg =~ /^!rt/) {
            $send = encode_utf8(parse_cmd($msg));
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

Irssi::signal_add_last('message irc action', sub {
    my ($server, $msg, $nick, $addr, $target) = @_;
    Irssi::signal_continue($server, $msg, $nick, $addr, $target);
    handler($server, $msg, $nick, $addr, $target);
});

Irssi::signal_add_last('message irc own_action', sub {
    my ($server, $msg, $target) = @_;
    Irssi::signal_continue($server, $msg, $target);
    handler($server, $msg, '', '', $target);
});

Irssi::signal_add_last('message private', sub {
    my ($server, $msg, $nick, $addr, $target) = @_;
    Irssi::signal_continue($server, $msg, $nick, $addr, $target);
    handler($server, $msg, $nick, $addr, $target, 1);
});

