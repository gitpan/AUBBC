#!/usr/bin/perl
use strict;
use warnings;
use Carp qw(carp croak);
use Data::Dumper;
use Benchmark;

my %loaded;
for (qw/ AUBBC BBCode::Parser Parse::BBCode HTML::BBCode HTML::BBReverse /) {
    eval "use $_";
    unless ($@) {
      $loaded{$_} = $_->VERSION;
    }
}
print "Benchmarking...\n";
for my $key (keys %loaded) {
    print "$key\t$loaded{$key}\n";
}


my $code = <<'EOM';
[br][b]The Very common UBBC Tags[/b][br]
[[b]Bold[[/b] = [b]Bold[/b][br]
[[strong]Strong[[/strong] = [strong]Strong[/strong][br]
[[small]Small[[/small] = [small]Small[/small][br]
[[big]Big[[/big] = [big]Big[/big][br]
[[h1]Head 1[[/h1] = [h1]Head 1[/h1][br]
through.....[br]
[[h6]Head 6[[/h6] = [h6]Head 6[/h6][br]
[[i]Italic[[/i] = [i]Italic[/i][br]
[[u]Underline[[/u] = [u]Underline[/u][br]
[[strike]Strike[[/strike] = [strike]Strike[/strike][br]
[left]]Left Align[[/left] = [left]Left Align[/left][br]
[[center]Center Align[[/center] = [center]Center Align[/center][br]
[right]]Right Align[[/right] = [right]Right Align[/right][br]
[sup]Sup[/sup][br]
[sub]Sub[/sub][br]
[pre]]Pre[[/pre] = [pre]Pre[/pre][br]
[img]]http://www.google.com/intl/en/images/about_logo.gif[[/img] =
[img]http://www.google.com/intl/en/images/about_logo.gif[/img][br][br]
[url=URL]]Name[[/url] = [url=http://www.google.com]Google[/url][br]
http[utf://#58]//google.com = http://google.com[br]
[email]]Email[/email] = [email]some@email.com[/email] Recommended Not to Post your email in a public area[br]
[code]]# Some Code ......
my %hash = ( stuff => { '1' => 1, '2' => 2 }, );
print $hash{stuff}{'1'};[[/code] =
[code]# Some Code ......
my %hash = ( stuff => { '1' => 1, '2' => 2 }, );
print $hash{stuff}{'1'};[/code][br]
[c]]# Some Code ......
my %hash = ( stuff => { '1' => 1, '2' => 2 }, );
print $hash{stuff}{'1'};[/c]] =
[c]# Some Code ......
my %hash = ( stuff => { '1' => 1, '2' => 2 }, );
print $hash{stuff}{'1'};[/c][br]
[[c=My Code]# Some Code ......
my %hash = ( stuff => { '1' => 1, '2' => 2 }, );
print $hash{stuff}{'1'};[/c]] =
[c=My Code]# Some Code ......
my %hash = ( stuff => { '1' => 1, '2' => 2 }, );
print $hash{stuff}{'1'};[/c][br][br]
[quote]]Quote[/quote]] = [quote]Quote[/quote][br]
[quote=Flex]]Quote[/quote]] = [quote=Flex]Quote[/quote][br]
[color=Red]]Color[/color]] = [color=Red]Color[/color][br][br]
[b]Unicode Support[/b][br]
[utf://#x3A3]] = [utf://#x3A3][br]
[utf://#0931]] = [utf://#0931][br]
? =  ?[br][br]
[b]Entity names[/b][br]
¿ = ¿[br]

EOM


sub create_pb {
    my $pb = Parse::BBCode->new();
    return $pb;
}

sub create_hb {
    my $bbc  = HTML::BBCode->new();
    return $bbc;
}

sub create_bp {
    my $parser = BBCode::Parser->new(follow_links => 1);
    return $parser;
}

sub create_bbr {
    my $bbr = HTML::BBReverse->new();
    return $bbr;
}

sub create_au {
    my $au = AUBBC->new();
    return $au;
}

my $pb = create_pb();
my $bp = create_bp();
my $hb = create_hb();
my $bbr = create_bbr();
my $au = create_au();

my $rendered1 = $pb->render($code);
#print "PB\n$rendered1\n\n";
my $tree = $bp->parse($code);
my $rendered2 = $tree->toHTML();
#print "BP\n$rendered2\n\n";
my $rendered3 = $hb->parse($code);
#print "HB\n$rendered3\n\n";
my $rendered4 = $bbr->parse($code);
print "BBR\n$rendered4\n\n";
my $rendered5 = $au->do_all_ubbc($code);
#print "AU\n$rendered5\n\n";

timethese($ARGV[0] || -1, {
    $loaded{'Parse::BBCode'} ?  (
        'P::B::new'  => \&create_pb,
        'P::B::x'  => sub { my $out = $pb->render($code) },
    ) : (),
    $loaded{'HTML::BBCode'} ?  (
        'H::B::new'  => \&create_hb,
        'H::B::x'  => sub { my $out = $hb->parse($code) },
    ) : (),
    $loaded{'BBCode::Parser'} ?  (
        'B::P::new' => \&create_bp,
        'B::P::x' => sub { my $tree = $bp->parse($code); my $out = $tree->toHTML(); },
    ) : (),
    $loaded{'HTML::BBReverse'} ?  (
        'BBR::new' => \&create_bbr,
        'BBR::x' => sub { my $out = $bbr->parse($code); },
    ) : (),
    $loaded{'AUBBC'} ?  (
        'AU::new' => \&create_au,
        'AU::x' => sub { my $out = $au->do_all_ubbc($code); },
    ) : (),
});
