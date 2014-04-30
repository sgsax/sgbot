use strict;
use Encode;
use vars qw($VERSION %IRSSI);
use Irssi;

our $VERSION = '0.1';
our %IRSSI = (
    authors     => 'Seth Galitzer',
    contact     => 'sethgali@gmail.com',
    name        => 'lunch',
    description => 'lookup and return the location of the next lunch',
    license     => 'Public Domain',
);

sub getnextwed {
    use Date::Simple (':all');
    use DateTime;

    # day of week for today
    my $today = today();
    my $dow = $today->day_of_week;
    # if it's a lunch day and already after lunch, recalculate for next week
    my $now = DateTime->now(time_zone => "local");
    #if ($now->hour() >= 12) { $dow += 1; };
    # find the next wednesday from today
    my $next = $today + ((3 - $dow) % 7);
    return [$next->year, $next->month, $next->day];
}

sub getlocation {
    use LWP::Simple;
    use iCal::Parser;
    use Data::Dumper;

    my $url = 'https://www.google.com/calendar/ical/pnvjel5jlspo02q93gsoakpaf0%40group.calendar.google.com/public/basic.ics';

    my $raw = get($url);
    my $ical = iCal::Parser->new();
    my $data = $ical->parse_strings($raw);

    my $nextwed = getnextwed();
    print Dumper($nextwed);
    return $nextwed;
    # there should be only one key returned, but grab a slice just in case
#    my $key = (keys $data->{events}->{$$nextwed[0]}->{$$nextwed[1]}->{$$nextwed[2]})[0];
#    return  $data->{events}->{$$nextwed[0]}->{$$nextwed[1]}->{$$nextwed[2]}->{$key}->{LOCATION};
}

sub handler {
    my ($server, $msg, $nick, $addr, $target, $priv) = @_;

    use utf8;
    $msg = decode_utf8 $msg;
    if ($msg =~ m/^!lunch/) {
        $msg = getlocation();
        if (!(defined $msg)) { 
            $msg = "error running command";
        } else {
            $msg = encode_utf8("Location of next lunch is $msg");
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

