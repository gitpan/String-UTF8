#!perl -w

use strict;

use lib 't/lib', 'lib';
use myconfig;

use Test::More tests => (66 * 2) + 1;

BEGIN {
    use_ok('String::UTF8', ':all');
}

my @nonchars = (
    0xFDD0 .. 0xFDEF,
    0xFFFE,   0xFFFF,
    0x1FFFE,  0x1FFFF,
    0x2FFFE,  0x2FFFF,
    0x3FFFE,  0x3FFFF,
    0x4FFFE,  0x4FFFF,
    0x5FFFE,  0x5FFFF,
    0x6FFFE,  0x6FFFF,
    0x7FFFE,  0x7FFFF,
    0x8FFFE,  0x8FFFF,
    0x9FFFE,  0x9FFFF,
    0xAFFFE,  0xAFFFF,
    0xBFFFE,  0xBFFFF,
    0xCFFFE,  0xCFFFF,
    0xDFFFE,  0xDFFFF,
    0xEFFFE,  0xEFFFF,
    0xFFFFE,  0xFFFFF,
    0x10FFFE, 0x10FFFF
);

foreach my $cp (@nonchars) {
    my $chr = utf8_chr($cp);
    is is_utf8($chr), !!1, sprintf('is_utf8(U+%.4X) == true', $cp);
    is is_utf8($chr, UTF8_DISALLOW_NONCHARACTERS), !!0, sprintf('is_utf8(U+%.4X, UTF8_DISALLOW_NONCHARACTERS) == false', $cp);
}

sub utf8_chr {
    @_ == 1 || die(q/Usage: utf8_chr($cp)/);
    my ($cp) = @_;

    if ($cp < 0x80) {
        return pack('C1', $cp);
    }
    elsif ($cp < 0x800) {
        return pack('C2', 0xC0 |  ($cp >> 6),
                          0x80 |  ($cp        & 0x3F));
    }
    elsif ($cp < 0x10000) {
        return pack('C3', 0xE0 |  ($cp >> 12),
                          0x80 | (($cp >>  6) & 0x3F),
                          0x80 | ( $cp        & 0x3F));
    }
    elsif ($cp < 0x200000) {
        return pack('C4', 0xF0 |  ($cp >> 18),
                          0x80 | (($cp >> 12) & 0x3F),
                          0x80 | (($cp >>  6) & 0x3F),
                          0x80 | ( $cp        & 0x3F));
    }
    elsif ($cp < 0x4000000) {
        return pack('C5', 0xF8 |  ($cp >> 24),
                          0x80 | (($cp >> 18) & 0x3F),
                          0x80 | (($cp >> 12) & 0x3F),
                          0x80 | (($cp >>  6) & 0x3F),
                          0x80 | ( $cp        & 0x3F));

    }
    elsif ($cp < 0x80000000) {
        return pack('C6', 0xFE |  ($cp >> 30),
                          0x80 | (($cp >> 24) & 0x3F),
                          0x80 | (($cp >> 18) & 0x3F),
                          0x80 | (($cp >> 12) & 0x3F),
                          0x80 | (($cp >>  6) & 0x3F),
                          0x80 | ( $cp        & 0x3F));
    }

    die(q/utf8_chr(cp <= 0x7FFFFFFF)/);
}



