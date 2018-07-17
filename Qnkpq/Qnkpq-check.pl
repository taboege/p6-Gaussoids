#!/usr/bin/perl -an

use Modern::Perl;

next if /^#/;
chomp;
my ($in, $out) = split /\t+/;
$_ = `PERL6LIB=lib ./Qnkpq-deg.p6 --formula $in`;
chomp;
/(\d+)$/;
say "$in: " . ($out == $1 ? "PASS" : "FAIL");
