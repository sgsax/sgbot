use strict;
use Encode;
use vars qw($VERSION %IRSSI);
use Irssi;

our $VERSION = '0.1';
our %IRSSI = (
    authors     => 'Seth Galitzer',
    contact     => 'sethgali@gmail.com',
    name        => 'foaas',
    description => 'Fuck Off As A Service, based on https://foaas.herokuapp.com/',
    license     => 'Public Domain',
);

sub randomizer {
    my $msg = shift;

    my @parts = split(/\s+/, $msg);
    my @selection = ( "!off $parts[1]",
                      "!you $parts[1]",
                      "!yeah $parts[1]",
                      "!no $parts[1]",
                      "!up $parts[1]",
                      "!this",
                      "!that",
                      "!everything",
                      "!holy",
                      "!everyone",
                      "!donut $parts[1]",
                      "!linus $parts[1]", 
                      "!finger $parts[1]" );

    return $selection[ rand @selection ];
}

sub generate_message {
    my ($msg, $nick) = @_;
    my $ret = "";

    my $finger = "\N{U+1F595}";

    my @parts = split(/\s+/, $msg);
    if ($parts[0] =~ m/^!off\b/) {
        $ret = "Fuck off. - $nick";
        if ($parts[1] ne "") { $ret = "$parts[1]: $ret"; }
    } elsif ($parts[0] =~ m/^!you\b/) {
        $ret = "Fuck you. - $nick";
        if ($parts[1] ne "") { $ret = "$parts[1]: $ret"; }
    } elsif ($parts[0] =~ m/^!yeah\b/) {
        $ret = "Fuck yeah! - $nick";
        if ($parts[1] ne "") { $ret = "$parts[1]: $ret"; }
    } elsif ($parts[0] =~ m/^!no\b/) {
        $ret = "Fuck no!  Are you kidding me? - $nick";
        if ($parts[1] ne "") { $ret = "$parts[1]: $ret"; }
    } elsif ($parts[0] =~ m/^!up\b/) {
        $ret = "You really fucked up this time. - $nick";
        if ($parts[1] ne "") { $ret = "$parts[1]: $ret"; }
    } elsif ($parts[0] =~ m/^!this\b/) {
        $ret = "Fuck this. - $nick";
    } elsif ($parts[0] =~ m/^!that\b/) {
        $ret = "Fuck that. - $nick";
    } elsif ($parts[0] =~ m/^!everything\b/) {
        $ret = "Fuck everything. - $nick";
    } elsif ($parts[0] =~ m/^!holy\b/) {
        $ret = "Holy fuck! - $nick";
    } elsif ($parts[0] =~ m/^!everyone\b/) {
        $ret = "Everyone can go and fuck off. - $nick";
    } elsif ($parts[0] =~ m/^!donut\b/) {
        $ret = "Go and take a flying fuck at a rolling donut. - $nick";
        if ($parts[1] ne "") { $ret = "$parts[1]: $ret"; }
    } elsif ($parts[0] =~ m/^!linus\b/) {
        $ret = "There aren't enough swear-words in the English language, so now I'll have to call you perkeleen vittupää just to express my disgust and frustration with this crap. - $nick";
        if ($parts[1] ne "") { $ret = "$parts[1]: $ret"; }
    } elsif ($parts[0] =~ m/^!finger\b/) {
        $ret = "$finger$finger$finger - $nick";
        if ($parts[1] ne "") { $ret = "$parts[1]: $ret"; }
    }


    return $ret;
}
sub handler {
    my ($server, $msg, $nick, $addr, $target, $priv) = @_;
    use utf8;

    $msg = decode_utf8 $msg;
    if ($msg =~ m/^!rfo/) { $msg = randomizer($msg) };
    $msg = generate_message($msg, $nick);

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

