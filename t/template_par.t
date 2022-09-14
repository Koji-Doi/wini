#!/usr/bin/perl

#package Text::Markup::Wini;
use strict;
use warnings;
use Test::More;
use utf8;
use Data::Dumper;

use lib '.';
use Wini;
use File::Basename;
#use is;
Text::Markup::Wini::init();

sub std{
  my($x)=@_;
  $x=~s/[\n\r]//g;
  $x=~s/> */>/g;
  $x=~s/\s{2,}/ /g;
  $x=~s/ +</</g;
  $x=~s/> +/>/g;
  $x=~s{(</\w+>)}{$1\n}g;
  return($x);
}

my @indata;
my $basename = basename($0, qw/.t .pl .pm/);
my($parfile0, $tmplfile0) = ($basename.'templatetest.par', $basename.'templatetest.wini');
my $i=0;
my $mode="";
$_=<DATA>;
while(<DATA>){
  /^---start tmpl(?:\s*)(.*)/ and ($i++, $mode='tmpl', $indata[$i]{tag}=$1, next);
  /^---start par/  and ($mode='par',  next);
  /^---start html/ and ($mode='html', next);
  /^---start log/  and ($mode='log',  next);
  /^---end/ and last;
  $indata[$i]{$mode} .= $_;
}

# prepare input files
for(my $i=1; $i<=$#indata; $i++){
  my %infile = (par=>"no${i}$parfile0", tmpl=>"no${i}$tmplfile0");
  foreach my $k (keys %infile){
    open(my $fho, '>:utf8', $infile{$k}) or die "Failed to modify $infile{$k}";
    print {$fho} $indata[$i]{$k};
    close $fho;
  }
}

SKIP: for(my $i=1; $i<=$#indata; $i++){
  Text::Markup::Wini::init();
  my($parfile, $tmplfile) = ("no${i}$parfile0", "no${i}$tmplfile0");
  foreach my $whole ('', '--whole'){
    my $outfile = "$parfile${whole}.html";
    my $cmd = "perl Wini.pm ${whole} -q -i $parfile -o $outfile --outcssfile";
    print STDERR "$indata[$i]{tag}: $cmd\n";
    my $r = system($cmd);
    if($r!=0){
      die "Failure: $cmd";
    }
    open(my $phi, '<:utf8', $outfile) or die "Something wring on '$cmd'";
    my $o = join('', <$phi>);
    $o=~s{.*<body>}{}s;
    $o=~s{</body>.*}{}s;
    $o=~s/[\n\r]*//g;
    is std($o), std($indata[$i]{html}), "$indata[$i]{tag} $whole";
    close $phi;
  }
}

1;
done_testing;

__DATA__
"
---start tmpl simple replace
Var x from par file is [[x]], which should be 'abc'.

---start par 1
===
x: 'abc'
template: 'no1templatetest.wini'
===

---start html 1
Var x from par file is abc, which should be 'abc'.

---start tmpl replace with section
Var x from par file is [[x]], which should be 'abc'.

Main text which should be 'main text':
[[_]]

Section text which should be 'sect1text':
[[sect1]]

---start par 2
===
x: 'abc'
template: 'no2templatetest.wini'
===

main text

? sect1
sect1text

---start html 2
Var x from par file is abc, which should be 'abc'.
Main text which should be 'main text':
<p>main text</p>
Section text which should be 'sect1text':<p>sect1text</p>

---end
