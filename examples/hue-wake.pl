#!/usr/bin/perl -w

use lib 'lib';
use local::lib;
use common::sense;

use Hue;

	die "usage: $0 <light number> <color temperature (K)> <sunrise in minutes>"
		unless scalar @ARGV == 3;

	my ($light, $temp, $minutes) = @ARGV;

	my $hue = new Hue;

	my $l = $hue->light($light);

	$l->off;

	sleep 1;

	$l->begin->bri(1)->ct_k($temp)->on->commit;
	$l->begin->transitiontime($minutes * 60 * 10)->bri(255)->commit;
