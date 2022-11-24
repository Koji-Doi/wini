#!/usr/bin/env perl

#package Text::Markup::Wini;
use strict;
use warnings;
use Test::More;
use utf8;
use Data::Dumper;

use lib '.';
use Wini;
use File::Basename;
use lib './t';
use t;
our $DEBUG = (defined $ARGV[0] and $ARGV[0] eq '-d') ? 1 : 0;
Text::Markup::Wini::init();

=begin c

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

=end c

=cut

sub std1{
  my($x) = @_;
  $x=~s/ +/ /g;
  $x=~s/\s+$//sg;
  $x=~s/^\s+//;
  $x=~s/\n+/\n/g;
  return($x);
}

my @indata;
my $basename = basename($0, qw/.t .pl .pm/);
my($parfile0, $tmplfile0) = ($basename.'_tmpl.par', $basename.'_tmpl.wini');
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
my @infile;
for(my $i=1; $i<=$#indata; $i++){
  $infile[$i] = {par=>"no${i}$parfile0", tmpl=>"no${i}$tmplfile0"};
  foreach my $k (keys %{$infile[$i]}){
    open(my $fho, '>:utf8', $infile[$i]{$k}) or die "Failed to modify $infile[$i]{$k}";
    my $out = $indata[$i]{$k};
    $out=~s/template:.*$/template: '$infile[$i]{tmpl}'/gm;
    print {$fho} $out;
    close $fho;
  }
}

SKIP: for(my $i=1; $i<=$#indata; $i++){
  Text::Markup::Wini::init();
  my($parfile, $tmplfile) = ($infile[$i]{par}, $infile[$i]{tmpl}); # ("no${i}$parfile0", "no${i}$tmplfile0");
  foreach my $whole ('', '--whole'){
    my $outfile = "$parfile${whole}.html";
    $infile[$i]{"outhtml$whole"} = $outfile;
    $infile[$i]{outcss}          = "${parfile}.css";
    my $cmd = "perl Wini.pm ${whole} -q -i $parfile -o $outfile --outcssfile";
    ($DEBUG) and print STDERR "*** $indata[$i]{tag}: $cmd\n";
    my $r = system($cmd);
    if($r!=0){
      die "Failure: $cmd";
    }
    open(my $phi, '<:utf8', $outfile) or die "Something wrong on '$cmd'";
    my $o = join('', <$phi>);
    $o=~s{.*<body>}{}s;
    $o=~s{</body>.*}{}s;
    #$o=~s/[\n\r]*//g;
    is1( std1($o, {spc=>0}), std1($indata[$i]{html}, {spc=>0}), "$indata[$i]{tag} $whole");
    #is1($o, $indata[$i]{html}, "$indata[$i]{tag} $whole");
    close $phi;
  }
}

unless($DEBUG){
  foreach my $x (@infile){
    foreach my $k (keys %$x){
      #print STDERR "del $x->{$k}\n";
      unlink $x->{$k};
    }
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
template: 
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
template: 
===

main text

? sect1
sect1text

---start html 2
Var x from par file is abc, which should be 'abc'.
Main text which should be 'main text':
<p>
main text
</p>
Section text which should be 'sect1text':
<p>
sect1text
</p>

---start tmpl mg text replace

Main text in mg

[[_]]

---start par 3

main text in {{B|mg}} 

---start html 3

<p>
main text in <b>mg</b>
</p>

---end
