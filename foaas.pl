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

    my @parts = split(/\s+, $msg);
    my @selection = ( "!off $parts[1]",
                      "!you $parts[1]",
                      "!this",
                      "!that",
                      "!everything",
                      "!everyone",
                      "!donut $parts[1]",
                      "!linus $parts[1]" );

    return $selection[ rand @selection ];
}

sub generate_message {
    my ($msg, $nick) = @_;
    my $ret;

    my @parts = split(/\s+/, $msg);
    if ($parts[0] =~ m/^!off/) {
        $ret = "$parts[1]: Fuck off. - $nick";
    } elsif ($parts[0] =~ m/^!you/) {
        $ret = "$parts[1]: Fuck you. - $nick";
    } elsif ($parts[0] =~ m/^!this/) {
        $ret = "Fuck this. - $nick";
    } elsif ($parts[0] =~ m/^!that/) {
        $ret = "Fuck that. - $nick";
    } elsif ($parts[0] =~ m/^!everything/) {
        $ret = "Fuck everything. - $nick";
    } elsif ($parts[0] =~ m/^!everyone/) {
        $ret = "Everyone can go and fuck off. - $nick";
    } elsif ($parts[0] =~ m/^!donut/) {
        $ret = "$parts[1]: Go and take a flying fuck at a rolling donut. - $nick";
    } elsif ($parts[0] =~ m/^!linus/) {
        $ret = "$parts[1]: There aren't enough swear-words in the English language, so now I'll have to call you perkeleen vittupää just to express my disgust and frustration with this crap. - $nick";
    }

    return $ret;
}
sub handler {
    my ($server, $msg, $nick, $addr, $target, $priv) = @_;
    use utf8;

    $msg = decode_utf8 $msg;
    if ($msg =~ m/^!rfo/) { $msg = randomizer($msg) };
    $msg = generate_message($msg, $nick);

    $msg = encode_utf8($msg);
    if ($priv) {
        $server->command ("msg $nick $msg");
    } else {
        $server->command ("msg $target $msg");
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

