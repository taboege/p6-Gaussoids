#!/usr/bin/env perl6

use Cube;

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

multi sub MAIN {
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
