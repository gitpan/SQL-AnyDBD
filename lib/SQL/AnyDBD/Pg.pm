package SQL::AnyDBD::Pg;

use Params::Validate qw(:all);

sub LIMIT {

    shift;
    my %p = validate_with
      (params => \@_, 
       spec   => { rows_desired => 
		   { type => SCALAR, optional => 0, regex => qr/(ALL|\d+)/i },
		   start_row => 
		   { type => SCALAR, optional => 1, regex => qr/\d*/ } 
		 });

    my   @LIMIT = "LIMIT  $p{rows_desired}";
    push @LIMIT,  "OFFSET $p{start_row}"    if $p{start_row};

    "@LIMIT"

}


1;
