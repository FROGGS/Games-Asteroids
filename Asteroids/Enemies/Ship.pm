package Asteroids::Enemies::Ship;
use strict;
use warnings;
use Carp;
use Math::Trig;

use Class::XSAccessor {
    accessors => [ qw(x y d r v_m v_r gpc) ],
};

use SDL::Events;
use SDLx::App;

sub new {
    my ($class, $x, $y, $r) = @_;

    my $self = bless {}, ref($class) || $class;

    $self->x( $x + sin(deg2rad($self->r)) * 18 );
    $self->y( $y - cos(deg2rad($self->r)) * 18 );
    $self->d( 0 );
    $self->r( $r );
    $self->v_m( 5 );
    $self->v_r( 0 );
    
    return $self;
}

1;
