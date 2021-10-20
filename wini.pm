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

=item B<-i> I<INPUT>

Set input file name to INPUT. If the file named 'INPUT' does not exists, wini.pm looks for 'INPUT.wini'. If -i is not set, wini.pm takes data from standard input.

=item B<-o> I<OUTPUT>

Set output file name. If both -o and -i are omitted, wini.pm outputs HTML-translated text to standard output.
If -o is omitted and the input file name is 'input.wini', the output file will be 'input.wini.html'.
Users can specify the output directory rather than the file. If -o value ends with 'output/', output file will be output/input.wini.html. if 'output/' does not exist, wini.pm will create it.

=item B<--whole>

Add HTML5 headar and footer to output. The result output will be a complete HTML5 document.

=item B<--cssflamework> I<[url]>

Specify the url of CSS flamework (especially "classless" flameworks are supposed). If the URL is omitted, it is set to "https://unpkg.com/mvp.css".

=item B<--cssfile> I<[out.css]>

CSS is output to an independent css file, rather than the html file. If '--cssfile' is set without a file name, "wini.css" is the output css file name.

=item B<--extralib> I<LIB>, B<-E> I<LIB>

Load specified library LIB

=item B<--libpath> I<PATH>, B<-I> I<PATH>

Add specified directory PATH into library path

=item B<--title> I<[title]>

Set text for <title>. Effective only when --whole option is set.

=item B<--version>

Show version.

=item B<--help>

Show this help.

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
use Cwd;
#use Module::Load qw( load );
#load('YAML::Tiny');

*Data::Dumper::qquote = sub { return encode "utf8", shift } ;
$Data::Dumper::Useperl = 1 ;
my  @libs;
my  @libpaths;
our %macros;

our %VARS;
our $ENVNAME="_";
our %ID; # list of ID assigned to tags in the target html
our %EXT;

my $scriptname = basename($0);
my $version    = "ver. 0 rel. 20210924";
my @save;
my %ref; # $ref{image}{imageID} = 1; keys of %$ref: qw/image table formula citation math ref/
my $debug;

# barrier-free color codes: https://jfly.uni-koeln.de/html/manuals/pdf/color_blind.pdf
our ($red, $green, $blue, $magenta, $purple) 
  = map {sprintf('rgb(%s); /* %s */', @$_)} 
    (['219,94,0', 'red'], ['0,158,115', 'green'], ['0,114,178', 'blue'], ['218,0,250', 'magenta'], ['204,121,167', 'purple']);
