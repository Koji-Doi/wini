use strict;
use warnings;

use Cwd;
use File::Temp qw(tempdir);
use File::Basename;
use Test::More;
use lib '.';
use Wini;

our($Indir, $Outdir);
our(@Infiles, @Outfiles);
our $DEBUG;

sub save_obj_to_file{
  my($x, $outfile) = @_;
  open(my $fho, '>:utf8', $outfile) or die "Failed to save $outfile.";
  print {$fho} "$x\n";
  close $fho;
  ($DEBUG) and print STDERR "##### saved $outfile.\n";
}

sub outdir4indir{
  my($indir) = @_;
  my($body) = $indir=~/(?:wini_in_)?(\w+$)/;
  return(tempdir("wini_out_${body}_XXXX"));
}

sub prepare{
  my($indata, $outdata) = @_; 
  # $indata:  array def containing input mg data
  # $outdata: array def containing output html data
  $Indir    = tempdir('wini_in_XXXX');
  $Outdir   = outdir4indir($Indir);

  if(defined $indata){
    for(my $i=1; $i<=$#$indata; $i++){
      open(my $fho, '>:utf8', "$Indir/$i.mg") or die "Failed to create $Indir/$i.mg";
      print {$fho} $indata->[$i];
      close $fho;
    }
  }
  if(defined $outdata){
    for(my $i=1; $i<=$#$outdata; $i++){
      open(my $fho, '>:utf8', "$Outdir/$i.html") or die "Failed to create $Outdir/$i.html";
      print {$fho} $outdata->[$i];
      close $fho;
    }
  }

  unless(defined $indata and defined $outdata){ # just generate simple input files
    for(my $i=0; $i<=3; $i++){
      my $infile = "${Indir}/${i}.wini";
      push(@Infiles,  $infile);
      push(@Outfiles, "$Outdir/$i.wini.html");
      open(my $fho, '>', $Infiles[$i]) or die "Cannot modify $Infiles[$i]";
      print {$fho} "$i\n";
      close $fho;
    }
  }
} # sub prepare

