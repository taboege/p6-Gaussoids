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

# Join all images of G under π. This is not necessarily a gaussoid.
sub orbit-join (Face @G, @π, :$limit = Inf) {
    my Set $H;
    loop {
        $H ∪= @G;
        last if $H<> eqv ENTER $H<>;
        last if ++$ == $limit;
        @G .= map: { $_ ⤩ @π };
    }
    $H.keys.&(Array[Face])
}

multi MAIN ($perm, $G where /^<[01]>+$/, :$limit = Inf) {
    my $n = $perm.chars;
    my Face @G = Gaussoid-from-string($n, $G);
    my @π = $perm.comb».Int;
    say Gaussoid-to-string($n, orbit-join(@G, @π, :$limit));
}

multi MAIN ($perm, *@F where { .all ~~ /<[01*]>/ }, :$limit = Inf) {
    my $n = $perm.chars;
    my Face @G = @F».&{Face.from-word: $_};
    my @π = $perm.comb».Int;
    say Gaussoid-to-string($n, orbit-join(@G, @π, :$limit));
}
