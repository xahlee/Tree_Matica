#!perl -w

use strict;
require 'dumpvar.pl';


sub Table {
my $exprString = shift(@_);
my @iteratorList = @_;

my $depth = scalar(@iteratorList);
my @parameterList = ();

foreach my $ref_iterator (@iteratorList) {
if (scalar(@$ref_iterator) == 1) { push(@parameterList, ${UniqueString($exprString,1)}[0]);}
else { push(@parameterList, shift(@$ref_iterator));};
};
my $ref_rangeSequence = _rangeSequence(\@iteratorList);

my $stringToBeEvaluated;
$stringToBeEvaluated .= 'my (';
foreach my $variable (@parameterList) {$stringToBeEvaluated .= '$' . $variable . ','};
$stringToBeEvaluated .= "); \n";
$stringToBeEvaluated .= 'my @resultArray;' . "\n\n";

	for my $i (0 .. $depth-1) {
	$stringToBeEvaluated .= 'foreach $' . $parameterList[$i] .
	' (0 .. scalar(@{$ref_rangeSequence->[' . $i . ']}) -1 ) {' . qq(\n);
	};
	
	$stringToBeEvaluated .= '$resultArray';
	foreach my $variable (@parameterList) {$stringToBeEvaluated .= '[$' . $variable . ']';};
	$stringToBeEvaluated .= ' = &{Function(\@parameterList,$exprString)} (';
	for (my $i=0; $i<$depth; $i++) {$stringToBeEvaluated .=  '$ref_rangeSequence->[' . $i .
	']->[$' . $parameterList[$i] . '],'
	};
	$stringToBeEvaluated .= "); \n";
	
	$stringToBeEvaluated .= '};' x $depth . "\n\n";
	$stringToBeEvaluated .=  'return \@resultArray;';

eval($stringToBeEvaluated);
};

sub UniqueString {
	my $input = $_[0];
	my $n = $_[1];
	
	my $str = 'unik' . int(rand()*10000*$n);
	my @result = ();
	for (my $i = 0; $i < $n; $i++) {
	while ($input =~ m($str)) {$str = 'unik' . int(rand()*10000*$n);}
	$input .= $str;
	push (@result, $str);
	};
	return \@result;
};
sub Function {
	my @parameterList = @{$_[0]};
	my $expression = $_[1];
	
	my $parameterDeclarationString = '(';
	
	foreach my $parameterString (@parameterList) {
	my $variable = '$' . $parameterString;
	$expression =~ s($parameterString)($variable)g;
	$parameterDeclarationString .= q($) . $parameterString . q(,);
	};
	
	chop($parameterDeclarationString);
	$parameterDeclarationString = q(my ) . $parameterDeclarationString . ')' . q(= 	@_;);
	
	return eval("sub {$parameterDeclarationString; return ($expression);}");
};

sub _rangeSequence {
my $ref_iteratorList = $_[0];

my @result;
foreach my $ref_iterator (@$ref_iteratorList) {push(@result, Range(@$ref_iterator))};
return \@result;
};

sub Range {
if (scalar @_ == 1) {return &_range(1,$_[0],1);};
if (scalar @_ == 2) {return &_range($_[0],$_[1],1);};
if (scalar @_ == 3) {return &_range($_[0],$_[1],$_[2]);};
};

sub _range {
my ($a1, $b1, $dx) = @_;

if ($dx == 0) {print "Range: increment cannot be zero."; return 0}
elsif ($a1 == $b1) {return [$a1];}
elsif ( ((($b1 - $a1) > 0) && ($dx < 0)) || ((($b1 - $a1) < 0) && ($dx > 0)) ) {print "Range: bad arguments. You have [$a1,$b1,$dx]"; return 0;}
elsif ((($a1 < $b1) && ($b1 < ($a1 + $dx))) || (($a1 > $b1) && ($b1 > ($a1 + $dx)))) {return [$a1];}
else { return _rangeWithGoodArgs ($a1,$b1,$dx);};
};

sub _rangeWithGoodArgs {
my ($a1, $b1, $dx) = @_;
my @result;

if ($a1 < $b1) {for (my $i = $a1; $i <= $b1; $i += $dx) { push (@result, $i);}; }
else {for (my $i = $a1; $i >= $b1; $i += $dx) { push (@result, $i);}; };
return \@result;
};


# ------------------------
# testing

my $ref_array = Table('[h,m]',['h',3],[3],['m',1,-5,-2]);

dumpValue($ref_array);


__END__

