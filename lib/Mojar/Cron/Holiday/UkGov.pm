package Mojar::Cron::Holiday::UkGov;
use Mojo::Base 'Mojar::Cron::Holiday';

use Mojo::UserAgent;

has ua => sub { Mojo::UserAgent->new(max_redirects => 3) };
has division => 'england-and-wales';
has url => 'https://www.gov.uk/bank-holidays.json';

sub load {
  my ($self, %param) = @_;
  require IO::Socket::SSL;

  my $tx = $self->ua->get($self->url);
  if ($tx->error and my ($err, $code) = $tx->error) {
    $self->error(sprintf "Failed to fetch holidays (%u)\n%s",
        $code // '0', $err // '');
    return undef;
  }

  my $loaded = $tx->res->json(sprintf '/%s/events', $self->division);
  return 0 unless @$loaded;

  $self->holidays({}) if $param{reset};
  $self->holiday($_->{date} => 1) for @$loaded;

  return scalar @$loaded;
}

1;
__END__

=head1 NAME

Mojar::Cron::Holiday::UkGov - Feed from gov.uk

=head1 SYNOPSIS

  use Mojar::Cron::Holiday::UkGov;
  my $calendar = Mojar::Cron::Holiday::UkGov->new(division => 'Scotland');
  if ($calendar->load) {
    say 'Whoopee!' if $calendar->holiday($today);
  }

=head1 COPYRIGHT AND LICENCE

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.

Copyright (C) 2014, Nic Sandfield.

=head1 SEE ALSO

L<Mojar::Cron::Holiday::Kayaposoft>.
