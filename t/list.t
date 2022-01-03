#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

use lib '/home/koji/perl';
use mysystem;
use lib '.';
use wini;

sub std{
  my($x)=@_;
  $x=~s/[\n\r]*//g;
  $x=~s/> */>/g;
  $x=~s/\s{2,}//g;
  $x=~s/ +</</g;
  $x=~s/> +/>/g;
  return($x);
}


{
  my($o, undef) = WINI::to_html(<<'EOC');
* a
* b


EOC
  $o=std($o);

my $p = <<EOC;



<ul class="winilist">
<li> a
</li>
<li> b
</li>
</ul>


EOC
  $p=std($p);

  is $o, $p;
}


{
  my($o, undef) = WINI::to_html(<<'EOC');
# a
# b


EOC
  $o=std($o);

my $p = <<EOC;



<ol class="winilist">
<li> a
</li>
<li> b
</li>
</ol>


EOC
  $p=std($p);

  is $o, $p;
}


{
  my($o, undef) = WINI::to_html(<<'EOC');
; a
: a-text

; a
: a-text
:* a-text-list1
:* a-text-list2

; b
:* b-text-list1
:* b-text-list2

; c
:* c-text-list1
:* c-text-list2
: c-text
:# c-text-n1
:# c-text-n2
:## c-text-n2-n1
:## c-text-n2-n2
; c2

EOC
  $o=std($o);

my $p = <<EOC;



<dl class="winilist">
<dt> a
</dt>
<dd> a-text
</dd>
</dl>

<dl class="winilist">
<dt> a
</dt>
<dd> a-text
<ul class="winilist">
<li> a-text-list1
</li>
<li> a-text-list2
</li>
</ul>
</dd>
</dl>

<dl class="winilist">
<dt> b
</dt>
<dd>
<ul class="winilist">
<li> b-text-list1
</li>
<li> b-text-list2
</li>
</ul>
</dd>
</dl>

<dl class="winilist">
<dt> c
</dt>
<dd>
<ul class="winilist">
<li> c-text-list1
</li>
<li> c-text-list2
</li>
</ul>
</dd>
<dd> c-text
<ol class="winilist">
<li> c-text-n1
</li>
<li> c-text-n2
<ol class="winilist">
<li> c-text-n2-n1
</li>
<li> c-text-n2-n2
</li>
</ol>
</li>
</ol>
</dd>
<dt> c2
</dt>
</dl>


EOC
  $p=std($p);

  is $o, $p;
}


done_testing;
