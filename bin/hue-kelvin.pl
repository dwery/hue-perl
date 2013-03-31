#!/usr/bin/env perl

use strict;
use common::sense;

use Device::Hue;

die "usage: $0 <light number> <color temperature (K)>"
    unless scalar @ARGV == 2;

my ( $light, $ct ) = @ARGV;

my $hue = new Device::Hue;

$hue->light($light)->ct_k($ct);

# PODNAME: hue-kelvin.pl
# ABSTRACT: set the color temperature of your Philips Hue lights