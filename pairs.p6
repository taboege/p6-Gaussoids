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
sub MAIN (Int $n where * ≥ 4) {
    my $d = Face.new: :$n, :I(2..$n), :K();
    for $*IN.lines {
        my Face @G = Gaussoid-from-string($n, $_);
        print Gaussoid-to-string($n - 1, @G ↘ $d);
        print " ";
        print Gaussoid-to-string($n - 1, @G ↘ $d°);
        NEXT say "";
    }
}
