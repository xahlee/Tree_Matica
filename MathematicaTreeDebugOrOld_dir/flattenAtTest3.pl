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
   my $tree = shift;
   my @levels = @{shift()};

   my $offset = pop @levels;
   my $parent = $tree;
   foreach my $l (@levels) {
      $parent = $parent->[$l];
   }
   my $child = $parent->[$offset];
   splice @{$parent}, $offset, 1, @{$child};
   return $tree;
}

__END__

#---------------------
sub FlattenAt {
   my ($tree, @levels) = (shift, @{shift()});
   my $offset = pop @levels;
   my $parent = $tree;
   foreach my $l (@levels) {
      $parent = $parent->[$l];
   }
   my $child = $parent->[$offset];
   splice @{$parent}, $offset, 1, @{$child};
   return $tree;
}

#my $tree = [ [8, ['a']], [3, ['b', 4, ['c', 'd'], 5], 6] ];
#my $flat = FlattenAt($tree, [1,1,2]);
#print @{$flat->[1][1]}  # prints b4cd5

print Dumper FlattenAt(['a', ['b']], [1]); # returns ['a', 'b'].
print Dumper FlattenAt([[8,['a']], [3] ], [0]); # returns [8, ['a'], [3] ]
print Dumper FlattenAt([ [8, ['a']], [3] ], [0,1]); # returns [ [8, 'a'], [3] ]
__END__

 
