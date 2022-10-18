#!/usr/bin/env perl

#package Text::Markup::Wini;
use strict;
use warnings;
use Test::More;
use utf8;
use Data::Dumper;
$ENV{LANG}='C';

use lib '.';
use Wini;
use lib './t';
use t;

our $DEBUG = (defined $ARGV[0] and $ARGV[0] eq '-d') ? 1 : 0;

my $mg;
my $html='';
my @data;
while(<DATA>){
  chomp;
  if(/^-$/){
    (defined $mg) and push(@data, {mg=>$mg, html=>$html});
    $mg   = <DATA>;
    chomp $mg;
    $html = '';
  }else{
    $html .= $_;
  }
}
push(@data, {mg=>$mg, html=>$html});

for(my $i=0; $i<=$#data; $i++){
  test1($data[$i]{mg}, $data[$i]{mg}, $data[$i]{html});
}
done_testing;

__DATA__
-
{{?}} : ?
<p>
&#63; : ?
</p>
-
{{!}} : !
<p>
&#33; : !
</p>
-
{{?!==|abc}} : ?!==|abc
<p>
&#11800;abc&#8253; : ?!==|abc
</p>
-
{{?!}} : ?!
<p>
&#63;&#33; : ?!
</p>
-
{{!?}} : !?
<p>
&#33;&#63; : !?
</p>
-
{{!^}} : !^
<p>
&#161; : !^
</p>
-
{{?!^}} : ?!^
<p>
&#63;&#33; : ?!^
</p>
-
{{?!=}} : ?!=
<p>
&#8264; : ?!=
</p>
-
{{?!==}} : ?!==
<p>
&#8253; : ?!==
</p>
-
{{!|abc}} : !|abc
<p>
&#161;abc&#33; : !|abc
</p>
-
{{!!?|abc}} : !!?|abc
<p>
&#191;&#161;&#161;abc&#33;&#33;&#63; : !!?|abc
</p>
