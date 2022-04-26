#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use Data::Dumper;
use Encode qw/encode decode/;
use File::Temp qw/tempfile/;
my($fh, $tempfile) = tempfile(TEMPLATE => "chk_t_result_XXXX", SUFFIX => ".tmp", TEMPDIR => 1);
print STDERR "tmp=$tempfile\n";

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
#($res{got}, $res{exp}) = ('', '');
my $r = decode('utf-8', `perl $infile 2>&1`);
@{$res{res}} = $r=~/((?:not )?ok \d+)/sg;
@{$res{got}} = $r=~/got:\s*'(.*?)'\n#\s*expected:/sg;
@{$res{exp}} = $r=~/expected:\s*'(.*?)'/sg;

print "=== File Comparison (got/expected) ===\n";
print join("\n", @{$res{res}}), "\n\n";
$DB::single=$DB::single=1;
1;
for(my $i=0; $i<=$#{$res{got}}; $i++){
  foreach my $mode (qw/got exp/){
    $res{$mode}[$i] or next;
    my $outfile = "${mode}${i}.html";
    open(my $fho, '>:utf8', $outfile) or die;
    print {$fho} <<'EOD';
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<style>
.reflist           {
                    list-style-type: none; margin: 0; padding: 0;: ;
                   }
</style>
<title>Markgaab test</title>
</head>
<body>
EOD

    $res{$mode}[$i] =~ s/^# *//gm;
    $res{$mode}[$i] =~ s/'.*//s;
    my @lines = grep {/./} split(/(<.*?>)/, $res{$mode}[$i]);
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
      my $cmd = "tidy -q -e -f $tempfile $outfile ";
      my $r   = system($cmd);
      if($r==0){
        print "$outfile: tidy ok\n";
      }else{
        print "$outfile: tidy ng\n";
      }
      open(my $fhi, '<:utf8', $tempfile) or die "Something wrong to running tidy";
      my $tidy_res = join('', map {" tidy> $_"} grep {/\w/} <$fhi>);
      $tidy_res=~/\w/ and print "$tidy_res\n";
      close $fhi;
      unlink $tempfile;
    }
  } # foreach $mode
} # for $i
