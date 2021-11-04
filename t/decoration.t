#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

use lib '/home/koji/perl';
use mysystem;
use lib '.';
use wini;

{
  my($o, undef) = WINI::wini(<<'EOC');
{{b|bold}}
{{*|bold}}

{{i|italic}}
{{/|italic}}

{{u|underline}}
{{_|underline}}

{{s|strike}}
{{-|strike}}

{{B|keyword}}
{{I|inner voice}}
{{S|incorrect}}


{{*/_-|bold, italic, underline, and strike}}

{{**|important}}
{{***|very important}}



EOC
  $o=~s/[\n\r]*//g;

my $p = <<EOC;
<p>
<span style="font-weight:bold;">bold</span>
<span style="font-weight:bold;">bold</span>
</p>

<p>
<span style="font-style:italic;">italic</span>
<span style="font-style:italic;">italic</span>
</p>

<p>
<span style="border-bottom: solid 1px;">underline</span>
<span style="border-bottom: solid 1px;">underline</span>
</p>

<p>
<span style="text-decoration: line-through;">strike</span>
<span style="text-decoration: line-through;">strike</span>
</p>

<p>
<b>keyword</b>
<i>inner voice</i>
<s>incorrect</s>
</p>

<p>
<span style="font-weight:bold; border-bottom: solid 1px; text-decoration: line-through; font-style:italic;">bold, italic, underline, and strike</span>
</p>

<p>
<strong>important</strong>
<strong><strong>very important</strong></strong>
</p>


EOC
  $p=~s/[\n\r]*//g;

  is $o, $p;
}
  
done_testing;

