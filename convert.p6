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

# Converts the set of squares given in binary notation into
# a list of squares.
#
# E.g. the 3-separation graphoids:
# while read G; do echo $G:; ./convert.p6 --binary=3 $G; echo; done <<EOF
# 000000
# 000011
# 001100
# 101111
# 110000
# 111011
# 111110
# 111111
# EOF
#
multi sub MAIN ($G where m/^ <[01]>+ $/, Int :binary(:$n)!) {
    Gaussoid-from-string($n, $G).deepmap(*.Str)».say;
}

# Same as --binary but we don't care about it being zeros and ones.
# Find any zeros and report the corresponding squares.
multi sub MAIN ($O, Int :raw(:$n)!) {
    my @O = $O.comb;
    say join " ", ~« Squares($n).grep({ @O[$++] eq '0' })
}

# Converts a set of squares of the n-cube into the binary
# notation according to the authoritative ordering of squares.
#
# E.g. ./convert.p6 --squares=3 '**1' '**0'
# > 001111
multi sub MAIN (*@F where { .all ~~ /<[01*]>/ }, Int :squares(:$n)!) {
    Gaussoid-to-string($n, @F».&{Face.from-word: $_}).say;
}
