#!/usr/bin/perl

use strict;
use warnings;
use utf8;

package WINI;
use Data::Dumper;
binmode STDOUT, ':utf8';

our %macros;
#init_macro();

$DB::single=1; $DB::single=1;

sub split1{
  my($x, $n)=@_;
  my $sep = substr($x, 0, 1);
  return(($n) ? split(/$sep/, substr($x,1), $n) : split(/$sep/, substr($x,1)));
}

#sub init_macro{
# s/({{(form|x|text|ph=bb)}})/call_macro($2,$3)/eg;

$macros{form} = sub{
# form|xx|yy
# n: type=number
# a: textarea
# init=: value= or textarea initial value
# ph=: placeholder=
# *: required

  my($name, $type, @f) = @_;
  my $outform;
  my %opt;
  #my($name, $type, @f) = split('\|', $f);
  my @f2;
  foreach my $f (@f){
    if(my($k,$v) = $f=~/^\s*(\w+)\s*=\s*(\S*)/){
      $opt{$k} = $v;
    }elsif($f eq '*'){
      $opt{required}=1;
    }elsif($f=~/\s*\*(.*)/){
      $opt{selected}{$1}=1;
      push(@f2, $1);
    }else{
      push(@f2, $f);
    }
  }
  my $opt      = ' ' . join(' ', map {"$_=$opt{$_}"} grep {!/(ph|init|required)/} keys %opt);
  my $ph       = (defined $opt{ph})?         $opt{ph}  :'';
  my $init     = (defined $opt{init})?       $opt{init}:'';
  my $required = (defined $opt{required})? ' required' :'';
  ($type) or $type='text';

  if($type eq 'a'){ # text input (long text)
    $outform=qq!<textarea name="$name" placeholder="$ph"$required>$init</textarea>!;

  }elsif((scalar grep {$type eq $_} qw/n numeral integer real date datetime range/)>0){ # text input (numeral)
    ($type eq 'n' or $type eq 'integer' or $type eq 'real') and $type='number';
    $outform=qq!<label><input name="$name" type="$type" value="$init" placeholder="$ph"$opt$required></label>!;

  }elsif((scalar grep {$type eq $_} qw/t text email url tel search password color/)>0){ # text input
    ($type eq 't') and $type='text';
    $outform=qq!<label><input name="$name" type="$type" value="$init" placeholder="$ph"$opt$required></label>!;
#  }elsif((scalar grep {$type eq $_} qw/s sel select/)>0){

  }elsif($type eq 's' or $type eq 'r'){ # select or radio button (easy version)
    my(@o);
    my %o2;
    my($group, $out) = ('', '');
    for(my $i=0; $i<=$#f2; $i++){
      my $vname = $f2[$i];
      $i++;
      my $val   = $f2[$i] || $f2[$i-1];
#      ($val) or warn("Value for '$vname' seems empty.");
      my $sel   = '';
      push(@o, {name=>$vname, val=>$val, sel=>$sel});
    }
    my $multi = ($opt{m})?' multiple':'';
    my $size  = (defined $opt{size}) ? qq! size="$opt{size}"! : '';
    $outform = ($type eq 's')
      ? qq!<select id="$name" name="$name"$size$multi$required>\n! . join("\n", 
        map {
          if($_->{name}=~/\S/){
            my $sel = (exists $opt{selected}{$_->{name}}) ? ' selected' : '';
            qq!<option value="$_->{val}"${sel}>$_->{name}</option>!
          }else{ # group setting
            ($group) and my $out="</optgroup>\n";
            $group = $_->{val};
            $out .= qq!<optgroup label="$group">!;
          }
        } @o) . "\n" . (($group)?"</optgroup>\n":'') . "</select>"
      : join("\n", map { # $typpe eq 'r'
          if($_->{name}=~/\S/){
            my $sel = (exists $opt{selected}{$_->{name}}) ? ' checked' : '';
            qq!<label><input name="$name" type="radio" value="$_->{val}"${sel}>$_->{name}</label>!
          }else{ # subgroup
            qq!<br><span class="radio_group">$_->{val}</span>!
          }
        } @o);
  }elsif($type eq 'button' or $type eq 'submit' or $type eq 'reset'){
    my $cont = ($f[1]) ? join('', @f[1..$#f]) : '';
    my $val  = ($f[0]) ? qq! value="$f[0]"! : '';
    $outform = qq!\n<button name="$name" type="$type"$val>$cont</button>!;
  }elsif($type eq 'finish'){
    $outform = qq!\n<input name="$name" type="submit"> <input name="$name" type="reset">\n</form>!;
  }elsif($type eq 'start'){
    my $action = $opt{action} || '';
    my $method = $opt{method} && qq!method="$opt{method}" ! || '';
    $outform = qq!\n<form id="${name}" ${method}action="${action}">\n!;
  }else{
    $outform=qq!<input name="$name" type="$type" value="$init" placeholder="$ph"$required>!;
  }
  return($outform);
};

$macros{warn} = sub{

};
#}

1;
