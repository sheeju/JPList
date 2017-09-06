# ========================================================================== #
# lib/JPList/Controls/Filter.pm  - JPList Filter controls
# Copyright (C) 2017 Exceleron Software, LLC
# ========================================================================== #

package JPList::Controls::Filter;

use Moose::Role;

# ========================================================================== #

=head1 NAME

JPList::Controls::Filter - JPList Filter controls

=head1 SYNOPSIS

  with 'JPList::Controls::Filter'

=head1 DESCRIPTION

The Filter module allows you get the values filter controls

=head2 methods

=over 4

=cut

# ========================================================================== #

=item C<textbox>

Params : filter_vals

    {
        'type' => 'textbox',
        'action' => 'filter',
        'inStorage' => $VAR1->[0]{'inStorage'},
        'data' => {
                    'filterType' => 'TextFilter',
                    'mode' => 'contains',
                    'value' => '',
                    'ignore' => '[~!@#$%^&*()+=`\'"/\\_]+',
                    'path' => '.UserName'
                  },
        'isAnimateToTop' => $VAR1->[0]{'isAnimateToTop'},
        'initialIndex' => 1,
        'inDeepLinking' => $VAR1->[0]{'inStorage'},
        'name' => 'username-filter',
        'inAnimation' => $VAR1->[0]{'inStorage'}
    }

Returns: Returns the column and value for filter textbox

Desc   : Returns the column and value for filter textbox

=cut

sub textbox
{
    my ($self, $filter_vals) = @_;

    my $data = $filter_vals->{'data'};
    my $result;

    if (exists($data->{'path'}) && exists($data->{'value'}) && $data->{'value'}) {

        $result->{'column'} = $data->{'path'};
        $result->{'column'} =~ s/\.//;
        $result->{'value'} = $data->{'value'};
        if ($data->{'mode'} ne "integer") {
            $result->{'type'} = 'like';
        }
    }

    return $result;
}

# ========================================================================== #

=item C<filterdropdown>

Params : filter_vals
    {
        'type' => 'filter-drop-down',
        'data' => {
                    'filterType' => 'ColumnName',
                    'path' => 'default'
                  },
        'action' => 'filter',
        'isAnimateToTop' => $VAR1->[0]{'isAnimateToTop'},
        'initialIndex' => 5,
        'inDeepLinking' => $VAR1->[0]{'inDeepLinking'},
        'inAnimation' => $VAR1->[0]{'inDeepLinking'},
        'inStorage' => $VAR1->[0]{'inDeepLinking'},
        'name' => 'category-dropdown-filter'
    }

Returns: Returns the column and value for filter dropdown

Desc   : Returns the column and value for filter dropdown

=cut

sub filterdropdown
{
    my ($self, $filter_vals) = @_;

    my $data = $filter_vals->{'data'};
    my $result;

    if (exists($data->{'path'}) && ($data->{'path'} ne 'default')) {
        my $column = $filter_vals->{'name'};

        $result->{'column'} = $data->{'filterType'};
        $result->{'value'}  = $data->{'path'};
        $result->{'value'} =~ s/\.$column//;

    }

    return $result;
}

# ========================================================================== #

=item C<filterselect>

Params : filter_vals
    {
        'isAnimateToTop' => $VAR1->[0]{'isAnimateToTop'},
        'data' => {
                    'path' => '.Electric',
                    'filterType' => 'path'
                  },
        'inDeepLinking' => $VAR1->[0]{'inDeepLinking'},
        'action' => 'filter',
        'name' => 'ServiceType',
        'type' => 'filter-select',
        'inStorage' => $VAR1->[0]{'inDeepLinking'},
        'inAnimation' => $VAR1->[0]{'inDeepLinking'}
      }

Returns: Returns the column and value for filter select

Desc   : Returns the column and value for filter select

=cut

sub filterselect
{
    my ($self, $filter_vals) = @_;

    my $data = $filter_vals->{'data'};
    my $result;

    if (exists($data->{'path'}) && ($data->{'path'} ne 'default')) {
        my $column = $filter_vals->{'name'};

        $result->{'column'} = $column;
        $result->{'value'}  = $data->{'path'};
        $result->{'value'} =~ s/\.$column//;

    }

    return $result;
}

# ========================================================================== #

=item C<filterdaterange>

