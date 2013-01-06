# try out codes for dimensions. Can be trashed.

# The following is incorrect.
# 1. generate the position indexes of all atoms. e.g. [[0,0,0],[0,1,0],[0,2,0],[1,0,0],[1,1,0],[1,2,0],[0,0,0,0]];
# 2. pick the minimum length. e.g. 3. This means the length of dimensions list will also be 3.
# 3. Of all the indexes of length 3, compare indexes slot by slot and pick the max number in each slot. We have [1,2,0].
# 4. Add 1 to each slot, the result is the dimensions. e.g. [2,3,1]. We need to add 1 because the indexing system starts at 0.


# recurse(aNode,n), where n is the specified number of children from each child.
# it checks to see if the number of each children's children is equal to n.
# If so, 
# traverse each child of aNode, and made sure that each child has the same number of children. i.e. aNode has the same number of grandchildren from each child. If so, the number of children is recorded, then recurse is sent to each child node. If not, it stops.

#the following implementatino is incorrect.
sub _dimensions ($) {
# @indexList has the form [[n1,n2,...],...].
my @indexList = map {$_ = $_ ->[0]} @{ TreeToIndexSet($_[0])};
#print Dumper(\@indexList);
#[['0','0','0'],['0',1,'0'],['0',2,'0'],[1,'0','0'],[1,1,'0'],[1,2,'0']]

my $ref_result = [];
my $minLength = 100000000; #assume the tree has dimension less than this.
# find $minLength
foreach my $ref_index (@indexList) { if (scalar @{$ref_index} < $minLength) {$minLength = scalar @{$ref_index};};};
#print "$minLength\n";

# get rid of longer indexes
@indexList = grep {scalar @{$_} <= $minLength} @indexList;
print Dumper(\@indexList);

# find the max in each slot.
$ref_result = [split(m( ), '0 ' x $minLength)];
for my $i (0 .. ($minLength -1)) {
	for my $ref_index (@indexList) {
		if ($ref_index->[$i] > $ref_result->[$i]) { $ref_result->[$i] = $ref_index->[$i];};
	};
};

# increase each slot by 1.
foreach $_ (@{$ref_result}) { $_ += 1;};

return $ref_result;
};
