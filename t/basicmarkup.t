#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use File::Temp qw/tempfile tempdir/;
use lib '.';
use Wini;
use lib './t';
use t;
our $DEBUG=0;

if(defined $ARGV[0] and $ARGV[0] eq '-d'){
  $DEBUG=1;
}

sub test_cmd2{
  my($testname, $mg, $cmd_opt, $outdir, $outtxt, $err) = @_;
  (defined $outdir) or $outdir = tempdir('wini_out_XXXX');
  my($fho, $tfile) = tempfile("wini_in_XXXX", SUFFIX=>".mg");
  binmode($fho, ":utf8");
  print {$fho} "$mg\n";
  close $fho;
  $cmd_opt->{i}    = $tfile;
  $cmd_opt->{o}    = "$outdir/out.html";
  $cmd_opt->{'2>'} = "$outdir/err.log";
  test_cmd($testname, $cmd_opt, $outdir, [$cmd_opt->{o}, $cmd_opt->{'2>'}], [$outtxt, $err]);
  #unlink $tfile;
}
while(<DATA>){
  /^#/ and next;
  s/[\n\r]*$//;
  my($name, $src, $expect, $opt) = split(/\t/, $_);
  (defined $name) or next;
  test1($name, $src, $expect, $opt);
}

Text::Markup::Wini::init();
test_cmd2('unsupported macro', '{{hyhyhy|www}}', undef, undef, q#<p>\{\{hyhyhy|www}}<!-- Cannot find Macro 'hyhyhy' --></p>#, <<"EOT");
infile:  wini_in_.mg
cssfile: wini.css
outfile: wini_out_/out.html
File specification: OK
Warning at line 1604. 1218[Text::Markup::Wini::call_macro]@./Wini.pm <- 1055[Text::Markup::Wini::markgaab]@./Wini.pm <- 505[Text::Markup::Wini::to_html]@./Wini.pm <- 332[Text::Markup::Wini::stand_alone]@./Wini.pm
  Cannot find Macro 'hyhyhy'
EOT

#test_cmd('unsupported macro', '
#  my($o, undef) = markgaab('{{hyhyhy|www}}');
#  $o=~s/[\n\r]*//g;
#  is $o, q#<p>\{\{hyhyhy|www}}<!-- Cannot find Macro 'hyhyhy' --></p>#;

done_testing;
exit();

SKIP:{
  my($o, undef) = markgaab('{{b|abc}}');
  $o=~s/[\n\r]*//g;
  is $o, '<p><span style="font-weight:bold;">abc</span></p>';
}

SKIP:{
  my($o, undef) = markgaab('{{B|abc}}');
  $o=~s/[\n\r]*//g;
  is $o, '<p><b>abc</b></p>';
}

SKIP:{
  my($o, undef) = markgaab('{{*/|abc}}');
  $o=~s/[\n\r]*//g;
  is $o, '<p><span style="font-weight:bold; font-style:italic;">abc</span></p>';
}

SKIP:{
  my($o, undef) = markgaab('{{ruby|abc|ABC|xyz|XYZ}}');
  $o=~s/[\n\r]*//g;
  is $o, '<p><ruby>abc<rp>(</rp><rt>ABC</rt><rp>)</rp>xyz<rp>(</rp><rt>XYZ</rt><rp>)</rp></ruby></p>';
}

SKIP:{
  my($o, undef) = markgaab('{{l}}{{r}}{{bar}}');
  $o=~s/[\n\r]*//g;
  is $o, '<p>&#x7b;&#x7d;&#x7c;</p>';
}

SKIP:{
  my($o, undef) = markgaab('{{hyhyhy|www}}');
  $o=~s/[\n\r]*//g;
  is $o, q#<p>\{\{hyhyhy|www}}<!-- Cannot find Macro 'hyhyhy' --></p>#;
}

SKIP:{
  my($o, undef) = markgaab('__a^^b');
  $o=~s/[\n\r]*//g;
  is $o, '<p><sub>a</sub><sup>b</sup></p>';
}

SKIP:{
  my($o, undef) = markgaab('[hoge](http://example.com/hoge)');
  $o=~s/[\n\r]*//g;
  is $o, '<p><a href="http://example.com/hoge">hoge</a></p>';
}

SKIP:{
  my($o, undef) = markgaab('[hoge](http://example.com/hoge)');
  $o=~s/[\n\r]*//g;
  is $o, '<p><a href="http://example.com/hoge">hoge</a></p>';
}

done_testing;

__DATA__
bold	{{b|abc}}	<p><span style="font-weight:bold;">abc</span></p>
Bold	{{B|abc}}	<p><b>abc</b></p>
bold/ita	{{*/|abc}}	<p><span style="font-weight:bold; font-style:italic;">abc</span></p>
ruby	{{ruby|abc|ABC|xyz|XYZ}}	<p><ruby>abc<rp>(</rp><rt>ABC</rt><rp>)</rp>xyz<rp>(</rp><rt>XYZ</rt><rp>)</rp></ruby></p>
#l_r_bar	{{l}}{{r}}{{bar}}	<p>&#x7b;&#x7d;&#x7c;</p>
ascii	{{*}}{{/}}{{&}}{{#}}{{"}}	<p>&#x2a;&#x2f;&#x26;&#x23;&#x22;</p>
