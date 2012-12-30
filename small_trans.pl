#!/usr/local/bin/perl

use strict;
use Data::Dumper; $Data::Dumper::Indent=0; $Data::Dumper::Deepcopy=1;

my $tree =
	[
	 [ 1, 2, 3],
	 [ 'a', 'b', 'c']
	];

my $bb =
&{sub {my @result; for( my $i=0; $i < scalar @{$_[0]->[0]}; $i++) {push @result, [$_[0]->[0]->[$i],$_[0]->[1]->[$i]]}
return \@result}} ($tree);

print Dumper($bb);

__END__


sub trans ($)
{
my $a1 = $_[0]->[0];
my $a2 = $_[0]->[1];
my @aa;
 for( my $i=0; $i < scalar @$a1; $i++) {push @aa, [$a1->[$i],$a2->[$i]]}
return \@aa;
}
my $bb = trans($tree);

print Dumper($bb);


