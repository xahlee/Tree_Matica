
=pod

=head1 NAME

Tree::Matica - A Perl package for expression structure based functional programing.

=head1 SYNOPSIS

 # importing all functions. Recommended.
 use Tree::Matica;

 # importing a selection of functions.
 use Tree::Matica ('functionName1', 'functionName2', ...);

=head1 DESCRIPTION

This package provides about 30 functions for creating and manipulating trees. (tree as nested lists) These functions include tree constructors, selectors, mutators, structure transformers and a set of functions usually found in functional programing languages. Together they form a consistent way of functional programing on trees -- a paradigm often used in Lisp programing. These functions are modeled after the Mathematica language. (Mathematica is a trademark of Wolfram Research, Inc.)

Perl provides nested lists using references. Familiarity with Perl references is necessary in using this module. See the "See Also" section at the bottom for helpful references.

In this documentation, a tree will mean a nested lists of the form [[...],...]. In other words, when you read "...f(tree) does xxx.", it means the argument to f is a reference to a list. Anything in the tree that is not an array reference is considered an atom. Atoms should be either numbers or strings. Other data types such as hash, tie, typeglob, handle, reference to anything other than array, are not expected.

The following is a list of functions that can be exported, followed by detailed documentation.

=over

=item Tree constructors

Range, Table

=item Tree measurers

Depth, LeafCount, NonleafCount, NodeCount, Dimensions

=item Branchs and Nodes Extractors

Part, Level

Possible Addition: Extract, Take, Drop, Rest, First, Last, Cases, DeleteCases.

=item Structure Transformation

Transpose, FlattenAt

Unimplemented: Distribute, Thread, Operate, Flatten, Sequence.

=item Functions on Flat Lists

RotateLeft

Unimplemented: Union, Intersection, Complement, Append, Prepend, Join, Partition, Split

=item Funtional Programing Tools

Function

=item Function on Trees

Map

Unimplemented: Apply, MapIndexed, MapAll, MapThread, Nest, NestList, FixedPoint, FixedPointList, Fold, FoldList, Outer, Inner, Cross.

=item Tree Index Set Utilities

RandomIndexSet, LeavesIndexSet, NonleavesIndexSet, MinimumIndexSet, CompleteIndexSet, IndexSetSort, TreeToIndexSet, IndexSetToTree

=item Miscellaneous Functions

UniqueString, RandomInteger, RandomReal

=item Internal Functions

_iteratorFullForm,
_lengthOfIterator,
_rangeSequence,
_postIncrement,
_equalNumericalArrayQ,
_nonleafQ,
_inferableIndexQ,

_rangeFullArgsWithErrorCheck,
_rangeWithGoodArgs,

_randomIndexSetFullArguments,
_indexOrdering,

_indexSetSortFullArguments
 
=back

=head1 Detailed Documentation

=cut


#----------------program starts here------------

package Tree::Matica;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);
use POSIX qw(ceil floor);
use Exporter;

@ISA = qw(Exporter);

#EXPORT and EXPORT_OK list will be added one by one below.
@EXPORT = ();
@EXPORT_OK = ();

$VERSION = q(0.01);

#_____ some internal functions _____ _____ _____ _____

# _iteratorFullForm($ref_iterator) returns the full form of $ref_iterator.
#For example
#_iteratorFullForm([3]) returns [1,3,1].
#_iteratorFullForm([2,5]) returns [2,5,1].
#_iteratorFullForm([2,10,3]) returns [2,10,3].
#_iteratorFullForm does not check the validity of argument. For example _iteratorFullForm(-5) will return [1,-5,1].

# Dependent functions: (none).

sub _iteratorFullForm ($) {
if (scalar(@{$_[0]}) == 1) {return [1,@{$_[0]}[0],1];}
elsif (scalar(@{$_[0]}) == 2) {return [@{$_[0]}[0],@{$_[0]}[1],1];}
else {return $_[0];};
};

# _lengthOfIterator($ref_iterator) returns the length of list specified by $ref_iterator. An $ref_iterator has the form [n], [n,m], or [n,m,step]. _lengthOfIterator returns the number of elements in Range(@{$ref_iterator}) without actually generating the range and counting.
# Example: _lengthOfIterator([3,10,2]) returns 4.
# _lengthOfIterator assumes that the argument is a valid iterator. i.e. that the boundary makes sense. e.g. [1,-5,1] is a bad one.
# Dependent Functions: _iteratorFullForm, floor.
sub _lengthOfIterator ($) {
my ($a1,$b1,$dx) = @{_iteratorFullForm( $_[0] )};
return floor( ($b1 - $a1) / $dx) +1;
};

# _rangeSequence($ref_iteratorList) returns a sequence of ranges. For example, _rangeSequence([[-5,10,6],[3],[7,10]]) returns [[-5, 1, 7], [1, 2, 3], [7, 8, 9, 10]]. 
# Dependent functions: Range.
sub _rangeSequence ($) {
my $ref_iteratorList = $_[0];

my @result;
foreach my $ref_iterator (@$ref_iteratorList) {push(@result, Range(@$ref_iterator))};
return \@result;
};

# _postIncrement($variable, n) will return the value of $variable, then increment it by n. It is similar to the =+ operator in some languages.
sub _postIncrement ($$) { my $dummy = $_[0]; $_[0] += $_[1]; return $dummy;};


# _equalNumericalArrayQ($ref_array1, $ref_array2) returns true (1) if two one-dimentional numerical arrays are equal, else false (0).
#$ref_array must be of the form [n1,n2,...] where n are numbers. Example: _equalNumericalArrayQ([1,2,3],[1,2,3]) returns 1.

sub _equalNumericalArrayQ ($$) {
my $ref_array1 = $_[0];
my $ref_array2 = $_[1];

if (scalar @{$ref_array1} != scalar @{$ref_array2}) {return 0;};

for (my $i = 0; $i <= scalar (@{$ref_array1}) -1; $i++) {if (@{$ref_array1}[$i] != @{$ref_array2}[$i]) {return 0;}; };

return 1;
};

# _nonleafQ($indexA,$indexB) returns 1 if $indexB is longer than $indexA and starts with elements of $indexA. i.e. $indexA is a non-leaf.
#$indexA and B must have the form [n1,n2,...], where n are non-negative integers. Example: _nonleafQ([1,2,7],[1,2,7,3]) returns 1. _nonleafQ([1,2,7],[1,2,7]) returns 0.

# when _nonleafQ returns true, it means that $indexA is a non-leaf with respect to $indexB, and $indexB is a leaf with respect to $indexA. When _nonleafQ returns false, nothing can be proven.

