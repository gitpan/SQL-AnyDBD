package SQL::AnyDBD;

use strict;
use warnings;
use base 'DBIx::AnyDBD';

our $VERSION = '0.03';

sub new {
    my ($pkg, $dbh) = @_;
    my $self = bless { 'package' => __PACKAGE__ , dbh => $dbh }, __PACKAGE__;
    $self->rebless;
    $self->_init if $self->can('_init');
    return $self; 
}

1;

__END__

=head1 NAME

SQL::AnyDBD - Perl extension to generate SQL for RDBMS variants

=head1 SYNOPSIS

  use SQL::AnyDBD;

  my $dbh = DBI->connect($dsn, $user, $pass, $attr) or die $!;
  my $sa  = SQL::AnyDBD->new($dbh);

  my $rows_desired = 8;
  my $start_row    = 4;

  warn $sa->LIMIT(rows_desired => $rows_desired, start_row => $start_row);

  # yields ...

  LIMIT 8 OFFSET 4  -- for Pg and SQLite
  4,8               -- for Mysql


=head1 ABSTRACT

SQL::AnyDBD is module which generates SQL for different RDBMSes from a 
uniform API. It uses DBIx::AnyDBD to determine which SQL variant to
generate. In this documentation, "the big 3" is used to refer to the 3 free
popular databases: Postgresql, SQLite, and MySQL (There is a reason I listed
them in that order, but now is no time to get into a holy war. :)


=head1 METHODS

=head2 $sa->LIMIT(rows_desired => $r [ , start_row => $s ] )

=over 4

=item REQUIRED: rows_desired

=item OPTIONAL: start_row

=back

A limit clause is used to limit the result set from an SQL select. 
Each of the big 3 supports this concept. All 3 also accept integers for both
arguments. However, Pg can also accept the term C<ALL> for C<rows_desired>.  

=head2 $sa->IN ( values => \@v )

=over 4 

=item REQUIRED: values

=back

It is required that the arrayref C<values> be passed. 
It is not required that the
arrayref have any data:

 my $sql = $sa->IN(values => [12..14]);

 # yields...

 IN (12,13,14)

=head2 $sa->AS ( $real, $alias)

=over 4 

=item REQUIRED: both arguments

=back

 my $sql = $sa->AS('userprefs', 'up');
 
 # yields...

 userprefs AS up

=head2 $sa->SELECT ( fields => \@f, tables => \@t, ... )

=over 4 

=item REQUIRED: fields, 

=item OPTIONAL: tables, where, group_by, having, order_by, limit

=back

All the optional arguments take a string as an argument with the exception of
C<limit> which takes a hashref which is passed to C<LIMIT()>. 'tables' and the required
arguments take an arrayref  B<even if they only have one argument>: 

 my %select = 
	(
	 fields   => [qw(student_ssan)],
	 tables   => ["student INNER JOIN classes"],
	 where    => "student.classes_id = classes.classes_id",
	 group_by => "classes_year",
	 having   => "student_age > 30",
	 order_by => 'student_id',
	 limit    => { rows_desired => 5, start_row => 77 },
	);

 my $sa  = SQL::AnyDBD->new($dbh);
 my $sql = $sa->SELECT(%select);

 # yields...

 SELECT 
    student_ssan 
 FROM 
    student INNER JOIN classes 
 WHERE 
    student.classes_id = classes.classes_id 
 GROUP BY 
    classes_year 
 HAVING 
    student_age > 30 
 ORDER BY 
    student_id 
 LIMIT  
    5 
 OFFSET 
    77

As of 0.03 'tables' is optional so that you can do queries liek this:
 
 my $sql = $sa->SELECT( 'fields' => [ $sa->function('NOW', time) ]);
  
 #yields:
 
 SELECT NOW(1170616724)

=head2 $sa->DELETE ( table => $tbl [ ,  ...  ] )

=over 4 

=item REQUIRED: table

=item OPTIONAL:  where, order_by, limit

=back

C<table> is the name of the table from which to delete records. C<where> is a
string specifying the filtering of rows. C<order_by> is useful in
conjunction with C<limit> in order to delete rows based on order:

 my %parms = 
	(
	 table => 'student',
	 where  => "student.classes_id = 420",
	 order_by => 'date_enrolled',
	 limit  => 4
	);

 my $sa  = SQL::AnyDBD->new($dbh);
 my $sql = $sa->DELETE(%parms);

 # yields ...

 DELETE FROM 
   student 
 WHERE 
   student.classes_id = 420 
 ORDER BY 
   date_enrolled 
 LIMIT 4

=head2 $sa->UPDATE ( set => $set_expr, , table => $t [, ...] )

