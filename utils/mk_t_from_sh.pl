#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use Data::Dumper;

no warnings;
*Data::Dumper::qquote = sub { return encode "utf8", shift } ;
$Data::Dumper::Useperl = 1 ;
use warnings;

binmode STDIN,  ':utf8';
binmode STDOUT, ':utf8';
binmode STDERR, ':utf8';

# $ this.pl 'perl wini.pm < input.wini' hoge.t
# save STDOUT to hoge.t.stdout
# save STDERR to hoge.t.stderr
# save new test script to hoge.t

sub do_it{
  my($cmd, $cmd_infile, $cmd_outfile, $cmd_errfile) = @_;
#  my($cmd_infile, $cmd_errfile, $cmd_outfile) = ('','','');
#  $cmd=~s{\s*<\s*(\S+)}{ $cmd_infile=$1;  ''}eg;
#  $cmd=~s{\s*2>\s*(\S+)}{$cmd_errfile=$1; ''}eg;
#  $cmd=~s{\s*>\s*(\S+)}{ $cmd_outfile=$1; ''}eg;

  if ($cmd=~/>/) {
    die "Output redirection with '>' is not allowed\n";
  }
  eval{
    system("cat ${cmd_infile} | $cmd > ${cmd_outfile} 2> ${cmd_errfile}");
  };
  if ($@) {
    print "error ", $@;
  }

}

my($cmd, $infile, $outfile) = @_;
$outfile or $outfile='out';
do_it($cmd, $infile, "$outfile.out", "$outfile.err");
