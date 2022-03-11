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
