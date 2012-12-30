#!/usr/local/bin/perl5 -w

use strict;
use Data::Dumper; $Data::Dumper::Indent=0; $Data::Dumper::Deepcopy=1;

use lib qw(/disk1/www/home/xah/perl_dir/);
use Tree::Matica;

#-----------------------

my $ss;

$ss ||= 3;

print $ss;

__END__

my $tree =
	[
	 [ ['x1','x2'], ['y1','y2'], ['z1','z2']],
	 [ ['a1','a2'], ['b1','b2'], ['c1','c2']]
	];

print Dumper(Transpose( $tree, [1, 2, 3]) );


__END__

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


my $tree = [[[1]]];

my $ref = Depth($tree);

# my $ref = Part($tree, 1);

print Dumper($ref);


__END__

 Depth([]); # returns 1.

 Depth([5,98,'x']); # returns 2.

 Depth([['level1A', [ 'level 2', [ 3, 'level 3 here']]], [ 'B']]);
 # returns 4.


 Table('q(s)' ,[3]); #returns ['s','s','s']

 Table( 'i**2' , ['i', 4]); #returns [1, 4, 9, 16]

 Table('[i,j,k]',['i',2],['j',100,200,100],['k',5,6])
 # returns [[[[1,100,5],[1,100,6]],[[1,200,5],[1,200,6]]],[[[2,100,5],[2,100,6]],[[2,200,5],[2,200,6]]]]



Table

 Table('exprString', [iMax]) generates a list of iMax copies of value of eval('exprString'), and returns the refence to the list. i.e. [eval('exprString'),eval('exprString'),...]

 Table('exprString', ['i', iMax]) generates a list of the values by evaluating 'exprString' when 'i' in the string runs from 1 to iMax.

 Table('exprString', ['i', iMin, iMax]) starts with 'i' = iMin.

 Table('exprString', ['i', iMin, iMax, iStep]) uses steps iStep. If iStep is negative, then the roll of iMin and iMax are reversed. Inputs such as [1, -3 , 1] returns bad result.

 Table('exprString', ['i', iMin, iMax, iStep], ['j', jMin, jMax, iStep], ... ) gives a array by iterating 'i', 'j' in 'exprString'. For example, Table('f(i,j)', ['i',1,3], ['j',5,6]) returns [[f(1, 5), f(1, 6)], [f(2, 5), f(2, 6)], [f(3, 5), f(3, 6)]].

 In general, Table has the form Table('expressionString', iterator1, iterator2, ...) where 'expressionString' is a string that will be evaluated by eval. iterator have one of the following forms [iMax], ['dummyVarString',iMax], ['dummyVarString',iMin, iMax], or ['dummyVarString',iMin, iMax, iStep].

If Table fails, 0 is returned. Table can fail, for example, when the argument are not appropriate references or the iterator range is bad such as ['i',5,1].

 Example:

