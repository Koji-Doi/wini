use strict;
use warnings;

package Text::Markup::Wini;
our %MACROS;
#$WINI::VAR{bs4}="bs4test";
$MACROS{txtpri} = sub{
  my(@p) = @_;
  return(qq!<span class="text-primary">$p[0]</span>!);
#  my($x) = wini("{{b|$p[0]}}");
};
$MACROS{box} = sub{
  my (@p) = @_;
  my($maintxt, $topimage, $title, $header, $footer) = ($#p==0)?($p[0], '', '', '', '') : (map {$p[$_]} qw/3 0 1 2 4/);
  my @classes;
  map {$_ and push(@classes, $_)} split(/\s+/, $p[5]);
  my $r = bs4card($topimage, $title, $header, $maintxt, $footer, @classes);
  return("$r\n");
};

sub bs4card{
#  {
#    my $i = 0; my @subs;
#my ($pack, $file, $line, $subname, $hasargs, $wantarray, $evaltext, $is_require) ;
#    while ( ($pack, $file, $line, $subname, $hasargs, $wantarray, $evaltext, $is_require) = caller( $i++) ){push(@subs, "$line\[$subname]")}
#    print STDERR "****CALLER**** ", join(' <- ', @subs), "\n";
#  }

  my($topimage, $title, $header, $maintext, $footer, @classes) = @_;
  $topimage = $topimage || '';
  $title    = $title    || '';
  $header   = $header   || '';
  $maintext = $maintext || '';
  $footer   = $footer   || '';
  $classes[0] or @classes = qw(border border-black bg-light col-md-6 col-sm-12);
  my @classes_col = grep { /^(col-|h-)/} @classes;
  my @classes1    = grep {!/^(col-|h-)/} @classes;
  my $classlist = ($classes1[0]) ? ' '.join(' ', @classes1) : '';
  my $res =  ($classes_col[0]) ? sprintf('<div class="%s">', join(' ', @classes_col)) : '';
     $res .= qq!<div class="card${classlist}">!;
  $topimage and $res .= qq!<div class="">${topimage}</div>!;
  $res .= '<div class="card-body">'."\n";
  $header   and $res .= qq! <h4 class="card-header">${header}</h4>\n!;
  $title    and $res .= qq! <div class="card-title">${title}</div>\n!;
  $maintext and $res .= qq! <div class="card-text">${maintext}</div>\n!;
  $footer   and $res .= qq! <div class="card-footer">${footer}</div>\n!;
  $res .= "</div>\n</div>\n</div>\n";
  return($res || '');
}

1;

=begin c
<div class="card text-white bg-secondary mb-3" style="max-width: 18rem;">
  <div class="card-header">Header</div>
  <div class="card-body">
    <h5 class="card-title">Secondary card title</h5>
    <p class="card-text">Some quick example text to build on the card title and make up the bulk of the card's content.</p>
  </div>
</div>
=end c
=cut
