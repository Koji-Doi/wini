use strict;
use warnings;

use File::Temp qw(tempdir);
use Test::More;

our($Indir, $Outdir);
our(@Infiles, @Outfiles);
our $DEBUG;

sub prepare{
  $Indir    = tempdir('wini_in_XXXX');
  my($body) = $Indir=~/wini_in_(.*)/;
  $Outdir   = tempdir("wini_out_${body}_XXXX");

  for(my $i=0; $i<=3; $i++){
    my $infile = "${Indir}/${i}.wini";
    push(@Infiles,  $infile);
    push(@Outfiles, "$Outdir/$i.wini.html");
    open(my $fho, '>', $Infiles[$i]) or die "Cannot modify $Infiles[$i]";
    print {$fho} "$i\n";
  }
}

sub std{
  my($x, $opt)=@_;
#opt: cr==1, check returns; spc==1, check spaces;
  ($opt->{cr})  or $x=~s/[\n\r]/ /sg;
  unless($opt->{spc}){
    $x=~s/> */>/g;
    $x=~s/\s{2,}/ /g;
    $x=~s/ +</</g;
    $x=~s/> +/>/g;
  }
  #$x=~s{(</\w+>)}{$1\n}g;
  return($x);
}

sub test_cmd{
  my($testname, $cmd_opt, $outdir, $outputfiles, $output) = @_;
  my($p, $f, $l) = caller();
  my $i = 1; my @subs;
  while ( my($pack, $file, $line, $subname, $hasargs, $wantarray, $evaltext, $is_require) = caller( $i++) ){
    push(@subs, "$line\[$subname]\@$file");
  }
  my $mes = join(' <- ', @subs);
  ($DEBUG) and print STDERR "test_cmd at line $l $mes\n";
# test_cmd("test1", {i=>"$indir/0.wini", o=>"$indir/0.wini.html"}, "test_out/", ["$indir/0.wini.html"], ["<p>0</p>"]);
  my $cmd = "perl Wini.pm ";
  my @opt;
  foreach my $o (sort keys %$cmd_opt){
    if(ref $cmd_opt->{$o} eq 'ARRAY'){
      foreach my $o2 (@{$cmd_opt->{$o}}){
        push(@opt, sprintf('-%s "%s"', $o, $o2));
      }
    }else{
      $o=~/[<>]/ or push(@opt, sprintf('-%s "%s"', $o, $cmd_opt->{$o}));
    }
  }
  foreach my $o (qw/< >/){
    (defined $cmd_opt->{$o}) and push(@opt, "$o ".$cmd_opt->{$o});
  }
  $cmd .= join(' ', @opt);
  ($DEBUG) and printf STDERR "Try '$cmd' at %s:%s\n",__LINE__, __FILE__;
  #$DB::single=$DB::single=1;
  my $r = system("$cmd 2>/dev/null");
  ($r>0) and $r = $r >> 8;
  if($r>0){
    print STDERR (<<"EOD");
    Error occured in trying '$cmd'.
    Return=$r
EOD
  }
  if(defined $outputfiles){
    is join('', sort <$outdir/*.html>, <$outdir/*.css>), join('', sort @$outputfiles), "$testname: files";
    for(my $i=0; $i<=$#$outputfiles; $i++){
      if(defined $outputfiles->[$i]){
        open(my $fhi, '<:utf8', $outputfiles->[$i]) or die "Failed to open $i:$outputfiles->[$i]";
        if(defined $output->[$i]){
          my $got = join('', <$fhi>);
          is std($got), std($output->[$i]), "$testname: output text";
        }
      }
    }
  }
}

__PACKAGE__->try_this() if !caller() || caller() eq 'PAR';

sub try_this{
  prepare();
  test_cmd("test1", {i=>$Infiles[0], o=>$Outfiles[0]}, $Outdir, [$Outfiles[0]], ["<p>0</p>"]);
  test_cmd('-i -i > -o', {i=>[$Infiles[0], $Infiles[1]], o=>$Outfiles[0]}, $Outdir, [$Outfiles[0]]);

  done_testing;
}
1;
