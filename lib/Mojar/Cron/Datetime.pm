package Mojar::Cron::Datetime;
use Mojo::Base -base;

use Carp qw(carp croak);
use Mojar::ClassShare 'have';
use Mojar::Cron::Util qw(balance normalise_local normalise_utc
    time_to_zero zero_to_time utc_to_ts local_to_ts);
use POSIX 'strftime';
#use Time::Local 'timegm';

our @TimeFields = qw(sec min hour day month year);

# Normal maxima (soft limits)
%Mojar::Cron::Datetime::Max = (
  sec  => 59,
  min  => 59,
  hour => 23,
  day => 30,
  month  => 11,
  weekday => 6
);
@Mojar::Cron::Datetime::Max =
    @Mojar::Cron::Datetime::Max{qw(sec min hour day month weekday)};

# Class attributes
# (not usable on objects)

have format => '%Y-%m-%d %H:%M:%S';
have is_local => 0;

# Constructors

sub new {
  my $class = shift;
  my $self;
  if (ref $class) {
    # Clone
    $self = [ @$class ];
    $class = ref $class;
    carp "Useless arguments to new (@{[ join ',', @_ ]})" if @_;
  }
  elsif (@_ == 0) {
    # Zero member
    $self = [0,0,0, 0,0,0];
  }
  elsif (@_ == 1) {
    # Pre-generated
    $self = shift;
    croak "Non-ref argument to new ($self)" unless ref $self;
  }
  else {
    $self = [ @_ ];
  }
  bless $self => $class;
  return $self->normalise;  # Calculate weekday etc
}

sub from_timestamp {
  my ($class, $timestamp, $is_local) = @_;
  $class = ref $class || $class;
  my @parts = $is_local ? localtime $timestamp
                        : gmtime $timestamp;
  return $class->new( time_to_zero @parts );
}

sub now { shift->from_timestamp(time, @_) }

sub from_string {
  my ($class, $iso_date, $local) = @_;
  $class = ref $class || $class;
  if ($iso_date =~ /^(\d{4})-(\d{2})-(\d{2})(?:T|\s)(\d{2}):(\d{2}):(\d{2})Z?$/) {
    return $class->new($6, $5, $4, $3 - 1, $2 - 1, $1 - 1900);
  }
  croak "Failed to parse datetime string ($iso_date)";
}

# Public methods

sub reset_parts {
  my ($self, $end) = @_;
  $$self[$_] = 0 for 0 .. $end;
  return $self;
}

sub weekday {
  my $self = shift;
  $self->normalise;
  return $self->[6];
}

sub normalise {
  my $self = shift;
  my $class = ref $self || $self;
  my (@parts, $is_modifier);
  if (@_) {
    # operate on args
    @parts = balance @_;
  }
  else {
    # operate on $self
    @parts = balance @$self;
    $is_modifier = 1;
  }
  @parts = zero_to_time @parts;
  @parts = $class->is_local
      ? normalise_local @parts
      : normalise_utc @parts;
  return time_to_zero @parts unless $is_modifier;

  @$self = time_to_zero @parts;
  return $self;
}

sub to_timestamp {
  my ($self, $is_local) = @_;
  return $is_local ? local_to_ts zero_to_time @$self
                   : utc_to_ts zero_to_time @$self;
}

sub to_string {
  my $self = shift;
  my $class = ref $self || $self;
  $self = ref $_[0] ? shift : [ @_ ] unless ref $self;
  return strftime $class->format, zero_to_time @$self;
}

sub with_format { strftime $_[1], zero_to_time @{$_[0]} }

1;
__END__

=head1 NAME

Mojar::Cron::Datetime - Lightweight datetime with small footprint

=head1 SYNOPSIS

  use Mojar::Cron::Datetime;
  say Mojar::Cron::Datetime->now->to_string;
  my $d = Mojar::Cron::Datetime->from_string('2001-12-25 00:00:01');
  $d->day($d->day + 14);
  $d->normalise;
  say "$d";

=head1 DESCRIPTION

=head1 CONSTRUCTORS

=head2 C<new>

Construct a datetime from passed arguments.

  $d = Mojar::Cron::Datetime->new;  # zero datetime
  $d = $datetime->new;  # clone
  $d = Mojar::Cron::Datetime->new([00, 00, 20, 26, 06, 112]);
  $d = Mojar::Cron::Datetime->new(00, 00, 20, 26, 06, 112);

The first constructs the zero datetime '1900-01-01 00:00:00'.  The second clones
the value of C<$datetime>.  The third uses the passed value (2012-07-27 21:00:00
London time expressed in UTC).  The fourth does the same but using its own
reference.

=head2 C<now>

  $d = Mojar::Cron::Datetime->now;
  $d = Mojar::Cron::Datetime->now($use_local);
  $d = $d->now;

constructs a datetime for now.  Uses UTC clock unless passed a true value
(indicating to use local clock).  If called as an object method, ignores the
value of the object, so it gives the same result as the class method.  (Compare
to C<new> which uses the object's value.)

=head2 C<from_string>

  $d = Mojar::Cron::Datetime->from_string('2012-07-27 20:00:00');
  $d = Mojar::Cron::Datetime->from_string('2012-07-28 01:00:00', 1);

constructs a datetime by parsing an ISO 8601 string.  (The method only supports
the format shown and not any of the other 8601 variants.)  Both examples result
in the same value if the machine's clock is in UTC+5.

=head1 METHODS

=head2 C<normalise>

=head2 C<to_string>

=head1 SEE ALSO

L<DateTime>.

=cut
