#!/usr/bin/env perl

#package Text::Markup::Wini;
use strict;
use warnings;
use Test::More;
use utf8;
use Data::Dumper;
use File::Temp qw(tempdir);
use File::Copy qw(cp copy);
use Cwd;

use lib '.';
use Wini;
use lib './t';
use t;
our $DEBUG = (defined $ARGV[0] and $ARGV[0] eq '-d') ? 1 : 0;
Text::Markup::Wini::init();
$ENV{LANG}='C';

sub std1{
  my($x)=@_;
  $x = std($x);
  $x=~s{(</\w+>)}{$1\n}g;
  return($x);
}

our %REF;
my @indata;
my $i=0;
my $mode="";
my @reflist;

# save test enw files
my @files;
my $fho;
while(<DATA>){
  if(/^---start (.*)/){
    (defined $fho) and close $fho;
    my $file=$1;
    ($DEBUG) and print STDERR "output=$file\n";
    open($fho, '>:utf8', $file) or die "Cannot open $file";
    ($file=~/\.enw$/) and push(@files, $file);
  }elsif(/^---end/){
    close $fho;
    undef $fho;
    last;
  }else{ # write to .enw file
    print {$fho} $_;
  }
}

my $cwd = cwd();
for(my $i=0; $i<=$#files; $i++){
  my $tempdir = tempdir('reffile_XXXX');
  chdir $tempdir;
  ($DEBUG) and print STDERR "Test in $tempdir\n";
  copy("../$files[$i]", $files[$i]) or die "Failed to copy $files[$i] to $tempdir";
  my $cmd = "../Wini.pm --bibonly --bib $files[$i] 2> err.log";
  ($DEBUG) and print STDERR "Try $cmd\n";
  my $r = system($cmd);
  if($r>0){
    $r = $r >> 8;
    ($DEBUG) and print STDERR (<<"EOD");
Error occured in trying '$cmd'.
Return=$r
EOD
  }

  my $outfiles = join(' ', sort <*.*>);
  is $outfiles, join(' ', sort ('err.log', $files[$i], "$files[$i].ref")), $files[$i];

  open(my $fhi, '<:utf8', "$files[$i].ref") or die "$files[$i].ref not found";
  my $got = join('', <$fhi>);
  close $fhi;
  open($fhi, '<:utf8', "../$files[$i].ref") or die "../$files[$i].ref not found";
  my $exp = join('', <$fhi>);
  is $got, $exp, "$files[$i]: output";

  ($DEBUG) or map{unlink $_} <*>;
  chdir $cwd;
  ($DEBUG) or rmdir $tempdir;
}

while(<DATA>){
  /^"$/ and next;
  /^---start mg(?:\s*(.*))?$/ and ($i++, $mode='mg', $indata[$i]{tag}=$1, next);
  /^---start html/ and ($mode='html', next);
  /^---start log/  and ($mode='log', next);
  /^---end/ and last;
  $indata[$i]{$mode} .= $_;
}

done_testing;

__DATA__
---start reffile_book.enw
%0 Book
%T The Scope of American Linguistics: Papers of the First Golden Anniversary Symposium of the Linguistic Society of America, Held at the University of Massachusetts, Amherst, on July 24 and 25, 1974
%A Austerlitz, Robert
%@ 3110857618
%D 2015
%I Walter de Gruyter GmbH & Co KG
---start reffile_book.enw.ref
refid	type	cittype	source	url	inline_id	au	tau	ye	ti
austerlitz2015_001	cit	ja	1			Austerlitz, Robert		2015	The Scope of American Linguistics: Papers of the First Golden Anniversary Symposium of the Linguistic Society of America, Held at the University of Massachusetts, Amherst, on July 24 and 25, 1974
---start reffile_bookchapter.enw
%0 Book Section
%T It’s DE-licious: a recipe for differential expression analyses of RNA-seq experiments using quasi-likelihood methods in edgeR
%A Lun, Aaron TL
%A Chen, Yunshun
%A Smyth, Gordon K
%B Statistical genomics
%P 391-416
%D 2016
%I Springer
%# (from the original content) Cite this protocol as:    Lun A.T.L., Chen Y., Smyth G.K. (2016) It’s DE-licious: A Recipe for Differential Expression Analyses of RNA-seq Experiments Using Quasi-Likelihood Methods in edgeR. In: Mathé E., Davis S. (eds) Statistical Genomics. Methods in Molecular Biology, vol 1418. Humana Press, New York, NY. https://doi.org/10.1007/978-1-4939-3578-9_19
%# (from pubmed APA format)          Lun, A. T., Chen, Y., & Smyth, G. K. (2016). It's DE-licious: A Recipe for Differential Expression Analyses of RNA-seq Experiments Using Quasi-Likelihood Methods in edgeR. Methods in molecular biology (Clifton, N.J.), 1418, 391–416. https://doi.org/10.1007/978-1-4939-3578-9_19
%# (from google scholoar APA format) Lun, A. T., Chen, Y., & Smyth, G. K. (2016). It’s DE-licious: a recipe for differential expression analyses of RNA-seq experiments using quasi-likelihood methods in edgeR. In Statistical genomics (pp. 391-416). Humana Press, New York, NY.
---start reffile_bookchapter.enw.ref
refid	type	cittype	source	url	inline_id	au	tau	ye	ti
lun_2016_001	cit	ja	1			Lun, Aaron TL		2016	It’s DE-licious: a recipe for differential expression analyses of RNA-seq experiments using quasi-likelihood methods in edgeR
---start reffile_cirnii_jpn.enw
%T 報告 2021年日本ベントス学会・日本プランクトン学会合同大会自由集会 「環境DNAを使ったベントス研究の現状：実際，どの程度使えるものなのか？」開催報告
%J 日本ベントス学会誌
%0 Journal Article
%@ 1345-112X
%I 日本ベントス学会
%D 2021
%G ja
%8 2021-12-25
%V 76
%N 0
%P 135-136
%U https://cir.nii.ac.jp/crid/1390009640044958464
%R 10.5179/benthos.76.135

