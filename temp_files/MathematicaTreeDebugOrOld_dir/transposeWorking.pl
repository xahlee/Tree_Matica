#!/usr/local/bin/perl5 -w

# testing testing.

#-----------------------

#use lib qw(APS318User:T2:perl_dir:perlModules_dir:);
#use MathematicaTree;
use strict;
#use English;
#use Benchmark;
#require 'dumpvar.pl';
use Data::Dumper; $Data::Dumper::Indent=0; $Data::Dumper::Deepcopy=1;

#-----------------------

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



#_____ Transpose _____ _____ _____ _____

=pod

B<Transpose>

Transpose(tree) returns a result that is the given tree with the first two levels transposed. e.g. Transpose( [[1,2,3],['a','b','c']] ) returns [[1,'a'],[2,'b'],[3,'c']].

Transpose(tree, permutationList) transposes the tree according to permutationList of the form [n1,n2,...,nm], where each n_i is a unique positive integer from 1 to m. Transpose( [[1,2,3],['a','b','c']] ) is equivalent to Transpose( [[1,2,3],['a','b','c']], [2,1] ).

Transpose essentially restructures a tree into a different shape. Here are some explanations, examples follows at the end. First, we'll use a simple example to illustrate. Suppose we have $tree = [[1,2,3],['a','b','c']] and $permutationList = [2,1]. The elements at level two of the tree have these position indexes:

 element    position index
    1            [0,0]
    2            [0,1]
    3            [0,2]
   'a'           [1,0]
   'b'           [1,1]
   'c'           [1,2]

Since the length of $permutationList is two, thus Transpose will reshape the tree at level two. For each node, Transpose will apply the given permutation to its position index. Here's the result:

 element    position index
    1            [0,0]
    2            [1,0]
    3            [2,0]
   'a'           [0,1]
   'b'           [1,1]
   'c'           [2,1]

Transpose then construct a tree by this new element/index pair. The result is [[1,'a'],[2,'b'],[3,'c']]. Because transposition with permutation [2,1] is common (matrix computations), thus it is the default behavior for Transpose with just one argument.

The given tree needs to be a rectangular array only up to the level m, where m is the length of the specified permutation. For example, suppose we have $tree = [[1,2,3],[$anotherTree,'b','c']] and $permutationList = [2,1]. It all works just as before, except that the element 'a' is substituted by $anotherTree. For example, Transpose([[ 1,2,3],[ ['m','n'] ,'b','c']], [2,1]) returns [[1,['m','n']],[2,'b'],[3,'c']].

Longer permutations also works similarly. For example, suppose

$tree = [ [['x1','x2'],['y1','y2'],['z1','z2']], [ ['a1','a2'] ,['b1','b2'], ['c1','c2']]];
$permutationList = [3,1,2];

Since the length of $permutationList is 3, thus looking at level 3 of the tree we have

 element    position index
           before /  after permute by [3,1,2]
   'x1'    [0,0,0]  [0,0,0]
   'x2'    [0,0,1]  [1,0,0]
   'y1'    [0,1,0]  [0,0,1]
   'y2'    [0,1,1]  [1,0,1]
   'z1'    [0,2,0]  [0,0,2]
   'z2'    [0,2,1]  [1,0,2]
   'a1'    [1,0,0]  [0,1,0]
   'a2'    [1,0,1]  [1,1,0]
   'b1'    [1,1,0]  [0,1,1]
   'b2'    [1,1,1]  [1,1,1]
   'c1'    [1,2,0]  [0,1,2]
   'c2'    [1,2,1]  [1,1,2]

Therefore, the result is [[['x1','y1','z1'],['a1','b1','c1']],[['x2','y2','z2'],['a2','b2','c2']]].

There are some implied restrictions on the input to Transpose:
1. The second argument must be a permutation of a range of m numbers that starts with one.
2. The tree must be a rectangular array up to level m. That is, Length(Dimensions($tree)) >= m.

A property of Transpose:
If $tree is a rectangular array, then the following is always true.
Permute(Dimensions($tree), $permutationList) == Dimensions(Transpose($tree, $permutationList))

