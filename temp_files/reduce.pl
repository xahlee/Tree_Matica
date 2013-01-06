#200308

use strict;
use Data::Dumper;

sub combo ($) {
	my $max=$_[0];
	my %hh=();
	for (my $j=1; $j < $max; ++$j) {
		for (my $i=1; $i <= $max; ++$i) {
			my $m = (($i+$j)-1)%$max+1;
			if ($i < $m){ $hh{"$i,$m"}=[$i,$m];}
		}
	}
	return \%hh;
}


=pod


suppose we have a set of n things in a list, we index them from 1 to n. We want to partition the list so that equal things are gathered together.
We generation a comparison list, such as
[1,2],[2,3],[3,4],[4,5],[1,3],[2,4],[3,5],[1,4],[2,5],[1,5]
each pair represents a comparison test. This list is the same as 5 taken 2, where order does not matter. Comparison is expensive, so we want to reduce necessary comparisons as soon as we find a pair to be equal. For example, if 1 and 2 are equal, then we do not have to do both [2,3] and [1,3], since 1 and 2 are the same, and we just need to compare one of them to 3.



reduce ($VAR1, [3,5]) where 
$VAR1 = {'5,6' => ['5',6],'1,2' => [1,2],'1,3' => [1,3],'1,4' => [1,4],'1,5' => [1,5],'1,6' => [1,6],'2,3' => ['2',3],'2,4' => ['2',4],'2,5' => ['2',5],'2,6' => ['2',6],'3,4' => ['3',4],'3,5' => ['3',5],'3,6' => ['3',6],'4,5' => ['4',5],'4,6' => ['4',6]};

returns the following: {'1,2' => [1,2],'1,3' => [1,3],'1,4' => [1,4],'2,3' => ['2',3],'1,6' => [1,6],'2,4' => ['2',4],'2,6' => ['2',6],'3,4' => ['3',4],'3,5' => ['3',5],'3,6' => ['3',6],'4,6' => ['4',6]};

the first parameter is a list of pairs of numbers. Each pair has two numbers, each number represent a thing. Their paring means that these two things needs to be comparied to see if they are identical. The second parameter to reduce is a pair meaning these two are identical. What reduce does is reduce the first argument, so that necessary comparisons can be reduced.
For example, if the list is [1,3], [3,8],[5,8],[6,7], and we know that 3 and 5 are the same, then we no longer needs to compare 5 and 8 because 5 is really the same as 3 and  a comparison between 3 and 8 is already in the list.

the first argument have have the pairs ordered so that first element is smaller than the second. No repeation like [5,5]

=cut


sub reduce ($$) {
my %hh= %{$_[0]}; # e.g. {'1,2'=>[1,2],'5,6'=>[5,6],...}
my ($j1,$j2)=($_[1]->[0],$_[1]->[1]);  # e.g. [3,4]

# my $jackpot =$_[1]; # $jackpot=~m/^(\d+),(\d+)$/; my ($j1,$j2)=($1,$2);

delete $hh{"$j1,$j2"};

foreach my $k (keys %hh) {
	$k=~m/^(\d+),(\d+)$/;
	my ($k1,$k2)=($1,$2);
	if ($k1==$j1) {if ($j2 < $k2) {delete $hh{"$j2,$k2"}} else {delete $hh{"$k2,$j2"}};};
	if ($k2==$j1) {if ($k1 < $j2) {delete $hh{"$k1,$j2"}} else {delete $hh{"$j2,$k1"}};};
}
return \%hh;
}



$Data::Dumper::Indent=0;

print Dumper combo 6;
print Dumper reduce( combo 6, [3,5] );
print "\n";


__END__

my $jackpot ='3,5';
$jackpot=~m/^(\d+),(\d+)$/;
my ($j1,$j2)=($1,$2);

