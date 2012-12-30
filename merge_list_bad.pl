#2003-08


# given a list of pairs such as ([1,3],[7,9],[3,2],[5,3],[2,1],[4,7],[8,6])
# where each pair means equivalence of two numbers, so [1,3] and [3,2] implies [1,2] too.
# the problem is to put equivalent number together, i.e. the input should become [[8,6],[1,3,2,5],[7,9,4]];

# the following solution has logic problem in algorithm.
# for some input such as ( [1,9], [2,8], [4,7], [5,6], [8,9] );
# in returns [[1,9,8],[2,8],[4,7],[5,6]];
# and, the solution also creates repeations in the result

# the algorithm used as follows:
# call the input as @merge, the result list is named @final
# take one pair in merge and put it in @final, e.g. final ([m,n])
# then, go thru each pair in @merge.
# For each pair in @merge, check each pairs in each equivalence group in @final
# if match, add the pair to the current group then start with the next pair in @merge
# if no match, go to the next group in @final.

# the problem with this algorithm is that for some inputs containing equivalent pairs e.g. [1,3],[2,4] that has a link between them [1,2] that comes later in the input list , the algorithm will create two groups in @final [1,3],[2,4] and the algorithm never goes back to join them.
# also, the algorithm needs to get rid of repeaetions in @final.



use strict;
use Data::Dumper;


$Data::Dumper::Indent=0;


my @merge =();
 @merge =  ([1,3],[7,9],[3,2],[5,3],[2,1],[4,7],[8,6]);
 @merge = ( [1,2], [1,4], [1,5], [2,5], [2,6], [3,6], [4,5], [5,6] );
 @merge = ( [1,9], [2,8], [4,7], [5,6], [8,9] );
my @final =();

$final[0]= shift @merge;
# print Dumper \@final;


N1: for my $aPair (@merge) { print 'aPair is ', Dumper $aPair; print "\n";
  for my $aGroup (@final) { print '     aGroup is ', Dumper $aGroup; print "\n";
		for my $aIndex (@$aGroup) { #print '          a index ', Dumper $aIndex; print "\n";
			if ($aPair->[0]==$aIndex) {push @$aGroup, $aPair->[1]; next N1}
			if ($aPair->[1]==$aIndex) {push @$aGroup, $aPair->[0]; next N1}
		}
	}
  push @final, $aPair;
}

print Dumper \@final;


__END__

The following variation is the same algorithm but using hash as input and hash as the final list.
The advantage of hash is that one does not have to worry about repetition.


my @merge=();
@merge=( [1,2], [1,4], [1,5], [2,5], [2,6], [3,6], [4,5], [5,6] );
#print Dumper \@merge; print "\n";

my @final; # array of hashs

# put the last value of @merge into @final
push @final, {$merge[-1][0]=>'x'}; ${final[-1]}{$merge[-1][1]}='x'; pop @merge;

print '                     final is ', Dumper \@final; print "\n";

N1: for my $aPair (@merge) { print 'aPair is ', Dumper $aPair; print "\n";
  for my $aGroup (@final) { print '     aGroup is ', Dumper $aGroup; print "\n";
			if (exists ${$aGroup}{$aPair->[0]}) {${$aGroup}{$aPair->[1]}='x'; next N1}
			if (exists ${$aGroup}{$aPair->[1]}) {${$aGroup}{$aPair->[0]}='x'; next N1}
	}
	push @final, {$aPair->[0]=>1}; ${final[-1]}{$aPair->[1]}=1;
print '          final is ', Dumper \@final; print "\n";
}

print Dumper \@final;

__END__


$VAR1 = [[1,2],['5',6],[1,4],[1,5],['2',5],['2',6],['3',6],['4',5]];
                     final is $VAR1 = [{'4' => 'x','5' => 'x'}];
aPair is $VAR1 = [1,2];
     aGroup is $VAR1 = {'4' => 'x','5' => 'x'};
          final is $VAR1 = [{'4' => 'x','5' => 'x'},{'1' => 1,'2' => 1}];
aPair is $VAR1 = ['5',6];
     aGroup is $VAR1 = {'4' => 'x','5' => 'x'};
aPair is $VAR1 = [1,4];
     aGroup is $VAR1 = {'4' => 'x','5' => 'x','6' => 'x'};
aPair is $VAR1 = [1,5];
     aGroup is $VAR1 = {'1' => 'x','4' => 'x','5' => 'x','6' => 'x'};
aPair is $VAR1 = ['2',5];
     aGroup is $VAR1 = {'1' => 'x','4' => 'x','5' => 'x','6' => 'x'};
aPair is $VAR1 = ['2',6];
     aGroup is $VAR1 = {'1' => 'x','2' => 'x','4' => 'x','5' => 'x','6' => 'x'};
aPair is $VAR1 = ['3',6];
     aGroup is $VAR1 = {'1' => 'x','2' => 'x','4' => 'x','5' => 'x','6' => 'x'};
$VAR1 = [{'1' => 'x','2' => 'x','3' => 'x','4' => 'x','5' => 'x','6' => 'x'},{'1' => 1,'2' => 1}];

__END__
