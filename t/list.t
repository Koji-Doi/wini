#!/usr/bin/env perl

#package Text::Markup::Wini;
use strict;
use warnings;
use Test::More;

use lib '.';
use Wini;
use lib './t';
use t;

Text::Markup::Wini::init();

=begin c
sub std{
  my($x)=@_;
  $x=~s/[\n\r]*//g;
  $x=~s/> */>/g;
  $x=~s/\s{2,}//g;
  $x=~s/ +</</g;
  $x=~s/> +/>/g;
  return($x);
}

=end c

=cut

my %indata;
my $mode="";
my $i=0;
$_=<DATA>;
while(<DATA>){
  if(/^---start mg(?:\s*(.*))?$/){
    $i++;
    my $x=$1;
    $mode='mg';
    $x=~s/[\n\r]*$//;
    $indata{tag}[$i]=$x;
    next;
  } 
  /^---start html/ and ($mode='html', next);
  /^---start log/  and ($mode='log', next);
  /^---end/ and last;
  $indata{$mode}[$i] .= $_;
}

#Text::Markup::Wini::init();

for(my $test_no=1; $test_no<=$#{$indata{mg}}; $test_no++){
  test1($indata{tag}[$test_no], $indata{mg}[$test_no], $indata{html}[$test_no]);
}
done_testing;

__DATA__
"
---start mg A: non-ordered
* a
* b
---start html A:
<ul class="mglist">
<li> a
</li>
<li> b
</li>
</ul>

---start mg B: ordered
# a
# b
---start html B:
<ol class="mglist">
<li> a
</li>
<li> b
</li>
</ol>

---start mg C: simple description list
; a
: a-text
---start html C:
<dl class="mglist">
<dt> a
</dt>
<dd> a-text
</dd>
</dl>

---start mg D: nested description list
; a
: a-text
:; a-text term
:: a-text desc
---start html D:
<dl class="mglist">
<dt> a
</dt>
<dd> a-text
 <dl class="mglist">
 <dt>a-text term</dt>
 <dd>a-text desc</dd>
 </dl>
</dd>
</dl>

---start mg E: description list with nested non-ordered list
; a
: a-text
:* a-text-list1
:* a-text-list2
---start html E:
<dl class="mglist">
<dt> a
</dt>
<dd> a-text
<ul class="mglist">
<li> a-text-list1
</li>
<li> a-text-list2
</li>
</ul>
</dd>
</dl>

---start mg F: description list complex
; c
:* c-text-list1
:* c-text-list2
: c-text
:# c-text-n1
:# c-text-n2
:## c-text-n2-n1
:## c-text-n2-n2
; c2
---start html F:
<dl class="mglist">
<dt> c
</dt>
<dd>
<ul class="mglist">
<li> c-text-list1
</li>
<li> c-text-list2
</li>
</ul>
</dd>
<dd> c-text
<ol class="mglist">
<li> c-text-n1
</li>
<li> c-text-n2
<ol class="mglist">
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

---start mg G: nesded description list under ordered list
# a
# b
# c

#; 1 list1title
#: 1 list1desc
#; 1 list2title
#: 1 list2desc

#;  2 list1title
#:  2 list1desc
#;- 2 list2title
#:  2 list2desc
---start html G:
<ol class="mglist">
<li>a
</li>
<li>b
</li>
<li>c
</li>
</ol>


<ol class="mglist">
<li><dl class="mglist">
<dt>1 list1title
</dt>
<dd>1 list1desc
</dd>
<dt>1 list2title
</dt>
<dd>1 list2desc
</dd>
</dl>
</li>
</ol>


<ol class="mglist">
<li><dl class="mglist">
<dt>2 list1title
</dt>
<dd>2 list1desc
</dd>
</dl>
</li>
<li><dl class="mglist">
<dt>2 list2title
</dt>
<dd>2 list2desc
</dd>
</dl>
</li>
</ol>

---end
