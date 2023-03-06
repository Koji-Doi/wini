#!/usr/bin/env perl

package Text::Markup::Wini;
use strict;
use warnings;
use Test::More;
use File::Basename;
use File::Temp qw(tempdir tempfile);
use File::Path qw(remove_tree);
use lib '.';
use lib './t';
use Wini;
use t;

our($Indir, $Outdir);
our(@Infiles, @Outfiles);
our $DEBUG = (defined $ARGV[0] and $ARGV[0] eq '-d') ? 1 : 0;

# preparation
my $testoutdir = "testoutdir";
my $testdir = 'testdir';
(-d $testdir)  or mkdir $testdir;
my $testdir1 = "$testdir/subdir1";
(-d $testdir1) or mkdir $testdir1;
my $testdir2 = "$testdir/subdir2";
(-d $testdir2) or mkdir $testdir2;
my $testdir11 = "$testdir1/subdir11";
(-d $testdir11) or mkdir $testdir11;
my @body="a".."d";
my $i=0;
my @expfiles;
foreach my $d ($testdir, $testdir1, $testdir2, $testdir11){
  my $file = "$d/$body[$i].mg";
  open(my $fho, '>', $file) or die "Cannot modify: ${file}";
  push(@expfiles, map {s/testdir/testoutdir/; $_} "${file}.html");
  print {$fho} "$body[$i]\n";
  close $fho;
  $i++;
}

system(q!./Wini.pm -i "testdir/" -o "testoutdir/"!);
push(my @files, <testoutdir/*.html>, <testoutdir/subdir1/*.html>, <testoutdir/subdir2/*.html>, <testoutdir/subdir1/subdir11/*.html>);
is join(' ', @files), 'testoutdir/a.mg.html testoutdir/subdir1/b.mg.html testoutdir/subdir2/c.mg.html testoutdir/subdir1/subdir11/d.mg.html', 'test';

done_testing();