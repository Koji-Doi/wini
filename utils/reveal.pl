#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use Time::Piece;
use File::Copy;
use File::Path qw(make_path);
use File::Find;
use File::Basename;
use Cwd;
use Data::Dumper;
use Wini;

no warnings;
*Data::Dumper::qquote = sub { return encode "utf8", shift } ;
$Data::Dumper::Useperl = 1 ;
use warnings;

binmode STDIN, ':utf8';
binmode STDOUT, ':utf8';
binmode STDERR, ':utf8';

# set parameters for Reveal.initialized
my %rev_pars = (
controls => "true",
progress => "true",
slideNumber => "false",
history => "false",
keyboard => "true",
overview => "true",
center => "true",
touch => "true",
loop => "false",
rtl => "false",
fragments => "true",
embedded => "false",
help => "true",
autoSlide => "0",
autoSlideStoppable => "true",
mouseWheel => "false",
hideAddressBar => "true",
previewLinks => "false",
transition => "default",
transitionSpeed => "default",
backgroundTransition => "default",
viewDistance => "3",
parallaxBackgroundImage => "",
parallaxBackgroundSize => "",
parallaxBackgroundHorizontal => "",
parallaxBackgroundVertical => ""
);

my($infile, $outfile) = @ARGV;

my %Config = (
  title   => 'Presentation',
  theme   => 'beige',
  path    => "",
  lang    => "ja",
  color   => "black",
  bgcolor => "white",
  time    => localtime->strftime("%Y%m%d_%H%M"),
  font    => q{"Helvetica Neue", Arial, "Hiragino Kaku Gothic ProN", "Hiragino Sans", "BIZ UDPGothic", Meiryo, sans-serif}
);
$Config{title} = "Presentation at $Config{time}";
$Config{config} = '';

Text::Markup::Wini::init();
my($basehtml, $body) = ('',''); # index.html, src.wini
my @body0;
my $slidetype;

# read data file and merge
open(my $fhi, '<:utf8', $infile) or die "$infile: not found";
my $div_no = 0;
while(<$fhi>){
  if(/^----\s*$/){
    $div_no++;
    next;
  }
  if(my($nextslidetype) = m{^//(.*)//}){
    if(defined $body0[$div_no]){
      if(defined $body0[$div_no]){
        my $x = add(\@body0, ($slidetype||''));
        $body .= $x;
      } 
    } 
    $slidetype = $nextslidetype;
    $div_no = 0;
    undef $body0[$div_no];
  }else{
    push(@{$body0[$div_no]}, $_);
  }
}
if(defined $body0[$div_no]){
  $body .= add(\@body0, $slidetype);
}

# set parameters
$Config{init} = '';
foreach my $k (%rev_pars){
  if(exists $Config{$k}){
    $Config{init} .= "$k: $Config{$k},\n";
  }
}

# read index.html
$basehtml = join('', <DATA>);
foreach my $c (keys %Config){
  $basehtml=~s/\{\{$c}}/$Config{$c} || ''/eg;
}

$basehtml=~s{([ \t]*)<div class="slides">.*?</div>}{
  my $spc = $1;
  $body=~s/^/$spc/gm;
  <<"EOD";
  ${spc}<div class="slides">
  $body
  ${spc}</div>
EOD
}se;

# final
open(my $fho, '>:utf8', $outfile) or die "Cannot modify $outfile.";
print {$fho} "$basehtml\n";
close $fho;

{
  my $slide_no = 0;
sub add{
  my($body00, $slidetype) = @_;
  my $out;
  my $init='';
  for(my $i = 0; $i<=$#$body00; $i++){
    my $body0 = $body00->[$i];
    my $body1;
    if($slidetype eq 'config'){
      foreach my $b (@$body0){
        my($k, $v) = $b=~/(\S+)\s*:\s*(.*)/;
        (defined $k) or next;
        $v=~s/\s*$//;
        $Config{$k} = $v;
      }
      return('');

    }elsif($slidetype eq 'title'){
      my($ptitle, $psubtitle, $au, $af) = map {s/\s*$//; my($x)=Text::Markup::Wini::markgaab($_, {para=>'nb'}); $x} @$body0;
      $body1 = <<"EOD";
<h2 class="ptitle">${ptitle}</h2>
<h3 class="psubtitle">${psubtitle}</h3>
<p class="au">${au}</p>
<p class="af">${af}</p>
EOD
      chomp $body1;

    }else{ # normal slide
      $slide_no++;
      if($slide_no>=6){
        $DB::single=$DB::single=1;
        1;
      }
      print STDERR "no: $slide_no\n", (scalar @$body00), "\n";
      ($body1) = Text::Markup::Wini::to_html(join('', @$body0));
      $body1=~s/^\s*//; $body1=~s/\s*$//;
      $body1 = qq!<div class="side${i}">${body1}</div>!;
    }
    $out .= "<section>\n$body1\n</section>\n\n";
  }
  return($out);
}
}


__DATA__
<!doctype html>
<html lang="{{lang}}">
	<head>
		<meta charset="utf-8">
		<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">

		<title>{{title}}</title>

		<link rel="stylesheet" href="dist/reset.css">
		<link rel="stylesheet" href="dist/reveal.css">
		<link rel="stylesheet" href="dist/theme/{{theme}}.css">

		<!-- Theme used for syntax highlighted code -->
		<link rel="stylesheet" href="plugin/highlight/monokai.css">
    <style>
    html{
      font: {{font}}; {{color}} {{bgcolor}};
    }
    /* Flexboxコンテナのスタイリング */
    .flex-container {
      display: flex;
      flex-wrap: wrap; /* コンテンツが多い場合は折り返す */
      gap: 20px; /* アイテム間のスペース */
    }

/* Flexアイテムのスタイリング */
    .flex-item {
      flex: 1; /* 各アイテムが均等にスペースを取るようにする */
      min-width: 300px; /* 最小のアイテム幅 */
    }

/* テキストのスタイリング */
    .flex-item p {
      text-align: justify;
    }

    h2.ptitle{
      text-shadow: 4px 4px 10px;
    }
    h3.psubtitle{
      color: #303030;
    }
    .au{ /* Presentaters in title slide */
      font-weight: bold;
    }
    .af{ /* Affiliation in title slide */
      color: #909090;
    }
    </style>
	</head>
	<body>
		<div class="reveal">
			<div class="slides">
				<section>Slide 1</section>
				<section>Slide 2</section>
			</div>
		</div>

		<script src="dist/reveal.js"></script>
		<script src="plugin/notes/notes.js"></script>
		<script src="plugin/markdown/markdown.js"></script>
		<script src="plugin/highlight/highlight.js"></script>
		<script>
			// More info about initialization & config:
			// - https://revealjs.com/initialization/
			// - https://revealjs.com/config/
			Reveal.initialize({
				hash: true,
        {{init}}
				// Learn about plugins: https://revealjs.com/plugins/
				plugins: [ RevealMarkdown, RevealHighlight, RevealNotes ]
			});
		</script>
	</body>
</html>
