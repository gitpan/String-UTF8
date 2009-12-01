#!perl -w

use strict;

use lib 't/lib', 'lib';
use myconfig;

use Test::More tests => 1;

my @import = qw(
    is_utf8
    UTF8_DISALLOW_NONCHARACTERS
);

BEGIN {
    use_ok('String::UTF8', @import);
}

