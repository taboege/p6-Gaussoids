#!/usr/bin/env perl6

use Cube;

#my $F = Face.new: :5n, :I(1,2,3), :K(5);
#say ~$F;

# This is a good test:
#   my $s = "000000000000111100111111";
#   my @G = Gaussoid-from-string($s);
#   my $t = Gaussoid-to-string(@G);
#   say $s;
#   say $t;
#   .Str.say for @G;
#
#   000000000000111100111111
#   000000000000111100111111
#   [23|](0**0)
#   [23|1](1**0)
#   [23|4](0**1)
#   [23|14](1**1)
#   [24|3](0*1*)
#   [24|13](1*1*)
#   [34|](00**)
#   [34|1](10**)
#   [34|2](01**)
#   [34|12](11**)
#
# (verified with the gaussoid-tools.sage which generated
# the input bitstring).

my \Gaussoids3 = "000000", "000011",
       "001100", "011111", "101111",
       "110000", "110111", "111011",
       "111101", "111110", "111111";

use experimental :cached;

sub Squares ($n) is cached { Faces($n, 2) }

sub Gaussoid-from-string ($n, $_) {
    Squares($n)[(m:g/0/)».from];
}

multi sub Gaussoid-to-string ($n, @G) {
    # TODO: Get rid of all the string conversions.
    # I'd like to get the indices in Squares of the
    # faces in @G but it looks like objects aren't
    # compared by their attributes...?
    my $s = '1' x Squares($n).elems;
    return $s unless @G;
    my @active = @G.map: { Squares($n).first(:k, * eq $_) };
    $s.substr-rw($_,1) = '0' for @active;
    $s;
}

multi sub MAIN ("3-stats", Int $n) {
    my @stats = 0 xx Gaussoids3;
    for $*IN.lines {
        # @G is a gaussoid.
        my Face @G = Gaussoid-from-string($n, $_);
        for Faces($n, 3) -> $face {
            my $c = Gaussoid-to-string(3, @G ↾ $face);
            next unless $c;
            die "Input '$c' is not a gaussoid!?" unless Gaussoids3 ∋ $c;
            @stats[Gaussoids3.first(:k, $c)]++;
        }
    }
    .say for Gaussoids3 Z @stats;

    # $ PERL6LIB=lib ./test.p6 3-stats 4 <cnf4-list.txt
    #
    # (000000 64)
    # (000011 120)
    # (001100 120)
    # (011111 592)
    # (101111 592)
    # (110000 120)
    # (110111 592)
    # (111011 592)
    # (111101 592)
    # (111110 592)
    # (111111 1456)
    #
}

multi sub MAIN ("plot3") {
    my %Squares =
        'bottom' => Face.new(:3n, :I(1,2), :K()),
        'top'    => Face.new(:3n, :I(1,2), :K(3)),
        'front'  => Face.new(:3n, :I(1,3), :K()),
        'back'   => Face.new(:3n, :I(1,3), :K(2)),
        'left'   => Face.new(:3n, :I(2,3), :K()),
        'right'  => Face.new(:3n, :I(2,3), :K(1)),
    ;
    for Gaussoids3.map({ Gaussoid-from-string(3, $_) }).deepmap(*.Str) -> @G {
        my $faces = @G.Set;
        say '\cube{%';
        say '  scale=1.3,';
        for %Squares.kv -> $where, $f {
            print "  $where/.style=";
            print ~$f ∈ $faces ?? '{purple!30!blue!30!white,opacity=0.5}'
                               !! '{gray,opacity=0.5}';
            say ',';
        }
        say '}';
    }
}
