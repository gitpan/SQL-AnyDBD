use 5.008;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'SQL::AnyDBD',
    'VERSION_FROM'	=> 'lib/SQL/AnyDBD.pm', # finds $VERSION
    'PREREQ_PM'		=> 
	      {
	       'DBIx::AnyDBD'     => 2.01,
	       'Params::Validate' => 0.69
	      }, 
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'lib/SQL/AnyDBD.pm', # retrieve abstract from module
       AUTHOR     => 'Terrence Brannon <metaperl@urth.org>') : ()),
);
