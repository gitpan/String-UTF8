package String::UTF8;
use strict;
use warnings;

BEGIN {
    our $VERSION   = 0.1;
    our @EXPORT_OK = qw(
        is_utf8
        UTF8_DISALLOW_NONCHARACTERS
    );

    our %EXPORT_TAGS = (
        all => [ @EXPORT_OK ],
    );

    if ( !$ENV{STRING_UTF8_PP} ) {

        eval {
            require String::UTF8::XS;
        };
    }

    if ( $ENV{STRING_UTF8_PP} || $@ ) {
        require String::UTF8::PP;
        String::UTF8::PP->import(@EXPORT_OK);
    }
    else {
        String::UTF8::XS->import(@EXPORT_OK);
    }

    require Exporter;
    *import = \&Exporter::import;
}

1;

__END__

=head1 NAME

String::UTF8 - Determine whether a string consists of well-formed UTF-8 byte sequences

=head1 SYNOPSIS

  use String::UTF8 qw[:all];
  
  $boolean = is_utf8($string);
  $boolean = is_utf8($string, UTF8_DISALLOW_NONCHARACTERS);

=head1 DESCRIPTION

Determine whether a string consists of well-formed UTF-8 byte sequences.

=head1 FUNCTIONS

=head2 is_utf8

Determine whether C<$string> consists of well-formed UTF-8 byte sequences.

I<Usage>

    $boolean = is_utf8($string);
    $boolean = is_uft8($string, $flags);

I<Arguments>

=over 4

=item C<$string>

=item C<$flags> (optional)

=back

I<Returns>

=over 4

=item C<$boolean>

=back

I<Note>

This function ignores Perl's internal UTF-8 flag (C<SVf_UTF8>) and simply 
checks the content of the string.

=head1 CONSTANTS

=head2 FLAGS

=over 4

=item UTF8_DISALLOW_NONCHARACTERS

If this flag is set, noncharacters is not considered well-formed.

=back

=head1 EXPORT

None by default. Functions and constants can either be imported individually or
in sets grouped by tag names. The tag names are:

=over 4

=item C<:all> exports all functions and constants.

=back

=head1 DIAGNOSTICS

=over 4

=item B<(F)> Usage: %s

Subroutine %s invoked with wrong number of arguments.

=back

=head1 ENVIRONMENT

Set the environment variable C<STRING_UTF8_PP> to a true value before loading this package to disable usage of XS implementation.

=head1 PREREQUISITES

=head2 Run-Time

=over 4

=item L<perl> 5.006 or greater.

=item L<Carp>, core module.

=item L<Exporter>, core module.

=back

=head2 Build-Time

In addition to Run-Time:

=over 4

=item L<Test::More> 0.47 or greater, core module since 5.6.2.

=item L<Test::Exception>.

=back

=head1 SEE ALSO

L<String::UTF8::XS>

=head1 AUTHOR

Christian Hansen, E<lt>chansen@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Christian Hansen

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
