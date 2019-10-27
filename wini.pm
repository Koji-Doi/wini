#!/usr/bin/env perl
=head1 NAME

wini.pm - WIKI markup ni NIta nanika (Japanese: "Something like wiki markup")

=head1 SYNOPSIS

 use wini;
 my $htmltext = wini(<<'EOT');
 ! Large heading
 !! Middle heading
 !!! Small heading

 * list item 1
 ** nested list item 1-1
 ** nested list item 1-2
 * list item 2
 * list item 3

 # numbered list item 1
 # numbered list item 2

 Paragraphs should be separated by null line, like wiki or markdown. Line breaks in plain text are ignored. 
 Thus this is not a first sentence of the second paragraph, but the second sentence of the first paragraph.

 This is the second paragraph.

 Tables can be represented easily as follows.

 |!!~~3__2  Game | Players |-    |-    |
 |!!~~2__3^      |       A |   B |   C |
 |             1 |       1 |@  5 |   3 |
 |             2 |       4 |   5 |@ 10 |
 |==3!!!   Total |       5 |  10 |@ 13 |

 EOT

 open(my $fho, '>:utf8', 'output.html') or die;
 print {$fho} $htmltext;
 close $fho;

=head1 DESCRIPTION

The script file wini.pm is a perl module supporting WINI markup, which is a simple markup language to build HTML5 texts. This script can also be used as a stand-alone perl script. Users easily can get HTML5 documents from WINI source texts, by using wini.pm as a filter command.

The text presented here is just a brief description.

Please refer to the synopsis of this page to grasp ontline about WINI markup. 

Please refer to the homepage for details. 

=head2 As module

Put this script file in the directory listed in @INC. If you are not clear about what @INC is, please try 'perldoc perlvar'.
Add 'use wini;' in the begining of your script to use functions of wini.pm.  

=head2 As stand-alone script

Put this script file in the directory listed in your PATH. The script file name can be renamed as 'wini' instead of 'wini.pm'. Do 'chmod a+x wini.pm'. It might be required to do 'hash' ('rehash' in zsh) to make your shell recognize wini.pm as a valid command name.

If you succeed the install, you can use this script as follows:

 $ wini.pm < input.wini > output.html

See section 'Options' to find out detail about advanced usage.

=head2 WINI, a simple but useful markup language

WINI stands for "WIki ni NIta nanika", which means "something like wiki" in Japanese. As suggested from this naming, WINI is designed with reference to wiki mark up.

Strong points of WINI include:

=over 4

=item * B<Easiness to learn:>     WINI grammar is similar to that of wiki markup. The grammer is very simple. Not only persons with experience of wiki typesetting, but everyone can find out usage easily.

=item * B<HTML5 compartibility:>  WINI is designed with a strong emphasis on affinity with HTML5 and easiness of complex HTML table construction.  WINI is a useful system to produce modern and valid HTML5 texts quickly.

=back

Today many people try to build and maintain blogs, wikipedia-like sites, etc. They produce or update a huge number of such pages daily within a time limit. For SEO, outputs should follow the valid html5 grammer. Complex data should be presented in complex HTML tables. Average writers must have a hard time to fulfill such requirements. WINI must be one of the best partners for all those people!

=head1 Options

=over 4

=item * -i INPUT    set input file name to INPUT. If the file named INPUT does not exists, wini.pm try to search INPUT.wini. If -i is not set, wini.pm takes data from standard input.

=item * -o OUTPUT   set output file name. If both -o and -i are omitted, wini.pm output data to standard output.
If -o is omitted and the input file name is 'input.wini', the output file will be 'input.wini.html'.
Users can specify the output directory rather than the file. If -o value ends with 'output/', output file will be output/input.wini.html. if 'output/' does not exist, wini.pm will create it.

=item * --whole     add HTML5 headar and footer to output. The result output will be a complete HTML5 document.

=item * --help      show this help.

=back

=cut

use strict;
use Data::Dumper;
use File::Basename;
use FindBin;
use Pod::Usage;
use Getopt::Long;

my $scriptname = basename($0);
my @save;

