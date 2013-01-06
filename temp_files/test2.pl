# use Tree::Matica;
use Data::Dumper;

for $i (1..100){
  if (($i%2) == 0){
    print $i, "\n";
  } else {
    print "$i,", "\n";
  }
}


__END__

#!/usr/local/bin/perl -w

use strict;
use Data::Dumper;

use lib qw(/disk1/www/home/xah/perl_dir/);
use Tree::Matica;

sub _transpose2 {
    my ($tree, $perm, $new, @pos) = @_;
    if (@pos < @$perm) {
				my $i = 0;
				_transpose2($_, $perm, $new, @pos, $i++) for @$tree;
		} else {
				$new = \$$new->[$_] for map $pos[$_ - 1] => @$perm;
				$$new = $tree;
    }
}

sub Transpose2 {
    my ($tree, $perm) = @_;
#   my $tree = $_[0];
#		my $perm = 
		$perm ||= [2,1];
    _transpose2($tree, $perm, \my $new);
    return $new;
}

#--------
# testing

my $tree =
	[
	 [ ['x1','x2'], ['y1','y2'], [[1,[3,4]],'z2']],
	 [ ['a1','a2'], ['b1','b2'], ['c1', [4,5] ]]
	];

my $tree2 = [[['a', ['b1','b2'],'c'],['d','e','f'],['g','h','i']],[['j','k','l'],['m','n','o'],['p','q','r']],[['s','t','u'],['v','w','x'],['y','z','.']]];

my $perm = [3,2,1];
$Data::Dumper::Indent=0;

$Data::Dumper::Indent = 0;
print Dumper( Transpose( $tree, $perm) ) . "\n";
print Dumper( Transpose2( $tree, $perm) ); # 3 1 2

__END__
print Dumper( Transpose( $tree, [1, 2, 3]) );
print Dumper( Transpose2( $tree, [1, 2, 3]) );
# returns [[['x1','x2'],['y1','y2'],['z1','z2']],[['a1','a2'],['b1','b2'],['c1','c2']]]

print Dumper( Transpose( $tree, [1, 3, 2]) );
print Dumper( Transpose2( $tree, [1, 3, 2]) );
# returns [[['x1','y1','z1'],['x2','y2','z2']],[['a1','b1','c1'],['a2','b2','c2']]]

print Dumper( Transpose( $tree, [2, 1, 3]) );
print Dumper( Transpose2( $tree, [2, 1, 3]) );
# returns [[['x1','x2'],['a1','a2']],[['y1','y2'],['b1','b2']],[['z1','z2'],['c1','c2']]]

print Dumper( Transpose( $tree, [2, 3, 1]) );
print Dumper( Transpose2( $tree, [2, 3, 1]) );
# returns [[['x1','a1'],['x2','a2']],[['y1','b1'],['y2','b2']],[['z1','c1'],['z2','c2']]]

print Dumper( Transpose( $tree, [3, 1, 2]) );
print Dumper( Transpose2( $tree, [3, 1, 2]) );
# returns [[['x1','y1','z1'],['a1','b1','c1']],[['x2','y2','z2'],['a2','b2','c2']]]

print Dumper( Transpose( $tree, [3, 2, 1]) );
print Dumper( Transpose2( $tree, [3, 2, 1]) );
# returns [[['x1','a1'],['y1','b1'],['z1','c1']],[['x2','a2'],['y2','b2'],['z2','c2']]]

print Dumper( Transpose( $tree, [2, 1]) );
print Dumper( Transpose2( $tree, [2, 1]) );
# returns [[['x1','x2'],['a1','a2']],[['y1','y2'],['b1','b2']],[['z1','z2'],['c1','c2']]]

__END__

$VAR1 = [[['x1','x2'],['y1','y2'],['z1','z2']],[['a1','a2'],['b1','b2'],['c1','c2']]];
$VAR1 = [[['x1','x2'],['y1','y2'],['z1','z2']],[['a1','a2'],['b1','b2'],['c1','c2']]];
$VAR1 = [[['x1','y1','z1'],['x2','y2','z2']],[['a1','b1','c1'],['a2','b2','c2']]];
$VAR1 = [[['x1','y1','z1'],['x2','y2','z2']],[['a1','b1','c1'],['a2','b2','c2']]];
$VAR1 = [[['x1','x2'],['a1','a2']],[['y1','y2'],['b1','b2']],[['z1','z2'],['c1','c2']]];
$VAR1 = [[['x1','x2'],['a1','a2']],[['y1','y2'],['b1','b2']],[['z1','z2'],['c1','c2']]];
$VAR1 = [[['x1','a1'],['x2','a2']],[['y1','b1'],['y2','b2']],[['z1','c1'],['z2','c2']]];
$VAR1 = [[['x1','a1'],['x2','a2']],[['y1','b1'],['y2','b2']],[['z1','c1'],['z2','c2']]];
$VAR1 = [[['x1','y1','z1'],['a1','b1','c1']],[['x2','y2','z2'],['a2','b2','c2']]];
$VAR1 = [[['x1','y1','z1'],['a1','b1','c1']],[['x2','y2','z2'],['a2','b2','c2']]];
$VAR1 = [[['x1','a1'],['y1','b1'],['z1','c1']],[['x2','a2'],['y2','b2'],['z2','c2']]];
$VAR1 = [[['x1','a1'],['y1','b1'],['z1','c1']],[['x2','a2'],['y2','b2'],['z2','c2']]];
$VAR1 = [[['x1','x2'],['a1','a2']],[['y1','y2'],['b1','b2']],[['z1','z2'],['c1','c2']]];
$VAR1 = [[['x1','x2'],['a1','a2']],[['y1','y2'],['b1','b2']],[['z1','z2'],['c1','c2']]];
