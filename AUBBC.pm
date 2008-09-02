package AUBBC;
=head1 COPYLEFT

 AUBBC.pm, v1.10 09/02/2008 09:49:46 By: N.K.A

 Advanced Universal Bulletin Board Code Tags.

 sflex@cpan.org
 http://search.cpan.org/~sflex/

=cut
use strict;
use warnings;

our ( $DEBUG_AUBBC, $BAD_MESSAGE, %SMILEYS ) = ( '', 'Error', () );

my ( $AUBBC_VERSION, %Build_AUBBC ) = ( '1.10', () );

my %AUBBC = (
aubbc => 1,
utf => 1,
smileys => 1,
highlight => 1,
no_bypass => 0,
for_links => 0,
aubbc_escape => 1,
icon_image => 1,
image_hight => 60,
image_width => 90,
image_border => 0,
image_wrap => 1,
href_target => 0,
images_url => '',
html_type => 'html',
code_class => '',
code_extra => '',
href_class => '',
quote_class => '',
quote_extra => '',
bad_pattern => 'view\-source:|script:|mocha:|mailto:|about:|shell:|\.js',
script_escape => 1,
protect_email => 1,
);

sub new {
warn "ENTER new" if $DEBUG_AUBBC;

 settings_prep();

	my $self = {};
	bless $self;

    if ($DEBUG_AUBBC) {
         warn "CREATING $self";
         my $uabbc_settings = '';
         foreach my $set_key (keys %AUBBC) {
                 $uabbc_settings .= $set_key . ' =>' . $AUBBC{$set_key} . ', ';
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
$AUBBC{html_type} = ($AUBBC{html_type} eq 'xhtml') ? ' /' : '';
}

sub settings {
my ($self,%s_hash) = @_;

     foreach my $key_name (keys %s_hash) {
             $AUBBC{$key_name} = $s_hash{$key_name} if exists $AUBBC{$key_name};
     }

     settings_prep();

 if ($DEBUG_AUBBC) {
 my $uabbc_settings = '';
         foreach my $set_key (keys %AUBBC) {
                 $uabbc_settings .= $set_key . ' =>' . $AUBBC{$set_key} . ', ';
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
    $text_code =~ s~<br>~=br=~gso;
    $text_code =~ s!:!&#58;!go;
    $text_code =~ s!\[!&#91;!go;
    $text_code =~ s!\]!&#93;!go;
    $text_code =~ s!\{!&#123;!go;
    $text_code =~ s!\}!&#125;!go;
    $text_code =~ s!%!&#37;!go;
    $text_code =~ s!\s{1};!&#59;!go; # ;
    $text_code =~ s{&lt;}{&#60;}go;
    $text_code =~ s{&gt;}{&#62;}go;
    $text_code =~ s{&quot;}{&#34;}go;
if ($AUBBC{highlight}) {
    warn "START block highlight" if $DEBUG_AUBBC;
    $text_code =~ s{\z}{=br=}go if $text_code !~ m/=br=\z/io; # fix
    $text_code =~ s!(&#60;&#60;(\w+);.*?\b\2\b)!<font color=DarkRed>$1</font>!go;
    $text_code =~ s{(?<![\&\$])(\#.*?(?:=br=))}{<font color='#0000FF'><i>$1</i></font>}igo;
    $text_code =~ s{(&#39;.*?(?:&#39;|=br=))}{<font color='#8B0000'>$1</font>}go;
    $text_code =~ s{(&#34;.*?(?:&#34;|=br=))}{<font color='#8B0000'>$1</font>}go;
    $text_code =~ s{(?<![\#|\w|\d])(\d+)(?!\w)}{<font color='#008000'>$1</font>}go;
    $text_code =~ s!\b(strict|package|return|require|for|my|sub|if|eq|ne|lt|ge|le|gt|or|use|while|foreach|next|last|unless|elsif|else|not|and|until|continue|do|goto)\b!<b>$1</b>!go;
    warn "END block highlight" if $DEBUG_AUBBC;
    }
    $text_code =~ s~=br=~<br>~gso;
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
         $1:<br>
          <div$AUBBC{code_class}><code>
          ${\code_highlight($2)}
          </code></div>$AUBBC{code_extra}
          }isg;

        # Images
        while ($message =~ s{\[(img|right_img|left_img)\](.+?)\[/img\]} {
                        my $tmp = $2;
                        my $tmp2 = $1;
                          if ($tmp =~ m!($AUBBC{bad_pattern})!i || $tmp =~ m!#!i) {
                               $tmp = qq(\[<font color=red>$BAD_MESSAGE<\/font>\]$tmp2);
                          }
                          else {
                               if ($AUBBC{icon_image}) {
                                    if($tmp2 eq 'img') { $tmp = qq(<img src="$tmp" width="$AUBBC{image_width}" height="$AUBBC{image_hight}" alt="" border="$AUBBC{image_border}"$AUBBC{html_type}>$AUBBC{image_wrap}); }
                                    elsif($tmp2 eq 'right_img') { $tmp = qq(<img align="right" hspace="5" src="$tmp" border="$AUBBC{image_border}" width="$AUBBC{image_width}" height="$AUBBC{image_hight}" alt=""$AUBBC{html_type}>$AUBBC{image_wrap}); }
                                    elsif($tmp2 eq 'left_img') { $tmp = qq(<img align="left" hspace="5" src="$tmp" border="$AUBBC{image_border}" width="$AUBBC{image_width}" height="$AUBBC{image_hight}" alt=""$AUBBC{html_type}>$AUBBC{image_wrap}); }
                                  }
                                   else {
                                    if($tmp2 eq 'img') { $tmp = qq(<img src="$tmp" alt="" border="$AUBBC{image_border}"$AUBBC{html_type}>$AUBBC{image_wrap}); }
                                    elsif($tmp2 eq 'right_img') { $tmp = qq(<img align="right" hspace="5" src="$tmp" border="$AUBBC{image_border}" alt=""$AUBBC{html_type}>$AUBBC{image_wrap}); }
                                    elsif($tmp2 eq 'left_img') { $tmp = qq(<img align="left" hspace="5" src="$tmp" border="$AUBBC{image_border}" alt=""$AUBBC{html_type}>$AUBBC{image_wrap}); }
                                   }
                          }
                }exisog) {}

        # Email
        #$message =~ s~\[email\]($AUBBC{bad_pattern})\[/email\]~\[<font color=red>$BAD_MESSAGE<\/font>\]email~isgo;
        $message =~ s~\[email\](?!([a-z\d\.\-\_\&]+)\@([a-zA-Z\d\.\-\_]+)).+?\[/email\]~\[<font color=red>$BAD_MESSAGE<\/font>\]email~isgo;
        if ($AUBBC{protect_email}) {
        # Protect email address.
        $message =~ s/\[email\]([a-z\d\.\-\_\&]+\@[a-zA-Z\d\.\-\_]+)\[\/email\]/
        my $protect_email = protect_email($1, $AUBBC{protect_email});
        $protect_email
        /exig;
        }
         else {
         # Standard
                $message =~ s~\[email\]([a-z\d\.\-\_]+\@[a-zA-Z\d\.\-\_]+)\[/email\]~<A href="mailto:$1"$AUBBC{href_class}>$1</a>~isgo;
              }

        $message =~ s~\[color=([\w#]+)\](.*?)\[/color\]~<font color='$1'>$2</font>~isgo;
        $message =~ s~\[quote=([\w\s]+)\]~<span$AUBBC{quote_class}><small><b><u>$1:</u></b></small><br>~isgo;
        $message =~ s~\[/quote\]~</span>$AUBBC{quote_extra}~isgo;
        $message =~ s~\[quote\]~<span$AUBBC{quote_class}>~isgo;
        $message =~ s~\[right\]~<div align=\"right\">~isgo;
        $message =~ s~\[\/right\]~</div>~isgo;
        $message =~ s~\[left\]~<div align=\"left\">~isgo;
        $message =~ s~\[\/left\]~</div>~isgo;

        $message =~ s~\[li\]~<li>~isgo;
        $message =~ s~\[li=(\d+)\]~<li value="$1">~isgo;
        $message =~ s~\[/li\]~</li>~isgo;

        # 1 = <1>...</1>, 2 = <2>
        my %AUBBC_TAGS =('b' => 1,'br' => 2,'hr' => 2,'i' => 1,'sub' => 1,'sup' => 1,'pre' => 1,'u' => 1,'strike' => 1,'center' => 1,
        'ul' => 1, 'ol' => 1, 'small' => 1, 'big' => 1,);
        foreach my $a_key (keys %AUBBC_TAGS) {
                if ($AUBBC_TAGS{$a_key} eq 1) {
                     $message =~ s{\[$a_key\]}{<$a_key>}gs;
                     $message =~ s{\[\/$a_key\]}{<\/$a_key>}gs;
                }
                 elsif ($AUBBC_TAGS{$a_key} eq 2) {
                         $message =~ s~\[$a_key\]~<$a_key$AUBBC{html_type}>~sg;
                 }
        }

        $message =~
            s~\[url=(\w+\://.+?)\](.+?)\[/url\]~<a href="$1"$AUBBC{href_target}$AUBBC{href_class}>$2</a>~isgo;
        $message =~
            s~\[url\](\w+\://.+?)\[/url\]~<a href="$1"$AUBBC{href_target}$AUBBC{href_class}>$1</a>~isgo;
        $message =~
            s~(?:(?<![\w\"\=\{\[\]])|[\n\b]|\A)\\*(\w+://[\w\~\.\;\:\,\$\-\+\!\*\?/\=\&\@\#\%]+[\w\~\.\;\:\$\-\+\!\*\?/\=\&\@\#\%])~<a href="$1"$AUBBC{href_target}$AUBBC{href_class}>$1</a>~isgo;
        $message =~
            s~(?:(?<![\"\=\[\]/\:\.])|[\n\b]|\A)\\*(www\.[\w\~\.\;\:\,\$\-\+\!\*\?/\=\&\@\#\%]+[\w\~\.\;\:\$\-\+\!\*\?/\=\&\@\#\%])~<a href="http://$1"$AUBBC{href_target}$AUBBC{href_class}>$1</a>~isgo;
        warn "END do_ubbc $self" if $DEBUG_AUBBC;
        return $message;
}

sub protect_email {
my ($email, $option) = @_;
my $protect_email = '';
my @key64 = ('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','0','1','2','3','4','5','6','7','8','9','+','/');
if ($option eq 1) {
 # none Javascript
 my @letters = split (//, $email);
 foreach my $character (@letters) {
          $protect_email .= '&#' . ord($character) . ';';
 }
  $protect_email = '<A href="&#109;&#97;&#105;&#108;&#116;&#111;&#58;' . $protect_email . "\"$AUBBC{href_class}>" . $protect_email . '</a>';
}
 elsif ($option eq 2) {
 # Javascript
 my @letters = split (//, $email);
 foreach my $character (@letters) {
          $protect_email .= '&#' . ord($character) . ';';
 }
 my ($email1, $email2) = split ("&#64;", $protect_email);
        $protect_email = <<JS;
<script language="javascript"><!--
document.write("<a href=" + "&#109;&#97;" + "&#105;&#108;" + "&#116;&#111;&#58;" + "$email1" + "&#64;" + "$email2" + "$AUBBC{href_class}>" + "$email1" + "&#64;" + "$email2" + "</a>")
//--></script>
JS
 }
  elsif ($option eq 3) {
  # A Javascript, random function and var names
  my $random_id = random_39();
   my @letters = split (//, $email);
   $protect_email = 'var c' . $random_id . ' = String.fromCharCode(109,97,105,108,116,111,58';
   my $name_protect = 'var b' . $random_id . ' = String.fromCharCode(160';
 foreach my $character (@letters) {
          $protect_email .= ',' . ord($character);
          $name_protect .= ',' . ord($character);
 }
 $protect_email .= ');';
 $name_protect .= ',160);';
        $protect_email = <<JS;
<script language="javascript"><!--
function a$random_id () {
$protect_email
 window.location=c$random_id;
};
$name_protect
document.write("<a href=\\"javascript:a$random_id();\\"" + "$AUBBC{href_class}>" + b$random_id + "</a>")
//--></script>
JS
  }
   elsif ($option eq 4) {
   # A Javascript encryption with random function and var names
   my ($random_id, @letters)  = ( random_39(), split(//, "mailto:$email") );
   my $prote = 'var c' . $random_id . ' = new Array(';
   foreach my $charect (@letters) {
           my $ran_num = int(rand(64)) || 0;
           $prote .= '\'' . (ord($key64[$ran_num]) ^ ord($charect)) . '\',\'' . $key64[$ran_num] . '\',';
           }
   $prote =~ s/\,\z/);/g;
   $protect_email = <<JS;
<script type='text/javascript'>
$prote
var f$random_id= new Array('',c$random_id.length,1,'');
    for(f$random_id\[2];f$random_id\[2]<f$random_id\[1];f$random_id\[2]++) {
        f$random_id\[0]+=String.fromCharCode(c$random_id\[f$random_id\[2]].charCodeAt(0)^c$random_id\[f$random_id\[2]-1]);f$random_id\[2]++;
    };
f$random_id\[3]=f$random_id\[0].replace(/^\\w+\\W/g, "");
document.write("<a href=\\"" + f$random_id\[0] + "\\"$AUBBC{href_class}>" + f$random_id\[3] + "</a>");
</script>
JS
   }
return $protect_email;
}

sub random_39 {
  my (@seed, $random_id) = ( ('a'..'f','0'..'9'), '' );
  rand(time ^ $$);
  for (my $i = 0; $i < 39; $i++) {
       $random_id .= $seed[int(rand($#seed + 1))];
  }
  return $random_id;
}

sub do_build_tag {
my ($self,$message) = @_;

   if ($DEBUG_AUBBC) {
        warn "ENTER do_build_tag $self";
        my $uabbc_settings = '';
         foreach my $set_key (keys %Build_AUBBC) {
                 $uabbc_settings .= $set_key . ' =>' . $Build_AUBBC{$set_key} . ', ';
         }
         warn "Build tags $uabbc_settings";
        }

    foreach my $b_key (keys %Build_AUBBC) {
             warn "ENTER foreach do_build_tag $self" if $DEBUG_AUBBC;
             my ($pattern, $type, $fn) = split (/\|\|/, $Build_AUBBC{$b_key});
             my $build_pat = '';
             if ($pattern eq 'all') {
                    $build_pat = 'a-z\d\:\-\s\_\/\.\;\&\=\?\-\+\#\%\~\,\|';
                    }
                     else {
                     my @pat_split = split (/\,/, $pattern);
                     my $p_ct = 0;
                         foreach my $pat_is (@pat_split) {
                                 last if $p_ct == 6;
                                 $p_ct++;
                                 $build_pat .= 'a-z' if $pat_is eq 'l';
                                 $build_pat .= '\d' if $pat_is eq 'n';
                                 $build_pat .= '\_' if $pat_is eq '_';
                                 $build_pat .= '\:' if $pat_is eq ':';
                                 $build_pat .= '\s' if $pat_is eq 's';
                                 $build_pat .= '\-' if $pat_is eq '-';
                         }
                     }
             $message =~ s/(\[$b_key\:\/\/([$build_pat]+)\])/
              my $ret = check_build_tag( $b_key, $2 , $fn ) || '';
              $ret ? $ret : $1;
              /exig if ($type eq 1);

             $message =~ s/(\[$b_key\]([$build_pat]+)\[\/$b_key\])/
              my $ret = check_build_tag( $b_key, $2 , $fn ) || '';
              $ret ? $ret : $1;
              /exig if ($type eq 2);

             $message =~ s/(\[$b_key\])/
              my $ret = check_build_tag( $b_key, '' , $fn ) || '';
              $ret ? $ret : $1;
              /exig if ($type eq 3);
     }
    warn "END do_build_tag $self" if $DEBUG_AUBBC;
    return $message;
}

sub check_build_tag {
my ($key, $term, $fun) = @_;
warn "ENTER check_build_tag" if $DEBUG_AUBBC;
return '' if !$term || !$fun;
no strict 'refs';
my $vid = $fun->($key, $term) || '';
use strict 'refs';
warn "END check_build_tag" if $DEBUG_AUBBC;
(!$vid) ? return '' : return $vid;
}

sub add_build_tag {
my ($self,%NewTag) = @_;
#$name,$pattern,$type,$fn
warn "ENTER add_build_tag $self" if $DEBUG_AUBBC;
   unless (defined("&$NewTag{function}") && (ref $NewTag{function} eq 'CODE' || ref $NewTag{function} eq '')) {
    die "Usage: do_build_tag 'no function named' => $NewTag{function}";
  }
  $NewTag{pattern} = 'l' if ($NewTag{type} eq 3);
  # all, l, n, \_, \:, \s, \- (delimiter \,)
  if ($NewTag{name} =~ m/\A[a-z0-9]+\z/i && ($NewTag{pattern} =~ m/\A[lns_:\-,]+\z/i || $NewTag{pattern} eq 'all')) {
         $Build_AUBBC{"$NewTag{name}"} = $NewTag{pattern} . '||' . $NewTag{type} . '||' . $NewTag{function} if ($NewTag{name} && $NewTag{pattern} && $NewTag{type});
       warn "Added Build_AUBBC Tag ".$Build_AUBBC{"$NewTag{name}"} if $DEBUG_AUBBC && $Build_AUBBC{"$NewTag{name}"};

  }
   else {
         die "Pattern: do_build_tag 'Bad name or pattern format'";
       }
warn "ENTER add_build_tag $self" if $DEBUG_AUBBC;
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
    # Unicode Support
    # [u://0931] or [utf://x23]
    $message =~ s{\[(?:u|utf)://(x?[0-9a-f]+)\]}{&#$1\;}igso;
    # [ux23] - Commented to reserve more tag names
    #$message =~ s{\[u(x?[0-9a-f]+)\]}{&#$1\;}igso;
    # &#x23; or &#0931;
    $message =~ s{&amp\;#(x?[0-9a-f]+)\;}{&#$1\;}igso;
    # code names
    $message =~ s{&amp\;([a-fA-Z]+)\;}{&$1\;}igso;
    warn "END do_unicode $self" if $DEBUG_AUBBC;
    return $message;
}

sub do_smileys {
    my ($self,$message) = @_;
    warn "ENTER do_smileys $self" if $DEBUG_AUBBC;
       # Make the smilies.
       foreach my $smly (keys %SMILEYS) {
               $message =~ s~\[$smly\]~<img src="$AUBBC{images_url}/smilies/$SMILEYS{$smly}" alt="$smly" border="$AUBBC{image_border}"$AUBBC{html_type}>$AUBBC{image_wrap}~isg if $smly && exists $SMILEYS{$smly};
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
    if (!$AUBBC{no_bypass} && $message =~ s/\A\#none//go) {
        warn "START&END no_bypass $self" if $DEBUG_AUBBC;
        $message = $self->script_escape($message) if $AUBBC{script_escape}; # Added
         return $message;
    }
     else {
    $message = $self->script_escape($message) if $AUBBC{script_escape}; # Moved up here
    return $message unless $message =~ m{[\[\]\(\:]};
    $message = $self->escape_aubbc($message, 1) if $AUBBC{aubbc_escape};
    $message = (!$AUBBC{no_bypass} && $message =~ s/\A\#noubbc//go)
        ? $message
        : $self->do_ubbc($message) if !$AUBBC{for_links} && $AUBBC{aubbc};

    $message = (!$AUBBC{no_bypass} && $message =~ s/\A\#nobuild//go)
        ? $message
        : $self->do_build_tag($message) if !$AUBBC{for_links} && %Build_AUBBC;

    $message = (!$AUBBC{no_bypass} && $message =~ s/\A\#noutf//go)
        ? $message
        : $self->do_unicode($message) if $AUBBC{utf};

    $message = (!$AUBBC{no_bypass} && $message =~ s/\A\#nosmileys//go)
        ? $message
        : $self->do_smileys($message) if $AUBBC{smileys};

    $message = $self->escape_aubbc($message) if $AUBBC{aubbc_escape};
    }
    warn "END do_all_ubbc $self" if $DEBUG_AUBBC;
    return $message;
}

sub escape_aubbc {
    my ($self, $message, $escaper) = @_;
    warn "ENTER escape_aubbc $self" if $DEBUG_AUBBC;
    if ($escaper) {
         warn "block escape 1 $self" if $DEBUG_AUBBC;
         $message =~ s{\[\[}{\{\{}go;
         $message =~ s{\]\]}{\}\}}go;
    }
     else {
           warn "block escape 2 $self" if $DEBUG_AUBBC;
           $message =~ s{\{\{}{\[}go;
           $message =~ s{\}\}}{\]}go;
     }
     warn "END escape_aubbc $self" if $DEBUG_AUBBC;
     return $message;
}

sub script_escape {
my ($self, $text, $option) = @_;
warn "ENTER html_escape $self" if $DEBUG_AUBBC;
     return '' unless $text;
     if (!$option) {
        $text =~ s{&}{&amp;}gso;
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
        $text =~ s{\n}{<br>}gso if (!$option);
        $text =~ s{\cM}{}gso if ($option || !$option);
warn "END html_escape $self" if $DEBUG_AUBBC;
        return $text;
}
sub html_to_text {
my ($self, $html, $option) = @_;
warn "ENTER html_to_text $self" if $DEBUG_AUBBC;
     return '' unless $html;
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
        $html =~ s{<br>}{\n}gso if (!$option);
warn "END html_to_text $self" if $DEBUG_AUBBC;
        return $html;
}
sub version {
my ($self) = @_;
     return $AUBBC_VERSION;
}

1;
