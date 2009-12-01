package String::UTF8::PP;
use strict;
use warnings;

use Carp qw[croak];

BEGIN {
    our $VERSION   = 0.1;
    our @EXPORT_OK = qw(
        is_utf8
        UTF8_DISALLOW_NONCHARACTERS
    );

    require Exporter;
    *import = \&Exporter::import;
}

sub UTF8_DISALLOW_NONCHARACTERS () { 1 }

{
    use bytes;

    my $UTF8_1              = qr/[\x00-\x7F]/;
    my $UTF8_2              = qr/ [\xC2-\xDF] [\x80-\xBF] /x;
    my $UTF8_3              = qr/  \xE0       [\xA0-\xBF] [\x80-\xBF]
                                | [\xE1-\xEC] [\x80-\xBF] [\x80-\xBF]
                                |  \xED       [\x80-\x9F] [\x80-\xBF]
                                | [\xEE-\xEF] [\x80-\xBF] [\x80-\xBF]
                              /x;
    my $UTF8_4              = qr/  \xF0       [\x90-\xBF] [\x80-\xBF] [\x80-\xBF]
                                | [\xF1-\xF3] [\x80-\xBF] [\x80-\xBF] [\x80-\xBF]
                                |  \xF4       [\x80-\x8F] [\x80-\xBF] [\x80-\xBF]
                              /x;

    my $UTF8_3_nonchar      = qr/ \xEF \xB7 [\x90-\xAF]
                                | \xEF \xBF [\xBE-\xBF]
                              /x;

    my $UTF8_4_nonchar      = qr/  \xF0       [\x9F\xAF\xBF]     \xBF [\xBE-\xBF]
                                | [\xF1-\xF3] [\x8F\x9F\xAF\xBF] \xBF [\xBE-\xBF]
                                |  \xF4       [\x8F]             \xBF [\xBE-\xBF]
                              /x;

#   my $UTF8_3_interchange  = qr/ $UTF8_3 (?<!$UTF8_3_nonchar) /x;
    my $UTF8_3_interchange  = qr/  \xE0       [\xA0-\xBF] [\x80-\xBF]
                                | [\xE1-\xEC] [\x80-\xBF] [\x80-\xBF]
                                |  \xED       [\x80-\x9F] [\x80-\xBF]
                                |  \xEE       [\x80-\xBF] [\x80-\xBF]
                                |  \xEF (?:
                                            [\x80-\xB6\xB8-\xBE] [\x80-\xBF]
                                          |  \xB7                [\x80-\x8F\xB0-\xBF]
                                          |  \xBF                [\x80-\xBD]
                                         )
                              /x;

#   my $UTF8_4_interchange  = qr/ $UTF8_4 (?<!$UTF8_4_nonchar) /x;
    my $UTF8_4_interchange  = qr/  \xF0       (?: [\x90-\x9E\xA0-\xAE\xB0-\xBE]             [\x80-\xBF] [\x80-\xBF]
                                                | [\x9F\xAF\xBF]                        (?: [\x80-\xBE] [\x80-\xBF]
                                                                                          |  \xBF       [\x80-\xBD]))
                                | [\xF1-\xF3] (?: [\x80-\x8E\x90-\x9E\xA0-\xAE\xB0-\xBE]    [\x80-\xBF] [\x80-\xBF]
                                                | [\x8F\x9F\xAF\xBF]                    (?: [\x80-\xBE] [\x80-\xBF]
                                                                                          |  \xBF       [\x80-\xBD]))
                                |  \xF4       (?: [\x80-\x8E]                               [\x80-\xBF] [\x80-\xBF]
                                                |  \x8F                                 (?: [\x80-\xBE] [\x80-\xBF]
                                                                                          |  \xBF       [\x80-\xBD]))
                              /x;

    my $UTF8                = qr/ $UTF8_1 | $UTF8_2 | $UTF8_3 | $UTF8_4 /x;
    my $UTF8_interchange    = qr/ $UTF8_1 | $UTF8_2 | $UTF8_3_interchange | $UTF8_4_interchange /x;
    my $UTF8_noncharacter   = qr/ $UTF8_3_nonchar | $UTF8_4_nonchar /x;
    my $UTF8_BOM            = qr/ \xEF \xBB \xBF /x;

    sub is_utf8 {
        @_ == 1 || @_ == 2 || croak(q/Usage: is_utf8(string [, flags])/);
        local $_ = $_[0];
        return ( defined 
              && ((@_ == 1 || !($_[1] & UTF8_DISALLOW_NONCHARACTERS))
                     ? /\A $UTF8* \z/xo
                     : /\A $UTF8_interchange* \z/xo ));
    }
}

1;

