#!/usr/bin/env perl

use strict;
use Device::Hue;
use common::sense;

my $hue = Device::Hue->new( { 'debug' => 1 } );

my $lights = $hue->lights;

foreach (@$lights) {
    say join( " - ", $_->id, $_->modelid, $_->name );
}

# PODNAME: hue-info.pl
# ABSTRACT: report the current status of your Philips Hue devices
