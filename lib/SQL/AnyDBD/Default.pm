package SQL::AnyDBD::Default;

use strict;

use Params::Validate qw(:all);
use Data::Dumper;

sub SELECT {

    my $sa = shift;
    my %p = validate_with
      (params => \@_, 
       spec   => { 

		  fields => { type => ARRAYREF,  optional => 0 },
		  tables => { type => ARRAYREF,  optional => 0 },
		  where    => { type => SCALAR,  optional => 1 },
		  group_by => { type => SCALAR,  optional => 1 },
		  having   => { type => SCALAR,  optional => 1 },
		  order_by => { type => SCALAR,  optional => 1 },
		  limit    => { type => HASHREF, optional => 1 }

		 });

    my $fields = join ',', @{$p{fields}};
    my $tables = join ',', @{$p{tables}};

    my $where =  $p{where} ? "WHERE $p{where}" : undef;
    my $group_by = 
      $p{group_by} ? "GROUP BY $p{group_by}" : undef ;
    my $having =
      $p{having} ? "HAVING $p{having}" : undef;
    my $order_by = 
      $p{order_by} ? "ORDER BY $p{order_by}" : undef;
    my $limit  = 
      (scalar keys %{$p{limit}}) ? $sa->LIMIT(%{$p{limit}}) : undef ;

   "SELECT $fields FROM $tables $where $group_by $having $order_by $limit"

}

sub UPDATE {

    my $sa = shift;
    my %p = validate_with
      (params => \@_, 
       spec   => { 

		  table    => { type => SCALAR,  optional => 0 },
		  set      => { type => SCALAR,  optional => 0 },
		  where    => { type => SCALAR,  optional => 1 },
		  limit    => { type => SCALAR,  optional => 1 }

		 });


    my $where  =  $p{where} ? "WHERE $p{where}" : undef;
    my $limit  =  $p{limit} ? "LIMIT $p{limit}" : undef;


   "UPDATE $p{table} SET $p{set} $where $limit"

}

sub INSERT {

    my $sa = shift;
    my %p = validate_with
      (params => \@_, 
       spec   => { 

		  table     => { type => SCALAR,    optional => 0 },
		  columns   => { type => ARRAYREF,  optional => 1 },
		  values    => { type => ARRAYREF,  optional => 0 },
		 });

    my $columns =  scalar @{$p{columns}} 
      ? sprintf "(%s)", join ',', @{$p{columns}}
	: undef;
    my $values  = 
      sprintf "(%s)", join ',', @{$p{values}};

   "INSERT INTO $p{table} $columns VALUES $values"

}

sub DELETE {

    my $sa = shift;
    my %p = validate_with
      (params => \@_, 
       spec   => { 

		  table    => { type => SCALAR,  optional => 0 },
		  where    => { type => SCALAR,  optional => 1 },
		  order_by => { type => SCALAR,  optional => 1 },
		  limit    => { type => SCALAR,  optional => 1 }

		 });

    my $where =  $p{where} ? "WHERE $p{where}" : undef;
    my $group_by = 
      $p{group_by} ? "GROUP BY $p{group_by}" : undef ;
    my $order_by = 
      $p{order_by} ? "ORDER BY $p{order_by}" : undef;
    my $limit  = 
      $p{limit}    ? "LIMIT $p{limit}" : undef;

   "DELETE FROM $p{table} $where $order_by $limit"

}


sub IN {

   shift;
    my %p = validate_with
      (params => \@_, 
       spec   => { 

		  values => { type => ARRAYREF, optional => 0 },

		 });
   
   my $values = join ',' , @{$p{values}};
   $values ? "IN ($values)" : "" ;


}

1;
