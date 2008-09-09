#!usr/bin/perl

use strict;
use warnings;

use AUBBC;
my $aubbc = new AUBBC;

# Change some default settings
$aubbc->settings( protect_email => 4 );

# Add some tags to Build tags
  my @other_sites =
        ('cpan','google','wikisource','ws','wikiquote','wq','wikibooks','wb','wikipedia','wp');
  foreach my $tag (@other_sites) {
  $aubbc->add_build_tag(
        name     => $tag,
        pattern  => 'all',
        type     => 1,
        function =>'main::other_sites',
        );
  }

  $aubbc->add_build_tag(
        name     => 'time',
        pattern  => '',
        type     => 3,
        function => 'main::other_sites',
        );

# The list
my $message = <<HTML;
[br][b]The Very common UBBC Tags[/b][br]
[[b]Bold[[/b] = [b]Bold[/b][br]
[[i]Italic[[/i] = [i]Italic[/i][br]
[[u]Underline[[/u] = [u]Underline[/u][br]
[[strike]Strike[[/strike] = [strike]Strike[/strike][br]
[left]]Left Align[[/left] = [left]Left Align[/left][br]
[[center]Center Align[[/center] = [center]Center Align[/center][br]
[right]]Right Align[[/right] = [right]Right Align[/right][br]
[sup]]Sup[[/sup] = [sup]Sup[/sup][br]
[sub]]Sub[[/sub] = [sub]Sub[/sub][br]
[pre]]Pre[[/pre] = [pre]Pre[/pre][br]
[img]]Image[[/img] = [img]home1.png[/img][br]
[right_img]]Image[[/img] = [right_img]home1.png[/img][br]
[left_img]]Image[[/img] = [left_img]home1.png[/img][br][br][br]
[url]]URL[[/url] = [url]http://google.com[/url][br]
[url=URL]]Name[[/url] = [url=http://google.com]Google[/url][br]
http&#58;//google.com = http://google.com[br]
www&#46;cpan.org = www.cpan.org[br]
[email]]Email[/email] = [email]some\@email.com[/email] Recommended Not to Post your email in a public area[br]
[code]]# Some Code ......[[/code] = [code]# Some Code ......[/code][br]
[c]]# Some Code ......[/c]] = [c]# Some Code ......[/c][br]
[[c=My Code]# Some Code ......[/c]] = [c=My Code]# Some Code ......[/c][br]
[[code=My Code]]# Some Code ......[[/code]] = [code=My Code]# Some Code ......[/code][br]
[quote]]Quote[/quote]] = [quote]Quote[/quote][br]
[quote=Flex]]Quote[/quote]] = [quote=Flex]Quote[/quote][br]
[ul]]My List[li]].....[/li]][li]].....[/li]][li]].....[/li]][/ul]] = [ul]My List[li].....[/li][li].....[/li][li].....[/li][/ul][br]
[ol]]My Numbered List[li=1]].....[/li]][li]].....[/li]][li]].....[/li]][/ol]] = [ol]My Numbered List[li=1].....[/li][li].....[/li][li].....[/li][/ol][br]
[color=Red]]Color[/color]] = [color=Red]Color[/color][br][br]
[b]Unicode Support[/b][br]
[utf://x3A3]] = [utf://x3A3][br]
[utf://0931]] = [utf://0931][br]
&#0931&#59; =  &#0931;[br][br]
[b]Entity names[/b][br]
&iquest&#59; = &iquest;[br]
[b]Built Tags[/b][br]
[google://Google] Google Search[br]
[wp://Wikipedia:About] or  [wikipedia://Wikipedia:About] Wikipedia[br]
[wb://Wikibooks:About] or [wikibooks://Wikibooks:About] Wikibooks[br]
[wq://Wikiquote:About] or [wikiquote://Wikiquote:About] Wikiquote[br]
[ws://Wikisource:About_Wikisource] or [wikisource://Wikisource:About_Wikisource] Wikisource[br]
[cpan://Cpan] Cpan Module Search[br]
[time] Time[br]
HTML

$message = $aubbc->do_all_ubbc($message);

print "Content-type: text/html\n\n";
print <<HTML;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>AUBBC.pm Tag List</title>
</head>
<body>
$message
</body>
</html>
HTML
exit;

sub other_sites {
  my ($tag_name, $text_from_AUBBC) = @_;

  # cpan modules
  $text_from_AUBBC = "<a href=\"http://search.cpan.org/search?mode=module&query=$text_from_AUBBC\" target=\"_blank\">$text_from_AUBBC</a>" if $tag_name eq 'cpan';

  # wikipedia Wiki
  $text_from_AUBBC = "<a href=\"http://wikipedia.org/wiki/Special:Search?search=$text_from_AUBBC\" target=\"_blank\">$text_from_AUBBC</a>" if ($tag_name eq 'wikipedia' || $tag_name eq 'wp');

  # wikibooks Wiki Books
  $text_from_AUBBC = "<a href=\"http://wikibooks.org/wiki/Special:Search?search=$text_from_AUBBC\" target=\"_blank\">$text_from_AUBBC</a>" if ($tag_name eq 'wikibooks' || $tag_name eq 'wb');

  # wikiquote Wiki Quote
  $text_from_AUBBC = "<a href=\"http://wikiquote.org/wiki/Special:Search?search=$text_from_AUBBC\" target=\"_blank\">$text_from_AUBBC</a>" if ($tag_name eq 'wikiquote' || $tag_name eq 'wq');

  # wikisource Wiki Source
  $text_from_AUBBC = "<a href=\"http://wikisource.org/wiki/Special:Search?search=$text_from_AUBBC\" target=\"_blank\">$text_from_AUBBC</a>" if ($tag_name eq 'wikisource' || $tag_name eq 'ws');

  # google search
  $text_from_AUBBC = "<a href=\"http://www.google.com/search?q=$text_from_AUBBC\" target=\"_blank\">$text_from_AUBBC</a>" if $tag_name eq 'google';

  # localtime()
  if ($tag_name eq 'time') {
        my $time = scalar(localtime);
        $text_from_AUBBC = "<b>[$time]</b>";
        }
        return $text_from_AUBBC;
}
