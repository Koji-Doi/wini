#!/usr/bin/env perl
=head1 NAME

wini.pm - WIki markup ni NIta nanika (Japanese: "Something like wiki markup")

=head1 SYNOPSIS

 use wini;

 my($htmltext) = wini(<<'EOT');
 ! Large header
 !! Middle header
 !!! Small header

 * list item 1
 ** nested list item 1-1
 ** nested list item 1-2
 * list item 2
 * list item 3

 # numbered list item 1
 # numbered list item 2

 Paragraphs should be separated by null line, like wiki or markdown. Line breaks in plain text are ignored. 
 Thus this is not a first sentence of the second paragraph, but the second sentence of the first paragraph.

 This is the second paragraph.

 Tables can be represented easily as follows.

 |!!~~3__2  Game | Players |-    |-    |
 |!!~~2__3^      |       A |   B |   C |
 |             1 |       1 |@  5 |   3 |
 |             2 |       4 |   5 |@ 10 |
 |==3!!!   Total |       5 |  10 |@ 13 |

 EOT

 open(my $fho, '>:utf8', 'output.html') or die;
 print {$fho} $htmltext;
 close $fho;

=head1 DESCRIPTION

The script file wini.pm is a perl module supporting WINI markup, which is a simple markup language to build HTML5 texts. This script can also be used as a stand-alone perl script. Users easily can get HTML5 documents from WINI source texts, by using wini.pm as a filter command.

The text presented here is just a brief description.

Please refer to the synopsis of this page to grasp ontline about WINI markup. 

Please refer to the homepage for details. 

=head2 As module

Put this script file in the directory listed in @INC. If you are not clear about what @INC is, please try 'perldoc perlvar'.
Add 'use wini;' in the begining of your script to use functions of wini.pm.  

=head2 As stand-alone script

Put this script file in the directory listed in your PATH. The script file name can be renamed as 'wini' instead of 'wini.pm'. Do 'chmod a+x wini.pm'. It might be required to do 'hash' ('rehash' in zsh) to make your shell recognize wini.pm as a valid command name.

If you succeed the install, you can use this script as follows:

 $ wini.pm < input.wini > output.html

See section 'Options' to find out detail about advanced usage.

=head2 WINI, a simple but useful markup language

WINI stands for "WIki ni NIta nanika", which means "something like wiki" in Japanese. As suggested from this naming, WINI is designed with reference to wiki mark up.

Strong points of WINI include:

=over 4

=item * B<Easiness to learn:>     WINI grammar is similar to that of wiki markup. The grammer is very simple. Not only persons with experience of wiki typesetting, but everyone can find out usage easily.

=item * B<HTML5 compartibility:>  WINI is designed with a strong emphasis on affinity with HTML5 and easiness of complex HTML table construction.  WINI is a useful system to produce modern and valid HTML5 texts quickly.

=back

Today many people try to build and maintain blogs, wikipedia-like sites, etc. They produce or update a huge number of such pages daily within a time limit. For SEO, outputs should follow the valid html5 grammer. Complex data should be presented in complex HTML tables. Average writers must have a hard time to fulfill such requirements. WINI will resque all those people!

=head1 Options

=over 4

=item * -i INPUT             Set input file name to INPUT. If the file named 'INPUT' does not exists, wini.pm looks for 'INPUT.wini'. If -i is not set, wini.pm takes data from standard input.

=item * -o OUTPUT            Set output file name. If both -o and -i are omitted, wini.pm outputs HTML-translated text to standard output.
If -o is omitted and the input file name is 'input.wini', the output file will be 'input.wini.html'.
Users can specify the output directory rather than the file. If -o value ends with 'output/', output file will be output/input.wini.html. if 'output/' does not exist, wini.pm will create it.

=item * --whole              Add HTML5 headar and footer to output. The result output will be a complete HTML5 document.

=item * --cssflamework [url] Specify the url of CSS flamework (especially "classless" flameworks are supposed). If the URL is omitted, it is set to "https://unpkg.com/mvp.css".

=item * --cssfile [out.css]  CSS is output to an independent css file, rather than the html file. If '--cssfile' is set without a file name, "wini.css" is the output css file name.

=item * --title [title]      Set text for <title>. Effective only when --whole option is set.

=item * --version            Show version.

=item * --help               Show this help.

=back

=cut

package WINI;
use strict;
use Data::Dumper;
use File::Basename;
use FindBin;
use Pod::Usage;
use Getopt::Long;
use Encode;
*Data::Dumper::qquote = sub { return encode "utf8", shift } ;
$Data::Dumper::Useperl = 1 ;

my $scriptname = basename($0);
my $version    = "ver. 0 rel. 20200727";
my @save;
my %ref; # $ref{image}{imageID} = 1; keys of %$ref: qw/image table formula citation math ref/
my $debug;

# barrier-free color codes: https://jfly.uni-koeln.de/html/manuals/pdf/color_blind.pdf
our ($red, $green, $blue, $magenta, $purple) 
  = map {sprintf('rgb(%s); /* %s */', @$_)} 
    (['219,94,0', 'red'], ['0,158,115', 'green'], ['0,114,178', 'blue'], ['218,0,250', 'magenta'], ['204,121,167', 'purple']);
