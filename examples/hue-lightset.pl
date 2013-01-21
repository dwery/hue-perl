#!/usr/bin/perl -w

use lib 'lib';
use local::lib;
use common::sense;

use Hue;
use Hue::LightSet;

	my $hue = new Hue;

	my $set = Hue::LightSet->create($hue->light(1), $hue->light(3));

	$set->on;

	sleep 2;

	$set->off;



