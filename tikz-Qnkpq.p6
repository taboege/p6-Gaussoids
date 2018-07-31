#!/usr/bin/env perl6

use lib 'lib';
use Cube;

my @faces;

use experimental :cached;

use MONKEY-TYPING;
augment class Face {
    method gist {
        my @map = @!I => '*', @!K => '1', @!K̃ => '0';
        @map.map: { slip .key X .value } ==>
        sort *[0] ==> map *[1] ==>
        join '' ==> return;
    }
}

sub label (Str() $s) is cached {
    "N" ~ @faces.first(:k, $s);
}

multi sub MAIN ($n, $k) {
    @faces = Faces($n, $k)».gist;
    my rule adj-list { $<node>=<[01*]>+ ':' [ $<adj>=<[01*]>+ ]* % ',' };

    print q:to/END/;
    \GraphInit[vstyle=Classic]
    \SetUpVertex[NoLabel]
    \tikzset{VertexStyle/.append style={draw,shape=circle,fill=black,minimum size=3pt,inner sep=0}}
    \SetUpEdge[style={ultra thin}]
    \grEmptyCycle[prefix=N]{40}
    END
    for $*IN.lines.map(* ~~ &adj-list) -> $/ {
        say qq:!b"\Edge({$<node>.&label})({$_.&label})" for $<adj>;
    }
}
