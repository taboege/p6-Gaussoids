multi sub circumfix:<[ ]> (Int $n) is export { 1..$n }

# This is a k-face of the n-cube, which might as well be the
# entire cube.
class Face is export {
    has Int $.n is required; # ambient dimension
    has Int $.k;             # face dimension

    # The following three sets must be a partition of [n].
    has Int @.I is required; # positions of *
    has Int @.K is required; # positions of 1
    has Int @.K̃; # positions of 0

    submethod TWEAK {
        $!k = @!I.elems;
        @!K̃ = ([$!n] ∖ @!I ∖ @!K).keys;
        # Sanity check
        die "Inconsistent face definition"
            unless [$!n] == @!I ⊎ @!K ⊎ @!K̃;
    }

    # Represent the face as a CI symbol [I|K] as well as a string
    # of length $!n over {0,1,*} with exactly |I|-many '*' symbols.
    method Str {
        # XXX: This doesn't use the indices stored in @!I, @!K, @!K̃
        # but their relative positions to each other.
        my @map = @!I => '*', @!K => '1', @!K̃ => '0';
        @map.map: { slip .key X .value } ==>
        sort *[0] ==> map *[1] ==>
        join '' ==> my $word;
        # XXX: The symbol notation [I|K] assumes single-digit numbers.
        "[{@!I.sort.join}|{@!K.sort.join}]($word)"
    }
}

# Authoritative ordering of the k-faces of the n-cube
# used to convert between set of faces and binary string.
# It is crucial that this yields the same ordering as the
# one on https://www.gaussoids.de/gaussoids.html because
# we use those as input files.
sub Faces($n, $k) is export {
    return gather {
        for [$n].combinations($k) -> @I {
            for ([$n] ⊖ @I).keys.sort.combinations -> @K {
                take Face.new: :$n, :$k,
                    :I(@I.sort), :K(@K.sort);
            }
        }
    }
}

# Returns whether the face $F embeds the face $a
# on the n-cube.
multi sub infix:<⊆> (Face $a, Face $F) is export {
    $a.I ⊆ $F.I and
    $a.K ⊆ $F.I ∪ $F.K and
    $a.K̃ ⊆ $F.I ∪ $F.K̃
}

# Get all faces contained in F, then project down to the
# free coordinates of $F. This takes an $F.k-dimensional
# slice out of @faces.
multi sub infix:<↾> (Face @faces, Face $F) is export {
    my @contained = @faces.grep: * ⊆ $F;
    return gather {
        for @contained -> $a {
            my (@I, @K);
            my $i = 1;
            for $F.I {
                # TODO: `given $_' seems like a no-op.
                # Can't we use `when' clauses directly?
                given $_ {
                    when * ∈ $a.I { @I.push: $i }
                    when * ∈ $a.K { @K.push: $i }
                }
                $i++;
            }
            take Face.new: :n($F.k), :@I, :@K;
        }
    }
}

# New notation, preferred (by me)
multi sub infix:<↘> (|c) is export { &infix:<↾>(|c) }

# The inverse to ↘: it takes a set of faces of the $F.k-cube
# and embeds them into the $F.n-cube, precisely into the
# $F.k-face $F.
multi sub infix:<↗> (Face @faces, Face $F) is export {
    return gather {
        for @faces -> $a {
            my (@I, @K);
            @I = $F.I[$a.I »-» 1];
            @K = |$F.I[$a.K »-» 1], |$F.K;
            take Face.new: :n($F.n), :@I, :@K;
        }
    }
}
