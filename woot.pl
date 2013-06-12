use strict;
use Encode;
use vars qw($VERSION %IRSSI);
use Irssi;

our $VERSION = '0.1';
our %IRSSI = (
    authors     => 'Seth Galitzer',
    contact     => 'sethgali@gmail.com',
    name        => 'woot',
    description => 'look up and print today\'s woot.com special; optionally display the image and/or "buy now" url',
    license     => 'Public Domain',
);

sub woot {
    use LWP::Simple;
    use XML::Simple;

    my @fargs = @_;
    
    my $rss = get("http://woot.com/salerss.aspx");
    my $xml = new XML::Simple;
    my $data = $xml->XMLin($rss);
    my $ret = "";
    my $pct;
    my $wo = 0;
    
    my $img = grep(/img/i, @fargs);
    my $buy = grep(/buy/i, @fargs);

    if ($$data{"channel"}{"item"}{"woot:wootoff"} =~ m/True/i) { $wo = 1; }
    
    if ($wo) {
    	$ret = "WOOT OFF! | ";
    } else {
    	$ret = "Daily Woot | ";
    }
    
    $ret .= $$data{"channel"}{"item"}{"title"} . " | " . $$data{"channel"}{"item"}{"woot:price"};
    if ($wo) {
    	if ($$data{"channel"}{"item"}{"woot:soldout"} eq "True") {
            	$ret .= " | SOLD OUT!";
    	} else {
    		my $pct = (eval $$data{"channel"}{"item"}{"woot:soldoutpercentage"} * 100);
    		$ret .= " | $pct% sold";
    	}
    }
    if ($img) { $ret .= " | Image URL: " . $$data{"channel"}{"item"}{"woot:standardimage"}; }
    if ($buy) { $ret .= " | Buy Now URL: " . $$data{"channel"}{"item"}{"woot:purchaseurl"}; }
    
    return $ret;
}

sub handler {
    my ($server, $msg, $nick, $addr, $target, $priv) = @_;

    use utf8;
    $msg = decode_utf8 $msg;
    if ($msg =~ m/^!woot/) {
        $msg = encode_utf8(woot($msg));
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

