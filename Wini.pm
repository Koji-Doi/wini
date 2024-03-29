#!/usr/bin/env perl
=encoding utf8
=head1 NAME

Text::Markup::Wini.pm - WIki markup ni NIta nanika (Japanese: "Something like wiki") - The supporting tool of Markgaab, a novel lightweight markup language

=head1 SYNOPSIS

 use Wini;

 my($htmltext) = to_html(<<'EOT');
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

=head1 USAGE

The script file Wini.pm is a perl module supporting Markgaab markup (formerly called WINI markup). Markgaab (Markup Going Above And Beyond) is an advanced lightweight markup language, which allows users to make structured and multilingual documents in semantic HTML5.

Wini.pm can be used not only as perl module file but also as a stand-alone perl script. Users easily can generate HTML5 documents from Markgaab source texts, by using Wini.pm as a filter command. This script can be used as a static site generator as well.

The text presented here is just a brief description.

Please refer to the synopsis of this page to grasp ontline about markgaab markup. Also, The author is pareparing the homepage describing markgaab and Wini.pm for details.

=head2 As module

Put this script file in the directory listed in @INC. If you are not clear about what @INC is, please try 'perldoc perlvar'.
Add 'use Wini;' in the begining of your script to use functions of Wini.pm.  

=head2 As stand-alone script

Put this script file in the directory listed in your PATH. The script file name can be renamed as 'wini' instead of 'Wini.pm'. Do 'chmod a+x Wini.pm'. It might be required to do 'hash' ('rehash' in zsh) to make your shell recognize Wini.pm as a valid command name.

If you succeed the install, you can use this script as follows:

 $ Wini.pm < input.wini > output.html

See section 'Options' to find out detail about advanced usage.

=head2 Markgaab, a lightweight but powerful markup language

Markgaab is a novel lightweight language, developed to construct web contents in HTML Live Standard. The name stands for "Markup Going Above And Beyond". WINI is a markgaab supporting tool.

Try "perl Wini.pm -h mg", and you can read a brief document about Markgaab.

=head1 OPTIONS

=over 4

=item B<-i> I<INPUT>

Set input file name to INPUT. If -i is not set, Wini.pm takes data from standard input.

=item B<-o> I<OUTPUT>

Set output file name. If both -o and -i are omitted, Wini.pm outputs HTML-translated text to standard output.
If -o is omitted and the input file name is set to, for example, 'input.wini', the output file will be 'input.wini.html'.
Users can specify the output directory rather than the file. If -o value ends with '/', for example 'output/', output file will be output/input.wini.html. If 'output/' does not exist, Wini.pm will create it.

=item B<--outcssfile> I<FILENAME>

Set CSS file name. If this option is set, CSS is written to the specified file. Otherwise, CSS is written in the style element of the result HTML document. If '--cssfile' is set without a file name, the output css file name is generated from input file name. if input file name is not set (when markgaab data is input from STDIN), "wini.css" is the output css file name.

=item B<--whole>

Add HTML Live Standard headar and footer to output. The result output will be a complete HTML5 document.

=item B<--cssflamework> I<[url]>

Specify the url of CSS flamework (especially "classless" flameworks are supposed). If the URL is omitted, it is set to "https://unpkg.com/mvp.css".

=item B<--extralib> I<LIB>, B<-E> I<LIB>

Load specified library LIB

=item B<--libpath> I<PATH>, B<-I> I<PATH>

Add specified directory PATH into library path

=item B<--title> I<[title]>

Set text for <title>. Effective only when --whole option is set.

=item B<--template> I<[template]>

Specify template file written in html.

=item B<--templatedir> I<[templatedir]>

Specify directory where template files exist.

=item B<--bib> I<[bibliography list file]>

Specify name of file in ".enw" or "refer/bibIX" format, which might be exported from Endnote Basic etc.

=item B<--bibonly>

When the -bib option is specified, WINI only writes out the ref file and exits without processing markgaab data.

=item B<--lang> I<[language]>

The specified value is set to $LANG, to determine language. The default is 'en'. Error/Warning messages are printed in the specified language. This setting may also affect how typesetting is done.

=item B<--quiet>

Suppress additional message output

=item B<--force>

Ignore errors and continue process.

=item B<--version>

Show version.

=item B<--help>

Show this help.

=back

=head1 MARKGAAB

Here is brief description and examples of mg for quick start.

=head2 Basics

Write plain texts as they appear. Howerever, paragraphes must be separated by blank lines.

---

 This is the first sentence of the first paragraph. This is the second sentence of the first paragraph.
 This is the third sentence of the first paragraph. Single line breaks are ignored.

 This is the first sentence of the second paragraph, since it is prefaced by a blank line.

---

=head2 Text decoration

superscripts: z^^2 = x^^2 + y^^2

subscripts: H__2O

bolds: {{b|bold text}}

italics: {{i|italic text}}

undelines: {{u|underlined text}}

strikes: {{s|striked text}}

