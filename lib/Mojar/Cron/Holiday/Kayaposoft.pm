package Mojar::Cron::Holiday::Kayaposoft;
use Mojo::Base 'Mojar::Cron::Holiday';

use Mojo::UserAgent;

has ua => sub { Mojo::UserAgent->new(max_redirects => 3) };
has country => 'eng';
has 'region';
has url => 'http://kayaposoft.com/enrico/json/v1.0/index.php';

sub load {
  my ($self, %param) = @_;

  $self->holidays({}) if $param{reset};
  my $total = 0;

  for my $i (-1, 0, 1) {
    my %args = (
      action => 'getPublicHolidaysForYear',
      country => $self->country,
      region => $self->region,
      year => (localtime)[5] + 1900 + $i,
      %param
    );
    my $url = $self->url .'?'.  Mojo::Parameters->new(%args)->to_string;

    my $tx = $self->ua->get($url);
    if ($tx->error and my ($err, $code) = $tx->error) {
      $self->error(sprintf "Failed to fetch holidays (%u)\n%s",
          $code // '0', $err // '');
      return undef;
    }

    my $loaded = $tx->res->json;
    if (ref $loaded eq 'HASH' and my $err = $loaded->{error}) {
      $self->error(sprintf "Failed to fetch holidays\n%s", $err // '');
      return undef;
    }
    return 0 unless @$loaded;

    $self->holiday(sprintf('%04u-%02u-%02u', $_->{date}{year},
        $_->{date}{month}, $_->{date}{day}) => 1) for @$loaded;
    $total += @$loaded;
  }

  return $total;
}

1;
__END__

=head1 NAME

Mojar::Cron::Holiday::Kayaposoft - Feed from holidays.kayaposoft.com

=head1 SYNOPSIS

  use Mojar::Cron::Holiday::Kayaposoft;
  my $calendar = Mojar::Cron::Holiday::Kayaposoft->new(country => 'nir');
  if ($calendar->load) {
    say 'Whoopee!' if $calendar->holiday($today);
  }

=head1 COPYRIGHT AND LICENCE

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.

Copyright (C) 2014, Nic Sandfield.

=head1 SEE ALSO

L<Mojar::Cron::Holiday::UkGov>.
