# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl limit.t'


#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;

use Test::More tests => 2;
use SQL::AnyDBD;

require 't/test_util.pl'; my $tu = Test::Util->new;
$tu->test_connection_info;
my ($dsn, $user, $pass) = $tu->get_connection_info;


#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $dbh = DBI->connect($dsn, $user, $pass);
die "Unable to connect to DB for testing!" unless $dbh;



my $driver = $dbh->{Driver}->{Name}; 
$tu->expect( Pg => [ 'LIMIT  8 OFFSET 4', 'LIMIT  8' ] );


my $sb  = SQL::AnyDBD->new($dbh);

my $rows_desired = 8;
my $start_row    = 4;
my $sql = $sb->LIMIT(rows_desired => $rows_desired, start_row => $start_row);
my $expect = $tu->next_expect($driver);

is ( $sql , $expect, 'LIMIT with rows_desired and start_row' ) ;


$start_row = '';

$sql = $sb->LIMIT(rows_desired => $rows_desired, start_row => $start_row);

is ( $sql , $tu->next_expect($driver), 'LIMIT with rows_desired no start_row passed' ) ;


