#!/usr/bin/env perl6

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
    ([*] ($n-$k) ^.. $n) /
    ([*] 1 .. $k);
}

sub MAIN (Int $n, Int $k, Int $p, Int $q) {
    my $d = Faces($n, $k).head;
    my $neighbors = +neighbors($d, $n, $k, $p, $q);
    my $vertices = binom($n, $k) * 2**($n-$k);
    say 'Degree:   ', $neighbors;
    say 'Vertices: ', $vertices;
    say 'Complete graph' if $neighbors == $vertices-1;
}
