#!/usr/bin/env perl
=head1 NAME

Text::Markup::Wini.pm - WIki markup ni NIta nanika (Japanese: "Something like wiki markup")

=head1 SYNOPSIS

 use Wini;

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

The script file Wini.pm is a perl module supporting WINI markup, which is a simple markup language to build HTML5 texts. This script can also be used as a stand-alone perl script. Users easily can get HTML5 documents from WINI source texts, by using Wini.pm as a filter command.

The text presented here is just a brief description.

Please refer to the synopsis of this page to grasp ontline about WINI markup. 

Please refer to the homepage for details. 

=head2 As module

Put this script file in the directory listed in @INC. If you are not clear about what @INC is, please try 'perldoc perlvar'.
Add 'use Wini;' in the begining of your script to use functions of Wini.pm.  

=head2 As stand-alone script

Put this script file in the directory listed in your PATH. The script file name can be renamed as 'wini' instead of 'Wini.pm'. Do 'chmod a+x Wini.pm'. It might be required to do 'hash' ('rehash' in zsh) to make your shell recognize Wini.pm as a valid command name.

If you succeed the install, you can use this script as follows:

 $ Wini.pm < input.wini > output.html

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

Set input file name to INPUT. If the file named 'INPUT' does not exists, Wini.pm looks for 'INPUT.wini'. If -i is not set, Wini.pm takes data from standard input.

=item B<-o> I<OUTPUT>

Set output file name. If both -o and -i are omitted, Wini.pm outputs HTML-translated text to standard output.
If -o is omitted and the input file name is 'input.wini', the output file will be 'input.wini.html'.
Users can specify the output directory rather than the file. If -o value ends with 'output/', output file will be output/input.wini.html. if 'output/' does not exist, Wini.pm will create it.

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

=item B<--quiet>

Suppress additional message output

=item B<--force>

Ignore errors and continue process.

=item B<--version>

Show version.

=item B<--help>

Show this help.

=back
=cut

package Text::Markup::Wini;
#use Text::Wini;
use 5.8.1;
use strict;
use POSIX qw/locale_h/;
use locale;
use utf8;
use Data::Dumper;
use File::Basename;
use File::Path 'mkpath';
use FindBin;
use Pod::Usage;
use Getopt::Long qw(:config no_ignore_case auto_abbrev);
use Encode;
use Cwd;
use Time::Piece;
use Module::Load qw( load );
#load('YAML::Tiny');

our $ENVNAME;
#our %EXT;
our $LANG;
our $QUIET;
our %MACROS;
our %VARS;
our %REF;
our %REFCOUNT;
our %REFASSIGN;
our %TXT;
our($MI, $MO);
our(@INDIR, @INFILE, $OUTFILE);
our($TEMPLATE, $TEMPLATEDIR);
my(@libs, @libpaths, $SCRIPTNAME, $VERSION, $debug);
my @save;
my $FORCE;

# barrier-free color codes: https://jfly.uni-koeln.de/html/manuals/pdf/color_blind.pdf
our ($red, $green, $blue, $magenta, $purple) 
  = map {sprintf('rgb(%s) /* %s */', @$_)} 
  (['219,94,0', 'red'], ['0,158,115', 'green'], ['0,114,178', 'blue'], ['218,0,250', 'magenta'], ['204,121,167', 'purple']);
our $CSS = {
  'ol, ul, dl' => {'padding-left'     => '1em'},
  'table, figure, img' 
	       => {'margin'           => '1em',
	           'border-collapse'  => 'collapse'},
  'tfoot, figcaption'
               => {'font-size'        => 'smaller'},
  '.b-r'       => {'background-color' => $red},
  '.b-g'       => {'background-color' => $green},
  '.b-b'       => {'background-color' => $blue},
  '.b-w'       => {'background-color' => 'white'},
  '.b-b25'     => {'background-color' => '#CCC'},
  '.b-b50'     => {'background-color' => '#888'},
  '.b-b75'     => {'background-color' => '#444'},
  '.b-b100'    => {'background-color' => '#000'},
  '.b-m'       => {'background-color' => $magenta},
  '.b-p'       => {'background-color' => $purple},
  '.f-r'       => {'color' => $red,    'border-color' => 'black'},
  '.f-g'       => {'color' => $green,  'border-color' => 'black'},
  '.f-b'       => {'color' => $blue,   'border-color' => 'black'},
  '.f-w'       => {'color' => 'white',       'border-color' => 'black'},
  '.f-b25'     => {'color' => '#CCC',        'border-color' => 'black'},
  '.f-b50'     => {'color' => '#888',        'border-color' => 'black'},
  '.f-b75'     => {'color' => '#444',        'border-color' => 'black'},
  '.f-b100'    => {'color' => '#000',        'border-color' => 'black'},
  '.f-m'       => {'color' => $magenta,'border-color' => 'black'},
  '.f-p'       => {'color' => $purple, 'border-color' => 'black'},
  '.tategaki'  => {'-ms-writing-mode' => 'tb-rl', 'writing-mode' => 'vertical-rl', '-webkit-text-orientation' => 'mixed',   'text-orientation' => 'mixed'},
  '.tatetate'  => {'-ms-writing-mode' => 'tb-rl', 'writing-mode' => 'vertical-rl', '-webkit-text-orientation' => 'upright', 'text-orientation' => 'upright'},
  '.yokoyoko'  => {'-ms-writing-mode' => 'tb-rl', 'writing-mode' => 'vertical-rl', '-webkit-text-orientation' => 'sideways', 'text-orientation' => 'sideways'}
};

__PACKAGE__->stand_alone() if !caller() || caller() eq 'PAR';

sub init{
  setlocale(LC_ALL, 'C');
  setlocale(LC_TIME, 'C');
  no warnings;
  *Data::Dumper::qquote = sub { return encode "utf8", shift } ;
  $Data::Dumper::Useperl = 1 ;
  use warnings;
  binmode STDIN, ':utf8';
  binmode STDERR,':utf8';
  binmode STDOUT,':utf8';
#  ($MI, $MO)  = ("\x00", "\x01");
  ($MI, $MO)  = ("<<<", ">>>");
  $ENVNAME    = "_";
  $LANG       = 'en';
  $QUIET      = 0; # 1: suppress most of messages
  $SCRIPTNAME = basename($0);
  $VERSION    = "ver. 1.0alpha rel. 20220114";
  while(<Text::Markup::Wini::DATA>){
    chomp;
    my $sp = '\\' . substr($_, 0, 1);
    my($id, $en, $ja) = split($sp, substr($_,1));
    $TXT{$id} = {en=>$en, ja=>$ja};
  }
}

