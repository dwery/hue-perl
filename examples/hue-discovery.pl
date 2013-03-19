#!/usr/bin/env perl

use common::sense;

use Device::Hue;

my $hue = Device::Hue->new({ 'debug' => 1 });

say 'finding using remote upnp...';

foreach (@{$hue->nupnp}) {
	say $_;
}

say "\nfinding using local upnp...";

foreach (@{$hue->upnp}) {
	say $_;
}
