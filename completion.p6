#!/usr/bin/env perl6

# FIXME: The algorithm is broken, it doesn't do what it advertises.
# It finds a bunch of gaussoid extensions to a set of squares, but
# they are not guaranteed to be all minimal extensions, i.e.
# gaussoid closures, and some might be repeated.
#
# All minimal closures are among the output, though.

use lib 'lib';
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
sub extensions-step ($n, Face @H) {
    take @H andthen return if not my $c = violated($n, @H);
    # Apply all the minimal extensions in that 3-face,
    # then continue fixing the resulting set.
    for MinimalExtensions3(Gaussoid-to-string 3, @H ↘ $c) -> $ext {
        my Face @P = @H.clone.append: $ext ↗ $c;
        @P .= unique: with => &[eqv];
        extensions-step $n, @P;
    }
}

# Return as-few-as-we-can extensions of the given set of squares.
# It is guaranteed that all minimal extensions are among the
# ones we return, but there might be non-minimal ones.
sub extensions ($n, Face @H --> Seq) {
    gather { extensions-step($n, @H) }
}

# Filter the result of &extensions to produce only the minimal extensions,
# i.e. completions or closures of the given set of squares @H.
#
# This step is expensive as it uses a buffer (not a Seq) of linear size
# in the number of &extensions obtained and quadratic time. Would like to
# know how many extensions I should expect as a function of $n.
#
# The filtering is necessary, for without it, we don't get minimal
# extensions only, as this example shows:
#
#   $ ./completion.p6 --binary 4 111111111111000000000000  # version calling extensions directly
#   111111111111000000000000
#   --------------------------------------------------------------------------------
#   111100000000000000000000
#   000000000000000000000000
#   000000001111000000000000
#   000000001111000000000000
#   000000001111000000000000
#   000011110000000000000000
#   000000001111000000000000
#
# The full gaussoid /^0+$/ is clearly not minimal. It is also not nice that
# some extensions are repeated in the output, but that would be a smaller
# problem. With the filtering in &completions, these two issues are fixed:
#
#   $ ./completion.p6 --binary 4 111111111111000000000000  # using completions
#   111111111111000000000000
#   --------------------------------------------------------------------------------
#   111100000000000000000000
#   000011110000000000000000
#   000000001111000000000000
sub completions ($n, Face @H --> Seq) {
    my @exts = extensions($n, @H);
    my @binary = @exts.map({ Gaussoid-to-string($n, $_) });
    gather {
        EXTENSION: for 0..^@exts -> $i {
            for $i^..^@exts -> $j {
                next EXTENSION if @binary[$i] ~~ @binary[$j].&extmask;
            }
            take @exts[$i];
        }
    }
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
#           00100011111111111101011111111111001010111111111100010111111111111111111111111111
#           00000111000101110001011111111111111111111111111100111111111111111111111111111111
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
#        say .Str for @G;
    }
}

multi sub MAIN (Int $n, $H, Bool :$binary!) {
    my Face @H = Gaussoid-from-string($n, $H);
    say Gaussoid-to-string($n, @H);
    say '-' x 80;
    for completions($n, @H) -> @G {
        say Gaussoid-to-string($n, @G);
#        say .Str for @G;
    }
}
