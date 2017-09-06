# ========================================================================== #
# lib/JPList/Result.pm  - JPList DB Result
# Copyright (C) 2017 Exceleron Software, LLC
# ========================================================================== #

package JPList::DB::Result;

use Moose::Role;
use SQL::Abstract;

# ========================================================================== #

=head1 NAME

JPList::DB::Result - JPList DB Result

=head1 SYNOPSIS

  with 'JPList::DB::Result'

=head1 DESCRIPTION

The JPList::DB::Result module allows you get the resultset from table/view

=head2 ATTRIBUTES

=over 4

=cut

# ========================================================================== #

has 'sql_abs' => (
    is      => 'rw',
    isa     => 'SQL::Abstract',
    default => sub {
        SQL::Abstract->new(quote_char => '"');
    }
);

# ========================================================================== #

=head2 methods

=over 4

=cut

# ========================================================================== #

=item C<_get_resultset>

Params : $request_data

Returns: Resultset data from table/view based on the request params

Desc   : Resultset data from table/view based on the request params

=cut

sub _get_resultset
{
    my $self         = shift;
    my $request_data = shift;
    my $is_download  = shift || 0;

    my $source = $self->db_table_name;

    my $fields;
    if ($self->fields) {
        $fields = $self->fields;
    }
    else {
        $fields = ['*'];
    }

    my $where = $self->_build_where_clause($request_data);

    my $order = $self->_build_sort_order($request_data);

    my ($sql_query, @bind_vals) = $self->sql_abs->select($source, $fields, $where);

    if ($self->group_fields) {
        $sql_query .= " GROUP BY " . $self->group_fields;
    }

    if ($order) {
        $sql_query .= " $order";
    }

    my $bind_vals = \@bind_vals;

    my $params;
    my $count = 0;
    if (!$is_download) {
        ## Add Limit Query for jplist data
        ($sql_query, $bind_vals) = $self->_build_limit_query($request_data, $sql_query, \@bind_vals);

        #Get total count for paging
        $count = $self->_get_paging_count($source, $where);
    }
    else {
        ## Return array of array for csv download
        $params->{return_aoa} = 1;
    }

    print STDERR "[jplist info] " . $sql_query . "\n";
    print STDERR "[jplist info] bind_vals @bind_vals \n";

    $params->{sql}                  = $sql_query;
    $params->{bind_vals}            = $bind_vals;

    my $data = $self->select_hashref($params);

    #Return data
    my $return_data = {
        count => $count,
        data  => $data
    };

    return $return_data;
}

# ========================================================================== #

=item C<_build_where_clause>

Params : $request_data

Returns: $where_clause

Desc   : Builds where_clause based on JPList request "filter_data" and also custom "where_fields"

=cut

sub _build_where_clause
{
    my $self         = shift;
    my $request_data = shift;

    return $self->{where_clause} if ($self->{where_clause});

    my %where;

    #Custom Where Clause like UtilityId/AccountId/MeterId filter based on auth
    foreach my $column (keys %{$self->where_fields}) {
        $where{$column} = $self->where_fields->{$column};
    }

    #Where clause applied based on filter data
    foreach my $data (@{$request_data->filter_data}) {
        if (exists($data->{'type'})) {
            if ($data->{'type'} eq 'like') {
                $where{$data->{'column'}} = {-like => '%' . $data->{'value'} . '%'};
            }
            elsif ($data->{'type'} eq 'between') {
                $where{$data->{'column'}} = {-between => [$data->{'from_date'}, $data->{'to_date'}]};
            }
            elsif ($data->{'type'} eq 'in') {
                $where{$data->{'column'}} = {-in => $data->{'values'}};
            }
        }
        else {
            $where{$data->{'column'}} = $data->{'value'};
        }
    }

    $self->{where_clause} = \%where;

    return $self->{where_clause};
}

# ========================================================================== #

=item C<_build_sort_order>

Params : $request_data

Returns: $order

Desc   : Builds order data structure based on JPList request "sort_data"

=cut

