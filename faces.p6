#!/usr/bin/env perl6

sub faces ($n, $k) {
    # Kinda bad to generate all 3^n words and filter them to get
    # those (n choose k)*2^(n-k) faces we want. Better construct
    # them explicitly using nested loops and subsets.
    # But it's only used once here.
    ([X] '01*'.comb xx $n).grep(*.grep('*') == $k)».join;
}

sub share-face ($f, $g, $k --> Bool) {
    my @F = $f.comb; my @G = $g.comb;
    my @cube = '*' xx @F;
    # Do they intersect at all? The '0' and '1' must match,
    # except where one of them has a star.
    return False if (@F Z @G).grep({ not .any eq '*' || .[0] eq .[1] });
    # Check dimension of intersection
    my @shared-stars = [Zeq] @cube, @F, @G;
    @shared-stars.grep(*.so) >= $k;
}

# Given a collection of k-faces of the n-cube, list all 3-faces
# which share a 2-face (not necessarily the same) with at least
# two different k-faces in the given collection.
sub MAIN (*@F where { .all ~~ /^<[01*]>+$/ and .race».chars.squish == 1 }) {
    my $n = @F[0].chars;
    for faces($n, 3) -> $a {
        my @sharing = @F.grep: *.&share-face($a, 2);
        if @sharing > 1 {
            say "$a shares a 2-face with { @sharing.join: ', ' }";
        }
    }
}
