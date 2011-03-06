package Asteroids::Bullets;
use strict;
use warnings;
use Carp;
use Math::Trig;
use Math::Geometry::Planar;

use SDLx::App;
use Asteroids::Bullets::Bullet;

sub move {
    my ( $delta, $app, $t ) = @_;
    
    foreach my $b (@{$app->stash->{bullets}}) {
        next unless defined $b;
        $b->x( $b->x + sin(deg2rad($b->r)) * $b->v_m);
        $b->y( $b->y - cos(deg2rad($b->r)) * $b->v_m);

        if($b->x < $app->stash->{field}->x
        || $b->x > $app->stash->{field}->x + $app->stash->{field}->w
        || $b->y < $app->stash->{field}->y
        || $b->y > $app->stash->{field}->y + $app->stash->{field}->h) {
            $b = undef;
        }
        else {
            my $a = Math::Geometry::Planar->new;
            $a->polygons([[
                [$b->x, $b->y],
                [$b->x+1, $b->y],
                [$b->x+1, $b->y+1]
            ]]);
            $b->gpc($a->convert2gpc($a));
        }
    }
}

sub show {
    my ( $delta, $app ) = @_;

    foreach my $b (@{$app->stash->{bullets}}) {
        next unless defined $b;
        $app->draw_line( [ $b->x - sin(deg2rad($b->r)) * 9, $b->y + cos(deg2rad($b->r)) * 9 ], [ $b->x, $b->y ], 0xFFFFFFFF );
    }
}

1;
