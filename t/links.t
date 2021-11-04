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
links without link text.  [http://example.com]

Links with [http://example.com link text].

links with [link text in markdown-compartible format](http://example.com)

[#hoge inner link]

{{.hoge|Paragraph with ID}}



EOC
  $o=~s/[\n\r]*//g;

my $p = <<EOC;


<p>
links without link text.  <a href="http://example.com" target="_self">http://example.com</a>
</p>

<p>
Links with <a href="http://example.com" target="_self">link text</a>.
</p>

<p>
links with <a href="http://example.com">link text in markdown-compartible format</a>
</p>

<p>
<a href="#hoge" target="_self">inner link</a>
</p>

<p>
<span id="hoge">Paragraph with ID</span>
</p>


EOC
  $p=~s/[\n\r]*//g;

  is $o, $p;
}


done_testing;
