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

my $sb  = SQL::AnyDBD->new($dbh);
my $sql = $sb->IN(values => [qw(fee fi fo fum)]);

my $expect = 'IN (fee,fi,fo,fum)';

is ($sql, $expect, 'test output of IN()');

