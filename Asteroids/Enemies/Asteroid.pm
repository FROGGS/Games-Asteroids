package Asteroids::Enemies::Asteroid;
use strict;
use warnings;
use Carp;

use Class::XSAccessor {
    accessors => [ qw(x y d r v_m v_r shape gpc size) ],
};

sub new {
    my ($class, $x, $y, $v_m, $size) = @_;

    my $self = bless {}, ref($class) || $class;

    $self->x( $x );
    $self->y( $y );
    $self->d( rand(360) );
    $self->r( rand(360) );
    $self->v_m( defined $v_m ? $v_m : (rand(1) + 1) );
    $self->v_r( rand(1) + 0.5);
    $self->v_r($self->v_r * -1) if int(rand(1) + 0.5);
    $self->size( defined $size ? $size : 3 );
    
    return $self;
}

1;
