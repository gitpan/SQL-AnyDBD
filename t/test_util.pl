package Test::Util;

use Exporter;

use Class::Struct;

struct 
  (
   expect => '%'
  );


sub test_connection_info {
    unless ( 
	    defined($ENV{DBI_DSN})  and 
	    defined($ENV{DBI_USER}) and 
	    defined($ENV{DBI_PASS}) ) {
	warn "\n";
	warn "A working DBI connection is required for the remaining tests.\n";
	warn "Enter the following parameters (or pre-set in your ENV):\n";
	warn "\n";
    }
}

sub get_connection_info {
    my $tu = shift;
    my $dsn  = defined($ENV{DBI_DSN})  || 
      $tu->prompt(DBI_DSN => 'dbi:Pg:dbname=test');
    my $user = defined($ENV{DBI_USER}) || $tu->prompt(DBI_USER => 'metaperl');
    my $pass = defined($ENV{DBI_PASS}) || $tu->prompt(DBI_PASS => '');

    ($dsn, $user, $pass);
}

sub next_expect {
    my $tu = shift;
    my $driver = shift;

    my $expect = $tu->expect($driver);
    shift @$expect;
}

sub prompt {
    shift;
    warn "  $_[0] (or accept default '$_[1]'): \n";
    chomp( my $input = <STDIN> );
    return length($input) ? $input : $_[1]
}




1;