sub _nonleafQ ($$) {
my @indexA = @{$_[0]};
my @indexB = @{$_[1]};
if (scalar @indexA >= scalar @indexB) {return 0};
foreach my $i (0 .. $#indexA) {if ($indexA[$i] != $indexB[$i]) {return 0;};};
return 1;
};

# _inferableIndexQ($indexA,$indexB) returns 1 if $indexB implies $indexA.
# indexA is inferable if one the following are met:
# 1. B begins with all the components of A. (meaning that B is an offspring of A.)
# 2. A and B have the same length, they only differ in their last component, and A[-1] <= B[-1]. (meaning that A and B are siblings and B is older.)
# Suppose indexA = {a,b,c,d}. Then it is inferable if MatchQ[indexB, {a,b,c,x$_/;x$ > d}|{a,b,c,x$_/;x$ >= d,__}]. If indexA == indexB, we also say it's inferable.
# $indexA and B must have the form [n1,n2,...], where n_i is non-negative integer.
# Examples: the following are all true:
# _inferableIndexQ([3,2],[3,2]);
# _inferableIndexQ([3,2],[3,3]);
# _inferableIndexQ([3,2],[3,2,0]);
# _inferableIndexQ([3,2],[3,2,2,4]);
# the following are false:
# _inferableIndexQ([3,2],[4]);
# _inferableIndexQ([3,2],[3,1]);
# _inferableIndexQ([3,2],[3,1,5]);

sub _inferableIndexQ ($$) {
my @indexA = @{$_[0]};
my @indexB = @{$_[1]};

# if length of indexA is greater then indexB, then indexA is not inferable.
if (scalar @indexA > scalar @indexB) {return 0};

# if the first few of indexA are not the same as indexB, then indexA is not inferable.
foreach my $i (0 .. $#indexA -1) {if ($indexA[$i] != $indexB[$i]) {return 0;};};

if ($indexA[-1] <= $indexB[$#indexA]) {return 1;};

return 0;
};


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


# _offspringIndexSet(indexSetS, indexA) returns elements of indexSetS that are offsprings of indexA.
# syntax: _offspringIndexSet([[a1,a2,...],[b1,b2,...],...], [n1,n2,...]).
# detail: it returns all the indexes in indexSetS that starts with the same component as indexA, including itself.
# note: _offspringIndexSet($ref_tree,[]) also works; it returns $ref_tree unchanged.
sub _offspringIndexSet ($$) {
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

return \@indexSet;
};

=pod

=head2 Tree constructors

=cut

#_____ Range _____ _____ _____ _____

=pod

B<Range>

Range($iMax) generates the list [1, 2, ... , $iMax].

Range($iMin, $iMax) generates the list [$iMin, ... , $iMax].

Range($iMin, $iMax, $iStep) uses increment $iStep, with the last element in the result being less or equal to $iMax. $iStep cannot be 0. If $iStep is negative, then the role of $iMin and $iMax are reversed.

If Range fails, 0 is returned.

Example:

 Range(5); # returns [1,2,3,4,5]

 Range(5,10); # returns [5,6,7,8,9,10]

 Range( 5, 7, 0.3); # returns [5, 5.3, 5.6, 5.9, 6.2, 6.5, 6.8]

 Range( 5, -4, -2); # returns [5,3,1,-1,-3]

=cut

push (@EXPORT, q(Range));
push (@EXPORT_OK, q(Range));

sub Range ($;$$) {
if (scalar @_ == 1) {return _rangeFullArgsWithErrorCheck(1,$_[0],1);};
if (scalar @_ == 2) {return _rangeFullArgsWithErrorCheck($_[0],$_[1],1);};
if (scalar @_ == 3) {return _rangeFullArgsWithErrorCheck($_[0],$_[1],$_[2]);};
};

sub _rangeFullArgsWithErrorCheck ($$$) {
my ($a1, $b1, $dx) = @_;

if ($dx == 0) {print "Range: increment cannot be zero."; return 0}
elsif ($a1 == $b1) {return [$a1];}
elsif ( ((($b1 - $a1) > 0) && ($dx < 0)) || ((($b1 - $a1) < 0) && ($dx > 0)) ) {print "Range: bad arguments. You have [$a1,$b1,$dx]"; return 0;}
elsif ((($a1 < $b1) && ($b1 < ($a1 + $dx))) || (($a1 > $b1) && ($b1 > ($a1 + $dx)))) {return [$a1];}
else { return _rangeWithGoodArgs ($a1,$b1,$dx);};
};

sub _rangeWithGoodArgs ($$$) {
my ($a1, $b1, $dx) = @_;
my @result;

if ($a1 < $b1) {for (my $i = $a1; $i <= $b1; $i += $dx) { push (@result, $i);}; }
else {for (my $i = $a1; $i >= $b1; $i += $dx) { push (@result, $i);}; };
return \@result;
};

#end Range

#_____ Table _____ _____ _____ _____

=pod

B<Table>

Table('exprString', [iMax]) generates a list of iMax copies of value of eval('exprString'), and returns the refence to the list. i.e. [eval('exprString'),eval('exprString'),...]

Table('exprString', ['i', iMax]) generates a list of the values by evaluating 'exprString' when 'i' in the string runs from 1 to iMax.

Table('exprString', ['i', iMin, iMax]) starts with 'i' = iMin.

Table('exprString', ['i', iMin, iMax, iStep]) uses steps iStep. If iStep is negative, then the roll of iMin and iMax are reversed. Inputs such as [1, -3 , 1] returns bad result.

Table('exprString', ['i', iMin, iMax, iStep], ['j', jMin, jMax, iStep], ... ) gives a array by iterating 'i', 'j' in 'exprString'. For example, Table('f(i,j)', ['i',1,3], ['j',5,6]) returns [[f(1, 5), f(1, 6)], [f(2, 5), f(2, 6)], [f(3, 5), f(3, 6)]].

In general, Table has the form Table('expressionString', iterator1, iterator2, ...) where 'expressionString' is a string that will be evaluated by eval. iterator have one of the following forms [iMax], ['dummyVarString',iMax], ['dummyVarString',iMin, iMax], or ['dummyVarString',iMin, iMax, iStep].

If Table fails, 0 is returned. Table can fail, for example, when the argument are not appropriate references or the iterator range is bad such as ['i',5,1].

Example:

 Table('q(s)' ,[3]); # returns ['s','s','s']

 Table( 'i**2' , ['i', 4]); # returns [1, 4, 9, 16]

 Table('[i,j,k]',['i',2],['j',100,200,100],['k',5,6])
 # returns [[[[1,100,5],[1,100,6]],[[1,200,5],[1,200,6]]],
 #          [[[2,100,5],[2,100,6]],[[2,200,5],[2,200,6]]]]

=cut

# implementation note:
# gist: Generate a nested foreach loop, then evaluate this loop to get the result.

# First, get some basic info:

# @parameterList is of the form: ('i','j',...). If non exists, then a unique string is inserted. For example, if input is Table('expr',['i',4],[3]), then @parameterList is ('i','unik293');
# @iteratorList is of the form ([1,3],[2],[-2,7,3],...). It is the iterators without the dummy variable (if exists).
# $ref_rangeSequence is of the form [[1,...3],[1,...2],...]. It is the iterator expanded.

# Now, generate $stringToBeEvaluated. It has the following form (sample):

#foreach $h (0 .. scalar(@{$ref_rangeSequence->[0]}) -1 ) {
#foreach $unik5926 (0 .. scalar(@{$ref_rangeSequence->[1]}) -1 ) {
#foreach $gg (0 .. scalar(@{$ref_rangeSequence->[2]}) -1 ) {
#$resultArray[$h][$unik5926][$gg] = &{Function(\@parameterList,$exprString)} #($ref_rangeSequence->[0]->[$h],$ref_rangeSequence->[1]->[$unik5926],$ref_rangeSequence->[2]->[$gg],); 
#};};};

# Dependent functions: UniqueString, _rangeSequence, Function.


push (@EXPORT, q(Table));
push (@EXPORT_OK, q(Table));

sub Table ($;@) {
my $exprString = shift(@_);
my @iteratorList = @_;

my $depth = scalar(@iteratorList);
my @parameterList = ();

# set @parameterList and @iteratorList.
foreach my $ref_iterator (@iteratorList) {
if (scalar(@$ref_iterator) == 1) { push(@parameterList, ${UniqueString($exprString,1)}[0]);}
else { push(@parameterList, shift(@$ref_iterator));};
};

# Now, @parameterList is of the form ('i','j',...).
# Now, @iteratorList is of the form ([1,3],[2],[-2,7,3],...).

# $ref_rangeSequence is of the form [[1,...3],[1,...2],...].
my $ref_rangeSequence = _rangeSequence(\@iteratorList);

my $stringToBeEvaluated;
# generate a declaration of all the symbols. e.g. 'my ($i,$j,...); my @resultArray';
$stringToBeEvaluated .= 'my (';
foreach my $variable (@parameterList) {$stringToBeEvaluated .= '$' . $variable . ','};
$stringToBeEvaluated .= "); \n";
$stringToBeEvaluated .= 'my @resultArray;' . "\n\n";

#generate the beginning of for loops, $depth number of times. e.g. 'for $i (1..10) {'
	for my $i (0 .. $depth-1) {
	$stringToBeEvaluated .= 'foreach $' . $parameterList[$i] .
	' (0 .. scalar(@{$ref_rangeSequence->[' . $i . ']}) -1 ) {' . qq(\n);
	};
	
#generate the heart of the loop. e.g. $array[$i][$j]... = f($i,$j,...);
	$stringToBeEvaluated .= '$resultArray';
	foreach my $variable (@parameterList) {$stringToBeEvaluated .= '[$' . $variable . ']';};
	$stringToBeEvaluated .= ' = &{Function(\@parameterList,$exprString)} (';
	for (my $i=0; $i<$depth; $i++) {$stringToBeEvaluated .=  '$ref_rangeSequence->[' . $i .
	']->[$' . $parameterList[$i] . '],'
	};
	$stringToBeEvaluated .= "); \n";
	
#generate the ending of loops, $depth number of times. e.g. '};'
	$stringToBeEvaluated .= '};' x $depth . "\n\n";
	$stringToBeEvaluated .=  'return \@resultArray;';

#	debugging lines:
#	print qq(\$exprString is: $exprString\n);
#	print "\@parameterList is: @parameterList\n";
#	foreach my $ref_iterator (@iteratorList) {print "@\$ref_iterator is: @$ref_iterator\n"};
#	dumpValue($ref_rangeSequence);
#	print "\n\n-----------------\n\n$stringToBeEvaluated------------\n";

#evaluate the stringToBeEvaluated to obtain the array. Return the result.
eval($stringToBeEvaluated);
};

#end Table

=pod

=head2 Tree Measurers

=cut

#_____ Depth _____ _____ _____ _____

=pod

B<Depth>

Depth(tree) returns a positive integer: the maximum number of indexes needed to specify any part of given tree.

The argument must be a reference to a nested list.

Related: LeafCount, NonleafCount, NodeCount, Dimensions.

Example:

 Depth([]); # returns 0.
 
 Depth([5,98,'x']); # returns 1.

 Depth([ 'level1' , ['level2', [ 'level3', [ 'level4']]], ['lev1']]);
 # returns 4.

=cut

# implementation note:
# Dependent functions: _treeToIndexSet.

push (@EXPORT, q(Depth));
push (@EXPORT_OK, q(Depth));

sub Depth ($) {return _depth($_[0]);};

sub _depth ($) {
my @positionIndexList = @{ _treeToIndexSet($_[0])};

my $result = 0;
foreach my $ref_index (@positionIndexList) {
my $currentDepth = scalar @{$ref_index->[0]};
if ($result < $currentDepth) {$result = $currentDepth;};
};

return $result;
};


#_____ LeafCount _____ _____ _____ _____

=pod

B<LeafCount>

LeafCount(tree) returns the number of leaves in a tree.

The argument must be a reference to a nested list. (i.e. [[...],...]) An atom is anything in the tree that is not an array reference. (should be either numbers or strings only.)

Related: NonleafCount, NodeCount, Depth, Dimensions.

Example:

 LeafCount([]); # returns 0.
 
 LeafCount([5,98,'x']); # returns 3.

 LeafCount([['1', [ '2', [ 3, '4']]], [ [5], '6']]);
 # returns 6.

=cut

# implementation note:
# Dependent functions: _treeToIndexSet.

push (@EXPORT, q(LeafCount));
push (@EXPORT_OK, q(LeafCount));

sub LeafCount ($) {return _leafCount($_[0]);};

sub _leafCount ($) {return scalar @{ _treeToIndexSet($_[0])};};


#_____ NonleafCount _____ _____ _____ _____

=pod

B<NonleafCount>

NonleafCount(tree) returns a the number of non-leaf nodes in a tree (root is also a non-leaf node).

The argument must be a reference to a nested list. (i.e. [[...],...]) An atom is anything in the tree that is not an array reference. (should be either numbers or strings only.)

It is always true that NodeCount(tree) == NonleafCount(tree) + LeafCount(tree).

Related: LeafCount, NodeCount, Depth, Dimensions.

Example:

 NonleafCount([]); # returns 0.
 
 NonleafCount([5,98,'x']);
 # returns 1, because this is a tree with three branches from the root,
 # and each branch is a leaf. The only non-leaf node is the root.

 NonleafCount([['a','b'],['c','d']]);
 # returns 3. This tree has two nodes from the root, each has two nodes.

 NonleafCount([['a']]);
 # returns 2.

=cut

# implementation note:
# misc note: this function may be re-written for speed improvement. Currently, it is done by finding the length of non-leaves index set of a complete index set of the argument. Perhaps the count can be derived from the leaves index set directly.
# Dependent functions: _treeToIndexSet NonleavesIndexSet CompleteIndexSet.

push (@EXPORT, q(NonleafCount));
push (@EXPORT_OK, q(NonleafCount));

sub NonleafCount ($) {return _nonleafCount($_[0]);};

sub _nonleafCount ($) {return scalar @{ _nonleavesIndexSet( CompleteIndexSet( [map {$_ = $_->[0]} @{ _treeToIndexSet($_[0])} ]));};};


#_____ NodeCount _____ _____ _____ _____

=pod

B<NodeCount>

NodeCount(tree) returns the number of nodes in a tree. It is always true that NodeCount(tree) == NodeCount(tree) + LeafCount(tree).

Related: LeafCount, NonleafCount, Depth, Dimensions

Example:

 NodeCount([]); # returns 0.
 
 NodeCount([5,98,'x']);
 # returns 4, because this is a tree with three branches plus the root.

 NodeCount([['a','b'],['c','d']]);
 # returns 7.

 NodeCount([['a']]);
 # returns 3.

=cut

# implementation note:
# misc note: this function may be re-written for speed improvement. Currently, it is done by finding the length of non-leaves index set of a complete index set of the argument. Perhaps the count can be derived from the leaves index set directly.
# Dependent functions: _treeToIndexSet CompleteIndexSet.

push (@EXPORT, q(NodeCount));
push (@EXPORT_OK, q(NodeCount));

sub NodeCount ($) {return _nodeCount($_[0]);};

sub _nodeCount ($) {return scalar @{ CompleteIndexSet( [map {$_ = $_->[0]} @{ _treeToIndexSet($_[0])} ]);};};


#_____ Dimensions _____ _____ _____ _____

=pod

B<Dimensions>

Dimensions(tree) returns a reference to a list of the form [n_1, n_2, ..., n_i, ...], where every node at ith level of the given tree has n_(i+1) children. For example, [[['a'],['b'],['c']],[[1],[2],[3]]] has dimensions [2,3,1]. In other words, Dimensions returns a list of m items if the argument is an m-dimentional (rectangular) array.

Related: Depth, NonleafCount, LeafCount, NodeCount.

Example:

 Dimensions([]); # returns [].

 Dimensions([5,98,'x']); # returns [3].

 Dimensions([['a','b','c'],[1,2,3]]); # returns [2,3].

 Dimensions([[['a'],['b'],['c']],[[1],[2],[3]]]); # returns [2,3,1].

 Dimensions([['a','b','c'],[1,2]]); # returns [2].

=cut

# implementation note:
# general plan: set up three variables and have a recursor function to do a loop, for each loop travel all nodes at a level. If successful, then reset the variables , then loop the next level, so on until one of the node contain atoms or one of the nodes fails to have the same number of children as other nodes. (dimensions essentially means every node at the same level must have the same number of children.)
# @result is the result dimensions.
# @nodesOfSameLevel is the nodes of a level. At the beginning, it is level 0 consisting of just the root.
# $numberOfChild = is the number of child of a node. Whenever the number of child of a node differ from this, then the loop is aborted.;

# Dependent functions: (none).

push (@EXPORT, q(Dimensions));
push (@EXPORT_OK, q(Dimensions));

sub Dimensions ($) {
if ((ref $_[0] eq 'ARRAY') and (scalar @{$_[0]} == 0)) {return [];};
# do other input arg check here...
return _dimensions($_[0]);
};

sub _dimensions ($) {
my @indexList = @{$_[0]};

my @result = ();
my @nodesOfSameLevel = (\@indexList);
my $numberOfChild = scalar @{$nodesOfSameLevel[0]};

# $recurser is a subroutine that does not take arguments. It updates three variables outside of it, and calls itself until it abort itself when appropriate.
my $rf_recursor;
	$rf_recursor = sub {
		my $failed = 0;
		EQUALCHILDCHECK: foreach my $ref_node (@nodesOfSameLevel)
		{if ((ref $ref_node ne 'ARRAY') or $numberOfChild != scalar @{$ref_node}) {$failed = 1; last EQUALCHILDCHECK;};};
	
		if ($failed) {return;} else {
		#set a slot of the result
		push( @result, $numberOfChild);
		
		# reset @nodesOfSameLevel for next level recurse.
		for (my $i = $#nodesOfSameLevel; $i >= 0; $i--)
		{splice(@nodesOfSameLevel, $i, 1, @{$nodesOfSameLevel[$i]});};
		
		# reset numberOfChild for next level recurse
		if (ref $nodesOfSameLevel[0] ne 'ARRAY') {return;};
		$numberOfChild = scalar @{$nodesOfSameLevel[0]};
		
		&$rf_recursor;
		};
	};

&$rf_recursor;
return \@result;
};

# this is a terse version of the same algorithm written by David Alan Black (dblack@pilot.njin.net) on 1998/10. coding style tweaked by xah.
#sub _dimensions {
#	my @result = ();
#	my $rf_recursor;
#	$rf_recursor = sub {
#		my ($firstNode, @nodesOfSameLevel) = @_;
#		if ((ref $firstNode ne 'ARRAY') or (scalar @$firstNode == 0)) {return;};
#		&$rf_recursor(@$firstNode);
#		unshift @result, scalar @$firstNode
#			unless grep { scalar @$_ != scalar @$firstNode } @nodesOfSameLevel;
#	};
#	&$rf_recursor;
#	return \@result;
#};

#end Dimensions

=pod

=head2 Branchs and Nodes Extractors

=cut

#_____ Part _____ _____ _____ _____

=pod

B<Part>

Part(tree, e1, e2, e3,...) returns a branch of the tree at position index (e1, e2, e3,...). The e_i are integers. For example, Part([[['0','a','b'],'h'],'x','t'], 0, 0, 2) returns 'b'. If e_i is negative, counting starts from right. Cyclic counting is also used. For example, Part([0,1,2], 3) returns 0 and Part([0,1,2], -4) returns 2.

Each element e_i can also be a list of integers of the form [e_i_1, e_i_2, e_i_3,...]. In such case, Part returns the Cartesian product of all e_i. For example, Part([[['0','a','b'],'h'],'x','t'], 0, 0, [1,2]) returns ['a','b'], which has position indexes (0,0,1) and (0,0,2). Part($tree, [1,2],0,[3,4]) will return [['part 1 0 3', 'part 1 0 4'],['part 2 0 3', 'part 2 0 4']].

Related: Extract, Level.

Example:

 Part(['a','b','c'], 0); # returns 'a'.
 
 Part(['a','b','c'], 3); # returns 'a'.
 
 Part(['a','b','c'], -1); # returns 'c'.

 Part([5,[98, 44],'x'], 1, 0); # returns 98.

 Part([5,[98, 44],'x','y'], [3,2,3]); # returns ['y', 'x', 'y'].

 $tree = [[['000', '001'], ['010', '011']], [['100', '101'], ['110', '111']]];
 Part($tree, 0, 0); # returns ['000', '001'].
 Part($tree, 0, -1); # returns ['010', '011'].
 Part($tree, 0, 1, 0); # returns '010'.
 Part($tree, 0, 1, [0,0]); # returns ['010', '010'].
 Part($tree, 0, [1,0], 0); # returns ['010', '000'].
 Part($tree, 0, [1,0], [1,0]); # returns [['011','010'],['001','000']].

 Part($tree, [1,-4], [4,1,4], [0]);
 # returns [[['100'], ['110'], ['100']], [['000'], ['010'], ['000']]].

=cut

# implementation note:
# the code uses the same algorithm as the following Mathematica codes.
#part[expr_,0]:=Head[expr];
#part[expr_,a1_Integer]:=First@Take[expr,{a1}];
#part[expr_,a1_List]:=(Head@expr)@@(Map[part[expr,#]&,a1]);
#part[expr_,a1_Integer,rest___]:=part[part[expr,a1],rest];
#part[expr_,a1_List,rest___]:=Map[part[#,rest]&,part[expr,a1]];

# misc note: the following version is from Rick Delaney <rick.delaney@shaw.wave.ca>, 1998/10.
# Dependent functions: (none)

push (@EXPORT, q(Part));
push (@EXPORT_OK, q(Part));

sub Part ($$@) {
# input checks here...
return _part(@_);
};

sub _part {
	my ($ref_tree, @indexes) = @_;
	my $index;
	while(defined($index = shift @indexes)) {
		if (ref $index) {
			$ref_tree = [ map { _part($ref_tree, $_, @indexes) } @$index ];
			last;
		};
		$index = $index % @$ref_tree;
		$ref_tree = $ref_tree->[$index];
	};
	return $ref_tree;
};

# here's a preliminary version that is a direct translation of Mma code. It does not do cyclic indexing, and needs more testing. The code is written on 1998/10.
#sub _part {
#  if (scalar @_ == 2) {
#    if ($_[1] == 0) {return __part_0(@_);}
#    elsif (ref \$_[1] eq 'SCALAR') {return __part_integer(@_);}
#    elsif (ref $_[1] eq 'ARRAY') {return __part_list(@_);}
#    else {print "error: _part: argument is wrong\n"; return 0;};
#  }
#  elsif ((scalar @_) > 2) {
#    if (ref \$_[1] eq 'SCALAR') {return __part_integer_rest(@_);}
#    elsif (ref $_[1] eq 'ARRAY') {return __part_list_rest(@_);}
#    else {print "error: _part: something's wrong in _part\n"; return 0;};
#  } else {"error: _part: logical error.\n"; return 0;};
#
#};
#
#sub __part_0 {return $_[0]->[0];};
#sub __part_integer {return $_[0]->[$_[1]];};
#sub __part_list {return [map { $_[0]->[$_] } @{$_[1]}];};
#sub __part_integer_rest {my ($ra_tree, $n, @rest) = @_;return _part( _part($ra_tree,$n), @rest);};
#sub __part_list_rest {my ($ra_tree, $ra_list, @rest) = @_; return [map { _part($_, @rest) } @{_part($ra_tree, $ra_list)}]};

#end Part


#_____ Level _____ _____ _____ _____

=pod

B<Level>

Level(tree, [n]) returns a list of all nodes that are on the nth level of the tree. Level 0 is the root, consisting of the whole tree. Level 1 is the immediate elements in the list, i.e. those accessible by $tree->[m1]. Level 2 are those accessible by $tree->[m1][m2], and so on.

If n is negative, levels are counted from leaves to root. That is, Level(tree, [-n]) for a positive n returns all nodes in the tree that have depth n. The depth of a tree, Depth(tree), is the maximum number of indices needed to specify any node, plus one. (i.e. a node at level n for a positive n has depth n+1.) (see Depth.)

Level( tree, [n, m]) returns a list of all nodes of the tree that's on levels n to m inclusive. Either one of n or m can be negative. For example, Level( tree, [2,-2]) returns all nodes on level 2 or more, and has depth 2 or greater.

Level( tree, n) is equivalent to Level( tree, [1, n]).

In general, the form is Level( tree, levelSpec), where levelSpec has one of the forms: n, [n], [n, m], where the first two forms are shortcuts. That is, n is equivalent to [1,n], and [n] is equivalent to [n, n].

If the levelSpec is beyond the depth of the tree, or if it doesn't make sense (e.g. [5,3] or [-3,-5]), an empty list is returned. (i.e. []). Note: levelSpec such as [3,-2] is not necessarily illegal.

Nodes in the result list is ordered by their position indexes' components ascending (i.e. [2,1] comes before [3].). When there is a tie (e.g. [2] vs. [2,1]), index length descending is used (i.e. [2,1] comes before [2]). For example, here's a complete index set sorted the way Level would: [[0],[1,0],[1,1,0],[1,1,1],[1,1,2],[1,1],[1,2,0],[1,2,1],[1,2,2],[1,2],[1],[2,0],[2,1,0],[2,1,1],[2,1,2],[2,1],[2,2,0],[2,2,1],[2,2,2],[2,2],[2]]. See IndexSetSort for details about sorting nodes.
 
Related: Part, Extract.

Example:

 Level( $tree, [0]); # returns [ $tree ].

 Level( $tree, [1]); # returns $tree unchanged.

 Level( [[1,2],[3,[44]],'a'], [2]); # returns [ 1,2,3,[44] ].

 Level( [[1,2],[3,[44]],'a'], [3]); # returns [ 44 ].

 Level( [[1,2],[3,[44]],'a'], [-1]);
 # returns all the leaves [ 1,2,3,44,'a' ].
 # In other words, atoms or leaves are those having depth 1.
 
 Level( [[1,2],[3,[44]]], [-2]);
 # returns [ [1,2], [44] ] because both element has depth 2.

 Level( [[1,2],[3,[44]]], [-3]); # returns [ [3,[44]] ]

 Level( [[1,2],[3,[44]]], [-4]);
 # returns [ [[1,2],[3,[44]]] ] because the whole tree has depth 4.;

 Level( [[1,2],[3,[44]]], [-5]);
 # returns [ ] because the tree has depth 4. i.e. It's root node has depth 4.
 # No other node can have depth greater than the root.;

 Level( [[1,2],[3,[44]]], [1,2]);
 # returns [ 1, 2, [1,2], 3, [44], [3,[44]] ]
 # the result consists of all nodes that requires 1 or 2 indexes to access.
 # their position indexes in the tree are:
 # [0,0], [0,1], [0], [1,0], [1,1], [1]
 # note the order returned.

 Level( [[1,2],[3,[44]]], [1,3]);
 # returns [ 1, 2, [1,2], 3, 44, [44], [3,[44]] ]
 # these are nodes on levels 1 to 3.
 # their position indexes are
 # [0,0], [0,1], [0], [1,0], [1,1,0], [1,1], [1]

 Level( [[1,2],[3,[44]]], [2,3]);
 # returns [ 1, 2, 3, 44, [44] ]
 # their position indexes are
 # [0,0], [0,1], [1,0], [1,1,0], [1,1]

 Level( [[1,2],[3,[44]]], [2,-1]);
 # returns [ 1, 2, 3, 44, [44] ]
 
 Level( [[1,2],[3,[44]]], [2,-2]);
 # returns [ [44] ] because [44] is the only node on level 2
 # or greater and have a depth of 2 or more.

 Level( [[1,2],[3,[44]]], [1,-2]);
 # returns [ [1,2], [44], [3,[44]] ]
 # these are nodes on level 1 or greater and have a depth of 2 or more.

 Level( [[1,2],[3,[44]]], [-10,-2]);
 # returns [ [1,2], [44], [3,[44]], [[1,2],[3,[44]]] ]
 # i.e. all nodes having depth <= 10 and >= 2. Their depths are 2, 2, 3, 4.
 
 Level( [[1,2],[3,[44]]], [-2,1]);
 # returns [ [1,2] ];
 # i.e. all nodes having depth <= 2 and on level <= 1.

 Level( [[1,2],[3,[44]]], [-2,2]);
 # returns [ 1,2,[1,2],3,[44] ];
 # i.e. all nodes having depth <= 2 and on level <= 2.

 Level( [[1,2],[3,[44]]], [-2,3]);
 # returns [1,2,[1,2],3,44,[44]];
 # i.e. all nodes having depth <= 2 and on level <= 3.

=cut


# implementation note:
# plan:
# 0. Given a tree and a levelSpec.
# 1. Create a complete index set of the tree.
# 2. Select those indexes specified by the levelSpec.
# 3. Sort this by standard tree-traversing order. (i.e. index ascending; depth descending.)
# 4. Extract these elements from given tree. The result is as desired.

# similar algorithm can be used for implementing Map. On the 4th step, apply the given function to nodes of the tree specified by the indexes. Use forms like $ref_tree->[n1][n2] = f($ref_tree->[n1][n2]). Note that the order of applying a function to nodes is very important. Step 3 must be followed.

# step 3 may need some explanation:
# problem: given a complete index set and a levelSpec, how to determine which node's in it?
# answer: 
# Since all levelSpec can be rewritten in the form [A,B], suppose we are given levelSpec [A,B]. Let a and b be the absolute value of A and B.
# Suppose A is positive and B is negative, then:
# If the length of a node is greater or equal to a, and its depth is greater or equal to b, then it is in the levelSpec.
# The following are other possible combination of signs, and their corresponding methods:
# l means the node's length and d means its depth.
# signs ,  predicates (both must be satisfied)
# + +   ,  l >= a, l <= b
# + -   ,  l >= a, d >= b
# - +   ,  d <= a, l <= b
# - -   ,  d <= a, d >= b
# if a or b is 0, treat them as positive here.

# Dependent functions: _treeToIndexSet, _completeIndexSet, _indexSetSortFullArguments, _nodeDepth.

push (@EXPORT, q(Level));
push (@EXPORT_OK, q(Level));

sub Level ($$) {
# input checks here...
return _level(@_);
};

sub _level ($$) {
# this function converts levelSpec to a full form, then pass it to _levelWithFullArgs.
  if ( ref $_[1] eq 'ARRAY') {
    if (scalar @{$_[1]}==1) {return _levelWithFullArgs($_[0], [$_[1]->[0], $_[1]->[0] ]); }
    else {return _levelWithFullArgs( @_ ); };
  } else {return _levelWithFullArgs($_[0], [1, $_[1]]); };
};

sub _levelWithFullArgs ($$) {
my $ref_tree = $_[0];
my ($A, $B) = @{$_[1]};

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
my @result;
foreach my $ref_index (grep {eval $predicateString} @{$ref_completeIndexSet}) {
push @result, eval( '$ref_tree' . join('', (map {"->[$_]"} @$ref_index)) );
};

return \@result;
};

#end Level


#_____ Transpose _____ _____ _____ _____

=pod

B<Transpose>

Transpose(tree) returns a result that is the given tree with the first two levels transposed. e.g. Transpose( [[1,2,3],['a','b','c']] ) returns [[1,'a'],[2,'b'],[3,'c']].

Transpose(tree, permutationList) transposes the tree according to permutationList of the form [n1,n2,...,nm], where each n_i is a unique positive integer from 1 to m. Transpose($tree) is equivalent to Transpose($tree, [2,1] ).

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

 Transpose( $tree, [2, 1]);
 # returns [[['x1','x2'],['a1','a2']],[['y1','y2'],['b1','b2']],[['z1','z2'],['c1','c2']]]

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

push (@EXPORT, q(Transpose));
push (@EXPORT_OK, q(Transpose));

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
my $ref_indexSet = [grep {scalar @$_ == $transposeLevel} @{ _completeIndexSet([map {$_ = $_->[0];} @{ _treeToIndexSet($ref_tree)}]) }];

my $ref_resultTree;
foreach my $ref_index (@$ref_indexSet) {
	eval(
	'$ref_resultTree' . join('', (map {"->[$_]"} @{Permute($ref_index, $ref_perm)})) . '=' .
	'$ref_tree' . join('', (map {"->[$_]"} @$ref_index)) . ';'
	);
};

return $ref_resultTree;
};

#end Transpose

#_____ FlattenAt _____ _____ _____ _____

=pod

B<FlattenAt>

FlattenAt(tree, positionIndex) returns a modified version of given tree where the node (subtree) at positionIndex is moved (flattened) up to its parent generation. (In other words: the brackets of the element at positionIndex is removed.)

Related: Flatten, Sequence, xxxxx.

Example:

 FlattenAt(['a', ['b']], [1]); # returns ['a', 'b'].

 FlattenAt(['a', 'b'], [0]);
 # xxxxx returns 0 and prints "Error: position [0] of tree has no parts and cannot be flattened".

 FlattenAt([[8,['a']], [3] ], [0]); # returns [8, ['a'], [3] ]

 FlattenAt([ [8, ['a']], [3] ], [0,1]); # returns [ [8, 'a'], [3] ]

=cut

# implementation note:
# basic plan: Use the fact that perl auto flatten lists as in
# splice(@array,1,1, @array2)

# Dependent functions: (none)

push (@EXPORT, q(FlattenAt));
push (@EXPORT_OK, q(FlattenAt));

sub FlattenAt ($$) {
# input checks here...
return _flattenAt(@_);
};

sub _flattenAt ($$) {
my $ref_tree = [@{$_[0]}];
my $ref_index = [@{$_[1]}];

my @parentNodeIndex = @{$ref_index}; pop(@parentNodeIndex);
my @parentNode = @{eval('$ref_tree' . join('', (map {"->[$_]"} @parentNodeIndex)))};
my $treePartsString = '$ref_tree' . join('', (map {"->[$_]"} @$ref_index));
splice(@parentNode, $ref_index->[-1], 1, @{eval($treePartsString)});

eval( '$ref_tree' . join('', (map {"->[$_]"} @parentNodeIndex)) . ' = \@parentNode');

return $ref_tree;
};


#end FlattenAt


#_____ RotateLeft _____ _____ _____ _____

=pod

B<RotateLeft>

RotateLeft($arrayReference) returns an array reference that is the given array with elements rotated to the left. RotateLeft($arrayReference, n) rotates by n. n is an integer. ($n can be negative or 0) 

Example:

 RotateLeft([1..4], 2) # returns [3,4,1,2].

Example:

 for (my $i=0;$i<=3;$i++) {print qq(@{RotateLeft([0..3],$i)}\n);};
 # prints a 4 x 4 Latin square
 0 1 2 3
 1 2 3 0
 2 3 0 1
 3 0 1 2

=cut

# implementation note:
# Dependent functions: (none).

push (@EXPORT, q(RotateLeft));
push (@EXPORT_OK, q(RotateLeft));

sub RotateLeft ($;$) {
if (scalar @_ == 1) {return _rotateLeft($_[0],1);}
else {return _rotateLeft(@_);};
};

sub _rotateLeft ($$) {
my @aa=@{$_[0]};
my $n=$_[1];

if ($n >= 0) {return [(@aa[$n..$#aa],@aa[0..$n-1])]}
else {return [(@aa[$#aa+$n+1..$#aa], @aa[0..$#aa+$n])]};
};

# alternative definition for RotateLeft. Only accept positive n.
# sub RotateLeft2 {my @aa=@{$_[0]};my $n=$_[1];for (my $i=1;$i<=$n;$i++) {push(@aa,shift(@aa));};return [@aa];};

#end RotateLeft

#_____ Function _____ _____ _____ _____

=pod

B<Function>

Function(parameterList,'expressionString') returns a function. The function takes parameters in parameterList and has body expressionString. parameterList is a reference to a list of strings, each represents a parameter name. For example: ['i','j']. The return value of Function is a reference to a function.

Example:

&{Function(['i','j'],'i + j')}(3,4); # returns 7.

=cut

# implementation note:
# Dependent functions: (none).

push (@EXPORT, q(Function));
push (@EXPORT_OK, q(Function));

sub Function ($$) {
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

#end Function

#_____ Map _____ _____ _____ _____

=pod

B<Map>

Map(f, tree) returns the result of applying f to tree. f must be a reference to a subroutine or anonymous function. For example: Map( sub {$_**2;}, [9,2,5]); returns [81,4,25].

Map(f, tree, levelSpec) maps f to nodes specified by levelSpec. Map(f, tree) is equivalent to Map(f, tree, [1]). The general form of levelSpec is [m,n], meaning levels m to n inclusive. f is applied to the tree in the same order as the function 'Level'. That is, commonly known as "depth first". See Level for detail about levels and levelSpec.

Map(f, tree, [1]) has the same functionality as Perl's "map".

The most common use of Map is applying a function to a specific level of a tree. For example, Map( $func , $tree, [2]) will return a modified $tree, where all nodes (subtrees) at level 2 are transformed by having $func applied to them. For example:

 Map($f, [[$subTree1,$subTree2], 'anAtom', [$subTree3] ], [2])
 # returns [[&{$f}($subTree1), &{$f}($subTree2)], 'anAtom', [ &{$f}($subTree3) ] ].

 Map($f, [[$subTree1,$subTree2], 'anAtom', [$subTree3] ], [1])
 # returns [&{$f}([$subTree1, $subTree2]), &{$f}('anAtom'), &{$f}([$subTree3]) ].

Map( $func , $tree, [-1]) will apply $func to all the leaves of the tree.

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
# misc note: this function needs heavy testing.
# Dependent functions: _treeToIndexSet, _completeIndexSet, _indexSetSortFullArguments, _nodeDepth.

push (@EXPORT, q(Map));
push (@EXPORT_OK, q(Map));

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

#_____ UniqueString _____ _____ _____ _____

=pod

B<UniqueString>

UniqueString('aString', n) returns a reference to a list of n elements of strings, none of which are in the given string and no two are identical. Each string starts with 'unik' and followed by digits.

Example:

 UniqueString('Something about love...', 2);
 # returns ['unik23946', 'unik14135'].

=cut

# implementation note:
# Dependent functions: (none).

push (@EXPORT, q(UniqueString));
push (@EXPORT_OK, q(UniqueString));

sub UniqueString ($$) {
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

#end UniqueString

#_____ RandomInteger _____ _____ _____ _____

=pod

B<RandomInteger>

RandomInteger(iMin, iMax) returns a pseudo-random integer between iMin and iMax, including the boundaries. iMin and iMax should be integers, if not, their integer part is taken.

RandomInteger calls Perl's "rand" function. It's quality is dependent on "rand".

Example:

 RandomInteger(-5, 3);

=cut

# implementation note:
# Dependent functions: (none)

push (@EXPORT, q(RandomInteger));
push (@EXPORT_OK, q(RandomInteger));

sub RandomInteger ($$) {return int (rand (int($_[1]) - int($_[0]) +1)) +int($_[0]);};

#end RandomInteger

#_____ RandomReal _____ _____ _____ _____

=pod

B<RandomReal>

RandomReal(iMin, iMmax) returns a pseudo-random real number between real numbers rMin and rMax.

RandomReal calls Perl's "rand" function. It's quality is dependent on "rand".


Example:

 RandomReal(-3.7, 10);

=cut

push (@EXPORT, q(RandomReal));
push (@EXPORT_OK, q(RandomReal));

# implementation note:
# Dependent functions: (none)

sub RandomReal ($$) {return rand ($_[1] - $_[0]) +$_[0];};

#end RandomReal

#_____ RandomIndexSet _____ _____ _____ _____

=pod

B<RandomIndexSet>

RandomIndexSet() returns a random list of indexes. e.g. [[3,2,5],[0,3],[4,2,0,4]].

RandomIndexSet([minIndexNumber, maxIndexNumber], [minIndexLength, maxIndexLength], [minTotalIndexes, maxTotalIndexes]) generates a list of random indexes based on given parameters.

Not all arguments must be given. The default parameters are RandomIndexSet([0,4],[1,4],[1,10]). Supplied ones will replace the default beginning from left.

Example:

 RandomIndexSet()
# returns [[3,2,5],[0,3]]

 RandomIndexSet([0,8],[1,5],[5,5])
# returns [[7], [6], [4, 4, 5], [3], [8, 8, 7]]

=cut

# implementation note:
# Dependent functions: RandomInteger.

push (@EXPORT, q(RandomIndexSet));
push (@EXPORT_OK, q(RandomIndexSet));

sub RandomIndexSet (;$$$) {
if (scalar @_ == 0) {return _randomIndexSetFullArguments([0,4], [1,4], [1,10])};
if (scalar @_ == 1) {return _randomIndexSetFullArguments($_[0], [1,4], [1,10])};
if (scalar @_ == 2) {return _randomIndexSetFullArguments($_[0], $_[1], [1,10])};
if (scalar @_ == 3) {return _randomIndexSetFullArguments($_[0], $_[1], $_[2])};
};

sub _randomIndexSetFullArguments ($$$) {
my ($minIndexNumber, $maxIndexNumber) = @{$_[0]};
my ($minIndexLength, $maxIndexLength) = @{$_[1]};
my ($minTotalIndexes, $maxTotalIndexes) = @{$_[2]};

my @anIndex;
my @result;
for my $i (1.. RandomInteger($minTotalIndexes, $maxTotalIndexes)) {
  for my $j (1.. RandomInteger($minIndexLength, $maxIndexLength)) {
    push(@anIndex, RandomInteger($minIndexNumber, $maxIndexNumber));
   };
  push(@result,[@anIndex]);
  @anIndex = ();
};
return \@result;
};

# testing
#require 'dumpvar.pl';
#dumpValue(RandomIndexSet());
#print "\n\n";
#dumpValue(RandomIndexSet([0,4]));
#print "\n\n";
#dumpValue(RandomIndexSet([0,4],[1,5]));
#print "\n\n";
#dumpValue(RandomIndexSet([0,4],[1,5],[1,5]));

#end RandomIndexSet

#_____ LeavesIndexSet _____ _____ _____ _____

=pod

B<LeavesIndexSet>

LeavesIndexSet([index1,index2,...]) returns a modified version of input in which non-leaf indexes are deleted. Indexes are of the form [n1,n2,n3,...] where the n are non-negative integers.

Related: NonleavesIndexSet.

Example:

 LeavesIndexSet([[2], [4], [4, 2], [4, 3], [4, 3, 5]])
 # returns [[2], [4, 2], [4, 3, 5]].

=cut

# implementation note:
# definition: for each index E, if there is no other index that start with same element as E, then E is a leave.
# algorithm used: go through the list. delete ones that's non-leaf. Return the result.
# implementation: start a loop, setting the current selection ($ref_currentIndex). while counter is not equal to the length of the list, go through a inner loop. The inner loop will compare the current selection to any element, and delete any non-leaf, including current selection (if it is a non-leaf). Both the outer loop and inner loop begins from right, so that when an element is deleted, the index won't be screwed. Each inner loop starts at an element that is the left of the current seletion, since elements to its right processed previously.

# Dependent functions: _nonleafQ

# misc notes: this function needs heavy testing. xxxxx

push (@EXPORT, q(LeavesIndexSet));
push (@EXPORT_OK, q(LeavesIndexSet));

sub LeavesIndexSet ($) {
my @indexList = @{$_[0]};

my $count = 1;
my $ref_currentIndex;
my $ref_currentElement;
OUTER: while ($count < scalar @indexList) {
$ref_currentIndex = $indexList[-$count];
	INNER: for (my $i = scalar(@indexList) -$count -1; $i >= 0; $i--) {
	$ref_currentElement = $indexList[$i];
	
	if (_nonleafQ($ref_currentElement,$ref_currentIndex))
	{splice(@indexList,$i,1); next INNER;}
	elsif (_nonleafQ($ref_currentIndex,$ref_currentElement))
	{splice(@indexList,-$count,1); next OUTER;};
	};
$count++;
};

return \@indexList;
};

#end LeavesIndexSet

#_____ NonleavesIndexSet _____ _____ _____ _____

=pod

B<NonleavesIndexSet>

NonleavesIndexSet([index1,index2,...]) returns a modified version of input in which leaf indexes are deleted. Indexes are of the form [n1,n2,n3,...] where the n are non-negative integers.

Related: LeavesIndexSet.

Example:

 NonleavesIndexSet([[2], [4], [4, 2], [4, 3], [4, 3, 5]])
 # returns [[4], [4, 3]].

=cut

# implementation note:
# It is intuitive to think that the implementation for NonleavesIndexSet can be a simple modification of the code for LeavesIndexSet in some reversal sense. This is not so in our choice of implementation of NonleavesIndexSet.

# Given two indexes of a tree. For example, $indexA = [2] and $indexB = [2,3]. If one starts with same number sequence of the other, then we can conclude that the shorter one is a node, but we cannot conclude that the longer one is a leaf. (thus we cannot delete it) Given a set of indexes E, it is a subset of a tree's full index set E2. Therefore, indexes can be partitioned into leaf and nonleaf. An index A is a leaf if there exists in E2 other indexes such that starts with the same numbers as A. The expansion of set E to E2 preserves the leaf/nonleaf partition, so the same mechanism can be used to determine leaf in E.

# The algorithm of LeavesIndexSet is based on the fact that a non-leaf can be deleted without loss of information as long the leaf that signaled the deletion is kept. Thus, the algorithm basically keeps deleting non-leaves. But conversely, a leaf cannot be deleted without losing information about which nodes may be leafs. For example, given $indexA = [2] and $indexB = [2,1], we know $indexA is a nonleaf but we do not know whether $indexB is a leaf because the set may or may not contain [2,1,3] or the like. Therefore, we cannot use an algorithm for NonleavesIndexSet that keeps on deleting leaves. However, we can still code NonleavesIndexSet by modifying the algorithm of LeavesIndexSet a bit, by adding a non-leaf into a result list each time it is to be deleted. This is the algorithm we will use.

# Dependent functions: _nonleafQ.

# misc notes: this function needs heavy testing. xxxxx

push (@EXPORT, q(NonleavesIndexSet));
push (@EXPORT_OK, q(NonleavesIndexSet));

sub NonleavesIndexSet ($) {
return _nonleavesIndexSet($_[0]);
};

sub _nonleavesIndexSet ($) {
my @indexList = @{$_[0]};

my $count = 1;
my $ref_currentIndex;
my $ref_currentElement;
my @result;
OUTER: while ($count < scalar @indexList) {
$ref_currentIndex = $indexList[-$count];
	INNER: for (my $i = scalar(@indexList) -$count -1; $i >= 0; $i--) {
	$ref_currentElement = $indexList[$i];
	
	if (_nonleafQ($ref_currentElement,$ref_currentIndex))
	{push(@result, splice(@indexList,$i,1)); next INNER;}
	elsif (_nonleafQ($ref_currentIndex,$ref_currentElement))
	{push(@result,splice(@indexList,-$count,1)); next OUTER;};
	};
$count++;
};

return [reverse(@result)];
};

#end NonleavesIndexSet

#_____ MinimumIndexSet _____ _____ _____ _____

=pod

B<MinimumIndexSet>

MinimumIndexSet([index1,index2,...]) returns a modified version of input in which indexes that can be inferred from other indexes are deleted. Indexes are of the form [n1,n2,n3,...] where the n are non-negative integers.

Related: CompleteIndexSet, FullArrayIndexSet.


Example:

 MinimumIndexSet([[1], [2], [3], [2, 3], [2, 2], [2, 3, 7], [3, 1]])
 # returns [[2, 3, 7], [3, 1]].

=cut

# implementation note:
# definition: Suppose {a,b,c,d} is one index. It is redundant if MemberQ[givenIndexes,{a,b,c,x$_/;x$ > d}|{a,b,c,x$_/;x$ >= d,__}], and if the index is {}, then it is redundant if MemberQ[givenIndexes,{__}].
# algorithm used: exactly same as LeafIndexSet except _leafIndexQ is replaced by _inferableIndexQ.

# Dependent functions: _inferableIndexQ.

# misc notes: this function needs heavy testing. xxxxx

push (@EXPORT, q(MinimumIndexSet));
push (@EXPORT_OK, q(MinimumIndexSet));

sub MinimumIndexSet ($) {
my @indexList = @{$_[0]};

my $count = 1;
my $ref_currentIndex;
my $ref_currentElement;
OUTER: while ($count < scalar @indexList) {
$ref_currentIndex = $indexList[-$count];
	INNER: for (my $i = scalar(@indexList) -$count -1; $i >= 0; $i--) {
	$ref_currentElement = $indexList[$i];
	
	if (_inferableIndexQ($ref_currentElement,$ref_currentIndex))
	{splice(@indexList,$i,1); next INNER;}
	elsif (_inferableIndexQ($ref_currentIndex,$ref_currentElement))
	{splice(@indexList,-$count,1); next OUTER;};
	};
$count++;
};

return \@indexList;
};

#end MinimumIndexSet


#_____ CompleteIndexSet _____ _____ _____ _____

=pod

B<CompleteIndexSet>

CompleteIndexSet([index1,index2,...]) returns a modified version of argument in which indexes that are implied by givens are inserted. The elements in the result list is arbitrary ordered, and without duplicates.

Related: MinimumIndexSet, FullArrayIndexSet, IndexSetSort.

Example:

The empty array [] in the result represents the index for the root node.

 IndexSetSort( CompleteIndexSet( [[2, 1]] ) );
 # returns [[],[0],[1],[2],[2,0],[2,1]].

 IndexSetSort( CompleteIndexSet( [[2, 1], [3]] ) );
 # returns [[],[0],[1],[2],[3],[2,0],[2,1]].

 IndexSetSort( CompleteIndexSet( [[2, 1], [3], [3]] ) );
 # returns [[],[0],[1],[2],[3],[2,0],[2,1]].

 IndexSetSort( CompleteIndexSet( [[3, 3], [4]] ) );
 # returns [[],[0],[1],[2],[3],[4],[3,0],[3,1],[3,2],[3,3]].

 IndexSetSort( CompleteIndexSet( [[3, 3], [1, 1], [4]] ) );
 # returns [[],[0],[1],[2],[3],[4],[1,0],[1,1],[3,0],[3,1],[3,2],[3,3]].

=cut

# implementation note:
# some description:
# Suppose one of the given index is {a,b,c,d}. If the last digit is not 0, then generate {a,b,c,d-1}. If the last digit is 0, then generate {a,b,c}. Add the new element into a result list. Now take new element as input and repeat the process until it becomes {}. Now do the above with every given index. Now eliminate duplicates and {} in the result list. The result is as desired.

# Dependent functions: (none)

# misc notes: this function needs heavy testing. This function's time complexity can also be improved by first generate a minimum index set, and use a smart algorithm to avoid generating repeatitions (without even checking for presence). xxxxx

push (@EXPORT, q(CompleteIndexSet));
push (@EXPORT_OK, q(CompleteIndexSet));

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

push (@EXPORT, q(IndexSetSort));
push (@EXPORT_OK, q(IndexSetSort));

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

#end IndexSetSort

#_____ TreeToIndexSet _____ _____ _____ _____

=pod

B<TreeToIndexSet>

TreeToIndexSet(tree) returns a list of all atoms (leaves) and their positions that represents the tree completely. The return value consists of pairs of position indexes and corresponding atoms.

The input tree must have the form [[...],...] where an atomic element is anything that is not a reference to an array. The return value is a reference to an array, of the form [[positionIndex1, atom1],[positionIndex2,atom2],...], where each positionIndex has the form [n1,n2,...].

Unimplemented extension: TreeToIndexSet(tree,levelSpec) returns the indexes and corresponding subexpression at levspec. xxxxx

Related: xxxxx IndexSetToExpression.

Example:

 TreeToIndexSet( [0,1,2,3] );
 # returns [[[0],0],[[1],1],[[2],2],[[3],3]]

 TreeToIndexSet( [[3,4],'b',[[7,8],'love']] );
 # returns [[[0,0],3],[[0,1],4],[[1],'b'],[[2,0,0],7],[[2,0,1],8],[[2,1],'love']]

 TreeToIndexSet( [[[1,1],[1,2]],[[2,1],[2,2]],[[3,1],[3,2]]] );
 # returns:  [[[0,0,0],1],[[0,0,1],1],[[0,1,0],1],[[0,1,1],2],
 #            [[1,0,0],2],[[1,0,1],1],[[1,1,0],2],[[1,1,1],2],
 #            [[2,0,0],3],[[2,0,1],1],[[2,1,0],3],[[2,1,1],2]]

 # hash references can also serve as atoms, but not recommended.
 TreeToIndexSet ( [[3,4],[{'key1' => 1,'key2' => 2}, 5]] )
 # returns: [[[0,0],3],[[0,1],4],[[1,0],{'key1' => 1,'key2' => 2}],[[1,1],5]]

=cut

# implementation note:
# Dependent functions: (none)
# misc notes: this function needs heavy testing. xxxxx

push (@EXPORT, q(TreeToIndexSet));
push (@EXPORT_OK, q(TreeToIndexSet));

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

#_____ IndexSetToTree _____ _____ _____ _____

=pod

B<IndexSetToTree>

IndexSetToTree(positionIndexSetWithAtoms) returns a reference to a nested list specified by positionIndexSetWithAtoms.

positionIndexSetWithAtoms is of the form [[positionIndex1, atom1],[positionIndex2,atom2],...] where a positionIndex has the form [n1,n2,...] and an atom is either string or number. The return value is a reference to a nested list, i.e. [[[...],...],...].

IndexSetToTree( TreeToIndexSet( args)) returns the args unchanged.

Related: TreeToIndexSet.

Example:

 IndexSetToTree( [[[0],0],[[1],1],[[2],2],[[3],3]] );
 # returns [0,1,2,3]

 IndexSetToTree( [[[0,0],3],[[0,1],4],[[1],'b'],[[2,0,0],7],[[2,0,1],8],[[2,1],'love']] );
 # returns [[3,4],'b',[[7,8],'love']]

 IndexSetToTree(
  [[[0,0,0],1],[[0,0,1],1],[[0,1,0],1],
   [[0,1,1],2],[[1,0,0],2],[[1,0,1],1],
   [[1,1,0],2],[[1,1,1],2],[[2,0,0],3],
   [[2,0,1],1],[[2,1,0],3],[[2,1,1],2]] );
 # returns: [[[1,1],[1,2]],[[2,1],[2,2]],[[3,1],[3,2]]]

 # hash references does not work well as atoms.
 IndexSetToTree ( [[[0,0],3],[[0,1],4],[[1,0],{'key1' => 1,'key2' => 2}],[[1,1],5]] )
 # returns: [[3,4],['HASH(0x256dea4)', 5]]

=cut

# implementation note:

# Dependent functions: 

# misc notes: this function needs heavy testing. xxxxx

push (@EXPORT, q(IndexSetToTree));
push (@EXPORT_OK, q(IndexSetToTree));

sub IndexSetToTree ($) {
return _indexSetToTree($_[0]);
};

sub _indexSetToTree ($) {
my @indexWithAtomList = @{$_[0]};

my $ref_resultArray = [];
my $evaluationString = '';

	foreach my $ref_indexWithAtom (@indexWithAtomList) {
	my @index = @{$ref_indexWithAtom->[0]};
	my $atom = $ref_indexWithAtom->[1];
	
	my $arrayIndexStr = '';
	# build the evaluation string; e.g. $ref_resultArray->[3]->[5] = 6;
	foreach my $elem (@index) {$arrayIndexStr .= "->[$elem]";};
	$evaluationString .= qq(\$ref_resultArray$arrayIndexStr = '$atom';\n);
	};
	eval($evaluationString);
 
return $ref_resultArray;
};


#_______________________________

return 'package end';

__END__


=pod


=head1 SEE ALSO

Related modules:

PDL - Perl Data Language, a system of modules (with extensions) that tries to make Perl an industrial strength scientific number cruncher. (Available on CPAN)

Math::matica - A Mathlink application that allows one to call Mathematica functions within Perl and vice versa. (I think. Available on CPAN)

The following files are helpful documentations related in using this module.
 * perlref.pod,  Perl references
 * perldsc.pod,  Perl data structures intro
 * perllol.pod,  Perl data structures: lists of lists
 * "Advanced Perl Programing" by Sriram Srinivasan, Chapters 1 to 6.

=head1 AUTHOR

 Xah Lee, (xah@xahlee.org)
 http://xahlee.org/PageTwo_dir/more.html
 
This package is written with the help of comp.lang.perl.* newsgroups. In particular, the following people have contributed (not ordered): David Alan Black <dblack@email.njin.net>, Larry Rosler <lr@hpl.hp.com>, John Porter <jdporter@min.net>, Rick Delaney <rick.delaney@shaw.wave.ca>.

 Copyright 1998-1999 by Xah Lee.
 This software is licensed under the GNU Public License. The license is available at
 http://www.gnu.org/copyleft/gpl.html

Module Created: 1998/10.

This version created: 1998/10.

 status as of 1999/11
 I'm putting this on the web for the first time.
 I've been wanting to finish it, but never had the motivation or time since
 late 1998. I've been busy as a web application engineer.
 I hope that by publishing this module, I may get
 readers to get me going, or even have someone complete this module
 for the sake of public interest.

 By the way, Perl is the suckest language on earth.

=cut

#------------------------------------
# notes:

# Status as of 1998/11.
# Need to check all function to see if the argument are modified.
# If so, need to fix by first making a copy of the tree.

#sub min {return @{[sort {$a <=> $b} @_]}[0];};

# end of file.