Params : filter_vals
    {
        'data' => {
                    'path' => '.FromDate',
                    'next_day' => 14,
                    'prev_year' => 2017,
                    'next_month' => 5,
                    'next_year' => 2017,
                    'format' => '{month}/{day}/{year}',
                    'filterType' => 'dateRange',
                    'prev_month' => 5,
                    'prev_day' => 6
                  },
        'inDeepLinking' => $VAR1->[0]{'inAnimation'},
        'action' => 'filter',
        'inStorage' => $VAR1->[0]{'inAnimation'},
        'name' => 'FromDate',
        'type' => 'date-picker-range-filter',
        'isAnimateToTop' => $VAR1->[0]{'isAnimateToTop'},
        'inAnimation' => $VAR1->[0]{'inAnimation'}
      }

Returns: Returns the column and value for filter daterange

Desc   : Returns the column and value for filter daterange

=cut

sub filterdaterange
{
    my ($self, $filter_vals) = @_;

    my $result;

    if (exists($filter_vals->{'data'}) && $filter_vals->{'data'}{'prev_year'} && $filter_vals->{'data'}{'next_year'}) {
        my $data = $filter_vals->{'data'};
        my ($from_date, $to_date);

        $from_date =
            $data->{'prev_year'} . "-"
          . sprintf("%02d", ($data->{'prev_month'} + 1)) . "-"
          . sprintf("%02d", $data->{'prev_day'});
        $to_date =
            $data->{'next_year'} . "-"
          . sprintf("%02d", ($data->{'next_month'} + 1)) . "-"
          . sprintf("%02d", $data->{'next_day'});

        if ($from_date =~ /\d{4}-\d{2}-\d{2}/ && $to_date =~ /\d{4}-\d{2}-\d{2}/) {
            $result->{'column'}    = $filter_vals->{'name'};
            $result->{'from_date'} = $from_date;
            $result->{'to_date'}   = $to_date;
            $result->{'type'}      = 'between';
        }
    }

    return $result;
}

# ========================================================================== #

=item C<filterdatepicker>

Params : filter_vals
    {
        'inDeepLinking' => $VAR1->[0]{'inAnimation'},
        'inAnimation' => $VAR1->[0]{'inAnimation'},
        'isAnimateToTop' => $VAR1->[0]{'isAnimateToTop'},
        'action' => 'filter',
        'inStorage' => $VAR1->[0]{'inAnimation'},
        'type' => 'date-picker-filter',
        'data' => {
                    'year' => 2017,
                    'format' => '{month}/{day}/{year}',
                    'filterType' => 'date',
                    'day' => 10,
                    'path' => '.ReadDate',
                    'month' => 6
                  },
        'name' => 'ReadDate'
    }

Returns: Returns the column and value for filter daterange

Desc   : Returns the column and value for filter daterange

=cut

sub filterdatepicker
{
    my ($self, $filter_vals) = @_;

    my $result;

    if (exists($filter_vals->{'data'}) && $filter_vals->{'data'}{'year'}) {
        my $data = $filter_vals->{'data'};
        my ($date);

        $date = $data->{'year'} . "-" . sprintf("%02d", ($data->{'month'} + 1)) . "-" . sprintf("%02d", $data->{'day'});

        if ($date =~ /\d{4}-\d{2}-\d{2}/) {
            $result->{'column'} = $filter_vals->{'name'};
            $result->{'value'}  = $date;
        }
    }

    return $result;
}

# ========================================================================== #

=item C<checkboxgroup>

Params : filter_vals
    {
        'name' => 'SourceType',
        'action' => 'filter',
        'inStorage' => $VAR1->[0]{'inStorage'},
        'isAnimateToTop' => $VAR1->[0]{'isAnimateToTop'},
        'type' => 'checkbox-group-filter',
        'inAnimation' => $VAR1->[0]{'inStorage'},
        'data' => {
                    'pathGroup' => [
                                     '.Schedule',
                                     '.Estimate'
                                   ],
                    'filterType' => 'pathGroup'
                  },
        'inDeepLinking' => $VAR1->[0]{'inStorage'}
    }

Returns: Returns the column and value for filter checkbox group

Desc   : Returns the column and value for filter checkbox group

=cut

sub checkboxgroup
{
    my ($self, $filter_vals) = @_;

    my $result;

    if (exists($filter_vals->{'data'})) {
        my $data = $filter_vals->{'data'};

        if (exists($data->{'pathGroup'}) && ref($data->{'pathGroup'}) eq 'ARRAY') {

            my $column      = $filter_vals->{'name'};
            my $values      = $data->{'pathGroup'};
            my @real_values = map { my $s = $_; $s =~ s/\.$column//g; $s } @$values;

            if (scalar @real_values) {
                $result->{'column'} = $column;
                $result->{'values'} = \@real_values;
                $result->{'type'}   = 'in';
            }

        }
    }

    return $result;
}

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

