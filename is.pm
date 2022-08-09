use strict;
use warnings;
{
my $cnt=0;
sub is1{
  my(@x) = @_;
  is $x[0], $x[1];
  foreach my $i (0..1){
    $x[$i]=~/<html>/ or  $x[$i] = whole($x[$i]);
    my $outfile = sprintf('%s_%d_%s.html', $0, $cnt, [qw/got expected/]->[$i]);
    open(my $fho, '>:utf8', $outfile);
    print {$fho} $x[$i];
    close $fho;
  }
  $cnt++;
}
}

sub whole{
  my($x) = @_;
  return(<<"EOD");
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
</head>
<body>
  $x
</body>
</html>
EOD

}

1;
