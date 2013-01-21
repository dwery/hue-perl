package Hue;

use strict;
use warnings;
use common::sense;

our $VERSION = '0.1';

use Moose;
with 'Role::REST::Client';

has 'bridge' => ( is => "rw", isa => "Str" );
has 'key' => ( is => "rw", isa => "Str" );

use Hue::Light;

use Data::Dumper;
use Carp;

sub new
{
	my ($proto, @args) = @_;

	my $class = ref $proto || $proto;  

	my $self = $class->SUPER::new(@args);

	if ($self) {
		$self->init;
	}

	return $self;
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

	$self->server($self->bridge);
	$self->type('application/json');
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

sub path_to
{
	my ($self, @endp) = @_;

	my $uri = '/' . join('/', 'api', $self->key, @endp);
#	say $uri;
	return $uri;
}

sub light
{
	my ($self, $id) = @_;

	return Hue::Light->new({ 'hue' => $self, 'id' => $id });
}

1;