my $css = {
  'ol, ul, dl' => {'padding-left'  => '1em'},
  'table, figure, img' 
               => {'margin'           => '1em'},
  'tfoot, figcaption'
               => {'font-size'        => 'smaller'},
  '.b-r'       => {'background-color' => $WINI::red},
  '.b-g'       => {'background-color' => $WINI::green},
  '.b-b'       => {'background-color' => $WINI::blue},
  '.b-w'       => {'background-color' => 'white'},
  '.b-b25'     => {'background-color' => '#CCC'},
  '.b-b50'     => {'background-color' => '#888'},
  '.b-b75'     => {'background-color' => '#444'},
  '.b-b100'    => {'background-color' => '#000'},
  '.b-m'       => {'background-color' => $WINI::magenta},
  '.b-p'       => {'background-color' => $WINI::purple},
  '.f-r'       => {'color' => $WINI::red,    'border-color' => 'black'},
  '.f-g'       => {'color' => $WINI::green,  'border-color' => 'black'},
  '.f-b'       => {'color' => $WINI::blue,   'border-color' => 'black'},
  '.f-w'       => {'color' => 'white',       'border-color' => 'black'},
  '.f-b25'     => {'color' => '#CCC',        'border-color' => 'black'},
  '.f-b50'     => {'color' => '#888',        'border-color' => 'black'},
  '.f-b75'     => {'color' => '#444',        'border-color' => 'black'},
  '.f-b100'    => {'color' => '#000',        'border-color' => 'black'},
  '.f-m'       => {'color' => $WINI::magenta,'border-color' => 'black'},
  '.f-p'       => {'color' => $WINI::purple, 'border-color' => 'black'},
  '.tategaki'  => {'-ms-writing-mode' => 'tb-rl', 'writing-mode' => 'vertical-rl', '-webkit-text-orientation' => 'mixed',   'text-orientation' => 'mixed'},
  '.tatetate'  => {'-ms-writing-mode' => 'tb-rl', 'writing-mode' => 'vertical-rl', '-webkit-text-orientation' => 'upright', 'text-orientation' => 'upright'},
  '.yokoyoko'  => {'-ms-writing-mode' => 'tb-rl', 'writing-mode' => 'vertical-rl', '-webkit-text-orientation' => 'sideways', 'text-orientation' => 'sideways'}
};

__PACKAGE__->stand_alone() if !caller() || caller() eq 'PAR';

# Following function is executed when this script is called as stand-alone script
sub stand_alone(){
  my($input, $output, $fhi, $title, $cssfile, $test, $fho, $whole, $cssflamework);
  GetOptions(
    "h|help"         => sub {help()},
    "v|version"      => sub {print STDERR "wini.pm Version $version\n"; exit()},
    "i=s"            => \$input,
    "o=s"            => \$output,
    "title=s"        => \$title,
    "cssfile:s"      => \$cssfile, 
    "t"              => \$test,
    "d"              => \$debug,
    "whole"          => \$whole,
    "cssflamework:s" => \$cssflamework
  );
  (defined $cssflamework) and ($cssflamework eq '') and $cssflamework='https://unpkg.com/mvp.css'; # 'https://newcss.net/new.min.css';
  ($test) and ($input, $output)=("test.wini", "test.html");
  if ($input) {
    unless(open($fhi, '<:utf8', $input)){
      print STDERR "Not accessible: $input\n";
      $input = "$input.wini";
      print STDERR "Will try to open: $input\n";
      open($fhi, '<utf8:', $input) or die "Not accessible either: $input";
    }
  } else {
    $fhi = *STDIN;
  }
  unless($output){
    if ($input) {
      $output = "$input.html";
      print STDERR "Will try to create $output\n";
      open($fho, '>:utf8', $output) or die "Cannot open file: $output";
    } else {
      $fho = *STDOUT;
    }
  } else {
    if (-d $output) {
      $output = "$output/$input.html";
    } elsif (substr($output, -1) eq '/') {
      print STDERR "Will try to create directory: $output\n";
      mkdir($output) or die "Cannot create directory: $output";
      $output = "$output/$input.html";
    }
    print STDERR "Will try to create file: $output\n";
    open($fho, '>:utf8', $output) or die "Cannot create file: $output";
  }
  if(defined $cssfile){
    ($cssfile eq '') and $cssfile="wini.css";
  }
  my @input = <$fhi>;
  push(@input, "\n");
  print {$fho} (wini(join('', @input), {whole=>$whole, cssfile=>$cssfile, title=>$title, cssflamework=>$cssflamework}))[0];
}

sub help{
  print pod2usage(-verbose => 2, -input => $FindBin::Bin . "/" . $FindBin::Script);
  exit();
}


