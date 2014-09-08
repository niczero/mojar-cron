use 5.010001;
use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  NAME         => 'Mojar::Cron',
  VERSION_FROM => 'lib/Mojar/Cron.pm',
  ABSTRACT     => 'Cron-style time patterns and algorithm',
  AUTHOR       => 'Nic Sandfield <niczero@cpan.org>',
  LICENSE      => 'artistic_2',
  META_MERGE   => {
    requires  => {perl => 5.010001},
    resources => {
      homepage    => 'http://niczero.github.com/mojar-cron/',
      license     => 'http://www.opensource.org/licenses/artistic-license-2.0',
      repository  => 'http://github.com/niczero/mojar-cron',
      bugtracker  => 'http://github.com/niczero/mojar-cron/issues'
    },
    no_index => {directory => [qw(test)]}
  },
  BUILD_REQUIRES => {'Test::More' => '0'},
  CONFIGURE_REQUIRES => {'ExtUtils::MakeMaker' => '6.30'},
  PREREQ_PM => {
    Mojolicious => 5,
    Mojar => 1.053
  },
  EXE_FILES => [],
  test => {TESTS => 'test/*.t'}
);
