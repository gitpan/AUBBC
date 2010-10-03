package AUBBC;
use strict;
use warnings;
use Memoize;
our $VERSION = '3.13';
our $BAD_MESSAGE = 'Error';
our $DEBUG_AUBBC = 0;

my $msg = '';
my %SMILEYS = ();
my %Build_AUBBC = ();
my %AUBBC = (aubbc => 1,utf => 1,smileys => 1,highlight => 1,highlight_function => \&{code_highlight},no_bypass => 0,for_links => 0,aubbc_escape => 1,no_img => 0,icon_image => 1,image_hight => 60,image_width => 90,image_border => 0,image_wrap => ' ',href_target => ' target="_blank"',images_url => '',html_type => ' /',fix_amp => 1,line_break => 1,code_class => '',code_extra => '',href_class => '',quote_class => '',quote_extra => '',script_escape => 1,protect_email => 0,email_message => '&#67;&#111;&#110;&#116;&#97;&#99;&#116;&#32;&#69;&#109;&#97;&#105;&#108;',highlight_class1 => '',highlight_class2 => '',highlight_class3 => '',highlight_class4 => '',highlight_class5 => '',highlight_class6 => '',highlight_class7 => '',);
my @do_flag = (1,1,1,1,1,0,0);
my $long_regex = '[\w\.\/\-\~\@\:\;\=]+(?:\?[\w\~\.\;\:\,\$\-\+\!\*\?\/\=\&\@\#\%]+?)?';
my @key64 = ('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/');

Memoize::memoize('AUBBC::smiley_hash');
Memoize::memoize('AUBBC::add_build_tag');
Memoize::memoize('AUBBC::do_all_ubbc');
Memoize::memoize('AUBBC::do_ubbc');
Memoize::memoize('AUBBC::do_build_tag');
Memoize::memoize('AUBBC::do_smileys');
Memoize::memoize('AUBBC::script_escape');
Memoize::memoize('AUBBC::html_to_text');

sub new {
warn 'CREATING AUBBC '.$VERSION if $DEBUG_AUBBC;
return bless {};
}

sub DESTROY {
warn 'DESTROY AUBBC '.$VERSION if $DEBUG_AUBBC;
}

sub settings_prep {
$AUBBC{href_target} = ($AUBBC{href_target}) ? ' target="_blank"' : '';
$AUBBC{image_wrap} = ($AUBBC{image_wrap}) ? ' ' : '';
$AUBBC{image_border} = ($AUBBC{image_border}) ? 1 : 0;
$AUBBC{html_type} = ($AUBBC{html_type} eq 'xhtml' || $AUBBC{html_type} eq ' /') ? ' /' : '';
}

sub settings {
 my ($self,%s_hash) = @_;
 if (keys %s_hash) {
  foreach (keys %s_hash) {
   if ('highlight_function' eq $_) {
    my $is_ok = check_subroutine($s_hash{$_}) || '';
    $AUBBC{highlight} = 0;
    $AUBBC{highlight_function} = ($is_ok) ? \&{$s_hash{$_}} : \&{code_highlight};
   } else {
    $AUBBC{$_} = $s_hash{$_};
   }
  }
  &settings_prep;
 }
 if ($DEBUG_AUBBC) {
  my $uabbc_settings = '';
  $uabbc_settings .= $_ . ' =>' . $AUBBC{$_} . ', ' foreach keys %AUBBC;
  warn 'AUBBC Settings Change: '.$uabbc_settings;
 }
}

sub get_setting {
 my ($self,$name) = @_;
 return $AUBBC{$name} if exists $AUBBC{$name};
}

