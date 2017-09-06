# ========================================================================== #
# lib/JPList.pm  - JPList Main Module
# Copyright (C) 2017 Exceleron Software, LLC
# ========================================================================== #

package JPList;

use Moose;
use namespace::autoclean;

use JPList::Request;

with 'JPList::DB::Config';
with 'JPList::DB::Result';

# ========================================================================== #

=head1 NAME

JPList - JPList Main Module 

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

    my $jplist = JPList->new(
                {
                    db_shard_type  => 'System/MDM/Alerts',
                    db_shard_id    => <SHARD_ID>,
                    db_table_name  => <TABLE/VIEW>,
                    fields         => <Custom fields or custom query>,
                    where_fields   => <WHERE FIELDS like UtilityID etc..>,
                    request_params => <JPList request params statuses>
                }
            );

=head1 DESCRIPTION

    my $jplist = JPList->new({});
    $jplist->get_resultset();

=head2 ATTRIBUTES

=over 4

=cut

# ========================================================================== #

has 'request_params' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

has 'jplist_request' => (
    is      => 'ro',
    isa     => 'JPList::Request',
    builder => '_build_jplist_request',
    lazy    => 1
);

# ========================================================================== #

=head2 methods

=over 4

=cut

# ========================================================================== #

=item C<_build_jplist_request>

Params : NONE

Returns: Object of JPList::Request

Desc   : Decode the Request params and return Object of JPList::Request

=cut

sub _build_jplist_request
{

    my $self = shift;

    my $jplist_req = JPList::Request->new(request_params => $self->request_params);
    $jplist_req->decode_data();
    return $jplist_req;
}

# ========================================================================== #

=item C<get_resultset>

Params : $self->request_params

Returns: Resultset data from table/view based on the request params

Desc   : Resultset data from table/view based on the request params

=cut

sub get_resultset
{
    my $self = shift;

    my $data = $self->_get_resultset($self->jplist_request);

    return $data;
}

1;

__END__

=back
   
=head1 AUTHORS

Sheeju Alex, <sheeju@exceleron.com>

=head1 BUGS

https://github.com/sheeju/JPList/issues

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc JPList


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=JPList>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/JPList>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/JPList>

=item * Search CPAN

L<http://search.cpan.org/dist/JPList/>

=back

=head1 ACKNOWLEDGEMENTS

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2017 Exceleron Software, LLC

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut

# vim: ts=4
# vim600: fdm=marker fdl=0 fdc=3
