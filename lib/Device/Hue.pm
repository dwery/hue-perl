use strict;

package Device::Hue;

use warnings;
use common::sense;

use Moo;

has 'bridge' => ( is => 'rw' );
has 'key'    => ( is => 'rw' );
has 'agent'  => ( is => 'rw' );
has 'debug'  => ( is => 'rw' );

use Device::Hue::UPnP;
use Device::Hue::Light;

use LWP::UserAgent;
use LWP::Protocol::https;

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

	# Extend the bridge address with http if it is not present.
	my $bridge = $self->bridge;
	$self->bridge('http://' . $bridge)
		if ($bridge =~ /^\d/);

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

	} else {
		say "Request failed: " . $res->status_line if $self->debug;
	}

	return undef;
}

sub get
{
	my ($self, $uri) = @_;

	say "GET $uri" if $self->debug;

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
		or return;

	my @lights = ();

	foreach my $key (sort keys %{ $config->{'lights'} }) {

		my $light = $config->{'lights'}{$key};

		push @lights, Device::Hue::Light->new({
				'hue'	=> $self,
				'id'	=> $key,
				'data'	=> $light,
		});
	}

	return \@lights;
}

sub discovery
{
	my ($self) = @_;

	my $devices = $self->nupnp;

	return scalar @$devices ? $devices : $self->upnp;
}

sub nupnp
{
	my $data = (shift)->get('https://www.meethue.com/api/nupnp')
		or return [];

	return [ map { $_->{'internalipaddress'} } @$data ];
}

sub upnp
{
	return Device::Hue::UPnP::upnp();
}

sub path_to
{
	my ($self, @endp) = @_;

	my $bridge = $self->bridge;

	# Extend the bridge address with http if it is not present.
	$bridge = 'http://' . $bridge if ($bridge =~ /^\d/);
	my $uri = join('/', $self->bridge, 'api', $self->key, @endp);

	say $uri
		if $self->debug;

	return $uri;
}

sub light
{
	my ($self, $id) = @_;

	return Device::Hue::Light->new({ 'hue' => $self, 'id' => $id });
}

1;

# ABSTRACT: Perl module for the Philips Hue light system

=head1 DESCRIPTION

A perl module to interface Philips Hue devices. See http://meethue.com

To use the examples in the examples folder, please configure the environment appropriately (using your own IP address
and API key):

=over

=item export HUE_BRIDGE="192.168.1.123"

=item export HUE_KEY="7c1590fb6089be2129260acb2df53372"

=back

=head1 CONSTRUCTOR METHODS

=head2 $hue = Device::Hue->new({ %parameters })

This is the constructor of the Device::Hue object. Supported parameters are:

=over

=item bridge

IP address of the hue bridge, in dotted notation numeric form

=item key

Your API key, something like 7c1590fb6089be2129260acb2df53372

=item agent

Defaults to LWP::UserAgent

=item debug

Set to 1 to enable debugging output

=back

=head1 METHODS

=head2 $hue->discovery

Tries to discover a bridge, returns an arrayref of IP addresses

=head2 $hue->light($id)

Return a Device::Hue::Light object for the specified light id

=head2 $hue->lights

To be documented

=head2 $hue->nupnp

Tries to discover a bridge using the remote API, returns an arrayref of IP addresses

=cut
