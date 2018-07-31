#!/usr/bin/env perl6

use lib 'lib';
use Cube;

sub share-face ($d, $f, $q --> Bool) {
    $d.K ⊆ $f.I ∪ $f.K and $f.K ⊆ $d.I ∪ $d.K  # intersection non-empty?
    and $q <= $d.I ∩ $f.I       # only then we can compute the dimension
}

sub neighbors ($d, $n, $k, $p, $q) {
    gather {
        KFACE: for Faces($n, $k).grep(* !eqv $d) -> $f {
            for Faces($n, $p) -> $s {
                if all($d, $f).&share-face($s, $q) {
                    take $f;
                    next KFACE;
                }
            }
            say "Not incident: ", $f.Str if %*ENV<DEBUG>
        }
    }
}

sub binom ($n, $k) {
    return 0 if $k > $n;
    ([*] ($n-$k) ^.. $n) /
    ([*] 1 .. $k);
}

multi sub MAIN (Int $n, Int $k, Int $p, Int $q, Bool :$enumerate) {
    my $d = Faces($n, $k).head;
    my $neighbors = +neighbors($d, $n, $k, $p, $q);
    my $vertices = binom($n, $k) * 2**($n-$k);
    say 'Degree:   ', $neighbors;
    say 'Vertices: ', $vertices;
    say 'Complete graph' if $neighbors == $vertices-1;
}

multi sub MAIN (Int $n, Int $k, Int $p, Int $q, Bool :$formula!) {
    my $sum = sum gather {
        for (0..($n-$k)) X (0..$k) -> ($m, $j) {
            next unless $n - $k ≥ $m + $k - $j;        # need enough 0's and 1's to disagree and non-intersect
            next unless $p ≥ $m + 2*$q - min($j, $q);  # need enough dimension to repair disagreement and intersections
            take binom($k,$j)*2**($k-$j) *  # this consumes all *'s of the first k-face
                 binom($n-$k,$k-$j) *       # put the rest of the *'s of the second one
                 binom($n-2*$k+$j, $m) *    # place a disagreement of size m
                 1                          # all other positions are determined
        }
    }
    say 'Degree:   ', -1+$sum; # no loops
}
