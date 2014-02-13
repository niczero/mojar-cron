use Mojo::Base -strict;
use Test::More;

use Mojar::Cron::Datetime;

my $dt;

subtest q{Basics} => sub {
  is $Mojar::Cron::Datetime::Max{weekday}, 6, 'Max weekday from hash';
  is $Mojar::Cron::Datetime::Max[5], 6, 'Max weekday from array';
};

subtest q{Constructors} => sub {
  ok $dt = Mojar::Cron::Datetime->new;
  ok $dt = Mojar::Cron::Datetime->now;
};

subtest q{Strings} => sub {
  my $a = '2012-02-29 23:59:59';
  ok $dt = $dt->from_string($a), 'from_string';
  is $dt->to_string, $a, 'from_string then to_string roundtrip';
};

sub check_normalise {
  my ($in, $expected) = @_;
  my $datetime = Mojar::Cron::Datetime->from_string($in);
  is $datetime->to_string, $expected, "from_string $in";
  $datetime->normalise;
  is $datetime->to_string, $expected, "normalise $in";
}

subtest q{normalise} => sub {
  check_normalise('2012-01-01 00:00:00', '2012-01-01 00:00:00');
  check_normalise('2010-01-19 00:00:00', '2010-01-19 00:00:00');
  check_normalise('2012-02-29 23:59:59', '2012-02-29 23:59:59');
  check_normalise('2012-02-30 23:59:59', '2012-03-01 23:59:59');
};

done_testing();
