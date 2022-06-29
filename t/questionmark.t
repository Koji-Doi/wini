#!/usr/bin/env perl

package Text::Markup::Wini;
use utf8;
use strict;
use warnings;
use Test::More;

use lib '.';
use Wini;

binmode STDIN, ':utf8';
binmode STDERR,':utf8';
binmode STDOUT,':utf8';
init();

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
  my($o, undef) = to_html(<<'EOC');
{{?}} : ?

EOC
  $o=std($o);

my $p = <<EOC;

<p>
&#63; : ?
</p>


EOC
  $p=std($p);

  is $o, $p;
}


{
  my($o, undef) = to_html(<<'EOC');

{{!}} : !

EOC
  $o=std($o);

my $p = <<EOC;

<p>
&#33; : !
</p>


EOC
  $p=std($p);

  is $o, $p;
}


{
  my($o, undef) = to_html(<<'EOC');

{{?!==|abc}} : ?!==|abc

EOC
  $o=std($o);

my $p = <<EOC;

<p>
&#11800;abc&#8253; : ?!==|abc
</p>


EOC
  $p=std($p);

  is $o, $p;
}


{
  my($o, undef) = to_html(<<'EOC');

{{?!}} : ?!

EOC
  $o=std($o);

my $p = <<EOC;

<p>
&#63;&#33; : ?!
</p>


EOC
  $p=std($p);

  is $o, $p;
}


{
  my($o, undef) = to_html(<<'EOC');

{{!?}} : !?

EOC
  $o=std($o);

my $p = <<EOC;

<p>
&#33;&#63; : !?
</p>


EOC
  $p=std($p);

  is $o, $p;
}


{
  my($o, undef) = to_html(<<'EOC');

{{!^}} : !^

EOC
  $o=std($o);

my $p = <<EOC;

<p>
&#161; : !^
</p>


EOC
  $p=std($p);

  is $o, $p;
}


{
  my($o, undef) = to_html(<<'EOC');

{{?!^}} : ?!^

EOC
  $o=std($o);

my $p = <<EOC;

<p>
&#63;&#33; : ?!^
</p>


EOC
  $p=std($p);

  is $o, $p;
}


{
  my($o, undef) = to_html(<<'EOC');

{{?!=}} : ?!=

EOC
  $o=std($o);

my $p = <<EOC;

<p>
&#8264; : ?!=
</p>


EOC
  $p=std($p);

  is $o, $p;
}


{
  my($o, undef) = to_html(<<'EOC');

{{?!==}} : ?!==

EOC
  $o=std($o);

my $p = <<EOC;

<p>
&#8253; : ?!==
</p>


EOC
  $p=std($p);

  is $o, $p;
}


{
  my($o, undef) = to_html(<<'EOC');

{{!|abc}} : !|abc

EOC
  $o=std($o);

my $p = <<EOC;

<p>
&#161;abc&#33; : !|abc
</p>


EOC
  $p=std($p);

  is $o, $p;
}


{
  my($o, undef) = to_html(<<'EOC');

{{!!?|abc}} : !!?|abc

EOC
  $o=std($o);

my $p = <<EOC;

<p>
&#191;&#161;&#161;abc&#33;&#33;&#63; : !!?|abc
</p>


EOC
  $p=std($p);

  is $o, $p;
}


done_testing;
