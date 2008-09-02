#!usr/bin/perl

use strict;
use warnings;

use AUBBC;
my $aubbc = new AUBBC;

# Change some default settings
$aubbc->settings( protect_email => 4 );

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
