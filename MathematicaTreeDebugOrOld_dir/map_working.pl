#!/usr/local/bin/perl5 -w

use strict;
use Data::Dumper qw(Dumper); $Data::Dumper::Indent=0;

#-------

# _nodeDepth(completeIndexSet, index) returns the depth of the index.
# problem: given an index I and a complete index set S, how to find the depth of the index?
# solution:
# 1. find all the indexes that starts with the same components as I. (i.e. all offsprings of I, including itself.)
# 2. count the number of the trailing components. The answer is max+1.
sub _nodeDepth ($$) {
my @indexSet = @{$_[0]};
my @index = @{$_[1]};

my $length = scalar @index;
@indexSet = grep {
my $temp =1;
HH: for (my $i=0; $i <= $#index; $i++) {
  if ($index[$i] != $_->[$i]) {$temp =0; last HH;};
};
$temp;
} (grep {scalar @{$_} >= $length} @indexSet);

my $result = $length;
foreach $_ (@indexSet) {
  if (scalar @{$_} > $result) {$result = scalar @{$_};};
};

return $result -$length + 1;
};


#_____ TreeToIndexSet _____ _____ _____ _____

=pod

B<TreeToIndexSet>

TreeToIndexSet(tree) returns a list of all atoms (leaves) and their positions that represents the tree completely. The return value consists of pairs of position indexes and corresponding atoms.

The input tree must have the form [[...],...] where an atomic element is anything that is not a reference to an array. The return value is a reference to an array, of the form [[positionIndex1, atom1],[positionIndex2,atom2],...], where each positionIndex has the form [n1,n2,...].

Unimplemented extension: TreeToIndexSet(tree,levelSpec) returns the indexes and corresponding subexpression at levspec. xxxxx

Related: xxxxx IndexSetToExpression.

Example:

 TreeToIndexSet( [0,1,2,3] );
 #returns [[[0],0],[[1],1],[[2],2],[[3],3]]

 TreeToIndexSet( [[3,4],'b',[[7,8],'love']] );
 #returns [[[0,0],3],[[0,1],4],[[1],'b'],[[2,0,0],7],[[2,0,1],8],[[2,1],'love']]

 TreeToIndexSet( [[[1,1],[1,2]],[[2,1],[2,2]],[[3,1],[3,2]]] );
 #returns:  [[[0,0,0],1],[[0,0,1],1],[[0,1,0],1],[[0,1,1],2],[[1,0,0],2],[[1,0,1],1],[[1,1,0],2],[[1,1,1],2],[[2,0,0],3],[[2,0,1],1],[[2,1,0],3],[[2,1,1],2]]

 # hash references can also serve as atoms, but not recommended.
 TreeToIndexSet ( [[3,4],[{'key1' => 1,'key2' => 2}, 5]] )
 #returns: [[[0,0],3],[[0,1],4],[[1,0],{'key1' => 1,'key2' => 2}],[[1,1],5]]

=cut

# implementation note:
# Dependent functions: (none)
# misc notes: this function needs heavy testing. xxxxx

#push (@EXPORT, q(TreeToIndexSet));
#push (@EXPORT_OK, q(TreeToIndexSet));

# A interface gate for the possibility of adding input error checking.
sub TreeToIndexSet ($) {
return _treeToIndexSet($_[0]);
};

sub _treeToIndexSet ($) {
my $ref_tree = $_[0];
my @result;

# &$_recursor(currentPositionIndex, ASubexpression) ... works like this:
# loop through ASubexperssion.
# if an element is an atom, then add the index (currentPositionIndex,$i) to the result.
# else, do &$_recursor( (currentPositionIndex,$i), $currentElement)
my $rf_recursor;
$rf_recursor = sub {
my $ref_currentPosition = $_[0];
my $ref_input = $_[1];

for my $i (0 ..  $#{$ref_input}) {
  if (ref $ref_input->[$i] ne 'ARRAY')
    {push( @result, [[(@{$ref_currentPosition},$i)], $ref_input->[$i] ]);}
  else
    {&$rf_recursor( [(@{$ref_currentPosition},$i)], $ref_input->[$i] ); };
};

};

&$rf_recursor([],$ref_tree);

return \@result;
};

#end TreeToIndexSet


#_____ CompleteIndexSet _____ _____ _____ _____

=pod

B<CompleteIndexSet>

CompleteIndexSet([index1,index2,...]) returns a modified version of argument in which indexes that are implied by givens are inserted. The elements in the result list is arbitrary ordered, and without duplicates.

Related: MinimumIndexSet, FullArrayIndexSet, IndexSetSort.

Example:

