package SQL::AnyDBD::Mysql;

use strict;
use Params::Validate qw(:types validate_with);

sub LIMIT {
    my $sa = shift;
    
    my %p = validate_with(
        'params' => \@_, 
        'spec'   => { 
            'rows_desired' => { 
                'type'     => SCALAR, 
                'optional' => 0, 
                'regex'    => qr / \A \d+ \z /xms,
            },
		    'start_row'    => { 
		        'type'     => SCALAR, 
		        'optional' => 1, 
		        'regex'    => qr/ \A \d* \z /xms,
		    }, 
        },
    );
   
    my @LIMIT;
    push @LIMIT, $p{'start_row'} if $p{'start_row'};
    push @LIMIT, $p{'rows_desired'};

    return join ',', @LIMIT;
}

1;