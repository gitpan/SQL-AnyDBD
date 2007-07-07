package SQL::AnyDBD::Pg;

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
                'regex'    => qr/ \A (?: ALL | \d+ ) \z /xmsi,
            },
		    'start_row'    => { 
		        'type'     => SCALAR, 
		        'optional' => 1, 
		        'regex'    => qr/ \A \d* \z /xms,
		    }, 
        },
    );

    my $LIMIT = "LIMIT $p{'rows_desired'}";
    $LIMIT   .= " OFFSET $p{'start_row'}" if $p{'start_row'};

    return $LIMIT;
}

1;