if ($scriptname eq 'wini.pm' or $scriptname eq 'wini'){
  my($input, $output, $fhi, $fho, $test, $whole);
  GetOptions(
    "h|help" => sub {help()},
    "i=s"    => \$input,
    "o=s"    => \$output,
    "t"      => \$test,
    "whole"  => \$whole
  );
  ($test) and ($input, $output)=("test.wini", "test.html");
  if ($input) {
    unless(open($fhi, '<:utf8', $input)){
      print STDERR "Not accessible: $input\n";
      $input = "$input.wini";
      print STDERR "Will try to open: $input\n";
      open($fhi, '<utf8:', $input) or die "Not accessible either: $input";
    }
  } else {
    $fhi = *STDIN;
  }
  unless($output){
    if ($input) {
      $output = "$input.html";
      print STDERR "Will try to create $output\n";
      open($fho, '>:utf8', $output) or die "Cannot open file: $output";
    } else {
      $fho = *STDOUT;
    }
  } else {
    if (-d $output) {
      $output = "$output/$input.html";
    } elsif (substr($output, -1) eq '/') {
      print STDERR "Will try to create directory: $output\n";
      mkdir($output) or die "Cannot create directory: $output";
      $output = "$output/$input.html";
    }
    print STDERR "Will try to create file: $output\n";
    open($fho, '>:utf8', $output) or die "Cannot create file: $output";
  }
  my @input = <$fhi>;
  print {$fho} wini(join('', @input), {whole=>$whole});
}

sub help{
  print pod2usage(-verbose => 2, -input => $FindBin::Bin . "/" . $FindBin::Script);
  exit();
}


