# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl limit.t'


#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;

use Test::More tests => 1;
use SQL::AnyDBD;
require 't/test_util.pl'; my $tu = Test::Util->new;
$tu->test_connection_info;
my ($dsn, $user, $pass) = $tu->get_connection_info;


#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.




######################
## import test data ##
######################

my $dbh = DBI->connect($dsn, $user, $pass);
die "Unable to connect to DB for testing!" unless $dbh;



my %insert =
	(
         table     => "student",
	 columns   => [qw(student_ssan3 student_ssan2 student_ssan4 student_lname student_fname)],
	 values    => [qw(123 45 9876 olajuwon hakeem)]
	);


my $sb  = SQL::AnyDBD->new($dbh);
my $sql = $sb->INSERT(%insert);

my $expect = 'INSERT INTO student (student_ssan3,student_ssan2,student_ssan4,student_lname,student_fname) VALUES (123,45,9876,olajuwon,hakeem)';
is ($sql, $expect);