sub _build_sort_order
{
    my $self         = shift;
    my $request_data = shift;

    my $sort_one = $request_data->sort_data->[0] if (ref($request_data->sort_data) eq 'ARRAY');

    my $order;
    if ($sort_one && $sort_one->{column} ne 'default') {

        if ($self->order_index) {
            my $order_index = $self->order_index->{$sort_one->{column}};
            $order = qq/ORDER BY $order_index/;
            if ($sort_one->{order} eq "desc") {

                $order .= ' DESC';

            }
        }
        else {
            $order = qq/ORDER BY "$sort_one->{column}"/;
            if ($sort_one->{order} eq "desc") {

                $order .= ' DESC';

            }
        }

    }

    return $order;
}

# ========================================================================== #

=item C<_build_limit_query>

Params : $request_data, $sql_query, $bind_vals

Returns: $sql_query, $bind_vals

Desc   : Builds SQL updated with LIMIT and OFFEST based on JPList request "pagination_data"

=cut

sub _build_limit_query
{
    my $self         = shift;
    my $request_data = shift;
    my $sql_query    = shift;
    my $bind_vals    = shift;

    my $number       = $request_data->pagination_data->{'number'}      || 10;
    my $current_page = $request_data->pagination_data->{'currentPage'} || 0;

    my $limit = $number;
    my $offset = ($limit * $current_page) || 0;

    if ($limit and $limit ne 'all') {
        $sql_query .= " LIMIT ? OFFSET ?";
        push(@$bind_vals, ($limit, $offset));
    }

    return ($sql_query, $bind_vals);
}

# ========================================================================== #

=item C<_get_paging_count>

Params : $table_source, $wheres

Returns: total count based on filter

Desc   : total count based on filter

=cut

sub _get_paging_count
{
    my $self   = shift;
    my $source = shift;
    my $where  = shift;

    my ($sql_count_query, @bind_count_vals);

    if ($self->group_fields) {
        my $group_fields = $self->group_fields;

        ($sql_count_query, @bind_count_vals) = $self->sql_abs->select($source, $group_fields, $where);
        $sql_count_query = "SELECT COUNT(*) FROM ($sql_count_query GROUP BY $group_fields) AS SQ";

    }
    else {

        ($sql_count_query, @bind_count_vals) = $self->sql_abs->select($source, 'count(*)', $where);
    }

    my $data = $self->select_hashref(
        {
            sql                  => $sql_count_query,
            bind_vals            => \@bind_count_vals,
            return_aoa           => 1
        }
    );

    my $count = $data->[0][0] || 0;

    return $count;
}

# ========================================================================== #

=item B<select_hashref>

Params : {
             sql => 'SQL Statement', 
             bind_vals => ARRAYREF[optional],
             return_key => Column [optional],
             return_aoa => 1 [optional]
         }

Returns: ARRAYREF/HASHREF of data
         If return_key is undef : Returns rows as Array of Hash
         If return_key has a valid column: Returns rows as Hash of Hash with Column value as hash key
         If return_aoa is 1 : Returns rows as Array of Array

Desc   : Using SQL get hashref of data

=cut

sub select_hashref
{
    my $self      = shift;
    my $params    = shift;
    my $sql       = $params->{sql};
    my $bind_vals = (defined($params->{'bind_vals'}) && exists($params->{'bind_vals'})) ? $params->{'bind_vals'} : [];

    my $dbh = $self->dbh;

    my $data;
    my $sth = $dbh->prepare_cached($sql) or die("$!");

    for (my $i = 0; $i < scalar(@$bind_vals); $i++) {
        $sth->bind_param($i + 1, $bind_vals->[$i]) or die("$!");
    }

    if (defined $params->{return_key}) {
        $data = $dbh->selectall_hashref($sth, $params->{return_key}) or die("$!");
    }
    elsif (defined $params->{return_aoa}) {
        $data = $dbh->selectall_arrayref($sth) or die("$!");
    }
    else {
        $data = $dbh->selectall_arrayref($sth, {Slice => {}}) or die("$!");
    }    
    
    return $data;
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

