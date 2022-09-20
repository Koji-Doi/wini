#!/usr/bin/perl

#package Text::Markup::Wini;
use strict;
use warnings;
use Test::More;
use utf8;
use Data::Dumper;

use lib '.';
use Wini;
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

our %REF;
my @indata;
my $i=0;
my $mode="";
my @reflist;
$_=<DATA>;
while(<DATA>){
  if(/^---start reflist/ .. /---end reflist/){
    /^---/ or push(@reflist, $_);
  }else{
    /^---start mg/   and ($i++, $mode='mg', $indata[$i]{tag}=$_, next);
    /^---start html/ and ($mode='html', next);
    /^---start log/  and ($mode='log', next);
    /^---end/ and last;
    $indata[$i]{$mode} .= $_;
  }
}

my @files;
SKIP: for(my $i=1; $i<=$#indata; $i++){
  Text::Markup::Wini::init();

  my $infile   = "links_t$i.wini";
  my $htmlfile = "links_t$i.html";
  my $errfile  = "links_t$i.err.txt";
  push(@files, $infile, $htmlfile, $errfile);
  open(my $fho_w, '>:utf8', $infile);
  print {$fho_w} $indata[$i]{mg};
  close $fho_w;
  system("perl Wini.pm --quiet < $infile > $htmlfile 2>$errfile");
  open(my $fh_h, '<:utf8', $htmlfile);
  my $got = join("\n", <$fh_h>);
  is std($got), std($indata[$i]{html});
  if($indata[$i]{tag}=~/ e /){
    open(my $fh_log, '<:utf8', $errfile);
    my $got_e = join('', <$fh_log>);
    is std($got_e), std($indata[$i]{log});
  }
}

foreach my $f (@files){
  unlink $f;
}

1;
done_testing;

__DATA__
"
---start mg 1

links without link text.  [http://example.com]

---start html 1

<p>
links without link text.  <a href="http://example.com" target="_self">http://example.com</a>
</p>

---start mg 2

Links with [http://example.com link text].

---start html 2

<p>
Links with <a href="http://example.com" target="_self">link text</a>.
</p>

---start mg 3

links with [link text in markdown-compartible format](http://example.com)

---start html 3

<p>
links with <a href="http://example.com">link text in markdown-compartible format</a>
</p>

---start mg 4

[#hoge inner link]

---start html 4

<p>
<a href="#hoge" target="_self">inner link</a>
</p>

---start mg 5 ext ref

{{.hoge|Paragraph with ID}}

---start html 5

<p>
<span id="hoge">Paragraph with ID</span>
</p>

---end
