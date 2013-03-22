use strict;

package Device::Hue::LightSet;

use common::sense;
use Class::Accessor;

use base qw(Class::Accessor);
use vars qw($AUTOLOAD);

__PACKAGE__->mk_accessors(qw / _group _trx /);

sub create {
    my ( $self, @lights ) = @_;

    $self = ref($self) || $self->new;

    $self->_group( [@lights] );

    return $self;
}

sub begin {
    my ($self) = @_;

    $self->_trx(1);
    do { $_->begin; }
        for @{ $self->_group };
}

sub commit {
    my ($self) = @_;

    do { $_->commit; }
        for @{ $self->_group };
    $self->_trx(0);
}

sub in_transaction {
    return (shift)->_trx;
}

sub AUTOLOAD {
    my ( $self, @args ) = @_;

    ( my $method = $AUTOLOAD ) =~ s/.*:://;

    return if $method eq 'DESTROY';

    foreach ( @{ $self->_group } ) {
        my $rc = $_->$method(@args);
    }
}

1;

# ABSTRACT: A set of light items to be used with Device::Hue

=head1 DESCRIPTION

A set of light bulbs to be controlled together

=head1 METHODS

=head2 C<begin>

=head2 C<commit>

=head2 C<create(id1, id2, ...)>

Create a set of lights, consisting of the lights with ID id1, id2, ...

=head2 C<in_transaction>

=cut


