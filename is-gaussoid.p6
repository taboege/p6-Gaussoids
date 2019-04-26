#!/usr/bin/env perl6

use lib 'lib';
use Cube;

use experimental :cached;

sub Squares ($n) #`(is cached) { Faces($n, 2) }

sub Gaussoid-from-string ($n, $_) {
    Squares($n)[(m:g/0/)».from];
}

# List all k-minors of the n-gaussoid G given in binary.
multi MAIN ($n, $G) {
    my Face @G = Gaussoid-from-string($n, $G);
    my \Gaussoids3 = "111111" | "000000"
        | "011111" | "110111" | "111101"
        | "101111" | "111011" | "111110"
        | "110000" | "001100" | "000011"
    ;
    for Faces($n, 3) -> \Δ {
        my @indices = Squares($n).grep: * ⊆ Δ, :k;
        my $minor = $G.comb[@indices].join;
        if $minor ne Gaussoids3 {
            say "Violates { Δ.Str }: $minor";
        }
    }
    exit 0;
}
