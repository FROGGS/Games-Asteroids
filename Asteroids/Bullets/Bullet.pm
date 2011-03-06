package Asteroids::Bullets::Bullet;
use strict;
use warnings;
use Carp;
use Math::Trig;

use Class::XSAccessor {
    accessors => [ qw(x y r v_m gpc) ],
};

use SDL::Events;
use SDLx::App;

sub new {
    my ($class, $x, $y, $r) = @_;

    my $self = bless {}, ref($class) || $class;

    $self->r($r);
    $self->v_m(5);
    
    $self->x( $x + sin(deg2rad($self->r)) * 18 );
    $self->y( $y - cos(deg2rad($self->r)) * 18 );

    
    return $self;
}

1;
