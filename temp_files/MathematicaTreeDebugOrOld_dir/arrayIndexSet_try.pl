#!perl -w

# testing testing.

#------------

use strict;

use Data::Dumper; $Data::Dumper::Indent=0;
# require 'dumpvar.pl'; #dumpValue($ref);
 use MathematicaTree;
# use Benchmark;

#---------------


#_____ ArrayIndexSet _____ _____

=pod

B<ArrayIndexSet>

ArrayIndexSet(dimensions) returns a complete index set for an array of given dimensions. dimensions has the from [n1,n2,...], where n are non-negative integers. The return value is a reference to a nested array, where there are n1 elements in the first level, and n2 elements in each element of the second level, and so on. ArrayIndexSet(dimensions) is equivalent to ArrayIndexSet(dimensions, 0).

ArrayIndexSet(dimensions,n) starts the index at n, where n is any integer.

Related: CompleteIndexSet, MinimumIndexSet, IndexSetSort.

Example:


=cut

# implementation note:
# Definition:
# ArrayIndexSet[dimensions1,Heads->True] is supposed to return all the indexes of a tree having dimensions1. For example, suppose dimensions1={a,b,c}, then it should generate all the following indexes: {0,0,0}<=({i},{i,j},{i,j,k})<={a,b,c}.
#For example, ArrayIndexSet[{2,2,2}] should return
#{{0},{1},{2},{0,0},{0,1},{0,2},{1,0},{1,1},{1,2},{2,0},{2,1}, {2,2},{0,0,0},{0,0,1},{0,0,2},{0,1,0},{0,1,1},{0,1,2},{0,2,0}, {0,2,1},{0,2,2},{1,0,0},{1,0,1},{1,0,2},{1,1,0},{1,1,1},{1,1,2}, {1,2,0},{1,2,1},{1,2,2},{2,0,0},{2,0,1},{2,0,2},{2,1,0},{2,1,1}, {2,1,2},{2,2,0},{2,2,1},{2,2,2}}

# Dependent functions: (none)

# misc notes: this function needs heavy testing.

push (@EXPORT, q(ArrayIndexSet));
push (@EXPORT_OK, q(ArrayIndexSet));

sub _arrayIndexSetFullArguments ($$) {
	my @dimensions = @{$_[0]};
	my @beginningCount = $_[1];

	my @result;
	LABEL132: foreach my $currentDimensionNumber (@dimensions) {
		LABEL282: foreach my $i (1..$currentDimensionNumber) {
			
		}
	};

};
