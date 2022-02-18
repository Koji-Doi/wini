#!/usr/bin/perl

package Text::Markup::Wini;
use strict;
use warnings;
use Test::More;

use lib '.';
use Wini;
init();
{
  my($o, undef) = to_html(<<'EOC');
===
a:1
b:2
 c:3
===

Value of variable 'b' is {{va|b}}.

EOC

  $o=~s/[\n\r]*//g;
  is $o, "<p>Value of variable 'b' is 2.</p>";
}
  
done_testing;
