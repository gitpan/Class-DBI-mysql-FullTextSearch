use ExtUtils::MakeMaker;

my $me = "lib/Class/DBI/mysql/FullTextSearch.pm";

WriteMakefile(
    NAME          => 'Class::DBI::mysql::FullTextSearch',
    VERSION_FROM  => $me, 
    PREREQ_PM     => { 
      'Class::DBI::mysql'    => '0.10',
      'DBIx::FullTextSearch' => '0.57',
      'Lingua::Stem'         => '0.50',
      'Test::Simple'         => '0.17',
    },
    ($] < 5.005 ? () : (
       ABSTRACT_FROM => $me, 
       AUTHOR     => 'Tony Bowden <kasei@tmtm.com>') 
    ),
);
