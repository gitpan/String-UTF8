#!perl -w

use strict;

use lib 't/lib', 'lib';
use myconfig;

use Test::More tests => 2;

BEGIN {
    use_ok('String::UTF8');
    use_ok('String::UTF8::' . ( $ENV{STRING_UTF8_PP} ? 'PP' : 'XS' ));
}

diag("String::UTF8 $String::UTF8::VERSION, Perl $], $^X");