If $tree is a rectangular array up to level m only, then the left and right hand side agrees up to the first m numbers.

Example:

my $tree =
[
	[ ['x1','x2'], ['y1','y2'], ['z1','z2']],
	[ ['a1','a2'], ['b1','b2'], ['c1','c2']]
];

Transpose( $tree, [1, 2, 3]);
# returns [[['x1','x2'],['y1','y2'],['z1','z2']],[['a1','a2'],['b1','b2'],['c1','c2']]]

Transpose( $tree, [1, 3, 2]);
# returns [[['x1','y1','z1'],['x2','y2','z2']],[['a1','b1','c1'],['a2','b2','c2']]]

Transpose( $tree, [2, 1, 3]);
# returns [[['x1','x2'],['a1','a2']],[['y1','y2'],['b1','b2']],[['z1','z2'],['c1','c2']]]

Transpose( $tree, [2, 3, 1]);
# returns [[['x1','a1'],['x2','a2']],[['y1','b1'],['y2','b2']],[['z1','c1'],['z2','c2']]]

Transpose( $tree, [3, 1, 2]);
# returns [[['x1','y1','z1'],['a1','b1','c1']],[['x2','y2','z2'],['a2','b2','c2']]]

Transpose( $tree, [3, 2, 1]);
# returns [[['x1','a1'],['y1','b1'],['z1','c1']],[['x2','a2'],['y2','b2'],['z2','c2']]]

=cut

# Permute([$e1, $e2,...], $ref_permutationList) permutes the first argument by the specifed permutation. e.g. Permute (['a',2,3,4,5],[3,2,5,4,1]).
sub Permute ($$) {
my $ref_list = $_[0];
my $ref_perm = $_[1];

my @result;
for (my $i = 0; $i <= $#{$ref_list}; $i++) {
$result[$i] = $ref_list->[$ref_perm->[$i] -1];
};
return \@result;
};

#push (@EXPORT, q(Transpose));
#push (@EXPORT_OK, q(Transpose));

# implementation note:
# plan: 
# check validity of arguments.
# get a complete index set of the tree.
# select the indexes that are on the right level.
# reassign the nodes, using the form $ref_resultTree->[n1][n2] = $ref_tree->[n2][n1].

# Dependent functions: _treeToIndexSet, _completeIndexSet, Permute.

sub Transpose ($;$) {
# input checks here...
return _transpose(@_);
};

sub _transpose ($;$) {
# this function adds the optional arg, then pass it to _transposeFullArgs.
  if ( scalar @_ == 1) {return _transposeFullArgs( $_[0], [2,1]);}
  else {return _transposeFullArgs(@_);};
};

sub _transposeFullArgs ($$) {
my $ref_tree = $_[0];
my $ref_perm = $_[1];

my $transposeLevel = scalar @$ref_perm;
my $ref_completeIndexSet = [grep {scalar @$_ == $transposeLevel} @{ _completeIndexSet([map {$_ = $_->[0];} @{ _treeToIndexSet($ref_tree)}]) }];

my $ref_resultTree;
foreach my $ref_index (@$ref_completeIndexSet) {
	eval(
	'$ref_resultTree' . join('', (map {"->[$_]"} @{Permute($ref_index, $ref_perm)})) . '=' .
	'$ref_tree' . join('', (map {"->[$_]"} @$ref_index)) . ';'
	);
};

return $ref_resultTree;
};

#end Transpose


#-------------------------------
#testing


my $tree = [ [['x1','x2'],['y1','y2'],['z1','z2']], [ ['a1','a2'] ,['b1','b2'], ['c1','c2']]];

print Dumper _transpose( $tree, [1, 2, 3]);
print Dumper _transpose( $tree, [1, 3, 2]);
print Dumper _transpose( $tree, [2, 1, 3]);
print Dumper _transpose( $tree, [2, 3, 1]);
print Dumper _transpose( $tree, [3, 1, 2]);
print Dumper _transpose( $tree, [3, 2, 1]);
print Dumper _transpose( $tree, [2, 1]);

__END__

