package SQL::AnyDBD::Mysql;

use Params::Validate qw(:all);

sub SELECT {


}

sub LIMIT {

    shift;
    my %p = validate_with
      (params => \@_, 
       spec   => { rows_desired => 
		   { type => SCALAR, optional => 0, regex => qr/\d+/ },
		   start_row => 
		   { type => SCALAR, optional => 1, regex => qr/\d*/ } 
		 });

#    $p{last_row} = $p{start_row} + $p{rows_desired};

    my   @LIMIT;
    push @LIMIT,  $p{start_row}    if $p{start_row};
    push @LIMIT,  $p{rows_desired};

    join ",", @LIMIT

}


1;
