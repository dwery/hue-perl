#!/usr/bin/env perl

use strict;
use common::sense;

use Device::Hue;
use Device::Hue::LightSet;

my $hue = new Device::Hue;

my $set = Device::Hue::LightSet->create( $hue->light(1), $hue->light(3) );

$set->on;

sleep 2;

$set->off;

# PODNAME: hue-lightset.pl
# ABSTRACT: example program that shows how to control a set of Philips Hue lights with the Device::Hue module.