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



my %select = 
	(
	 fields => [qw(student_ssan)],
	 tables => ["student INNER JOIN classes"],
	 where  => "student.classes_id = classes.classes_id",
	 group_by => "classes_year",
	 having   => "student_age > 30",
	 order_by => 'student_id',
	 limit  => { rows_desired => 5, start_row => 77 },
	);

my $sb  = SQL::AnyDBD->new($dbh);
my $sql = $sb->SELECT(%select);

my $expect = 'SELECT student_ssan FROM student INNER JOIN classes WHERE student.classes_id = classes.classes_id GROUP BY classes_year HAVING student_age > 30 ORDER BY student_id LIMIT  5 OFFSET 77';
is ($sql, $expect);

