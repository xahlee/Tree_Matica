#2003-08

# given a list of pairs such as ([1,3],[7,9],[3,2],[5,3],[2,1],[4,7],[8,6])
# where each pair means equivalence of two numbers, so [1,3] and [3,2] implies [1,2] too.
# the problem is to put equivalent number together, i.e. the input should become [[1,2,3,5],[7,9,4],[8,6]];
# sorted if desired.


# algorithm description:
# call the input as @input, the result list is named @interm
# take one pair from input and put it in @interm, e.g. interm ([m,n])
# then, go thru each pair in @input.
# For each pair in @input, check each pairs in each equivalence group in @interm
# if match, add the pair to the current group then start with the next pair in @input
# if no match, go to the next group in @interm.

# Now, for some inputs containing equivalent pairs e.g. [1,9],[2,7] that has a link between them [7,9] that comes later in the input list , the algorithm will create two groups in @interm [1,9],[2,7]. So we need join them.

# again, we basically go thru the above step but now @interm is our @input and @fin is our @interm. @fin is the final result.


use strict;
use Data::Dumper;
$Data::Dumper::Indent=0;


sub merge($) {
my @input = @{$_[0]};

my @interm; # array of hashs

# chop the first value of @input into @interm
$interm[0]={$input[0][0]=>'x'}; ${interm[0]}{$input[0][1]}='x'; shift @input;

N1: for my $aPair (@input) {
  for my $aGroup (@interm) {
			if (exists ${$aGroup}{$aPair->[0]}) {${$aGroup}{$aPair->[1]}='x'; next N1}
			if (exists ${$aGroup}{$aPair->[1]}) {${$aGroup}{$aPair->[0]}='x'; next N1}
	}
	push @interm, {$aPair->[0]=>'x'}; ${interm[-1]}{$aPair->[1]}='x';
}

# print Dumper \@interm;
my @fin = shift @interm;

N2: for my $group (@interm) {
  for my $newcoup (@fin) {
		foreach my $k (keys %$group) {
			if (exists ${$newcoup}{$k}) {map { ${$newcoup}{$_}='x'} (keys %$group); next N2;}
    }
  }
	push @fin, $group;
}
return map {[keys (%$_)]} @fin;
}


# print Dumper [merge [[1,3],[7,9],[3,2],[5,3],[2,1],[4,7],[8,6]] ]; # returns [['1','2','3','5'],['7','9','4'],['8','6']];
print Dumper [merge [  [1,9], [2,8], [4,7], [5,6], [8,9] ]]; # returns [['8','9','1','2'],['7','4'],['5','6']];
# print Dumper [merge [ [3,4],[1,2],[1,3]  ] ]; # returns [[1,2,3,4]];


__END__
