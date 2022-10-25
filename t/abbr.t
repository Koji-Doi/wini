#!/usr/bin/env perl

use utf8;
use strict;
use warnings;
use Test::More;
use lib '.';
use lib './t';
use t;
use Wini;

our $ENVNAME;
our @LANGS;
our $LANG;
our $QUIET;
our %MACROS;
our %VARS;
our %REF;       # dataset for each reference
our %REFASSIGN; # reference id definitions
our %TXT;       # messages and forms
our($MI, $MO);  # escape chars to 
our(@INDIR, @INFILE, $OUTFILE);
our($TEMPLATE, $TEMPLATEDIR);
our $DEBUG = (defined $ARGV[0] and $ARGV[0] eq '-d') ? 1 : 0;

binmode STDIN, ':utf8';
binmode STDERR,':utf8';
binmode STDOUT,':utf8';
Text::Markup::Wini::init();
while(<DATA>){
  /^#/ and next;
  s/[\n\r]*$//;
  my($name, $src, $expect, $opt) = split(/\t/, $_);
  (defined $name) or next;
  my($o) = Text::Markup::Wini::to_html($src);
  is1(std($o), std($expect), $name);
}

done_testing;

__DATA__
abbr1	{{@|abbr=DNA}}	<p><abbr>DNA</abbr></p>
abbr2	{{@|text=DNA}}	<p><dfn>DNA</dfn></p>
abbr3	{{@|DNA}}	<p><abbr>DNA</abbr></p>
abbr4	{{@||DNA}}	<p><dfn>DNA</dfn></p>
abbr5	{{@|abbr=DNA|text=deoxyribonucleic acid}}	<p><abbr title="deoxyribonucleic acid">DNA</abbr></p>
abbr6	{{@|abbr=DNA|text=deoxyribonucleic acid|dfn=1}}	<p><dfn><abbr title="deoxyribonucleic acid">DNA</abbr></dfn></p>
