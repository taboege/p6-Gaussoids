#!/usr/bin/env perl6

use lib 'lib';
use Cube;

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

# List all k-minors of the n-gaussoid G given in binary.
sub MAIN ($n, $k, $G) {
    my Face @G = Gaussoid-from-string($n, $G);
    say Gaussoid-to-string($k, @G ↘ $_) for Faces($n, $k);
}
