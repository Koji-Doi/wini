#!/usr/bin/perl
=head1 NAME

test script to display bib data

=head1 Filter options

Letters 'X' and 'Y' in filter name listed below represent any characters which users can choose freely from alphabets. For example, one can use 'p()' or 'p[]' to represent texts in parenthes.

Letter 'T' in filter name listed below represents any text containing any characters except for '|'. For example ,one can use '"abc"|"def"|"ghi"|j; ' to represent 'abc; def; ghi'.

Letter 'I' and 'J' in filter name listed below represents any text containing any numerals except for '|'. For example ,one can use '"abc"|"def"|"ghi"|2-3; ' to represent '"def"|"ghi"'.

=over 4

=item * B<pXY>: "abc"|p() -> "(abc)"

=item * B<lX>: "abc"|l* -> "*abc"

=item * B<rX>: "abc"|r* -> "abc*"

=item * B<jT>: '"abc"|"def"|"ghi"|j; ' -> 'abc; def; ghi'

=item * B<fl>: Represent person name in the format "Firstname Lastname". '"Kirk,  James T."|fl' -> 'James T. Kirk'

=item * B<lf>: Represent person name in the format "Lastname, firstname". '"Kirk,  James T."|lf' -> ' Kirk, James T.'

=item * B<fli>: Represent person name in the format "Firstname Lastname". First letters of words are capitalized. '"Kirk,  James T."|fl' -> 'James T. Kirk'

=item * B<lfi>: Represent person name in the format "Lastname, firstname". First letters of words are capitalized. '"Kirk,  James T."|lf' -> ' Kirk, James T.'

=item * B<u>, B<uu>: Case conversion of text. '"abc"|uu' -> "ABC", '"abc"|u' -> "Abc"

=item * B<I-J>: List slice. '"a"|"b"|"c"|"d"|2-3' -> '"b"|"c"' 

=back

=cut

package Text::Markup::Wini;
use strict;
use warnings;
use utf8;
use List::Util qw(max);
use Data::Dumper;
use lib '.';
use Wini;

no warnings;
*Data::Dumper::qquote = sub { return encode "utf8", shift } ;
$Data::Dumper::Useperl = 1 ;
use warnings;

binmode STDIN,  ':utf8';
binmode STDOUT, ':utf8';
binmode STDERR, ':utf8';

my @x = ({
 'au' => ["Kirk,  James T.", "Suzuki, Taro", "Yamada, Hanako", "McDonald, Ronald"],
 'ti' => "A study of biologists' endurance in research settings.",
 'jo' => "Journal of Negative data in Biology",
 "year" => 2022,
 "vo" => 2,
 "issue" => 2,
 "pp" => "100-110",
 'url' => "http://example.com/jndb/2022_2_2_100",
 'doi' => "00.00000/ZZZZZ00/0000",
},{
 'au' => ["山岡, 士郎", "栗田, ゆう子", "海原, 雄山"],
 'ti' => "究極のメニューとは何か？",
 'year' => 2022,
 'url' => "http://example.com/2022_1",
 'pu'  => "東西新聞社"
});

my $form = "[au|1|lf]; [au|2-3|lf|j: ]; [au|4-|etal]; [year]. [ti]. {{/|[jo]}} [vo][issue|p()]:[pp].";

=begin c
sub val{
 my($x, $form) = @_;
 my($valname, @filter) = split(/\|/, $form);
 my $y0 = $x->{$valname} || [''];
 my $y = (ref $y0 eq 'ARRAY')? $y0 : [$y0];
 foreach my $f (@filter){
   if($f eq '1'){
     $y=[$y->[0]];
   }elsif($f eq 'lf' or $f eq 'lfi'){ # Last, First
     $y = [map {
       my($last, $first) = /([^,]*), *(.*)/;
       ($f eq 'lfi') and ($last, $first) = ((uc substr($last,0,1)), (uc substr($first,0,1)));
       "${last}, ${first}"
     } @$y];
   }elsif($f eq 'fl' or $f eq 'fli'){ # First Last
     $y = [map {my($last, $first) = /([^,]*), +(.*)/; "${first} ${last}"} @$y ];
   }elsif($f eq 'uu'){
     $y = [map {uc $_} @$y];
   }elsif($f eq 'u'){
     $y = [map {ucfirst(lc $_)} @$y];
   }elsif($f=~/(\d)+(?:-(\d+))?/){
     my($first,$last) = ($1-1, ($2||scalar @$y)-1);
     $y = [@$y[$first..$last]];
   }elsif($f=~/^j(.*)$/){
     my $sep = $1 || ' ';
     $y = [ join($sep, @$y) ];
   }elsif($f=~/^l(.*)$/){ # "abc"|l* -> "*abc"
   }elsif($f=~/^r(.*)$/){ # "abc"|r* -> "abc*"
   }elsif($f=~/^p(.)(.)$/){ # "abc"|p() -> "(abc)"
     $y = [ map {$1 . $_ . $2} @$y];
   }elsif($f=~/^etal(\d*)$/){
   }
 }
 return($y->[-1]);
}

=end c
=cut

my @data = qw/au|1|lf au|2-|fl|j, jo|p<>/;
my $len = max(map {length($_)} @data);

foreach my $d (@data){
  printf "%*s : %s\n", -$len, $d, refval($x[0], $d);
}
print "-----\n\n";

my $f=$form;
print "Before: $f\n";
$f=~s/\[(.*?)\]/refval($x[0], $1)/ge;
print "After:  $f\n";
my(@res) = markgaab($f);
print "\nFinal result:\n";
print Dumper @res;

__END__

{{Cite web |url= |title= |trans-title= |accessdate= |last= |first= |author= |authorlink= |coauthors= |date= |year= |month= |format= |website= |work= |publisher= |page= |pages= |quote= |language= |archiveurl= |archivedate= |deadlinkdate= |doi= |ref=}}
