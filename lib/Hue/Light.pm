package Hue::Light;

use common::sense;
use Class::Accessor;
use JSON::XS;
use Hash::Merge::Simple qw/ merge /;
use Data::Dumper;

use base qw(Class::Accessor);

__PACKAGE__->mk_accessors( qw / id hue _trx _data / );

sub begin
{
        my ($self) = @_;

	$self->_trx(1);
	return $self;
}

sub commit
{
        my ($self) = @_;

	$self->_trx(0);

	my $r = $self->hue->put($self->hue->path_to('lights', $self->id, 'state'), $self->_data);

	say Dumper($r->data);


	$self->_data({});
	return $r;
}

sub in_transaction
{
	return (shift)->_trx;
}

sub merge_param
{
        my ($self, $param) = @_;
	$self->_data(merge($self->_data || {}, $param));
	return $self;
}

sub set_state
{
        my ($self, $param) = @_;

	if (exists $param->{'on'}) {
		$param->{'on'} = (defined $param->{'on'} && $param->{'on'}) ? JSON::XS::true : JSON::XS::false;
	}

	$self->merge_param($param);

	if ($self->_trx) {
	} else {
#		say Dumper($param);
		$self->commit;
#		say Dumper($r->data);
	}

	return $self;
}

sub on
{
	return (shift)->set_state({ 'on' => 1 }); 
}

sub off
{
	return (shift)->set_state({ 'on' => 0 }); 
}

sub bri
{
	return (shift)->set_state({ 'bri' => int shift });
}

# 150-500
sub ct
{
	return (shift)->set_state({ 'ct' => int shift });
}

# 2000-6500
sub ct_k
{
	return (shift)->ct(1_000_000 / shift);
}

sub transitiontime
{
	return (shift)->merge_param({ 'transitiontime' => int shift });
}

1;
