package Asteroids::Enemies;
use strict;
use warnings;
use Carp;
use Math::Trig;
use Math::Geometry::Planar;

use SDLx::App;
use Asteroids::Enemies::Asteroid;
use Asteroids::Enemies::Ship;

sub move {
    my ( $delta, $app, $t ) = @_;
    
    foreach my $e (@{$app->stash->{enemies}}) {
        next unless defined $e;
        
        $e->r( $e->r + $e->v_r );
        
        $e->x( $e->x + sin(deg2rad($e->d)) * $e->v_m );
        $e->y( $e->y - cos(deg2rad($e->d)) * $e->v_m );
        
        $e->x( ($e->x + $app->stash->{field}->w) % $app->stash->{field}->w );
        $e->y( ($e->y + $app->stash->{field}->h) % $app->stash->{field}->h );
        
        my $z = $e->size == 3
              ? 5
              : ($e->size == 2
              ? 3
              : 1.5);
              
        
        $e->shape([
            $z *  sin(deg2rad( 40 + $e->r)) * 5 + $e->x + $app->stash->{field}->x,
            $z * -cos(deg2rad( 40 + $e->r)) * 5 + $e->y + $app->stash->{field}->y,
            $z *  sin(deg2rad( 80 + $e->r)) * 2 + $e->x + $app->stash->{field}->x,
            $z * -cos(deg2rad( 80 + $e->r)) * 2 + $e->y + $app->stash->{field}->y,
            $z *  sin(deg2rad( 80 + $e->r)) * 6 + $e->x + $app->stash->{field}->x,
            $z * -cos(deg2rad( 80 + $e->r)) * 6 + $e->y + $app->stash->{field}->y,
            $z *  sin(deg2rad(125 + $e->r)) * 6 + $e->x + $app->stash->{field}->x,
            $z * -cos(deg2rad(125 + $e->r)) * 6 + $e->y + $app->stash->{field}->y,
            $z *  sin(deg2rad(225 + $e->r)) * 6 + $e->x + $app->stash->{field}->x,
            $z * -cos(deg2rad(225 + $e->r)) * 6 + $e->y + $app->stash->{field}->y,
            $z *  sin(deg2rad(290 + $e->r)) * 6 + $e->x + $app->stash->{field}->x,
            $z * -cos(deg2rad(290 + $e->r)) * 6 + $e->y + $app->stash->{field}->y,
            $z *  sin(deg2rad(340 + $e->r)) * 6 + $e->x + $app->stash->{field}->x,
            $z * -cos(deg2rad(340 + $e->r)) * 6 + $e->y + $app->stash->{field}->y,
        ]);
        
        my $p = Math::Geometry::Planar->new;
        $p->polygons([[
            [$e->shape->[ 0], $e->shape->[ 1]],
            [$e->shape->[ 2], $e->shape->[ 3]],
            [$e->shape->[ 4], $e->shape->[ 5]],
            [$e->shape->[ 6], $e->shape->[ 7]],
            [$e->shape->[ 8], $e->shape->[ 9]],
            [$e->shape->[10], $e->shape->[11]],
            [$e->shape->[12], $e->shape->[13]]
        ]]);
        
        $e->gpc($p->convert2gpc($p));
        
        foreach my $b (@{$app->stash->{bullets}}) {
            next unless defined $e;
            next unless defined $b;
            
            if($e->gpc && Gpc2Polygons(GpcClip('INTERSECTION', $b->gpc, $e->gpc))) {
                if($e->size > 1) {
                    push(@{$app->stash->{enemies}}, Asteroids::Enemies::Asteroid->new( $e->x, $e->y, $e->v_m, $e->size - 1 ));
                    push(@{$app->stash->{enemies}}, Asteroids::Enemies::Asteroid->new( $e->x, $e->y, $e->v_m, $e->size - 1 ));
                }
                $e = undef;
                $b = undef;
            }
        }
        
        if($e && $e->gpc && Gpc2Polygons(GpcClip('INTERSECTION', $app->stash->{player}->gpc, $e->gpc))) {
            $app->stash->{player}->x($app->stash->{field}->w / 2);
            $app->stash->{player}->y($app->stash->{field}->h / 2);
            sleep(1);
        }
    }
}

sub show {
    my ( $delta, $app ) = @_;

    foreach my $b (@{$app->stash->{enemies}}) {
        next unless defined $b;
        
        if($b->gpc) {
            if(my @i = Gpc2Polygons(GpcClip('INTERSECTION', $app->stash->{field_gpc}, $b->gpc))) {
                my $polygon_refs = $i[0]->polygons;
                my $polygon_ref  = ${$polygon_refs}[0];
                my @points       = @{$polygon_ref};
                @{$b->shape}     = ();
                
                foreach(@points) {
                    push(@{$b->shape}, @{$_});
                }
            }
        }
        
        $app->draw_polygon( $b->shape, 0xFFFFFFAA, 1 );
    }
}

1;
