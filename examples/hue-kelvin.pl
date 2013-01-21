#!/usr/bin/perl -w

use lib 'lib';
use local::lib;
use common::sense;

use Hue;

	die "usage: $0 <light number> <color temperature (K)>"
		unless scalar @ARGV == 2;

	my ($light, $ct) = @ARGV;

	my $hue = new Hue;

	$hue->light($light)->ct_k($ct);
