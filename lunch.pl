use strict;
use Encode;
use vars qw($VERSION %IRSSI);
use Irssi;

use Date::Simple (':all');
use DateTime;

our $VERSION = '0.1';
our %IRSSI = (
    authors     => 'Seth Galitzer',
    contact     => 'sethgali@gmail.com',
    name        => 'lunch',
    description => 'lookup and return the location of the next lunch',
    license     => 'Public Domain',
);

sub wed_today {
    my $today = shift;

    return ($today->day_of_week == 3)
}

sub after_lunch {
    my $now = shift;

    return ($now->hour() >= 13)
}

sub get_next_mtg_date {
    my $today = shift;
    my $time = shift;

    my $offset = 0;
    # if it's a lunch day and already after lunch, recalculate for next week
    if ((after_lunch($time)) && wed_today($today)) { $offset = 7; };
    # find the next wednesday from today
    my $next = $today + ((3 - $today->day_of_week) % 7) + $offset;
    return [$next->year, $next->month, $next->day];
}

sub build_msg {
    my $today = today();
    my $now = DateTime->now(time_zone => "local");

    my $msg = "Location of ";

    my $loc = getlocation($today, $now);

    if ((wed_today($today)) && !(after_lunch($now))) {
        $msg .= "lunch today ";
    } else {
        $msg .= "next lunch ";
    }

    $msg .= "is $loc";

    return $msg;
}

sub getlocation {
    use LWP::Simple;
    use iCal::Parser;

    my $today = shift;
    my $time = shift;

    my $url = 'https://www.google.com/calendar/ical/pnvjel5jlspo02q93gsoakpaf0%40group.calendar.google.com/public/basic.ics';

    my $raw = get($url);
    my $ical = iCal::Parser->new();
    my $data = $ical->parse_strings($raw);

    my $nextwed = get_next_mtg_date($today, $time);
    # there should be only one key returned, but grab a slice just in case
    my $key = (keys %{$data->{events}->{$$nextwed[0]}->{$$nextwed[1]}->{$$nextwed[2]}})[0];
    return  $data->{events}->{$$nextwed[0]}->{$$nextwed[1]}->{$$nextwed[2]}->{$key}->{LOCATION};
}

sub handler {
    my ($server, $msg, $nick, $addr, $target, $priv) = @_;

    use utf8;
    $msg = decode_utf8 $msg;
    if ($msg =~ m/^!lunch/) {
        $msg = build_msg();
        if (!(defined $msg)) { 
            $msg = "error running command";
        } else {
            $msg = encode_utf8($msg);
        }
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