sub close_listtag{
  my($ref, $l) = @_;
  map{
    $$ref .= (' ' x ($#$l-$_)) . (($l->[$_] eq 'ul')?'</ul>':($l->[$_] eq 'ol')?'</ol>':'</dl>') . "\n";
  } 0..$#$l;
}

sub css{
  my $css = shift;
  my $out = '';
  my $l   = 0;
  map {my $ll=length($_); $ll>$l and $l=$ll} keys %$css;
  foreach my $k (sort keys %$css){
    my $x   = $css->{$k};
    my($kx) = $k=~/^\d*(.*)/;
    $out .= sprintf('%*s {', -$l, $kx)."\n";
    foreach my $k2 (keys %$x){
      my($k2x) = $k2=~/^\d*(.*)/;
      $out.= (' ' x $l) . "  $k2x: $x->{$k2};\n";
    }
    $out.= (' ' x $l) . " }\n";
  }
  return($out);
}

{
my $footnote_cnt = {main=>0};
my @footnotes;

sub wini{
# wini($tagettext, {para=>'br', 'is_bs4'=>1, baseurl=>'http://example.com', nocr=>1});
  # para: paragraph mode (br:set <br>, p: set <p>, nb: no separation
  # nocr: whether CRs are conserved in result text. 0(default): conserved, 1: not conserved
  # table: table-mode, where footnote macro is effective. $opt->{table} must be a table ID. Footnote texts are set to @{$opt->{footnote}}
  my($t0, $opt)           = @_;
  my $cr                  = (defined $opt->{nocr} and $opt->{nocr}==1)
                          ?"\t":"\n"; # option to inhibit CR insertion (in table)
  my($baseurl, $is_bs4)   = ($opt->{baseurl}, $opt->{is_bs4});
  my $cssfile             = $opt->{cssfile};
  my $cssflamework        = $opt->{cssflamework};
  my $para                = 'p'; # p or br or none
  (defined $opt->{para}) and $para = $opt->{para};
  my $title               = 'WINI page';
  (defined $opt->{title}) and $title = $opt->{title};
  
  # pre, code, citation, ...
  $t0 =~ s/\{\{(pre|code|q(?: [^|]+?)?)}}(.+?)\{\{end}}/&save_quote($1,$2)/esmg;  
  $t0 =~ s/^'''\n(.*?)\n'''$/         &save_quote('pre',  $1)/esmg;
  $t0 =~ s/^```\n(.*?)\n```$/         &save_quote('code', $1)/esmg;
  $t0 =~ s/^"""([\w =]*)\n(.*?)\n"""$/&save_quote("q $1", $2)/esmg;
    
  # conv table to html
  $t0 =~ s/^\s*(\|.*?)[\n\r]+(?!\|)/make_table($1)/esmg;

  # footnote
  if(exists $opt->{table}){ # in table
    $t0=~s&\{\{\^\|([^}|]*)(?:\|([^}]*))?}}&
      $footnote_cnt->{$opt->{table}}++;
      my($txt, $style) = ($1, $2);
      my %cref = ('*'=>'lowast' ,'+'=>'plus', 'd'=>'dagger', 'D'=>'Dagger', 's'=>'sect', 'p'=>'para');
      $style = $style || '*';
      my($char, $char2) = $style=~/([*+dDsp])(\1)?/; # asterisk, plus, dagger, double-dagger, section, paragraph
      $char or $char = (($style=~/\d/)?'0':substr($style,0,1));
      my $prefix = ($char2)?("\&$cref{$char};" x $footnote_cnt->{$opt->{table}}) # *, **, ***, ...
        :"\&$cref{$char};".$footnote_cnt->{$opt->{table}};  # *1, *2, *3, ...
      push(@{$opt->{footnote}}, "<sup>$prefix</sup>$txt");
      "<sup>$prefix</sup>";
    &emg;
  }else{ # for main text
    $t0=~s&\{\{\^\|([^}|]*)(?:\|([^}]*))?}}&
      $footnote_cnt->{main}++;
      my($txt, $style) = ($1, $2);
      my %cref = ('*'=>'lowast' ,'+'=>'plus', 'd'=>'dagger', 'D'=>'Dagger', 's'=>'sect', 'p'=>'para');
      $style = $style || '*';
      my($char, $char2) = $style=~/([*+dDsp])(\1)?/; # asterisk, plus, dagger, double-dagger, section, paragraph
      $char or $char = (($style=~/\d/)?'0':substr($style,0,1));
      my $prefix = ($char2)?("\&$cref{$char};" x $footnote_cnt->{main}) # *, **, ***, ...
        :"\&$cref{$char};".$footnote_cnt->{main};  # *1, *2, *3, ...
      push(@footnotes, "<sup>$prefix</sup>$txt");
      "<sup>$prefix</sup>";
    &emg;
  }

  # sub, sup
  $t0 =~ s!__\{(.*?)}!<sub>$1</sub>!g;  
  $t0 =~ s!\^\^\{(.*?)}!<sup>$1</sup>!g;
  $t0 =~ s!__([^{])!<sub>$1</sub>!g;  
  $t0 =~ s!\^\^([^{])!<sup>$1</sup>!g;

  my $r;
  my @localclass = ('wini');
  ($is_bs4) and push(@localclass, "col-sm-12");
  #my $myclass = ' class="'.join(' ',@localclass).'"';
  foreach my $t (split(/\n{2,}/, $t0)){ # for each paragraph
    my @myclass = @localclass;
    my($myclass, $myid) = ('', '');
    my $lastlistdepth=0;
    my $ptype; # type of each paragraph (list, header, normal paragraph, etc.)
    while(1){ # loop while subst needed
      my($x, $id0, $cont) = $t=~/^(!+)([-#.\w]*)\s*(.*)$/m; # !!!...
      if($x){ # if header
        ($id0=~/^[^.#]/) and $id0=".$id0";
        while($id0=~/([#.])([^#.]+)/g){
          my($prefix, $label) = ($1, $2);
          ($label) or next;
          ($prefix eq '#') and push(@myclass, $label);
          ($prefix eq '.') and $myid = qq{ id="$label"};
        }
        my $tag0 = length($x); ($tag0>5) and $tag0="5";
        (defined $myclass[0]) and $myclass = qq{ class="} . join(" ", @myclass) . qq{"};
        $t=~s#^(!+)\s*(.*)$#<h${tag0}${myclass}${myid}>$cont</h${tag0}>#m;
        $ptype = 'header';
      } # endif header
      (
        $t =~ s!\{\{([IBUS])\|([^{}]*?)}}!{my $x=lc $1; "<$x>$2</$x>"}!esg or
        $t =~ s!\{\{i\|([^{}]*?)}}!<span style="font-style:italic;">$1</span>!g or
        $t =~ s!\{\{b\|([^{}]*?)}}!<span style="font-weight:bold;">$1</span>!g or
        $t =~ s!\{\{u\|([^{}]*?)}}!<span style="border-bottom: solid 1px;">$1</span>!g or
        $t =~ s!\{\{s\|([^{}]*?)}}!<span style="text-decoration: line-through;">$1</span>!g or
        $t =~ s!\{\{ruby\|([^{}]*?)}}!ruby($1)!eg or
        $t =~ s!\{\{([-_/*]+[-_/* ]*)\|([^{}]*?)}}!symmacro($1,$2)!eg or
        $t =~ s!\{\{([.#][^{}|]+)\|([^{}]*?)}}!
          my($a,$b,  @c)=($1,$2);
          push(my(@class), $a=~/\.([^.#]+)/g);
          push(my(@id),    $a=~/#([^.#]+)/g);
          (defined $class[0]) and push(@c, q{class="}.join(" ", @class).q{"});
          (defined $id[0])    and push(@c, q{id="}   .join(" ", @id)   .q{"});
          $_ = "<span " . join(" ", @c) . ">$b</span>"; 
        !eg or
        $t=~ s!\{\{v\|([^{}]*?)}}!<span class="tategaki">$1</span>!g or
        $t =~ s!\[(.*?)\]!make_a($1, $baseurl)!eg or
        $t =~ s/\{\{l}}/&#x7b;/g or   # {
        $t =~ s/\{\{bar}}/&#x7c;/g or # |
        $t =~ s/\{\{r}}/&#x7d;/g      # }

      ) or last; # no subst need, then escape inner loop
    } # loop while subst needed
    my $t2='';
       
    # for list items
    my $listtagc;
    my @is_dl; # $is_dl[1]: whether list type of depth 1 is 'dl'
    my @listtagc;
    foreach my $l (split("\n", $t)){
      # line/page break
      if(($l=~s/^---$/<br style="page-break-after: always;">/) or
         ($l=~s/^--$/<br style="clear: both;">/)){
        $t2 .= $l; next;
      }

      my($x, $listtype, $txt) = $l=~/^\s*([#*:;]*)([#*:;])\s*(.*)$/; # whether list item      
      if($listtype ne ''){
        $ptype = 'list';
        my $listdepth = length($x)+length($listtype);
        ($listtype eq ';') and $is_dl[$listdepth]='dl';
        my($itemtag, $listtag) = ($listtype eq '*') ? qw/li ul/
                               : ($listtype eq ':') ? (($is_dl[$listdepth] eq 'dl')?qw/dd dl/:(qq{li style="list-style:none"}, 'ul'))
                               : ($listtype eq ';') ? qw/dt dl/ : qw/li ol/;
        my $itemtagc = $itemtag; # closing tag for list item
           $listtagc = $listtag; # closing tag for list
        $itemtagc =~ s/ .*//;
        $listtagc =~ s/ .*//;
        $listtagc[$listdepth] = $listtagc;
        # new list start?
        if($listdepth>$lastlistdepth){
          $t2 .= sprintf(qq!%*s<$listtag class="winilist">$cr!, $listdepth, ' ');
        }
        # new list end?
        for(my $i = $lastlistdepth-$listdepth; $i>0; $i--){
          $t2 .= sprintf("%*s</%s>$cr", $i+$listdepth, ' ', $listtagc[$i+$listdepth]);
        }
        $t2 .= sprintf("%*s<$itemtag>$txt</$itemtagc>$cr",$listdepth+1,' ');
        $lastlistdepth = $listdepth;
      }else{ # if not list item
        $t2 .= "$l\n";
      }
    } # $l
    if($lastlistdepth>0){
      $t2 .= sprintf("%*s", $lastlistdepth-1, ' ') . ("</$listtagc>" x $lastlistdepth) . $cr;
      $lastlistdepth=0;
    }

    $r .= ($ptype eq 'header' or $ptype eq 'list')                      ? "$t2\n"
        : ($para eq 'br')                                               ? "$t2<br>$cr"
        : ($para eq 'nb')                                               ? $t2
        : $t2=~m{<(p|table|img|figure|blockquote|[uod]l)[^>]*>.*</\1>}s ? $t2
                                                                        : "<p${myclass}>\n$t2</p>$cr$cr";
  } # foreach $t

  $r=~s/\x00i=(\d+)\x01/$save[$1]/ge;
  if($cssfile){
    open(my $fho, '>', $cssfile) or die "Cannot modify $cssfile";
    print {$fho} css($css);
    close $fho;
  }
  if(defined $footnotes[0]){
    $r .= qq{<hr>\n<footer>\n<ul style="list-style:none;">\n} . join("\n", (map {"<li>$_</li>"}  @footnotes)) . "\n</ul>\n</footer>\n";
  }
  if(defined $opt->{whole}){
    my $style = ($cssflamework)?qq{<link rel="stylesheet" type="text/css" href="$cssflamework">}:'';
    $style   .= ($cssfile)?qq{<link rel="stylesheet" type="text/css" href="$cssfile">} : "<style>\n".css($css)."</style>\n";
    $r = <<"EOD";
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
$style
<title>$title</title>
</head>
<body>
$r
</body>
</html>
EOD
  }
  return($r, $opt);
} # sub wini
}

sub symmacro{
  # {{/*_-|text}}
  my($tag0, $text)=@_;
  my @styles;
  my $r;
  my $strong=0;
  while($tag0=~/(\*+)/g){
    (length($1)>1) ? ($strong=length($1)-1) : push(@styles, 'font-weight:bold;');
  }
  ($tag0=~/_/)  and push(@styles, 'border-bottom: solid 1px;');
  ($tag0=~/-/)  and push(@styles, 'text-decoration: line-through;');
  ($tag0=~m{/}) and push(@styles, 'font-style:italic;');
  $r = (scalar @styles > 0)?'<span style="' . join(' ', @styles) . qq{">$text</span>} : $text;
  ($strong) and $r = '<strong>'x$strong . $r . '</strong>'x$strong;
  return($r);
}

sub readpars{
  my($p, @list)=@_;
  my %pars; my @pars;
  foreach my $x (split(/\|/, $p)){
    if(my($k,$v) = $x=~/(\w+)\s*=\s*(.*)\s*/){
      $pars{$k}=$v;
    }else{
      push(@pars, $x);
    }
  }
  foreach my $k (@list){
    if(not exists $pars{$k}){
      my $x = shift(@pars);
      $pars{$k}=$x;
    }
  }
  return(\%pars);
}

sub escape{
  ($_)=@_;
  ($_) or return('');
  s/</&lt;/g;
  s/>/&gt;/g;
  return($_);
}

{
my $i=-1;
sub save_quote{ # pre, code, cite ...
  my($cmd, $txt) = @_;
  $i++;
  $save[$i] = $txt;
  $cmd = lc $cmd;
  if($cmd eq 'def'){
    return('');
  }elsif($cmd=~/^q/){ # q
    my(@opts) = $cmd=~/(\w+=\S+)/g;
    my %opts;
    foreach my $o (@opts){
      my($k,$v) = $o=~/([^;]*?)=(.*)/;
      ($k) and $opts{$k} = $v;
    }
    ($opts{cite}) or $opts{cite} = 'http://example.com';
    return(<<"EOD");
<blockquote cite="$opts{cite}">
\x00i=$i\x01
</blockquote>
EOD
  }else{ # pre, code
    my($ltag, $rtag) = ($cmd eq 'code')?('<pre><code>','</code></pre>')
                                       :('<pre>',      '</pre>');
    return("$ltag\n\x00i=$i\x01\n$rtag");
  }
}
}

# [[label|type|ja_name|en_name|ja_desc|en_desc|maxlen|minlen|maxval|minval|regexp|ncol|nrow]]
sub readblank{
  my($indata)=@_; # '[[a|b|c]]'
  ($indata)=$indata=~/(?:\[\[)?([^]]*)(?:\]\])?/;
  my $x = readpars($indata, qw/label type ja_name en_name ja_desc en_desc maxlen minlen maxval minval regexp ncol nrow/);
  return($x);
}

# [xxxx] -> <a href="www">...</a>
{
my $img_no=0;
sub make_a{
# [! image.png text]
# [!"image.png" text]
# [!!image.png|#x text] # figure
# [!image.png|< text]   # img with float:left
# [http://example.com text]
# [http://example.com|@@ text] # link with window specification
# [#goat text]  # link within page

  my($t, $baseurl)=@_;
  my($prefix, $url0, $text)          = $t=~m{([!?#]*)"(\S+)"\s+(.*)};
  ($url0) or ($prefix, $url0, $text) = $t=~m{([!?#]*)([^\s"]+)(?:\s+(.*))?};
  my($url, $opts) = split(/\|/, $url0, 2);
  ($prefix eq '#') and $url=$prefix.$url;
  $text = escape($text) || $url;

  # options
  my $style            = ($opts=~/</)?"float: left;":($opts=~/>/)?"float: right;":undef;
  ($style) and $style  = qq{ style="$style"};
  my @ids              = $opts=~/#([-\w]+)/g;
  my @classes          = $opts=~/\.([-\w]+)/g;  $opts=~s/[.#][-\w]+//g;
  my($width,$height)   = ($opts=~/(\d+)x(\d+)/)?($1,$2):(0,0);
  my $imgopt           = ($width>0)?qq{ width="$width"}:'';
  $height and $imgopt .= qq{ height="$height"};
  my $target           = ($opts=~/@@/)?'_blank':($opts=~/@(\w+)/)?($1):'_self';

  if($prefix=~/[!?]/){ # img, figure
    $img_no++;
    my $id = $ids[-1]; ($id) or $id = "image${img_no}";
    my $class = join(' ', @classes); ($class) and $class = qq{ class="$class"};
    $ref{image}{$id} = $img_no;
    if($prefix eq '!!'){
      return(qq!<figure$style> <img src="$url" alt="$id" id="$id"$class$imgopt><figcaption>$text</figcaption></figure>!);
    }elsif($prefix eq '??'){
      return(qq!<figure$style> <a href="$url" target="$target"><img src="$url" alt="$id" id="$id"$class$imgopt></a><figcaption>$text</figcaption></figure>!);
    }elsif($prefix eq '?'){
      return(qq!<a href="$url" target="$target"><img src="$url" alt="$text" id="$id"$class$style$imgopt></a>!);      
    }else{ # "!"
      return(qq!<img src="$url" alt="$text" id="$id"$class$style$imgopt>!);
    }
  }elsif($url=~/^[\d_]+$/){
    return(qq!<a href="$baseurl?aid=$url" target="$target">$text</a>!);
  }else{
    return(qq!<a href="$url" target="$target">$text</a>!);
  }
}
}

sub ruby{
  my($x) = @_; # text1|ruby1|text2|ruby2 ...
  my @txt = split(/\|/, $x);
  my $t = join("", map {my $a=$_*2; "$txt[$a]<rp>(</rp><rt>$txt[$a+1]</rt><rp>)</rp>"} (0..$#txt/2));
  return("<ruby>$t</ruby>");
}

{
my $table_no;
sub make_table{
  my($in)=@_;
  (defined $table_no) or $table_no=1;
  my $ln=0;
  my @winiitem;
  my @htmlitem;
  my $caption;
  #my $footnote_cnt=0;
  my $footnotetext;
  my @footnotes; # footnotes in cells

  push(@{$htmlitem[0][0]{copt}{class}}, 'winitable');

  #get caption & table setting - remove '^|-' lines from $in
  $in =~ s&(^\|-([^-].*$))\n&
    my $caption0=$2;
    $caption0=~s/\|\s*$//;
    my($c, $o) = split(/ \|(?= |$)/, $caption0, 2); # $caption=~s{[| ]*$}{};
    while($o =~ /([^=\s]+)="([^"]*)"/g){
      my($k,$v) = ($1,$2);
      ($k eq 'class')  and push(@{$htmlitem[0][0]{copt}{class}}, $v), next;
      ($k eq 'border') and $htmlitem[0][0]{copt}{border}=$v         , next;
      push(@{$htmlitem[0][0]{copt}{style}{$k}}, $v);
    }
    if($o=~/(?<![<>])([<>])(?![<>])/){
      $htmlitem[0][0]{copt}{style}{float}[0] = ($1 eq '<')?'left':'right';
    }
    while($o=~/([tbf])@(?!@)(\d*)/g){
      $htmlitem[0][0]{copt}{$1.'border'} = ($2)?$2:1;
    }
    while($o=~/([tbf])@@(\d*)/g){
      $htmlitem[0][0]{copt}{$1.'borderall'} = ($2)?$2:1;
      (defined $htmlitem[0][0]{copt}{$1.'border'}) or $htmlitem[0][0]{copt}{$1.'border'} = ($2)?$2:1; 
    }
    while($o=~/\.([-\w]+)/g){
      push(@{$htmlitem[0][0]{copt}{class}}, $1);
    }
    while($o=~/#([-\w]+)/g){
      $htmlitem[0][0]{copt}{id}[0] = $1;
    }
    ($htmlitem[0][0]{copt}{id}[0]) or $htmlitem[0][0]{copt}{id}[0] = "winitable${table_no}";
    while($o=~/\&([lrcjsebtm]+)/g){
      my $h = {qw/l left r right c center j justify s start e end/}->{$1};
      (defined $h) and push(@{$htmlitem[0][0]{copt}{style}{'text-align'}}, $h);
      my $v = {qw/t top m middle b bottom/}->{$1};
      (defined $v) and push(@{$htmlitem[0][0]{copt}{style}{'vertical-align'}}, $v);
    }
    while($o=~/(?<!\w)([][_~@=|])+([,;:]?)(\d+)?/g){
      my($a, $aa, $b) = ($1, $2, $3);
      my $b1    = sprintf("%s %dpx", ($aa)?(($aa eq ',')?'dotted':($aa eq ';')?'dashed':'double'):'solid', $b);
      ($a=~/[[@|]/) and $htmlitem[0][0]{copt}{style}{'border-left'}   = $b1;
      ($a=~/[]@|]/) and $htmlitem[0][0]{copt}{style}{'border-right'}  = $b1;
      ($a=~/[_@=]/) and $htmlitem[0][0]{copt}{style}{'border-bottom'} = $b1;
      ($a=~/[~@=]/) and $htmlitem[0][0]{copt}{style}{'border-top'}    = $b1;
    }
    ($caption)=wini($c, {para=>'nb', nocr=>1});
    $caption=~s/[\s\n\r]+$//;
  ''&emg;

  my @lines = split(/\n/, $in);
  my $macro = '';
  my %macros;
  foreach my $line (@lines){
    $line=~s/[\n\r]*//g;
    ($line eq '') and next;
    my @cols = split(/((?:^| +)\|\S*)/, $line);

    # standardize
    $cols[-1]=~/^\s+$/  and delete $cols[-1];
    $cols[-1]!~/^\s*\|/ and push(@cols, '|');
    map{ s/^\s*//; s/\s*$//;} @cols;

    # mode
    my $rowmerge = ($line=~m{^\|\^\^}) ? 1 : 0;
    if($rowmerge!=1){
      $macro = ($line=~m{^\|([a-zA-Z\d]+)}) ? $1 : '';
      ($macro eq '') and $ln++;
    }

    # inner-table macro entry
    if($macro ne ''){
      $macros{$macro} = ($rowmerge==1)?("$macros{$macro}\n$cols[2]") : $cols[2];
      next;
    }

    # prepare %winiitem
    for (my $cn=1; $cn<$#cols; $cn++){
      if($rowmerge){
        ($cn%2==0) and $winiitem[$ln][$cn] .= "\n".$cols[$cn]; # separators are skipped
      }else{
        $winiitem[$ln][$cn] = $cols[$cn];
      }
    }
  } # foreach @lines
  
  my @rowlen;
  for($ln=$#winiitem; $ln>=1; $ln--){
    ($winiitem[$ln][1] =~ /^\|---(.*)$/) and $htmlitem[$ln][0]{footnote}=1;
    $rowlen[$ln]=0;

    my $colspan=0;
    my $val='';
    for(my $cn=1; $cn<=$#{$winiitem[$ln]}; $cn+=2){
      if($winiitem[$ln][$cn]=~/<([a-zA-Z\d]+)/){
        my $macro=$1;
        (defined $macros{$macro}) and $winiitem[$ln][$cn+1] = $macros{$macro};
      }
    }

    for(my $cn=$#{$winiitem[$ln]}; $cn>=0; $cn--){
      my $col   = $winiitem[$ln][$cn];
      my $col_n = $cn/2+1;
      if($cn%2==1){ # separator
        $col = substr($col,1); # remove the first '|'

        # border style initial setting from $htmlitem[0][0]{copt}{style} 191217 - 191220
        foreach my $btype (map {"border-$_"} qw/left right bottom top/){
          (not defined $htmlitem[$ln][0]{footnote}) and 
            (defined $htmlitem[0][0]{copt}{style}{$btype}) and 
              $htmlitem[$ln][$col_n]{copt}{style}{$btype}[0] = $htmlitem[0][0]{copt}{style}{$btype}; 
        }

        #$ctag = ($col=~/\bh\b/)?'th':'td';
        $htmlitem[$ln][$col_n]{ctag} = 'td';
        $col=~s/\.\.\.\.([^.]+)/unshift(@{$htmlitem[  0][     0]{copt}{class}}, $1), ''/eg;
        $col=~s/\.\.\.([^.]+)/  unshift(@{$htmlitem[  0][$col_n]{copt}{class}}, $1), ''/eg;
        $col=~s/\.\.([^.]+)/    unshift(@{$htmlitem[$ln][     0]{copt}{class}}, $1), ''/eg;
        $col=~s/\.([^.]+)/      unshift(@{$htmlitem[$ln][$col_n]{copt}{class}}, $1), ''/eg;
        while($col=~/(?<!!)(!+)(?!!)/g){
          my($h) = $1;
          if(length($h) == 1){ # cell
            $htmlitem[$ln][$col_n]{ctag} = 'th';
          }elsif(length($h) == 2){ # row
            $htmlitem[$ln][0]{ctag} = 'th';
          }elsif(length($h) == 3){ #col
            $htmlitem[0][$col_n]{ctag} = 'th';
          }
        } # header

        if($col eq '-'){ # colspan
          $colspan++;
          $winiitem[$ln][$cn-1]   .= "\n" . $winiitem[$ln][$cn+1];
          if(defined $htmlitem[$ln][$col_n]{copt}{colspan}){
            $htmlitem[$ln][$col_n-1]{copt}{colspan} = $htmlitem[$ln][$col_n]{copt}{colspan}+1;
          }else{
            $htmlitem[$ln][$col_n-1]{copt}{colspan} = 2;
          }
          $htmlitem[$ln][$col_n]{copt}{colspan}   = -1;
          next;
        }elsif($colspan>0){
          $colspan=0;
        } # colspan

        if($col=~/\^/){ # rowspan
          $winiitem[$ln-1][$cn+1] .= "\n" . $winiitem[$ln][$cn+1]; # merge data block to upper row 
          (defined $htmlitem[$ln][$col_n]{copt}{rowspan}) or $htmlitem[$ln][$col_n]{copt}{rowspan} = 1;
          $htmlitem[$ln-1][$col_n]{copt}{rowspan} = $htmlitem[$ln][$col_n]{copt}{rowspan}+1;
          $htmlitem[$ln][$col_n]{copt}{rowspan} = -1; #200708
          next;
        } # rowspan

        while($col=~/(([][_~=@|])(?:\2*))([,;:]?)(\d*)/g){ # border setting
          my($m, $btype, $n) = (length($1), $2, sprintf("%s %dpx", ($3)?(($3 eq ',')?'dotted':($3 eq ';')?'dashed':'double'):'solid', ($4 ne '')?$4:1));
          my %btype;
          ($btype=~/[[@|]/) and $btype{left}   = $n;
          ($btype=~/[]@|]/) and $btype{right}  = $n;
          ($btype=~/[~@=]/) and $btype{top}    = $n;
          ($btype=~/[_@=]/) and $btype{bottom} = $n;
          foreach my $k (keys %btype){
            my($r,$c) = ($m==4)?(  0, 0)       # for whole table
                       :($m==3)?(  0, $col_n)  # for all cells in the target col
                       :($m==2)?($ln, 0)       # for all cells in the target row
                       :        ($ln, $col_n); # for target cell
            push(@{$htmlitem[$r][$c]{copt}{style}{"border-$k"}}, 
              (defined $btype{$k})?$btype{$k}
             :(defined $htmlitem[0][0]{copt}{style}{"border-$k"})?$htmlitem[0][0]{copt}{style}{"border-$k"}:undef
            );
          }
        } # while border

        while($col=~/(&{1,2})([lrcjsetmb])/g){ # text-align
          my($a,$b)=($1,$2);
          my $h = {qw/l left r right c center j justify s start e end/}->{$b};
          (defined $h) and push(@{$htmlitem[$ln][($a eq '&&')?0:$col_n]{copt}{style}{'text-align'}}, $h);
          my $v = {qw/t top m middle b bottom/}->{$b};
          (defined $v) and push(@{$htmlitem[$ln][($a eq '&&')?0:$col_n]{copt}{style}{'vertical-align'}}, $v);
        } # text align
        while($col=~/(\${1,2})(\d+)/g){ # height/width
          my($a,$b)=($1,$2);
          if($a eq '$$'){ # height -> tr and table
            push(@{$htmlitem[$ln][0]{copt}{style}{height}}, "${b}px");
          }else{ # width -> td and table
            push(@{$htmlitem[$ln][$col_n]{copt}{style}{width}}, "${b}px");
          }
        }
        $htmlitem[$ln][$col_n]{val}  = $val;
      }else{ # value
        $val = $col;
      }
    } # $cn

    for(my $i=1; $i<=$#{$htmlitem[$ln]}; $i++){ # set winified text to cells
      (defined $htmlitem[$ln][$i]) or next;
      my $cell = $htmlitem[$ln][$i];
      ($cell->{wini}, my $opt) = wini($cell->{val}, {para=>'nb', nocr=>1, table=>$htmlitem[0][0]{copt}{id}[0]});
      (exists $opt->{footnote}) and push(@footnotes, @{$opt->{footnote}});
      $cell->{wini} =~ s/\t *//g;
      $cell->{wini} =~ s/[ \n]+/ /g;
      $htmlitem[$ln][$i] = $cell; # $htmlitem[$ln][0]: data for row (tr)
      $rowlen[$ln] += (defined $htmlitem[$ln][$i]{wini})?(length($htmlitem[$ln][$i]{wini})):0;
    }
  } # for $ln

  for(my $i=1; $i<=$#{$htmlitem[1]}; $i++){ # set colclass to cells
    map {
      (defined $htmlitem[0][$i]{copt}{class}) and push(@{$htmlitem[$_][$i]{copt}{class}}, @{$htmlitem[0][$i]{copt}{class}}) 
    }1..$#htmlitem;
  }

  (defined $htmlitem[0][0]{copt}{style}{height}[0]) 
        or $htmlitem[0][0]{copt}{style}{height}[0] = sprintf("%drem", (scalar @lines)*2);
  (defined $htmlitem[0][0]{copt}{style}{width}[0]) 
        or $htmlitem[0][0]{copt}{style}{width}[0] = sprintf("%drem", ((sort @rowlen)[-1])*2);

  ($debug) and print(STDERR "winiitem\n", (Dumper @winiitem), "htmlitem\n", (Dumper @htmlitem));

  # make html
  my $outtxt = sprintf(qq!<table id="%s" class="%s"!, $htmlitem[0][0]{copt}{id}[0], join(' ', @{$htmlitem[0][0]{copt}{class}}));
  (defined $htmlitem[0][0]{copt}{border}) and $outtxt .= ' border="1"';
  $outtxt .= q{ style="border-collapse: collapse; };
  foreach my $k (qw/text-align vertical-align color background-color float/){
    (defined $htmlitem[0][0]{copt}{style}{$k}) and $outtxt .= qq{ $k: $htmlitem[0][0]{copt}{style}{$k}[0]; }; 
  }
  (defined $htmlitem[0][0]{copt}{border}) and $outtxt .= sprintf("border: solid %dpx; ", $htmlitem[0][0]{copt}{border});

  $outtxt .= qq{">\n}; # end of style
  (defined $caption) and $outtxt .= "<caption>$caption</caption>\n";
  $outtxt .= (defined $htmlitem[0][0]{copt}{bborder})?qq{<tbody style="border:solid $htmlitem[0][0]{copt}{bborder}px;">\n}:"<tbody>\n";

  for(my $rn=1; $rn<=$#htmlitem; $rn++){
    my $outtxt0;
    ($htmlitem[$rn][0] eq '^^') and next;
    my $ropt = '';
    my @styles;
    if(defined $htmlitem[$rn][0]{copt}{style}){
      push(@styles, map{ sprintf("$_:%s;", join(' ', @{$htmlitem[$rn][0]{copt}{style}{$_}})) } (keys %{$htmlitem[$rn][0]{copt}{style}}));
      #$ropt .= ' style="' . 
      # join(' ', map{ sprintf("$_:%s;", join(' ', @{$htmlitem[$rn][0]{copt}{style}{$_}})) } (keys %{$htmlitem[$rn][0]{copt}{style}})) . '"';
    }
    my $border;
    if(defined $htmlitem[$rn][0]{copt}{style}{tborderall}){
      $border = $htmlitem[$rn][0]{copt}{style}{tborderall};
    }
    if(defined $htmlitem[$rn][0]{copt}{style}{bborderall} and (not defined $htmlitem[$rn][0]{footnote})){
      $border = $htmlitem[$rn][0]{copt}{style}{bborderall};
    }
    if(defined $htmlitem[$rn][0]{copt}{style}{fborderall} and ( defined $htmlitem[$rn][0]{footnote})){
      $border = $htmlitem[$rn][0]{copt}{style}{fborderall};
    }
    (defined $border) and push(@styles, "border: solid ${border}px");

    #(defined $htmlitem[0][0]{copt}{border}) and $outtxt .= sprintf("border: solid %dpx; ", $htmlitem[0][0]{copt}{border});
    (defined $styles[0]) and $ropt .= qq{style="} . join('; ', @styles) . '"';  

    if(defined $htmlitem[$rn][0]{copt}{class}[0]){
      $ropt .= q{ class="} . join(' ',  @{$htmlitem[$rn][0]{copt}{class}}) . q{"};
    }
    ($ropt) and $ropt = " $ropt";
    $outtxt0 .= qq!<tr$ropt>!;
    $outtxt0 .= join("", 
      map { # for each cell ($_: col No.)
        if((defined $htmlitem[$rn][$_]{copt}{rowspan} and $htmlitem[$rn][$_]{copt}{rowspan}<=1) or (defined $htmlitem[$rn][$_]{copt}{colspan} and $htmlitem[$rn][$_]{copt}{colspan}<=1)){
          '';
        }else{
          my $copt = '';
          foreach my $c (qw/class colspan rowspan/){
            ($c eq 'rowspan') and ($htmlitem[$rn][0]{footnote}) and next;
            (defined $htmlitem[$rn][$_]{copt}{$c}) and
              $copt .= sprintf(qq{ $c="%s"},
                         (ref $htmlitem[$rn][$_]{copt}{$c} eq 'ARRAY') 
                           ? join(' ', @{$htmlitem[$rn][$_]{copt}{$c}}) 
                           : $htmlitem[$rn][$_]{copt}{$c});
          }
          if(defined $htmlitem[$rn][$_]{copt}{style}){
            $copt .= q! style="!;
            foreach my $c (keys %{$htmlitem[$rn][$_]{copt}{style}}){
              $copt .= sprintf("$c:%s; ", join(' ', @{$htmlitem[$rn][$_]{copt}{style}{$c}}));
            }
            $copt .= q!"!;
          }
          my $ctag = (
            (not $htmlitem[$rn][0]{footnote}) and (
            ($htmlitem[$rn][$_]{ctag} eq 'th') or 
            ($htmlitem[0][$_]{ctag}   eq 'th') or
            ($htmlitem[$rn][0]{ctag}  eq 'th'))
          )?'th':'td';
          sprintf("<$ctag$copt>%s</$ctag>", $htmlitem[$rn][$_]{wini});
        }
      } (1 .. $#{$htmlitem[1]})
    );
    $outtxt0 .= "</tr>\n";
    ($htmlitem[$rn][0]{footnote}) ? ($footnotetext .= $outtxt0) : ($outtxt .= $outtxt0);
  } # foreach $rn
  $outtxt .= "</tbody>\n";
  if((scalar @footnotes > 0) or $footnotetext){
    $outtxt .= (defined $htmlitem[0][0]{copt}{fborder})?qq{<tfoot style="border: solid $htmlitem[0][0]{copt}{fborder}px;">\n}:"<tfoot>\n";
    my $colspan = scalar @{$htmlitem[-1]} -1;
    ($footnotetext) and $outtxt .= $footnotetext;
    if(scalar @footnotes > 0){
      $outtxt .= sprintf(qq{<tr><td colspan="$colspan">%s</td></tr>\n}, join('&ensp;', @footnotes));
    }
    $outtxt .= "</tfoot>\n";
  }
  $outtxt .= "</table>\n";
  $outtxt=~s/\t+/ /g; # tab is separator of cells vertically unified
  return("\n$outtxt\n");
} # sub make_table

} # table env

1;
