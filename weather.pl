use strict;
use Encode;
use vars qw($VERSION %IRSSI);
use Irssi;
use JSON;

our $VERSION = '0.3';
our %IRSSI = (
    authors     => 'Seth Galitzer',
    contact     => 'sethgali@gmail.com',
    name        => 'weather',
    description => 'prints short weather report for specified zipcode or weather station',
    license     => 'Public Domain',
);

our %icons = (
    "01" => "\x{2600}",
    "02" => "\x{1F324}",
    "03" => "\x{2601}",
    "04" => "\x{1F325}",
    "09" => "\x{1F326}",
    "10" => "\x{1F327}",
    "11" => "\x{26C8}",
    "13" => "\x{2744}",
    "50" => "\x{1F32B}"
);

sub get_secrets {
    use File::Slurp;
    
    # The secrets.json file should be placed in the same directory as this
    #   script and should be formatted as follows:
    #   { "apikey" : "youropenweathermapapikey" }
    my $secrets = read_file("./secrets.json");
    return decode_json($secrets);
}

sub get_the_weather {
    use LWP::Simple;
    use URI::Escape;
    ##use Data::Dumper;
 
    my $apikey = get_secrets()->{apikey};

    my $ret;

    # User variable, change this to suit your location
    my $location = shift;
    if ($location eq "") { $location = "66502"; };

    # format location string for passing to URL
    $location = uri_escape($location);
 
    # get the current conditions

    my $raw = get("http:\/\/api.openweathermap.org\/data\/2.5\/weather?zip=$location&units=imperial&appid=$apikey");
    if ($raw eq ""){
        return "Invalid location code: $location\n";
    };
    my $current = decode_json($raw);

    my $lat = $current->{coord}->{lat};
    my $lon = $current->{coord}->{lon};

    # get forecast data
    my $forecast = decode_json(get("https:\/\/api.openweathermap.org\/data\/2.5\/onecall?lat=$lat&lon=$lon&exclude=current,minutely,hourly,alerts&units=imperial&appid=$apikey"));
 
    # display data
    if (not defined $current) {
        $ret = "Current weather not available";
    } else {
        $ret = "Current weather for $current->{name} | ";
        $ret .= localtime($current->{dt}) . " | ";
        $ret .= "$current->{weather}[0]->{description} ";
        $ret .= $icons{substr($current->{weather}[0]->{icon}, 0, 2)} . ", ";
        $ret .= "Temp: $current->{main}->{temp}\x{b0}F, ";
        $ret .= "Feels like: $current->{main}->{feels_like}\x{b0}F | ";
        $ret .= "Humidity: $current->{main}->{humidity}%, Pressure: $current->{main}->{pressure} hPa | ";
        $ret .= "Wind: $current->{wind}->{deg} $current->{wind}->{speed} mph | ";
    }

    if (not defined $forecast) {
        $ret .= "Forecast not available";
    } else {
        $ret .= "Forecast: $forecast->{daily}[0]->{weather}[0]->{description} | ";
        $ret .= "High: $forecast->{daily}[0]->{temp}->{max}\x{b0}F,";
        $ret .= " Low: $forecast->{daily}[0]->{temp}->{min}\x{b0}F";
    }

    return $ret;
}

sub handler {
    my ($server, $msg, $nick, $addr, $target, $priv) = @_;

    use utf8;
    $msg = decode_utf8 $msg;
    if ($msg =~ m/^!weather/) {
        my @data = split(/ /, $msg);
        $msg = encode_utf8(get_the_weather($data[1]));
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

