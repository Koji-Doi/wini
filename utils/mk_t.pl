#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use Data::Dumper;
use lib '/home/kdoi2/l';
use mylib;
use arg;

no warnings;
*Data::Dumper::qquote = sub { return encode "utf8", shift } ;
$Data::Dumper::Useperl = 1 ;
use warnings;

binmode STDIN,  ':utf8';
binmode STDOUT, ':utf8';
binmode STDERR, ':utf8';

# % this.pl 'sh script' file1 file2 ...
my($sh, @files) = @ARGV;
my $files = join(', ', map {qq!'$_'!} @files);
while(<DATA>){
  s/{{sh}}/$sh/ge;
  s/{{files}}/$files/ge;
  print;
}
print "__DATA__\n";
foreach my $file (@files){
  open(my $fhi, '<:utf8', $file) or die "$file not found";
  print "---start $file\n";
  print <$fhi>;
  print "---end\n";
}

__DATA__
use strict;
use warnings;
use utf8;
use Data::Dumper;
use File::Temp 'tempdir';
use File::Path 'remove_tree';
use Cwd;
use Test::More;

no warnings;
*Data::Dumper::qquote = sub { return encode "utf8", shift } ;
$Data::Dumper::Useperl = 1 ;
use warnings;

binmode STDIN,  ':utf8';
binmode STDOUT, ':utf8';
binmode STDERR, ':utf8';
my $tempdir = tempdir('t_XXXX');
my $infile;
my %r;
while(<DATA>){
  chomp;
  if(/^---start (.*)/){
    $infile=$1;
  }elsif(/^---end/){
    undef $infile;
  }else{
    (defined $infile) and $r{$infile} .= "$_\n";
  }
}

my $odir = getcwd;
chdir $tempdir;
system(qq{ {{sh}} });

foreach my $file ({{files}}){
  open(my $fhi, '<:utf8', $file) or die;
  my $o = join('', <$fhi>);
  is $o, $r{$file};
}
chdir $odir;
remove_tree($tempdir);

done_testing;