=over 4 

=item REQUIRED: set, table

=item OPTIONAL: where, limit

=back

The required argument set is a string consisting of a series of

   col_name1=expr1 [, col_name2=expr2, ...]

expressions. The required argument C<table> is a table name.


All the optional arguments take a scalar as an argument.
C<limit> which takes a hashref which is passed to C<LIMIT()>. Both required
arguments take an arrayref  B<even if they only have one argument>:

 my %update =
	(
         table  => "student",
	 set    => "student_ssan = NULL",
	 where  => "student_country_id <> 1",
	 limit  => 12
	);

 my $sa  = SQL::AnyDBD->new($dbh);
 my $sql = $sa->UPDATE(%update);

 # yields...

 UPDATE student SET student_ssan = NULL WHERE student_country_id <> 1 LIMIT 12

=head2 $sa->INSERT ( table => $tbl, values => \@values ...

=over 4 

=item REQUIRED: table, values

=item OPTIONAL: columns

=back

 my %insert =
   (
     table     => "student",
     columns   => [qw(student_ssan3 student_ssan2 student_ssan4 
                      student_lname student_fname)],
     values    => [qw(123 45 9876 olajuwon hakeem)]
   );

 my $sa  = SQL::AnyDBD->new($dbh);
 my $sql = $sa->INSERT(%insert);

 # yields ...

 INSERT INTO student 
   (student_ssan3, student_ssan2, student_ssan4,student_lname,student_fname) 
 VALUES
   (123,           45,            9876,         olajuwon,     hakeem)

=head2 Utility methods

=head3 $sa->function($function_name, $argument_string)

This utility method helps us to consistently render funtion call SQL.

    $sa->function('foo') # FOO()
    $sa->function('bar', q{'baz = 1'}) # BAR('baz = 1')

A subclass might have a lookup hash in its function() where it translates common functions to its specific type and set default arguments:

    $sa->function('NOW') # SYSTEM_TIME( GMTOFFSET -4 )

=head3 $sa->get_placeholder_string()

Pass a single array ref or array and you get back a string suitable for placeholding ('?' joined with commas):

   my @people = (
       ['Larry', 'Wall'],
       ['Homer', 'Simpson'],
       ['Joe', 'Mama'],
   );

   my $sth = $dbh->prepare( 
       $sa->INSERT(
          'table'  => 'people',
          'values' => [ 'NULL', $sa->get_placeholder_string( $people[0] ) ], # ?,?
       )
   );
   # INSERT INTO people VALUES(NULL,?,?)
   
   for my $person ( @people ) {
       $sth->execute( @{ $person } );
   }

=head3 $sa->get_placeholder_array()

Same as get_placeholder_string() except it returns an array of '?' placeholder
(or an array ref of the same in scalar context)

=head3 $sa->get_sql_from_files()

Takes a list of files and concatenates their contents together.

If a given argument exists with a dot-normalized_sql_driver_name that is used instead.

If you are using SQLite and do this:

   my $sql = $sa->get_sql_from_files('./sql/schema');

Then is uses ./sql/schema.sqlite if it exists, and ./sql/schema if it does not.

If the last argument is a code ref its return value is what gets concatenated instead of the raw file.
It gets called with these arguments:
  SQL::AnyDBD-object, SQL,       FILE_PASSED,    FILE_OPENED
  $sa,               -contents-, './sql/schema', './sql/schema.sqlite'

=head3 $sa->normalized_sql_driver_name()

Normalized version of $sa->sql_driver_name()

=head3 $sa->sql_driver_name()

SQL::AnyDBD driver name

=head3 $sa->sql_driver_version()

SQL::AnyDBD driver version number.

=head3 $sa->get_dbh()

Returns the $dbh passed to new(). provided by L<DBIx::AnyDBD>

=head1 SEE ALSO

L<DBIx::Std>

=head2 Multi-database Products on CPAN

=over 4

=item L<DBIx::Std>

=item L<Rose::DB>

=item L<SQL::Translator>

=item L<Alzabo>

=item L<Class::DBI>

=item L<DBIx::Recordset>

=item L<DBIx::AnyDBD>

=back

=head2 Supported RDBMSes

=over 4

=item Postgresql

http://www.postgresql.org

=item SQLite

http://www.sqlite.org

=item MySQL

http://www.mysql.com

=back

=head1 AUTHOR

Terrence Brannon, <tbone@cpan.org>

v0.03 Co-maintainer Daniel Muey, L<http://drmuey.com/cpan_contact.pl>

=head1 COPYRIGHT AND LICENSE

Copyright 2003 by Terrence Brannon

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
