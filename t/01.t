#!/usr/bin/perl -w

use strict;
use vars qw/$TESTS/;
BEGIN { $TESTS = 11; }

use Test::More tests => $TESTS;

SKIP: {
  my $dbh = DBI->connect('dbi:mysql:test');
  skip "Don't have MySQL test DB", $TESTS unless $dbh;
  my $table = create_test_table($dbh) or
    skip "Can't create MySQL test DB", $TESTS;

  package Sheep;
  use base 'Class::DBI::mysql';
  use Class::DBI::mysql::FullTextSearch;
  __PACKAGE__->set_db('Main', "dbi:mysql:test", '', '');
  __PACKAGE__->set_up_table($table);
  __PACKAGE__->full_text_search(find_some => [qw/title keywords/]);

  package main;
  my $sheep = Sheep->create({
    title    => 'Beowulf Genomics',
    keywords => 'Teladorsagia circumcincta, Haemonchus contortus',
  });
  isa_ok $sheep => 'Sheep';
  ok $sheep->_find_some_handle, 'DBIx::FullTextSearch';

  my @by_title = Sheep->find_some('genomics');
  ok @by_title == 1, "Found an article by title: $by_title[0]";
  my $found = $by_title[0];
  isa_ok $found => 'Sheep';
  is $found->id, $sheep->id, " the correct one";

  my @by_keywords = Sheep->find_some('circumcincta');
  ok @by_keywords == 1, "Found an article by keyword";
  is $by_keywords[0]->id, $sheep->id, " the correct one";

  $sheep->keywords("Haemonchus contortus");
  ok $sheep->commit, "No more contortus";

  my @now = Sheep->find_some('circumcincta');
  ok @now == 0, "So no-one interested in circumcincta any more :(";

  ok($sheep->_find_some_handle->drop, "Clean up index");
  ok($dbh->do("DROP TABLE $table"), "Clean up table");

  $dbh->disconnect;
}

sub create_test_table {
  my $dbh = shift;
  my $table_name = next_available_table($dbh);
  eval {
    my $create = qq{
      CREATE TABLE $table_name (
        id mediumint not null auto_increment primary key,
        title varchar(255) not null default '',
        keywords varchar(255) not null default ''
      )
    };
    $dbh->do($create);
  };
  return $@ ? 0 : $table_name;
}

sub next_available_table {
  my $dbh = shift;
  my @tables = sort @{ $dbh->selectcol_arrayref(qq{
    SHOW TABLES
  })};
  my $table = $tables[-1] || "aaa";
  return "z$table";
}

