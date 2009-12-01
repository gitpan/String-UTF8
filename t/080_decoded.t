#!perl -w

use strict;

use lib 't/lib', 'lib';
use myconfig;

use Test::More tests => 3;

BEGIN {
    use_ok('String::UTF8', ':all');
}

sub TRUE  { !!1 };
sub FALSE { !!0 };

my $string = "\xC3\xA5"  # U+00E5 LATIN SMALL LETTER A WITH RING ABOVE
           . "\xC3\xA4"  # U+00E4 LATIN SMALL LETTER A WITH DIAERESIS
           . "\xC3\xB6"; # U+00F6 LATIN SMALL LETTER O WITH DIAERESIS

SKIP: {
    skip('requires utf8::encode', 2)
      unless defined &utf8::encode;

    is is_utf8($string), TRUE, qq<decoded UTF-8 string is valid>;
    utf8::encode($string);
    is is_utf8($string), TRUE, qq<encoded UTF-8 string is valid>;
}


