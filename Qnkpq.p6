#!/usr/bin/env perl6

# Print an adjacency list representation for the graph Q(n,k,p,q),
# n ≥ k ≥ p ≥ q ≥ 0, defined over the vertex set of k-faces of the
# n-cube with an edge between two faces d and f iff there is a
# p-face s which intersects d and f in at least q dimensions each.

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
        }
    }
}

sub MAIN (Int $n, Int $k, Int $p, Int $q) {
    for Faces($n, $k) -> $d {
        print ~$d, ': ';
        say neighbors($d, $n, $k, $p, $q)».Str.join(', ');
    }
}
