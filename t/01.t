use strict;
use warnings;
use Test::More;

use lib '..';
use wini;


subtest '{{b|...}}' => sub {
  my($o, undef) = WINI::wini('{{b|abc}}');
  $o=~s/[\n\r]*//g;
  is $o, '<p><span style="font-weight:bold;">abc</span></p>';
};

subtest '{{B|...}}' => sub {
  my($o, undef) = WINI::wini('{{B|abc}}');
  $o=~s/[\n\r]*//g;
  is $o, '<p><b>abc</b></p>';
};

subtest '{{*/|...}}' => sub {
  my($o, undef) = WINI::wini('{{*/|abc}}');
  $o=~s/[\n\r]*//g;
  is $o, '<p><span style="font-weight:bold; font-style:italic;">abc</span></p>';
};

subtest '{{ruby|...|...}}' => sub {
  my($o, undef) = WINI::wini('{{ruby|abc|ABC|xyz|XYZ}}');
  $o=~s/[\n\r]*//g;
  is $o, '<p><ruby>abc<rp>(</rp><rt>ABC</rt><rp>)</rp>xyz<rp>(</rp><rt>XYZ</rt><rp>)</rp></ruby></p>';
};

subtest '{{l}}{{r}}{{bar}}' => sub {
  my($o, undef) = WINI::wini('{{l}}{{r}}{{bar}}');
  $o=~s/[\n\r]*//g;
  is $o, '<p>&#x7b;&#x7d;&#x7c;</p>';
};

subtest 'Illegal macro name' => sub{
  my($o, undef) = WINI::wini('{{hyhyhy|www}}');
  $o=~s/[\n\r]*//g;
  is $o, q#<p>\{\{hyhyhy|www}}<!-- Macro named 'hyhyhy' not found! --></p>#;
};

subtest '__.^^.' => sub {
  my($o, undef) = WINI::wini('__a^^b');
  $o=~s/[\n\r]*//g;
  is $o, '<p><sub>a</sub><sup>b</sup></p>';
};

subtest '[http://example.com/hoge page]' => sub{
  my($o, undef) = WINI::wini('[hoge](http://example.com/hoge)');
  $o=~s/[\n\r]*//g;
  is $o, '<p><a href="http://example.com/hoge">hoge</a></p>';
};

subtest '[http://example.com/hoge page]' => sub{
  my($o, undef) = WINI::wini('[hoge](http://example.com/hoge)');
  $o=~s/[\n\r]*//g;
  is $o, '<p><a href="http://example.com/hoge">hoge</a></p>';
};

done_testing;