package AUBBC;

=head1 COPYLEFT

AUBBC.pm, v2.10 09/03/2010 By: N.K.A.

Advanced Universal Bulletin Board Code a Perl BBcode API

shakaflex@gmail.com
http://search.cpan.org/~sflex/

Note: This code has a lot of settings and works good
with most default settings see the POD and example files
in the archive for usage

=cut

use strict;
use warnings;

our ( $DEBUG_AUBBC, $BAD_MESSAGE, %SMILEYS ) = ( '', 'Error', () );

my ( $VERSION, %Build_AUBBC ) = ( '2.10', () );

my %AUBBC = (
aubbc => 1,
utf => 1,
smileys => 1,
highlight => 1,
no_bypass => 0,
for_links => 0,
aubbc_escape => 1,
no_img => 0,
icon_image => 1,
image_hight => 60,
image_width => 90,
image_border => 0,
image_wrap => 1,
href_target => 0,
images_url => '',
html_type => 'html',
fix_amp => 1,
line_break => 1,
code_class => '',
code_extra => '',
href_class => '',
quote_class => '',
quote_extra => '',
script_escape => 1,
protect_email => 1,
email_message => '&#67;&#111;&#110;&#116;&#97;&#99;&#116;&#32;&#69;&#109;&#97;&#105;&#108;',
highlight_class1 => '',
highlight_class2 => '',
highlight_class3 => '',
highlight_class4 => '',
highlight_class5 => '',
highlight_class6 => '',
highlight_class7 => '',
);

sub new {
warn "ENTER new" if $DEBUG_AUBBC;

settings_prep();

my $self = {};
bless $self;

if ($DEBUG_AUBBC) {
 warn "CREATING $self";
 my $uabbc_settings = '';
 foreach (keys %AUBBC) {
  $uabbc_settings .= $_ . ' =>' . $AUBBC{$_} . ', ';
  }
 warn "AUBBC Settings: $uabbc_settings";
 warn "END new";
 }

return $self;
}

sub DESTROY {
if ($DEBUG_AUBBC) {
 my $self = shift;
 warn "DESTROY $self";
 }
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
  $AUBBC{$_} = $s_hash{$_} if exists $AUBBC{$_};
 }
}

settings_prep();

if ($DEBUG_AUBBC) {
 my $uabbc_settings = '';
 foreach (keys %AUBBC) {
  $uabbc_settings .= $_ . ' =>' . $AUBBC{$_} . ', ';
  }
 warn "AUBBC Settings Change: $uabbc_settings";
 }

}

sub get_setting {
my ($self,$name) = @_;
return $AUBBC{$name} if exists $AUBBC{$name};
}

