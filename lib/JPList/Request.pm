# ========================================================================== #
# lib/JPList/Request.pm  - JPList Request parser module
# Copyright (C) 2017 Exceleron Software, LLC
# ========================================================================== #

package JPList::Request;

use Moose;
use URI::Escape;
use JSON;

with 'JPList::Controls::Filter';
with 'JPList::Controls::Sort';

# ========================================================================== #

=head1 NAME

JPList::Request - JPList Request parser module

=head1 SYNOPSIS

  use JPList::Request;
  my $jplist_req = JPList::Request->new(request_params => $self->request_params);

=head1 DESCRIPTION

The JPList::Request module allows you to decode the request params with all the controls

=head2 ATTRIBUTES

=over 4

=cut

# ========================================================================== #

has 'request_params' => (
    is  => 'rw',
    isa => 'Str'
);

has 'request_data' => (
    is      => 'rw',
    builder => '_decode_request_params',
    lazy    => 1,
    clearer => 'clear_request_data'
);

has 'filter_attrs' => (
    is  => 'rw',
    isa => 'HashRef'
);

has 'filter_data' => (
    is  => 'rw',
    isa => 'ArrayRef'
);

has 'sort_data' => (
    is  => 'rw',
    isa => 'ArrayRef'
);

has 'pagination_data' => (
    is  => 'rw',
    isa => 'HashRef'
);

has 'is_download' => (
    is      => 'rw',
    default => 0
);

# ========================================================================== #

=head2 methods

=over 4

=cut

# ========================================================================== #

=item C<decode_data>

Params : $statuses_request

Returns: NONE

Desc   : decode the request params

=cut

sub decode_data
{
    my ($self) = @_;

    if (ref($self->request_data) eq 'ARRAY') {

        $self->_store_status_list($self->request_data);

    }
    else {

        return undef;
    }
}

# ========================================================================== #

=item C<_decode_request_params>

Params : $self->request_params

Returns: Data structure of formatted request data structure

Desc   : decode params

=cut

sub _decode_request_params
{

    my $self = shift;

    return decode_json(uri_unescape($self->request_params));
}

# ========================================================================== #

=item C<_store_status_list>

Params : Request Data

Returns: NONE

Desc   : parses the list of unique actions and computes filter, sort and pagination data

=cut

sub _store_status_list
{
    my ($self, $statuses_request) = @_;

    foreach my $status_req (@$statuses_request) {
        my $action = $status_req->{'action'};
        push(@{$self->{'status_list'}->{$action}}, $status_req);
    }

    $self->_get_filter_data();

    $self->_get_sort_data();

    $self->_get_pagination_data();

    ## Clear unwanted attributes
    $self->clear_request_data();
    delete($self->{'status_list'});
}

# ========================================================================== #

=item C<_get_filter_data>

Params : NONE

Returns: NONE

Desc   : private function to parse filter data

=cut

sub _get_filter_data
{
    my ($self) = @_;

    my @filter_data;

    # This is used to store the values of filter by column name
    # Eg: $jplist->jplist_request->filter_attrs->{'ServiceType'}
    my %filter_attrs;

    foreach my $filter_vals (@{$self->{'status_list'}->{'filter'}}) {
        if ($filter_vals->{'type'} eq 'textbox') {
            my $filter_result = $self->textbox($filter_vals);
            if (defined $filter_result) {
                push(@filter_data, $filter_result);
                $filter_attrs{$filter_result->{'column'}} = $filter_result->{'value'};
            }
        }
        elsif ($filter_vals->{'type'} eq 'filter-drop-down') {
            my $filter_result = $self->filterdropdown($filter_vals);
            if (defined $filter_result) {
                push(@filter_data, $filter_result);
                $filter_attrs{$filter_result->{'column'}} = $filter_result->{'value'};
            }
        }
        elsif ($filter_vals->{'type'} eq 'filter-select') {
            my $filter_result = $self->filterselect($filter_vals);
            if (defined $filter_result) {
                push(@filter_data, $filter_result);
                $filter_attrs{$filter_result->{'column'}} = $filter_result->{'value'};
            }
        }
        elsif ($filter_vals->{'type'} eq 'date-picker-range-filter') {
            my $filter_result = $self->filterdaterange($filter_vals);
            if (defined $filter_result) {
                push(@filter_data, $filter_result);
                $filter_attrs{$filter_result->{'column'}} = $filter_result;
            }
        }
        elsif ($filter_vals->{'type'} eq 'date-picker-filter') {
            my $filter_result = $self->filterdatepicker($filter_vals);
            if (defined $filter_result) {
                push(@filter_data, $filter_result);
                $filter_attrs{$filter_result->{'column'}} = $filter_result->{'value'};
            }
        }
        elsif ($filter_vals->{'type'} eq 'checkbox-group-filter') {
            my $filter_result = $self->checkboxgroup($filter_vals);
            if (defined $filter_result) {
                push(@filter_data, $filter_result);
                $filter_attrs{$filter_result->{'column'}} = $filter_result->{'values'};
            }
        }
        elsif ($filter_vals->{'type'} eq 'button-filter' and $filter_vals->{'name'} eq 'download') {
            print STDERR "[jplist info] download request filter called\n";
            my $data = $filter_vals->{'data'};
            if (    exists($data->{'filterType'})
                and ($data->{'filterType'} eq 'path')
                and exists($data->{'path'})
                and ($data->{'path'} eq '.download'))
            {
                $self->is_download(1);
            }
        }
    }

    $self->filter_data(\@filter_data);
    $self->filter_attrs(\%filter_attrs);
}

# ========================================================================== #

=item C<_get_sort_data>

Params : NONE

Returns: NONE

Desc   : private functiont to parse sort data

=cut

sub _get_sort_data
{
    my ($self) = @_;

    my @sort_data;

    foreach my $sort_vals (@{$self->{'status_list'}->{'sort'}}) {
        if ($sort_vals->{'type'} eq 'sort-drop-down') {
            my $sort_result = $self->sortdropdown($sort_vals);
            push(@sort_data, $sort_result);
        }
        elsif ($sort_vals->{'type'} eq 'sort-select') {
            my $sort_result = $self->sortselect($sort_vals);
            push(@sort_data, $sort_result);
        }
    }

    $self->sort_data(\@sort_data);
}

# ========================================================================== #

=item C<_get_pagination_data>

Params : NONE

Returns: NONE

Desc   : private functiont to parse pagination data

=cut

sub _get_pagination_data
{
    my ($self) = @_;

    my $pagination_data;

    foreach my $paging_vals (@{$self->{'status_list'}->{'paging'}}) {
        my $data = $paging_vals->{'data'};

        if ($data) {
            if ($data->{'currentPage'}) {
                $pagination_data->{'currentPage'} = $data->{'currentPage'};
            }

            if ($data->{'number'}) {
                $pagination_data->{'number'} = $data->{'number'};
            }
        }
    }

    $self->pagination_data($pagination_data);
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

