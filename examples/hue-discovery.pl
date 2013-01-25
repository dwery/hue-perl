#!/usr/bin/perl -w

use lib 'lib';
use local::lib;
use common::sense;

use Hue;

	my $hue = Hue->new({ 'debug' => 1 });

	say 'finding using remote upnp...';

	foreach (@{$hue->nupnp}) {
		say $_;
	}

	say "\nfinding using local upnp...";

	foreach (@{$hue->upnp}) {
		say $_;
	}