sub code_highlight {
 my $txt = shift;
 warn 'ENTER code_highlight' if $DEBUG_AUBBC;
 $txt =~ s/:/&#58;/go;
 $txt =~ s/\[/&#91;/go;
 $txt =~ s/\]/&#93;/go;
 $txt =~ s/\{/&#123;/go;
 $txt =~ s/\}/&#125;/go;
 $txt =~ s/%/&#37;/go;
 $txt =~ s/\s{1};/ &#59;/go;
 $txt =~ s/&lt;/&#60;/go;
 $txt =~ s/&gt;/&#62;/go;
 $txt =~ s/(?<!>)\n/<br$AUBBC{html_type}>\n/go;
 $txt =~ s/&quot;/&#34;/go;
 if ($AUBBC{highlight}) {
  warn 'ENTER block highlight' if $DEBUG_AUBBC;
  $txt =~ s/\z/<br$AUBBC{html_type}>/o if $txt !~ m/<br$AUBBC{html_type}>\z/o;
  $txt =~ s/(&#60;&#60;(?:&#39;)?(\w+)(?:&#39;)?;(?s).*?\b\2\b)/<span$AUBBC{highlight_class1}>$1<\/span>/go;
  $txt =~ s/(?<![\&\$])(\#.*?(?:<br$AUBBC{html_type}>))/<span$AUBBC{highlight_class2}>$1<\/span>/go;
  $txt =~ s/(&#39;(?s).*?(?<!&#92;)&#39;)/<span$AUBBC{highlight_class3}>$1<\/span>/go;
  $txt =~ s/(&#34;(?s).*?(?<!&#92;)&#34;)/<span$AUBBC{highlight_class4}>$1<\/span>/go;
  $txt =~ s/(?<![\#|\w|\d])(\d+)(?!\w)/<span$AUBBC{highlight_class5}>$1<\/span>/go;
  $txt =~ s/\b(strict|package|return|require|for|my|sub|if|eq|ne|lt|ge|le|gt|or|xor|use|while|foreach|next|last|unless|elsif|else|not|and|until|continue|do|goto)\b/<span$AUBBC{highlight_class6}>$1<\/span>/go;
  $txt =~ s/(?<!&#92;)((?:&#37;|\$|\@)\w+(?:(?:&#91;.+?&#93;|&#123;.+?&#125;)+|))/<span$AUBBC{highlight_class7}>$1<\/span>/go;
 }
 return $txt;
}

sub do_ubbc {
 warn 'ENTER do_ubbc' if $DEBUG_AUBBC;
 $msg =~ s/\[(?:c|code)\](?s)(.+?)\[\/(?:c|code)\]/<div$AUBBC{code_class}><code>
${\$AUBBC{highlight_function}->($1)}
<\/code><\/div>$AUBBC{code_extra}
/go;
 $msg =~ s/\[(?:c|code)=(.+?)\](?s)(.+?)\[\/(?:c|code)\]/# $1:<br$AUBBC{html_type}><div$AUBBC{code_class}><code>
${\$AUBBC{highlight_function}->($2)}
<\/code><\/div>$AUBBC{code_extra}
/go;

 $msg =~ s/\[(img|right_img|left_img)\](.+?)\[\/img\]/${\fix_image($1, $2)}/go if ! $AUBBC{no_img};

 $msg =~ s/\[email\](?![\w\.\-\&\+]+\@[\w\.\-]+).+?\[\/email\]/\[<font color=red>$BAD_MESSAGE<\/font>\]email/go;
 ($AUBBC{protect_email})
  ? $msg =~ s/\[email\]([\w\.\-\&\+]+\@[\w\.\-]+)\[\/email\]/${\protect_email($1)}/go
  : $msg =~ s/\[email\]([\w\.\-\&\+]+\@[\w\.\-]+)\[\/email\]/<A href="mailto:$1"$AUBBC{href_class}>$1<\/a>/go;

 $msg =~ s/\[color=([\w#]+)\](?s)(.+?)\[\/color\]/<span style="color:$1;">$2<\/span>/go;
 $msg =~ s/\[quote=([\w\s]+)\]/<span$AUBBC{quote_class}><small><strong>$1:<\/strong><\/small><br$AUBBC{html_type}>/go;
 $msg =~ s/\[quote\]/<span$AUBBC{quote_class}>/go;
 $msg =~ s/\[\/quote\]/<\/span>$AUBBC{quote_extra}/go;
 $msg =~ s/\[(left|right|center)\](?s)(.+?)\[\/\1\]/<div style=\"text-align: $1;\">$2<\/div>/go;
 $msg =~ s/\[li=(\d+)\]/<li value="$1">/go;
 $msg =~ s/\[u\](?s)(.+?)\[\/u\]/<span style="text-decoration: underline;">$1<\/span>/go;
 $msg =~ s/\[strike\](?s)(.+?)\[\/strike\]/<span style="text-decoration: line-through;">$1<\/span>/go;
 $msg =~ s/\[([bh]r)\]/<$1$AUBBC{html_type}>/go;
 $msg =~ s/\[list\](?s)(.+?)\[\/list\]/${\fix_list($1)}/go;
 $msg =~ s/\[(\/?(?:big|h[123456]|[ou]l|li|em|pre|s(?:mall|trong|u[bp])|[bip]))\]/<$1>/go;
 $msg =~ s/(<\/?(?:ol|ul|li)>)\r?\n?<br(?:\s?\/)?>\r?\n?/$1\n/go;
 $msg =~ s/\[url=(\w+\:\/\/$long_regex)\](.+?)\[\/url\]/<a href="$1"$AUBBC{href_target}$AUBBC{href_class}>${\fix_message($2)}<\/a>/go;
 $msg =~ s/(?<!["=\.\/\'\[\{\;])((?:\b\w+\b\:\/\/)$long_regex)/<a href="$1"$AUBBC{href_target}$AUBBC{href_class}>$1<\/a>/go;
}

sub fix_list {
my $list = shift;
 if ($list =~ m/\[\*/o && $list =~ s/<br$AUBBC{html_type}>//go) {
 my $type = 'ul';
 $type = 'ol' if $list =~ s/\[\*=(\d+)\]/\[\*\]$1\|/go;
  my @clean = split('\[\*\]', $list);
  $list = "<$type>\n";
  foreach (@clean) {
   if ($_ && $_ =~ s/\A(\d+)\|(?s)(.+?)/$2/o) {
    $list .= "<li value=\"$1\">$_<\/li>\n" if $_ !~ m/\A\r?\n?\z/o;
   } elsif ($_ && $_ !~ m/\A(?:\s+|\d+\|\r?\n?)\z/o) {
    $list .= "<li>$_<\/li>\n";
    }
  }
  $list .= "<\/$type>";
 }
 return $list;
}

sub fix_image {
 my ($tmp2, $tmp) = @_;
 if ($tmp !~ m/\A(?:\w+:\/\/|\/)/o || $tmp =~ m/(?:\?|\#|\.\bjs\b\z)/io) {
  $tmp = "[<font color=red>$BAD_MESSAGE</font>]$tmp2";
 }
  else {
  $tmp2 = '' if $tmp2 eq 'img';
  $tmp2 = ' align="right"' if $tmp2 eq 'right_img';
  $tmp2 = ' align="left"' if $tmp2 eq 'left_img';

  $tmp = ($AUBBC{icon_image})
   ? "<a href=\"$tmp\"$AUBBC{href_target}$AUBBC{href_class}><img$tmp2 src=\"$tmp\" width=\"$AUBBC{image_width}\" height=\"$AUBBC{image_hight}\" alt=\"\" border=\"$AUBBC{image_border}\"$AUBBC{html_type}></a>$AUBBC{image_wrap}"
   : "<img$tmp2 src=\"$tmp\" alt=\"\" border=\"$AUBBC{image_border}\"$AUBBC{html_type}>$AUBBC{image_wrap}";
 }
 return $tmp;
}

sub protect_email {
 my $em = shift;
 my ($email1, $email2, $ran_num, $protect_email, @letters) = ('', '', '', '', split (//, $em));
 $protect_email = '[' if $AUBBC{protect_email} eq 3 || $AUBBC{protect_email} eq 4;
 foreach my $character (@letters) {
  if ($AUBBC{protect_email} eq 1 || $AUBBC{protect_email} eq 2) {
   $protect_email .= '&#' . ord($character) . ';';
  } elsif ($AUBBC{protect_email} eq 3) {
   $protect_email .= ord($character) . ',';
  } elsif ($AUBBC{protect_email} eq 4) {
   $ran_num = int(rand(64)) || 0;
   $protect_email .= '\'' . (ord($key64[$ran_num]) ^ ord($character)) . '\',\'' . $key64[$ran_num] . '\',';
  }
 }
 if ($AUBBC{protect_email} eq 1) {
  return "<a href=\"&#109;&#97;&#105;&#108;&#116;&#111;&#58;$protect_email\"$AUBBC{href_class}>$protect_email</a>";
 } elsif ($AUBBC{protect_email} eq 2) {
  ($email1, $email2) = split ("&#64;", $protect_email);
  $protect_email = "'$email1' + '&#64;' + '$email2'";
 } elsif ($AUBBC{protect_email} eq 3 || $AUBBC{protect_email} eq 4) {
  $protect_email =~ s/\,\z/]/o;
 }
 return <<JS if $AUBBC{protect_email} eq 2 || $AUBBC{protect_email} eq 3 || $AUBBC{protect_email} eq 4;
<a href="javascript:void(0)" onclick="javascript:MyEmCode('$AUBBC{protect_email}',$protect_email);"$AUBBC{href_class}>$AUBBC{email_message}</a>
JS
}

sub js_print {
my $self = shift;
print <<JS;
Content-type: text/javascript

/*
AUBBC v$VERSION
Fully supports dynamic view in XHTML.
*/
function MyEmCode (type, content) {
var returner = false;
if (type == 4) {
 var farray= new Array(content.length,1);
 for(farray[1];farray[1]<farray[0];farray[1]++) { returner+=String.fromCharCode(content[farray[1]].charCodeAt(0)^content[farray[1]-1]);farray[1]++; }
} else if (type == 3) {
 for (i = 0; i < content.length; i++) { returner+=String.fromCharCode(content[i]); }
} else if (type == 2) { returner=content; }
if (returner) { window.location='mailto:'+returner; }
}
JS
exit(0);
}

sub do_build_tag {
 warn 'ENTER do_build_tag' if $DEBUG_AUBBC;

 foreach (keys %Build_AUBBC) {
  warn 'ENTER foreach do_build_tag' if $DEBUG_AUBBC;
  $msg =~ s/(\[$_\:\/\/([$Build_AUBBC{$_}[0]]+)\])/
   my $ret = do_sub( $_, $2 , $Build_AUBBC{$_}[2] ) || '';
   $ret ? $ret : $1;
  /eg if ($Build_AUBBC{$_}[1] eq 1);

  $msg =~ s/(\[$_\](?s)([$Build_AUBBC{$_}[0]]+)\[\/$_\])/
   my $ret = do_sub( $_, $2 , $Build_AUBBC{$_}[2] ) || '';
   $ret ? $ret : $1;
  /eg if ($Build_AUBBC{$_}[1] eq 2);

  $msg =~ s/(\[$_\])/
   my $ret = do_sub( $_, '' , $Build_AUBBC{$_}[2] ) || '';
   $ret ? $ret : $1;
  /eg if ($Build_AUBBC{$_}[1] eq 3);

  $msg =~ s/\[$_\]/$Build_AUBBC{$_}[2]/g if ($Build_AUBBC{$_}[1] eq 4);
 }
}

sub do_sub {
 my ($key, $term, $fun) = @_;
 warn 'ENTER check_build_tag' if $DEBUG_AUBBC;
 $fun = \&{$fun};
 return $fun->($key, $term) || '';
}

sub check_subroutine {
 my $name = shift;
 $name = '' unless (defined $name && exists &{$name} && (ref $name eq 'CODE' || ref $name eq ''));
 return $name;
}

sub add_build_tag {
 my ($self,%NewTag) = @_;
 warn 'ENTER add_build_tag' if $DEBUG_AUBBC;
 if ($NewTag{type} ne 4) {
  my $is_ok = check_subroutine($NewTag{function}) || '';
  die "Usage: add_build_tag - function 'Undefined subroutine' => '$NewTag{function}'" if ! $is_ok;
 }
 $NewTag{pattern} = 'l' if ($NewTag{type} eq 3 || $NewTag{type} eq 4);
 if ($NewTag{name} =~ m/\A[\w\-]+\z/o && ($NewTag{pattern} =~ m/\A[lns_:\-,]+\z/o || $NewTag{pattern} eq 'all')) {
  if ($NewTag{name} && $NewTag{pattern} && $NewTag{type}) {
   if ($NewTag{pattern} eq 'all') {
    $NewTag{pattern} = '\w\:\s\/\.\;\&\=\?\-\+\#\%\~\,';
   }
    else {
    my ($p_ct,@pat_split) = ( 0, () );
    my %is_pat = ('l' => 'a-z', 'n' => '\d', '_' => '\_', ':' => '\:', 's' => '\s', '-' => '\-');
    @pat_split = split (/\,/, $NewTag{pattern});
    $NewTag{pattern} = '';
    foreach (@pat_split) {
     last if $p_ct == 6;
     $p_ct++;
     $NewTag{pattern} .= $is_pat{$_} if exists $is_pat{$_};
    }
   }
   $Build_AUBBC{$NewTag{name}} = [$NewTag{pattern}, $NewTag{type}, $NewTag{function}];
   $do_flag[5] = 1 if !$do_flag[5];
  }
  warn 'Added Build_AUBBC Tag '.$Build_AUBBC{$NewTag{name}} if $DEBUG_AUBBC && $Build_AUBBC{$NewTag{name}};
 }
  else {
   die 'Usage: add_build_tag - Bad name or pattern format';
 }
}

sub remove_build_tag {
 my ($self,$name,$type) = @_;
 warn 'ENTER remove_build_tag' if $DEBUG_AUBBC;
 delete $Build_AUBBC{$name} if exists $Build_AUBBC{$name} && !$type; # clear one
 %Build_AUBBC = () if $type && !$name; # clear all
}

sub do_unicode{
 warn 'ENTER do_unicode' if $DEBUG_AUBBC;
 $msg =~ s/\[utf:\/\/(\#?[\d\w]+)\]/&$1;/go;
 $msg =~ s/&amp;(\#?[\d\w]+);/&$1;/go;
}

sub do_smileys {
warn 'ENTER do_smileys' if $DEBUG_AUBBC;
$msg =~ s/\[$_\]/<img src="$AUBBC{images_url}\/smilies\/$SMILEYS{$_}" alt="$_" border="$AUBBC{image_border}"$AUBBC{html_type}>$AUBBC{image_wrap}/g foreach (keys %SMILEYS);
}

sub smiley_hash {
 my ($self,%s_hash) = @_;
 warn 'ENTER smiley_hash' if $DEBUG_AUBBC;
 if (keys %s_hash) {
 %SMILEYS = %s_hash;
 $do_flag[6] = 1;
 }
}

sub do_all_ubbc {
 my ($self,$message) = @_;
 warn 'ENTER do_all_ubbc' if $DEBUG_AUBBC;
 $msg = (defined $message) ? $message : '';
 if ($msg) {
  $msg = $self->script_escape($msg,'') if $AUBBC{script_escape};
  $msg =~ s/&(?!\#?[\d\w]+;)/&amp;/go if $AUBBC{fix_amp};
  if (!$AUBBC{no_bypass} && $msg =~ m/\A\#no/o) {
   $do_flag[4] = 0 if $msg =~ s/\A\#none//o;
   if ($do_flag[4]) {
   $do_flag[0] = 0 if $msg =~ s/\A\#noubbc//o;
   $do_flag[1] = 0 if $msg =~ s/\A\#nobuild//o;
   $do_flag[2] = 0 if $msg =~ s/\A\#noutf//o;
   $do_flag[3] = 0 if $msg =~ s/\A\#nosmileys//o;
   }
   warn 'START no_bypass' if $DEBUG_AUBBC && !$do_flag[4];
  }
  if ($do_flag[4]) {
   escape_aubbc($msg) if $AUBBC{aubbc_escape};
   if (!$AUBBC{for_links}) {
    do_ubbc($msg) if $do_flag[0] && $AUBBC{aubbc};
    do_build_tag($msg) if $do_flag[5] && $do_flag[1];
   }
   do_unicode($msg) if $do_flag[2] && $AUBBC{utf};
   do_smileys($msg) if $do_flag[6] && $do_flag[3] && $AUBBC{smileys};
  }
 }
 return $msg;
}

sub fix_message {
 my $txt = shift;
 $txt =~ s/\./&#46;/go;
 $txt =~ s/\:/&#58;/go;
 return $txt;
}
sub escape_aubbc {
 warn 'ENTER escape_aubbc' if $DEBUG_AUBBC;
 $msg =~ s/\[\[/&#91;/go;
 $msg =~ s/\]\]/&#93;/go;
}

sub script_escape {
 my ($self, $text, $option) = @_;
 warn 'ENTER html_escape' if $DEBUG_AUBBC;
 $text = '' unless defined $text;
 if ($text) {
  if (!$option) {
  $text =~ s/&/&amp;/go;
  $text =~ s/\t/ \&nbsp; \&nbsp; \&nbsp;/go;
  $text =~ s/  / \&nbsp;/go;
  }
  $text =~ s/"/&#34;/go;
  $text =~ s/</&#60;/go;
  $text =~ s/>/&#62;/go;
  $text =~ s/'/&#39;/go;
  $text =~ s/\)/&#41;/go;
  $text =~ s/\(/&#40;/go;
  $text =~ s/\\/&#92;/go;
  $text =~ s/\|/&#124;/go;
  (!$option && $AUBBC{line_break} eq 2)
   ? $text =~ s/\n/<br$AUBBC{html_type}>/go
   : $text =~ s/\n/<br$AUBBC{html_type}>\n/go if !$option && $AUBBC{line_break} eq 1;
 }
 return $text;
}

sub html_to_text {
 my ($self, $html, $option) = @_;
 warn 'ENTER html_to_text' if $DEBUG_AUBBC;
 $html = '' unless defined $html;
 if ($html) {
  if (!$option) {
  $html =~ s/&amp;/&/go;
  $html =~ s/ \&nbsp; \&nbsp; \&nbsp;/\t/go;
  $html =~ s/ \&nbsp;/  /go;
  }
  $html =~ s/&#34;/"/go;
  $html =~ s/&#60;/</go;
  $html =~ s/&#62;/>/go;
  $html =~ s/&#39;/'/go;
  $html =~ s/&#41;/\)/go;
  $html =~ s/&#40;/\(/go;
  $html =~ s/&#92;/\\/go;
  $html =~ s/&#124;/\|/go;
  $html =~ s/<br(?:\s?\/)?>\n?/\n/go if $AUBBC{line_break};
 }
 return $html;
}

sub version {
 my $self = shift;
 return $VERSION;
}

1;

__END__

=pod

=head1 COPYLEFT

AUBBC.pm, v3.13 09/30/2010 By: N.K.A.

Advanced Universal Bulletin Board Code a Perl BBcode API

shakaflex@gmail.com
http://search.cpan.org/~sflex/

Note: This code has a lot of settings and works good
with most default settings see the POD and example files
in the archive for usage.

=cut
