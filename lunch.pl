use strict;
use Encode;
use vars qw($VERSION %IRSSI);
use Irssi;

use Date::Simple (':all');
use DateTime;
use Time::Piece;

our $VERSION = '0.2';
our %IRSSI = (
    authors     => 'Seth Galitzer',
    contact     => 'sethgali@gmail.com',
    name        => 'lunch',
    description => 'lookup and return the location of the next lunch',
    license     => 'Public Domain',
);

my $WED = 3;
my $FRI = 5;

sub is_today {
    my $day = shift;
    my $today = shift;

    return ($today->day_of_week == $day)
}

sub after_lunch {
    my $now = shift;

    return ($now->hour() >= 13)
}

sub get_next_mtg_date {
    my $day = shift;
    my $today = shift;
    my $time = shift;

    my $offset = 0;
    # if it's a lunch day and already after lunch, recalculate for next week
    if ((after_lunch($time)) && wed_today($today)) { $offset = 7; };
    # find the next wednesday from today
    my $next = $today + (($day - $today->day_of_week) % 7) + $offset;
    return [$next->year, $next->month, $next->day];
}

sub get_time_diff {
    my $nextwed = shift;
    my $now = Time::Piece->strptime(shift,"%Y-%m-%dT%H:%M:%S");
    my $next = Time::Piece->strptime("$$nextwed[0]-$$nextwed[1]-$$nextwed[2]T12:00:00", "%Y-%m-%dT%H:%M:%S");

    my $diff = $next - $now;

    return $diff->pretty;
}

sub build_msg {
    my $day = shift;
    my $today = today();
    my $now = DateTime->now(time_zone => "local");
	my $nextdate = get_next_mtg_date($day, $today, $now);

    my $msg = "";
	my $label = "";
    my $msg2 = "";

    if ($day == $WED) {
        $label = "K-SLUG";
        $msg2 = ", location is ". getlocation($nextdate);
    } elsif ($day == $FRI) {
        $label = "Friday";
    }
    $msg = "Next $label lunch starts in " . get_time_diff($nextdate, $now) . $msg2;

    return $msg;
}

sub getlocation {
    use LWP::Simple;
    use iCal::Parser;

	my $nextwed = shift;

    my $url = 'https://www.google.com/calendar/ical/pnvjel5jlspo02q93gsoakpaf0%40group.calendar.google.com/public/basic.ics';

    my $raw = get($url);
    my $ical = iCal::Parser->new();
    my $data = $ical->parse_strings($raw);

    # there should be only one key returned, but grab a slice just in case
    my $key = (keys %{$data->{events}->{$$nextwed[0]}->{$$nextwed[1]}->{$$nextwed[2]}})[0];
    return  $data->{events}->{$$nextwed[0]}->{$$nextwed[1]}->{$$nextwed[2]}->{$key}->{LOCATION};
}

sub select_lunch {
	my $input = shift;
	my $ret = "";

	if ($input =~ m/^!lunch/) {
		$ret = build_msg($WED);
	} elsif ($input =~ m/^!0lunch/) {
		$ret = build_msg($FRI);
	}

	return $ret;
}
sub handler {
    my ($server, $msg, $nick, $addr, $target, $priv) = @_;

    use utf8;
    $msg = decode_utf8 $msg;

	$msg = select_lunch($msg);
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