The empty array [] in the result represents the index for the root node.

 IndexSetSort( CompleteIndexSet( [[2, 1]] ) );
 #returns [[],[0],[1],[2],[2,0],[2,1]].

 IndexSetSort( CompleteIndexSet( [[2, 1], [3]] ) );
 #returns [[],[0],[1],[2],[3],[2,0],[2,1]].

 IndexSetSort( CompleteIndexSet( [[2, 1], [3], [3]] ) );
 #returns [[],[0],[1],[2],[3],[2,0],[2,1]].

 IndexSetSort( CompleteIndexSet( [[3, 3], [4]] ) );
 #returns [[],[0],[1],[2],[3],[4],[3,0],[3,1],[3,2],[3,3]].

 IndexSetSort( CompleteIndexSet( [[3, 3], [1, 1], [4]] ) );
 #returns [[],[0],[1],[2],[3],[4],[1,0],[1,1],[3,0],[3,1],[3,2],[3,3]].

=cut

# implementation note:
# some description:
# Suppose one of the given index is {a,b,c,d}. If the last digit is not 0, then generate {a,b,c,d-1}. If the last digit is 0, then generate {a,b,c}. Add the new element into a result list. Now take new element as input and repeat the process until it becomes {}. Now do the above with every given index. Now eliminate duplicates and {} in the result list. The result is as desired.

# Dependent functions: (none)

# misc notes: this function needs heavy testing. This function's time complexity can also be improved by first generate a minimum index set, and use a smart algorithm to avoid generating repeatitions (without even checking for presence). xxxxx

#push (@EXPORT, q(CompleteIndexSet));
#push (@EXPORT_OK, q(CompleteIndexSet));

sub CompleteIndexSet ($) {
# arg checks here...
return _completeIndexSet(@_);
};

sub _completeIndexSet ($) {
	my @indexList = @{$_[0]};

	my %indexListHash;
	foreach my $elem (@indexList) {$indexListHash{"@{$elem}"} = $elem;};

    foreach my $ref_index (@indexList) {
        my @index = @{$ref_index};
	LOOP1: while (@index) {
			if ($index[-1]-- == 0) {pop(@index);};
			if (exists $indexListHash{"@index"}) {last LOOP1;};
			$indexListHash{"@index"} = [@index];
		};
	};
	return [values %indexListHash];
};

#end CompleteIndexSet

#_____ IndexSetSort _____ _____ _____ _____

=pod

B<IndexSetSort>

IndexSetSort([index1,index2,...]) returns the indexes sorted. This is equivalent to IndexSetSort([index1,index2,...],0,1,1). The indexes have the form [[a1,a2,...],[b1,b2,...],...].

IndexSetSort([index1,index2,...], $sortByIndexFirstQ, $indexAscendingQ, $lengthAscendingQ) returns the indexes sorted. The rest of the parameters are booleans specifying the sorting criterions application order and directions.

The indexes are sorted using two criterions: (1) index number sequence from left to right. (2) the length of the indexes.

sortByIndexFirstQ controls which criterion will be used first. The other two arguments indexAscendingQ, lengthAscendingQ controls the ascending or decending direction for each criterion. The three booleans forms a total of 8 possible ways of ordering. Any number of the booleans can be omitted. User specified booleans will replace the defaults (0, 1, 1) from the left.

Example:

 IndexSetSort([[0], [1, 0], [1, 1, 0], [1, 1, 1], [1, 1, 2], [1, 1], [1, 2, 0], [1, 2, 1], [1, 2, 2], [1, 2], [1], [2, 0], [2, 1, 0], [2, 1, 1], [2, 1, 2], [2, 1], [2, 2, 0], [2, 2, 1], [2, 2, 2], [2, 2], [2]], 0, 1, 1);

Depending on the last three arguments, it returns one of the following:

#(0,0,0)
#sort by (depth decending, then index decending).
#[[2,2,2],[2,2,1],[2,2,0],[2,1,2],[2,1,1],[2,1,0],[1,2,2],[1,2,1],[1,2,0],[1,1,2],[1,1,1],[1,1,0],[2,2],[2,1],[2,0],[1,2],[1,1],[1,0],[2],[1],[0]];

#(0,0,1)
#sort by (depth ascending, then index decending).
#[[2],[1],[0],[2,2],[2,1],[2,0],[1,2],[1,1],[1,0],[2,2,2],[2,2,1],[2,2,0],[2,1,2],[2,1,1],[2,1,0],[1,2,2],[1,2,1],[1,2,0],[1,1,2],[1,1,1],[1,1,0]];

#(0,1,0)
#sort by (depth decending, then index ascending).
#[[1,1,0],[1,1,1],[1,1,2],[1,2,0],[1,2,1],[1,2,2],[2,1,0],[2,1,1],[2,1,2],[2,2,0],[2,2,1],[2,2,2],[1,0],[1,1],[1,2],[2,0],[2,1],[2,2],[0],[1],[2]];

