package Mojar::Cron::Util;
use Mojo::Base 'Exporter';

use Carp 'croak';
use POSIX qw( mktime strftime );
use Time::Local 'timegm';

our @EXPORT_OK = qw(
  time_to_zero zero_to_time cron_to_zero zero_to_cron life_to_zero zero_to_life
  balance normalise_utc normalise_local 
  utc_to_ts local_to_ts ts_to_utc ts_to_local
  local_to_utc utc_to_local
);

# ------------
# Public functions
# ------------

sub time_to_zero { @_[0..2], $_[3] - 1, @_[4..$#_] }
sub zero_to_time { @_[0..2], $_[3] + 1, @_[4 .. $#_] }

sub cron_to_zero { @_[0..2], $_[3] - 1, $_[4] - 1, @_[5..$#_] }
sub zero_to_cron { @_[0..2], $_[3] + 1, $_[4] + 1, @_[5..$#_] }

sub life_to_zero { @_[0..2], $_[3] - 1, $_[4] - 1, $_[5] - 1900, @_[6..$#_] }
sub zero_to_life { @_[0..2], $_[3] + 1, $_[4] + 1, $_[5] + 1900, @_[6..$#_] }

sub balance {
  my @parts = @_;
  my @Max = (59, 59, 23, undef, 11);
  # Bring values within range for sec, min, hour, month
  for (0,1,2,4) {
    $parts[$_] += $Max[$_] + 1, --$parts[$_ + 1] while $parts[$_] < 0;
    $parts[$_] -= $Max[$_] + 1, ++$parts[$_ + 1] while $parts[$_] > $Max[$_];
  }
  return @parts;
}

sub normalise_utc {
  my @parts = balance @_;
  my $days = $parts[3] - 1;  # could be negative
  my $ts = timegm @parts[0..2], 1, @parts[4..$#parts];
  $ts += $days * 24 * 60 * 60;
  return gmtime $ts;
}

sub normalise_local {
  my @parts = balance @_;
  my $days = 0;
  if ($parts[3] < 1 or 28 < $parts[3] && $parts[4] == 1 or 30 < $parts[3]) {
    $days = $parts[3] - 1;  # possibly negative
    $parts[3] = 1;
  }
  my $ts = mktime @parts;
  $ts += $days * 24 * 60 * 60;
  return localtime $ts;
}

sub utc_to_ts       { timegm @_ }
sub local_to_ts     { mktime @_ }

sub ts_to_utc       { gmtime $_[0] }
sub ts_to_local     { localtime $_[0] }

sub local_to_utc    { gmtime mktime @_ }
sub utc_to_local    { localtime timegm @_ }

my %UnitFactor = (
  S => 1,
  M => 60,
  H => 60 * 60,
  d => 60 * 60 * 24,
  w => 60 * 60 * 24 * 7,
  m => 60 * 60 * 24 * 30,
  y => 60 * 60 * 24 * 365
);

sub str_to_delta {
  my ($str) = @_;
  return 0 unless $str;
  return $str if $str =~ /^[-+]?\d+S?$/;
  return $1 * $UnitFactor{$2} if $str =~ /^([-+]?\d+)([MHdwmy])$/;
  croak qq{Failed to interpret time period ($str)};
}

1;
__END__
