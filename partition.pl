
=pod

partition(list, predicate) partitions a list according to the predicate. assuming that the list is sorted already.

predicate is a reference to a function; It takes two arguments; and it returns either true or false. e.g. sub {$_[0] == $_[1]}

list is a reference to a list. (or tree.)

e.g.

partition([[5,1],[2,2],[8,2],[3,1],[3,2],[5,2]], sub {$_[0]->[1] == $_[1]->[1]} );

returns
[[[5,1]],[[2,2],[8,2]],[[3,1]],[[3,2],[5,2]]];

=cut

sub partition($$) {
my @li = @{$_[0]};
my $sameQ = $_[1];

my @tray=($li[0]);
my @result;

for (my $i=1; $i < (scalar @li); $i++) {
	if (&$sameQ($li[$i-1], $li[$i])) {push @tray, $li[$i]} else {push @result, [@tray]; @tray=($li[$i]);}
}
push @result, [@tray];

return [@result];
}

