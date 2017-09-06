# ========================================================================== #
# lib/JPList/Controls/Sort.pm  - JPList Sort controls
# Copyright (C) 2017 Exceleron Software, LLC
# ========================================================================== #

package JPList::Controls::Sort;

use Moose::Role;

# ========================================================================== #

=head1 NAME

JPList::Controls::Sort - JPList Sort controls

=head1 SYNOPSIS

  with 'JPList::Controls::Sort'

=head1 DESCRIPTION

The Sort module allows you get the values sort controls

=head2 methods

=over 4

=cut

# ========================================================================== #

=item C<sortdropdown>

Params : sort_vals

	{
		'type' => 'sort-drop-down',
        'inStorage' => $VAR1->[0]{'inDeepLinking'},
        'inAnimation' => $VAR1->[0]{'inDeepLinking'},
        'name' => 'sort',
        'data' => {
                    'order' => '',
                    'type' => '',
                    'dateTimeFormat' => '',
                    'path' => 'default',
                    'ignore' => ''
                  },
        'initialIndex' => 1,
        'inDeepLinking' => $VAR1->[0]{'inDeepLinking'},
        'action' => 'sort',
        'isAnimateToTop' => $VAR1->[0]{'isAnimateToTop'}
      }

Returns: Returns the column and value for order

Desc   : Returns the column and value for order

=cut

sub sortdropdown
{
    my ($self, $sort_vals) = @_;

    my $data = $sort_vals->{'data'};
    my $result;
    my $order = "asc";

    if ($data && exists($data->{'path'}) && $data->{'path'}) {

        $result->{'column'} = $data->{'path'};
        $result->{'column'} =~ s/\.//;

        if (exists($data->{'order'})) {
            $order = lc($data->{'order'});
        }

        $result->{'order'} = ($order eq "desc") ? "desc" : "asc";
    }

    return $result;
}

# ========================================================================== #

=item C<sortselect>

Params : sort_vals

	{
        'type' => 'sort-select',
        'action' => 'sort',
        'inStorage' => bless( do{\(my $o = 1)}, 'JSON::PP::Boolean' ),
        'data' => {
                    'order' => '',
                    'type' => '',
                    'dateTimeFormat' => '{month}/{day}/{year}',
                    'path' => 'default',
                    'ignore' => ''
                  },
        'isAnimateToTop' => bless( do{\(my $o = 0)}, 'JSON::PP::Boolean' ),
        'inDeepLinking' => $VAR1->[0]{'inStorage'},
        'name' => 'sort',
        'inAnimation' => $VAR1->[0]{'inStorage'}
    }

Returns: Returns the column and value for order

Desc   : Returns the column and value for order

=cut

sub sortselect
{
    shift->sortdropdown(@_);
}

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

