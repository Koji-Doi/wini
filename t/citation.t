#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use File::Basename;
use File::Temp qw(tempdir);
use File::Path qw(remove_tree);
use lib '.';
use lib './t';
use Wini;
#use is;
use t;
use Data::Dumper;
our($Indir, $Outdir);
our(@Infiles, @Outfiles);
our $DEBUG=0;

if(defined $ARGV[0] and $ARGV[0] eq '-d'){
  $DEBUG=1;
}

# prepare test input files

my %indata;
my $mode="";
my $i=0;
$_=<DATA>;
while(<DATA>){
  /^#/ and next;
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
prepare($indata{mg}, $indata{html});

for(my $i=1; $i<=$#{$indata{mg}}; $i++){
  Text::Markup::Wini::init();
  my $newdir  = outdir4indir($Indir);
  my $newfile = "$newdir/$i.html";
  test_cmd($indata{tag}[$i], {i=>"$Indir/$i.mg", o=>$newfile}, $newdir, [$newfile], [$indata{html}[$i]]);
  (!$DEBUG) and remove_tree($newdir);
}
(!$DEBUG) and (-d $Indir)   and (print("remove $Indir\n"),   remove_tree($Indir));
(!$DEBUG) and (-d $Outdir)  and (print("remove $Outdir\n"),  remove_tree($Outdir));
(!$DEBUG) and map {unlink $_} <err*.log>;
done_testing;

__DATA__
"
---start mg A: {{q}}
aaa

{{q}}
abc
{{end}}

xxx
---start html A:

<p>
aaa
</p>

<blockquote cite="http://example.com">

abc

</blockquote>
<p>
xxx
</p>

---start mg B: {{q|cite}}

aaa

{{q|cite=http://example.com/}}
abc
{{end}}

xxx
---start html B:
<p>
aaa
</p>

<blockquote cite="http://example.com/">

abc

</blockquote>
<p>
xxx
</p>

---start mg C: {{pre}}
aaa

{{pre}}
abc
{{end}}

xxx
---start html C:
<p>aaa</p>

<p><pre>abc</pre></p>

<p>xxx</p>


---start mg D: {{code}}
aaa

{{code}}
abc
{{end}}

xxx
---start html D:
<p>aaa</p>

<p><pre><code>abc</code></pre></p>

<p>xxx</p>

---start mg E: %%%
aaa

%%%
abc

def
%%%

xxx
---start html E:
<p>aaa</p>

<p>abc def</p>

<p>xxx</p>

---start mg F: '''
aaa

'''
abc

def
'''

xxx
---start html F:
<p>aaa</p>
<p><pre>abc def</pre></p>
<p>xxx</p>

---start mg G: ```

aaa

```
abc

def
```

xxx
---start html G:
<p>aaa</p>
<p>
<pre><code>
abc def
</code></pre>
</p>
<p>xxx</p>

---start mg H: """ with inner %%%
aaa

"""
abc

%%%
def
%%%
"""

xxx
---start html H:
<p>aaa</p>
<blockquote cite="http://example.com">abc %%% def %%%</blockquote>
<p>xxx</p>

---start mg I: %%% with inner """
aaa

%%%

abc

"""
def
"""
%%%

xxx

---start html I:
<p>aaa</p>
<p>
abc """ def """
</p>
<p>xxx</p>

---end
