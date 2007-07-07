use Test::More 'tests' => 21;
use lib '../lib';

BEGIN { use_ok('SQL::AnyDBD') };

my $sa = SQL::AnyDBD->new( { 'Driver' => { 'Name' => 'SQLite' } } ); # fake an SQLite $dbh
# we use SQLite incase we want to use the actual driver in testing at some point and 
# still not require a server to be running and/or somehow reliably get a working DSN 

ok( ref $sa eq 'SQL::AnyDBD::SQLite', 'Object created' );

#### get_placeholder_string
my $scl = $sa->get_placeholder_string( qw(a b c d) );
my $arr = $sa->get_placeholder_string( [qw(a b c d)] );
ok( $scl eq '?,?,?,?', 'placeholder string passed array');
ok( $arr eq '?,?,?,?', 'placeholder string passed array ref');

#### get_placeholder_array
my $sc = $sa->get_placeholder_array( qw(a b c d) );
my @ar = $sa->get_placeholder_array( [qw(a b c d)] );
is_deeply( $sc, [qw(? ? ? ?)], 'placeholder array scalar context (passed array)' );
is_deeply( \@ar, [qw(? ? ? ?)], 'placeholder array array context (passed array ref)' );

#### normalized_sql_driver_name
ok( $sa->normalized_sql_driver_name() eq 'sqlite', 'normalized_sql_driver_name()');

#### sql_driver_name
ok( $sa->sql_driver_name() eq 'SQLite', 'sql_driver_name()');

#### LIMIT
ok( $sa->LIMIT( 'rows_desired' => 8, 'start_row' => 4 ) eq 'LIMIT 8 OFFSET 4', 'LIMIT()' );
ok( $sa->LIMIT( 'rows_desired' => 7 ) eq 'LIMIT 7', 'LIMIT() only' );

#### INSERT
ok(
    $sa->INSERT(
        'table'     => 'student',
   	    'columns'   => [qw(student_ssan3 student_ssan2 student_ssan4 student_lname student_fname)],
   	    'values'    => [qw(123 45 9876 olajuwon hakeem)],
    )
      eq
    'INSERT INTO student (student_ssan3,student_ssan2,student_ssan4,student_lname,student_fname) VALUES (123,45,9876,olajuwon,hakeem)',
    'INSERT()'    
);

#### SELECT
ok( 
    $sa->SELECT(
        'fields'   => [qw(student_ssan)],
        'tables'   => ['student INNER JOIN classes'],
        'where'    => 'student.classes_id = classes.classes_id',
        'group_by' => 'classes_year',
        'having'   => 'student_age > 30',
        'order_by' => 'student_id',
        'limit'    => { rows_desired => 5, start_row => 77 },        
    )
      eq 
    'SELECT student_ssan FROM student INNER JOIN classes WHERE student.classes_id = classes.classes_id GROUP BY classes_year HAVING student_age > 30 ORDER BY student_id LIMIT 5 OFFSET 77',
    'SELECT()' 
);

ok( $sa->SELECT( 'fields' => [ $sa->function('now') ] ) eq 'SELECT NOW()', 'non-table SELECT' );

#### UPDATE
ok(
    $sa->UPDATE(
        'table'  => 'student',
   	    'set'    => 'student_ssan = NULL',
   	    'where'  => 'student_country_id <> 1',
   	    'limit'  => 12,    
    )
      eq 
    'UPDATE student SET student_ssan = NULL WHERE student_country_id <> 1 LIMIT 12',
    'UPDATE()'
);

#### DELETE 
ok(
    $sa->DELETE( 
        'table'    => 'student',
	    'where'    => 'student.classes_id = 420',
	    'order_by' => 'date_enrolled',
	    'limit'    => 4,
	) 
	  eq 
	'DELETE FROM student WHERE student.classes_id = 420 ORDER BY date_enrolled LIMIT 4',
    'DELETE()'
);

#### IN
ok( $sa->IN( 'values' => [qw(1 2 3 4)] ) eq 'IN (1,2,3,4)', 'IN()' );

#### AS 
ok( $sa->AS('foo', 'bar') eq 'foo AS bar', 'AS()' );


#### sql_driver_version
ok( $sa->sql_driver_version() eq '0.03', 'sql_driver_version()');

#### function
ok( $sa->function('now') eq 'NOW()', 'function no_uc false' );

{
    local  $sa->{'no_uc'} = 1;
    ok( $sa->function('now') eq 'now()', 'function no_uc true' );
}

#### get_dbh
ok( $sa->can('get_dbh'), 'get_dbh subclassed ok');