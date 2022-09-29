#!/usr/bin/env perl

package Text::Markup::Wini;
use strict;
use warnings;
use Test::More;

use lib '.';
use Wini;
init();

sub std{
  my($x)=@_;
  $x=~s/[\n\r]*//g;
  $x=~s/> */>/g;
  $x=~s/\s{2,}//g;
  $x=~s/ +</</g;
  $x=~s/> +/>/g;
  return($x);
}

{
  my($o, undef) = to_html(<<'EOC');
root body

?#s1

?#second

?#s3 Third

??#s4 Third-1

??#s5 Third-1-1

third-1-1 body

?#s6 Forth

EOC
  $o=std($o);

my $p = <<EOC;


<p>
root body
</p>

<section class="mg" id="s1">


</section> <!-- end of "s1" d=ld=1 lastdepth=1 -->

<section class="mg" id="second">


</section> <!-- end of "second" d=ld=1 lastdepth=1 -->

<section class="mg" id="s3">
<h1 class="sectiontitle">Third</h1>



<section class="mg" id="s4">
<h1 class="sectiontitle">Third-1</h1>


</section> <!-- end of "s4" d=ld=2 lastdepth=2 -->

<section class="mg" id="s5">
<h1 class="sectiontitle">Third-1-1</h1>

<p>
third-1-1 body
</p>
</section> <!-- end of "s5" d=2 (6) -->
</section> <!-- end of "s3" *d=1 (6) -->

<section class="mg" id="s6">
<h1 class="sectiontitle">Forth</h1>
<!-- s6 -->



</section>

EOC
  $p=std($p);

  is $o, $p;
}


{
  my($o, undef) = to_html(<<'EOC');
root body

?h#s1

?s#s2

?a#s3 Third

??a#s4 Third-1

??a#s5 Third-1-1

third-1-1 body

?f#s6 Forth

?-

last of root section

EOC
  $o=std($o);

my $p = <<EOC;


<p>
root body
</p>

<header class="mg" id="s1">


</header> <!-- end of "s1" d=ld=1 lastdepth=1 -->

<aside class="mg" id="s2">


</aside> <!-- end of "s2" d=ld=1 lastdepth=1 -->

<article class="mg" id="s3">
<h1 class="sectiontitle">Third</h1>



<article class="mg" id="s4">
<h1 class="sectiontitle">Third-1</h1>


</article> <!-- end of "s4" d=ld=2 lastdepth=2 -->

<article class="mg" id="s5">
<h1 class="sectiontitle">Third-1-1</h1>

<p>
third-1-1 body
</p>
</article> <!-- end of "s5" d=2 (6) -->
</article> <!-- end of "s3" *d=1 (6) -->

<footer class="mg" id="s6">
<h1 class="sectiontitle">Forth</h1>
<!-- s6 -->

<p>
last of root section
</p>
</footer>

EOC
  $p=std($p);

  is $o, $p;
}


done_testing;

#!/usr/bin/env perl

package Text::Markup::Wini;
use strict;
use warnings;
use Test::More;
use File::Basename;
use File::Temp qw(tempdir);
use File::Path qw(remove_tree);
use lib '.';
use lib './t';
use Wini;
use is;
use t;
use Data::Dumper;
our($Indir, $Outdir);
our(@Infiles, @Outfiles);
our $DEBUG=0;

if(defined $ARGV[0] and $ARGV[0] eq '-d'){
  $DEBUG=1;
}

sub outdir4indir{
  my($indir) = @_;
  my($body) = $indir=~/(\w+$)/;
  return(tempdir("wini_out_${body}_XXXX"));
}

{
my $cnt=1;

sub test1{ # check output css and html files, in specifying indir/1.wini
  my($testname, $cmd, $indir, $outdir, $outfiles) = @_;
#  my $infile2  = $infile || "$indir/1.wini";
  my $outdir2  = $outdir || tempdir('wini_testout_XXXX');
  my $outfile2 = (defined $outfiles->[0]) ? $outfiles : ["$outdir2/1.html"]; 
  my $err="err${cnt}.log";
  $cmd=~s!\{\{indir}}!$indir!g;
  $cmd=~s!\{\{outdir}}!$outdir2!g;
  $cmd=~s!\{\{infile}}!${indir}/1.wini!g;
  $cmd=~s!\{\{outfile}}!${outdir2}/1.html!g;
  $cmd=~s!\{\{err}}!$err!g;

  ($DEBUG) and print STDERR "$cmd\n";
  my $r = system($cmd);
  ($r>0) and $r = $r >> 8;
  if($r>0){
    print STDERR (<<"EOD");
    Errror occured in trying '$cmd'.
    Return=$r
EOD
  }
  my $exp = join("\n", sort @$outfile2);
  my $got = join("\n", sort (<$outdir2/*.html>, <$outdir2/*.css>));
  $got=~s{${outdir2}/}{}sg;
  $got=~s/[\n\s]+/ /gs;
  is std($got), std($exp), $testname;
  $cnt++;
} # test1
}

# prepare test input files

my %indata;
my $mode="";
my $i=0;
$_=<DATA>;
while(<DATA>){
  if(/^---start mg(?:\s*(.*))?$/){
    $i++;
    my $x=$1;
    $mode='mg';
    $x=~s/[\n\r]*$//;
    $indata{tag}[$i]=$x;
    next;
  } 
  /^---start html/ and ($mode='html', next);
  /^---start log/  and ($mode='log', next);
  /^---end/ and last;
  $indata{$mode}[$i] .= $_;
}

prepare($indata{mg}, $indata{html});
#test_cmd("STDIN -> STDOUT",     {"<"=>"$indir/0.wini", ">"=>"$outdir/0.html"},                $outdir, ["$outdir/0.html"]);
for(my $i=1; $i<=$#{$indata{mg}}; $i++){
  Text::Markup::Wini::init();
  test_cmd($indata{tag}[$i], {i=>"$Indir/$i.mg", o=>"$Outdir/$i.html"}, $Outdir, ["$Outdir/$i.html"], [$indata{html}[$i]]);
}


(!$DEBUG) and (-d $Indir)   and (print("remove $Indir\n"),   remove_tree($Indir));
(!$DEBUG) and (-d $Outdir)  and (print("remove $Outdir\n"),  remove_tree($Outdir));
#(!$DEBUG) and (-d $outdir2) and (print("remove $outdir2\n"), remove_tree($outdir2));
(!$DEBUG) and map {unlink $_} <err*.log>;
done_testing;

__DATA__
"
---start mg A simple
{{B|abc}}
---start html A
<p>
<b>abc</b> 
</p>
---start log
---end
