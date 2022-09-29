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
  my $newdir  = outdir4indir($Indir);
  my $newfile = "$newdir/$i.html";
  test_cmd($indata{tag}[$i], {i=>"$Indir/$i.mg", o=>$newfile}, $newdir, [$newfile], [$indata{html}[$i]]);
  (!$DEBUG) and remove_tree($newdir);
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

---start mg B third level sections
root body

?#s1

?#second

?#s3 Third

??#s4 Third-1

??#s5 Third-1-1

third-1-1 body

?#s6 Forth

---start html
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

---start mg C header/aside/footer/article
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

---start html
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

---start mg D sections in multiple layers

? sect1

?? sect1-2-1

? sect2

??? sect2-x-1

? sect3

---start html
<section class="mg" id="sect1">
<h1 class="sectiontitle">sect1</h1>

<section class="mg" id="sect2">
<h1 class="sectiontitle">sect1-2-1</h1>


</section> <!-- end of "sect2" d=2 (3) -->
</section> <!-- end of "sect1" *d=1 (3) -->

<section class="mg" id="sect3">
<h1 class="sectiontitle">sect2</h1>
<!-- sect3 -->



<section class="mg" id="sect4">
<h1 class="sectiontitle">sect2-x-1</h1>


</section> <!-- end of "sect4" d=3 (5) -->
</section> <!-- end of "sect2" d=2 (5) -->
</section> <!-- end of "sect3" *d=1 (5) -->

<section class="mg" id="sect5">
<h1 class="sectiontitle">sect3</h1>
<!-- sect5 -->

</section>

---start mg E section/header in multiple layers

?h header1 

?? sect1-2-1

? sect2

??? sect2-x-1

? sect3

---start html
<header class="mg" id="sect1">
<h1 class="sectiontitle">header1</h1>

<section class="mg" id="sect2">
<h1 class="sectiontitle">sect1-2-1</h1>


</section> <!-- end of "sect2" d=2 (3) -->
</header> <!-- end of "sect1" *d=1 (3) -->

<section class="mg" id="sect3">
<h1 class="sectiontitle">sect2</h1>
<!-- sect3 -->

<section class="mg" id="sect4">
<h1 class="sectiontitle">sect2-x-1</h1>

</section> <!-- end of "sect4" d=3 (5) -->
</section> <!-- end of "sect2" d=2 (5) -->
</section> <!-- end of "sect3" *d=1 (5) -->

<section class="mg" id="sect5">
<h1 class="sectiontitle">sect3</h1>
<!-- sect5 -->

</section>

---start mg F section/header/footer in multiple layers

?h header1 

?? sect1-2-1

? sect2

??? sect2-x-1

?f footer1

---start html
<header class="mg" id="sect1">
<h1 class="sectiontitle">header1</h1>

<section class="mg" id="sect2">
<h1 class="sectiontitle">sect1-2-1</h1>


</section> <!-- end of "sect2" d=2 (3) -->
</header> <!-- end of "sect1" *d=1 (3) -->

<section class="mg" id="sect3">
<h1 class="sectiontitle">sect2</h1>
<!-- sect3 -->

<section class="mg" id="sect4">
<h1 class="sectiontitle">sect2-x-1</h1>

</section> <!-- end of "sect4" d=3 (5) -->
</section> <!-- end of "sect2" d=2 (5) -->
</section> <!-- end of "sect3" *d=1 (5) -->

<footer class="mg" id="sect5">
<h1 class="sectiontitle">footer1</h1>
<!-- sect5 -->

</footer>

---start mg G section/article/header in multiple layers

?h header1 

?? sect1-2-1

? sect2

??? sect2-x-1

?a article1

---start html
<header class="mg" id="sect1">
<h1 class="sectiontitle">header1</h1>

<section class="mg" id="sect2">
<h1 class="sectiontitle">sect1-2-1</h1>


</section> <!-- end of "sect2" d=2 (3) -->
</header> <!-- end of "sect1" *d=1 (3) -->

<section class="mg" id="sect3">
<h1 class="sectiontitle">sect2</h1>
<!-- sect3 -->

<section class="mg" id="sect4">
<h1 class="sectiontitle">sect2-x-1</h1>

</section> <!-- end of "sect4" d=3 (5) -->
</section> <!-- end of "sect2" d=2 (5) -->
</section> <!-- end of "sect3" *d=1 (5) -->

<article class="mg" id="sect5">
<h1 class="sectiontitle">article1</h1>
<!-- sect5 -->

</article>

---end
