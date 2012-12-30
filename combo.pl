use strict;
use Data::Dumper;

=pod

# combo(n) returns an array of pairs that is all possible combinations of 2 things from n. For example, combo(5) returns [[1,2],[2,3],[3,4],[4,5],[1,3],[2,4],[3,5],[1,4],[2,5],[1,5]].
=cut

sub combo ($) {
my $max=$_[0];

my @li=();
for (my $j=1; $j < $max; ++$j) {
	for (my $i=1; $i <= $max; ++$i) {
		my $m = (($i+$j)-1)%$max+1;
		if ($i < $m){ push @li, [$i,$m];}
	}
}
return @li;
}


my @mm = combo(6);

# for my $i (@mm) { print "$i->[0], $i->[1]\n"}
$Data::Dumper::Indent=0; print Dumper \@mm;


__END__
