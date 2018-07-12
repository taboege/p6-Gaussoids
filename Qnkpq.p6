#!/usr/bin/env perl6

# Print an adjacency list representation for the graph Q(n,k,p,q),
# n ≥ k ≥ p ≥ q ≥ 0, defined over the vertex set of k-faces of the
# n-cube with an edge between two faces d and f iff there is a
# p-face s which intersects d and f in at least q dimensions each.

use Cube;

# Lighter printing
use MONKEY-TYPING;
augment class Face {
    method gist {
        my @map = @!I => '*', @!K => '1', @!K̃ => '0';
        @map.map: { slip .key X .value } ==>
        sort *[0] ==> map *[1] ==>
        join '' ==> return;
    }
    #method gist { "[{@!I.sort.join}|{@!K.sort.join}]" }
}

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
        print $d.gist, ': ';
        say neighbors($d, $n, $k, $p, $q)».gist
            .join(', ');
    }
}
