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

done_testing;

__DATA__
h1	! heading1	<h1 class="mg">heading1</h1>
h2	!! heading2	<h2 class="mg">heading2</h2>
h1 with classname	!.class1 heading1	<h1 class="class1 mg">heading1</h1>
h1 with classnames	!.class1.class2 heading1	<h1 class="class1 class2 mg">heading1</h1>
h1 with id	!#id1 heading1	<h1 class="mg" id="id1">heading1</h1>
