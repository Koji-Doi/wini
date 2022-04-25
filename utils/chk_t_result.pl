#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use Data::Dumper;
use Encode qw/encode decode/;

no warnings;
*Data::Dumper::qquote = sub { return encode "utf8", shift } ;
$Data::Dumper::Useperl = 1 ;
use warnings;

binmode STDOUT, ':utf8';
binmode STDERR, ':utf8';

my $infile = $ARGV[0]; # "t/test.t"
($infile) or die "Specify test script.\n";
my $tidy_ok = `tidy -v`;

my %res;
($res{got}, $res{exp}) = ('', '');
my $r = decode('utf-8', `perl $infile 2>&1`);
($res{got}) = $r=~/got:\s*'(.*)'\n#\s*expected:/s;
($res{exp}) = $r=~/expected:\s*'(.*)/s;
foreach my $mode (qw/got exp/){
  $res{$mode} or next;
  my $outfile = "${mode}.html";
  open(my $fho, '>:utf8', $outfile) or die;
  print {$fho} <<'EOD';
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<title>Markgaab test</title>
</head>
<body>
EOD

  $res{$mode} =~ s/^# *//gm;
  $res{$mode} =~ s/'.*//s;
  my @lines = grep {/./} split(/(<.*?>)/, $res{$mode});
  foreach my $l (@lines){
    chomp $l;
    print {$fho} "$l\n";
  }

  print {$fho} <<'EOD';
</body>
</html>
EOD

  close $fho;
  if(defined $tidy_ok){
    open(my $fh, '-|', "tidy -q -e $outfile") or die;
    my $r = join('', <$fh>);
    ($r eq '') and print "$outfile: Tidy check ok\n";
    close $fh;
  }
} # foreach $mode

