use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'		=> 'SQL::AnyDBD',
    'VERSION_FROM'	=> 'lib/SQL/AnyDBD.pm',
    'PREREQ_PM'		=> 
	      {
	       'DBIx::AnyDBD'     => 2.01,
	       'Params::Validate' => 0.69,
	      }, 
    ($] >= 5.005 ?   
      (ABSTRACT_FROM => 'lib/SQL/AnyDBD.pm',
       AUTHOR     => 'Terrence Brannon <metaperl@urth.org>') : ()),
);
