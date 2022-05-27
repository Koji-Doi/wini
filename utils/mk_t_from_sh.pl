#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use Data::Dumper;
use File::Temp 'tempdir';


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

my $tempdir1 = tempdir('tXXXX') or die 'Failed to create temp dir';
chdir $tempdir1;
my $fho;
while(<DATA>){
  chomp;
  if(/^---start\s+(\S+)/){
    print STDERR "Trying to create $1\n";
    open($fho, '>:utf8', $1) or die "Failed to open temp file '$1'";
  }elsif(/^---end/){
    close $fho;
  }else{
    (defined fileno $fho) and print {$fho} "$_\n";
  }
}

# do_it('touch a.txt', 'a_out.txt', 'a_err.txt');
sub do_it{
  my($cmd, $cmd_outfile, $cmd_errfile) = @_;
#  my($cmd_infile);
#  $cmd=~s{\s*<\s*(\S+)}{ $cmd_infile=$1;  ''}eg;
#  $cmd=~s{\s*2>\s*(\S+)}{$cmd_errfile=$1; ''}eg;
#  $cmd=~s{\s*>\s*(\S+)}{ $cmd_outfile=$1; ''}eg;

  if ($cmd=~/>/) {
    die "Output redirection with '>' is not allowed\n";
  }
  eval{
    system("$cmd > ${cmd_outfile} 2> ${cmd_errfile}");
  };
  if ($@) {
    print "error ", $@;
  }

}

my($cmd, $outfile) = @_;
($cmd)   or $cmd    ='touch a.txt';
$outfile or $outfile='out';
do_it($cmd, "$outfile.out", "$outfile.err");

__DATA__
---start a.txt
This is a.txt.
---start b.txt
This is b.txt.
---end

