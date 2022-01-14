#!/usr/bin/perl

package Text::Markup::Wini;
use strict;
use warnings;
use Test::More;

use lib '.';
use wini;

{
  my($o, undef) = markgaab('{{b|abc}}');
  $o=~s/[\n\r]*//g;
  is $o, '<p><span style="font-weight:bold;">abc</span></p>';
}

{
  my($o, undef) = markgaab('{{B|abc}}');
  $o=~s/[\n\r]*//g;
  is $o, '<p><b>abc</b></p>';
}

{
  my($o, undef) = markgaab('{{*/|abc}}');
  $o=~s/[\n\r]*//g;
  is $o, '<p><span style="font-weight:bold; font-style:italic;">abc</span></p>';
}

{
  my($o, undef) = markgaab('{{ruby|abc|ABC|xyz|XYZ}}');
  $o=~s/[\n\r]*//g;
  is $o, '<p><ruby>abc<rp>(</rp><rt>ABC</rt><rp>)</rp>xyz<rp>(</rp><rt>XYZ</rt><rp>)</rp></ruby></p>';
}

{
  my($o, undef) = markgaab('{{l}}{{r}}{{bar}}');
  $o=~s/[\n\r]*//g;
  is $o, '<p>&#x7b;&#x7d;&#x7c;</p>';
}

{
  my($o, undef) = markgaab('{{hyhyhy|www}}');
  $o=~s/[\n\r]*//g;
  is $o, q#<p>\{\{hyhyhy|www}}<!-- Macro named 'hyhyhy' not found! --></p>#;
}

{
  my($o, undef) = markgaab('__a^^b');
  $o=~s/[\n\r]*//g;
  is $o, '<p><sub>a</sub><sup>b</sup></p>';
}

{
  my($o, undef) = markgaab('[hoge](http://example.com/hoge)');
  $o=~s/[\n\r]*//g;
  is $o, '<p><a href="http://example.com/hoge">hoge</a></p>';
}

{
  my($o, undef) = markgaab('[hoge](http://example.com/hoge)');
  $o=~s/[\n\r]*//g;
  is $o, '<p><a href="http://example.com/hoge">hoge</a></p>';
}

done_testing;
