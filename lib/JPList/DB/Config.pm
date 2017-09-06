# ========================================================================== #
# lib/JPList::DB::Config.pm  - JPList DB Config
# Copyright (C) 2017 Exceleron Software, LLC
# ========================================================================== #

package JPList::DB::Config;

use Moose::Role;
use strict;
use warnings;
use namespace::autoclean;

# ========================================================================== #

=head1 NAME

JPList::DB::Config - JPList DB Config

=head1 SYNOPSIS

  with 'JPList::DB::Config';

=head1 DESCRIPTION

The JPList::DB::Config module allows you store the DB Config

=head2 ATTRIBUTES

=over 4

=cut

# ========================================================================== #

has 'dbh' => (
    is      => 'rw',
    required => 1,
);


has 'db_table_name' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

has 'fields' => (
    is => 'rw',
    documentation =>
'fields as per SQL::Abstract it can be array of fields (which will be joined and quoted) or plain scalar (literal SQL, not quoted)'
);

has 'where_fields' => (
    is      => 'rw',
    default => sub {
        return {};
    },
    documentation => 'Custom Where fields like UtilityId etc..'
);

has 'group_fields' => (
    is            => 'rw',
    documentation => 'Custom group by fields like UtilityId, AccountId etc..'
);

has 'order_index' => (
    is => 'rw',
    documentation =>
      'Custom order index to sort by order index instad of column name to support quries with custom fields'
);

# ========================================================================== #

1;

__END__

=back
   
=head1 LICENSE

Copyright (C) 2017 Exceleron Software, LLC

=head1 AUTHORS

Sheeju Alex, <sheeju@exceleron.com>

=head1 SEE ALSO

=cut

# vim: ts=4
# vim600: fdm=marker fdl=0 fdc=3
