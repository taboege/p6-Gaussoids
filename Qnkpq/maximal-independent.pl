#!/usr/bin/perl

use Modern::Perl;

my %vertex;
while (<>) {
    chomp;
    warn "Bogus line '$_'" and next unless /^([01*]+): (.*)$/;
    my @adj = split /, /, $2;
    $vertex{$1} = \@adj;
}

while (%vertex) {
    my $v = (keys %vertex)[0];
    say $v;
    delete $vertex{$_} for @{$vertex{$v}};
    delete $vertex{$v};
}
