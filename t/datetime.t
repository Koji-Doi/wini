#!/usr/bin/env perl

package Text::Markup::Wini;
use strict;
use warnings;
use utf8;
use Time::Piece;
use Test::More;

use lib '.';
use wini;

binmode STDIN, ':utf8';
binmode STDERR,':utf8';
binmode STDOUT,':utf8';
init();

my @test = (
#>>
  "date|2021-02-05",                                   "<p>2021-02-05</p>",
  "date|2021-02-05|lang=ja",                           "<p>2021年02月05日</p>",
  "date|2021-02-05T07:20:00",                          "<p>2021-02-05</p>",
  "date|2021-02-05T07:20:00|lang=ja",                  "<p>2021年02月05日</p>",
  "date|2021-02-05T07:20:00|weekday=1|lang=ja",        "<p>2021年02月05日(金)</p>",
  "date|2021-02-05T07:20:00|weekday=1|trad=1|lang=ja", "<p>令和03年(2021年)02月05日(金)</p>",
  "date|2021-02-05T07:20:00|trad=1|lang=ja",           "<p>令和03年(2021年)02月05日</p>",
  "date|2021-02-05T07:20:00|weekday=1",                "<p>Fri.2021-02-05</p>",
  "date|2021-02-05T07:20:00|weekday=1|trad=1|lang=ja", "<p>令和03年(2021年)02月05日(金)</p>",
  "dt|2021-02-05",                                   "<p>2021-02-05T00:00:00</p>",
  "dt|2021-02-05|lang=ja",                           "<p>2021年02月05日00時00分00秒</p>",
  "dt|2021-02-05T07:20:00",                          "<p>2021-02-05T07:20:00</p>",
  "dt|2021-02-05T07:20:00|lang=ja",                  "<p>2021年02月05日07時20分00秒</p>",
  "dt|2021-02-05T07:20:00|weekday=1|lang=ja",        "<p>2021年02月05日(金)07時20分00秒</p>",
  "dt|2021-02-05T07:20:00|weekday=1|trad=1|lang=ja", "<p>令和03年(2021年)02月05日(金)07時20分00秒</p>",
  "dt|2021-02-05T07:20:00|trad=1|lang=ja",           "<p>令和03年(2021年)02月05日07時20分00秒</p>",
  "dt|2021-02-05T07:20:00|weekday=1",                "<p>Fri.2021-02-05T07:20:00</p>",
  "dt|2021-02-05T07:20:00|weekday=1|trad=1|lang=ja", "<p>令和03年(2021年)02月05日(金)07時20分00秒</p>",
#<<
);

for(my $i=0; $i<=$#test; $i+=2){
  my($o);
  eval {($o) = to_html("{{$test[$i]}}");};
  if($@){
    $DB::single=$DB::single=1;
    1;
  }
  $o=~s/[\n\s]//gs;
  is $test[$i+1], $o;
}

done_testing;