# Following function is executed when this script is called as stand-alone script
sub stand_alone{
  init();
  my(@input, $output, $fhi, $title, $cssfile, $test, $whole, @cssflameworks);
  GetOptions(
    "h|help"         => sub {help()},
    "v|version"      => sub {print STDERR "Wini.pm $VERSION\n"; exit()},
    "i=s"            => \@input,
    "o=s"            => \$output,
    "title=s"        => \$title,
    "cssfile:s"      => \$cssfile,
    "E|extralib:s"   => \@libs,
    "I|libpath:s"    => \@libpaths,
    "lang=s"         => \$LANG,
    "T"              => \$test,
    "D"              => \$debug,
    "whole"          => \$whole,
    "cssflamework:s" => \@cssflameworks,
    "template=s"     => \$TEMPLATE,
    "templatedir=s"  => \$TEMPLATEDIR,
    "force"          => \$FORCE,
    "quiet"          => \$QUIET
  );
  foreach my $i (@libpaths){
    mes(txt('ttap', undef, {path=>$i}), {ln=>__LINE__});
    (-d $i) ? push(@INC, $i) : mes(txt('elnf', undef, {d=>$i}), {warn=>1});
  }
  foreach my $lib (@libs){ # 'form', etc.
    my $r = eval{load($lib)};
    mes((defined $r) ? txt('ll', undef, {lib=>$lib}) : txt('llf', undef, {lib=>$lib}));
  }

  (defined $cssflameworks[0]) and ($cssflameworks[0] eq '') and $cssflameworks[0]='https://unpkg.com/mvp.css'; # 'https://newcss.net/new.min.css';
  ($test) and ($INFILE[0], $OUTFILE)=("test.wini", "test.html");

  # check input/output
  my($ind, $inf, $outd, $outf) = winifiles(\@input, $output);
  if(defined $outd){
    (-f $outd) and unlink $outd;
    (-d $outd) or mkdir $outd;
  }
  if(defined $inf->[0]){
    mes(txt('if') . join(' ', @$inf), {q=>1});
  } else {
    push(@$inf, '');
  }
  
  (defined $cssfile) and ($cssfile eq '') and $cssfile="wini.css";

  # output
  if(scalar @$outf>1){
    # 1. multiple infile -> multiple outfile (1:1)
    for(my $i=0; $i<=$#$inf; $i++){
      if($inf->[$i] eq ''){
        mes(txt('conv', undef, {from=>'STDIN', to=>$outf->[$i]}), {q=>1});
        $fhi=*STDIN;
      }else{
        mes(txt('conv', undef, {from=>$inf->[$i], to=>$outf->[$i]}), {q=>1});
        open($fhi, '<:utf8', $inf->[$i]);
      }
      open(my $fho, '>:utf8', $outf->[$i]);
      my $winitxt = join('', <$fhi>);
      $winitxt=~s/\x{FEFF}//; # remove BOM if exists
      my($htmlout) = to_html($winitxt, {indir=>$ind, dir=>getcwd(), whole=>$whole, cssfile=>$cssfile, title=>$title, cssflameworks=>\@cssflameworks});
      print {$fho} $htmlout;
    }
  }else{
    # 2. infiles -> one outfile or STDOUT
    my $fho;
    if(defined $outf->[0]){
      (-f $outf->[0]) and unlink $outf->[0];
      open($fho, '>:utf8', $outf->[0]);
    }else{
      $fho = *STDOUT;
    }
    my $winitxt = '';
    map {
      my $fhi;
      ($_ eq '') ? $fhi=*STDIN : (
         open($fhi, '<:utf8', $_) or die txt('cno', undef, {f=>$_}) || mes(txt('ou', undef, {f=>$_}), {q=>1})
      );
      while(<$fhi>){
        s/[\n\r]*$//; s/\x{FEFF}//; # remove BOM if exists
        $winitxt .= "$_\n";
      }
      $winitxt .= "\n\n";
    } @$inf;
    my($htmlout) = to_html($winitxt, {indir=>$ind, dir=>getcwd(), whole=>$whole, cssfile=>$cssfile, title=>$title, cssflameworks=>\@cssflameworks});
    print {$fho} $htmlout;
  }
#  print STDERR "dump for ref: ", Dumper %REF;
#  print STDERR "dump for refcount: ", Dumper %REFCOUNT;
#  print STDERR "dump for refassign: ", Dumper %REFASSIGN;
} # sub stand_alone

sub txt{ # multilingual text from text id
  my($id, $lang, $par) = @_;
  #|fin|completed|終了|
  #id: 'fin', lang:'ja'
  #$par: hash reference for paragraph
  $lang = $lang || $LANG || 'en';
  (defined $TXT{$id}) or mes(txt('ut'). ": '$id'", {warn=>1});
  my $t = $TXT{$id}{$lang} || $TXT{$id}{en} || '';
  $t=~s/\{\{(.*?)}}/
  (defined $par->{$1})        ? $par->{$1} : 'xxx'; 
  /ge;
  return($t);
} # sub txt

sub mes{ # display guide, warning etc. to STDERR
  my($x, $o) = @_;
# $o->{err}: treat $x as error and die
# $o->{warn}: treat $x as warning and use warn()
# $o->{q}: do not show caller-related info
# $o->{ln}: line number
# $QUIET: show err or warn, but any others are omitted
  chomp $x;
  my $mes;
  my $ind = '';
  my($mestype, $col) = (exists $o->{err})  ? ('Error',   "\e[37m\e[41m")
                     : (exists $o->{warn}) ? ('Warning', "\e[31m\e[47m") : ('Message', "\e[0m");
  my $ln = ($o->{ln}) ? ":$o->{ln}" : '';
  if((not exists $o->{q}) and $QUIET==0){
    my $i = 1; my @subs;
    while ( my($pack, $file, $line, $subname, $hasargs, $wantarray, $evaltext, $is_require) = caller( $i++) ){push(@subs, "$line\[$subname]")}
    $mes = txt('mt', undef, {col=>$col, reset=>"\e[0m", mestype=>txt($mestype), ln=>$ln}) . join(' <- ', @subs);
    print STDERR "${col}$mes\e[0m\n";
    $ind='  ';
  }
  ($QUIET==0) and (exists $o->{ln}) and $x = sprintf("${x} at %d [Wini.pm] ", $o->{ln});
  if(exists $o->{err}){
    (($FORCE) and print STDERR "$ind$x\n") or die "$ind$x\n";
  }elsif($o->{warn}){
    warn("$ind$x\n");
  }else{
    ($QUIET==0) and print STDERR "$ind$x\n";
  }
  return($x);
} # sub mes

sub help{
  print pod2usage(-verbose => 2, -input => $FindBin::Bin . "/" . $FindBin::Script);
  exit();
}