sub code_highlight {
my $text_code = shift;
warn "START code_highlight" if $DEBUG_AUBBC;
$text_code =~ s{:}{&#58;}go;
$text_code =~ s{\[}{&#91;}go;
$text_code =~ s{\]}{&#93;}go;
$text_code =~ s{\{}{&#123;}go;
$text_code =~ s{\}}{&#125;}go;
$text_code =~ s{%}{&#37;}go;
$text_code =~ s{\s{1};}{ &#59;}go;
$text_code =~ s{&lt;}{&#60;}go;
$text_code =~ s{&gt;}{&#62;}go;
$text_code =~ s{&quot;}{&#34;}go;
if ($AUBBC{highlight}) {
 warn "START block highlight" if $DEBUG_AUBBC;
 $text_code =~ s{\z}{<br$AUBBC{html_type}>}go if $text_code !~ m/<br$AUBBC{html_type}>\z/io;
 $text_code =~ s{(&#60;&#60;(\w+);(?s).*?\b\2\b)}{<span$AUBBC{highlight_class1}>$1</span>}go;
 $text_code =~ s{(?<![\&\$])(\#.*?(?:<br$AUBBC{html_type}>))}{<span$AUBBC{highlight_class2}>$1</span>}igo;
 $text_code =~ s{(&#39;(?s).*?(?<!&#92;)&#39;)}{<span$AUBBC{highlight_class3}>$1</span>}go;
 $text_code =~ s{(&#34;(?s).*?(?<!&#92;)&#34;)}{<span$AUBBC{highlight_class4}>$1</span>}go;
 $text_code =~ s{(?<![\#|\w|\d])(\d+)(?!\w)}{<span$AUBBC{highlight_class5}>$1</span>}go;
 $text_code =~ s{\b(strict|package|return|require|for|my|sub|if|eq|ne|lt|ge|le|gt|or|xor|use|while|foreach|next|last|unless|elsif|else|not|and|until|continue|do|goto)\b}{<span$AUBBC{highlight_class6}>$1</span>}go;
 $text_code =~ s{(?<!&#92;)((?:&#37;|\$|\@)\w+(?:(?:&#91;.+?&#93;|&#123;.+?&#125;)+|))}{<span$AUBBC{highlight_class7}>$1</span>}go;
 warn "END block highlight" if $DEBUG_AUBBC;
 }
warn "END code_highlight" if $DEBUG_AUBBC;
return $text_code;
}

sub do_ubbc {
my ($self,$message) = @_;
warn "ENTER do_ubbc $self" if $DEBUG_AUBBC;

# Code post support
# [c]...[/c] or [code]...[/code]
$message =~ s{\[(?:c|code)\](?s)(.+?)\[/(?:c|code)\]} {
<div$AUBBC{code_class}><code>
${\code_highlight($1)}
</code></div>$AUBBC{code_extra}
}isg;
# [code=...]...[/code] or [c=...]...[/c]
$message =~ s{\[(?:c|code)=(.+?)\](?s)(.+?)\[/(?:c|code)\]} {
# $1:<br$AUBBC{html_type}><div$AUBBC{code_class}><code>
${\code_highlight($2)}
</code></div>$AUBBC{code_extra}
}isg;

# Images
if (!$AUBBC{no_img}) {
while ($message =~ s{\[(img|right_img|left_img)\](.+?)\[/img\]} {
 my $tmp = $2;
 my $tmp2 = $1;
 if ($tmp !~ m/\A\w+:\/\/|\//i || $tmp =~ m/\?|\#|\.\bjs\b/i) {
  $tmp = "[<font color=red>$BAD_MESSAGE</font>]$tmp2";
 }
  else {
   if ($AUBBC{icon_image}) {
    if($tmp2 eq 'img') { $tmp = "<a href=\"$tmp\"$AUBBC{href_target}$AUBBC{href_class}><img src=\"$tmp\" width=\"$AUBBC{image_width}\" height=\"$AUBBC{image_hight}\" alt=\"\" border=\"$AUBBC{image_border}\"$AUBBC{html_type}></a>$AUBBC{image_wrap}"; }
    elsif($tmp2 eq 'right_img') { $tmp = "<a href=\"$tmp\"$AUBBC{href_target}$AUBBC{href_class}><img align=\"right\" src=\"$tmp\" border=\"$AUBBC{image_border}\" width=\"$AUBBC{image_width}\" height=\"$AUBBC{image_hight}\" alt=\"\"$AUBBC{html_type}></a>$AUBBC{image_wrap}"; }
    elsif($tmp2 eq 'left_img') { $tmp = "<a href=\"$tmp\"$AUBBC{href_target}$AUBBC{href_class}><img align=\"left\" src=\"$tmp\" border=\"$AUBBC{image_border}\" width=\"$AUBBC{image_width}\" height=\"$AUBBC{image_hight}\" alt=\"\"$AUBBC{html_type}></a>$AUBBC{image_wrap}"; }
   }
    else {
     if($tmp2 eq 'img') { $tmp = "<img src=\"$tmp\" alt=\"\" border=\"$AUBBC{image_border}\"$AUBBC{html_type}>$AUBBC{image_wrap}"; }
     elsif($tmp2 eq 'right_img') { $tmp = "<img align=\"right\" src=\"$tmp\" border=\"$AUBBC{image_border}\" alt=\"\"$AUBBC{html_type}>$AUBBC{image_wrap}"; }
     elsif($tmp2 eq 'left_img') { $tmp = "<img align=\"left\" src=\"$tmp\" border=\"$AUBBC{image_border}\" alt=\"\"$AUBBC{html_type}>$AUBBC{image_wrap}"; }
   }
  }
 }exisog) {}
}

# Email error
$message =~ s{\[email\](?![\w\.\-\&\+]+\@[\w\.\-]+).+?\[/email\]}{\[<font color=red>$BAD_MESSAGE<\/font>\]email}isgo;
if ($AUBBC{protect_email}) {
# Protect email address.
 $message =~ s/\[email\]([\w\.\-\&\+]+\@[\w\.\-]+)\[\/email\]/
  $self->protect_email($1, $AUBBC{protect_email});
  /exig;
}
 else {
# Standard email
 $message =~ s{\[email\]([\w\.\-\&\+]+\@[\w\.\-]+)\[/email\]}{<A href="mailto:$1"$AUBBC{href_class}>$1</a>}isgo;
 }

$message =~ s{\[color=([\w#]+)\](.*?)\[/color\]}{<span style="color:$1;">$2</span>}isgo;

$message =~ s{\[quote=([\w\s]+)\]}{<span$AUBBC{quote_class}><small><strong>$1:</strong></small><br$AUBBC{html_type}>}isgo;
$message =~ s{\[/quote\]}{</span>$AUBBC{quote_extra}}isgo;
$message =~ s{\[quote\]}{<span$AUBBC{quote_class}>}isgo;

$message =~ s{\[(left|right|center)\]}{<div style=\"text-align: $1;\">}isgo;
$message =~ s{\[\/(?:left|right|center)\]}{</div>}isgo;
$message =~ s{\[li=(\d+)\]}{<li value="$1">}isgo;
$message =~ s{\[u\](.*?)\[/u\]}{<span style="text-decoration: underline;">$1</span>}isgo;
$message =~ s{\[strike\](.*?)\[/strike\]}{<span style="text-decoration: line-through;">$1</span>}isgo;

# 1 = <1>...</1>, 2 = <2>
my %AUBBC_TAGS =('b' => 1,'br' => 2,'hr' => 2,'i' => 1,'sub' => 1,'sup' => 1,'pre' => 1,
'ul' => 1, 'ol' => 1, 'small' => 1, 'big' => 1, 'li' => 1, 'p' => 1, 'h1' => 1, 'h2' => 1, 'h3' => 1, 'h4' => 1, 'h5' => 1,
'h6' => 1, 'div' => 1, 'strong' => 1,);
foreach my $a_key (keys %AUBBC_TAGS) {
 if ($AUBBC_TAGS{$a_key} eq 1) {
  $message =~ s{\[$a_key\]}{<$a_key>}isg;
  $message =~ s{\[\/$a_key\]}{<\/$a_key>}isg;
 }
  elsif ($AUBBC_TAGS{$a_key} eq 2) {
  $message =~ s{\[$a_key\]}{<$a_key$AUBBC{html_type}>}isg;
 }
}

my $long_regex = '[\w\.\/\-\~\@\:\;\=]+(?:\?[\w\~\.\;\:\,\$\-\+\!\*\?/\=\&\@\#\%]+?)?';
while ($message =~ s{\[url=(\w+\://$long_regex)\](.+?)\[/url\]} {
 my $tmp = $2;
 my $tmp2 = $1;
 $tmp =~ s/\./&#46;/gs;
 $tmp =~ s/\:/&#58;/gs;
 $tmp = "<a href=\"$tmp2\"$AUBBC{href_target}$AUBBC{href_class}>$tmp</a>";
}exisog) {}

$message =~
 s{(?<!["=\./\'\[\{\;])((?:\b\w+\b\://)$long_regex)}{<a href="$1"$AUBBC{href_target}$AUBBC{href_class}>$1</a>}isgo;

warn "END do_ubbc $self" if $DEBUG_AUBBC;
return $message;
}

sub protect_email {
my ($self, $email, $option) = @_;
my @key64 = ('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/');
my ($email1, $email2, $ran_num, $protect_email, @letters) =
('', '', '', '', split (//, $email));
   $protect_email = '[' if $option eq 3 || $option eq 4;
 foreach my $character (@letters) {
          $protect_email .= '&#' . ord($character) . ';' if ($option eq 1 || $option eq 2);
          $protect_email .= ord($character) . ',' if $option eq 3;
          $ran_num = int(rand(64)) || 0 if $option eq 4;
          $protect_email .= '\'' . (ord($key64[$ran_num]) ^ ord($character)) . '\',\'' . $key64[$ran_num] . '\',' if $option eq 4;
 }
  return "<a href=\"&#109;&#97;&#105;&#108;&#116;&#111;&#58;$protect_email\"$AUBBC{href_class}>$protect_email</a>" if $option eq 1;

 ($email1, $email2) = split ("&#64;", $protect_email) if $option eq 2;
 $protect_email = "'$email1' + '&#64;' + '$email2'" if $option eq 2;
 $protect_email =~ s/\,\z/]/g if $option eq 3 || $option eq 4;
        return <<JS if $option eq 2 || $option eq 3 || $option eq 4;
<a href="javascript:MyEmCode('$option',$protect_email);"$AUBBC{href_class}>$AUBBC{email_message}</a>
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
    for(farray[1];farray[1]<farray[0];farray[1]++) {
        returner+=String.fromCharCode(content[farray[1]].charCodeAt(0)^content[farray[1]-1]);farray[1]++;
    }
} else if (type == 3) {
  for (i = 0; i < content.length; i++) { returner+=String.fromCharCode(content[i]); }
 } else if (type == 2) { returner=content; }
 if (returner) { window.location='mailto:'+returner; }
}
JS
exit(0);
}

sub do_build_tag {
my ($self,$message) = @_;

if ($DEBUG_AUBBC) {
warn "ENTER do_build_tag $self";
my $uabbc_settings = '';
foreach (keys %Build_AUBBC) {
        $uabbc_settings .= $_ . ' =>' . $Build_AUBBC{$_} . ', ';
         }
warn "Build tags $uabbc_settings";
}

foreach (keys %Build_AUBBC) {
        warn "ENTER foreach do_build_tag $self" if $DEBUG_AUBBC;
        $message =~ s/(\[$_\:\/\/([$Build_AUBBC{$_}[0]]+)\])/
         my $ret = $self->do_sub( $_, $2 , $Build_AUBBC{$_}[2] ) || '';
         $ret ? $ret : $1;
        /exig if ($Build_AUBBC{$_}[1] eq 1);

        $message =~ s/(\[$_\](?s)([$Build_AUBBC{$_}[0]]+)\[\/$_\])/
         my $ret = $self->do_sub( $_, $2 , $Build_AUBBC{$_}[2] ) || '';
         $ret ? $ret : $1;
        /exig if ($Build_AUBBC{$_}[1] eq 2);

        $message =~ s/(\[$_\])/
         my $ret = $self->do_sub( $_, '' , $Build_AUBBC{$_}[2] ) || '';
         $ret ? $ret : $1;
        /exig if ($Build_AUBBC{$_}[1] eq 3);

        $message =~ s/\[$_\]/$Build_AUBBC{$_}[2]/isg if ($Build_AUBBC{$_}[1] eq 4);

        }
warn "END do_build_tag $self" if $DEBUG_AUBBC;
return $message;
}

sub do_sub {
my ($self, $key, $term, $fun) = @_;
warn "ENTER check_build_tag" if $DEBUG_AUBBC;
$fun = \&{$fun};
warn "END check_build_tag" if $DEBUG_AUBBC;
return $fun->($key, $term) || '';
}

sub add_build_tag {
my ($self,%NewTag) = @_;
warn "ENTER add_build_tag $self" if $DEBUG_AUBBC;

if ($NewTag{type} ne 4) {
 unless (exists $NewTag{function} && exists &{$NewTag{function}}
  && (ref $NewTag{function} eq 'CODE' || ref $NewTag{function} eq '')) {
  die "Usage: add_build_tag - function 'Undefined subroutine' => '$NewTag{function}'";
 }
}
$NewTag{pattern} = 'l' if ($NewTag{type} eq 3 || $NewTag{type} eq 4);

if ($NewTag{name} =~ m/\A[\w\-]+\z/i
 && ($NewTag{pattern} =~ m/\A[lns_:\-,]+\z/i || $NewTag{pattern} eq 'all')) {
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
 }
 warn "Added Build_AUBBC Tag ".$Build_AUBBC{$NewTag{name}} if $DEBUG_AUBBC && $Build_AUBBC{$NewTag{name}};
}
 else {
  die "Usage: add_build_tag - Bad name or pattern format";
}
warn "END add_build_tag $self" if $DEBUG_AUBBC;
}

sub remove_build_tag {
my ($self,$name,$type) = @_;
warn "ENTER remove_build_tag $self" if $DEBUG_AUBBC;
delete $Build_AUBBC{$name} if exists $Build_AUBBC{$name} && !$type; # clear one
%Build_AUBBC = () if $type && !$name; # clear all
warn "END remove_build_tag $self" if $DEBUG_AUBBC;
}

sub do_unicode {
my ($self,$message) = @_;
warn "ENTER do_unicode $self" if $DEBUG_AUBBC;
# tag for them all [utf://x23]
$message =~ s{\[utf://(\#?[0-9a-z]+)\]}{&$1;}igso;
# &#x23; or &#0931; or code names
$message =~ s{&amp;(\#?[0-9a-z]+);}{&$1;}igso;
warn "END do_unicode $self" if $DEBUG_AUBBC;
return $message;
}

sub do_smileys {
my ($self,$message) = @_;
warn "ENTER do_smileys $self" if $DEBUG_AUBBC;
# Make the smilies.
foreach (keys %SMILEYS) {
 $message =~ s{\[$_\]}{<img src="$AUBBC{images_url}/smilies/$SMILEYS{$_}" alt="$_" border="$AUBBC{image_border}"$AUBBC{html_type}>$AUBBC{image_wrap}}isg if $_ && exists $SMILEYS{$_};
 }
warn "END do_smileys $self" if $DEBUG_AUBBC;
return $message;
}

sub smiley_hash {
my ($self,%s_hash) = @_;
warn "ENTER smiley_hash $self" if $DEBUG_AUBBC;
%SMILEYS = %s_hash;
$AUBBC{smileys} = ($AUBBC{smileys} && %SMILEYS && $AUBBC{images_url} =~ m/\A\w+:\/\//) ? '1' : '';
warn "END smiley_hash $self" if $DEBUG_AUBBC;
}

sub do_all_ubbc {
my ($self,$message) = @_;
warn "ENTER do_all_ubbc $self" if $DEBUG_AUBBC;
$message = '' unless defined $message && $message;
$message = $self->script_escape($message) if $AUBBC{script_escape} && $message;
$message =~ s{&(?!\#?[0-9a-z]+;)}{&amp;}gsio if $AUBBC{fix_amp} && $message;
if ($message && !$AUBBC{no_bypass} && $message =~ s/\A\#none//go) {
 warn "START&END no_bypass $self" if $DEBUG_AUBBC;
}
 elsif ($message) {
    $message = $self->escape_aubbc($message) if $AUBBC{aubbc_escape};
    $message = (!$AUBBC{no_bypass} && $message =~ s/\A\#noubbc//go)
        ? $message
        : $self->do_ubbc($message) if !$AUBBC{for_links} && $AUBBC{aubbc};

    $message = (!$AUBBC{no_bypass} && $message =~ s/\A\#nobuild//go)
        ? $message
        : $self->do_build_tag($message) if !$AUBBC{for_links} && keys %Build_AUBBC;

    $message = (!$AUBBC{no_bypass} && $message =~ s/\A\#noutf//go)
        ? $message
        : $self->do_unicode($message) if $AUBBC{utf};

    $message = (!$AUBBC{no_bypass} && $message =~ s/\A\#nosmileys//go)
        ? $message
        : $self->do_smileys($message) if $AUBBC{smileys};
    }
 warn "END do_all_ubbc $self" if $DEBUG_AUBBC;
 return $message;
}

sub escape_aubbc {
my ($self, $message) = @_;
warn "ENTER escape_aubbc $self" if $DEBUG_AUBBC;
$message =~ s{\[\[}{\&#91;}go;
$message =~ s{\]\]}{\&#93;}go;
warn "END escape_aubbc $self" if $DEBUG_AUBBC;
return $message;
}

sub script_escape {
my ($self, $text, $option) = @_;
warn "ENTER html_escape $self" if $DEBUG_AUBBC;
return '' unless defined $text && $text;
     if (!$option) {
        $text =~ s{&}{&amp;}gsio;
        $text =~ s{\t}{ \&nbsp; \&nbsp; \&nbsp;}gso;
        $text =~ s{  }{ \&nbsp;}gso;
        }
     if ($option || !$option) {
        $text =~ s{"}{&#34;}gso;
        $text =~ s{<}{&#60;}gso;
        $text =~ s{>}{&#62;}gso;
        $text =~ s{'}{&#39;}gso;
        $text =~ s{\)}{&#41;}gso;
        $text =~ s{\(}{&#40;}gso;
        $text =~ s{\\}{&#92;}gso;
        $text =~ s{\|}{&#124;}gso;
        }
        $text =~ s{\n}{<br$AUBBC{html_type}>}gso if !$option && $AUBBC{line_break};
warn "END html_escape $self" if $DEBUG_AUBBC;
        return $text;
}

sub html_to_text {
my ($self, $html, $option) = @_;
warn "ENTER html_to_text $self" if $DEBUG_AUBBC;
return '' unless defined $html && $html;
     if (!$option) {
        $html =~ s{&amp;}{&}gso;
        $html =~ s{ \&nbsp; \&nbsp; \&nbsp;}{\t}gso;
        $html =~ s{ \&nbsp;}{  }gso;
        }
     if ($option || !$option) {
        $html =~ s{&#34;}{"}gso;
        $html =~ s{&#60;}{<}gso;
        $html =~ s{&#62;}{>}gso;
        $html =~ s{&#39;}{'}gso;
        $html =~ s{&#41;}{\)}gso;
        $html =~ s{&#40;}{\(}gso;
        $html =~ s{&#92;}{\\}gso;
        $html =~ s{&#124;}{\|}gso;
        }
        $html =~ s{<br(?:\s\/)?>}{\n}gso if !$option && $AUBBC{line_break};
warn "END html_to_text $self" if $DEBUG_AUBBC;
        return $html;
}

sub version {
my ($self) = @_;
return $VERSION;
}

1;

