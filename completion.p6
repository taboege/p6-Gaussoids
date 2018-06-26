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
    # Start with the set of squares:
    #
    #   **000
    #   **100  -- these two are in ***00
    #   *01*0  -- from incident *0**0
    #   1*00*  -- from incident 1**0*
    #
    # and pursue two different ways (by way of axiom (G4))
    # of completing it to a gaussoid. The two gaussoids below
    # have the same number of squares but they are not isomorphic
    # because they have different numbers of squares with |K|=2.
    #
    # TODO: I forgot: did I make choices (apply (G4)) while
    # completing the gaussoids below by hand, or were all further
    # choices deterministic?
    #
    # In the paper, it will probably be better to show the whole
    # lattice of gaussoids which extend the base given above.
    # That can be extracted by pattern matching from the list of
    # 5-gaussoids.
    my Face @G =
        # -- Base in ***00
        Face.new(:5n, :I(1,2), :K()),
        Face.new(:5n, :I(1,2), :K(3)),
        # -- Base in *0**0
        Face.new(:5n, :I(1,4), :K(3)),
        # -- Base in 1**0*
        Face.new(:5n, :I(2,5), :K(1)),
        # -- Application of (G4) in ***00
        Face.new(:5n, :I(1,3), :K()),
        Face.new(:5n, :I(1,3), :K(2)),
        # -- Completion in *0**0
        Face.new(:5n, :I(1,3), :K(4)),
        Face.new(:5n, :I(1,4), :K()),
        # --- Iterative completion (done by hand) to make a gaussoid
        Face.new(:5n, :I(1,2), :K(4)),
        Face.new(:5n, :I(1,4), :K(2)),
        Face.new(:5n, :I(1,2), :K(3,4)),
        Face.new(:5n, :I(1,3), :K(2,4)),
        Face.new(:5n, :I(1,4), :K(2,3)),
        Face.new(:5n, :I(1,2), :K(5)),
        Face.new(:5n, :I(2,5), :K()),
    ;
    my Face @H =
        # -- Base in ***00
        Face.new(:5n, :I(1,2), :K()),
        Face.new(:5n, :I(1,2), :K(3)),
        # -- Base in *0**0
        Face.new(:5n, :I(1,4), :K(3)),
        # -- Bas ein 1**0*
        Face.new(:5n, :I(2,5), :K(1)),
        # -- Application of (G4) in ***00
        Face.new(:5n, :I(2,3), :K()),
        Face.new(:5n, :I(2,3), :K(1)),
        # -- Completion in 1**0*
        Face.new(:5n, :I(2,5), :K(1,3)),
        Face.new(:5n, :I(2,3), :K(1,5)),
        # --- Iterative completion (done by hand) to make a gaussoid
        Face.new(:5n, :I(1,2), :K(3,4)),
        Face.new(:5n, :I(1,4), :K(2,3)),
        Face.new(:5n, :I(1,2), :K(5)),
        Face.new(:5n, :I(2,5), :K()),
        Face.new(:5n, :I(2,3), :K(5)),
        Face.new(:5n, :I(1,2), :K(3,5)),
        Face.new(:5n, :I(2,5), :K(3)),
    ;

    say Gaussoid-to-string(5, @G);
    for Faces(5, 3) -> $c {
        if Gaussoids3 !∋ Gaussoid-to-string(3, my Face @F = @G ↘ $c) {
            print "violated at $c with {Gaussoid-to-string(3, @F)} which is: ";
            print "\{ { @G.grep(* ⊆ $c)».Str.join(', ') } \}";
            say "";
            #say "check";
            #.Str.say for @F ↗ $c;
        }
    }

    say '-' x 80;

    say Gaussoid-to-string(5, @H);
    for Faces(5, 3) -> $c {
        if Gaussoids3 !∋ Gaussoid-to-string(3, my Face @F = @H ↘ $c) {
            print "violated at $c with {Gaussoid-to-string(3, @F)} which is: ";
            print "\{ { @H.grep(* ⊆ $c)».Str.join(', ') } \}";
            say "";
        }
    }
}
