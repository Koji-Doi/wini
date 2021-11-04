#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

use lib '/home/koji/perl';
use mysystem;
use lib '.';
use wini;

{
  my($o, undef) = WINI::wini_sects(<<'EOC');
===
cmd: --title test
a:1
b:2
 c:3
===

Value of variable 'a' should be 1, is {{va|a}}.
Value of variable 'b' should be 2, is {{va|b}}.
Env name is {{envname}}.

? xxx

===
b:333
===

xxxx

Value of variable 'a' should be 1, is {{va|a}}.
Value of variable 'b' should be 333, is {{va|b}}.
Env name is {{envname}}.

?? yyy

===
c:444
===

Value of variable 'a' should be 1, is {{va|a}}.
Value of variable 'b' should be 333, is {{va|b}}.
Value of variable 'c' should be 444, is {{va|c}}.
EOC
  $o=~s/[\n\r]*//g;

my $p = <<EOC;


<p>
Value of variable 'a' should be 1, is 1.
Value of variable 'b' should be 2, is 2.
Env name is _.
</p>

<section class="wini" id="sect1">
<h1 class="sectiontitle">xxx</h1>

<p>
xxxx
</p>

<p>
Value of variable 'a' should be 1, is 1.
Value of variable 'b' should be 333, is 333.
Env name is _.
</p>

<section class="wini" id="sect2">
<h1 class="sectiontitle">yyy</h1>

<p>
Value of variable 'a' should be 1, is 1.
Value of variable 'b' should be 333, is 333.
Value of variable 'c' should be 444, is 444.
</p>

</section></section>

EOC
  $p=~s/[\n\r]*//g;

  is $o, $p;
}
  
done_testing;

