#!/usr/local/bin/perl5 -w

#------------

use lib qw(APS318User:T2:perl_dir:perlModules_dir:);
#use MathematicaTree;
use strict;
#use English;
#use Benchmark;
#require 'dumpvar.pl';
use Data::Dumper; $Data::Dumper::Indent=0; $Data::Dumper::Deepcopy=1;


#---------------

sub FlattenAt {
   my ($tree, $d) = @_;
   my $depth  = '[' . (join '][', @$d) . ']';
   my $offset = pop @$d;
   my $parent  = '[' . (join '][', @$d) . ']';
   eval "splice \@{\$tree->$parent}, $offset, 1, \@{\$tree->$depth}";
   return $tree;
}

my $tree = [ [8, ['a']], [3, ['b', ['c', 'd'], 4], 5] ];
print Dumper FlattenAt($tree, [1]);

print Dumper FlattenAt(['a', ['b']], [1]); # returns ['a', 'b'].
#print Dumper FlattenAt([[8,['a']], [3] ], [0]); # returns [8, ['a'], [3] ]
#print Dumper FlattenAt([ [8, ['a']], [3] ], [0,1]); # returns [ [8, 'a'], [3] ]

__END__