sub std{
  my($x, $opt)=@_;
#opt: cr==1, check returns;
#     cr==0, ignore returns;
#    spc==1, check spaces;
#    spc==0, ignore spaces;

  $x=~s{(wini_(?:test)?(?:in|out)_)(\w+)}{$1}g; # remove tempdir names
  $x=~s{((\e\[)?\S* at line.*)}{}g; # remove warning/error messages
  if(defined $opt->{cr}){
    ($opt->{cr}==0) and $x=~s/[\n\r]//sg;
    #($opt->{cr}==1) and 
  }else{
    $x=~s/[\n\r]/ /sg;
  }
  if(defined $opt->{spc}){
    ($opt->{spc}==0) and $x=~s/\s//g;
    #($opt->{spc}==1) and
  }else{
    $x=~s/> */>/g;
    $x=~s/\s{2,}/ /g;
    $x=~s/ +</</g;
    $x=~s/> +/>/g;
  }
  #$x=~s{(</\w+>)}{$1\n}g;
  return($x);
}

sub whole_html1{
  my($x) = @_;
  return(<<"EOD");
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<title>test</title>
</head>
<body>
  $x
</body>
</html>
EOD

}


{
my $cnt=1;
sub is1{
  my(@x) = @_;
  my $title = (defined $x[2]) ? $x[2] : "test${cnt}";
  no warnings;
  $title=~s/\s*$//;
  is $x[0], $x[1], $title;
  use warnings;
  if($DEBUG){
    my $filename = basename($0, qw/.t .pl .pm/) . "_${cnt}_";
    print STDERR "\n";
    foreach my $i (0..1){
      $x[$i]=~/<html>/ or  $x[$i] = whole_html1($x[$i]);
      my $outfile = sprintf('%s%s.html', $filename, [qw/got exp/]->[$i]);
      open(my $fho, '>:utf8', $outfile);
      print STDERR "##### saved $outfile.\n";
      print {$fho} $x[$i];
      close $fho;
    }
  }
  $cnt++;
}

sub test1{
  my($testname, $src, $expect, $to_html_opt) = @_;
  Text::Markup::Wini::init();
  my($o0) = Text::Markup::Wini::to_html($src, $to_html_opt);

  no warnings;
  my($o) = std($o0);
  my($p) = std($expect);
  if($DEBUG){
    my $file = basename($0, qw/.t .pl .pm/) . "_${cnt}.wini";
    print STDERR "\n";
    save_obj_to_file($src,    $file);
    save_obj_to_file($expect, "${file}.exp.html");
    save_obj_to_file($o0,     "${file}.got.html");
  }  
  is $o, $p, $testname;
  $cnt++;
  use warnings;
}

sub test_cmd{
  my($testname, $cmd_opt, $outdir, $outputfiles, $output) = @_;
  my($p, $f, $l) = caller();
  my $depth = 1; my @subs;
  while ( my($pack, $file, $line, $subname, $hasargs, $wantarray, $evaltext, $is_require) = caller( $depth++) ){
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
        $o2=~s/\{\{err}}/"err${cnt}.log"/ge;
        push(@opt, sprintf('-%s "%s"', $o, $o2));
      }
    }elsif(not defined $cmd_opt->{$o}){
      push(@opt, "-$o ");
    }else{
      my $o2 = $cmd_opt->{$o};
      $o2=~s/\{\{err}}/"err${cnt}.log"/ge;
      $o=~/[<>]/ or push(@opt, sprintf('-%s "%s"', $o, $o2));
    }
  }

  (exists $cmd_opt->{'2>'}) or $cmd_opt->{'2>'}="/dev/null";
  foreach my $o (qw/< > 2>/){
    (defined $cmd_opt->{$o}) or next;
    $cmd_opt->{$o}=~s/\{\{err}}/"err${cnt}.log"/ge;
    push(@opt, "$o ".$cmd_opt->{$o});
  }
  $cmd .= join(' ', @opt);
  ($DEBUG) and printf STDERR "Try '$cmd' at %s:%s\n",__LINE__, __FILE__;
#  $DB::single=$DB::single=1;
#  my $r = system("$cmd 2>/dev/null");
  my $r = system($cmd);
  ($r>0) and $r = $r >> 8;
  if($r>0){
    ($DEBUG) and print STDERR (<<"EOD");
    Error occured in trying '$cmd'.
    Return=$r
EOD
  }
  if(defined $outputfiles){
    is join(' ', sort <$outdir/*.html>, <$outdir/*.css>, <$outdir/*.log>), join(' ', sort @$outputfiles), "$testname: files";
    for(my $i=0; $i<=$#$outputfiles; $i++){
      if(defined $outputfiles->[$i]){
        open(my $fhi, '<:utf8', $outputfiles->[$i]) or print STDERR "Failed to open $i:$outputfiles->[$i]", next;
        if(defined $output->[$i]){
          my $got = join(' ', <$fhi>);
          is std($got), std($output->[$i]), "$testname: output text ($i) ".$outputfiles->[$i];
          if($DEBUG){
            my $filename = basename($0, qw/.html/) . "_${cnt}_";
            print STDERR "> $filename\n";
            open(my $fho, '>:utf8', $filename."got.html");
            print {$fho} "$got\n";
            close $fho;
            open($fho, '>:utf8', $filename."exp.html");
            print {$fho} $output->[$i]."\n";
            close $fho;
          } # DEBUG
        } # defined $output->[$i]
      } # defined $outputfiles->[$i]
    } # for $outputfiles
  } # defined $outputfiles
  $cnt++;
} # sub test_cmd
}

__PACKAGE__->try_this() if !caller() || caller() eq 'PAR';

sub try_this{
  prepare();
  test_cmd("test1", {i=>$Infiles[0], o=>$Outfiles[0]}, $Outdir, [$Outfiles[0]], ["<p>0</p>"]);
  #test_cmd('-i -i > -o', {i=>[$Infiles[0], $Infiles[1]], o=>$Outfiles[0]}, $Outdir, [$Outfiles[0]]);

  test1('test2', 'abc', '<p>abc</p>');
  done_testing;
}
1;