=head3 Accents

 {{A`}}  : À (A with accent)
 {{A'}}  : Á (A with acute accent)
 {{A^}}  : Â (A with circumflex)
 {{A~}}  : Ã (A with tilde accent)
 {{A:}}  : Ä (A with diaeresis accent)
 {{A%}}  : Å (A with ring above)
 {{AE}}  : Æ (AE dephthong)
 {{C,}}  : Ç (C with cedilla)
 {{s-}}  : ß (German sharp s)
 etc.

=head2 listing

 # ordered list item 1
 # ordered list item 2
 # ordered list item 3

 * non-ordered list item 1
 * non-ordered list item 2
 * non-ordered list item 3

 # nested list item 1
 # nested list item 2
 #* nested list item 2-1
 #* nested list teim 2-2
 # nested list item 3

 ; description list item 1 title
 : description list item 1 description
 ; description list item 2 title
 : description list item 2 description 1
 : description list item 2 description 2

=head2 images and hyperlinks

 [http://example.com]                   : very simple hyperlink
 [http://example.com damy description]  : hyperlink with description
 [http://example.com|@@ description]    : hyperlink to be opened in new window ('_blank')
 [http://example.com|@hoge description] : hyperlink to be opened in the window named 'hoge'
 [#hoge text]                           : hyperlink within page

 [!sample.png]       : very simple in-line image
 [!!sample.png]      : in-line image with <figure> and <figcaption> tags
 [!image.png|< text] : img with float:left
 [!sample.png desc]  : in-line image with alternative text
 [?sample.png]       : in-line image with hyperlink to the image file
 [??sample.png]      : in-line image with hyperlink to the image file as well as <figure> and <figcaption> tags

=head2 table

 |- table title | table option |
 |!! col1 title                | col2 title | col3 title |
 | data 1-1                    | data 1-2   | data 1-3   |
 | data 2-1                    | data 2-2   | data 2-3   |
 | data 3 (with colspan)       |-           |-           |
 | data (4,5)-1 (with rowsapn) | data 4-2   | data 4-3   |
 |^                            | data 5-2   | data 5-3   |
 |<data6_1                     | data 6-2   | data 6-3   |
 |data6_1 This is the content of the cell "data6_1". Any markgaab codes can be included here. |

=head2 sections and headdings

 ! header 1
 !! header 2
 !!! header 3

 ? section
 ?a article
 ?h header
 ?f footer
 ?s aside
 ?n nav

=head2 list(stack) operation

Operations as shown below are valid in ev macro and in variable definition block.

 1|2|3|         : a list containing 3 numbers
 'a'|'b'|'c'|   : a list containing 3 texts
 1|2|+|         : 1+2
 1|2|+|3|*|     : (1+2)*3
 3|10|2|&nsort| : {2,3,10}
 3|10|2|&rev|   : {2,10,3}
 3|10|2|&nmax|  : {10}

 "a"|&ita       : <span style="font-style:italic">a</span>

 "James Tiberius Kirk"|&last_first,      : "Kirk, James Tiberius"
 "Kirk, James Tiberius"|&first_last      : "James Tiberius Kirk"
 "Kirk, James Tiberius"|&first_last_ini. : "J. K."
 "Kirk, James Tiberius"|&ini_f           : "Kirk, J. T."

 "Aa, Bb"|"Cc, Dd"|"gg"|"HH"|"iI"|&uc_all|&join;; : "AA, BB; CC, DD; GG; HH; II"
 "A"|"B"|"C"|"D"|"E"|&join,a                      : "A, B, C, D and E"
 "A"|"B"|"C"|"D"|"E"|&join;;3e                    : "A; B; C et al."

=cut

package Text::Markup::Wini;
use 5.9.5;
use strict;
use POSIX qw/locale_h/;
use locale;
use utf8;
use Data::Dumper;
use File::Basename;
use File::Path 'mkpath';
use FindBin;
use Pod::Usage qw/pod2usage/;
#use Pod::Find;
use Pod::Simple;
use Getopt::Long qw(:config no_ignore_case auto_abbrev);
use Encode;
use Cwd;
use Time::Piece;
use File::Find;
use Module::Load qw/mode/;
our $ENVNAME;
#our %EXT;
our @LANGS;
our $LANG;
our $QUIET;
our %MACROS;
our %VARS;
our %REF;       # dataset for each reference
#our %REFCOUNT;  # reference count
our %REFASSIGN; # reference id definitions
our %TXT;       # messages and forms
our($MI, $MO);  # escape chars to 
our(@INDIR, @INFILE, $OUTFILE);
our($TEMPLATE, $TEMPLATEDIR);
my(@libs, @libpaths, $SCRIPTNAME, $VERSION, $debug);
my @save;
our %sectdata;
our($sect_cnt, $sect_id) = (0, '_');
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
  '.citlist'   => {'list-style'       => 'none'},
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
  '.yokoyoko'  => {'-ms-writing-mode' => 'tb-rl', 'writing-mode' => 'vertical-rl', '-webkit-text-orientation' => 'sideways', 'text-orientation' => 'sideways'},
  '.reflist'   => {'list-style-type' => 'none; margin: 0; padding: 0;'}
};

__PACKAGE__->stand_alone() if !caller() || caller() eq 'PAR';

sub init{
  setlocale(LC_ALL, 'C');
  setlocale(LC_TIME, 'C');
  undef %MACROS; undef %VARS; undef %REF; undef %REFASSIGN; undef %sectdata;
  deref_init();
  no warnings;
  *Data::Dumper::qquote = sub { return encode "utf8", shift } ;
  $Data::Dumper::Useperl = 1 ;
  use warnings;
  binmode STDIN, ':utf8';
  binmode STDERR,':utf8';
  binmode STDOUT,':utf8';
  ($MI, $MO)  = ("\x00", "\x01");
#  ($MI, $MO)  = ("<<", ">>");
  $ENVNAME    = "_";
  @LANGS      = qw/en ja/;
  if(defined $ENV{LANG}){
    if($ENV{LANG} eq 'C'){
      $LANG = 'en';
    }else{
      foreach my $l (@LANGS){
        if($ENV{LANG}=~/^([a-zA-Z]+)/){
          ($l eq $1) and $LANG = $l;
        }
      }
    }
  }
  $LANG or $LANG = 'en';
  $QUIET      = 0; # 1: suppress most of messages
  $SCRIPTNAME = basename($0);
  $VERSION    = "ver. 1.0 rel. 20231223";
  while(<Text::Markup::Wini::DATA>){
    chomp;
    while(s/\\\s*$//){
      $_ .= <Text::Markup::Wini::DATA>;
    }
    /^##/ and next; # comment line
    /^\s*$/ and next;
    /^"[^"]*$/ and next; # skip dummy line
    my $sp = substr($_, 0, 1);
    ($sp eq '') or $sp = '\\' . $sp;
    my($id, @txt) = split($sp, substr($_,1));
    for(my $i=0; $i<=$#txt; $i++){
      no warnings; # work around to cancel "Wide character in substitution (s///)"
      $txt[$i]=~s/^\s+/ /;
      $txt[$i]=~s/\s+$/ /;
      use warnings;
      $TXT{$id}{$LANGS[$i]} = $txt[$i];
    }
  }
  to_html_reset(); # reset footnote etc.

# temp
$MACROS{switch} = sub{
  my($e0, @p) = @_; # {{macroname|p0|p1}}
  my $e = ev_val($e0);
  my $n = ($e>=$#p) ? $#p : $e;
  return($p[$n]);
};

$MACROS{if} = sub{
  my($e, $true, $false) = @_;
  return($e ? $true : $false);
};

} # sub init

# Following function is executed when this script is called as stand-alone script
sub stand_alone{
  my(@input, $output, $fhi, $title, $cssfile, $test, $whole, @cssflameworks, @bibfiles, $bibonly, $help);
  init();
  GetOptions(
    "h|help:s"       => \$help,
    "v|version"      => sub {print STDERR "Wini.pm $VERSION\n"; exit()},
    "i=s"            => \@input,
    "o:s"            => \$output,
    "title=s"        => \$title,
    "outcssfile:s"   => \$cssfile,
    "E|extralib:s"   => \@libs,
    "I|libpath:s"    => \@libpaths,
    "lang=s"         => \$LANG,
    "T"              => \$test,
    "D"              => \$debug,
    "whole"          => \$whole,
    "cssflamework:s" => \@cssflameworks,
    "template=s"     => \$TEMPLATE,
    "templatedir=s"  => \$TEMPLATEDIR,
    "bib=s"          => \@bibfiles,
    "bibonly"        => \$bibonly,
    "force"          => \$FORCE,
    "quiet"          => \$QUIET
  );
  (defined $help) and help($help);

  foreach my $i (@libpaths){
    mes(txt('ttap', undef, {path=>$i}), {q=>1});
    (-d $i) ? push(@INC, $i) : mes(txt('elnf', undef, {d=>$i}), {warn=>1});
  }
  foreach my $lib (@libs){ # 'form', etc.
    my $r = eval{Module::Load::load($lib)};
    if(defined $r){
      mes(txt('ll',  undef, {lib=>$lib}), {q=>1});
    }else{
      mes(txt('llf', undef, {lib=>$lib}), {err=>1});
    }
  }
 
  # bibliography
  if(defined $bibfiles[0]){
    read_bib(@bibfiles);
    if($bibonly){
      save_bib("$bibfiles[0].ref");
      exit();
    }
  }

  (defined $cssflameworks[0]) and ($cssflameworks[0] eq '') and $cssflameworks[0]='https://unpkg.com/mvp.css'; # 'https://newcss.net/new.min.css';
  ($test) and ($INFILE[0], $OUTFILE)=("test.wini", "test.html");

  # check input/output
  my($inf, $outd, $outf, $outcss) = winifiles(\@input, $output, $cssfile);
  if(
    (not defined $input[0] and not defined $outf->[0]) or
    (defined $inf->[0])
  ){
    mes(txt('fso'), {q=>1});
  #}else{
  #  print STDERR "check inf  ", Dumper $inf;
  #  print STDERR "check outd ", Dumper $outd;
  #  print STDERR "check outf ", Dumper $outf;
  }
  if(defined $outd){
    (-f $outd) and unlink $outd;
    (-d $outd) or mkdir $outd;
  }
  if(defined $inf->[0]){
#    mes(txt('if') . join(' ', @$inf), {q=>1});
  } else {
    push(@$inf, '');
  }

  #test
  if($test){
    init();
    exit;
  }

  # output
  my @flds = qw/type count lang text/;
  if(scalar @$outf>1){
    # 1. multiple infile -> multiple outfile (1:1)
    for(my $i=0; $i<=$#$inf; $i++){
      my $outfile    = $outf->[$i];
      my $outreffile = "$outfile.ref";
      if($inf->[$i] eq ''){
        mes(txt('conv', undef, {from=>'STDIN', to=>$outfile}), {q=>1});
        $fhi=*STDIN;
      }else{
        mes(txt('conv', undef, {from=>$inf->[$i], to=>$outfile}), {q=>1});
        open($fhi, '<:utf8', $inf->[$i]);
      }
      open(my $fho, '>:utf8', $outfile) or mes(txt('fnw', undef, {f=>$outfile}), {err=>1});
      my $winitxt = join('', <$fhi>);
      $winitxt=~s/\x{FEFF}//; # remove BOM if exists
      my($htmlout) = to_html($winitxt, {dir=>getcwd(), whole=>$whole, cssfile=>$outcss->[$i], title=>$title, cssflameworks=>\@cssflameworks});
      print {$fho} $htmlout;
      save_bib($outreffile);
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
         open($fhi, '<:utf8', $_) or die txt('fnf', undef, {f=>$_}) || mes(txt('ou', undef, {f=>$_}), {q=>1})
      );
      while(<$fhi>){
        s/[\n\r]*$//; s/\x{FEFF}//; # remove BOM if exists
        $winitxt .= "$_\n";
      }
      $winitxt .= "\n\n";
    } @$inf;
    my($htmlout) = to_html($winitxt, {dir=>getcwd(), whole=>$whole, cssfile=>$outcss->[0], title=>$title, cssflameworks=>\@cssflameworks});
    print {$fho} $htmlout;
    (scalar keys %REF) and save_bib((defined $outf->[0]) ? $outf->[0].'.ref' : 'STDOUT.ref');
  } # if scalar @$outf>1
} # sub stand_alone

sub read_bib{

=begin c
Wini.pm original specification: the text specified in %1 is regarded as an Reference ID.

%A 	Author	(au)
%B 	Secondary title of a book or conference name	(co)
%C 	Place published	(pp)
%D 	Year	(ye)
%E 	Editor/Secondary author	(ed)
%G 	Language	(lang)
%H 	Translated author	(tau)
%I 	Publisher	(pu)
%J 	Journal name	(jo)
%N 	Number or issue	(is)
%P 	Pages 	(pa_begin, pa_end)
%R 	DOI 	digital object identifier	(doi)
%T 	Title	(ti)
%U 	URL	(url)
%V 	Volume	(vo)
%0 	Reference type  -- This must be the first tag of each record
%1 	Reference ID -- Wini.pm original
%2 		PMCID
%@ 	ISBN/ISSN, ISBN or ISSN number	(SN)

=end c

=cut

  my(@bibfiles) = @_;
  for(my $i=0; $i<=$#bibfiles; $i++){
    my($ref, $fileformat) = ([], 'endnote'); # fileformat: endnote(default) or pubmed
    open(my $fhi, '<:utf8', $bibfiles[$i]) or mes(txt('fnf', undef, {f => $bibfiles[$i]}), {err=>1});
    unless($fileformat){
      ($bibfiles[$i]=~/.nbib$/) and $fileformat = 'pubmed';
    }
    bib_id(); # reset ID
  #  my $outbibfile = "$bibfiles[$i].ref";
    if($fileformat eq 'endnote'){
      my %item = qw/A au B co C pp D ye E ed G lang 8 da T ti H tau I pu J jo R doi V vo N is U url/;
      my %current_rec;
      while(<$fhi>){
        s/[\n\r]*$//g;
        my($type, $cont) = split(/\s/, $_, 2);
        my $type1 = substr($type, 1);
        if(/^[\s\r]*$/){ # new record
          push(@$ref, {type=>'cit'});
          foreach my $k (keys %current_rec){
            if(ref $current_rec{$k} eq 'ARRAY'){
              @{$ref->[-1]{$k}} = @{$current_rec{$k}};
            }else{
              $ref->[-1]{$k} = $current_rec{$k};
            }
          }
          undef %current_rec;
        }
        if($type eq '%0'){ # new article
          my $cont1 = ($cont eq 'Conference Proceedings') ? 'pc'
                    : ($cont eq 'Book section') ? 'bs'
                    : ($cont eq 'Web page') ? 'wp'
                    : ($cont eq 'Journal Article') ? 'ja' : '';
          $current_rec{cittype} = $cont1;
        }elsif($type eq '%1'){
          $current_rec{id} = $cont;
        }elsif(exists $item{$type1}){ # au, ti, etc.
          push(@{$current_rec{$item{$type1}}}, $cont);
        }elsif($type eq '%P'){ # page
          my($from, $to) = $cont=~/(\d+)(?:-(\d+))/;
          push(@{$current_rec{pa_begin}}, $from);
          push(@{$current_rec{pa_end}},   $to);
        }elsif($type eq '%U'){ # pubmed ID can be found here
          push(@{$current_rec{url}}, $cont);
          my($pmid) = $cont=~m{/pubmed/(\d+)};
          push(@{$current_rec{pmid}}, $pmid);
        }elsif($type eq '%2'){ # PMCID can be found here
          push(@{$current_rec{pmcid}}, $cont); # = $cont;
        }elsif($type eq '%@'){
          $cont=~s/\D//g;
          (length($cont)==8)                       and push(@{$current_rec{issn}}, $cont);
          (length($cont)==10 or length($cont)==13) and push(@{$current_rec{isbn}}, $cont);
        }
      } # <$fhi>
      if(scalar keys %current_rec > 0){
        push(@$ref, {type=>'cit'});
        foreach my $k (keys %current_rec){
          if(ref $current_rec{$k} eq 'ARRAY'){
            @{$ref->[-1]{$k}} = @{$current_rec{$k}};
          }else{
            $ref->[-1]{$k} = $current_rec{$k};
          }
        }
      }
    }else{ # for pubmed file
      my $itemname;
      my @itemnames;
      my %item;
      while(<$fhi>){
        s/[\n\r]*$//;
        /^\s*$/ and last;
        my($itemname0, $cont) = /(?:([^- ]*?) *- )?(.*)\s*$/;
        if($itemname0=~/\S/){
          $itemname = $itemname0;
          push(@itemnames, $itemname);
          push(@{$item{$itemname}}, $cont);
        }else{
          $cont=~s/^\s*//;
          $item{$itemname}[-1] .= $cont;
        }
      } # <$fhi>
    }
    close $fhi;
    for(my $i=0; $i<=$#$ref; $i++){
      my $cit_form     = ($ref->[$i]{cittype}) ? ('cit_form_'.$ref->[$i]{cittype}) : 'cit_form';
      $ref->[$i]{id}   = bib_id($ref->[$i], {n=>1});
      foreach my $l (@LANGS){
        $ref->[$i]{text}{$l} = cittxt($ref->[$i], $cit_form, $l);
      }
    }
    #open(my $fho, '>:utf8', $outbibfile) or die mes(txt('fnf', undef, {f=>$outbibfile}), {err=>1});
    #print {$fho} join("\t", qw/id lang au tau ye ti/), "\n";
    foreach my $x (sort {$a->{id} cmp $b->{id}} @$ref){
      my $id = $x->{id};
      foreach my $k (grep {$_ ne 'text' and $_ ne 'id' and $_ ne 'type' and $_ ne 'cittype'} keys %$x){
        (ref $x->{$k} ne 'ARRAY') and next;
        map { push(@{$REF{$id}{$k}}, $_) } @{$x->{$k}};
      }
      $REF{$id}{source}  = $i+1; # reference No. (1,2,3,...) refs from '{{ref|..}}' should be 0.
      $REF{$id}{type}    = 'cit';
      $REF{$id}{cittype} = $x->{cittype} || 'ja';
      $REF{$id}{text}    = $x->{text};
      (defined $REF{$id}{lang}) or $REF{$id}{lang}[0] = 'en';
      #my $au  = (defined $x->{au}[0])  ? join(' & ', grep {/\S/} @{$x->{au}})  : '';
      #my $tau = (defined $x->{tau}[0]) ? join(' & ', grep {/\S/} @{$x->{tau}}) : '';
      #$REF{$id}{au} =  $au;
      #$REF{$id}{tau} = $tau;
      
      #print {$fho} join("\t", $id, $x->{lang}[0], $au, $tau, $x->{ye}[0]||'', $x->{ti}[0]||''), "\n";
    }
    #close $fho;
  } #foreach @bibfiles
} # sub read_bib

{
my  %au_ye;
sub bib_id{
  my($ref, $opt)  = @_; # $r: hash reference
  my($pre, $post) = ($opt->{post} || '', $opt->{post} || '');
  if((scalar keys %$ref)>0){
    (exists $ref->{id}) and return($ref->{id}); # When ref Id is already defined, use that.
    my $id0 = $ref->{tau}[0] || $ref->{au}[0];
    $id0=~s/^["?].*//;
    $id0=~s/[, ].*//;
    $id0 = ($id0 eq '') ? '?' : lc latin2ascii($id0);
    ((scalar @{$ref->{au}})>1) and $id0 .= '_';
    $id0 .= ($ref->{ye}[0]);
    $au_ye{$id0}++;
    my $id = $pre . $id0 . ((defined $opt->{n})
      ? sprintf('_%03d', $au_ye{$id0})
      : (('', '', 'a'..'z', 'aa'..'zz')[$au_ye{$id0}])
    ) . $post;
    return($id);
  }
  undef %au_ye;
  return(undef);
}
} # env bib_id

sub save_bib{
# final whole list of references
  my($outfile) = @_;
  ((scalar keys %REF)==0) and return;
  my $fho;
  if($outfile){
    open($fho, '>:utf8', $outfile) or mes(txt('fnw', undef, {f=>$outfile}), {err=>1});
  }else{
    $fho = *STDOUT;
  }
  print {$fho} join("\t", qw/refid type cittype source url inline_id au tau ye ti/), "\n";
  foreach my $type (qw/fig tbl cit/){
    foreach my $refid (sort grep {$REF{$_}{type} eq $type} keys %REF){
      print {$fho} join("\t", $refid, $type, $REF{$refid}{cittype}||'', $REF{$refid}{source}, $REF{$refid}{url}[0]||'', $REF{$refid}{inline_id}{en}||'', $REF{$refid}{au}[0]||'', $REF{$refid}{tau}[0]||'', $REF{$refid}{ye}[0], $REF{$refid}{ti}[0]||''), "\n";
    }
  }
  ($outfile) and close $fho;
}

sub txt{ # multilingual text from text id
  my($id, $lang, $par) = @_;
  my($p, $f, $l) = caller();
  #|fin|completed|終了|
  #id: 'fin', lang:'ja'
  #$par: hash reference for paragraph
  $lang = $lang || $LANG || 'en';
  (defined $TXT{$id}) or mes(txt('ut', $lang). ": '$id'", {warn=>1}), return(undef);
  my $t = $TXT{$id}{$lang} || $TXT{$id}{en} || '';
  $t=~s/\{\{(.*?)}}/(defined $par->{$1}) ? $par->{$1} : "??? $1" /ge;
  return($t);
} # sub txt

sub mes{ # display guide, warning etc. to STDERR
  my($txt, $o) = @_;
# $o->{err}: treat $txt as error and die
# $o->{warn}: treat $txt as warning and use warn()
# $o->{q}: do not show caller-related info
# $o->{ln}: line number
# $QUIET: show err or warn, but any others are omitted
  chomp $txt;
  my $mes;
  my $ind = '';
  my($mestype, $col) = (exists $o->{err})  ? ('Error',   "\e[37m\e[41m")
                     : (exists $o->{warn}) ? ('Warning', "\e[31m\e[47m") : ('Message', "\e[0m");
  my($p, $f, $l) = caller();
  my $ln  = (defined $o->{ln}) ? $o->{ln} : $l;
  my $ln1 = '';
  if((not exists $o->{q}) and $QUIET==0){
    ($ln) and $ln1 = " at line $ln";
    my $i = 1; my @subs;
    while ( my($pack, $file, $line, $subname, $hasargs, $wantarray, $evaltext, $is_require) = caller( $i++) ){
      push(@subs, "$line\[$subname]\@$file")
    }
    $mes = txt('mt', undef, {col=>$col, reset=>"\e[0m", mestype=>txt($mestype), ln=>$ln}) . join(' <- ', @subs);
    print STDERR "${col}$mes\e[0m\n";
    $ind='  ';
  }
  if(exists $o->{err}){
    (($FORCE) and print STDERR "$ind$txt\n") or die "$ind$txt\n";
  }elsif($o->{warn}){
    warn("$ind$txt\n");
  }else{
    ($QUIET==0) and print STDERR "$ind$txt\n";
  }
  return($txt);
} # sub mes

sub help{
  my($x) = @_;
  $x= lc $x;
  if($x eq ''){
    print STDERR "Wini.pm - MARKGAAB handling tool $VERSION\n";
    print STDERR << 'EOD';

First of all, see online help:

$ perl Wini.pm -h      : Show this brief help.
$ perl Wini.pm -h wini : Show Wini.pm help.
$ perl Wini.pm -h opt  : Show command-line options.
$ perl Wini.pm -h mg   : Show Markgaab quick-start guide and cheat sheet.
EOD

  }elsif($x eq 'wini'){
    print pod2usage(-verbose => 1, -noperldoc => 1, -input => $FindBin::Bin . "/" . $FindBin::Script);
  }else{
    my $sect = [
       ($x eq 'mg'  or $x eq 'markgaab') ? 'MARKGAAB'
     : ($x eq 'opt' or $x eq 'opts')     ? 'OPTIONS' 
     : qw(SYNOPSIS USAGE OPTIONS)
    ];
    #print pod2usage(-verbose => 99,  -sections => $sect, -input => Pod::Find::pod_where({-inc => 1}, __PACKAGE__) );
    print pod2usage(-verbose => 99,  -sections => $sect); #, -input => $FindBin::Bin . "/"). $FindBin::Script;
  }
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
  my($in0, $out, $css) = @_;
  # $in: string or array reference
  # $out: string (not array reference)
#  my($indir, @infile, $outdir, @outfile, @cssfile);
  my($indir, @infile, $outdir, @outfile, @cssfile);
  my @in = (ref $in0 eq 'ARRAY') ? @$in0 : ($in0);

=begin c

|!!  |  -i   |-                    |-                  |-                      |-                             |-       |
----------------------------------------------------------------------------------------------------------------------
|!!  |!!!    | undefined           | existing(ex)-file | non-existing(ne)-file | ex-dir                       | ne-dir |
| -o | undef | <stdin >stdout      | <i >i.html        | ERROR                 | <i/*.(wini|mg|par) >./*.html | ERROR  |
|    | file  | <stdin >o           | <i >o             |^                      | <i/*.(wini|mg|par) >o        |^       |
|    | dir   | <stdin >o/wini.html | <i >o/i.html      |^                      | <i/*.(wini|mg|par) >o/*.html |^       |

=end c

=cut

  my(%mode_in, $mode_out);
  foreach my $in (@in){
    if(not defined $in){
      $mode_in{'--'} = 1;
      last;
    }elsif(-d $in){
      (exists $mode_in{ed}) and mes(txt('mds'), {err=>1});
      (exists $mode_in{ef}) and mes(txt('dfs'), {err=>1});
      $mode_in{ed} = 1;
    }elsif(-f $in){
      (exists $mode_in{ed} or exists $mode_in{nd}) and mes(txt('dfs'), {err=>1});
      $mode_in{ef} = 1;
    }elsif($in=~m{/$}){
      (exists $mode_in{ef}) and mes(txt('dfs'), {err=>1});
      $mode_in{nd} = 1;
    }else{
      mes(txt('fnf', undef, {f=>$in}), {err=>1});
    }
  }
  (defined $in[0]) or $mode_in{'--'} = 1;
  if((defined $out) and ($out eq '')){
    $out = (defined $in[0]) ? "$in[0].html" : undef;
  }

  $mode_out = (not defined $out) ? '--'
            : (-d $out) ? 'ed'
            : (-f $out) ? 'ef'
            : ($out=~m{/$}) ? 'nd' : 'nf';

  if(exists $mode_in{ef}){
    push(@infile, @in);
  }elsif(exists $mode_in{ed}){
    #push(@infile, map { <$_/*.wini>, <$_/*.par>, <$_/*.mg>} @in);
    push(@infile, grep {/\.(?:mg|wini|par)$/} map{my $d=($_ eq '.')?cwd():$_; @{findfile($d)}} @in);
    $indir = $in[0];
  }else{ # '--' = STDIN
  }

  ($mode_out eq 'nd') and mkdir $out;
  if($mode_out eq 'ef' or $mode_out eq 'nf'){
    my $outcss = cssfilename($in[0], $css, dirname($out));
    ($outfile[0], $cssfile[0]) = ($out, $outcss);
  }elsif($mode_out eq 'ed' or $mode_out eq 'nd'){
    foreach my $in1 (@infile){
      my($base, $indir1, $ext) = fileparse($in1, qw/.wini .par .mg/);
      ($indir1 eq './') and $indir1='';
      $indir1=~s{/$}{};
      my $outdir1 = $out;
      $outdir1=~s{/$}{};
      my $outdir2=$indir1; # $outdir2 will show outdir (maybe subdir of $outdir1)
      $outdir2=~s!^[^/]+!${outdir1}!;
      $outdir2=~s{/$}{};
      if(-e $outdir2){
        (-d $outdir2) or mes(txt('dnw', undef, {d=>$outdir2}), {err=>1});
      }else{
        (mkpath $outdir2) || mes(txt('dnw', undef, {d=>$outdir2}), {err=>1});
      }
      #print "*** $indir1 - $outdir1 - $outdir2\n";
      push(@outfile, "${outdir2}/${base}${ext}.html");
      push(@cssfile, cssfilename("${outdir2}/${base}${ext}.css", $css, $outdir2));
    } # foreach @infile
  }

  mes(
#    "indir:   " . (($indir)?$indir:'undef') . "\n" .
    "infile:  " . (($infile[0])?join(' ', @infile):'undef') . "\n" .
#    "outdir:  " . (($outdir)?$outdir:'undef') . "\n" .
    "cssfile: " . (($cssfile[0])?join(' ',@cssfile):'undef') . "\n" .
    "outfile: " . (($outfile[0])?join(' ',@outfile):'undef'), {q=>1}
     );
#  (defined $indir  or defined $infile[0])  or mes(txt('din'), {q=>1});
  (defined $outdir or defined $outfile[0]) or mes(txt('rout'), {q=>1});
  return(\@infile, $outdir, \@outfile, \@cssfile);
} # sub winifiles

sub cssfilename{
  my($out, $default_css, $outdir) = @_;
  (defined $outdir) or $outdir = getcwd();

  $outdir=~s{/$}{};
  my $outcss;
  if(defined $default_css and $default_css eq ''){
    my $body = basename($out, qw/.css/);
    $outcss  = "$outdir/" . ((defined $out) ? "${body}.css" : "wini.css");
  }elsif(defined $default_css){
    $outcss = $default_css;
  }else{
    $outcss = 'wini.css';
  }
  return($outcss);
}

sub findfile{  # recursive file search.
  # Any files or dirs of which name begin with '_' are ignored.
  # &findfile('target_dir', sub{print "$_[0]\n"});
  my($dir, $p) = @_;
  my @files0;
  find(sub{push(@files0, grep {!/^\./} $File::Find::name)}, grep {!/^_/} $dir);
  my @files = sort grep {-f $_ and !m{(?:^|/)\.}} @files0;
  return(\@files);
}

{
my($footnote_cnt, %footnotes);
my(@auto_table_id);
sub to_html_reset{
  undef $footnote_cnt; undef %footnotes; undef @auto_table_id;
  undef $sect_cnt; undef $sect_id;
}
sub to_html{
  my($x, $opt) = @_;
  # $opt: mainly from commandline parameters
  (defined $opt) or $opt={};
  my($secttitle, @html);
  my $htmlout              = '';
  my @sectdata_depth       = ([{sect_id=>'_'}]);
#  my ($sect_cnt, $sect_id) = (0, '_');
  my ($depth, $lastdepth)  = (0, 0);
  my $ind                  = $opt->{indir};
  (defined $ind) or $ind   = '';
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
      (exists $sectdata{$sect_id}) and mes(txt('dsid', {id=>$sect_id}), {warn=>1});
      push(@{$sectdata_depth[$depth]}, {sect_id => $sect_id, tag => $tag});

      # add close tag for the former section here if necessary
      # and set open tag for the current section here
      my $opentag = qq{<$tag class="mg" id="${sect_id}">\n} .
        (($secttitle) ? qq{<h1 class="sectiontitle">$secttitle</h1>\n} : '');
      $html[$sect_cnt]{tag} = $tag;
      if($lastdepth==$depth){
        if($lastdepth>0){
          $html[$sect_cnt-1]{close} ||=
          sprintf(
            qq{</%s> <!-- end of "%s" d=$depth -->\n}, $html[$sect_cnt-1]{tag}, $html[$sect_cnt-1]{sect_id}
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
        if(ref $v->{$k} eq 'ARRAY'){
          $sectdata_depth[$depth][-1]{val}{$k} = $v->{$k};
          $sectdata{$sect_id}{val}{$k}         = $v->{$k};          
        }elsif(ref $v->{$k} eq 'HASH'){
        }else{
          $sectdata_depth[$depth][-1]{val}{$k} = $v->{$k};
          $sectdata{$sect_id}{val}{$k}         = $v->{$k};
        }
      }
      $t=~s/\{\{sectid}}/$sect_id/g;

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
  if($depth!=0){
    for(my $i=$depth; $i>0; $i--){
      $html[-1]{close} .= sprintf(
         qq{</%s>\n},
         $sectdata_depth[$i][-1]{tag}
      );
    }
  }
  $htmlout .= join("\n", map{join("\n", $_->{open}||'', $_->{txt}||'', $_->{close}||'')} @html);
  $htmlout .= "\n";
  
  # template?
  if(defined $sectdata_depth[0][-1]{val}{template}){ # template mode
    (defined $TEMPLATE) or $TEMPLATE = $sectdata_depth[0][-1]{val}{template};
  }
  if(defined $TEMPLATE){
    # read vals
    my $opt1 = { %$opt };
    foreach my $k (grep {$_ ne 'template'} keys %{$sectdata_depth[0][-1]{val}}){
      $opt1->{_v}{$k} = $sectdata_depth[0][-1]{val}{$k};
    }

    # read parameters from input
    my %par;
    foreach my $html (@html){
      my($id, $txt) = ($html->{sect_id}||'_', $html->{txt});
      $par{$id} = $txt;
    }

    # set tmpl directory
    my $tmplfile;
    my @tmpldir  = (defined $TEMPLATEDIR) ? ($TEMPLATEDIR, getcwd()) : (getcwd());

    # search tmpl file in $tmpldir
    L1:{
      foreach my $d (@tmpldir){
        my $f = "$d/$TEMPLATE";
        (-f $f) and ($tmplfile = $f, last L1);
      }
      map { mes(txt('cft', undef, {t=>$TEMPLATE, d=>$_}), {q=>1}) } @tmpldir;
      foreach my $d (@tmpldir){
        my $f = "$d/_template";
        (-f $f) and ($tmplfile = $f, last L1);
      }
      map { mes(txt('cft', undef, {t=>'_template', d=>$_}), {q=>1}) } @tmpldir;
      # no template file found
      mes(txt('stc',undef), {err=>1});
    }
    open(my $fhi, '<:utf8', $tmplfile) or mes(txt('fnf', undef, {f=>$tmplfile}), {err=>1});
    mes(txt('ftf', undef, {t=>$tmplfile}), {q=>1});

    my $tmpltxt = join('', <$fhi>);
    # replace vals in tmpl with pars set above
    $tmpltxt=~s!\[\[(.*?)]]!
      my($val, @opt) = split(/\s+/, $1);
      if(exists $par{$val}){
        $par{$val};
      }else{
        (defined $opt1->{_v}{$val}) ? ($opt1->{_v}{$val}) : '';
      }
    !ge;
    (defined $opt->{whole}) and $tmpltxt = whole_html($tmpltxt, $opt);
    $htmlout = deref($tmpltxt);
  }else{ # non-template
    (defined $opt->{whole}) and $htmlout = whole_html($htmlout, $opt);
    $htmlout = deref($htmlout);
  }
  $htmlout = fancy_html($htmlout);
  return($htmlout);
} # sub to_html

sub parse{ # for CPAN
  my ($file, $encoding, $opts) = @_;
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
  my $title = $opt->{title} || 'Markgaab page';
  (defined $footnote_cnt) or $footnote_cnt->{'_'}{'*'} = 0;
  my $lang  = $opt->{_v}{lang} || $LANG || 'en';

  # verbatim
  $t0 =~ s/(^\%%%)\n(.*?)\n%%%$/        &save_quote('',     $1, $2)/esmg;
  # pre, code, citation, ...
  $t0 =~ s/(\{\{(pre|code|q(?:[ |]+[^|]+?)?)}})(.+?)\{\{end}}/&save_quote($2, $1, $3)/esmg;  
  $t0 =~ s/(^''')\n(.*?)\n'''$/         &save_quote('pre',  $1, $2)/esmg;
  $t0 =~ s/(^```)\n(.*?)\n```$/         &save_quote('code', $1, $2)/esmg;
  $t0 =~ s/(^""")([\w =]*)\n(.*?)\n"""$/&save_quote("q $2", $1, $3)/esmg;
    
  $t0 =~ s/'''(.*?)'''/&save_quote('pre', undef, $1)/esmg;

  # conv table to html
  $t0 =~ s/^\s*(\|.*?)[\n\r]+(?!\|)/table($1, {lang=>$lang})/esmg;
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
  my @r;
  my @localclass = ('mg');
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
        $t =~ s!\[([^]]*?)\]!anchor($1, $baseurl, $lang)!esg or
        $t =~ s!(\{\{([^|]*?)(?:\|([^{}]*?))?}})!
        call_macro(
          ((defined $2) ? $2 : ''),
          $opt,
          $baseurl,
          ((defined $3) ? split(/\|/, $3) : ())
        )!esg #or
      ) or last; # no subst need, then escape inner loop
    } # loop while subst needed

    $t=~s{(?:^|(?<=\n))([*#;:].*?(?:(?=\n[^*#;:])|$))}{my($r,$o)=list($1, $cr, $ptype, $para, $myclass); $r}esg;
    $t = add_p($t, $cr, $para, $ptype, $myclass, $opt);

    push(@r, $t);
  } # foreach $t # for each paragraph
  my $r = join("\n", @r);
  $r=~s/${MI}i=(\d+)${MO}/$save[$1]{txt}/g;
  if($cssfile){
    open(my $fho, '>', $cssfile) or mes(txt('fnw', undef, {f=>$cssfile}), {err=>1});# "Cannot modify $cssfile";
    print {$fho} css($CSS);
    close $fho;
  }
  (defined $footnotes{'_'}[0]) and $r .= qq{<hr>\n<footer>\n<ul style="list-style:none;">\n} . join("\n", (map {"<li>$_</li>"}  @{$footnotes{'_'}})) . "\n</ul>\n</footer>\n";
  ($opt->{table}) or $r=~s/[\s\n\r]*$//;
  $r=~s/^[\s\n\r]*//;
  return($r, $opt);
} # sub markgaab

sub fancy_html {
  my ($html) = @_;
  my $indc = ' ';
  my $depth = 0;
  # Arrays to store extracted substrings
  my @escape;
    
  # Extract comments
  $html =~ s{<!--\s*(.*?)\s*-->}{push(@escape, "\n\n<!--\n$1\n-->\n\n") && "$MI" . $#escape . "$MO"}gse;
    
  # Extract <code> and <pre> contents
  $html =~ s{(<(code|pre)>(.*?)<\/\2>)}{push(@escape, "\n<$2>\n$3\n</$2>\n") && "$MI" . $#escape . "$MO"}gse;

  # Remove all other line breaks
  #$html =~ s/[\r\n]+//g;

  # list of tags and text contents
  my @htmls = grep {/\S/} split(/(<.*?>)/, $html);

  my @o;
  my $ind=0;
  foreach (@htmls){
    s/<\s+/</g;
    s/\s+>/>/g;
    if(my($m,$m2) = m{</([!\w]+)(.*)>}){ # close tag
      if($m=~/^(html|head|body|div|section|header|footer|main|aside|nav|table|dl|ol|ul)$/i){
        $ind--; ($ind<0) and $ind=0;                         #close -> indent--
      }
      my $t = "$_";
      ($m =~ /^(html|head|body|div|p|section|header|footer|main|aside|nav|table|dl|ol|ul)$/i)
        and ($o[-1]!~/\n$/) and push(@o, "\n");               #close -> pre \n
      push(@o, ($o[-1]=~/\n$/) ? (($indc x $ind).$t) : $t);   #close -> indent+content
      #push(@o, $t);
      if($m=~/^(html|head|body|h\d|div|p|section|header|footer|main|aside|nav|table|dl|ol|ul|li|dt|dd|tr)$/i){
        ($o[-1]!~/\n$/) and push(@o, "\n");                   #close -> post \n
      }
    }elsif(($m,$m2) = m{<([!\w]+)(.*)>}){ # open tag
      if($m=~/^(html|head|body|h\d|div|p|section|header|footer|main|aside|nav|table|dl|ol|ul)$/i){
        ($o[-1]!~/\n$/) and push(@o, "\n");                   #open  -> pre \n
      }
      my $t = "$_";
      push(@o, (($o[-1]=~/\n/) ? (($indc x $ind).$t) : $t)); #open  -> indent+content
      ($m =~ /^(html|head|body|div|p|section|header|footer|main|aside|nav|table|dl|ol|ul|br)$/i)
        and ($o[-1]!~/\n$/)
        and push(@o, "\n");                                  #open  -> post \n
      if($m=~/^(html|head|body|div|section|header|footer|main|aside|nav|table|dl|ol|ul)$/i){
        $ind++;                                              #open  -> indent++
      }
    }else{ # content
      s/\s*$//;
      #push(@o, ($o[-1]=~/\n$/) ? (($indc x $ind).$_) : $_);   #cont -> indent+content
      push(@o, $_);
    }
  }
  my $o = join('', @o);
  $o =~ s{$MI(\d+)$MO}{$escape[$1]}ge;
  $o =~ s/\n{2,}/\n/sg;
  return($o);
} # fancy_html

sub tdump{
  my($x) = @_;
  for(my $i=0; $i<length($x); $i++){
    my $y = substr($x, $i, 1);
    printf STDERR "$i/%d: 0x%04x '$y'\n", length($x), ord($y);
  }
}

sub add_p{
  my($t, $cr, $para, $ptype, $class, $opt) = @_;
  $t=~/^\s*$/ and return('');
  $t = ($ptype eq 'header' or $ptype eq 'list')                                     ? "$t\n"
     : ($para eq 'br')                                                              ? "$t<br>$cr"
     : ($para eq 'nb')                                                              ? $t
     : $t=~m{<(html|body|head|p|table|img|figure|blockquote|[uod]l)[^>]*>.*</\1>}is ? $t
     : $t=~m{<!doctype}is                                                           ? $t
     : $t=~m{${MI}t=citlist}is ? $t
     : "<p${class}>\n$t" . (($t=~/\n$/)?'':"\n") . "</p>$cr$cr";
  return($t);
}

{
my %ref_cnt;
my %id_cnt_in_text;
sub deref_init{
  undef %ref_cnt;
  undef %id_cnt_in_text;
}
sub deref{
  my($r) = @_;
  my $seq=0;
  $r=~s! *(${MI}([^${MI}${MO}]+)${MI}t=(?:(fig|tbl|cit))?(?:${MI}l=([^${MI}${MO}]+))?${MO}) *!
    my($r0, $id, $type, $lang) = ($1, $2, $3, $4);
    ($lang) or $lang = $LANG || 'en';
    (not $type and not $REF{$id}) and mes(txt('idnd', undef, {id=>$id}), {err=>1});
    if(defined $REF{$id}{order}){
      $type = $REF{$id}{type} || mes(txt('idnd', undef, {id=>$id}), {warn=>1});
    }else{
      (defined $ref_cnt{$type}) or $ref_cnt{$type}=1;
      while(defined $REFASSIGN{$type}{$ref_cnt{$type}}){
        $ref_cnt{$type}++;
      }
      $REF{$id}{order} = $ref_cnt{$type};
      $REFASSIGN{$type}{$ref_cnt{$type}} = $id;
    }
    if($type){
      foreach my $l (@LANGS){
        $REF{$id}{inline_id}{$l} = txt("ref_${type}", $l, {n=>$REF{$id}{order}});
      }
      $id_cnt_in_text{$id}++;
      my $title = $REF{$id}{text}{$lang} || $REF{$id}{doi};
      $title=~s/<.*?>//g;
      # $REF{$id}{text}{$lang} = $REF{$id}{inline_id};
      if($type eq 'cit'){
        my $x = qq{<span id="${id}_$id_cnt_in_text{$id}" title="title">$REF{$id}{inline_id}{$lang}</span>};
      #  $REF{$id}{inline_id}{$lang} =
        qq{<a href="#reflist_${id}">$x</a>};
      }else{
        sprintf(q|<a href="#%s">%s</a>|, $id, $REF{$id}{inline_id}{$lang});
      }
    }else{
      $REF{$id}{inline_id}{$lang};
    }
  !ge;

    $r=~s!${MI}citlist(?:${MI}l=(\w*))${MO}!
      my($lang) = ($1);
      ($lang) or $lang = $LANG || 'en';
      my $o = '';
      my @citids = grep {($REF{$_}{type} eq 'cit') and ($REF{$_}{order}>0)} keys %REF;
      foreach my $id (sort {$REF{$a}{order} <=> $REF{$b}{order}} @citids){
        $lang = $REF{$id}{lang}[0] || $lang;
        $o .= qq{<li id="${id}">} . txt('cit', $lang, {n=>$REF{$id}{order}||''}) . ' ';
# links from mglist to text
        for(my $i=1; $i<=$id_cnt_in_text{$id}; $i++){
          $o .= sprintf(qq{<a href="#%s">%s</a>}, "${id}_$i", "^$i&nbsp; ");
        }
        $o .= ' ' . ($REF{$id}{text}{$lang}||'') . "</li>\n";
      }
      $o;
  !ge;
  return($r);
} # sub deref
}

sub whole_html{
  my($x, $opt) = @_;
  $x=~s/[\s\n\r]*$//s;
  #  my($cssfile, $cssflameworks) = map {$opt->{$_}} qw/cssfile cssflameworks/;
  # lang -> css font
  $CSS->{body}{'font-family'} = txt('font');

  my $cssfile = $opt->{cssfile} || '';
  my $style   = '';
  my $title   = $opt->{title} || 'Markgaab page';
  (defined $opt->{cssflameworks}[0]) and map {$style .= qq{<link rel="stylesheet" type="text/css" href="$_">\n}} @{$opt->{cssflameworks}};
  if(defined $cssfile and $cssfile ne ''){
    my $cssfile1 = basename($cssfile);
    $style .= qq{<link rel="stylesheet" type="text/css" href="$cssfile1">\n};
  }else{
    $style .= "<style>\n".css($CSS)."</style>\n";
  }
  $style   .= qq{<link rel="stylesheet" type="text/css" href="wini_final.css">\n};
  return <<"EOD";
<!DOCTYPE html>
<html lang="$LANG">
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
    if($x=~/^([;:*#])(([;:*#])(-)?(.*))/ and ($1 eq $rootlisttype)){
      if($4 eq '-'){
        push(@list, $1.$3.$5);
      }else{
        if($#list>=0){
          $list[-1] .=  "\n$2"; 
        }else{
          push(@list, $2);
        }
      }
      $rootlisttype = $1;
    }else{
      $x=~/^([;:*#])/ and $rootlisttype = $1;
      push(@list, $x);
    }
  }

  my($lastlisttype, $lastlisttag) = ('', '');
  foreach my $l (@list) {
    my %listopt;
    # line/page break
    if (($l=~s/^---$/<br style="page-break-after: always;">/) or
        ($l=~s/^--$/<br style="clear: both;">/)) {
      $t2 .= $l; next;
    }
    my($hmark, $hopt, $txt0) = $l=~/^\s*([#*:;])(\|\S+)?(\S*\s+.*)/s;
    ($txt0) or $t2 .= $l,next; # non-list content
    if($hopt ne ''){
      foreach my $o (split(/\|/, $hopt)){
        $o=~/^##(\w+)/ and push(@{$listopt{listclass}}, $1);
      }
    }
    my($txt1, undef) = markgaab($txt0, {para=>'nb'});
    $txt1=~s/([^\n])$/$1\n/;
    if($hmark){
      my($listtype, $listtag) = ($listtype{$hmark},  $listtag{$hmark});
      my $listtype_o = (scalar keys %listopt > 0)
        ? sprintf(qq!$listtype class="%s"!, join(' ', 'mglist', @{$listopt{listclass}}))
        : qq!$listtype class="mglist"!;
      ($lastlisttype ne $listtype) and $t2 .= qq!</$lastlisttype>\n<${listtype_o}>\n!;
      $t2 .= "<${listtag}>$txt1</$listtag>\n";
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
  : $t2=~m{<(html|body|head|p|table|img|figure|blockquote|[uod]l)}is ? $t2
  : $t2=~m{<!doctype}is                                                           ? $t2
  : "<p${myclass}>\n$t2" . (($t2=~/\n$/)?'':"\n") . "</p>$cr$cr"
  ): '', \%listitems);
} # sub list

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
  my(@p) = @_;
  my $par = readpars(\@p, qw/abbr text dfn list/);
  my $out;
  if($par->{list}[-1]){
    $out = qq!\n<ul class="abbrlist">\n!;
    foreach my $t (sort keys %abbr){
      $out .= "<li> <abbr>$t</abbr>: $abbr{$t}</li>\n";
    }
    $out .= "</ul>";
    return($out);
  }
  if($par->{abbr}[0]){
    my $ab = (($par->{text}[-1]) ? qq!<abbr title="$par->{text}[-1]">! : '<abbr>') . qq!$par->{abbr}[-1]</abbr>!;
    $out = ($par->{dfn}[-1]) ? qq!<dfn>$ab</dfn>! : $ab;
    $abbr{$par->{abbr}[-1]} = $par->{text}[-1];
  }else{
    $out = ($par->{text}[-1]) ? '<dfn>' . $par->{text}[-1] . '</dfn>' : '';
  }
  return($out);
}
sub abbr{ # return abbr list
  my($t) = @_;
  (defined $t) and return($abbr{$t});
  return([ map {{term=>$_, abbr=>$abbr{$_}}} keys %abbr ]);
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
      $o2=~s!^(dotted|dashed|solid|double|groove|ridge|inset|outset)$]!$style{"${prop}-style"}=$o2; ''!ge;
      $o2=~s!^([a-z]+|#[0-9a-f]{3}|#[0-9a-f]{6})$]!$style{"${prop}-color"} = color($1); ''!ige;
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
  my($macroname, $opt, $baseurl, @f) = @_;
  my(@class, @id);
  $macroname=~s/\#([^.#]+)/push(@id,    $1); ''/ge;
  $macroname=~s/\.([^.#]+)/push(@class, $1); ''/ge;
  my $class_id = join(' ', @class);
  ($class_id) and $class_id = qq{ class="${class_id}"};
  $class_id   .= ($id[0]) ? qq! id="$id[0]"! : '';
  $macroname=~s/^[\n\s]*//;
  $macroname=~s/[\n\s]*$//;
  ($macroname eq '') and return(span(\@f, $class_id));

  my($sep, @f1);
  (defined $MACROS{$macroname})      and return($MACROS{$macroname}(@f));
  ($macroname=~m{^[!?]+[=^]{0,2}$})  and return(question($macroname, @f));
  (($macroname=~m{^[a-zA-Z][-^~"%'`:,.<=/]{1,2}$})     or
  ($macroname=~m{^(AE|ETH|IJ|KK|Eng|CE|ss|AE'|gat)$}i) or
  ($macroname=~m{^'[a-zA-Z]{1,2}$}))                   and return(latin($macroname));
  ($macroname=~/^l$/i)               and return('&#x7b;'); # {
  ($macroname=~/^bar$/i )            and return('&#x7c;'); # |
  ($macroname=~/^r$/i)               and return('&#x7d;'); # }
  ($macroname=~/^sl$/i)              and return('&#x5b;'); # [
  ($macroname=~/^sr$/i)              and return('&#x5d;'); # ]
  ($macroname=~/^([=-]([fh*]*-)?+[>v^ud]+|[<v^ud]+[=-]([fh*]*-)?+)/i)
                                     and return(arrow($macroname, @f));
  ($macroname=~m{^[!-/:-@\[-~]$})    and (not defined $f[0]) and 
    return('&#x'.unpack('H*',$macroname).';'); # char -> ascii code
  ($macroname=~/^\@$/)               and return(term(@f)); # abbr
  ($macroname=~/^(rr|ref|cit)$/i)    and return(cit(\@f, $opt->{_v})); # reference
#  ($macroname=~/^(cit|ref)list$/i)  and return("${MI}###${MI}t=citlist${MO}");
  ($macroname=~/^(cit|ref)list$/i)   and return(citlist(\@f, $opt->{_v}));
  ($macroname=~/^(date|time|dt)$/i)  and return(date([@f, "type=$1"],  $opt->{_v}));
  ($macroname=~/^(stack)$/i)         and (
     ($sep, @f1) = ($f[0], @f[1..$#f]),
     return(join($sep, (ev(\@f1, $opt->{_v}))))
  );
  ($macroname=~/^(ev|eval|calc)$/i)  and return((ev(\@f, $opt->{_v}))[-1]);
  ($macroname=~/^va$/i)              and return(
    (defined $opt->{_v}{$f[0]}) ? $opt->{_v}{$f[0]} : (mes(txt('vnd', undef, {v=>$f[0]}), {warn=>1}), '')
  );
  #($macroname=~/^envname$/i)         and return($ENVNAME);
  ($macroname=~/^([oun]l)$/i)        and return(listmacro($1, \@f));
  ($macroname=~/^[IBUS]$/)           and $_=lc($macroname), return("<$_${class_id}>$f[0]</$_>");
  ($macroname eq 'i')                and return(qq!<span${class_id} style="font-style:italic;">$f[0]</span>!);
  ($macroname eq 'b')                and return(qq!<span${class_id} style="font-weight:bold;">$f[0]</span>!);
  ($macroname eq 'u')                and return(qq!<span${class_id} style="border-bottom: solid 1px;">$f[0]</span>!);
  ($macroname eq 's')                and return(qq!<span${class_id} style="text-decoration: line-through;">$f[0]</span>!);
  ($macroname=~/^ruby$/i)            and return(ruby(@f));
  ($macroname=~/^v$/i)               and return(qq!<span class="tategaki">$f[0]</span>!);
  ($macroname=~/^vv$/i)              and return(qq!<span class="tatetate">$f[0]</span>!);

  ($macroname=~m!([-_/*]+[-_/* ]*)!) and return(symmacro($1, $f[0]));

  my $errmes = mes(txt('mnf', undef, {m=>$macroname}), {warn=>1});
  return(sprintf(qq#\\{\\{%s}}<!-- $errmes -->#, join('|', $macroname, @f)));
}

sub test2303{
  $VERSION or Text::Markup::Wini::init();
  my $x = '[!!!{400w.png|400w|min1140|570:}{600w.png|600w|50vw}{800w.png|800w|100vw|}{1000w.png|1000w}x.png]';
  my $y = to_html($x);
  $DB::single=$DB::single=1;
  print "x=$x\ny=", Dumper $y;
  1;
}
sub kw{
  my($r, $x)=@_;
  my @r;
  my @r0 = ((ref $r) eq 'ARRAY' ? @$r : keys %$r);
  foreach my $w (@r0){
    ($w eq $x) and return($x);
    $w=~/^$x/ and push(@r, $w);
  }
  if(scalar @r == 1){ #no problem
    return($r[0]);
  }elsif(scalar @r == 0){ # no match
    mes(txt('idnm', undef, {x=>$x, id=>join(',', @r0)}), {warn=>1});
    return($x);
  }else{# multiple candidates
    mes(txt('idns', undef, {x=>$x, id=>join(',', @r0)}), {err=>1});
    return(undef);
  }
}

sub readpars{
  my($p, @list)=@_;
  my %pars; my @pars;
#  $p=~s/(?<=\{\{)(.)(?=}})/latin($1)/ge;
  (ref $p eq '') and $p=[$p];
#  my @par0 = (ref $p eq 'ARRAY') ? @$p : split(/\|/, $p);
  my @par0;
  map { # trim, escape latin chars, for each parameter
    my $a=$_; $a=~s/^\s+//; $a=~s/\s+$//; $a=~s/\{\{(.)}}/call_macro($1)/ge;
    push(@par0, ($a eq '') ? '' : split(/\|/,$a));
  } @$p;

  my %alias;
  foreach my $k0 (@list){
    my($k, @kk) = split(/\|/, $k0);
    $alias{$k} = $k;
    foreach my $kk (@kk){
      $alias{$kk} = $k;
    }
  }
  foreach my $x (@par0){
    if(my($k0,$v) = $x=~/(\w+)\s*=\s*(.*)\s*/){
      my $k = kw(\%alias, $k0);
      $v=~s/^(['"])(.*)\1$/$2/;
      push(@{$pars{$k}}, $v);
    }else{
      push(@pars, $x);
    }
  }

  foreach my $k0 (@list){
    my $k = (split(/\|/, $k0))[0]; # a|b|c -> a
    (exists $pars{$k}) or push(@{$pars{$k}}, shift(@pars));
  }
  return(\%pars);
}

{
my $i=-1;
sub save_quote{ # pre, code, cite ...
  my($cmd, $pre, $txt) = @_;
  $i++;
#  $txt=~s/^%%%/&#x25;&#x25;&#x25;/g;
#  $txt=~s/^'''/&#x27;&#x27;&#x27;/g;
#  $txt=~s/^"""/&#x22;&#x22;&#x22;/g;
#  $txt=~s/^```/&#x60;&#x60;&#x60;/g;
  $cmd = lc $cmd;
  if($cmd eq 'def'){
    return('');
  }
  $txt=~s{${MI}i=(\d+)${MO}}{
       my $ltag = $save[$1]{pre};
       my $rtag = ($ltag=~/\{/) ? '{{end}}' : $ltag;
       "${ltag}\n$save[$1]{txt}\n${rtag}\n";
     }ge;
  $save[$i] = {txt=>$txt, cmd=>$cmd, pre=>$pre};

  if($cmd=~/^q/){ # q
    my(@opts) = $cmd=~/(\w+=\S+)/g;
    my %opts;
    foreach my $o (@opts){
      my($k,$v) = $o=~/([^;]*?)=(.*)/;
      ($k) and $opts{$k} = $v;
    }
    ($opts{cite}) or $opts{cite} = 'http://example.com';
    my $r = <<"EOD";
<blockquote cite="$opts{cite}">
${MI}i=$i${MO}
</blockquote>
EOD
    return($r);
  }else{ # pre, code
    my($ltag, $rtag) = ($cmd eq 'code')?('<pre><code>','</code></pre>')
                      :($cmd eq 'pre') ?('<pre>',      '</pre>') : ('', '');
    return("$ltag\n${MI}i=$i${MO}\n$rtag");
  }
} # sub save_quote
} # env save_quote

sub cittxt{ # format text with '[]' -> matured reference text
  my($x, $f0, $lang) = @_; # $x: hash ref representing a cit; $f: format
  #(defined $x) or $x = {au=>['Kirk, James T.', 'Tanaka, Taro', 'Yamada-Suzuki, Hanako', 'McDonald, Ronald'], ti=>'XXX', ye=>2021}; # test
  #  (defined $f) or $f = "[au|1|lf][au|2-3|lf|l; |j] [au|4-|etal|r;] [ye]. [ti]. {{/|[jo]}} [vo][issue|p()]:[pp].";
  #(defined $f) or $f = '[au|j;&e2] %%%% [au|i]'."\n";
  ($lang) or $lang = $x->{lang}[0] || 'en';
  unless(defined $x->{au}[0]){
    $x->{au} = [qq!"$x->{ti}[0]"!]; # no author -> use title instead
    undef $x->{ti};
  }
  my $f = (defined $f0) ? txt($f0, $lang) : "[au|i]\n";
  $f=~s/\[(.*?)\]/cittxt_vals($x, $1, $lang)/ge;
  return($f);
}

sub cittxt_vals{ # subst. "[...]" in reference format to final value
  my($x0, $form, $lang) = @_;
  (defined $x0 and defined $form) or return();
  my($valname, @filter) = split(/\|/, $form);
  my @xx =map {
    #s/"/&quot;/g;
    #s/'/&apos;/g;
    /^[\d&]/ ? $_ : qq!'$_'!;
  } @{$x0->{$valname}}, @filter;
  my(@r) = ev([@xx], $x0, $lang);

  return($r[-1]);
} # cittxt_val()

sub join_and{ # qw/a b c/ -> "a, b and c"
  my($l, $sep, $and, $lastsep) = @_;
  my $res;
  ($sep) or $sep = ', ';
 l1:{
    if(defined $and and $and ne ''){
      my $last = $#$l-1;
      if($last>0){
        $res = join($sep, @$l[0..$last]) . " $and " . $l->[-1];
        last l1;
      }
    }
    $res = join($sep, @$l);
  } # l1
  return($res);
}

sub citlist{
  my($pars0, $opt) = @_;
  my($pars)        =  readpars($pars0, qw/lang/);
  my $lang = $pars->{lang}[01] || $opt->{lang} || $LANG || 'en';
  return(qq!<ul class="citlist">\n${MI}citlist${MI}l=${lang}${MO}\n</ul>!);
}

sub cit{
# {{ref|...}} -> 
# inline_id: "Suzuki, 2022"
  # text:  "Suzuki, T., et al 2022. Koraeshou no Kenkyu. Journal of Pseudoscience 10:100-110."
  my($pars0, $opt) = @_;
  my($pars)        = readpars($pars0, qw/id type cittype au ye jo vo is pp ti pu lang url doi accessdate form/);
  my $lang         = $pars->{lang}[-1] || $opt->{lang} || $LANG || 'en';
  my $id           = $pars->{id}[-1];
  my @bibopts = grep {!/^(id\d*|type|lang)$/ and defined $pars->{$_}[0] and $pars->{$_}[0]} keys %$pars;
  ($id) or mes(txt('idnd', undef, {id=>''}), {err=>1});

  if((scalar @bibopts)>0){
    # is newly-defined bibliography
    (defined $REF{$id}) and mes(txt('did', undef, {id=>$id}), {err=>1});
    $REF{$id} = {type=>'cit', text=>$REF{$id}{text}};
    my $tmptxt = ref_tmp_txt("id=$id", "type=cit", "lang=$lang");
    foreach my $i (grep {$_ ne 'lang' and $_ ne 'id'} keys %$pars){
      foreach my $x (@{$pars->{$i}}){
        (defined $x) and push(@{$REF{$id}{$i}}, $x);
      }
    }
    my $cittype  = $REF{$id}{cittype} || 'ja';
    my $cit_form = "cit_form_${cittype}";
    #$REF{$id}{inline_cit_id} = txt("cit_inline_${cittype}", $lang, {au=>$pars->{au}[0], ye=>$pars->{ye}[-1]})||''; # printf("%s, %s", $au1, ($pars->{yr}[-1]||''));
    foreach my $l (@LANGS){
      $REF{$id}{text}{$l} = cittxt($pars, $cit_form, $l); # sprintf("%s, %s", $au1, ($pars->{yr}[-1]||''))
    }
    $REF{$id}{type}    = 'cit';
    $REF{$id}{cittype} = $cittype;
    $REF{$id}{lang}    = [$lang];
    $REF{$id}{source}  = 0;
    return($tmptxt);
  }else{ # the ids should already be defined (for bib, fig, table ...)
    #((scalar keys %{$REF{$id}})==0) and mes(txt('udrefid', undef, {id=>$id}), {warn=>1});
    (defined $REF{$id})             or  mes(txt('udrefid', undef, {id=>$id}), {warn=>1});
    my $reftype = $REF{$id}{type} || $pars->{type}[-1];
    my $lang1 = $REF{$id}{lang}[0] || $lang;
    return(ref_tmp_txt("id=$id", "type=$reftype", "lang=$lang1", "dup=ok"));
  }
} # sub cit

sub ref_txt{
  my($id, $type, $order, $caption, $lang) = @_;
  for(my $i=0; $i<=$#LANGS; $i++){
    $REF{$id}{text}{$LANGS[$i]} = txt("ref_${type}", $LANGS[$i], {n=>$order});
  }
  $REFASSIGN{$type}{$order} = $id;
  
  $caption = ref_tmp_txt("id=${id}", "type=${type}", "lang=$lang") . " $caption";
  return($caption);
}

sub ref_tmp_txt{
  # make temporal ref template, "${MI}id.*{MO}"
  my $par        = readpars(\@_, qw/id type lang order dup/);
  my($id, $type, $lang, $order, $dup) = map {$par->{$_}[-1]} qw/id type lang order dup/;
  (defined $REF{$id}) or mes(txt('udrefid', $lang, {id=>$id}), {err=>1});
  my $type1  = ($type  eq '') ? '' : "${MI}t=${type}";
  my $lang1  = ($lang  eq '') ? '' : "${MI}l=${lang}";
  my $order1 = ($order eq '') ? '' : "${MI}o=${order}";
  my   $out = "${MI}${id}${type1}${lang1}${order1}${MO}";
#  ($dup ne 'ok') and (exists $REF{$id}) and mes(txt('did', $lang, {id=>$id}), {err=>1});
#  (defined $type) and (not defined $REF{$id}) and $REF{$id} = {type=>$type};
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
# [!image.png text]
# [!"image.png" text]
# [!!image.png|#x text] # figure
# [!image.png|< text]   # img with float:left
# [http://example.com text]
# [http://example.com|@@ text] # link with window specification
# [#goat text]  # link within page

  my($t, $baseurl, $lang) = @_;
  ($lang) or $lang = 'en';
  my @source;
  # {}{}{} ... -> source (or srcset) data
  $t=~s{\{([^>]*?)\}}{
    my $src0 = $1;
    push(@source, {});
    foreach my $t (split(/\|/, $src0)){
      if($t=~/^(\d+)w$/){
        push(@{$source[-1]{w}}, $1.'w');
      }elsif($t=~/^(\d+)x$/){
        push(@{$source[-1]{x}}, $1.'x');
      }elsif($t=~/^(min|max)(\d+)(px|vw)?$/){
        my($name, $val, $unit) = ($1, $2, $3||'px');
        my $valunit = $val.$unit;
        push(@{$source[-1]{$name}}, $valunit);
        push(@{$source[-1]{mq_size}}, "($name-width: $valunit)"); # mediaquery and size for img size
      }elsif($t=~/^(?:(\d*)(px|vw)?)?:(?:(\d*)(px|vw)?)?$/){
        my($val_w, $unit_w, $val_h, $unit_h) = 
          ($1 eq '') ? (undef, undef, $3, $4||'px')
                     : ($1, $2||'px', $3, $4||'px');
        my $valunit = $val_w.$unit_w;
        push(@{$source[-1]{width}}, $valunit);
        push(@{$source[-1]{mq_size}}, "$valunit,"); # mediaquery and size for img size
      }elsif($t=~/^(webp)$/){
        push(@{$source[-1]{type}}, $1);
      }else{
        push(@{$source[-1]{file}}, $t);
      }  
    }
    '';
  }ge;
  my($prefix, $url0, $text)          = $t=~m{([!?#]*)"(\S+)"\s+(.*)}s;
  ($url0) or ($prefix, $url0, $text) = $t=~m{([!?#]*)([^\s"]+)(?:\s*(.*))?}s;
  my($url, $opts) = (split(/\|/, $url0, 2), '', '');
  ($prefix eq '#') and $url=$prefix.$url;
  my($caption) = markgaab($text, {nocr=>1, para=>'nb'});
  ($caption eq '') and $caption = $url;

  # options
  my $style            = ($opts=~/</) ? "float: left;" : ($opts=~/>/) ? "float: right;" : '';
  my($id)              = $opts=~/#([-\w]+)/;
  ($id=~/^\d+$/)     and $id="fig$id";
  ($id=~/^fig(\d+)/) and my $id_n = $1;
  my @classes          = $opts=~/\.([-\w]+)/g;
  my($crop0, $width, $width_u, $height, $height_u)
    = ($opts=~/(c(?:[news]*))?(\d+)(px|%|vw|vh|em|ex)?x(\d+)(px|%|vw|vh|em|ex)?/) ? ($1,$2,$3,$4,$5) : ('',0,'',0,'');
  my $crop             = ($crop0 eq '')   ? ''
                       : ($crop0 eq 'c' or $crop0 eq 'cc') ? '50% 50%'
                       : ($crop0 eq 'cnw') ? '0 0'
                       : ($crop0 eq 'cn')  ? '50% 0'
                       : ($crop0 eq 'cne') ? '100% 0'
                       : ($crop0 eq 'cw')  ? '0 50%'
                       : ($crop0 eq 'ce')  ? '100% 50%'
                       : ($crop0 eq 'csw') ? '0 100%'
                       : ($crop0 eq 'cs')  ? '50% 100%'
                       : ($crop0 eq 'cse') ? '100% 100%' : '';
  ($crop ne '') and $crop = " object-fit: cover; object-position: $crop";
  my $imgstyle               = ($crop ne '') ? qq{style="$crop"} : '';
  my($width1, $height1, $imgopt);
  ($width)  and $width1   = "$width${width_u}";
  ($height) and $height1  = "$height${height_u}";
  $width    and $imgopt   = qq{ width="$width1"};
  $height   and $imgopt   .= qq{ height="$height1"};
  ($crop ne '') and $imgopt .= qq{ style="$crop"};
  my $target           = ($opts=~/@@/)?'_blank':($opts=~/@(\w+)/)?($1):'_self';
  my $img_id           = '';  # ID for <img ...>
  ($style) and $style  = qq{ style="$style"};
  if($prefix=~/[!?]/){ # img, figure
    my $class = join(' ', @classes); ($class) and $class = qq{ class="$class"};
    if(defined $id){
      $REF{$id}   = (defined $id_n)
        ? {type=>'fig', lang=>[$lang], order=>$id_n}
        : {type=>'fig', lang=>[$lang]};
      $caption = ref_txt($id, 'fig', $id_n, $caption, $lang);
      $img_id     = qq! id="$id"!; # ID for <img ...>
    }
    my $alttext = $text || $url;
    my $img;
    my $srcset_picture = ''; # option for <figure>
    my $srcset_img     = ''; # option for <img>
    #my($media0, $media, $type, $size);
    for(my $i=0; $i<=$#source; $i++){
      my($media0, $media, $type, $size);
      my @srcset;
      $media0 = '';
      ($source[$i]{min}[0]) and $media0 .= "(min-width: $source[$i]{min}[0])";
      ($source[$i]{max}[0]) and $media0 .= "(max-width: $source[$i]{max}[0])";
      ($media0) and $media = qq{ media="$media0"};
      $type  = (defined $source[$i]{type}[0]) ? qq{ type="image/$source[$i]{type}[0]"} : '';

      for(my $j=0; $j<=$#{$source[$i]{file}}; $j++){
        push(@srcset, join(' ', grep {$_ ne ''} $source[$i]{file}[$j], ($source[$i]{w}[$j]||''), ($source[$i]{x}[$j]||'')));
      }
      ($source[$i]{width}[0]) and my $width2 = qq! sizes="$source[$i]{width}[0]"!;
      (defined $srcset[0]) and $srcset_picture .= sprintf(qq{ <source srcset="%s"$media$type$width2>}, join(', ', @srcset));
      (defined $srcset[0]) and $srcset_img     .= join(', ', @srcset);
      if($srcset_img){ # Sizes must be set if $srcset_img is defined
        $size = ($width1) ? $width1 : '';
        (defined $source[0]{width}) and $size .= " $source[0]{width}[0]";
      }
    } # foreach @source
    my $sizes = ($source[0]{mq_size}[0]) ? join(' ', @{$source[0]{mq_size}}) : '';
    if($sizes){
      $sizes=~s/[,\s]*$//;
      $sizes = qq{ sizes="$sizes"};
    }
    if($prefix eq '!!!'){
      return(qq{<picture>$style${srcset_picture}<img src="$url" alt="$alttext"${img_id}$class$style$imgopt></picture>});
    }
    # make img with srcset
    $img = ($srcset_img) 
      ? qq!<img srcset="$srcset_img"!  
      : qq!<img!;
    ($sizes) and $img .= $sizes;
    $img .= qq! src="$url" alt="$alttext"${img_id}$class$style$imgopt>!;
    
    if($prefix eq '!!'){
      return(qq!<figure$style>$img<figcaption>$caption</figcaption></figure>!);
    }elsif($prefix eq '??'){
      return(qq!<figure$style><a href="$url" target="$target"><img src="$url" alt="${id}"${img_id}$class$imgopt></a><figcaption>$caption</figcaption></figure>!);
    }elsif($prefix eq '?'){
      return(qq!<a href="$url" target="$target">$img</a>!);
    }else{ # "!"
    #  return(qq!<img src="$url" alt="$alttext"${img_id}$class$style$imgopt>!);
      return($img);
    }
  }elsif($url=~/^[\d_]+$/){
    return(qq!<a href="$baseurl?aid=$url" target="$target">$caption</a>!);
  }else{
    return(qq!<a href="$url" target="$target">$caption</a>!);
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

sub table{
  my($in, $v)=@_;
  my $ln=0;
  my $lang = $v->{lang} || $LANG || 'en';
  my(@winiitem, @htmlitem, $caption, $footnotetext);
  my @footnotes; # footnotes in cells
  my $tbl_id;
  push(@{$htmlitem[0][0]{copt}{class}}, 'mgtable');

  #get caption & table setting - remove '^|-' lines from $in

  $in =~ s{(^\|-([^-].*$))\n}{
    my $caption0 = $2;
    $caption0=~s/\|\s*$//;
    ($caption, my $o0) = split(/ *\|(?= |$)/, $caption0, 2); # $caption=~s{[| ]*$}{};

    foreach my $o (split(/\s+/, $o0||'')){
      ($o eq '') and next;
      if($o =~ /([^=\s]+)="([^"]*)"/){
        my($k,$v) = ($1,$2);
        ($k eq 'class')  and push(@{$htmlitem[0][0]{copt}{class}}, $v), next;
        ($k eq 'border') and $htmlitem[0][0]{copt}{border}=$v         , next;
        push(@{$htmlitem[0][0]{copt}{style}{$k}}, $v);
      }

      if($o=~/^([<>])$/){
        $htmlitem[0][0]{copt}{style}{float}[0] = ($1 eq '<')?'left':'right';
      }
      if($o=~/^@@(\d*)([a-zA-Z]+|#[\da-fA-F]{3}|#[\da-fA-F]{6})?$/){ # @@1red -> {copt}{borderall} for each cell
        $htmlitem[0][0]{copt}{borderall} = 'solid ' . (($1)?$1:1) . 'px' . (($2)?" $2":'') ;
        #(defined $htmlitem[0][0]{copt}{$1.'border'}) or $htmlitem[0][0]{copt}{$1.'border'} = ($2)?$2:1; 
      }elsif($o=~/^([tbf])@(\d*)([a-zA-Z]+|#[\da-fA-F]{3}|#[\da-fA-F]{6})?$/){ # @1red -> {copt}{xborder}
        my($attr, $w, $col) = ($1, $2||1, $3||'black');
        $htmlitem[0][0]{copt}{"${attr}border"} = sprintf("0 0 0 %dpx %s", $w, $col); # https://stackoverflow.com/questions/18989958/how-to-set-border-to-tbody-element
      }elsif($o=~/([][_~@=|])([,;:]?)(\d*)([a-zA-Z]*|#[a-fA-F0-9]{3}|#[a-fA-F0-9]{6})?$/){ # @;1red -> {copt}{style}{border-*} for <table>
        my($a, $linestyle, $width, $color) = ($1, $2, $3, $4);
        my $b1 = borderstyle($linestyle, $width, $color);
        ($a=~/[[@|]/) and $htmlitem[0][0]{copt}{style}{'border-left'}[0]   = $b1;
        ($a=~/[]@|]/) and $htmlitem[0][0]{copt}{style}{'border-right'}[0]  = $b1;
        ($a=~/[_@=]/) and $htmlitem[0][0]{copt}{style}{'border-bottom'}[0] = $b1;
        ($a=~/[~@=]/) and $htmlitem[0][0]{copt}{style}{'border-top'}[0]    = $b1;
      }
      ($o=~/\.([-\w]+)/) and push(@{$htmlitem[0][0]{copt}{class}}, $1);

      # set table ID in caption
      if($o=~/#(\w+)/){
        $tbl_id=$1;
        ($tbl_id=~/^\d+$/) and $tbl_id = "tbl${tbl_id}";
        $htmlitem[0][0]{copt}{id}[0] = $tbl_id;
        $caption = id_caption($caption, $tbl_id, 'tbl', $lang);

      } # if defined $tbl_id
      while($o=~/\&([lrcjsebtm]+)/g){
        foreach my $x (split('',$1)){
          my $h = {qw/l left r right c center j justify s start e end/}->{$x};
          (defined $h) and push(@{$htmlitem[0][0]{copt}{style}{'text-align'}}, $h);
          my $v = {qw/t top m middle b bottom/}->{$x};
          (defined $v) and push(@{$htmlitem[0][0]{copt}{style}{'vertical-align'}}, $v);
        }
      }
    } # foreach $o
    ($caption)=markgaab($caption, {para=>'nb', nocr=>1});
    $caption=~s/[\s\n\r]+$//;
  ''}emg; # end of caption & table setting

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

  # winiitem -> htmlitem: for each col for each row
  my @rowlen;
  for($ln=$#winiitem; $ln>=1; $ln--){
    ($winiitem[$ln][1] =~ /^\|---/) and $htmlitem[$ln][0]{footnote}=$winiitem[$ln][2];
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
          $htmlitem[$ln][$col_n-1]{copt}{colspan} =
            (defined $htmlitem[$ln][$col_n]{copt}{colspan}) ? $htmlitem[$ln][$col_n]{copt}{colspan}+1 : 2;
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
        while($col=~/(([][_~=@|])(?:\2*))([,;:]?)(\d*)([a-zA-Z]*|#[a-fA-F0-9]{3}|#[a-fA-F0-9]{6})?/g){ # border setting
          my($m, $btype, $linestyle, $width, $color) = (length($1), $2, $3, $4, $5);
          my $n = borderstyle($linestyle, $width, $color);
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
            my $x =
              (defined $btype{$k}) ? $btype{$k}
             :(defined $htmlitem[0][0]{copt}{style}{"border-$k"}) ? $htmlitem[0][0]{copt}{style}{"border-$k"} : undef;
            #($color) and $x .= " $color";
            push(@{$htmlitem[$r][$c]{copt}{style}{"border-$k"}}, $x);
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
    } # for $cn

    for(my $i=1; $i<=$#{$htmlitem[$ln]}; $i++){ # set winified text to cells
      (defined $htmlitem[$ln][$i]) or next;
      my $cell = $htmlitem[$ln][$i];
      ($cell->{wini}, my $opt) = markgaab($cell->{val}, {para=>'nb', nocr=>1, table=>$htmlitem[0][0]{copt}{id}[0]});
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
  ## style for <table>
  my $id = (defined $htmlitem[0][0]{copt}{id}[0] and $htmlitem[0][0]{copt}{id}[0]=~/^\w+$/) ? qq! id="$htmlitem[0][0]{copt}{id}[0]"! : '';
  my $outtxt = sprintf(qq!\n<table${id} class="%s"!, join(' ', sort @{$htmlitem[0][0]{copt}{class}}));
  (defined $htmlitem[0][0]{copt}{border})      and $outtxt .= ' border="1"';
  $outtxt .= q{ style="border-collapse: collapse; };
#  (defined $htmlitem[0][0]{copt}{tborder}) and $outtxt .= qq!border: $htmlitem[0][0]{copt}{tborder};!;
  (defined $htmlitem[0][0]{copt}{tborder}) and $outtxt .= qq!box-shadow: $htmlitem[0][0]{copt}{tborder};!;
  foreach my $k (qw/text-align vertical-align color background-color float/){
    (defined $htmlitem[0][0]{copt}{style}{$k}) and $outtxt .= qq! $k: $htmlitem[0][0]{copt}{style}{$k}[0];!;
  }
  (defined $htmlitem[0][0]{copt}{border})      and $outtxt .= sprintf("border: solid %dpx;", $htmlitem[0][0]{copt}{border});
  foreach my $bt0 (qw/left right bottom top/){
    my $bt = "border-${bt0}";
    (defined $htmlitem[0][0]{copt}{style}{$bt}[0]) and $outtxt .= "$bt: $htmlitem[0][0]{copt}{style}{$bt}[0]; ";
  }
  $outtxt .= qq{">\n}; # end of style

  if(defined $caption){
    $caption=~s/(^\s*|\s*$)//g;
    ($caption ne '') and $outtxt .= "<caption>\n$caption\n</caption>\n";
  }
  $outtxt .= (defined $htmlitem[0][0]{copt}{bborder})?qq{<tbody style="box-shadow: $htmlitem[0][0]{copt}{bborder};">\n}:"<tbody>\n";

  ## style for each row
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
        if($htmlitem[0][0]{copt}{borderall}){
          $style{border} = $htmlitem[0][0]{copt}{borderall};
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
        my $style0 = join('; ', map {
                       "$_:" . ((ref $style{$_} eq 'ARRAY')?$style{$_}[0]:$style{$_})
                     } grep {defined $style{$_}} sort keys %style);
        ($style0) and $copt .= qq! style="${style0};"!; #option for each cell
        my $ctag = (
          (not $htmlitem[$rn][0]{footnote}) and (
          ($htmlitem[$rn][$_]{ctag} and $htmlitem[$rn][$_]{ctag} eq 'th') or
          ($htmlitem[0][$_]{ctag}   and $htmlitem[0][$_]{ctag}   eq 'th') or
          ($htmlitem[$rn][0]{ctag}  and $htmlitem[$rn][0]{ctag}  eq 'th'))
        )?'th':'td';
        sprintf("<$ctag$copt>%s</$ctag>", (defined ($htmlitem[$rn][$_]{wini}) ? $htmlitem[$rn][$_]{wini} : ''));
      } # if {copt}{rowspan}<=1 or {copt}{colpan}<=1
    } (1 .. $#{$htmlitem[1]}) # map
    ); # join
    $outtxt0 .= "</tr>\n";
    (defined $htmlitem[$rn][0]{footnote}) ? ($footnotetext .= $htmlitem[$rn][0]{footnote}) : ($outtxt .= $outtxt0);
  } # foreach $rn
  $outtxt .= "</tbody>\n";
  if(defined $footnotes[0] or defined $footnotetext){
    if(defined $footnotes[0]){ # $footnotetext+@footnotes->$footnotetext
      my $f = join(";\&nbsp;\n", @footnotes);
      $footnotetext = (defined $footnotetext)
       ? join('<br>', $footnotetext, $f)
       : $f;
    }
    $outtxt .= ((defined $htmlitem[0][0]{copt}{fborder}) ? qq{<tfoot style="box-shadow: $htmlitem[0][0]{copt}{fborder};">\n} : "<tfoot>\n")
            . sprintf(qq!<tr><td colspan="%d">${footnotetext}</td></tr>\n</tfoot>\n!, $#{$htmlitem[1]});
  } #if defined $footnotes[0] ...
  $outtxt .= "</table>\n\n";
  $outtxt=~s/\t+/ /g; # tab is separator of cells vertically unified
  return($outtxt);
} # sub table

sub borderstyle{
  my($linestyle, $width, $color) = @_;
  my $linestyles = {',', qw/dotted ; dashed : double/};
  $linestyle = ($linestyle) ? (exists $linestyles->{$linestyle}) ? $linestyles->{$linestyle} : '' : 'solid';
  return(sprintf("%s %dpx%s", $linestyle, ($width)?$width:0, ($color)?" $color":''));
}

sub id_caption{
  my($caption, $id, $type, $lang) = @_; # id('tbl123', 'tbl');
  if($id=~/^${type}(\d+)$/){ # table No.: forced numbering to be stored in %REF
    my $order  = $1;
    (exists $REF{$id}) and mes(txt('did', $lang, {id=>$id}), {err=>1});
    $REF{$id} = {order=>$order, type=>'tbl'};
    $caption = ref_txt($id, $type, $order, $caption, $lang) . ' ';
  }else{ # free-style table ID
    $REF{$id} = {type=>$type};
    $caption = ref_txt($id, $type, undef, $caption, $lang) . ' ';
  } # if id
  return($caption);
}

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
          
=begin c
        }elsif($v=~/^\[(.*)\]$/){ # array
          $val->{$k} = [map {s/^(["'])(.*)\1$/$2/; $_} split(/\s*[|,]\s*/, $1)];
        }elsif(my($v2) = $v=~/^\{(.*)\}$/){ # hash
          foreach my $token (split(/\s*,\s*/, $v2)){
            my($kk,$vv) = $token=~/(\S+)\s*:\s*(.*)/;
            $vv=~s/^(["'])(.*)\1$/$2/;
            $val->{$k}{$kk} = (ev($vv, $val))[-1];
          }
=end c

=cut

        }else{
          if($v=~/\|/){
            $v.='&join';
          }
          $val->{$k} = (ev($v, $val))[-1] ;
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
  # $v->{lang}[0]: ja or en
  my $p = readpars($x, qw/date weekday trad lang type/);
  my $type = $p->{type}[0] || 'date';
  my $lang = $p->{lang}[0] || $v->{lang} || $LANG || '';
  my $lc0  = setlocale(LC_ALL, txt('LOCALE', $lang));
  my @days = split(/\s+/, txt('date_days', $lang));
  my $form0= $p->{type}[0].(('', qw/dow trad dowtrad/)[($p->{weekday}[0]>0)+($p->{trad}[0]>0)*2]);
  my $form = txt($form0, $lang);
  my $t;
  ($p->{date}[0]) or $p->{date}[0] = localtime->datetime;
  if($p->{date}[0]=~/\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d/){
    $t = Time::Piece->strptime($p->{date}[0], "%Y-%m-%dT%H:%M:%S");
  }elsif($p->{date}[0]=~m!^(\d{4})[-/]?(\d{2})[-/]?(\d{2})$!){
    my $t0 = "$1-$2-$3";
    $t = Time::Piece->strptime($t0, "%Y-%m-%d");
  }elsif($p->{date}[0]=~/^(\d{2}):?(\d{2}):?(\d{2})/){ # 020304, 02:03:04
    $t = Time::Piece->strptime("$1-$2-$3", "%H-%M-%S");
  }else{
    my @n = split("[-/.T]", $p->{date}[0]);
    eval{ $t = Time::Piece->strptime("$n[0]-$n[1]-$n[2]", "%Y-%m-%d") };
      $@ and mes("Invalid date format: '$p->{date}[0]'", {err=>1, ln=>__LINE__});
  }
  
  if(($type eq 'd' or $type eq 'dt') and $p->{weekday}[0]){ # weekday name
    my $wd = $t->day(@days); # Sun, Mon, ...
    $form=~s/%a/$wd/g;
  }
  my $res = decode('utf-8', $t->strftime($form));
  setlocale(LC_TIME, $lc0);
  my $t0 = Time::Piece->strptime("2019-05-01", "%Y-%m-%d");
  if($t >= $t0){
  # heisei -> reiwa: 令和に対応してない古いglibcが「平成33年」とかを返してきてしまうことへの対症療法的対処
    $res=~s{平成(\d+)}{sprintf("令和%02d", $1-30)}ge;
  # 一部の環境で「令和01年」ではなく「令和1年」になってしまうので統一
   $res=~s{(明治|大正|昭和|平成|令和)(\d)(?!\d)}{$1 . '0' . $2}ge;
  }
  return($res);
} # sub date

sub ev{ # <, >, %in%, and so on
  my($s, $v, $lang) = @_;

  # $s: string or array reference. string: 'a,b|='
  # $v: reference of variables given from wini()
  
  my(@token) = (ref $s eq '') ? split(/((?<!\\)[|])/, $s)
             : map{ (split(/((?<!\\)[|])/, $_)) } @$s;
  my @stack;
  my %stack1; # temporal stacks
  for(my $i=0; $i<=$#token; $i++){
    my $t  = $token[$i];
    my($ini, $sep0);
    if($t=~/^&(move|copy)(<|<<|>|>>)\s*(\w+)/){
      my($act, $dir, $val) = ($1, $2, $3);
      if(($dir eq '<<' or $dir eq '<') and not exists $stack1{$val}){
        mes(txt('snd', $lang, {s=>$val}), {err=>1});
      }
      if($dir eq '>' or $dir eq '>>'){ # stack -> stack1
        push(@{$stack1{$val}}, @stack);
        if($act eq 'move'){
          @stack = ();
        }
      }else{ # stack1 -> stack
        @stack = @{$stack1{$val}};
        if($act eq 'move'){
          @{$stack1{$val}} = ();
        }
      }
    }elsif($t=~/&(union|isec|sdiff)\s*(\S)+\s+(\S)/){
      my($f, $x, $y) = ($1, ($2 eq '_')?\@stack:$stack1{$2}, ($3 eq '_')?\@stack:$stack1{$3});
      @stack = ($f eq 'union') ? union($x, $y)
             : ($f eq 'isec')  ? isec($x, $y) : sdiff($x, $y);
    }elsif($t eq '&uniq'){
      @stack = uniq(\@stack);
#---
    }elsif(($ini, $sep0)=$t=~/\&last_first(_ini)?([,.])?/ or # "Lastname, Firstname"
           ($ini, $sep0)=$t=~/\&first_last(_ini)?([,.])?/){  # "Firstname Lastname"
      my $sep    = ($sep0 eq ',') ? ', ' : ' ';
      my $period = ($sep0 eq '.') ? '.'  : ''; # for initial
      @stack = map {
         my($last, $first);
         if(/,/){  # "Kirk, James Tiberius"
           ($last, $first) = /([^,]*)(?:, *(.*))?/;
         }else{    # "James Tiberius Kirk"
           my @x = split;
           ($first, $last) = (join(' ', @x[0..$#x-1]), $x[-1]);
         }
         $ini and ($last, $first) = ((uc(substr($last,0,1))).$period, ((uc(substr($first,0,1))).$period));
         join($sep, ($t=~/\&last/) ? ($last, $first) : ($first, $last));
      } @stack;
    }elsif($t eq '&lastname'){
      map { s/([^,]*),.*/$1/; } @stack;
    }elsif($t=~/^\&ini_[afl](0)?$/){ # take first letter and capitalize. This should be used before 'fl' or 'fli' filter
      my $sep = ($1 eq '') ? ', ' : ' ';
      @stack = map {
      my($last, $first) = /([^,]*), *(.*)/;
      if(defined $last){
        if($t ne '&ini_l'){ # Initial for the first name
          my(@first0) = $first=~/\b([A-Z])/g;
          if($first0[0]){
            map {s/(\w)/$1./} @first0;
              $first = join(' ', @first0) . '';
            }
          }
          if($t ne '&ini_f'){ # Initial for the last name
            if($last=~/([A-Z])\w*-([A-Z])\w/){ # Yamada-Suzuki -> Y-S.
              $last = "$1-$2.";
            }else{
              my(@l) = $last=~/\b([A-Z])/g;
              $last  = join(' ', map {($_ eq '') ? '' : "$_."} @l);
            }
          }
          join($sep, grep {/\S/} ($last, $first));
        }else{
          ''
        }
      } @stack;

    }elsif($t=~/^\&morethan *(\d+)/){
      ((scalar @stack)<=$1) and return(()); # if list size is not more than $1, the list is canceled.
    }elsif($t=~/^\&cut_(lt|le|gt|ge) +(\S+)/){
      my($f, $x) = ($1, $2);
      if($f eq 'lt'){
        @stack = ($x=~/^[.\d]+/) ? (grep {$_ <  $x} @stack) : (grep { $_ lt $x} @stack);
      }elsif($f eq 'le'){
        @stack = ($x=~/^[.\d]+/) ? (grep {$_ <= $x} @stack) : (grep { $_ le $x} @stack);
      }elsif($f eq 'gt'){
        @stack = ($x=~/^[.\d]+/) ? (grep {$_ >  $x} @stack) : (grep { $_ gt $x} @stack);
      }elsif($f eq 'ge'){
        @stack = ($x=~/^[.\d]+/) ? (grep {$_ >= $x} @stack) : (grep { $_ ge $x} @stack);
      }
    }elsif($t=~/^\&sort([nr]*)/){ #sort #sortn #sortr #sortnr (n=numerical, r=reverse)
      my($x, $y) = ($1, $&);
      my($n, $r) = ($x=~/n/?1:0, $x=~/r/?1:0);
      if($r){
        @stack = sort {($n) ? ($b <=> $a) : ($b cmp $a)} @stack;
      }else{
        @stack = sort {($n) ? ($a <=> $b) : ($a cmp $b)} @stack;
      }
    }elsif($t=~/^\&split(.*)?/){ #split
      @stack = map {split(" ", $_)} @stack;
    }elsif($t=~/^\&join([,;])?([a&,;])?(\d*)(e)?$/){ #join
      # , : a, b, c,
      # ; : a; b; c;
      # ,a: a, b and c
      # ,&: a, b & c
      # ;&: a; b & c
      # 2e: a, b et al.
      # 3e: a, b, c et al.
      my($m1, $m2, $m3, $m4) = ($1, $2, $3, $4);
      if($t eq '&join'){
        ($t, $m1, $m2) = ('&join,,', ',', ',');
      }
      if(scalar @stack==0){
      }else{
        my $sep = ($m1) ? "$m1 " : ', ';
        my $and  = ($m2 eq '') ? ' '
                              :  txt('cit_and', $lang, 
                                 {a => (($m2 eq 'a') ? ' and ' : ($m2 eq '&') ? ' &amp; ' : "$m2 ")}
                                 );
      #my $and = txt('cit_and', $lang, {a=>$a0});
        my $n   = ($m3 and $m3<scalar @stack) ? $m3 : scalar @stack;
        my $etal= $m4;
        my $yy  = ($n) ? [(@stack)[0..($n-1)]] : [@stack];
        my $j   = ($and) ? (($#$yy) ? join($sep, @$yy[0..$#$yy-1]) . $and . $yy->[-1]
                                  : $yy->[0])
                         : join($sep, @$yy);
        ($etal) and (scalar @stack > $n) and $j .= txt('etal', $lang);
        @stack  = ($j);
      }
    }elsif($t=~/^\&l_(.*)$/){ # "abc"|l_&ast; -> "*abc"
      my $p = $1 || '&ast;'; # default: "abc"|l_ -> "*abc"
      @stack = map {s/^\s*//; ($_ ne '') ? "$p$_" : ''} @stack;
    }elsif($t=~/^\&r_(.*)$/){ # "abc"|r_* -> "abc*"
      my $p = $1 || '.'; # default: "abc"|r_ -> "abc."
      @stack = map {s/\s*$//; ($_ ne '') ? "$_$p" : ''} @stack;
    }elsif($t=~/^\&q_(.)?(.)?$/){ # "abc"|&q_ -> "'abc'"; "abc"|&q_() -> "(abc)"
      my($l, $r) = ($1||"'", $2||"'");
      @stack = map {($_ ne '') ? "${l}$_${r}" : ''} @stack;
    }elsif($t eq '&bold'){
      @stack = map {qq{&nbsp;<span style="font-weight:bold">$_</span>}} @stack;
    }elsif($t eq '&ita' or $t eq '&italic'){
      @stack = map {qq{&nbsp;<span style="font-style:italic">$_</span>}} @stack;
    }elsif($t eq '&cutdown'){
      @stack = grep {defined and /./} @stack;
    }elsif($t=~/^\&(if|unless)_empty(?: +(\w+))?$/){ # if array($2) is empty,... exit
      my($if, $name) = ($1, $2);
      my @x = ev_val($name, \@stack, \%stack1, $v);
      ((scalar @x == 0) and ($if eq 'if'))     and return();
      ((scalar @x >  0) and ($if eq 'unless')) and return(@stack);
    }elsif($t eq '&end'){
      return(@stack);
#====
    }elsif($t eq '&ucase'){
      @stack = map {uc}      @stack;
      #push(@stack, uc      $stack[-1]); # $token[$i-2]);
    }elsif($t eq '&ucase1'){
      @stack = map {ucfirst} @stack;
      #push(@stack, ucfirst $stack[-1]); # $token[$i-2]);
    }elsif($t eq '&lcase'){
      @stack = map {lc}      @stack;
      #push(@stack, lc      $stack[-1]); # $token[$i-2]);
    }elsif($t eq '&lcase1'){
      @stack = map {lcfirst} @stack;
      #push(@stack, lcfirst $stack[-1]); # $token[$i-2]);
    }elsif($t=~/^\&cat([^|]*)$/){
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
      ($op eq 'rnsort' or $op eq 'nrsort') 
                       and (@stack = sort {$b<=>$a} @stack), next;
      ($op eq 'tsort') and (@stack = sort {$a cmp $b} @stack), next;
      ($op eq 'trsort' or $op eq 'trsort') 
                       and (@stack = sort {$b cmp $a} @stack), next;
      ($op eq 'rev')   and (@stack = reverse @stack), next;
      my $op1; (($op1)=$op=~/cat\\?(.*)/) and (@stack = join($op1, @stack)), next;
      my %s;
      map {$s{$_}=$stack[0]} qw/tmin tmax nmin nmax lmax lmin/;
      map {$s{$_}=length($stack[0])} qw/lmax lmin/;
      map {$s{$_}=0} qw/nmaxi nmini tmaxi tmini lmaxi lmini/;

      for(my $i=0; $i<=$#stack; $i++){
        #printf ">> $i $stack[$i] %d lmax=%s lmaxi=%d lmin=%s lmini=%d\n", length($stack[$i]), $s{lmax}, $s{lmaxi}, $s{lmin}, $s{lmini};
        ($stack[$i]>$s{nmax})         and ($s{nmax}, $s{nmaxi}) = ($stack[$i], $i);
        ($stack[$i]<$s{nmin})         and ($s{nmin}, $s{nmini}) = ($stack[$i], $i);
        ($stack[$i] gt $s{tmax})      and ($s{tmax}, $s{tmaxi}) = ($stack[$i], $i);
        ($stack[$i] lt $s{tmin})      and ($s{tmin}, $s{tmini}) = ($stack[$i], $i);
        (length($stack[$i])>length($s{lmax})) 
                                      and ($s{lmax}, $s{lmaxi}) = ($stack[$i], $i);
        (length($stack[$i])<length($s{lmin}))
                                      and ($s{lmin}, $s{lmini}) = ($stack[$i], $i);
        $s{sum}=$s{total}+=$stack[$i];
      }
      $s{mean} = $s{total}/(scalar @stack);
      #push(@stack, $s{$op});
      @stack = ($s{$op});
    }elsif(($op) = $t=~m{^(\+|-|/|\*|%|\&(?:eq|ne|lt|gt|le|ge)|==|!=|<|<=|>|>=)$}){
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
    }elsif($t=~/^-?(?:\d+|\d+\.\d*)$/){ # constants (numeral)
      push(@stack, $t);
    }elsif($t=~/^\&/){ # illegal filter
      mes(txt('ilfi', $lang, {x=>$t}), {err=>1});
    }else{ # variables or formula
      if($t=~/^\w+$/){
        #printf STDERR "v:%s ev_val:%s\n", $v->{$t}, ev_val($t, \@stack, \%stack1, $v); 
        #push(@stack, $v->{$t});
        push(@stack, ev_val($t, \@stack, \%stack1, $v));
      }else{
        ($t ne '|') and push(@stack, array($t));
      }
    }
  } # for(my $i=0; $i<=$#token; $i++)
  return(@stack);
} # sub ev

sub ev_val{ # evaluate $stack1 first, then $v
  my($name, $stack, $stack1, $val) = @_; # references
  if($name eq '_' or $name eq ''){
    return(@$stack);
  }
  if(exists $stack1->{$name}){
    return(@{$stack1->{$name}});
  }elsif(exists $val->{$name}){
    if(ref $val->{$name} eq 'ARRAY'){
      return($val->{$name}[-1]);
    }else{
      return($val->{$name});
    }
  }
  return($sectdata{$name});
}

sub union{ # @a ∪ @b
   my($x, $y) = @_; # array references
   my %cnt = ();
   my @xx = uniq($x);
   my @yy = uniq($y);
   return(sort (grep {++$cnt{$_} == 1 } (@xx, @yy)))
}

sub isec{ # @a ∩ @b 
   my($x, $y) = @_; # array references
   my @xx = uniq($x);
   my @yy = uniq($y);
   my %cnt = ();
   return(sort (grep {++$cnt{$_} == 2 } (@xx, @yy)))
}

sub sdiff{ # @a - @b
  my($x, $y) = @_;
  my %cnt = ();
  my @xx = uniq($x);
  my @yy = uniq($y);
  map { $cnt{$_}-- } @yy;
  return(sort (grep {++$cnt{$_}==1} @xx));
}

sub uniq{ # (a,b,b,c,d,a,e) -> (a,b,c,d,e)
  my($x) = @_;
  my %y;
  map{ $y{$_}=1} @$x;
  return(sort keys %y);
}

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

sub latin2ascii{
# ö -> o
  my($x) = @_; # $x should be decoded by utf-8
  $x=~s/([^-=,.a-zA-Z0-9])/latin($1, {ascii=>1})/ge;
  return($x);
}

{
my %latin;
sub latin_init{
=begin c
'  acute accent
=  breve accent/ligature
<  caron accent
,  cedilla accent
^  circumflex accent/inverted
:  dieresis or umlaut mark
.  dot accent
`  grave accent
-  Hook
-  Icelandic
-  macron accent
,, ogonek accent
/  slash
-  stroke accent
~  tilde
=end c

=cut

  my $x0 =<<'EOD';
À 192 A A`
Á 193 A A'
Â 194 A A^
Ã 195 A A~
Ä 196 A A:
Å 197 A A%
Æ 198 AE AE
Ç 199 C C,
È 200 E E`
É 201 E E'
Ê 202 E E^
Ë 203 E E:
Ì 204 I I`
Í 205 I I'
Î 206 I I^
Ï 207 I I:
Ð 208 E ETH
Ñ 209 N N~
Ò 210 O O`
Ó 211 O O'
Ô 212 O O^
Õ 213 O O~
Ö 214 O O:
Ø 216 O O/
Ù 217 U U`
Ú 218 U U'
Û 219 U U^
Ü 220 U U:
Ý 221 Y Y`
Þ 222 p P-
ß 223 s s-
à 224 a a`
á 225 a a'
â 226 a a^
ã 227 a a~
ä 228 a a:
å 229 a a%
æ 230 ae ae
ç 231 c c,
è 232 e e`
é 233 e e'
ê 234 e e^
ë 235 e e:
ì 236 i i`
í 237 i i'
î 238 i i^
ï 239 i i:
ð 240 e eth
ñ 241 n n~
ò 242 o o`
ó 243 o o'
ô 244 o o^
õ 245 o o~
ö 246 o o:
ø 248 o o/
ù 249 u u`
ú 250 u u'
û 251 u u^
ü 252 u u:
ý 253 y y'
þ 254 p p-
ÿ 255 y y:
Ā 256 A A-
ā 257 a a-
Ă 258 A A=
ă 259 a a=
Ą 260 A A,
ą 261 a a,
Ć 262 C C'
ć 263 c c'
Ĉ 264 C C^
ĉ 265 c c^
Ċ 266 C C.
ċ 267 c c.
Č 268 C C<
č 269 c c<
Ď 270 D D<
ď 271 d d<
Đ 272 D D-
đ 273 d d-
Ē 274 E E-
ē 275 e e-
Ĕ 276 E E=
ĕ 277 e e=
Ė 278 E E.
ė 279 e e.
Ę 280 E E,
ę 281 e e,
Ě 282 E E<
ě 283 e e<
Ĝ 284 G G^
ĝ 285 g g^
Ğ 286 G G=
ğ 287 g g=
Ġ 288 G G.
ġ 289 g g.
Ģ 290 G G,
ģ 291 g g,
Ĥ 292 H H^
ĥ 293 h h^
Ħ 294 H H-
ħ 295 h h-
Ĩ 296 I I~
ĩ 297 i i~
Ī 298 I I-
ī 299 i i-
Ĭ 300 I I=
ĭ 301 i i=
Į 302 I I,,
į 303 i i,,
İ 304 I I.
ı 305 i i.
Ĳ 306 IJ IJ
ĳ 307 ij ij
Ĵ 308 j J^
ĵ 309 j j^
Ķ 310 K K,
ķ 311 k k,
ĸ 312 k kk
Ĺ 313 l L'
ĺ 314 l l'
Ļ 315 L L,
ļ 316 l l,
Ľ 317 L L<
ľ 318 l l<
Ŀ 319 L L.
ŀ 320 l l.
Ł 321 L L-
ł 322 l l-
Ń 323 N N'
ń 324 n n'
Ņ 325 N N,
ņ 326 n n,
Ň 327 N N<
ň 328 n n<
ŉ 329 n 'n
Ŋ 330 N Eng
ŋ 331 n eng
Ō 332 O O-
ō 333 o o-
Ŏ 334 O O=
ŏ 335 o o=
Ő 336 O O"
ő 337 o o"
Œ 338 CE CE
œ 339 ce ce
Ŕ 340 R R'
ŕ 341 r r'
Ŗ 342 R R,
ŗ 343 r r,
Ř 344 R R<
ř 345 r r<
Ś 346 S S'
ś 347 s s'
Ŝ 348 S S^
ŝ 349 s s^
Ş 350 S S,
ş 351 s s,
Š 352 S S<
š 353 s s<
Ţ 354 T T,
ţ 355 t t,
Ť 356 T T<
ť 357 t t<
Ŧ 358 T T-
ŧ 359 t t-
Ũ 360 U U~
ũ 361 u u~
Ū 362 U U-
ū 363 u u-
Ŭ 364 U U=
ŭ 365 u u=
Ů 366 U U%
ů 367 u u%
Ű 368 U U"
ű 369 u u"
Ų 370 U U,
ų 371 u u,
Ŵ 372 W W^
ŵ 373 w w^
Ŷ 374 Y Y^
ŷ 375 y y^
Ÿ 376 Y Y:
Ź 377 Z Z'
ź 378 z z'
Ż 379 Z Z.
ż 380 z z.
Ž 381 Z Z<
ž 382 z z<
ſ 383 S ss
ƒ 402 f f-
Ơ 416 O O''
ơ 417 o o''
Ư 431 U U''
ư 432 u u''
Ǎ 461 A A<
ǎ 462 a a<
Ǐ 463 I I<
ǐ 464 i i<
Ǒ 465 O O<
ǒ 466 o o<
Ǔ 467 U U<
ǔ 468 u u<
Ǖ 469 U U:-
ǖ 470 u u:-
Ǘ 471 U U:'
ǘ 472 u u:'
Ǚ 473 U U:<
ǚ 474 u u:<
Ǜ 475 U U:`
ǜ 476 u u:`
Ǻ 506 A A%'
ǻ 507 a a%'
Ǽ 508 AE AE'
ǽ 509 ae ae'
Ǿ 510 O O/'
ǿ 511 o o/'
Ά 902 A 'A
· 903 . gat
Έ 904 E 'E
Ή 905 H 'H
Ί 906 I 'I
Ό 908 O 'oO
Ύ 910 Y 'Y
Ώ 911 O 'OO
ΐ 912 i i:'
? 63  ? ?
! 33  ! !
¡ 161 ! !^
¿ 191 ? ?^
‽ 8253 ?! ?!==
⸘ 11800 ?! ?!=^
‼ 8252 !! !!=
⁇ 8263 ?? ??=
⁈ 8264 ?! ?!=
⁉ 8265 !? !?=

EOD
  foreach my $x1 (split(/\n/, $x0)){
    my(@f) = split(/\s+/, $x1);
    $latin{$f[0]} = {n=>$f[1], ascii=>$f[2], mg=>$f[3]};
    $latin{$f[3]} = $f[1];
  }
}  # sub latin_init

sub latin{
# https://www.codetable.net/
# https://www.benricho.org/symbol/tokusyu_10_accent.html
  my($x, $o) = @_;
  # $o->{'ascii'}: ö -> o; undef: ö -> &#246;
  (scalar keys %latin == 0) and latin_init();

  if(exists $latin{$x}){
    if(defined $o){
      $o->{ascii} and return($latin{$x}{ascii});
      $o->{mg}    and return($latin{$x}{mg});
    }else{
      if(exists $latin{$x}){
        return(sprintf('&#%d;', (ref $latin{$x} eq 'HASH') ? $latin{$x}{n} : $latin{$x}));
      }else{
        return(undef);
      }
    }
  }else{
    return(undef);
  }
} # sub latin

sub ncr{ #numeric character reference
  my(@x) = @_; # $x should be integer
  my $out = '';
  foreach my $x0 (@x){
    $out .= '&#'.$x0.';';
  }
  return($out);
}
  
sub question{
  my($macroname, @f) = @_;
  my($m1, $m2) = $macroname=~/([?!]+)([=^])?/;
  (scalar keys %latin == 0) and latin_init();

  my($left, $right) = ('','');
  if($macroname eq '!?=' or $macroname eq '?!='){
    $right = ncr($latin{'?!='});
    $left  = ($macroname eq '!?') ? ncr($latin{'!^'}, $latin{'?^'}) : ncr($latin{'?^'}, $latin{'!^'});
  }elsif($macroname eq '!?==' or $macroname eq '?!=='){
    $right = ncr($latin{'?!=='});
    $left  = ncr($latin{'?!=^'});
  }elsif($macroname eq '!^'){
    $right = $left = ncr($latin{'!^'});
  }elsif($macroname eq '?^'){
    $right = $left = ncr($latin{'?^'});
  }else{ # multiple '!' and/or '?'
    my @m = split(//, $m1);
    for(my $i=0; $i<=$#m; $i++){
      $right .= ncr($latin{$m[$i]});
      $left  =  ncr($latin{$m[$i].'^'}) . $left;
    }
  }
  return((defined $f[0]) ? ($left . $f[0] . $right) : $right);
}

} # env latin
1;

__DATA__
" <- dummy quotation mark to cancel meddling emacs cperl-mode auto indentation
|LOCALE|en_US.utf8|ja_JP.utf8|
|and| and |，|
|cft|Cannot find template {{t}} in {{d}}|テンプレートファイル{{t}}はディレクトリ{{d}}内に見つかりません|
|chkbibfile| Check reference ID list ({{f}}) | リファレンスID対応表（{{f}}）を確認してください|
|cit| [{{n}}] | [{{n}}] |
|cit_and|{{a}}|&nbsp;{{a}}&nbsp;|
## jornal article, in-line citation
|cit_inline_ja| ({{au}}, {{ye}}) | ({{au}}, {{ye}})|
!cit_form! [au|&ini_f|&last_first,|&join;a2e] [ye|&q_()] [ti|&r_] [jo|&ita] [vo][is|&q_()] ! [au|&lastname|&join,2e] [ye|&q_()] [ti|&r_] [jo|&ita] [vo][is|&q_()] !
## journal article, citation in reference list
!cit_form_ja! [au|&ini_f|&last_first,|&join;a2e] [ye|&q_()] [ti|&r_] [jo|&ita] [vo][is|&q_()]![au|&lastname|&join,2e] [ye|&q_()] [ti|&r_] [jo|&ita] [vo][is|&q_()] !
## book chapter, citation in reference list
!cit_form_bc! BC [au|&ini_f|&last_first_ini,|&join;&2e] [ye|&q_()] [ti|&r_] In [bo] ! [au|&ini_f|&last_first|&join,2e] [ye|&q_()] [ti|&r_] [jo|&ita] [vo][is|&q_()] !
## conference proceedings
!cit_form_pc! BC [au|&ini_f|&last_first_ini,|&join;&2e] [ye|&q_()] [ti|&r_] [co] [pl] ! [au|&ini_f|&last_first|&join,2e] [ye|&q_()] [ti|&r_] [co] !
## web site, citation in reference list
!cit_form_ws! WS [au|&ini_f|&last_first_ini,|&join;&2e] [ye|&q_()] [ti|&r_] [jo|&ita] in [] eds. [] ! [au|&ini_f|&last_first|&join,2e] [ye|&q_()] [ti|&r_] [jo|&ita] [vo][is|&q_()] !
##
|conv|Conv {{from}} -> {{to}}|変換 {{from}} -> {{to}}|
|date|%Y-%m-%d|%Y年%m月%d日|
|date_days|Sun Mon Tue Wed Thu Fri Sat|日 月 火 水 木 金 土|
|datedow|%a. %Y-%m-%d|%Y年%m月%d日 (%a)|
|datetrad|%b %d, %Y|%EY(%Y年)%m月%d日|
|datedowtrad|%a. %b %d, %Y|%EY(%Y年)%m月%d日 (%a)|
|dt|%Y-%m-%dT%H:%M:%S|%Y年%m月%d日 %H時%M分%S秒|
|dtdow|%a. %Y-%m-%dT%H:%M:%S|%Y年%m月%d日 (%a) %H時%M分%S秒|
|dttrad|%b %d, %Y %H:%M:%S|%EY(%Y年)%m月%d日 %H時%M分%S秒|
|dtdowtrad|%a. %b %d, %Y %H:%M:%S|%EY(%Y年)%m月%d日 (%a) %H時%M分%S秒|
|dci|Input: Dir {{d}}|入力元ディレクトリ： {{d}}|
|dco|Output: Dir {{d}}|出力先ディレクトリ： {{d}}|
|dfs|A directory and a file cannot be specified at the same time.|ディレクトリとファイルは同時に指定できません。|
|did|Duplicated ID:{{id}}|ID:{{id}}が重複しています|
|din|Input:   STDIN|入力元: 標準入力|
|dnf|Directory not found: ({{d}})|ディレクトリが見つかりません： ({{d}})|
|dnw|Directory not writable: ({{d}})|ディレクトリの書き込みができません： ({{d}})|
|dsid|Duplicated section ID:{{id}}|セクションID:{{id}}が重複しています|
|elnf|{{d}} for extra library not found|{{d}}が見たらず、エキストラライブラリに登録できません|
|Error|error|エラー|
|etal| et al.|他|
|fail|failed|失敗|
|fci|File {{f}} is chosen as input|ファイル{{f}}が入力元ファイルです|
|fin|completed|終了|
|fnf|File not found: ({{f}})|ファイルが見つかりません： ({{f}})|
|fnw|File not writable: ({{f}})|ファイルへの書き込みができません： ({{f}})|
|font|"Helvetica Neue", Arial, sans-serif|"Helvetica Neue", Arial, "Hiragino Kaku Gothic ProN", "Hiragino Sans", "BIZ UDPGothic", Meiryo, sans-serif|
|fso|File specification: OK|ファイル指定：有効|
|ftf|Found {{t}} as template file|テンプレートファイル{{t}}が見つかりました|
|idnd|ID {{id}} not defined|ID '{{id}}'は定義されていません|
|idnm|No ID matched for {{x}} in {{id}}|{{x}}に該当するIDが見当たりません（{{id}}）|
|idns|Multiple ID matched for {{x}} in {{id}}|{{x}}に該当するIDが複数あります（{{id}}）|
|if|input file:|入力ファイル：|
|ilfi|Illegal filter: {{x}}|不正なフィルター： {{x}}|
|ll|loaded library: {{lib}}|ライブラリロード完了： {{lib}}|
|llf|failed to load library '{{lib}}'|ライブラリロード失敗： {{lib}}|
|mds|Multiple directories cannot be specified|ディレクトリを複数指定することはできません|
|mnf|Cannot find Macro '{{m}}'|マクロ「{{m}}」が見つかりません|
|Message|Message|メッセージ|
|mt|{{col}}{{mestype}}{{reset}} at line {{ln}}. |{{reset}}{{ln}}行目にて{{col}}{{mestype}}{{reset}}：|
|opf|File {{f}} is opened in utf8|{{f}}をutf-8ファイルとして開きます|
|ref_cit| ({{n}}) | ({{n}}) |
|ref_fig|Fig. {{n}} | 図{{n}}|
|ref_tbl|Table {{n}} | 表{{n}}|
|rout|Output:  STDOUT|出力先: 標準出力|
|secnames|part chapter section subsection|部 章 節 項|
|snd|Temporal stack '{{s}}' not defined|一時スタック{{s}}が定義されていません|
|snf|Searched {{t}}, but not found|{{t}}の内部を検索しましたが見つかりません|
|stc|Specify template file correctly|テンプレートファイルを正しく設定してください|
|time|%H:%M:%S|%H時%M分%S秒|
|timetrad|%H:%M:%S|%H時%M分%S秒|
|timedowtrad|%H:%M:%S|%H時%M分%S秒|
|ttap|trying to add path '{{path}}' into library directory|{{path}}のライブラリディレクトリへの追加を試みます|
|ut|undefined text|未定義のテキスト|
|udrefid|undefined reference ID: {{id}}|未定義の参照ID: {{id}}|
|uref|undefined label|未定義のラベル|
|vnd|Variable '{{v}}' not defined|変数{{v}}が定義されていません|
|Warning|Warning|警告|
