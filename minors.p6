#!/usr/bin/env perl6

use lib 'lib';
use Cube;

use experimental :cached;

sub Squares ($n) #`(is cached) { Faces($n, 2) }

sub Gaussoid-from-string ($n, $_) {
    Squares($n)[(m:g/0/)».from];
}

multi sub Gaussoid-to-string ($n, @G) {
    my $s = '1' x Squares($n).elems;
    return $s unless @G;
    my @active = @G.map: { Squares($n).first(:k, * eq $_) };
    $s.substr-rw($_,1) = '0' for @active;
    $s;
}

# List all k-minors of the n-gaussoid G given in binary.
multi MAIN ($n, $k, $G) {
    my Face @G = Gaussoid-from-string($n, $G);
    say "$_.Str(): " ~ Gaussoid-to-string($k, @G ↘ $_) for Faces($n, $k);
}

# Do not suppose that the input is a binary encoding of
# a set of squares. Just use the faces to index $G as a
# string. That way, we can list minors of oriented gaussoids
# just as well.
multi MAIN ($n, $k, $G, Bool :$raw where *.so) {
    for Faces($n, $k) -> \Δ {
        my @indices = Squares($n).grep: * ⊆ Δ, :k;
        say "{ Δ.Str }: " ~ $G.comb[@indices].join;
    }
}
