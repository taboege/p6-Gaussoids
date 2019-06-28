#!/usr/bin/env perl6

use lib 'lib';
use Cube;

use experimental :cached;

sub Squares ($n) #`(is cached) { Faces($n, 2) }

sub ingredients (@spec) {
    gather for @spec {
        with split(':', $_) {
            take (Face.from-word(.[0]), .[1] // '.')
        }
    }
}

sub plug ($n, $G is copy, \ingredients) {
    for ingredients -> (\β, $c) {
        my $i = Squares($n).first(* === β, :k)
            // die "did not find face { β }";
        my $rw := $G.substr-rw($i,1);
        die "attempt to overwrite non-zero" if $rw ne '0';
        $rw = $c;
    }
    $G
}

# Take a gaussoid and a list of «square:char» strings and plug the
# zeros in square's with the given char's, by default '.'
multi MAIN ($G, *@spec where { .elems && .all ~~ /^ <[01*]>+ [ ':' . ]? $/ }, Bool :$raw!) {
    my $n = chars @spec[0] ~~ /^ <( .* )> [ ':' | $ ] /;
    say plug $n, $G, ingredients @spec;
}
