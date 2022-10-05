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

done_testing;

__DATA__
subscript/superscript	H__2O C__6H__{12}O__6 1m^^2 ^^{235}U	<p>H<sub>2</sub>O C<sub>6</sub>H<sub>12</sub>O<sub>6</sub> 1m<sup>2</sup> <sup>235</sup>U</p>
strike	{{s|abc}}	<p><span style="text-decoration: line-through;">abc</span></p>
strike-	{{-|abc}}	<p><span style="text-decoration: line-through;">abc</span></p>
Strike	{{S|abc}}	<p><s>abc</s></p>
underline	{{u|abc}}	<p><span style="border-bottom: solid 1px;">abc</span></p>
underline_	{{_|abc}}	<p><span style="border-bottom: solid 1px;">abc</span></p>
Underline	{{U|abc}}	<p><u>abc</u></p>
ita	{{i|abc}}	<p><span style="font-style:italic;">abc</span></p>
ita/	{{/|abc}}	<p><span style="font-style:italic;">abc</span></p>
Ita	{{I|abc}}	<p><i>abc</i></p>
bold	{{b|abc}}	<p><span style="font-weight:bold;">abc</span></p>
bold*	{{*|abc}}	<p><span style="font-weight:bold;">abc</span></p>
Bold	{{B|abc}}	<p><b>abc</b></p>
bold/ita	{{*/|abc}}	<p><span style="font-weight:bold; font-style:italic;">abc</span></p>
nested	{{b|ab{{i|c}}}}	<p><span style="font-weight:bold;">ab<span style="font-style:italic;">c</span></span></p>
strong	{{*|abc}} {{**|abc}} {{***|abc}}	<p><span style="font-weight:bold;">abc</span> <strong>abc</strong> <strong><strong>abc</strong></strong></p>
ruby	{{ruby|abc|ABC|xyz|XYZ}}	<p><ruby>abc<rp>(</rp><rt>ABC</rt><rp>)</rp>xyz<rp>(</rp><rt>XYZ</rt><rp>)</rp></ruby></p>
#l_r_bar	{{l}}{{r}}{{bar}}	<p>&#x7b;&#x7d;&#x7c;</p>
ascii	{{*}}{{/}}{{&}}{{#}}{{"}}	<p>&#x2a;&#x2f;&#x26;&#x23;&#x22;</p>
