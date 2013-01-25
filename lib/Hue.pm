package Hue;

use strict;
use warnings;
use common::sense;

our $VERSION = '0.2';

use Moo;

has 'bridge' => ( is => 'rw' );
has 'key' => ( is => 'rw' );
has 'agent' => ( is => 'rw' );
has 'debug' => ( is => 'rw' );

use Hue::UPnP;
use Hue::Light;

use LWP::UserAgent;
use JSON::XS;

use Data::Dumper;
use Carp;

sub BUILD
{
	my ($self) = @_;

	$self->agent(new LWP::UserAgent);
	$self->init;
}

sub init
{
	my ($self) = @_;

	$self->bridge($ENV{'HUE_BRIDGE'})
		if defined $ENV{'HUE_BRIDGE'};

	$self->key($ENV{'HUE_KEY'})
		if defined $ENV{'HUE_KEY'};

	croak "missing hue bridge"
		unless defined $self->bridge;
	
	croak "missing hue key"
		unless defined $self->key;
}

sub process
{
	my ($self, $res) = @_;

	if ($res->is_success) {

		say $res->status_line
			if $self->debug;

		say Dumper(decode_json($res->decoded_content))
			if $self->debug;

		return decode_json($res->decoded_content);
	} 
	
	return undef;
}

sub get
{
	my ($self, $uri) = @_;

	my $req = HTTP::Request->new('GET', $uri);

	$req->content_type('application/json');

	return $self->process($self->agent->request($req));
}

sub put
{
	my ($self, $uri, $data) = @_;

	my $req = HTTP::Request->new('PUT', $uri);

	$req->content_type('application/json');
	$req->content(encode_json($data));

	return $self->process($self->agent->request($req));
}

sub config
{
	my ($self) = @_;

	return $self->get($self->path_to(''));
}

sub schedules
{
	my ($self) = @_;

	return $self->get($self->path_to('schedules'));
}

sub lights
{
	my ($self) = @_;

	my $config = $self->config
		or return undef;

	my @lights = ();

	foreach my $key (sort keys %{$config->{'lights'}}) {

		my $light = $config->{'lights'}{$key};

		push @lights, Hue::Light->new({ 'hue' => $self, 'id' => $key, 'data' => $light });
	}

	return \@lights;
}

sub discovery
{
	my ($self) = @_;

	my $devices = $self->nupnp;
	return $devices if scalar @$devices;

	return $self->pnp;
}

sub nupnp
{
	my ($self) = @_;

	my $data = $self->get('https://www.meethue.com/api/nupnp');
	return [] unless defined $data;

	my @devices = ();

	foreach (@$data) {
		push @devices, $_->{'internalipaddress'};
	}

	return \@devices;
}

sub upnp
{
	my ($self) = @_;

	return Hue::UPnP::upnp();
}

sub path_to
{
	my ($self, @endp) = @_;

	my $uri = join('/', $self->bridge, 'api', $self->key, @endp);

	say $uri
		if $self->debug;

	return $uri;
}

sub light
{
	my ($self, $id) = @_;

	return Hue::Light->new({ 'hue' => $self, 'id' => $id });
}

1;

__DATA__
$VAR1 = [
          {
            'macaddress' => '00:17:88:09:c4:a1',
            'internalipaddress' => '192.168.1.122',
            'id' => '001788fffe09c4a1'
          }
        ];
