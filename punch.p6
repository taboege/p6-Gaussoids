#!/usr/bin/env perl6

use lib 'lib';
use Cube;

use experimental :cached;

sub Squares ($n) #`(is cached) { Faces($n, 2) }

sub punch ($n, $G is copy, \ingredients) {
    for ingredients -> \β {
        my $i = Squares($n).first(* === β, :k)
            // die "did not find face { β }";
        $G.substr-rw($i,1) = '0';
    }
    $G
}

# Take a gaussoid and a list of squares and make all squares
# to zero in that gaussoid.
multi MAIN ($G, *@spec where { .elems && .all ~~ /^ <[01*]>+ $/ }, Bool :$raw!) {
    my $n = chars @spec[0];
    say punch $n, $G, map { Face.from-word: $_ } @spec;
}
