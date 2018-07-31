#!/usr/bin/env perl6

use lib 'lib';
use Cube;

# TODO: This is just string indexing on steroids. It should be possible
# to make it faster somehow...

use experimental :cached;

sub Squares ($n) is cached { Faces($n, 2) }

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

# Takes dimension n and a list of n-gaussoids on stdin.
# It prints the (n-1)-gaussoids in the opposite faces
# 0***...* and 1***...*.
multi sub MAIN (Int $n where * ≥ 4, Bool :$decompose?) {
    my $d = Face.new: :$n, :I(2..$n), :K();
    for $*IN.lines {
        my Face @G = Gaussoid-from-string($n, $_);
        print Gaussoid-to-string($n - 1, @G ↘ $d);
        print " ";
        print Gaussoid-to-string($n - 1, @G ↘ $d°);
        NEXT say "";
    }
}

# Takes a pair of n-gaussoids and prints the binary indicator
# vector of squares in the (n+1)-cube where the pair was
# prescribed into 0***...* and 1***...*.
multi sub MAIN (Int $n where * ≥ 4, $G, $H, Bool :$compose!) {
    die "G and H are of different dimension" if $G.chars ≠ $H.chars;
    my $d = Face.new: :$n, :I(2..$n), :K();
    # FIXME: The type constraints in various signatures make this so ugly
    my Face @G = Gaussoid-from-string($n-1, $G);
    @G ↗= $d;
    my Face @H = Gaussoid-from-string($n-1, $H);
    @H ↗= $d°;
    say Gaussoid-to-string($n, @G.append(@H).unique);
}