#(0,1,1)
#sort by (depth ascending, then index ascending). (Common)
#[[0],[1],[2],[1,0],[1,1],[1,2],[2,0],[2,1],[2,2],[1,1,0],[1,1,1],[1,1,2],[1,2,0],[1,2,1],[1,2,2],[2,1,0],[2,1,1],[2,1,2],[2,2,0],[2,2,1],[2,2,2]];

#(1,0,0)
#sort by (index decending, then depth decending).
#[[2,2,2],[2,2,1],[2,2,0],[2,2],[2,1,2],[2,1,1],[2,1,0],[2,1],[2,0],[2],[1,2,2],[1,2,1],[1,2,0],[1,2],[1,1,2],[1,1,1],[1,1,0],[1,1],[1,0],[1],[0]];

#(1,0,1)
#sort by (index decending, then depth ascending).
#[[2],[2,2],[2,2,2],[2,2,1],[2,2,0],[2,1],[2,1,2],[2,1,1],[2,1,0],[2,0],[1],[1,2],[1,2,2],[1,2,1],[1,2,0],[1,1],[1,1,2],[1,1,1],[1,1,0],[1,0],[0]];

#(1,1,0)
#Sort by (index ascending, then depth decending): (Common)
#[[0],[1,0],[1,1,0],[1,1,1],[1,1,2],[1,1],[1,2,0],[1,2,1],[1,2,2],[1,2],[1],[2,0],[2,1,0],[2,1,1],[2,1,2],[2,1],[2,2,0],[2,2,1],[2,2,2],[2,2],[2]];

#(1,1,1)
#Sort by (index ascending, then depth ascending): (Common)
#[[0],[1],[1,0],[1,1],[1,1,0],[1,1,1],[1,1,2],[1,2],[1,2,0],[1,2,1],[1,2,2],[2],[2,0],[2,1],[2,1,0],[2,1,1],[2,1,2],[2,2],[2,2,0],[2,2,1],[2,2,2]];


=cut

# implementation note:

# Dependent functions: _indexOrdering

# misc notes: this function needs heavy testing. The speed can also be improved greatly by eleminating the inner loop in the sort, using Swatze transform technique instead. Basically: convert all indexes to same length strings, and sort this string. xxxxx'

#push (@EXPORT, q(IndexSetSort));
#push (@EXPORT_OK, q(IndexSetSort));

# _indexOrdering([a1,a2,...],[b1,b2,...]) returns -1, 0, or 1 by comparing the number sequence in each array reference from left to right. If both begins with the same sequence, then it returns 0. The length of the arrays has no effect. Example: print "@{[_indexOrdering([2,2],[2,3,3])]}";
sub _indexOrdering ($$) {
my @array1 = @{$_[0]};
my @array2 = @{$_[1]};

my $minLength;
if (scalar @array1 < scalar @array2) {$minLength = scalar @array1}
else {$minLength = scalar @array2};

for my $i (0..$minLength -1) {
	if ($array1[$i] <=> $array2[$i]) {return $array1[$i] <=> $array2[$i];}
};

return 0;
};


sub IndexSetSort ($;$$$) {
if (scalar @_ == 1) {return _indexSetSortFullArguments($_[0],0,1,1);};
if (scalar @_ == 2) {return _indexSetSortFullArguments($_[0],$_[1],1,1);};
if (scalar @_ == 3) {return _indexSetSortFullArguments($_[0],$_[1],$_[2],1);};
return _indexSetSortFullArguments(@_);
};


#_indexSetSortFullArguments([index1, index2,...], sortByIndexFirstQ, indexAscendingQ, lengthAscendingQ)
sub _indexSetSortFullArguments ($$$$) {
my @indexList = @{$_[0]};
my $sortByIndexFirstQ = $_[1];
my ($indexAscendingQ, $lengthAscendingQ) = ($_[2],$_[3]);

if ($sortByIndexFirstQ) {
	if ($indexAscendingQ) {
		if ($lengthAscendingQ) {@indexList = sort {_indexOrdering($a,$b) || scalar @{$a} <=> scalar @{$b} } @indexList;}
		else {@indexList = sort {_indexOrdering($a,$b) || scalar @{$b} <=> scalar @{$a} } @indexList;}
	}
	else {
		if ($lengthAscendingQ) {@indexList = sort {_indexOrdering($b,$a) || scalar @{$a} <=> scalar @{$b} } @indexList;}
		else {@indexList = sort {_indexOrdering($b,$a) || scalar @{$b} <=> scalar @{$a} } @indexList;}
	};
}
else {
	if ($indexAscendingQ) {
		if ($lengthAscendingQ) {@indexList = sort {scalar @{$a} <=> scalar @{$b} || "@{$a}" cmp "@{$b}"} @indexList;}
		else {@indexList = sort {scalar @{$b} <=> scalar @{$a} || "@{$a}" cmp "@{$b}"} @indexList;}
	}
	else {
		if ($lengthAscendingQ) {@indexList = sort {scalar @{$a} <=> scalar @{$b} || "@{$b}" cmp "@{$a}" } @indexList;}
		else {@indexList = sort { scalar @{$b} <=> scalar @{$a} || "@{$b}" cmp "@{$a}" } @indexList;}
	};
};

return \@indexList;

};

