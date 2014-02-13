use Mojo::Base -strict;
use Test::More;

use Mojar::Cron::Util qw( utc_to_ts local_to_ts ts_to_utc ts_to_local
  local_to_utc utc_to_local normalise_utc normalise_local 
  time_to_zero zero_to_time cron_to_zero zero_to_cron life_to_zero zero_to_life
);
use Mojar::Cron::Datetime;

my ($dt, $es);

subtest q{Last second of Feb '12} => sub {
  ok $dt = Mojar::Cron::Datetime->new([59, 59, 23, 28, 01, 112]), 'new (Feb)';

  ok $es = utc_to_ts(zero_to_time @$dt), 'datetime -> epoch secs';

  ok my @lt = ts_to_local($es), 'timestamp -> local time';
  ok my @zero = time_to_zero(local_to_utc @lt), 'local time -> datetime';
  is_deeply [@zero], $dt, 'local -> utc -> datetime';

  is_deeply [ zero_to_life @zero ], [59, 59, 23, 29, 2, 2012, 3, 59, 0],
      'datetime -> real life';
};

subtest q{normalise_utc} => sub {
  my @date = (00, 00, 02, 31, 02, 2012);
  ok my @zero = life_to_zero(@date), 'real life -> datetime';
  is_deeply [ @zero ], [00, 00, 02, 30, 01, 112], 'correct parts';
  ok $dt = Mojar::Cron::Datetime->new(@zero), 'datetime constructed';

  $dt->[3] = 30; $dt->[4] = 1;
  is_deeply [ @$dt[0..5] ], [00, 00, 02, 30, 01, 112], 'before normalise';
  ok @$dt = time_to_zero(normalise_utc zero_to_time @$dt), 'normalise';
  is_deeply [ @$dt[0..5] ], [00, 00, 02, 01, 02, 112], 'after normalise';

  @$dt = (00, 00, 02, 29, 01, 112);
  is_deeply $dt, [00, 00, 02, 29, 01, 112], 'before normalise';
  ok @$dt = time_to_zero(normalise_utc zero_to_time @$dt), 'normalise';
  is_deeply [ @$dt[0..5] ], [00, 00, 02, 00, 02, 112], 'after normalise';
};

done_testing();