my $CSS = {
  'ol, ul, dl' => {'padding-left'     => '1em'},
  'table, figure, img' 
	       => {'margin'           => '1em',
	           'border-collapse'  => 'collapse'},
#  'tbody'      => {'border'           => 'solid 3px'},
#  'tbody td, tbody th' => {'border'   => 'solid 1px'},
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
sub stand_alone{
  my($input, $output, $fhi, $title, $cssfile, $test, $fho, $whole, @cssflameworks);
  GetOptions(
    "h|help"         => sub {help()},
    "v|version"      => sub {print STDERR "wini.pm $version\n"; exit()},
    "i=s"            => \$input,
    "o=s"            => \$output,
    "title=s"        => \$title,
    "cssfile:s"      => \$cssfile,
    "E|extralib:s"   => \@libs,
    "I|libpath:s"    => \@libpaths,
    "T"              => \$test,
    "D"              => \$debug,
    "whole"          => \$whole,
    "cssflamework:s" => \@cssflameworks
  );
  foreach my $i (@libpaths){
    print STDERR "Trying to add $i into library directory\n";
    (-d $i) ? push(@INC, $i) : warn("$i for extra library not found.\n");
  }
  foreach my $lib (@libs){ # 'form', etc.
    my $r = eval{load($lib)};
    (defined $r) ? print(STDERR "Loaded library: $lib\n") : warn("failed to load library '$lib'\n");
  }

  (defined $cssflameworks[0]) and ($cssflameworks[0] eq '') and $cssflameworks[0]='https://unpkg.com/mvp.css'; # 'https://newcss.net/new.min.css';
  ($test) and ($input, $output)=("test.wini", "test.html");
  if ($input) {
    unless(open($fhi, '<:utf8', $input)){
      print STDERR "Not accessible: $input\n";
      $input = "$input.wini";
      print STDERR "Will try to open: $input\n";
      open($fhi, '<:utf8', $input) or die "Not accessible either: $input";
    }
  } else {
    binmode STDIN, ':utf8';
    binmode STDERR,':utf8';
    $fhi = *STDIN;
  }
  unless($output){
    if ($input) {
      $output = "$input.html";
      print STDERR "Will try to create $output\n";
      open($fho, '>:utf8', $output) or die "Cannot open file: $output";
    } else {
      binmode STDOUT, ':utf8';
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
  (defined $cssfile) and ($cssfile eq '') and $cssfile="wini.css";
  $_=<$fhi>;
  s/\x{FEFF}//; # remove BOM if exists
  push(my @input, $_);
  push(@input, <$fhi>);
  push(@input, "\n");
  print {$fho} (wini_sects(join('', @input), {dir=>getcwd, whole=>$whole, cssfile=>$cssfile, title=>$title, cssflameworks=>\@cssflameworks}))[0];
} # sub stand_alone

sub help{
  print pod2usage(-verbose => 2, -input => $FindBin::Bin . "/" . $FindBin::Script);
  exit();
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
my($footnote_cnt, %footnotes);
sub wini_sects{
  my($x, $opt) = @_;
  (defined $opt) or $opt={};
  #my($level, $tagtype, $secttytle, $k) = ('', '', '', '');
  my(%sectdata, $secttitle, @html, $htmlout);
  my @sectdata_depth = ([{sect_id=>'_'}]);
  my ($sect_cnt, $sect_id)       = (0, '_');
  my ($depth, $lastdepth)        = (0, 0);
  foreach my $t (split(/(^\?.*?\n)/m, $x)){ # for each section
    $t=~s/^\n*//;
    $t=~s/[\s\n]+$//;
    if($t=~/^(\?+[-<=>]*)([a-z]*)(?:#(\S*))?(?:\s+(.*))?/){ # begin sect
      my($level, $tagtype, $id, $k) = ($1, $2, $3, $4);
      
      # clarify section depth
      $lastdepth = $depth;
      if($level=~/^\?+$/){
        $depth = length($level);
      }elsif($level=~/^\?=/){ # new section at the same level
      }elsif($level=~/^\?</){
        $depth--;
      }elsif($level=~/^\?>/){
        $depth++;
      }elsif($level=~/^\?-/){ # end of the last section
        $depth=0;
      }
      $depth==0 and next;
      
      my $tag = {qw/a article s aside h header f footer n nav d details/}->{$tagtype};
      $sect_cnt++;
      $secttitle = $k  || undef;
      $sect_id   = $id || "sect${sect_cnt}";
      $sect_id=~s/[^\w]//g;
      (exists $sectdata{$sect_id}) and print STDERR "duplicated section id ${sect_id}\n";
      push(@{$sectdata_depth[$depth]}, {sect_id => $sect_id, tag => $tag});

      # add close tag for the former section here if necessary
      # and set open tag for the current section here
      my $opentag = qq{<$tag class="wini" id="${sect_id}">\n} .
        (($secttitle) ? qq{<h1 class="sectiontitle">$secttitle</h1>\n} : '');
      $html[$sect_cnt]{tag} = $tag;
      if($lastdepth==$depth){
        if($lastdepth>0){
          if($html[$sect_cnt-1]{sect_id} eq '_'){
            $DB::single=$DB::single=1;
          }
          $html[$sect_cnt-1]{close} ||=
          sprintf(
            qq{</%s> <!-- end of "%s" d=ld=$depth lastdepth=$lastdepth -->\n}, $html[$sect_cnt-1]{tag}, $html[$sect_cnt-1]{sect_id}
          );
        }
        $html[$sect_cnt]{open}    ||= $opentag;
      }elsif($lastdepth>$depth){ # new section of upper level
        if($sect_cnt>0 and $lastdepth>0){ # close tag for former sect
          (defined $html[$sect_cnt-1]{close}) or $html[$sect_cnt-1]{close}='';
          my $j=0;
          for(my $i=$lastdepth; $i>$depth; $i--){
            $j++;
            $html[$sect_cnt-1]{close} .= sprintf(
              qq{</%s> <!-- end of "%s" d=$i (%d) -->\n},
              $sectdata_depth[$i][-1]{tag}, $sectdata_depth[$i][-1]{sect_id}, $sect_cnt
           );
            ($j>1) and $DB::single=$DB::single=1;
            1;
          }
          ($depth>0) and $html[$sect_cnt-1]{close} .= sprintf(
            qq{</%s> <!-- end of "%s" *d=$depth (%d) -->\n},
            $sectdata_depth[$depth][-2]{tag}, $sectdata_depth[$depth][-2]{sect_id}, $sect_cnt
          );
        }
        $html[$sect_cnt]{open} = $opentag . (qq{<section>} x ($depth-1)) . "<!-- ${sect_id} -->\n";
      }else{ # new section is under the former section
        $html[$sect_cnt]{open} = $opentag;
      }
    }else{ # read sect content
      # read old sect vals
      for(my $d=0; $d<$depth; $d++){
        foreach my $k (keys %{$sectdata_depth[$d][-1]{val}}){
          $sectdata{$sect_id}{val}{$k} = $sectdata_depth[$d][-1]{val}{$k};
        }
      }
      # vars in sect/main
      my $v;
      $t=~s/===(.*)===/$v = &yaml($1, $opt); ''/es;
      foreach my $k (keys %$v){
        $sectdata_depth[$depth][-1]{val}{$k} = $v->{$k};
        $sectdata{$sect_id}{val}{$k}         = $v->{$k};
      }
      
      # WINI interpretation
      my $opt1 = { %$opt };
      $opt1->{_v} = $sectdata{$sect_id}{val};
      my($h, $o) = WINI::wini($t, $opt1);
      $html[$sect_cnt]{sect_id} = $sect_id;
      $html[$sect_cnt]{txt}     = $h;
      $html[$sect_cnt]{opt}     = $o;
      $html[$sect_cnt]{depth}   = $depth;
    } # read sect content
  } # foreach sect
  ($depth!=0) and $html[-1]{close} = ("\n" . ('</section>' x $depth));
  map{$htmlout .= "\n" . join("\n", $_->{open}, $_->{txt}, $_->{close})} @html;
  $htmlout .= "\n";

  # template?
  if(defined $sectdata_depth[0][-1]{val}{template}){ # template mode
    my $basefile = $sectdata_depth[0][-1]{val}{template};
    print STDERR ">>> templatemode: '$basefile'\n";
    (-f $basefile) or $basefile = $opt->{dir}."/$basefile";
    (-f $basefile) or $basefile =    "_template/$basefile";
    (-f $basefile) or die qq{File "$sectdata_depth[0][-1]{template}": not found};
    open(my $fhi, '<:utf8', $basefile);
    my $opt1 = { %$opt };
    foreach my $k (grep {$_ ne 'template'} keys %{$sectdata_depth[0][-1]{val}}){
      $opt1->{_v} = $sectdata_depth[0][-1]{val}{$k};
    }
    my $txt_from_tmpl = join('', <$fhi>);
    $htmlout = wini_sects($txt_from_tmpl, $opt1);
  }

  (defined $opt->{whole}) and $htmlout = whole_html($htmlout, $opt->{title}, $opt);
  return($htmlout);
}

sub wini{
# wini($tagettext, {para=>'br', 'is_bs4'=>1, baseurl=>'http://example.com', nocr=>1});
  # para: paragraph mode (br:set <br>, p: set <p>, nb: no separation
  # nocr: whether CRs are conserved in result text. 0(default): conserved, 1: not conserved
  # table: table-mode, where footnote macro is effective. $opt->{table} must be a table ID. Footnote texts are set to @{$opt->{footnote}}
  my($t0, $opt) = @_;
  $t0=~s/\r(?=\n)//g; # cr/lf -> lf
  $t0=~s/(?!\n)$/\n/s; 
  my($baseurl, $is_bs4, $cssfile) = map {$opt->{$_}} qw/baseurl is_bs4 cssfile/;
  my $cr    = (defined $opt->{nocr} and $opt->{nocr}==1)
              ?"\t":"\n"; # option to inhibit CR insertion (in table)
  my $para  = (defined $opt->{para}) ? $opt->{para} : 'p'; # p or br or none;
  my $title = $opt->{title} || 'WINI page';
  (defined $footnote_cnt) or $footnote_cnt->{'_'}{'*'} = 0;

  # verbatim
  $t0 =~ s/\%%%\n(.*?)\n%%%$/         &save_quote('',     $1)/esmg;
  # pre, code, citation, ...
  $t0 =~ s/\{\{(pre|code|q(?: [^|]+?)?)}}(.+?)\{\{end}}/&save_quote($1,$2)/esmg;  
  $t0 =~ s/^'''\n(.*?)\n'''$/         &save_quote('pre',  $1)/esmg;
  $t0 =~ s/^```\n(.*?)\n```$/         &save_quote('code', $1)/esmg;
  $t0 =~ s/^"""([\w =]*)\n(.*?)\n"""$/&save_quote("q $1", $2)/esmg;
    
  # conv table to html
  $t0 =~ s/^\s*(\|.*?)[\n\r]+(?!\|)/make_table($1)/esmg;

  # footnote
  if(exists $opt->{table}){ # in table
    footnote($t0, '*', $footnote_cnt->{$opt->{table}}, $footnotes{$opt->{table}});
  }else{ # for main text
    $t0=~s&\{\{\^\|([^}|]*)(?:\|([^}]*))?}}&
      footnote($1, $2, $footnote_cnt->{'_'}, $footnotes{'_'});
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
  #my $section;
  #my $myclass = ' class="'.join(' ',@localclass).'"';
  foreach my $t (split(/\n{2,}/, $t0)){ # for each paragraph
    my @myclass = @localclass;
    my($myclass, $myid) = ('', '');
    my $ptype; # type of each paragraph (list, header, normal paragraph, etc.)

    while(1){ # loop while subst needed      
      my($x, $id0, $cont) = $t=~/^(!+)([-#.\w]*)\s*(.*)$/m; # !!!...
      if($x){ # if header
        ($id0=~/^[^.#]/) and $id0=".$id0";
        while($id0=~/([#.])([^#.]+)/g){
          my($prefix, $label) = ($1, $2);
          ($label) or next;
          ($prefix eq '.') and push(@myclass, $label);
          ($prefix eq '#') and $myid = qq{ id="$label"};
        }
        my $tag0 = length($x); ($tag0>5) and $tag0="5";
        (defined $myclass[0]) and $myclass = qq{ class="} . join(" ", sort @myclass) . qq{"};
        $t=~s#^(!+)\s*(.*)$#<h${tag0}${myclass}${myid}>$cont</h${tag0}>#m;
        $ptype = 'header';
      } # endif header
      (
        $t =~ s!\[\[(\w+)(?:\|(.*))?\]\]!$opt->{_v}{$1}!ge or
        $t =~ s!(\{\{([^|]*?)(?:\|([^{}]*?))?}})!call_macro($1, $2, $opt, $baseurl, split(/\|/,$3||''))!esg or
        $t =~ s!\[([^]]*?)\]\(([^)]*?)\)!make_a_from_md($1, $2, $baseurl)!eg or
        $t =~ s!\[([^]]*?)\]!make_a($1, $baseurl)!eg #or
      ) or last; # no subst need, then escape inner loop
    } # loop while subst needed

    my($rr, $list) = list($t, $cr, $ptype, $para, $myclass);
    #(defined $section and $section ne '') and $rr="$section\n$r" and $section='';
    $r .= $rr;
  } # foreach $t # for each paragraph

  $r=~s/\x00i=(\d+)\x01/$save[$1]/ge;
  if($cssfile){
    open(my $fho, '>', $cssfile) or die "Cannot modify $cssfile";
    print {$fho} css($CSS);
    close $fho;
  }
  (defined $footnotes{'_'}[0]) and $r .= qq{<hr>\n<footer>\n<ul style="list-style:none;">\n} . join("\n", (map {"<li>$_</li>"}  @{$footnotes{'_'}})) . "\n</ul>\n</footer>\n";
  #(defined $section) and $r.="</section>\n";
  #(defined $opt->{whole}) and $r = whole_html($r, $title, $opt);
  ($opt->{table}) or $r=~s/[\s\n\r]*$//;
  return($r, $opt);
} # sub wini

sub whole_html{
  my($x, $title, $opt) = @_;
  $x=~s/[\s\n\r]*$//s;
  #  my($cssfile, $cssflameworks) = map {$opt->{$_}} qw/cssfile cssflameworks/;
  my $cssfile = $opt->{cssfile};
  my $style   = '';
  (defined $opt->{cssflameworks}[0]) and map {$style .= qq{<link rel="stylesheet" type="text/css" href="$_">\n}} @{$opt->{cssflameworks}};
  $style   .= ($cssfile)?qq{<link rel="stylesheet" type="text/css" href="$cssfile">} : "<style>\n".css($CSS)."</style>\n";
  return <<"EOD";
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
$style
<title>$title</title>
</head>
<body>
$x
</body>
</html>
EOD
}
} # wini env
  
sub footnote{
  my($txt, $style, $footnote_cnt, $footnotes_ref) = @_;
  my %cref = ('*'=>'lowast' ,'+'=>'plus', 'd'=>'dagger', 'D'=>'Dagger', 's'=>'sect', 'p'=>'para');
  $style = $style || '*';
  my($char, $char2) = $style=~/([*+dDsp])(\1)?/; # asterisk, plus, dagger, double-dagger, section, paragraph
  $char or $char = (($style=~/\d/)?'0':substr($style,0,1));
  my $prefix;
  if($char2){
    my $charchar = $char.$char;
    (defined $footnote_cnt->{$charchar}) or $footnote_cnt->{$charchar}=0;
    $footnote_cnt->{$charchar}++;
    $prefix = "\&$cref{$char};" x $footnote_cnt->{$charchar}; # *, **, ***, ...
  }else{
    (defined $footnote_cnt->{$char}) or $footnote_cnt->{$char}=0;
    $footnote_cnt->{$char}++;
    $prefix = "\&$cref{$char};$footnote_cnt->{$char}";    # *1, *2, *3, ...
  }
  push(@{$footnotes_ref}, "<sup>$prefix</sup>$txt");
  return("<sup>$prefix</sup>");
}

sub list{
  my($t, $cr, $ptype, $para, $myclass) = @_;
  my $r;
  my $t2='';
  my $lastlistdepth=0;
  my $listtagc;
  my @is_dl;  # $is_dl[1]: whether list type of depth 1 is 'dl'
  my @listtagc;
  my %listitems;
  foreach my $l (split("\n", $t)) {
    # line/page break
    if (($l=~s/^---$/<br style="page-break-after: always;">/) or
        ($l=~s/^--$/<br style="clear: both;">/)) {
      $t2 .= $l; next;
    }

    my($x, $listtype, $txt) = $l=~/^\s*([#*:;]*)([#*:;])\s*(.*)$/; # whether list item      
    if ($listtype ne '') {
      $ptype = 'list';
      my $listdepth = length($x)+length($listtype);
      ($listtype eq ';') and $is_dl[$listdepth]='dl';
      my($itemtag, $listtag) = ($listtype eq '*') ? qw/li ul/
        : ($listtype eq ':') ? (($is_dl[$listdepth] eq 'dl')?qw/dd dl/:(qq{li style="list-style:none"}, 'ul'))
        : ($listtype eq ';') ? qw/dt dl/ : qw/li ol/;
      my $itemtagc = $itemtag;   # closing tag for list item
      $listtagc = $listtag;      # closing tag for list
      $itemtagc =~ s/ .*//;
      $listtagc =~ s/ .*//;
      $listtagc[$listdepth] = $listtagc;
      # new list start?
      if ($listdepth>$lastlistdepth) {
        $t2 .= sprintf(qq!%*s<$listtag class="winilist">$cr!, $listdepth, ' ');
      }
      # new list end?
      for (my $i = $lastlistdepth-$listdepth; $i>0; $i--) {
        $t2 .= sprintf("%*s</%s>$cr", $i+$listdepth, ' ', $listtagc[$i+$listdepth]);
      }
      $t2 .= sprintf("%*s<$itemtag>$txt</$itemtagc>$cr",$listdepth+1,' ');
      $lastlistdepth = $listdepth;
      push(@{$listitems{join("\t", @listtagc)}}, $txt);
    } else { # if not list item
      $t2 .= "$l\n";
    }
  } # $l
  if ($lastlistdepth>0) {
    $t2 .= sprintf("%*s", $lastlistdepth-1, ' ') . ("</$listtagc>" x $lastlistdepth) . $cr;
    $lastlistdepth=0;
  }

  if($t2=~/\S/){
    $r = ($ptype eq 'header' or $ptype eq 'list')                                      ? "$t2\n"
       : ($para eq 'br')                                                               ? "$t2<br>$cr"
       : ($para eq 'nb')                                                               ? $t2
       : $t2=~m{<(html|body|head|p|table|img|figure|blockquote|[uod]l)[^>]*>.*</\1>}is ? $t2
       : $t2=~m{<!doctype}is                                                           ? $t2
       : "<p${myclass}>\n$t2</p>$cr$cr";
  }
  return($r || '', \%listitems);
} # sub list

sub close_listtag{
  my($ref, $l) = @_;
  map{
    $$ref .= (' ' x ($#$l-$_)) . (($l->[$_] eq 'ul')?'</ul>':($l->[$_] eq 'ol')?'</ol>':'</dl>') . "\n";
  } 0..$#$l;
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

sub call_macro{
  my($fulltext, $macroname, $opt, $baseurl, @f) = @_;
  my(@class, @id);
  $macroname=~s/\.([^.#]+)/push(@id,    $1); ''/ge;
  $macroname=~s/\#([^.#]+)/push(@class, $1); ''/ge;
  my $class_id = join('', map{ qq! class="$_"! } @class);
  $class_id   .= ($id[0]) ? qq! id="$id[0]"! : '';
  $macroname=~s/^[\n\s]*//;
  $macroname=~s/[\n\s]*$//;
  if($macroname eq ''){
    return(($class_id) ? qq!<span${class_id}>$f[0]</span>! : $f[0]);
  }

  (defined $macros{$macroname}) and return($macros{$macroname}(@f));
  ($macroname eq 'calc')   and return(ev(\@f, $opt->{_v}));
#  ($macroname eq 'va')     and return(var($f[0], $opt->{_v}));
  ($macroname eq 'va')     and return($opt->{_v}{$f[0]});
  ($macroname eq 'envname')and return($ENVNAME);
  ($macroname=~/^[IBUS]$/) and $_=lc($macroname), return("<$_${class_id}>$f[0]</$_>");
  ($macroname eq 'i')      and return(qq!<span${class_id} style="font-style:italic;">$f[0]</span>!);
  ($macroname eq 'b')      and return(qq!<span${class_id} style="font-weight:bold;">$f[0]</span>!);
  ($macroname eq 'u')      and return(qq!<span${class_id} style="border-bottom: solid 1px;">$f[0]</span>!);
  ($macroname eq 's')      and return(qq!<span${class_id} style="text-decoration: line-through;">$f[0]</span>!);
  ($macroname eq 'ruby')   and return(ruby(@f));
  ($macroname eq 'v')      and return(qq!<span class="tategaki">$f[0]</span>!);

  ($macroname eq 'l')      and return('&#x7b;'); # {
  ($macroname eq 'bar')    and return('&#x7c;'); # |
  ($macroname eq 'r')      and return('&#x7d;'); # }
  ($macroname eq '<')      and return('&#x3c;'); # <
  ($macroname eq '>')      and return('&#x3e;'); # >
  ($macroname eq '[')      and return('&#x5b;'); # [
  ($macroname eq ']')      and return('&#x5d;'); # ]

  ($macroname=~m!([-_/*]+[-_/* ]*)!) and return(symmacro($1, $f[0]));

  warn("Macro named '$macroname' not found");
  my $r = sprintf(qq#\\{\\{%s}}<!-- Macro named '$macroname' not found! -->#, join('|', $macroname, @f));
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
    (exists $pars{$k}) or $pars{$k} = shift(@pars);
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
                      :($cmd eq 'pre') ?('<pre>',      '</pre>') : ('', '');
    return("$ltag\n\x00i=$i\x01\n$rtag");
  }
}
}

# [xxxx] -> <a href="www">...</a>
{
my $img_no=0;
sub make_a_from_md{
  my($t, $url, $baseurl) = @_;
  return(qq!<a href="$url">$t</a>!);
}

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
  #my($x) = @_; # text1|ruby1|text2|ruby2 ...
  my @txt = @_; #split(/\|/, $x);
  my $t = join("", map {my $a=$_*2; "$txt[$a]<rp>(</rp><rt>$txt[$a+1]</rt><rp>)</rp>"} (0..$#txt/2));
  return("<ruby>$t</ruby>");
}

{
my $table_no;
sub make_table{
  my($in, $footnotes)=@_;
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
    ($htmlitem[0][0]{copt}{id}[0]) or $htmlitem[0][0]{copt}{id}[0] = sprintf("winitable%d", $table_no++);
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
  ''&emg; # end of caption & table setting

  my @lines = split(/\n/, $in);
  my $macro = '';
  my %macros;
  my %fn_cnt;
  foreach my $line (@lines){
    $line=~s/[\n\r]*//g;
    ($line eq '') and next;

    # deal with inner-cell footnotes
    if($line=~/\{\{\^\|(.*?)}}/){
      $line=~s!\{\{\^\|(.*?)}}!
        my($txt, @p) = split(/\|/, $1);
        my $fn_mark  = $p[0] || '*';
        #my($r, $opt) = wini($1, {para=>'nb', nocr=>1, table=>$table_no});
        footnote($txt, $fn_mark, \%fn_cnt, \@footnotes);
      !e;
    }
    my @cols = split(/((?:^| +)\|\S*)/, $line);

    # standardize target text
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
    if($winiitem[$ln][1] =~ /^\|---/){
      $htmlitem[$ln][0]{footnote}=$winiitem[$ln][2];
    }
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

        while($col=~/(&{1,3})([lrcjsetmb])/g){ # text-align
          my($a,$b)=($1,$2);
          my $h = {qw/l left r right c center j justify s start e end/}->{$b};
          my $v = {qw/t top m middle b bottom/}->{$b};
          if($a eq '&&&'){
            (defined $h) and push(@{$htmlitem[0][$col_n]{copt}{style}{'text-align'}}, $h);
            (defined $v) and push(@{$htmlitem[0][$col_n]{copt}{style}{'vertical-align'}}, $v);
          }else{
            (defined $h) and push(@{$htmlitem[$ln][($a eq '&&')?0:$col_n]{copt}{style}{'text-align'}}, $h);
            (defined $v) and push(@{$htmlitem[$ln][($a eq '&&')?0:$col_n]{copt}{style}{'vertical-align'}}, $v);
          }
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
      #(exists $opt->{footnote}) and push(@{$footnotes->{$table_no}}, @{$opt->{footnote}});
      $cell->{wini} =~ s/\t *//g;
      $cell->{wini} =~ s/[ \n]+/ /g;
      $htmlitem[$ln][$i] = $cell; # $htmlitem[$ln][0]: data for row (tr)
      $rowlen[$ln] += (defined $htmlitem[$ln][$i]{wini})?(length($htmlitem[$ln][$i]{wini})):0;
    }
  } # for $ln

  (defined $htmlitem[0][0]{copt}{style}{height}[0])
        or $htmlitem[0][0]{copt}{style}{height}[0] = sprintf("%drem", (scalar @lines)*2);
  (defined $htmlitem[0][0]{copt}{style}{width}[0])
        or $htmlitem[0][0]{copt}{style}{width}[0] = sprintf("%drem", ((sort @rowlen)[-1])*2);

  ($debug) and print(STDERR "winiitem\n", (Dumper @winiitem), "htmlitem\n", (Dumper @htmlitem));

  # make html
  my $outtxt = sprintf(qq!\n<table id="%s" class="%s"!, $htmlitem[0][0]{copt}{id}[0], join(' ', sort @{$htmlitem[0][0]{copt}{class}}));
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
    ((not defined $htmlitem[0][0]{copt}{bborder}) and (defined $htmlitem[0][0]{copt}{tborder}))
      and $htmlitem[0][0]{copt}{bborder} = $htmlitem[0][0]{copt}{tborder};

    #(defined $htmlitem[0][0]{copt}{border}) and $outtxt .= sprintf("border: solid %dpx; ", $htmlitem[0][0]{copt}{border});
    (defined $styles[0]) and $ropt .= qq{style="} . join('; ', sort @styles) . '"';  

    if(defined $htmlitem[$rn][0]{copt}{class}[0]){
      $ropt .= q{ class="} . join(' ',  sort @{$htmlitem[$rn][0]{copt}{class}}) . q{"};
    }
    ($ropt) and $ropt = " $ropt";
    $outtxt0 .= qq!<tr$ropt>! . join("", map { # for each cell ($_: col No.)
      if((defined $htmlitem[$rn][$_]{copt}{rowspan} and $htmlitem[$rn][$_]{copt}{rowspan}<=1) or (defined $htmlitem[$rn][$_]{copt}{colspan} and $htmlitem[$rn][$_]{copt}{colspan}<=1)){
        '';
      }else{ #not rowspan or colspan
        my $copt = '';
        my %style;
        if(my $bb=$htmlitem[0][0]{copt}{bborder}){
          $style{border} .= "solid ${bb}px";
        }
        foreach my $c (qw/class colspan rowspan/){
          ($c eq 'rowspan') and ($htmlitem[$rn][0]{footnote}) and next;
          (defined $htmlitem[$rn][$_]{copt}{$c}) and
            $copt .= sprintf(qq{ $c="%s"},
                       (ref $htmlitem[$rn][$_]{copt}{$c} eq 'ARRAY') 
                         ? join(' ', sort @{$htmlitem[$rn][$_]{copt}{$c}}) 
                         : $htmlitem[$rn][$_]{copt}{$c});
        }
        if(defined $htmlitem[0][$_]{copt}{style}){ # &&& -> &
          foreach my $k (keys %{$htmlitem[0][$_]{copt}{style}}){
            map {$style{$k} = $_} (@{$htmlitem[0][$_]{copt}{style}{$k}});
          }
        }
        if(defined $htmlitem[$rn][$_]{copt}{style}){
          foreach my $c (keys %{$htmlitem[$rn][$_]{copt}{style}}){
            map {$style{$c} = $_} (@{$htmlitem[$rn][$_]{copt}{style}{$c}});
          }
        }
        $copt .= ' style="' . join('', sort map { "$_:$style{$_}; " } grep {$style{$_}} sort keys %style) . '"'; #option for each cell
        my $ctag = (
          (not $htmlitem[$rn][0]{footnote}) and (
          ($htmlitem[$rn][$_]{ctag} eq 'th') or 
          ($htmlitem[0][$_]{ctag}   eq 'th') or
          ($htmlitem[$rn][0]{ctag}  eq 'th'))
        )?'th':'td';
        $copt and $copt=" $copt";
        sprintf("<$ctag$copt>%s</$ctag>", $htmlitem[$rn][$_]{wini});
      }
    } (1 .. $#{$htmlitem[1]}) # map
    ); # join
    $outtxt0 .= "</tr>\n";
    (defined $htmlitem[$rn][0]{footnote}) ? ($footnotetext .= $htmlitem[$rn][0]{footnote}."; ") : ($outtxt .= $outtxt0);
    #($htmlitem[$rn][0]{footnote})
    #  ? ($footnotetext .= join('<br>', grep {/\S/} map {$htmlitem[$rn][$_]{val}} 1..$#{$htmlitem[$rn]}) . "<br>\n")
    #  : ($outtxt .= $outtxt0);
  } # foreach $rn
  $outtxt .= "</tbody>\n";
  if((defined $footnotes[0]) or (defined $footnotes->{$table_no} and scalar @{$footnotes->{$table_no}} > 0) or $footnotetext){
    $outtxt .= (defined $htmlitem[0][0]{copt}{fborder})?qq{<tfoot style="border: solid $htmlitem[0][0]{copt}{fborder}px;">\n}:"<tfoot>\n";
    #my $colspan = scalar @{$htmlitem[-1]} -1;
    $outtxt .= sprintf(qq!<tr><td colspan="%d">!, $#{$htmlitem[1]});
    (defined $footnotetext) and $outtxt .= $footnotetext;
    $outtxt .= join(";\n", @footnotes);
    #(scalar @{$footnotes->{$table_no}} > 0) and $outtxt .= sprintf(qq{<tr><td colspan="$colspan">%s</td></tr>\n}, join('&ensp;', @{$footnotes->{$table_no}}));
    $outtxt .= "</td></tr>\n</tfoot>\n";
  }
  $outtxt .= "</table>\n\n";
  $outtxt=~s/\t+/ /g; # tab is separator of cells vertically unified
  return($outtxt);
} # sub make_table

} # table env

{
my %vars;
my $avail_yamltiny;

sub yaml{
  my($x, $opt) = @_;
  my $val = $opt->{_v};
  my($package,$filename,$line) = caller();
  if($opt and $avail_yamltiny){
    my $yaml = YAML::Tiny->new;
    $val     = ($yaml->read_string($x))[0][0];
  }else{
    foreach my $line (split(/\s*\n\s*/, $x)){
      if(my($k,$v) = $line=~/^\s*([^: ]+):\s*(.*)\s*$/){
        ($v eq '') and next;
        if($v=~/^\[(.*)\]$/){ # array
          $val->{$k} = [map {s/^(["'])(.*)\1$/$2/; $_} split(/\s*,\s*/, $1)];
        }elsif(my($v2) = $v=~/^\{(.*)\}$/){ # hash
          foreach my $token (split(/\s*,\s*/, $v2)){
            my($kk,$vv) = $token=~/(\S+)\s*:\s*(.*)/;
            $vv=~s/^(["'])(.*)\1$/$2/;
            $val->{$k}{$kk} = ev($vv, $val);
          }
        }else{ # simple variable
          if($v=~s/^(["'])(.*)\1$/$2/){
            $val->{$k} = $2;
          }else{
            $val->{$k} = ev($v, $val) ;
          }
        }
      }
    } # for each $line
  }
  return($val);
} # sub yaml

sub ev{ # <, >, %in%, and so on
  my($x, $v) = @_;
  # $x: string or array reference. string: 'a,b|='
  # $v: reference of variables given from wini()
  my($package,$filename,$line) = caller();
  
  my(@token) = (ref $x eq '') ? (undef, split(/((?<!\\)[,|])/, $x))
             : (undef, map{ (split(/((?<!\\)[,|])/, $_)) } @$x);
  my @stack;
  for(my $i=1; $i<=$#token; $i++){
    my $t  = $token[$i];
    if($t eq ','){
#      push(@stack, $token[$i-1]);
    }elsif($t eq '|'){
#      push(@stack, $token[$i-1]);
    }elsif($t eq '&u'){
      push(@stack, uc      $token[$i-2]);
    }elsif($t eq '&ul'){
      push(@stack, ucfirst $token[$i-2]);
    }elsif($t eq '&l'){
      push(@stack, lc      $token[$i-2]);
    }elsif($t eq '&ll'){
      push(@stack, lcfirst $token[$i-2]);
    }elsif($t=~/([<>]+)(.+)/){
      my($op,$val) = ($1,$2);
      if($op eq '>'){
      }
    }elsif(my($op) = $t=~/^\&([nlt](min|max|sort|rev)?i?|mean|total|sum|rev|cat\W*)$/){
      ($op eq 'n')     and (@stack = (scalar @stack)), next;
      ($op eq 'nsort') and (@stack = sort {$a<=>$b} @stack), next;
      ($op eq 'tsort') and (@stack = sort {$a cmp $b} @stack), next;
      ($op eq 'rev')   and (@stack = reverse @stack), next;
      my $op1; (($op1)=$op=~/cat\\?(.*)/) and (@stack = join($op1, @stack)), next;
      my %s;
      map {$s{$_}=$stack[1]} qw/tmin tmax nmin nmax lmax lmin/;
      for(my $i=0; $i<=$#stack; $i++){
        ($stack[$i]>$s{nmax})         and ($s{nmax}, $s{nmaxi}) = ($stack[$i], $i);
        ($stack[$i]<$s{nmin})         and ($s{nmin}, $s{nmini}) = ($stack[$i], $i);
        ($stack[$i] gt $s{tmax})      and ($s{tmax}, $s{tmaxi}) = ($stack[$i], $i);
        ($stack[$i] lt $s{tmin})      and ($s{tmin}, $s{tmini}) = ($stack[$i], $i);
        (length($stack[$i])>$s{lmax}) and ($s{lmax}, $s{lmaxi}) = ($stack[$i], $i);
        (length($stack[$i])<$s{lmin}) and ($s{lmin}, $s{lmini}) = ($stack[$i], $i);
        $s{sum}=$s{total}+=$stack[$i];
      }
      $s{mean} = $s{total}/(scalar @stack);
      push(@stack, $s{$op});
    }elsif(($op) = $t=~m{^(\+|-|/|\*|%|\&(?=eq|ne|lt|gt|le|ge)|==|!=|<|<=|>|>=)$}){
      my($y) = pop(@stack);
      my($x) = pop(@stack);
      my $r=(
        ($op eq '+' )?($x +  $y)
             :($op eq '-'  )?($x -  $y)
             :($op eq '*'  )?($x *  $y)
             :($op eq '/'  )?(($y==0)?undef:($x / $y))
             :($op eq '%'  )?(($y==0)?undef:($x % $y))
             :($op eq '&eq')?($x eq $y)
             :($op eq '&ne')?($x ne $y)
             :($op eq '&lt')?($x lt $y)
             :($op eq '&gt')?($x gt $y)
             :($op eq '&le')?($x le $y)
             :($op eq '&ge')?($x ge $y)
             :($op eq '==' )?($x == $y)
             :($op eq '!=' )?($x != $y)
             :($op eq '<'  )?($x <  $y)
             :($op eq '<=' )?($x <= $y)
             :($op eq '>'  )?($x >  $y)
             :($op eq '>=' )?($x >= $y):undef
      );
      push(@stack, $r);
    }elsif($t=~/(["'])(.*)\1/){ # constants (string)
      push(@stack, $2 . '');
    }elsif($t=~/^\d+$/){ # constants (numeral)
      push(@stack, $t);
    }else{ # variables or formula
      if($t=~/^\w+$/){
        $DB::single=$DB::single=1;
        push(@stack, $v->{$t});
      }else{
  # SHould call var() rather than array().
        push(@stack, array($t));
      }
    }
  }
  return($stack[-1]);
} # end of ev

sub array{
  my($x, $val) = @_;
  if($x=~/^os$/i){
    return($^O);
  }elsif($x=~/^([ac])?(date|time)$/){
    my($t1, $t2, $lt)=($1, $2, localtime);
    ($t1) or return($lt->datetime);
  }else{
    return($val->{$x});
  }
  return(undef);
}
} # val env

1;
