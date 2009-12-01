#!perl -w

use strict;

use lib 't/lib', 'lib';
use myconfig;

use Test::More tests => 2;
use Test::Exception;

BEGIN {
    use_ok('String::UTF8', ':all');
}

my @functions = qw(
    is_utf8
);

foreach my $name (@functions) {
    my $code = __PACKAGE__->can($name);
    throws_ok { $code->() } qr/^Usage: /, "$name() whithout arguments throws an usage exception";
}

