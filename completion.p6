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

sub extmask ($s) is cached { /<{ $s.subst('1', '.', :g) }>/ }

# TODO: Build a static map. Hopefully `is cached' is working.
sub MinimalExtensions3 (Str $A) is cached {
    # The poset of 3-gaussoids. If we find an extension at some
    # level, we take all extensions at that level and can already
    # return, because all further extensions won't be minimal(!)
    state @Levels = [
        ["111111"],
        ["111110", "111101", "111011", "110111", "101111", "011111"],
        ["110000", "001100", "000011"],
        ["000000"],
    ];
    my @minext;
    for @Levels -> @L {
        @minext = @L.grep: * ~~ $A.&extmask;
        last if @minext;
    }
    # XXX: How to defeat Perl 6's sub resolution? I want it to be
    # as simple as @minext.map: { Gaussoid-from-string(3, $_) }
    # but that doesn't get enough type information it seems.
    my Array[Face] @res;
    for @minext {
        my Face @r = Gaussoid-from-string(3, $_);
        @res.push: @r;
    }
    return @res;
}

# Get the set of squares in a 3-faces which is not a gaussoid
# as a binary string, or Nil if @H is a gaussoid.
sub violated ($n, Face @H --> Face) {
    for Faces($n, 3) -> $c {
        return $c if Gaussoids3 !∋ Gaussoid-to-string(3, @H ↘ $c);
    }
    Nil
}

# Find a 3-face which does not contain a gaussoid and apply
# all minimal extensions of that non-gaussoid in that 3-face.
# These minimal 3-extensions apply multiple axioms at the same
# time, but all of them are necessary to complete @H to a
# gaussoid. Then the next step is performed with every set
# of squares thus obtained.
#
# It can happen that we fix the same 3-face multiple times,
# because of feedback from fixing an adjacent 3-face (which
# shares a 2-face with one we fixed previously).
sub completions-step ($n, Face @H) {
    take @H andthen return if not my $c = violated($n, @H);
    # Apply all the minimal extensions in that 3-face,
    # then continue fixing the resulting set.
    for MinimalExtensions3(Gaussoid-to-string 3, @H ↘ $c) -> $ext {
        my Face @P = @H.clone.append: $ext ↗ $c;
        @P .= unique: with => &[eqv];
        completions-step $n, @P;
    }
}

sub completions ($n, Face @H --> Seq) {
    gather { completions-step($n, @H) }
}

# Compute the set of minimal extensions to gaussoids of the given set
# of squares. This determines the poset of gaussoid extensions.
#
# Try:
#
#  1. '**000' '**100' '*01*0' '1*00*'
#       --> should have non-isomorphic minimal completions
#           of the same cardinality, namely
#           00000111000101110001011111111111111111111111111100111111111111111111111111111111
#           00100011111111111101011111111111001010111111111100010111111111111111111111111111
#       This is indeed true. These are the only two minimal extensions.
#       They have the same cardinality but are non-isomorphic.
#
#  2. '**000' '**100' '1*00*'
#       --> should have two minimal completions with
#           different cardinality.
#       This is also true. There are two minimal extensions and
#       perl -anE 'say $_ = () = /0/g' <<<"$extension" gives 12 and 7.
multi sub MAIN (*@A where { .all ~~ /^<[01*]>+$/ and .race».chars.squish == 1 }) {
    my $n = @A[0].chars;
    my Face @H <== map { Face.from-word: $_ } <== @A;

    # XXX: @H is not actually a gaussoid, but the sub works for any
    # set of squares in the n-cube. I should rename it.
    say Gaussoid-to-string($n, @H);
    say '-' x 80;
    for completions($n, @H) -> @G {
        say Gaussoid-to-string($n, @G);
        say .Str for @G;
    }
}
