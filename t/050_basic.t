#!perl -w

use strict;

use lib 't/lib', 'lib';
use myconfig;

use Test::More tests => 74;

BEGIN {
    use_ok('String::UTF8', ':all');
}

sub PASS () { !0 }
sub FAIL () { !1 }

my @tests = (

    # test cases extracted from: <http://www.cl.cam.ac.uk/~mgk25/ucs/examples/UTF-8-test.txt>

    # 1  Some correct UTF-8 text
    [ PASS, q<CE BA E1 BD B9 CF 83 CE BC CE B5>, '1' ],

    # 2  Boundary condition test cases
    # 2.1  First possible sequence of a certain length
    [ PASS, q<00>,                      '2.1.1' ], # 2.1.1  1 byte  (U-00000000)
    [ PASS, q<C2 80>,                   '2.1.2' ], # 2.1.2  2 bytes (U-00000080)
    [ PASS, q<E0 A0 80>,                '2.1.3' ], # 2.1.3  3 bytes (U-00000800)
    [ PASS, q<F0 90 80 80>,             '2.1.4' ], # 2.1.4  4 bytes (U-00010000)
    [ FAIL, q<F8 88 80 80 80>,          '2.1.5' ], # 2.1.5  5 bytes (U-00200000)
    [ FAIL, q<FC 84 80 80 80 80>,       '2.1.6' ], # 2.1.6  6 bytes (U-04000000)

    # 2.2  Last possible sequence of a certain length
    [ PASS, q<7F>,                      '2.2.1' ], # 2.2.1  1 byte  (U-0000007F)
    [ PASS, q<DF BF>,                   '2.2.2' ], # 2.2.2  2 bytes (U-000007FF)
    [ PASS, q<EF BF BF>,                '2.2.3' ], # 2.2.3  3 bytes (U-0000FFFF) (noncharacter --chansen)
    [ FAIL, q<F7 BF BF BF>,             '2.2.4' ], # 2.2.4  4 bytes (U-001FFFFF)
    [ FAIL, q<FB BF BF BF BF>,          '2.2.5' ], # 2.2.5  5 bytes (U-03FFFFFF)
    [ FAIL, q<FD BF BF BF BF BF>,       '2.2.6' ], # 2.2.6  6 bytes (U-7FFFFFFF)

    # 2.3  Other boundary conditions
    [ PASS, q<ED 9F BF>,                '2.3.1' ], # 2.3.1  U-0000D7FF
    [ PASS, q<EE 80 80>,                '2.3.2' ], # 2.3.2  U-0000E000
    [ PASS, q<EF BF BD>,                '2.3.3' ], # 2.3.3  U-0000FFFD
    [ PASS, q<F4 8F BF BF>,             '2.3.4' ], # 2.3.4  U-0010FFFF (noncharacter --chansen)
    [ FAIL, q<F4 90 80 80>,             '2.3.5' ], # 2.3.5  U-00110000

    # 3  Malformed sequences
    # 3.1  Unexpected continuation bytes
    [ FAIL, q<80>,                      '3.1.1' ], # 3.1.1  First continuation byte 0x80
    [ FAIL, q<BF>,                      '3.1.2' ], # 3.1.2  Last  continuation byte 0xbf

    [ FAIL, q<80 BF>,                   '3.1.3' ], # 3.1.3  2 continuation bytes
    [ FAIL, q<80 BF 80>,                '3.1.4' ], # 3.1.4  3 continuation bytes
    [ FAIL, q<80 BF 80 BF>,             '3.1.5' ], # 3.1.5  4 continuation bytes
    [ FAIL, q<80 BF 80 BF 80>,          '3.1.6' ], # 3.1.6  5 continuation bytes
    [ FAIL, q<80 BF 80 BF 80 BF>,       '3.1.7' ], # 3.1.7  6 continuation bytes
    [ FAIL, q<80 BF 80 BF 80 BF 80>,    '3.1.8' ], # 3.1.8  7 continuation bytes

    # 3.1.9  Sequence of all 64 possible continuation bytes (0x80-0xbf)
    [ FAIL, q<80 81 82 83 84 85 86 87 88 89 8A 8B 8C 8D 8E 8F
              90 91 92 93 94 95 96 97 98 99 9A 9B 9C 9D 9E 9F
              A0 A1 A2 A3 A4 A5 A6 A7 A8 A9 AA AB AC AD AE AF
              B0 B1 B2 B3 B4 B5 B6 B7 B8 B9 BA BB BC BD BE BF>, '3.1.9' ],

    # 3.2  Lonely start characters
    # 3.2.1  All 32 first bytes of 2-byte sequences (0xc0-0xdf),
    #        each followed by a space character:
    [ FAIL, q<C0 20 C1 20 C2 20 C3 20 C4 20 C5 20 C6 20 C7 20 C8 20 C9 20 CA 20 CB 20 CC 20 CD 20 CE 20 CF 20
              D0 20 D1 20 D2 20 D3 20 D4 20 D5 20 D6 20 D7 20 D8 20 D9 20 DA 20 DB 20 DC 20 DD 20 DE 20 DF 20>, '3.2.1' ],

    # 3.2.2  All 16 first bytes of 3-byte sequences (0xe0-0xef),
    #        each followed by a space character:
    [ FAIL, q<E0 20 E1 20 E2 20 E3 20 E4 20 E5 20 E6 20 E7 20 E8 20 E9 20 EA 20 EB 20 EC 20 ED 20 EE 20 EF 20>, '3.2.2' ],

    # 3.2.3  All 8 first bytes of 4-byte sequences (0xf0-0xf7),
    #        each followed by a space character:
    [ FAIL, q<F0 20 F1 20 F2 20 F3 20 F4 20 F5 20 F6 20 F7 20>, '3.2.3' ],

    # 3.2.4  All 4 first bytes of 5-byte sequences (0xf8-0xfb),
    #        each followed by a space character:
    [ FAIL, q<F8 20 F9 20 FA 20>, '3.2.4' ],

    # 3.2.5  All 2 first bytes of 6-byte sequences (0xfc-0xfd),
    #        each followed by a space character:
    [ FAIL, q<FC 20 FD 20>, '3.2.5' ],

    # 3.3  Sequences with last continuation byte missing
    [ FAIL, q<C0>,                  '3.3.1' ], # 3.3.1  2-byte sequence with last byte missing (U+0000)
    [ FAIL, q<E0 80>,               '3.3.2' ], # 3.3.2  3-byte sequence with last byte missing (U+0000)
    [ FAIL, q<F0 80 80>,            '3.3.3' ], # 3.3.3  4-byte sequence with last byte missing (U+0000)
    [ FAIL, q<F8 80 80 80>,         '3.3.4' ], # 3.3.4  5-byte sequence with last byte missing (U+0000)
    [ FAIL, q<FC 80 80 80 80>,      '3.3.5' ], # 3.3.5  6-byte sequence with last byte missing (U+0000)
    [ FAIL, q<DF>,                  '3.3.6' ], # 3.3.6  2-byte sequence with last byte missing (U-000007FF)
    [ FAIL, q<EF BF>,               '3.3.7' ], # 3.3.7  3-byte sequence with last byte missing (U-0000FFFF)
    [ FAIL, q<F7 BF BF>,            '3.3.8' ], # 3.3.8  4-byte sequence with last byte missing (U-001FFFFF)
    [ FAIL, q<FB BF BF BF>,         '3.3.9' ], # 3.3.9  5-byte sequence with last byte missing (U-03FFFFFF)
    [ FAIL, q<FD BF BF BF BF>,      '3.3.10'], # 3.3.10 6-byte sequence with last byte missing (U-7FFFFFFF)

    # 3.4  Concatenation of incomplete sequences
    # All the 10 sequences of 3.3 concatenated
    [ FAIL, q<C0 E0 80 F0 80 80 F8 80 80 80 FC 80 80 80 80 DF EF BF F7 BF BF FB BF BF BF FD BF BF BF BF>, '3.4' ],

    # 3.5  Impossible bytes
    # The following two bytes cannot appear in a correct UTF-8 string
    [ FAIL, q<FE>,                  '3.5.1' ], # 3.5.1
    [ FAIL, q<FF>,                  '3.5.2' ], # 3.5.2
    [ FAIL, q<FE FE FF FF>,         '3.5.3' ], # 3.5.3

    # 4  Overlong sequences 
    # 4.1  Examples of an overlong ASCII character 
    [ FAIL, q<C0 AF>,               '4.1.1' ], # 4.1.1 U+002F
    [ FAIL, q<E0 80 AF>,            '4.1.2' ], # 4.1.2 U+002F
    [ FAIL, q<F0 80 80 AF>,         '4.1.3' ], # 4.1.3 U+002F
    [ FAIL, q<F8 80 80 80 AF>,      '4.1.4' ], # 4.1.4 U+002F
    [ FAIL, q<FC 80 80 80 80 AF>,   '4.1.5' ], # 4.1.5 U+002F

    # 4.2  Maximum overlong sequences
    [ FAIL, q<C1 BF>,               '4.2.1' ], # 4.2.1  U-0000007F
    [ FAIL, q<E0 9F BF>,            '4.2.2' ], # 4.2.2  U-000007FF
    [ FAIL, q<F0 8F BF BF>,         '4.2.3' ], # 4.2.3  U-0000FFFF
    [ FAIL, q<F8 87 BF BF BF>,      '4.2.4' ], # 4.2.4  U-001FFFFF
    [ FAIL, q<FC 83 BF BF BF BF>,   '4.2.5' ], # 4.2.5  U-03FFFFFF

    # 5  Illegal code positions
    # 5.1 Single UTF-16 surrogates
    [ FAIL, q<ED A0 80>,            '5.1.1' ], # 5.1.1  U+D800
    [ FAIL, q<ED AD BF>,            '5.1.2' ], # 5.1.2  U+DB7F
    [ FAIL, q<ED AE 80>,            '5.1.3' ], # 5.1.3  U+DB80
    [ FAIL, q<ED AF BF>,            '5.1.4' ], # 5.1.4  U+DBFF
    [ FAIL, q<ED B0 80>,            '5.1.5' ], # 5.1.5  U+DC00
    [ FAIL, q<ED BE 80>,            '5.1.6' ], # 5.1.6  U+DF80
    [ FAIL, q<ED BF BF>,            '5.1.7' ], # 5.1.7  U+DFFF

    # 5.2 Paired UTF-16 surrogates
    [ FAIL, q<ED A0 80 ED B0 80>,   '5.2.1' ], # 5.2.1  U+D800 U+DC00
    [ FAIL, q<ED A0 80 ED BF BF>,   '5.2.2' ], # 5.2.2  U+D800 U+DFFF
    [ FAIL, q<ED AD BF ED B0 80>,   '5.2.3' ], # 5.2.3  U+DB7F U+DC00
    [ FAIL, q<ED AD BF ED BF BF>,   '5.2.4' ], # 5.2.4  U+DB7F U+DFFF
    [ FAIL, q<ED AE 80 ED B0 80>,   '5.2.5' ], # 5.2.5  U+DB80 U+DC00
    [ FAIL, q<ED AE 80 ED BF BF>,   '5.2.6' ], # 5.2.6  U+DB80 U+DFFF
    [ FAIL, q<ED AF BF ED B0 80>,   '5.2.7' ], # 5.2.7  U+DBFF U+DC00
    [ FAIL, q<ED AF BF ED BF BF>,   '5.2.8' ], # 5.2.8  U+DBFF U+DFFF

    # 5.3 Other illegal code positions (not illegal, these are noncharacters -- chansen)
    [ PASS, q<EF BF BE>,            '5.3.1' ], # 5.3.1  U+FFFE
    [ PASS, q<EF BF BF>,            '5.3.2' ], # 5.3.2  U+FFFF
);

foreach my $test (@tests) {
    my ($expected, $hex_sequence, $test_no) = @$test;

    my $string = join '', map { chr hex } split /\s+/, $hex_sequence;

    is is_utf8($string), $expected, qq<Test no: $test_no>;
}

