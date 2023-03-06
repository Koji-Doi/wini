use strict;
use warnings;
use utf8;

=head1 NAME

wini_addin_header.pm - The header code of add-in module for Wini.pm

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut

use Time::Piece;

package Text::Markup::Wini;
our %MACROS;
our %VARS;
our %TXT;       # messages and forms
our($MI, $MO);  # escape chars
our(@INDIR, @INFILE, $OUTFILE);
our($TEMPLATE, $TEMPLATEDIR);

=begin c
$MACROS{macroname} = sub{
  my(@p) = @_; # {{macroname|p0|p1}}
  return(qq!<span>$p[0]</span>!); # result html
};
=end c
=cut

# ADD Code for MACROS, or defition of global variables here.
$MACROS{copyright} = sub{
  my($name, $firstyear, $lastyear) = @_;
  (defined $name)      or $name = 'Anonymous';
  (defined $firstyear) or $firstyear = localtime->year; 
  (defined $lastyear)  or $lastyear  = localtime->year;
  my $period = ($firstyear eq $lastyear) ? $firstyear : "${firstyear}-${lastyear}";
  return(qq!<span>'&copy; ${period}, ${name}, All rights reserved.</span>!);
};
1;
