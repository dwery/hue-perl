package Hue;

use strict;
use warnings;
use common::sense;

our $VERSION = '0.2';

use Moo;

has 'bridge' => ( is => 'rw' );
has 'key' => ( is => 'rw' );
has 'agent' => ( is => 'rw' );

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

sub get
{
	my ($self, $uri) = @_;

	my $req = HTTP::Request->new('GET', $uri);

	$req->content_type('application/json');

	my $res = $self->agent->request($req);

	say $res->status_line;

	return decode_json($res->decoded_content);
}

sub put
{
	my ($self, $uri, $data) = @_;

	my $req = HTTP::Request->new('PUT', $uri);

	$req->content_type('application/json');
	$req->content(encode_json($data));

	my $res = $self->agent->request($req);

	return decode_json($res->decoded_content);
}

sub config
{
	my ($self) = @_;

	say 'config';
	say $self->bridge;

	$self->server($self->bridge);
	$self->type('application/json');

	my $res = $self->get($self->path_to(''));

	say Dumper($res->data);
}

sub discovery
{
	
}

sub path_to
{
	my ($self, @endp) = @_;

	my $uri = join('/', $self->bridge, 'api', $self->key, @endp);
#	say $uri;
	return $uri;
}

sub light
{
	my ($self, $id) = @_;

	return Hue::Light->new({ 'hue' => $self, 'id' => $id });
}

1;