foreach my $k (keys %hh) {
	 $k=~m/^(\d+),(\d+)$/;
	 my ($k1,$k2)=($1,$2);
   if ($k1==$j1) {if ($j2 < $k2) {delete $hh{"$j2,$k2"}} else {delete $hh{"$k2,$j2"}};};
   if ($k2==$j1) {if ($k1 < $j2) {delete $hh{"$k1,$j2"}} else {delete $hh{"$j2,$k1"}};};
}


--

my $jackpot ='3,5';
$jackpot=~m/^(\d+),(\d+)$/;
my ($j1,$j2)=($1,$2);
my %hh2;
NN: foreach my $k (keys %hh) {
	 $k=~m/^(\d+),(\d+)$/;
	 my ($k1,$k2)=($1,$2);
	 $hh2{$k}=[$k1,$k2];
   if ($k1==$j1) {if ($j2 < $k2) {delete $hh{"$j2,$k2"}} else {delete $hh{"$k2,$j2"}};} next NN;
   if ($k1==$j2) {if ($j1 < $k2) {delete $hh{"$j1,$k2"}} else {delete $hh{"$k2,$j1"}};} next NN;
   if ($k2==$j1) {if ($k1 < $j2) {delete $hh{"$k1,$j2"}} else {delete $hh{"$j2,$k1"}};} next NN;
   if ($k2==$j2) {if ($k1 < $j1) {delete $hh{"$k1,$j1"}} else {delete $hh{"$j1,$k1"}};} next NN;
}


print Dumper \%hh2;
print Dumper \%hh;


my $jackpot ='3,5';
$jackpot=~m/^(\d+),(\d+)$/;
my ($j1,$j2)=($1,$2);
my %hh2;
foreach my $k (keys %hh) {
	 $k=~m/^(\d+),(\d+)$/;
	 my ($k1,$k2)=($1,$2);
   if ($k1==$j1) {if ($j2 < $k2) {$hh2{"$j2,$k2"}=[$j2,$k2]} else {$hh2{"$k2,$j2"}=[$k2,$j2]};};
   if ($k1==$j2) {if ($j1 < $k2) {$hh2{"$j1,$k2"}=[$j1,$k2]} else {$hh2{"$k2,$j1"}=[$k2,$j1]};};
   if ($k2==$j1) {if ($k1 < $j2) {$hh2{"$k1,$j2"}=[$k1,$j2]} else {$hh2{"$j2,$k1"}=[$j2,$k1]};};
   if ($k2==$j2) {if ($k1 < $j1) {$hh2{"$k1,$j1"}=[$k1,$j1]} else {$hh2{"$j1,$k1"}=[$j1,$k1]};};
}


   if ($k1==$j1) {if ($j2 < $k2) {if(exists $hh{"$j1,$k2"} && exists $hh{"$j2,$k2"}) {delete $hh{"$j2,$k2"}}} else {if(exists $hh{"$k2,$j1"} && exists $hh{"$k2,$j2"}) {delete $hh{"$k2,$j2"}}}}
   if ($k1==$j2) {if ($j1 < $k2) {if(exists $hh{"$j1,$k2"} && exists $hh{"$j2,$k2"}) {delete $hh{"$j1,$k2"}}} else {if(exists $hh{"$t1,$t2"} && exists $hh{"$t1,$t2"}) {delete $hh{"$k2,$j1"}}}}
   if ($k2==$j1) {if ($k1 < $j2) {if(exists $hh{"$t1,$t2"} && exists $hh{"$t1,$t2"}) {delete $hh{"$k1,$j2"}}} else {if(exists $hh{"$t1,$t2"} && exists $hh{"$t1,$t2"}) {delete $hh{"$j2,$k1"}}}}
   if ($k2==$j2) {if ($k1 < $j1) {if(exists $hh{"$t1,$t2"} && exists $hh{"$t1,$t2"}) {delete $hh{"$k1,$j1"}}} else {if(exists $hh{"$t1,$t2"} && exists $hh{"$t1,$t2"}) {delete $hh{"$j1,$k1"}}}}