sub close_listtag{
  my($ref, $l) = @_;
  map{
    $$ref .= (' ' x ($#$l-$_)) . (($l->[$_] eq 'ul')?'</ul>':($l->[$_] eq 'ol')?'</ol>':'</dl>') . "\n";
  } 0..$#$l;
}

sub wini{
# wini($tagettext, {para=>'br', 'is_bs4'=>1, baseurl=>'http://example.com', nocr=>1});
  # para: paragraph mode (br:set <br>, p: set <p>, nb: no separation
  # nocr: whether CRs are conserved in result text. 0(default): conserved, 1: not conserved
  my($t0, $opt)         = @_;
  my $cr                = (defined $opt->{nocr} and $opt->{nocr}==1)
                          ?"\t":"\n"; # option to inhibit CR insertion (in table)
  my($baseurl, $is_bs4) = ($opt->{baseurl}, $opt->{is_bs4});
  my $para              = 'p'; # p or br or none
  (defined $opt->{para}) and $para = $opt->{para};

  $t0 =~ s/{{l}}/&#x7b;/g;   # {
  $t0 =~ s/{{bar}}/&#x7c;/g; # |
  $t0 =~ s/{{r}}/&#x7d;/g;   # }

  # pre, code, citation, ...
  $t0 =~ s/{{(pre|code|q(?: [^|]+)?)\|(.*?)}}/&save($1,$2)/esmg;  

  # conv table to html
  $t0 =~ s/(^\s*\|.*?)[\n\r]+(?!\|)/make_table($1)/esmg;

  my $r;
  my @localclass = ('wini');
  ($is_bs4) and push(@localclass, "col-sm-12");
  my $myclass = ' class="'.join(' ',@localclass).'"';
  foreach my $t (split(/\n{2,}/, $t0)){ # for each paragraph
    my $lastlistdepth=0;
    my $ptype; # type of each paragraph (list, header, normal paragraph, etc.)
    while(1){ # loop while subst needed
      if(my($x,$cont) = $t=~/^(!+)\s*(.*)$/m){ # !!!...
        my $tag0 = length($x)+2; ($tag0>5) and $tag0="5";
        $t=~s#^(!+)\s*(.*)$#<h${tag0}${myclass}>$2</h${tag0}>#m;
        $ptype = 'header';
      }
      (
        $t =~ s!{{([IBUS])\|([^{}]*?)}}!{my $x=lc $1; "<$x>$2</$x>"}!esg or
        $t =~ s!{{i\|([^{}]*?)}}!<span style="font-style:italic;">$1</span>!g or
        $t =~ s!{{b\|([^{}]*?)}}!<span style="font-weight:bold;">$1</span>!g or
        $t =~ s!{{u\|([^{}]*?)}}!<span style="border-bottom: solid 1px;">$1</span>!g or
        $t =~ s!{{s\|([^{}]*?)}}!<span style="text-decoration: line-through;">$1</span>!g or
        $t =~ s!{{([-_/*]+[-_/* ]*)\|([^{}]*?)}}!xtags($1,$2)!eg or
        $t =~ s!\[(.*?)\]!make_a($1, $baseurl)!eg
      ) or last; # no subst need, then escape inner loop
    } # loop while subst needed
    my $t2='';

    # for list items
    my $listtagc;
    my @is_dl; # $is_dl[1]: whether list type of depth 1 is 'dl'
    my @listtagc;
    foreach my $l (split("\n", $t)){
      my($x, $listtype, $txt) = $l=~/^\s*([#*:;]*)([#*:;])\s*(.*)$/; # whether list item
      if($listtype ne ''){
        $ptype = 'list';
        my $listdepth = length($x)+length($listtype);
        ($listtype eq ';') and $is_dl[$listdepth]='dl';
        my($itemtag, $listtag) = ($listtype eq '*') ? qw/li ul/
                               : ($listtype eq ':') ? (($is_dl[$listdepth] eq 'dl')?qw/dd dl/:(qq{li style="list-style:none"}, 'ul'))
                               : ($listtype eq ';') ? qw/dt dl/ : qw/li ol/;
        my $itemtagc = $itemtag; # closing tag for list item
           $listtagc = $listtag; # closing tag for list
        $itemtagc =~ s/ .*//;
        $listtagc =~ s/ .*//;
        $listtagc[$listdepth] = $listtagc;
        # new list start?
        if($listdepth>$lastlistdepth){
          $t2 .= sprintf(qq!%*s<$listtag class="winilist">$cr!, $listdepth, ' ');
        }
        # new list end?
        for(my $i = $lastlistdepth-$listdepth; $i>0; $i--){
          $t2 .= sprintf("%*s</%s>$cr", $i+$listdepth, ' ', $listtagc[$i+$listdepth]);
        }
        $t2 .= sprintf("%*s<$itemtag>$txt</$itemtagc>$cr",$listdepth+1,' ');
        $lastlistdepth = $listdepth;
      }else{ # if not list item
        $t2 .= "$l\n";
      }
    } # $l
    if($lastlistdepth>0){
      $t2 .= sprintf("%*s", $lastlistdepth-1, ' ') . ("</$listtagc>" x $lastlistdepth) . $cr;
      $lastlistdepth=0;
    }

    $r .= ($ptype eq 'header' or $ptype eq 'list') ? "$t2\n"
        : ($para eq 'br')                          ? "$t2<br>$cr"
        : ($para eq 'nb')                          ? $t2
        : $t2=~/<(?:p|table|[uod]l)[^>]*>/         ? $t2
                                                   : "<p${myclass}>\n$t2</p>$cr$cr";
  } # foreach $t

  $r=~s/\x00i=(\d+)\x01/$save[$1]/ge;
  (defined $opt->{whole}) and
    $r = <<"EOD";
<!DOCTYPE html>
<html lang="ja">
 <head>
 <meta charset="UTF-8">
 <style>
  table.winitable td, table.winitable th  {border: 1px black solid}
  table.winitable                         {border-collapse: collapse; border: 2px black solid;}
  ol, ul, dl                              {padding-left: 1em}
  .b-r                                    {background-color: red;}
  .b-g                                    {background-color: green;}
  .b-b                                    {background-color: black;}
  .b-w                                    {background-color: white;}
  .b-b50                                  {background-color: #888;}
  .b-m                                    {background-color: magenta;}
  .b-p                                    {background-color: purple;}
  .f-r                                    {color: red;}
  .f-g                                    {color: green;}
  .f-b                                    {color: black;}
  .f-w                                    {color: white;}
  .f-b50                                  {color: #888;}
  .f-m                                    {color: magenta;}
  .f-p                                    {color: purple;}
  .a-l                                    {text-align: left;}
  .a-r                                    {text-align: right;}
  .a-c                                    {text-align: center;}
 </style>
 <title>WINI test page</title>
 </head>
 <body>
$r
 </body>
</html>
EOD
  return($r);
}

sub xtags{
  # {{/*_-|text}}
  my($tag0, $text)=@_;
  my @styles;
  my $r;
  my $strong=0;
  while($tag0=~/(\*+)/g){
    (length($1)>1) ? $strong++ : push(@styles, 'font-weight:bold;');
  }
  ($tag0=~/_/)  and push(@styles, 'border-bottom: solid 1px;');
  ($tag0=~/-/)  and push(@styles, 'text-decoration: line-through;');
  ($tag0=~m{/}) and push(@styles, 'font-style:italic;');
  $r = (scalar @styles > 0)?'<span style="' . join(' ', @styles) . qq{">$text</span>} : $text;
  ($strong) and $r = '<strong>'x$strong . $r . '</strong>'x$strong;
  return($r);
}

sub readpars{
  my($p, @list)=@_;
  my %pars; my @pars;
  foreach my $x (split(/\|/, $p)){
    if(my($k,$v) = $x=~/(\w+)\s*=\s*(.*)\s*/){
      $pars{$k}=$v;
    }else{
      push(@pars, $x);
    }
  }
  foreach my $k (@list){
    if(exists $pars{$k}){
      
    }else{
      my $x = shift(@pars);
      $pars{$k}=$x;
    }
  }
  return(\%pars);
}

sub escape{
  ($_)=@_;
  ($_) or return('');
  s/&/&amp;/g;
  s/</&lt;/g;
  s/>/&gt;/g;
  return($_);
}

{
my $i=-1;
sub save{ # pre, code, cite ...
  my($cmd, $txt) = @_;
  $i++;
  $save[$i] = $txt;
  $cmd = lc $cmd;
  if($cmd eq 'def'){
    return('');
  }elsif($cmd=~/^q/){
    my(@opts) = $cmd=~/(\w+=\S+)/g;
    my %opts;
    foreach my $o (@opts){
      my($k,$v) = $o=~/(.*?)=(.*)/;
      $opts{$k} = $v;
    }
    ($opts{cite}) or $opts{cite} = 'http://example.com';
    return(<<"EOD");
<blockquote cite="$opts{cite}">
\x00i=$i\x01
</blockquote>
EOD
  }else{
    my($ltag, $rtag) = ($cmd eq 'code')?('<pre><code>','</code></pre>')
                                       :('<pre>',      '</pre>');
    return("$ltag\n\x00i=$i\x01\n$rtag");
  }
}
}


# [[label|type|ja_name|en_name|ja_desc|en_desc|maxlen|minlen|maxval|minval|regexp|ncol|nrow]]
sub readblank{
  my($indata)=@_; # '[[a|b|c]]'
  ($indata)=$indata=~/(?:\[\[)?([^]]*)(?:\]\])?/;
  my $x = readpars($indata, qw/label type ja_name en_name ja_desc en_desc maxlen minlen maxval minval regexp ncol nrow/);
  return($x);
}

# [xxxx] -> <a href="www">...</a>
sub make_a{
  my($t, $baseurl)=@_;
  my($a, $b)               = $t=~/\s*([!#]*".*?")\s+(.*)/;
  (defined $a) or ($a, $b) = $t=~/(\S*)(?:\s+(.*))?/;
  $a=~s/"//g;
  $b = escape($b);
  my $href;
  if($a =~ m!https?://!){
    $href = $a;
  }elsif($a =~ /^[\d_]+$/){
    $href = "$baseurl?aid=$a";
  }elsif(my($img) = $a=~/^!(.*)/){
    return(qq!<img src="$img" alt="$b">!);
  }else{
    $href = $a;
  }
  ($b eq '') and $b=$a;
  return(qq!<a href="$href">$b</a>!);
}

sub make_table{
  my($in)=@_;
  my $ln=0;
  my @winiitem;
  my @htmlitem;
  foreach my $line (split(/\n/, $in)){
    $line=~s/[\n\r]*//g;
    ($line eq '') and next;
    $ln++;
    my @cols = split(/( *\|\S*)/, $line); # $cols[0] is always undef. so delete.
    # standardize
    $cols[-1]=~/^\s+$/  and delete $cols[-1];
    $cols[-1]!~/^\s*\|/ and push(@cols, '|');
    for (my $cn=1; $cn<$#cols; $cn++){
      $cols[$cn]=~s/^\s*//;
      $cols[$cn]=~s/\s*$//;
      $winiitem[$ln][$cn] = $cols[$cn];
    }
  }
  
  for($ln=$#winiitem; $ln>=1; $ln--){
    if($winiitem[$ln][1]=~/\^\^/ and $ln>1){ # row merge
      for(my $i=2; $i<=$#{$winiitem[$ln]}; $i+=2){
        $winiitem[$ln-1][$i] .= "\n".$winiitem[$ln][$i]; # copy to upper winiitem
        $htmlitem[$ln][0] = $winiitem[$ln][0] = '^^';
      }
      next;
    }
    my $colspan=0;
    my $val='';
    for(my $cn=$#{$winiitem[$ln]}; $cn>=0; $cn--){
      my $col   = $winiitem[$ln][$cn];
      my $col_n = $cn/2+1;
      if($cn%2==1){ # border
        $col = substr($col,1); # remove the first '|'
        #$ctag = ($col=~/\bh\b/)?'th':'td';
        $htmlitem[$ln][$col_n]{ctag} = 'td';
        $col=~s/\.\.\.\.([^.]+)/unshift(@{$htmlitem[  0][     0]{copt}{class}}, $1), ''/eg;
        $col=~s/\.\.\.([^.]+)/  unshift(@{$htmlitem[  0][$col_n]{copt}{class}}, $1), ''/eg;
        $col=~s/\.\.([^.]+)/    unshift(@{$htmlitem[$ln][     0]{copt}{class}}, $1), ''/eg;
        $col=~s/\.([^.]+)/      unshift(@{$htmlitem[$ln][$col_n]{copt}{class}}, $1), ''/eg;
        while($col=~/(?<!!)(!+)(?!!)/g){
          my $h=$1;
          if(length($h) == 1){ # cell
            $htmlitem[$ln][$col_n]{ctag} = 'th';
          }elsif(length($h) == 2){ # row
            $htmlitem[$ln][0]{ctag} = 'th';
          }elsif(length($h) == 3){ #col
            $htmlitem[0][$col_n]{ctag} = 'th';            
          }
        }

        if($col=~/-/){ # colspan
          $colspan++;
          $winiitem[$ln][$cn-1]   .= "\n" . $winiitem[$ln][$cn+1];
          if(defined $htmlitem[$ln][$col_n]{copt}{colspan}){
            $htmlitem[$ln][$col_n-1]{copt}{colspan} = $htmlitem[$ln][$col_n]{copt}{colspan}+1;
          }else{
            $htmlitem[$ln][$col_n-1]{copt}{colspan} = 2;
          }
          $htmlitem[$ln][$col_n]{copt}{colspan}   = -1;
          next;
        }elsif($colspan>0){
          $colspan=0;
        }

        if($col=~/\^/){ # rowspan
          $winiitem[$ln-1][$cn+1] .= "\n" . $winiitem[$ln][$cn+1]; # merge data block to upper row 
          (defined $htmlitem[$ln][$col_n]{copt}{rowspan}) or $htmlitem[$ln][$col_n]{copt}{rowspan} = 1;
          $htmlitem[$ln-1][$col_n]{copt}{rowspan} = $htmlitem[$ln][$col_n]{copt}{rowspan}+1;
          next;
        }

        while($col=~/(([][_~=@|])(?:\2*))(\d*)/g){ # border setting
          my($m, $btype, $n) = (length($1), $2, sprintf("solid %dpx",($3 ne '')?$3:1));
          my %btype;
print STDERR ">>> $col: $m $btype $n\n";
          ($btype=~/[[@|]/) and $btype{left}   = $n;
          ($btype=~/[]@|]/) and $btype{right}  = $n;
          ($btype=~/[~@=]/) and $btype{top}    = $n;
          ($btype=~/[_@=]/) and $btype{bottom} = $n;
          foreach my $k (keys %btype){
            my($r,$c) = ($m==4)?(  0, 0)       # for whole table
                       :($m==3)?(  0, $col_n)  # for all cells in the target col
                       :($m==2)?($ln, 0)       # for all cells in the target row
                       :        ($ln, $col_n); # for target cell
            push(@{$htmlitem[$r][$c]{copt}{style}}, sprintf("border-$k: %s;", $btype{$k}));
          }
        } # while border

        $htmlitem[$ln][$col_n]{val}  = $val;
      }else{ # value
        $val = $col;
      }
    } # $cn

    for(my $i=1; $i<=$#{$htmlitem[$ln]}; $i++){ # set winified text to cells
      (defined $htmlitem[$ln][$i]) or next;
      my $cell = $htmlitem[$ln][$i];
      $cell->{wini} = wini($cell->{val}, {para=>'nb', nocr=>1});
      $cell->{wini} =~ s/\t *//g;
      $cell->{wini} =~ s/[ \n]+/ /g;
      $htmlitem[$ln][$i] = $cell; # $htmlitem[$ln][0]: data for row (tr)
    }
  } # for $ln
  for(my $i=1; $i<=$#{$htmlitem[1]}; $i++){ # set colclass to cells
    map {
      (defined $htmlitem[0][$i]{copt}{class}) and push(@{$htmlitem[$_][$i]{copt}{class}}, @{$htmlitem[0][$i]{copt}{class}}) 
    }1..$#htmlitem;
  }

  my $outtxt = qq!<table class="winitable"!;
  (defined $htmlitem[0][0]{copt}{style}[0]) and $outtxt .= q{ style="} . join(' ', @{$htmlitem[0][0]{copt}{style}}) .'"' ;
  $outtxt .= ">\n";
  for(my $rn=1; $rn<=$#htmlitem; $rn++){
    ($htmlitem[$rn][0] eq '^^') and next;

    $outtxt .= '<tr' .
      join('', map{ qq! $_="! . join(' ', @{$htmlitem[$rn][0]{copt}{$_}}) . '"' } (keys %{$htmlitem[$rn][0]{copt}}));
    #foreach my $k (keys %{$htmlitem[$rn][0]{copt}}){
    #  $htmlitemtxt .= qq{ $k="} . join(' ', @{$htmlitem[$rn][0]{copt}{$k}}) . qq{"};
    #}
    $outtxt .= '>';
    $outtxt .= join("", 
      map { # for each cell ($_: col No.)
        if((defined $htmlitem[$rn][$_]{copt}{rowspan} and $htmlitem[$rn][$_]{copt}{rowspan}<=1) or (defined $htmlitem[$rn][$_]{copt}{colspan} and $htmlitem[$rn][$_]{copt}{colspan}<=1)){
          '';
        }else{
          my $copt = '';
          foreach my $c (qw/class colspan rowspan style/){
            (defined $htmlitem[$rn][$_]{copt}{$c}) and
              $copt .= sprintf(qq{ $c="%s"},
                         (ref $htmlitem[$rn][$_]{copt}{$c} eq 'ARRAY') ? join(' ', @{$htmlitem[$rn][$_]{copt}{$c}}) : $htmlitem[$rn][$_]{copt}{$c});
          }
          my $ctag = (
            ($htmlitem[$rn][$_]{ctag} eq 'th') or 
            ($htmlitem[0][$_]{ctag}   eq 'th') or
            ($htmlitem[$rn][0]{ctag}  eq 'th')
          )?'th':'td';
          sprintf("<$ctag$copt>%s</$ctag>", $htmlitem[$rn][$_]{wini});
        }
      } (1 .. $#{$htmlitem[1]})
    );
    $outtxt .= "</tr>\n";
  } # foreach $rn
  $outtxt .= "</table>\n";
  $outtxt=~s/\t+/ /g; # tab is separator of cells vertically unified
  return("\n$outtxt\n");
}

1;
