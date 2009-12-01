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

my $string = "\xE5\xE4\xF6";

SKIP: {
    skip('requires utf8::upgrade', 2)
      unless defined &utf8::upgrade;

    is is_utf8($string), FALSE, qq<ISO-8859-1 string isn't valid>;
    utf8::upgrade($string);
    is is_utf8($string), TRUE, qq<upgraded ISO-8859-1 string is valid>;
}

