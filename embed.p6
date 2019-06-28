#!/usr/bin/env perl6

use lib 'lib';
use Cube;

use experimental :cached;

sub Squares ($n) #`(is cached) { Faces($n, 2) }

multi sub raw-to-string ($n, \mapping) {
    my $s = '.' x Squares($n).elems;
    for mapping -> ($c, $i) {
        my $rw := $s.substr-rw($i,1);
        die "inconsistent square $i" if $rw ne $c | '.';
        $rw = $c;
    }
    $s
}

sub ingredients (@spec) {
    gather for @spec {
        with split(':', $_) {
            take (.[0], Face.from-word: .[1])
        }
    }
}

sub mapping (\ingredients) {
    gather for ingredients -> ($G, \Δ) {
        my @indices = Squares(Δ.n).grep: * ⊆ Δ, :k;
        take slip $G.comb Z @indices;
    }
}

# Take a list of «gaussoid:face» strings and assemble a string that
# contains each gaussoid in the given face (of a higher cube).
multi MAIN (*@spec where { .elems && .all ~~ /<[.?01+-]>+ ':' <[01*]>+/ }, Bool :$raw!) {
    my $n = chars @spec[0] ~~ / <?after ':'> .* /;
    say raw-to-string $n, mapping ingredients @spec;
}
