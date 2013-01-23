#!/usr/bin/perl -w

use lib 'lib';
use local::lib;
use common::sense;

use Hue;

	my $hue = Hue->new({ 'debug' => 1 });

	$hue->discovery;
