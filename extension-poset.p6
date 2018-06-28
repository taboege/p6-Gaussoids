#!/usr/bin/env perl6

# Given a set of squares on the command-line and stream of gaussoids
# on stdin, find all gaussoids which extend the set of squares, and
# print all the minima in this poset.

use experimental :cached;

# Make a regex out of the argument which matches all its extensions
sub extmask ($s) is cached { /<{ $s.subst('1', '.', :g) }>/ }

# XXX: Kind of bad. We use Posetty to select the correct implementation
# of comparison operators, but rely on the Posetties to be Str.
#
# TODO: Should make a Poset module.
role Posetty { }
multi sub infix:«≤» (Posetty $a, Posetty $b --> Bool:D) { so $b ~~ $a.&extmask  }
multi sub infix:«≥» (Posetty $a, Posetty $b --> Bool:D) { $b ≤ $a               }
multi sub infix:«∥» (Posetty $a, Posetty $b --> Bool:D) { $a !≤ $b and $1 !≥ $b }

sub MAIN (Str:D $squares where m/^ <[01]>+ $/) {
    # How to find the minima in a poset: maintain a set of current
    # minima and for each incoming object $new, iterate over all
    # current minima $min:
    #
    #   1. If $min ≤ $new, then continue with the next $new,
    #
    #   2. If we find a $min with $new ≤ $min, then replace
    #      $min by $new and delete all further $min ≥ $new,
    #
    #   3. If $new is incomparable with all current minima,
    #      then add it to the list of minima.
    #
    my SetHash $minima;
    for $*IN.lines.grep: $squares.&extmask -> $new {
        $new does Posetty;
        next if $minima.keys.any ≤ $new;
        $minima{$_}-- if $new ≤ $_ for $minima.keys;
        $minima{$new}++;
        say "added {$new}... /{$minima.elems} (it#{++$_})";
    }
}
