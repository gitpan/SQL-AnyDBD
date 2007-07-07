package SQL::AnyDBD::Default;

use strict;
use Params::Validate qw(:types validate_with);

sub SELECT {
    my $sa = shift;
    
    my %p = validate_with(
        'params' => \@_, 
        'spec'   => { 
		    'fields'   => { 
		        'type'     => ARRAYREF,  
		        'optional' => 0, 
		    },
		    'tables'   => { 
		        'type'     => ARRAYREF,  
		        'optional' => 1, 
		    },
		    'where'    => { 
		        'type'     => SCALAR,    
		        'optional' => 1, 
		    },
		    'group_by' => { 
		        'type'     => SCALAR,    
		        'optional' => 1, 
		    },
		    'having'   => { 
		        'type'     => SCALAR,    
		        'optional' => 1, 
		    },
		    'order_by' => { 
		        'type'     => SCALAR,    
		        'optional' => 1, 
		    },
		    'limit'    => { 
		        'type'     => HASHREF,   
		        'optional' => 1, 
		    },
		},
	);

    my $fields   = join ',', @{ $p{'fields'} };
    my $tables   = $p{'tables'}   ? 'FROM ' . join(',', @{ $p{'tables'} }) : undef;
    my $where    = $p{'where'}    ? "WHERE $p{'where'}"                    : undef;
    my $group_by = $p{'group_by'} ? "GROUP BY $p{'group_by'}"              : undef;
    my $having   = $p{'having'}   ? "HAVING $p{'having'}"                  : undef;
    my $order_by = $p{'order_by'} ? "ORDER BY $p{'order_by'}"              : undef;
    my $limit    
        = ( scalar keys %{ $p{'limit'} } ) ? $sa->LIMIT( %{ $p{'limit'} } ) : undef;

    return 'SELECT ' . join(' ', grep { defined } $fields, $tables, $where, $group_by, $having, $order_by, $limit);
}

sub UPDATE {
    my $sa = shift;
    
    my %p = validate_with(
        'params' => \@_, 
        'spec'   => { 
		    'table' => { 
		        'type'     => SCALAR,  
		        'optional' => 0, 
		    },
		    'set'   => { 
		        'type'     => SCALAR,  
		        'optional' => 0, 
		    },
		    'where' => { 
		        'type'     => SCALAR,  
		        'optional' => 1, 
		    },
		    'limit' => { 
		        'type'     => SCALAR,  
		        'optional' => 1,
		    },
		},
    );
    
    my $where = $p{'where'} ? "WHERE $p{'where'}" : undef;
    my $limit = $p{'limit'} ? "LIMIT $p{'limit'}" : undef;

    return 'UPDATE ' . join(' ', grep { defined } $p{'table'}, 'SET', $p{'set'}, $where, $limit);
}

sub INSERT {
    my $sa = shift;
    
    my %p = validate_with(
        'params' => \@_, 
        'spec'   => { 
		    'table'   => { 
		        'type'     => SCALAR,    
		        'optional' => 0, 
		    },
		    'columns' => { 
		        'type'     => ARRAYREF,  
		        'optional' => 1, 
		    },
		    'values' => { 
		        'type'     => ARRAYREF,  
		        'optional' => 0, 
		    },
        },
    );

    my $columns = scalar @{ $p{'columns'} } 
        ? sprintf '(%s)', join( ',', @{ $p{'columns'} } ) : undef;
    my $values  = sprintf '(%s)', join( ',', @{ $p{'values'} } );

    return 'INSERT INTO ' . join(' ', grep { defined } $p{'table'}, $columns, 'VALUES', $values);
}

sub DELETE {
    my $sa = shift;
    
    my %p = validate_with(
        'params' => \@_, 
        'spec'   => { 
		    'table'    => { 
		        'type'     => SCALAR, 
		        'optional' => 0, 
		    },
		    'where'    => { 
		        'type'     => SCALAR, 
		        'optional' => 1, 
		    },
		    'group_by' => { 
		        'type'     => SCALAR, 
		        'optional' => 1, 
		    },
		    'order_by' => { 
		        'type'     => SCALAR, 
		        'optional' => 1, 
		    },
		    'limit'    => { 
		        'type'     => SCALAR, 
		        'optional' => 1, 
		    },
        },
    );

    my $where    = $p{'where'}    ? "WHERE $p{'where'}"       : undef;
    my $group_by = $p{'group_by'} ? "GROUP BY $p{'group_by'}" : undef;
    my $order_by = $p{'order_by'} ? "ORDER BY $p{'order_by'}" : undef;
    my $limit    = $p{'limit'}    ? "LIMIT $p{'limit'}"       : undef;

    return 'DELETE FROM ' . join(' ', grep { defined }  $p{'table'}, $where, $group_by, $order_by, $limit);
}

sub IN {
    my $sa = shift;
   
    my %p = validate_with(
        'params' => \@_, 
        'spec'   => { 
            'values' => { 
                'type'     => ARRAYREF, 
                'optional' => 0,
            },
		},
    );
   
    my $values = join ',', @{ $p{'values'} };
    
    return $values ? "IN ($values)" : '';
}

sub AS {
    my ($sa, $real, $alias) = @_;
    return "$real AS $alias";
}

# General Utility methods:

sub sql_driver_version {
    return shift->VERSION() || $SQL::AnyDBD::VERSION;    
}

sub get_placeholder_string {
    shift;
    return join( ',', split '', ( '?' x (ref $_[0] eq 'ARRAY' ? @{ $_[0] } : @_) ) );
}

sub get_placeholder_array {
    shift;
    return wantarray ?   map { '?' } (ref $_[0] eq 'ARRAY' ? @{ $_[0] } : @_) 
                     : [ map { '?' } (ref $_[0] eq 'ARRAY' ? @{ $_[0] } : @_) ]
                     ;
}

sub function {
    my ($sa, $function, $arg_str) = @_;
    $function = uc $function if !$sa->{'no_uc'};
    $arg_str  = '' if !defined $arg_str;
    return "$function($arg_str)";
}

sub get_sql_from_files {
    my ($sa, @files, $pre_process) = @_;
    
    my $slurp_sql = '';
    
    if( ref $pre_process ne 'CODE' ) {
        push @files, $pre_process;
        $pre_process = '';
    }
    
    for my $file (@files) {
        
        my $real = $file;
        $real   .=  '.' . $sa->normalized_sql_driver_name() 
            if -e $real . '.' . $sa->normalized_sql_driver_name();
        
        if( open my $sql_fh, '<', $real ) {
            my $sql = do { local $/; <$sql_fh> };
            close $sql_fh;
        
            if( ref $pre_process eq 'CODE' ) {
                $slurp_sql .= $pre_process->( $sa, $sql, $file, $real );
            }
            else {
                $slurp_sql .= $sql;
            }
        }
        else {
            return;
        }
    }
    
    return $slurp_sql;
}

sub sql_driver_name {
    return (reverse split "::", ref shift)[0];
}

sub normalized_sql_driver_name {
    return lc( shift->sql_driver_name() );
}

sub _init {
    my ($sa) = @_;
    $sa->{'no_uc'} = 0 if !defined $sa->{'no_uc'};
}

1;