sub color{
  my($colorname) = @_;
  return(
    ($colorname eq 'red') ? $red
   :($colorname eq 'green') ? $green
   :($colorname eq 'blue') ? $blue
   :($colorname eq 'purple') ? $purple
   :($colorname eq 'magenta') ? $magenta:$colorname
  );
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

sub winifiles{
  my($in, $out) = @_;
  # $in: string or array reference
  # $out: string (not array reference)
  my($indir, @infile, $outdir, @outfile);
  my @in;
  (defined $in) and @in = (ref $in eq 'ARRAY') ? @$in : ($in);
  #my @out;
  #(defined $out) and @out = (ref $out eq 'ARRAY') ? @$out : ($out);
  
  # check $indir
  foreach my $in1 (@in){
    my(@in1x) = ($in1);
    (not -e $in1) and map {my $a="$in1.$_"; push(@in1x, $a); (-f $a) and $in1=$a} qw/mg wini par/;
    (not -e $in1) and mes(txt('fnf').": ". join(" / ", @in1x), {err=>1});
    if(not defined $in1){
    }elsif(-d $in1){
      mes(txt('dci', {d=>$in1}), {q=>1});
      $indir = $in1;
      $indir=~s{/$}{};
    }elsif(not -f $in1){ # non-existing entry, x/=dir x.wini=file
      ($in1=~m{/$}) ? ($indir = $in1) : push(@infile, $in1);
    }else{ # existing normal file
      mes(txt('fci',undef, {f=>$in1}), {q=>1});
      push(@infile, $in1);
    }
  }
  if((not defined $infile[0]) and (defined $indir)){
    findfile($indir, sub{$_[0]=~/\.(wini|par|mg)$/ and push(@infile, $_[0])});
  }

  # check $outdir

  if(not defined $out){
    if(not defined $in){
    }

  }elsif(-d $out){
    mes(txt('dco', {d=>$out}), {q=>1});
    $outdir = $out;
    ($outdir=~m{^/}) or $outdir = cwd()."/$outdir";
  }elsif(-f $out){
    $outfile[0] = $out;
  }else{ # new entry
    ($out=~m{(.*)/$}) ? ($outdir = $1) : ($outfile[0] = $out);
  }
  
  if(defined $outdir){
    if(($outdir eq '.') or ($outdir=~m{/\.+$})){
      $outdir = cwd();
    }
    #$outdir=~s{/$}{};
    foreach my $in1 (@infile){
      my($base, $indir1, $ext) = fileparse($in1, qw/.wini .par .mg/);
      ($indir1 eq './') and $indir1='';
      $indir1=~s{/$}{};
      (defined $indir) and $indir1=~s{^$indir(/|$)}{};
      my $outdir1 = "$outdir" . (($indir1 eq '') ? '' : "/$indir1");
      my $d1 = '';
      (-d $outdir1) or (mkpath $outdir1) or die "Failed to create $outdir";
      push(@outfile, "$outdir1/$base.html");
    }
  }
  mes(
    "indir:   " . (($indir)?$indir:'undef') . "\n" .
    "infile:  " . (($infile[0])?join(' ', @infile):'undef') . "\n" .
    "outdir:  " . (($outdir)?$outdir:'undef') . "\n" .
    "outfile: " . (($outfile[0])?join(' ',@outfile):'undef'), {q=>1}
     );
  (defined $indir  or defined $infile[0])  or mes(txt('din'), {q=>1});
  (defined $outdir or defined $outfile[0]) or mes(txt('rout'), {q=>1});  
  return($indir, \@infile, $outdir, \@outfile);
}

sub findfile{  # recursive file search.
  # Any files or dirs of which name begin with '_' are ignored.
  # &findfile('target_dir', sub{print "$_[0]\n"});
  my($dir, $p) = @_;
  ($dir=~/^_/) and return();
  my @files = grep {!m(/_)} <$dir/*>;
  foreach my $file (@files) {
    (-d $file) ? findfile($file, $p) : $p->($file);
  }
}

{
my($footnote_cnt, %footnotes);
my(@auto_table_id);
sub to_html{
  my($x, $opt) = @_;
  (defined $opt) or $opt={};
  my(%sectdata, $secttitle, @html);
  my $htmlout = '';
  my @sectdata_depth = ([{sect_id=>'_'}]);
  my ($sect_cnt, $sect_id)       = (0, '_');
  my ($depth, $lastdepth)        = (0, 0);
  my $ind = $opt->{indir};
  (defined $ind) or $ind='';
  foreach my $t (split(/(^\?.*?\n)/m, $x)){ # for each section
    $t=~s/^\n*//;
    $t=~s/[\s\n]+$//;
    if($t=~/^(\?+[-<=>]*)([a-z]*)(?:#(\S*))?(?:\s+(.*))?/){ # begin sect
      my($level, $tagtype, $id, $secttitle) = ($1, $2, $3, $4);
      
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
      if($depth==0){
        my $j=0;
        for(my $i=$lastdepth; $i>=1; $i--){
          $html[$sect_cnt-$j]{close} = "</$sectdata_depth[$i][-1]{tag}>";
          $j++;
        }
        next;
      }
      
      my $tag = {qw/section section a article s aside h header f footer n nav d details/}->{$tagtype};
      $tag = $tag || 'section';
      $sect_cnt++;
      $sect_id = $id || "sect${sect_cnt}";
      $sect_id=~s/[^\w]//g;
      (exists $sectdata{$sect_id}) and mes("duplicated section id ${sect_id}", {warn=>1});
      push(@{$sectdata_depth[$depth]}, {sect_id => $sect_id, tag => $tag});

      # add close tag for the former section here if necessary
      # and set open tag for the current section here
      my $opentag = qq{<$tag class="wini" id="${sect_id}">\n} .
        (($secttitle) ? qq{<h1 class="sectiontitle">$secttitle</h1>\n} : '');
      $html[$sect_cnt]{tag} = $tag;
      if($lastdepth==$depth){
        if($lastdepth>0){
          $html[$sect_cnt-1]{close} ||=
          sprintf(
            qq{</%s> <!-- end of "%s" d=ld=$depth lastdepth=$lastdepth -->\n}, $html[$sect_cnt-1]{tag}, $html[$sect_cnt-1]{sect_id}
          );
        }
        $html[$sect_cnt]{open} ||= $opentag;
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
      $t=~s/===(.*)===/$v = &ylml($1, $opt); ''/es;
      foreach my $k (keys %$v){
        $sectdata_depth[$depth][-1]{val}{$k} = $v->{$k};
        $sectdata{$sect_id}{val}{$k}         = $v->{$k};
      }
      
      # WINI interpretation
      my $opt1 = { %$opt };
      $opt1->{_v} = $sectdata{$sect_id}{val};
      my($h, $o) = markgaab($t, $opt1);
      $html[$sect_cnt]{sect_id} = $sect_id;
      $html[$sect_cnt]{txt}     = $h;
      $html[$sect_cnt]{opt}     = $o;
      $html[$sect_cnt]{depth}   = $depth;
    } # read sect content
  } # foreach sect
  ($depth!=0) and $html[-1]{close} = ("\n" . ('</section>' x $depth));
  map{$htmlout .= "\n" . join("\n", $_->{open}||'', $_->{txt}||'', $_->{close}||'')} @html;
  $htmlout .= "\n";
  
  # template?
  if(defined $sectdata_depth[0][-1]{val}{template}){ # template mode
    $TEMPLATE = $sectdata_depth[0][-1]{val}{template};
  }
  if(defined $TEMPLATE){
    # read vals
    my $opt1 = { %$opt };
    foreach my $k (grep {$_ ne 'template'} keys %{$sectdata_depth[0][-1]{val}}){
      $opt1->{_v}{$k} = $sectdata_depth[0][-1]{val}{$k};
    }

    # read main text
    my %maintxt;
    foreach my $html (@html){
      my($id, $txt) = ($html->{sect_id}, $html->{txt});
      $maintxt{$id} = $txt;
    }

    # read tmpl data
    my $template = $TEMPLATE;
    my $tmpldir  = (defined $TEMPLATEDIR) ? $TEMPLATEDIR : cwd();
    if($template=~m{^/}){ # absolute path
    }else{
        my @testdirs = ($tmpldir, $opt->{dir}, (map {"$_/_template"} ($tmpldir, $opt->{dir})));
    L1:{
        foreach my $d (@testdirs){
          my $t = "$d/$TEMPLATE";
          if(-f $t){
            mes(txt('ftf', {t=>$t}), {q=>1});
            $template = $t;
            last L1;
          }else{
            mes(txt('snf', {t=>$t}), {q=>1});
          }
        }
        mes(txt('cft', undef, {t=>$TEMPLATE, d=>join(q{', '}, @testdirs)}), {err=>1});
      }  # L1
    }
    open(my $fhi, '<:utf8', $template);
    my $tmpltxt = join('', <$fhi>);
    $tmpltxt=~s!\[\[(.*?)]]!
      if(exists $maintxt{$1}){
       $maintxt{$1};
      }else{
        (defined $opt1->{_v}{$1}) ? ($opt1->{_v}{$1}) : '';
      }
    !ge;
    (defined $opt->{whole}) and $tmpltxt = whole_html($htmlout, $opt->{title}, $opt);
    return(deref($tmpltxt));
  }else{ # non-template
    (defined $opt->{whole}) and $htmlout = whole_html($htmlout, $opt->{title}, $opt);
    return(deref($htmlout), \@html);
  }
} # sub to_html

sub parse{ # for CPAN
  my ($file, $encoding, $opts) = @_;
#  my $md = Text::Wini->new(@{ $opts || [] });
  $encoding = $encoding || 'utf8';
  open my $fh, "<:encoding($encoding)", $file;
  local $/;
  my $src = join('', <$fh>);
  my $html = to_html($src);
  return unless $html =~ /\S/;
  utf8::encode($html);
  return($html);
}

sub markgaab{
# wini($targettext, {para=>'br', baseurl=>'http://example.com', nocr=>1});
  # para: paragraph mode (br:set <br>, p: set <p>, nb: no separation
  # nocr: whether CRs are conserved in result text. 0(default): conserved, 1: not conserved
  # table: table-mode, where footnote macro is effective. $opt->{table} must be a table ID. Footnote texts are set to @{$opt->{footnote}}
  my($t0, $opt) = @_;
  (defined $t0) and $t0=~s/\r(?=\n)//g; # cr/lf -> lf
  (defined $t0) and $t0=~s/(?!\n)$/\n/s;
  ($t0) or return('');
  my($baseurl, $cssfile) = map {$opt->{$_}} qw/baseurl cssfile/;
  my $cr    = (defined $opt->{nocr} and $opt->{nocr}==1)
              ?"\t":"\n"; # option to inhibit CR insertion (in table)
  my $para  = (defined $opt->{para}) ? $opt->{para} : 'p'; # p or br or none;
  my $title = $opt->{title} || 'WINI page';
  (defined $footnote_cnt) or $footnote_cnt->{'_'}{'*'} = 0;
  my $lang  = $opt->{_v}{lang} || $LANG || 'en';

  # verbatim
  $t0 =~ s/\%%%\n(.*?)\n%%%$/         &save_quote('',     $1)/esmg;
  # pre, code, citation, ...
  $t0 =~ s/\{\{(pre|code|q(?: [^|]+?)?)}}(.+?)\{\{end}}/&save_quote($1,$2)/esmg;  
  $t0 =~ s/^'''\n(.*?)\n'''$/         &save_quote('pre',  $1)/esmg;
  $t0 =~ s/^```\n(.*?)\n```$/         &save_quote('code', $1)/esmg;
  $t0 =~ s/^"""([\w =]*)\n(.*?)\n"""$/&save_quote("q $1", $2)/esmg;
    
  # conv table to html
  $t0 =~ s/^\s*(\|.*?)[\n\r]+(?!\|)/table($1)/esmg;
  # footnote
  if(exists $opt->{table}){ # in table
    my $table_id = $opt->{table};
    if($table_id and $footnote_cnt->{$table_id} and $footnotes{$table_id}){
      footnote($t0, '*', $footnote_cnt->{$table_id}, $footnotes{$table_id});
    }
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

  my $r = '';
  my @localclass = ('wini');
  foreach my $t (split(/\n{2,}/, $t0)){ # for each paragraph
    my @myclass = @localclass;
    my($myclass, $myid) = ('', '');
    my $ptype = ''; # type of each paragraph (list, header, normal paragraph, etc.)

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
        $t =~ s!\[\[(\w+)(?:\|(.*))?\]\]!(defined $opt->{_v}{$1}) ? $opt->{_v}{$1} : ''!ge or
        $t =~ s!\[([^]]*?)\]\(([^)]*?)\)!anchor_from_md($1, $2, $baseurl)!eg or
        $t =~ s!\[([^]]*?)\]!anchor($1, $baseurl, $lang)."\n"!esg or
        $t =~ s!(\{\{([^|]*?)(?:\|([^{}]*?))?}})!
        call_macro(
          ((defined $1) ? $1 : ''),
          ((defined $2) ? $2 : ''),
          $opt,
          $baseurl,
          ((defined $3) ? split(/\|/, $3) : ())
        )!esg #or
      ) or last; # no subst need, then escape inner loop
    } # loop while subst needed

    $t=~s{(?:^|(?<=\n))([*#;:].*?(?:(?=\n[^*#;:])|$))}
         {my($r,$o)=list($1, $cr, $ptype, $para, $myclass); $r}esg;
    ($t=~/\S/) and 
      $t = ($ptype eq 'header' or $ptype eq 'list')                                     ? "$t\n"
          : ($para eq 'br')                                                              ? "$t<br>$cr"
          : ($para eq 'nb')                                                              ? $t
          : $t=~m{<(html|body|head|p|table|img|figure|blockquote|[uod]l)[^>]*>.*</\1>}is ? $t
          : $t=~m{<!doctype}is                                                           ? $t
          : "<p${myclass}>\n$t</p>$cr$cr";

    $r .= "\n$t";
  } # foreach $t # for each paragraph

  $r=~s/${MI}i=(\d+)${MO}/$save[$1]/ge;
  if($cssfile){
    open(my $fho, '>', $cssfile) or die "Cannot modify $cssfile";
    print {$fho} css($CSS);
    close $fho;
  }
  (defined $footnotes{'_'}[0]) and $r .= qq{<hr>\n<footer>\n<ul style="list-style:none;">\n} . join("\n", (map {"<li>$_</li>"}  @{$footnotes{'_'}})) . "\n</ul>\n</footer>\n";
  #(defined $section) and $r.="</section>\n";
  #(defined $opt->{whole}) and $r = whole_html($r, $title, $opt);
  ($opt->{table}) or $r=~s/[\s\n\r]*$//;
    #dereference
#  print STDERR "\n<<<<REF=",Dumper %REF, ">>>>\n";

  if(0){ # cancel on trial 220217
    my $seq=0;
    # ref tag: MInidMIljaMIt...
    $r=~s!${MI}([^${MI}${MO}]+)(?:${MI}t=([^${MI}${MO}]+))(?:${MI}l=([^${MI}${MO}]+))${MO}!
      my($id, $type, $lang) = ($1, $2, $3);
      if(defined $REF{$id}{disp_id}){
#        $REF{fig}{$id}{id};
      }else{
        if(my($id0)=$id=~/^tbl(\d+)$/){
          $REF{$id}{disp_id} = $id0;
          $REFASSIGN{$type}{$id0} = 1;
        }else{
          (defined $REFCOUNT{$type}) ? $REFCOUNT{$type}++ : ( $REFCOUNT{$type} = 1);
          while(defined $REFASSIGN{$type}{$REFCOUNT{$type}}){
            $REFCOUNT{$type}++;
          }
          $REF{$id}{disp_id} = $REFCOUNT{$type};
          $REFASSIGN{$type}{$REFCOUNT{$type}} = 1;
        }
      }
      txt($type, $lang, {n=>$REF{$id}{disp_id}});
    !ge;
  }
#  print STDERR "\nAfter deref\n<<<<REF=",Dumper %REF, ">>>>\n";

  return($r, $opt);
} # sub markgaab

sub deref{
  my($r) = @_;
  my $seq=0;
  $r=~s!${MI}([^${MI}${MO}]+)(?:${MI}t=([^${MI}${MO}]+))(?:${MI}l=([^${MI}${MO}]+))${MO}!
    my($id, $type, $lang) = ($1, $2, $3);
    if(defined $REF{$id}{disp_id}){
    }else{
      if(my($type1, $id1)=$id=~/^(fig|tbl|bib)(\d+)$/){
        $REF{$id}{disp_id} = $id1;
        $REFASSIGN{$type}{$id1} = 1;
      }else{
        (defined $REFCOUNT{$type}) ? $REFCOUNT{$type}++ : ( $REFCOUNT{$type} = 1);
        while(defined $REFASSIGN{$type}{$REFCOUNT{$type}}){
          $REFCOUNT{$type}++;
        }
        $REF{$id}{disp_id} = $REFCOUNT{$type};
        $REFASSIGN{$type}{$REFCOUNT{$type}} = 1;
      }
    }
    txt($type, $lang, {n=>$REF{$id}{disp_id}});
  !ge;
  return($r);
}

sub whole_html{
  my($x, $title, $opt) = @_;
  $x=~s/[\s\n\r]*$//s;
  #  my($cssfile, $cssflameworks) = map {$opt->{$_}} qw/cssfile cssflameworks/;
  my $cssfile = $opt->{cssfile} || '';
  my $style   = '';
  $title = $title || 'wini page';
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
  
  $ptype = $ptype || '';
  $cr = $cr || "\n";
  $para = $para || '';
  my $t2='';
  my %listitems;
  my %listtype = (''=>'', ';'=>'dl', ':'=>'dl', '*'=>'ul', '#'=>'ol');
  my %listtag  = (''=>'', ';'=>'dt', ':'=>'dd', '*'=>'li', '#'=>'li');
  my($itemtag, $listtag, $itemtagc);
  my @list;
  my $rootlisttype = '';
  foreach my $x (split("\n", $t)){
    if($x=~/^([;:*#])([;:*#].*)/ and ($1 eq $rootlisttype)){
      if($#list>=0){
        $list[-1] = $list[-1]."\n$2";
      }else{
        push(@list, $2);
      }
      $rootlisttype = $1;
    }else{
      $x=~/^([;:*#])/ and $rootlisttype = $1;
      push(@list, $x);
    }
  }

  my($lastlisttype, $lastlisttag) = ('', '');
  foreach my $l (@list) {
    # line/page break
    if (($l=~s/^---$/<br style="page-break-after: always;">/) or
        ($l=~s/^--$/<br style="clear: both;">/)) {
      $t2 .= $l; next;
    }
    my($hmark, $txt0) = $l=~/^\s*([#*:;])(\S*\s+.*)/s;
    ($txt0) or $t2 .= $l,next; # non-list content
    my($txt1, undef) = markgaab($txt0, {para=>'nb'});
    $txt1=~s/([^\n])$/$1\n/;
    if($hmark){
      my($listtype, $listtag) = ($listtype{$hmark},  $listtag{$hmark});
      ($lastlisttype ne $listtype) and $t2 .= qq!</$lastlisttype>\n<$listtype class="winilist">\n!;
      $t2 .= "<$listtag>$txt1</$listtag>\n";
      ($lastlisttype, $lastlisttag) = ($listtype, $listtag);
    }
  } # foreach $l

  $lastlisttype and $t2 .= "</$lastlisttype>\n";
  $t2=~s{(</>|<>)}{}g;
  return(
    ($t2=~/\S/)?(
    ($ptype eq 'header' or $ptype eq 'list')                                      ? "$t2\n"
  : ($para eq 'br')                                                               ? "$t2<br>$cr"
  : ($para eq 'nb')                                                               ? $t2
  : $t2=~m{<(html|body|head|p|table|img|figure|blockquote|[uod]l)[^>]*>.*</\1>}is ? $t2
  : $t2=~m{<!doctype}is                                                           ? $t2
  : "<p${myclass}>\n$t2</p>$cr$cr"
  ): '', \%listitems);
} # sub list

sub close_listtag{
  my($ref, $l) = @_;
  map{
    $$ref .= (' ' x ($#$l-$_)) . (($l->[$_] eq 'ul')?'</ul>':($l->[$_] eq 'ol')?'</ol>':'</dl>') . "\n";
  } 0..$#$l;
}

sub symmacro{
  # {{/*_-|text}}
  my($tag0, $text)= map {defined($_) ? $_ : ''} @_;
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

sub listmacro{
  my($listtype, $pars) = @_; # (ul|ol|nl), item1, item2, ...
  my($listtag, $otag, $ctag) = ($listtype eq 'nl')
    ? ('ul',      qq{li style="list-style:none"}, 'li')
    : ($listtype, 'li',                           'li');
  my $r = "<$listtag>\n";
  foreach my $item (@$pars){
    $r .= "<$otag>" . (markgaab($item, {para=>'nb', nocr=>1}))[0] . "</$ctag>\n";
  }
  $r .= "</$listtag>\n";
  return($r);
}

{
my %abbr;
sub term{
  # {{@|abbr=DNA|text=deoxyribonucleic acid}} -> <abbr title="deoxyribonucleic acid">DNA</abbr>
  # {{@|abbr=DNA|text=deoxyribonucleic acid|dfn=1}} -> <dfn><abbr title="deoxyribonucleic acid">DNA</abbr></dfn>
  # {{@|DNA}} -> <abbr>DNA</abbr>
  # {{@||DNA}} -> <dfn>DNA</dfn>
  my($p) = @_;
  my $par = readpars($p, qw/abbr text dfn list/);
  my $out;
  if($par->{list}){
    $out = qq!\n<ul class="abbrlist">\n!;
    foreach my $t (sort keys %abbr){
      $out .= "<li> <abbr>$t</abbr>: $abbr{$t}</li>\n";
    }
    $out .= "</ul>";
    return($out);
  }
  if($par->{abbr}){
    my $ab = ($par->{text}) ? qq!<abbr title="$par->{text}">$par->{abbr}</abbr>! : qq!<abbr>$par->{abbr}</abbr>!;
    $out = ($par->{dfn}) ? qq!<dfn>$ab</dfn>! : $ab;
    $abbr{$par->{abbr}} = $par->{text};
  }else{
    $out = ($par->{text}) ? '<dfn>' . $par->{text} . '</dfn>' : '';
  }
  return($out);
}
sub abbr{ # return abbr list
  my($t) = @_;
  my $o;
  unless(defined $t){
    foreach my $k (keys %abbr){
      push(@$o, {term=>$k, abbr=>$abbr{$k}});
    }
    return($o);
  }
  return($abbr{$_[0]} || '');
}
} # term env

sub span{ # text deco with <span></span>
  my($f, $class_id)=@_;
  my($txt, @opt) = ($f->[0], @$f[1..$#$f]);
  my %style;
  my $style = '';
  foreach my $o (@opt){
    if(my($o1,$o2) = $o=~/(_|\[\])(\w*)/){ # underline, frame
      my $prop = ($o1 eq '_') ? 'border-bottom' : 'border';
      $style{"${prop}-style"} = 'solid';
      $style{"${prop}-width"} = '1px';
      $o2=~s/(\d+)/$style{"${prop}-width"} = $1."px"; ''/ge;
      $o2=~s[^(dotted|dashed|solid|double|groove|ridge|inset|outset)$]
            [$style{"${prop}-style"}=$o2; '']ge;
      $o2=~s[^([a-z]+|#[0-9a-f]{3}|#[0-9a-f]{6})$]
            [$style{"${prop}-color"} = color($1); '']ige;
    }elsif($o=~/^
([\d.]+(?:em|rem|vw|vh|%|px|pt|pc|vmin|vmax))<
([\d.]+(?:em|rem|vw|vh|%|px|pt|pc|vmin|vmax))<
([\d.]+(?:em|rem|vw|vh|%|px|pt|pc|vmin|vmax))/x){
      $style{fontsize} = sprintf('clamp(%s, %s, %s)', $1, $2, $3);
    }elsif($o=~/^(
[\d.]+(?:em|rem|vw|vh|%|px|pt|pc|vmin|vmax)| # absolute or relative length
smaller|larger| # relative kw
(?:x-|xx-)?(?:small|large) # absolute kw
)$/x){
      $style{fontsize} = $1;
    }elsif($o eq 'wb'){ # color: white,black
      ($style{"color"}, $style{"background-color"}) = qw/white black/;
    }elsif($o=~/^([a-z]+|#[0-9a-f]{3}|#[0-9a-f]{6})(?:,([a-z]+|#[0-9a-f]{3}|#[0-9a-f]{6}))?/){ # color
      my($fcolor, $bcolor) = ($1||'', $2||'');
      $fcolor=~s/^(red|green|blue|magenta|purple)$/color($1)/e;
      $bcolor=~s/^(red|green|blue|magenta|purple)$/color($1)/e;
      $style{'color'} = $fcolor;
      ($bcolor) and $style{'background-color'} = $bcolor;
    }
  } # foreach $o
  $style = join('; ',  map {"$_: $style{$_}"} (sort keys %style));
  $class_id = $class_id || '';
  $style = ($style) ? qq{ style="$style"} : '';
  return(qq!<span${class_id}$style>$txt</span>!);
}

sub call_macro{
  my($fulltext, $macroname, $opt, $baseurl, @f) = @_;
  # macroname: "macroname" or "add-in package name:macroname". e.g. "{{x|abc}}", "{{mypackage:x|abc}}"
  my(@class, @id);
  $macroname=~s/\.([^.#]+)/push(@id,    $1); ''/ge;
  $macroname=~s/\#([^.#]+)/push(@class, $1); ''/ge;
  my $class_id = join(' ', @class);
  ($class_id) and $class_id = qq{ class="${class_id}"};
  $class_id   .= ($id[0]) ? qq! id="$id[0]"! : '';
  $macroname=~s/^[\n\s]*//;
  $macroname=~s/[\n\s]*$//;
  if($macroname eq ''){
    return(span(\@f, $class_id));
#    return(($class_id) ? qq!<span${class_id}>$f[0]</span>! : $f[0]);
  }
  (defined $MACROS{$macroname}) and return($MACROS{$macroname}(@f));
  ($macroname=~/^l$/i)       and return('&#x7b;'); # {
  ($macroname=~/^bar$/i )    and return('&#x7c;'); # |
  ($macroname=~/^r$/i)       and return('&#x7d;'); # }
  ($macroname=~/^([=-]([fh*]*-)?+[>v^ud]+|[<v^ud]+[=-]([fh*]*-)?+)/i)
                             and return(arrow($macroname, @f));
  ($macroname=~m{^[!-/:-@\[-~]$}) and (not defined $f[0]) and 
    return('&#x'.unpack('H*',$macroname).';'); # char -> ascii code
  ($macroname=~/^\@$/)       and return(term(\@f));
  ($macroname=~/^(rr|ref)$/i)       and return(reftxt(@f, 'dup=ok')); #{{ref|id|fig}}
  ($macroname=~/^(date|time|dt)$/i) and return(date([@f, "type=$1"],  $opt->{_v}));
  ($macroname=~/^calc$/i)    and return(ev(\@f, $opt->{_v}));
  ($macroname=~/^va$/i)      and return(
    (defined $opt->{_v}{$f[0]}) ? $opt->{_v}{$f[0]} : (mes(txt('vnd', {v=>$f[0]}), {warn=>1}), '')
  );
  ($macroname=~/^envname$/i) and return($ENVNAME);
  ($macroname=~/^([oun]l)$/) and return(listmacro($1, \@f));
  ($macroname=~/^[IBUS]$/)   and $_=lc($macroname), return("<$_${class_id}>$f[0]</$_>");
  ($macroname eq 'i')        and return(qq!<span${class_id} style="font-style:italic;">$f[0]</span>!);
  ($macroname eq 'b')        and return(qq!<span${class_id} style="font-weight:bold;">$f[0]</span>!);
  ($macroname eq 'u')        and return(qq!<span${class_id} style="border-bottom: solid 1px;">$f[0]</span>!);
  ($macroname eq 's')        and return(qq!<span${class_id} style="text-decoration: line-through;">$f[0]</span>!);
  ($macroname=~/^ruby$/i)    and return(ruby(@f));
  ($macroname=~/^v$/i)       and return(qq!<span class="tategaki">$f[0]</span>!);

  ($macroname=~m!([-_/*]+[-_/* ]*)!) and return(symmacro($1, $f[0]));

  my $errmes = mes(txt('mnf', undef, {m=>$macroname}), {warn=>1});
  return(sprintf(qq#\\{\\{%s}}<!-- $errmes -->#, join('|', $macroname, @f)));
}

sub readpars{
  my($p, @list)=@_;
  my %pars; my @pars;
  my @par0 = (ref $p eq 'ARRAY') ? @$p : split(/\|/, $p);

  foreach my $x (@par0){
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
${MI}i=$i${MO}
</blockquote>
EOD
  }else{ # pre, code
    my($ltag, $rtag) = ($cmd eq 'code')?('<pre><code>','</code></pre>')
                      :($cmd eq 'pre') ?('<pre>',      '</pre>') : ('', '');
    return("$ltag\n${MI}i=$i${MO}\n$rtag");
  }
} # sub save_quote
} # env save_quote

sub reftxt{
  # make temporal ref template, "${MI}id.*{MO}"
  my $par        = readpars(\@_, qw/id type lang/);
  my($id, $type, $lang, $dup) = map {$par->{$_}} qw/id type lang dup/;
#  ($lang) or $lang = 'en';
#  my $type       = $REF{$id}{type};
  my $lang1 = ($lang eq '') ? '' : "${MI}l=${lang}";
  my $type1 = ($type eq '') ? '' : "${MI}t=${type}";
  my   $out = "${MI}${id}${type1}${lang1}${MO}";
  ($dup ne 'ok') and (exists $REF{$id}) and txt(mes('did', {id=>$id}), $lang, {err=>1});
  (defined $type) and $REF{$id} = {type=>$type};
  return($out);
}

{
my %arrows;

sub arrows_init{
%arrows = (
'-**->' => "27A1",
'-*->'  => "21E8",
'-*-^'  => "21E7",
'-*-v'  => "21E9",
'->'    => "2192",
'->d'   => "2198",
'->u'   => "2197",
'->v'   => "21B4",
'-^'    => "2191",
'-^>'   => "21B1",
'-f->'  => "261E",
'-f-^'  => "261D",
'-f-v'  => "261F",
'-h->'  => "27A4",
'-v'    => "2193",
'-v>'   => "21B3",
'<-'    => "2190",
'<-*-'  => "21E6",
'<->'   => "2194",
'<-f-'  => "261C",
'<='    => "21D0",
'<=>'   => "21D4",
'<^-'   => "21B0",
'<v-'   => "21B5",
'=>'    => "21D2",
'=>d'   => "21D8",
'=>u'   => "21D7",
'=^'    => "21D1",
'=v'    => "21D3",
'^-v'   => "2195",
'^=v'   => "21D5",
'd<-'   => "2199",
'd<='   => "21D9",
'u<-'   => "2196",
'u<='   => "21D6",
'v=^'   => "21D5"
);
}
sub arrow{
  my($cmd, @f) = @_;
  (scalar keys %arrows == 0) and arrows_init();
  my $x = $arrows{$cmd};
  unless(defined $x){
    my $errmes = mes(txt('mnf', undef, {m=>"arrow $cmd"}));
    return(sprintf(qq#\\{\\{%s}}<!-- $errmes -->#, join('|', $cmd, @f)));
  }
  $x=~/^[\dA-F]{4}$/ and $x = "\&#x$x;";
  return($x);
}
} # env arrow

sub anchor_from_md{
  my($t, $url, $baseurl) = @_;
  return(qq!<a href="$url">$t</a>!);
}

sub anchor{
# [! image.png text]
# [!"image.png" text]
# [!!image.png|#x text] # figure
# [!image.png|< text]   # img with float:left
# [http://example.com text]
# [http://example.com|@@ text] # link with window specification
# [#goat text]  # link within page

  my($t, $baseurl, $lang) = @_;
  ($lang) or $lang = 'en';
  my($prefix, $url0, $text)          = $t=~m{([!?#]*)"(\S+)"\s+(.*)}s;
  ($url0) or ($prefix, $url0, $text) = $t=~m{([!?#]*)([^\s"]+)(?:\s+(.*))?}s;
  my($url, $opts) = (split(/\|/, $url0, 2), '', '');
  ($prefix eq '#') and $url=$prefix.$url;
  #$text = escape($text) || $url;
  ($text) = markgaab($text, {nocr=>1, para=>'nb'});
  ($text eq '') and $text = $url;

  # options
  my $style            = ($opts=~/</) ? "float: left;" : ($opts=~/>/) ? "float: right;" : '';
  ($style) and $style  = qq{ style="$style"};
  my($id)              = $opts=~/#([-\w]+)/;
  ($id=~/^\d+$/) and $id = "fig$id";
  my @classes          = $opts=~/\.([-\w]+)/g;
  my($width,$height)   = ($opts=~/(\d+)x(\d+)/)?($1,$2):(0,0);
  my $imgopt           = ($width>0)?qq{ width="$width"}:'';
  $height and $imgopt .= qq{ height="$height"};
  my $target           = ($opts=~/@@/)?'_blank':($opts=~/@(\w+)/)?($1):'_self';
  my $img_id           = '';  # ID for <img ...>
  if($prefix=~/[!?]/){ # img, figure
    my $class = join(' ', @classes); ($class) and $class = qq{ class="$class"};
    if(defined $id){
      my $img_id0 = $id; # temp_id;
      $img_id0=~s{^(\d)}{fig$1}; # img_id0: "fig111"
      (exists $REF{$img_id0} and $text) and mes(txt('did', undef, {id=>$id}), {q=>1,err=>1});
      my $reftxt = reftxt($id, 'fig', $lang);
      $text       = "$reftxt $text";
#      $REF{$id}   = {type=>'fig', desc => ($text||undef)};
      $img_id     = qq! id="${img_id0}"!; # ID for <img ...>
    }
    if($prefix eq '!!'){
      return(qq!<figure$style><img src="$url" alt="$text"${img_id}$class$imgopt><figcaption>$text</figcaption></figure>!);
    }elsif($prefix eq '??'){
      return(qq!<figure$style><a href="$url" target="$target"><img src="$url" alt="${id}"${img_id}$class$imgopt></a><figcaption>$text</figcaption></figure>!);
    }elsif($prefix eq '?'){
      return(qq!<a href="$url" target="$target"><img src="$url" alt="$text"${img_id}$class$style$imgopt></a>!);
    }else{ # "!"
      return(qq!<img src="$url" alt="$text"${img_id}$class$style$imgopt>!);
    }
  }elsif($url=~/^[\d_]+$/){
    return(qq!<a href="$baseurl?aid=$url" target="$target">$text</a>!);
  }else{
    return(qq!<a href="$url" target="$target">$text</a>!);
  }
} # sub anchor

sub strdump{
  my($x) = @_;
  my @x = split(//,$x);
  my $o ='';
  $o .= join('', map { sprintf("%4s " , (/[\x00- ]/?' ':$_))} @x) . "\n";
  $o .= join('', map { sprintf("%04x ",              ord $_)} @x) . "\n";
  return($o);
}

sub ruby{
  #my($x) = @_; # text1|ruby1|text2|ruby2 ...
  my @txt = @_; #split(/\|/, $x);
  my $t = join("", map {my $a=$_*2; "$txt[$a]<rp>(</rp><rt>$txt[$a+1]</rt><rp>)</rp>"} (0..$#txt/2));
  return("<ruby>$t</ruby>");
}

{
#my $table_no;
sub table{
  my($in, $footnotes)=@_;
#  (defined $table_no) or $table_no=1;
  my $ln=0;
  my(@winiitem, @htmlitem, $caption, $footnotetext, $tbl_id);
  my @footnotes; # footnotes in cells

  push(@{$htmlitem[0][0]{copt}{class}}, 'winitable');

  #get caption & table setting - remove '^|-' lines from $in
  $in =~ s&(^\|-([^-].*$))\n&
    my $caption0 = $2;
    $caption0=~s/\|\s*$//;
    my($c, $o) = split(/ \|(?= |$)/, $caption0, 2); # $caption=~s{[| ]*$}{};
    if(defined $o){
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
        my($tbl_id0) = $1;
        $tbl_id0=~s{^(\d+)$}{tbl$1}; # #1 -> #tbl1
# todo: set $REF like figure Ids.
        (exists $REF{$tbl_id0}) and mes(txt('did', undef, {id=>$tbl_id0}), {q=>1,err=>1});
        ($tbl_id0=~/\S/) and $caption = reftxt($tbl_id0, 'tbl') . " $c";
        $htmlitem[0][0]{copt}{id}[0] = $tbl_id0;
        $tbl_id = sprintf(qq{ id="%s"}, $tbl_id0); # reftxt($tbl_id0, undef, 'tbl')); # for table->caption tag
      }
    }# if defined $o
    ($caption) or $caption = $c;

    if(defined $o){
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
    } # if defined $o
    ($caption)=markgaab($caption, {para=>'nb', nocr=>1});
    $caption=~s/[\s\n\r]+$//;
  ''&emg; # end of caption & table setting

#  ($htmlitem[0][0]{copt}{id}[0]) or $htmlitem[0][0]{copt}{id}[0] = sprintf("winitable%d", $table_no++);
  my @lines = split(/\n/, $in);
  my $macro = '';
  my %tablemacros;
  my %fn_cnt;
  foreach my $line (@lines){
    $line=~s/[\n\r]*//g;
    ($line eq '') and next;

    # deal with inner-cell footnotes
    if($line=~/\{\{\^\|(.*?)}}/){
      $line=~s!\{\{\^\|(.*?)}}!
        my($txt, @p) = split(/\|/, $1);
        my $fn_mark  = $p[0] || '*';
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
      $tablemacros{$macro} = ($rowmerge==1)?("$tablemacros{$macro}\n$cols[2]") : $cols[2];
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
        (defined $tablemacros{$macro}) and $winiitem[$ln][$cn+1] = $tablemacros{$macro};
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
      ($cell->{wini}, my $opt) = markgaab($cell->{val}, {para=>'nb', nocr=>1, table=>$htmlitem[0][0]{copt}{id}[0]});
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
        or $htmlitem[0][0]{copt}{style}{width}[0] = sprintf("%drem", ((sort map{$_ or 0} @rowlen)[-1])*2);

  # make html
  my $outtxt = sprintf(qq!\n<table${tbl_id} class="%s"!, join(' ', sort @{$htmlitem[0][0]{copt}{class}}));
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
        my $style0 = join(' ', sort map { "$_:$style{$_};" } grep {$style{$_}} sort keys %style);
        ($style0) and $copt .= qq! style="$style0"!; #option for each cell
        my $ctag = (
          (not $htmlitem[$rn][0]{footnote}) and (
          ($htmlitem[$rn][$_]{ctag} and $htmlitem[$rn][$_]{ctag} eq 'th') or
          ($htmlitem[0][$_]{ctag}   and $htmlitem[0][$_]{ctag}   eq 'th') or
          ($htmlitem[$rn][0]{ctag}  and $htmlitem[$rn][0]{ctag}  eq 'th'))
        )?'th':'td';
        sprintf("<$ctag$copt>%s</$ctag>", ($htmlitem[$rn][$_]{wini} || ''));
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
#  if((defined $footnotes[0]) or (defined $footnotes->{$table_no} and scalar @{$footnotes->{$table_no}} > 0) or $footnotetext){
   if(defined $footnotes[0]){
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
} # sub table

} # table env

{
my %vars;
my $avail_yamltiny;

sub ylml{ #ylml: yaml-like markup language
  my($x, $opt) = @_;
  my $val = $opt->{_v};
  if($opt and $avail_yamltiny){
    my $yaml = YAML::Tiny->new;
    $val     = ($yaml->read_string($x))[0][0];
  }else{
    foreach my $line (split(/\s*\n\s*/, $x)){
      if(my($s,$k,$v) = $line=~/^(\s*)([^: ]+):\s*(.*)\s*$/){
        #($v eq '') and next;
        if($v eq ''){
          
        }elsif($v=~/^\[(.*)\]$/){ # array
          $val->{$k} = [map {s/^(["'])(.*)\1$/$2/; $_} split(/\s*,\s*/, $1)];
        }elsif(my($v2) = $v=~/^\{(.*)\}$/){ # hash
          foreach my $token (split(/\s*,\s*/, $v2)){
            my($kk,$vv) = $token=~/(\S+)\s*:\s*(.*)/;
            $vv=~s/^(["'])(.*)\1$/$2/;
            $val->{$k}{$kk} = ev($vv, $val);
          }
        }else{ # simple variable
          $val->{$k} = ev($v, $val) ;
        }
      }
    } # for each $line
  }
  return($val);
} # sub ylml

sub date{
  my($x, $v) = @_;
  # %v: from environment
  # $x: array reference containing parameters from '{{date|...}}'
  # $x->[0]: 2021-12-17 or 2021-12-17T21:22:23
  # $x->[3]: output data type: 'd', 't', 'dt'
  # $v->{lang}: ja or en
  my $p = readpars($x, qw/date weekday trad lang type/);
  my $type = $p->{type} || 'date';
  my $lang = $p->{lang} || $v->{lang} || '';
  my $lc0  = setlocale(LC_ALL, txt('LOCALE', $lang));
  my @days = split(/\s+/, txt('date_days', $lang));
  my $form0= $p->{type}.(('', qw/dow trad dowtrad/)[($p->{weekday}>0)+($p->{trad}>0)*2]);
  my $form = txt($form0, $lang);
  my $t;
  ($p->{date}) or $p->{date} = localtime->datetime;
  my @n = split("[-/.T]", $p->{date});
  if($p->{date}=~/\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d/){
    $t = Time::Piece->strptime($p->{date}, "%Y-%m-%dT%H:%M:%S");
  }else{
    eval{ $t = Time::Piece->strptime("$n[0]-$n[1]-$n[2]", "%Y-%m-%d") };
      $@ and mes("Invalid date format: '$p->{date}'", {err=>1, ln=>__LINE__});
  }
  
  if(($type eq 'd' or $type eq 'dt') and $p->{weekday}){ # weekday name
    my $wd = $t->day(@days); # Sun, Mon, ...
    $form=~s/%a/$wd/g;
  }
  my $res = $t->strftime($form);
  setlocale(LC_TIME, $lc0);
  return(decode('utf-8', $res));
}

sub ev{ # <, >, %in%, and so on
  my($x, $v) = @_;

  # $x: string or array reference. string: 'a,b|='
  # $v: reference of variables given from wini()
  
  my(@token) = (ref $x eq '') ? (undef, split(/((?<!\\)[|])/, $x))
             : (undef, map{ (split(/((?<!\\)[|])/, $_)) } @$x);
  
  my @stack;
  for(my $i=1; $i<=$#token; $i++){
    my $t  = $token[$i];
    if($t eq '&u'){
      push(@stack, uc      $stack[-1]); # $token[$i-2]);
    }elsif($t eq '&uf'){
      push(@stack, ucfirst $stack[-1]); # $token[$i-2]);
    }elsif($t eq '&l'){
      push(@stack, lc      $stack[-1]); # $token[$i-2]);
    }elsif($t eq '&lf'){
      push(@stack, lcfirst $stack[-1]); # $token[$i-2]);
    }elsif($t=~/\&cat([^|]*)$/){
      my $sep=$1;
      $sep=~tr{csb}{, |};
      @stack = (join($sep, @stack));
    }elsif($t=~/(^[<>]+)(.+)/){
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
    }elsif($t=~/(["'])(.*?)\1/){ # constants (string)
      $t=escape_metachar($t);
      push(@stack, $2 . '');
    }elsif($t=~/^\d+$/){ # constants (numeral)
      push(@stack, $t);
    }else{ # variables or formula
      if($t=~/^\w+$/){
        push(@stack, $v->{$t});
      }else{
        push(@stack, array($t));
      }
    }
  }
  return($stack[-1]);
} # end of ev

sub escape_metachar{
  my($x, $format) = @_;
  $format = $format || '&#0x%X;';
  $x=~s!\\([][|,'{}])!sprintf($format, ord($1))!ge;
  return($x);
}

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

__DATA__
" <- dummy quotation mark to cancel meddling cperl-mode auto indentation
!LOCALE!en_US.utf8!ja_JP.utf8!
!cft!Cannot find template {{t}} in {{d}}!テンプレートファイル{{t}}はディレクトリ{{d}}内に見つかりません!
!cno!Could not open {{f}}!{{f}}を開けません!
!conv!Conv {{from}} -> {{to}}!変換 {{from}} -> {{to}}!
!date!%Y-%m-%d!%Y年%m月%d日!
!date_days!Sun Mon Tue Wed Thu Fri Sat!日 月 火 水 木 金 土!
!datedow!%a. %Y-%m-%d!%Y年%m月%d日 (%a)!
!datetrad!%b %d, %Y!%EY(%Y年)%m月%d日!
!datedowtrad!%a. %b %d, %Y!%EY(%Y年)%m月%d日 (%a)!
!dt!%Y-%m-%dT%H:%M:%S!%Y年%m月%d日 %H時%M分%S秒!
!dtdow!%a. %Y-%m-%dT%H:%M:%S!%Y年%m月%d日 (%a) %H時%M分%S秒!
!dttrad!%b %d, %Y %H:%M:%S!%EY(%Y年)%m月%d日 %H時%M分%S秒!
!dtdowtrad!%a. %b %d, %Y %H:%M:%S!%EY(%Y年)%m月%d日 (%a) %H時%M分%S秒!
!dci!Input: Dir {{d}}!入力元ディレクトリ: {{d}}!
!dco!Output: Dir {{d}}!出力先ディレクトリ: {{d}}!
!did!Duplicated ID:{{id}}!ID:{{id}}が重複しています!
!din!Input:   STDIN!入力元: 標準入力!
!elnf!{{d}} for extra library not found!{{d}}が見たらず、エキストラライブラリに登録できません!
!Error!error!エラー!
|fail|failed|失敗|
!fci!File {{f}} is chosen as input!ファイル{{f}}が入力元ファイルです!
!fig!Fig. {{n}}!図{{n}}!
|fin|completed|終了|
!fnf!File not found!ファイルが見つかりません!
!ftf!Found {{t}} as template file!テンプレートファイル{{t}}が見つかりました
!if!input file:!入力ファイル：!
|ll|loaded library: {{lib}}|ライブラリロード完了： {{lib}}|
|llf|failed to load library '{{lib}}'|ライブラリロード失敗： {{lib}}|
!mnf!Cannot find Macro '{{m}}'!マクロ「{{m}}」が見つかりません!
!Message!Message!メッセージ!
!mt!{{col}}{{mestype}}{{reset}} at line {{ln}}. !{{reset}}{{ln}}行目にて{{col}}{{mestype}}{{reset}}：!
!opf!File {{f}} is opened in utf8!{{f}}をutf-8ファイルとして開きます!
!rout!Output:  STDOUT!出力先: 標準出力!
!secnames!part chapter section subsection!部 章 節 項!
!snf!Searched {{t}}, but not found!{{t}}の内部を検索しましたが見つかりません!
!tbl!Table {{n}}!表{{n}}!
!time!%H:%M:%S!%H時%M分%S秒!
!timetrad!%H:%M:%S!%H時%M分%S秒!
!timedowtrad!%H:%M:%S!%H時%M分%S秒!
|ttap|trying to add {{path}} into library directory|{{path}}のライブラリディレクトリへの追加を試みます|
|ut|undefined text|未定義のテキスト|
!uref!undefined label!未定義のラベル!
!vnd!Variable '{{v}}' not defined!変数{{v}}が定義されていません!
!Warning!Warning!警告!