%A 宮園, 誠二
%A 児玉, 貴央
%A 赤松, 良久
%A 中尾, 遼平
%A 齋藤, 稔
%A 辻, 冴月
%G ja
%H Miyazono, Seiji
%H Kodama, Takao
%H Akamatsu, Yoshihisa
%H Nakao, Ryohei
%H Saito, Minoru
%H Tsuji, Satsuki
%T 環境 DNA 分析による江の川支流のアユ生息場としての評価
%J 応用生態工学
%0 Journal Article
%@ 1344-3755
%I 応用生態工学会
%D 2021
%8 2021-12-10
%V 24
%N 2
%P 259-266
%U https://cir.nii.ac.jp/crid/1390854882637686016
%R 10.3825/ece.21-00011
---start reffile_cirnii_jpn.enw.ref
refid	type	cittype	source	url	inline_id	au	tau	ye	ti
?2021_001	cit	ja	1	https://cir.nii.ac.jp/crid/1390009640044958464		"報告 2021年日本ベントス学会・日本プランクトン学会合同大会自由集会 「環境DNAを使ったベントス研究の現状：実際，どの程度使えるものなのか？」開催報告"		2021	
miyazono_2021_001	cit	ja	1	https://cir.nii.ac.jp/crid/1390854882637686016		宮園, 誠二	Miyazono, Seiji	2021	環境 DNA 分析による江の川支流のアユ生息場としての評価
---start reffile_googlescholar.enw
%0 Generic
%T Statistical Genomics: Methods and Protocols
%A Math, Ewy
%A Davis, Sean
%@ 1493935763
%D 2016
%I Humana Press
---start reffile_googlescholar.enw.ref
refid	type	cittype	source	url	inline_id	au	tau	ye	ti
math_2016_001	cit	ja	1			Math, Ewy		2016	Statistical Genomics: Methods and Protocols
---start reffile_various.enw
%0 Journal Article
%T Enrichr: interactive and collaborative HTML5 gene list enrichment analysis tool
%A Chen, Edward Y
%A Tan, Christopher M
%A Kou, Yan
%A Duan, Qiaonan
%A Wang, Zichen
%A Meirelles, Gabriela Vaz
%A Clark, Neil R
%A Ma’ayan, Avi
%J BMC bioinformatics
%V 14
%N 1
%P 1-14
%@ 1471-2105
%D 2013
%I BioMed Central

%0 Generic
%T Mojolicious. Real-time web framework
%A Riedel, Sebastian
%D 2008

%0 Conference Proceedings
%T P2P media streaming with HTML5 and WebRTC
%A Nurminen, Jukka K
%A Meyn, Antony JR
%A Jalonen, Eetu
%A Raivio, Yrjo
%A Marrero, Raul Garc?a
%B 2013 IEEE Conference on Computer Communications Workshops (INFOCOM WKSHPS)
%P 63-64
%@ 1479900567
%D 2013
%I IEEE
---start reffile_various.enw.ref
refid	type	cittype	source	url	inline_id	au	tau	ye	ti
chen_2013_001	cit	ja	1			Chen, Edward Y		2013	Enrichr: interactive and collaborative HTML5 gene list enrichment analysis tool
nurminen_2013_001	cit	pc	1			Nurminen, Jukka K		2013	P2P media streaming with HTML5 and WebRTC
riedel2008_001	cit	ja	1			Riedel, Sebastian		2008	Mojolicious. Real-time web framework
---end
