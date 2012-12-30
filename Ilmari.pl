#!/usr/local/bin/perl -w

# Ilmari Karonen - http://www.sci.fi/~iltzu/

use strict;

sub _transpose {
    my ($tree, $perm, $new, @pos) = @_;
    if (@pos < @$perm) {
				my $i = 0;
				_transpose($_, $perm, $new, @pos, $i++) for @$tree;
    } else {
				$new = \$$new->[$_] for map $pos[$_ - 1] => @$perm;
				$$new = $tree;
    }
}

sub Transpose {
    my ($tree, $perm) = @_;
    $perm ||= [2,1];
    _transpose($tree, $perm, \my $new);
    return $new;
}

# test 3-level transpose:
my @matrix = map [map [split//] => split] => <DATA>;
print join(" " => map join("" => @$_) => @$_), "\n" for @matrix;
print "--\n";
print join(" " => map join("" => @$_) => @$_), "\n" for @{Transpose(\@matrix, [3,1,2])};

__DATA__
abc def ghi
jkl mno pqr
stu vwx yz.

