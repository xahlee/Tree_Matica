#!perl -w

# testing testing.

#------------
use lib qw(APS318User:T2:perl_dir:perlModules_dir:);
#use MathematicaTree;
use strict;
#use English;
#use Benchmark;
#require 'dumpvar.pl';
use Data::Dumper; $Data::Dumper::Indent=0; $Data::Dumper::Deepcopy=1;
#---------------


#_____ FlattenAt _____ _____ _____ _____

=pod

B<FlattenAt>

FlattenAt(tree, positionIndex) returns a modified version of given tree where the node (subtree) at positionIndex is moved up (flattened) to its parent generation. (In other words: the brackets of the element at positionIndex is removed.)

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

#push (@EXPORT, q(FlattenAt));
#push (@EXPORT_OK, q(FlattenAt));

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

# CopyTree([[...],...]) returns a copy of the argument.
# The argument must be tree, i.e. reference of nested array of arrays, with number or string as atoms.
# this code is by Rick Delaney <rick.delaney@shaw.wave.ca>, 1998/11.
sub CopyTree ($) {return [map { ref($_) ? CopyTree($_) : $_ } @{$_[0]}];};

my $tree = [[[[4]]]];
my $tree2 =
 _flattenAt($tree, [0,0,0]); # returns [[[4]]].

print Dumper($tree,$tree2);
#print Dumper($tree2);

#print Dumper FlattenAt(['a', ['b']], [1]); # returns ['a', 'b'].
#print Dumper FlattenAt([[8,['a']], [3] ], [0]); # returns [8, ['a'], [3] ]
#print Dumper FlattenAt([ [8, ['a']], [3] ], [0,1]); # returns [ [8, 'a'], [3] ]

__END__