#_____ Map _____ _____ _____ _____

=pod

B<Map>

Map(f, tree) returns the result of applying f to tree. f must be an reference to a subroutine or anonymous function. For example: Map( sub {$_**2;}, [9,2,5]); returns [81,4,25]. Map(f, tree) is similar to Perl's "map".

Map(f, tree, levelSpec) maps f to nodes specified by levelSpec. Map(f, tree) is equivalent to Map(f, tree, [1]). The general form of levelSpec is [m,n]. f is applied to the tree in the same order as in Level. That is, commonly known as "depth first". See Level for detail about levels and levelSpec.

The most common use of Map is applying a function to a specific level of a tree. For example, Map( $func , $tree, [3]) will return a modified $tree, where all nodes at level 3 are transformed by having $func applied to them. Map( $func , $tree, [-1]) will apply $func to all the leaves of the tree.
 
Related: xxxxx, Apply, MapIndexed, MapAll, MapThread.

Example:

 Map( sub {$_[0]**2;}, [1,2,3,4]); # returns [1,4,9,16].

 Map( sub {$_[0]**2;}, [1,2,3,4], [1]); # returns [1,4,9,16].

 Map( sub {$_[0]**2;}, [[1],[2],[3]], [2]); # returns [[1],[4],[9]].
 # The levelSpec [-1] specified all the atoms/leaves of the tree.

 Map( sub {$_[0]**2;}, [7,[3],[5]], [-1]); # returns [49,[9],[25]].
 
 xxxxxx Needs more examples. Need examples that uses multiple levels, and practical examples showing the usefulness of Map.

=cut

# implementation note: See the implementation note for Level.
# Dependent functions: _treeToIndexSet, _completeIndexSet, _indexSetSortFullArguments, _nodeDepth.

#push (@EXPORT, q(Map));
#push (@EXPORT_OK, q(Map));

sub Map ($$;$) {
# input checks here...
return _map(@_);
};

sub _map ($$;$) {
# this function generates full arguments for Map, then pass it to _mapWithFullArgs.
	if (scalar @_ == 2) {return _mapWithFullArgs( @_, [1,1])}
	else { # _map is passed 3 arguments here.
		if ( ref $_[2] eq 'ARRAY') { # last arg is an array
    	if (scalar @{$_[2]}==1) { # the level spec has the form [n].
    		return _mapWithFullArgs($_[0], $_[1], [$_[2]->[0], $_[2]->[0] ]); }
			else {return _mapWithFullArgs( @_ ); };
  	}
  	else {return _mapWithFullArgs( @_, [1, $_[2]]); };
	};
};

# form: _mapWithFullArgs($function, $tree, $levelSpecFullForm).
sub _mapWithFullArgs ($$$) {
my $ref_func = $_[0];
my $ref_tree = $_[1];
my ($A, $B) = @{$_[2]};

my ($a, $b) =(abs $A, abs $B);
my $ref_completeIndexSet = _indexSetSortFullArguments( _completeIndexSet([map {$_ = $_->[0];} @{ _treeToIndexSet($ref_tree)}]),1,1,0);
my $predicateString =
($A >= 0 ?
 ($B >= 0 ?
  '((scalar @{$_} >= $a) and ( scalar @{$_} <= $b))':
  '((scalar @{$_} >= $a) and ( _nodeDepth($ref_completeIndexSet, $_) >= $b))'
 ):
 ( $B >= 0 ?
  '((_nodeDepth($ref_completeIndexSet, $_) <= $a) and (scalar @{$_} <= $b))':
  '(( _nodeDepth($ref_completeIndexSet, $_) <= $a) and ( _nodeDepth($ref_completeIndexSet, $_) >= $b))'
 )
);
foreach my $ref_index (grep {eval $predicateString} @{$ref_completeIndexSet}) {
# $treePartsString has the form: e.g. '$ref_tree->[n1]->[n2]'
my $treePartsString = '$ref_tree' . join('', (map {"->[$_]"} @$ref_index));
eval("$treePartsString" . ' = &{$ref_func}' . "($treePartsString)");
};

return $ref_tree;
};

#end Map

#----------------------
# testing

print Dumper
 Map( sub {$_[0]**2;}, [[1],[2],[3]], [2]); # [[1],[4],[9]]


__END__

