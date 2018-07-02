use strict;
use Encode;
use vars qw($VERSION %IRSSI);
use Irssi;

our $VERSION = '0.2';
our %IRSSI = (
    authors     => 'Seth Galitzer',
    contact     => 'sethgali@gmail.com',
    name        => 'weather',
    description => 'prints short weather report for specified zipcode or weather station',
    license     => 'Public Domain',
);

sub get_the_weather {
    use XML::Simple;
    use LWP::Simple;
    use URI::Escape;
    ##use Data::Dumper;
 
    # User variable, change this to suit your location
    my $location = shift;
    if ($location eq "") { $location = "66502"; };

    # format location string for passing to URL
    $location = uri_escape($location);
 
    # get the current conditions
    my $output_current = get("http:\/\/api.wunderground.com\/auto\/wui\/geo\/WXCurrentObXML\/index.xml?query=$location");
    # get forecast data
    my $output_forecast = get("http:\/\/api.wunderground.com\/auto\/wui\/geo\/ForecastXML\/index.xml?query=$location");
 
    my $data_current;
    my $data_forecast;
    my $ret;

    # parse retrieved data and dump XML to hash reference
    my $xml = new XML::Simple;
    if (defined $output_current) {
        my $data_current = $xml->XMLin($output_current);
    }
    if (defined $output_forecast) {
        my $data_forecast = $xml->XMLin($output_forecast);
    }
    ##print Dumper($data_current);
    ##print Dumper($data_forecast);
    
    if ($data_current->{display_location}->{full} eq ", ") {
        return "Invalid location code: $location\n";
    }
    
    # display data
    if (not defined $output_current) {
        $ret = "Current weather not available";
    } else {
        $ret = "Current weather for $data_current->{display_location}->{full} | ";
        $ret .= "$data_current->{observation_time} | ";
        $ret .= "$data_current->{weather}, Temp: $data_current->{temp_f},";
        if ($data_current->{heat_index_f} ne 'NA') {
            $ret .= " Heat Index: $data_current->{heat_index_f} F | ";
        } else {
            $ret .= " Wind Chill: $data_current->{windchill_f} F | ";
        };
        $ret .= "Humidity: $data_current->{relative_humidity}, Pressure: $data_current->{pressure_in}\" | ";
        $ret .= "Wind: $data_current->{wind_dir} $data_current->{wind_mph}mph | ";
    }

    if (not defined $output_forecast) {
        $ret .= "Forecast not available";
    } else {
        $ret .= "Forecast: $data_forecast->{simpleforecast}->{forecastday}[1]->{conditions} | ";
        $ret .= "High: $data_forecast->{simpleforecast}->{forecastday}[1]->{high}->{fahrenheit} F,";
        $ret .= " Low: $data_forecast->{simpleforecast}->{forecastday}[1]->{low}->{fahrenheit} F";
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

