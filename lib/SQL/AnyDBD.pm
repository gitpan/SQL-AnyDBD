package SQL::AnyDBD;

use 5.008;
use strict;
use warnings;

require Exporter;

use base qw/ DBIx::AnyDBD / ;

use Params::Validate qw(:all);

#our @ISA = qw(DBI);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use SQL::AnyDBD ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '0.01';


# Preloaded methods go here.

sub new {

  my ($pkg, $dbh) = @_;
  my $self = bless { 'package' => __PACKAGE__ , dbh => $dbh }, __PACKAGE__;
  $self->rebless;
  $self->_init if $self->can('_init');
  return $self; 

}



1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

SQL::AnyDBD - Perl extension to generate SQL for RDBMS variants

=head1 SYNOPSIS

  use SQL::AnyDBD;

  my $dbh = DBI->connect($dsn, $user, $pass, $attr) or die $!;
  my $sb  = SQL::AnyDBD->new($dbh);

  my $rows_desired = 8;
  my $start_row    = 4;

  warn $sb->LIMIT(rows_desired => $rows_desired, start_row => $start_row);

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

=head2 $sb->LIMIT ( rows_desired => $rows_desired, start_row => $start_row )

=over 4

=item REQUIRED: rows_desired

=item OPTIONAL: start_row

=back

A limit clause is used to limit the result set from an SQL select. 
Each of the big 3 supports this concept. All 3 also accept integers for both
arguments. However, Pg can also accept the term C<ALL> for C<rows_desired>.  


=head2 $sb->IN ( values => \@v )

=over 4 

=item REQUIRED: values

=back

It is required that the arrayref C<values> be passed. 
It is not required that the
arrayref have any data:

 my $sql = $sb->IN(values => [qw(fee fi fo fum)]);

 # yields...

 IN (fee,fi,fo,fum)

=head2 $sb->SELECT ( fields => \@f, tables => \@t, ... )

=over 4 

=item REQUIRED: fields, tables

=item OPTIONAL: where, group_by, having, order_by, limit

=back

All the optional arguments take a string as an argument with the exception of
C<limit> which takes a hashref which is passed to C<LIMIT()>. Both required
arguments take an arrayref  B<even if they only have one argument>: 

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


=head2 $sb->UPDATE ( set => $set_expr, ...

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

 my $sb  = SQL::AnyDBD->new($dbh);
 my $sql = $sb->UPDATE(%update);

 # yields...

 UPDATE student SET student_ssan = NULL WHERE student_country_id <> 1 LIMIT 12

=head2 $sb->INSERT ( table => $tbl, values => \@values ...

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

 my $sb  = SQL::AnyDBD->new($dbh);
 my $sql = $sb->INSERT(%insert);

 # yields ...

 INSERT INTO student 
   (student_ssan3, student_ssan2, student_ssan4,student_lname,student_fname) 
 VALUES
   (123,           45,            9876,         olajuwon,     hakeem)


=head2 EXPORT

None by default.


=head1 SEE ALSO

=head2 Multi-database Products on CPAN

=over 4

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

=head1 COPYRIGHT AND LICENSE

Copyright 2003 by Terrence Brannon

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
