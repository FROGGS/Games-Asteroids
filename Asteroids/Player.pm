package Asteroids::Player;
use strict;
use warnings;
use Carp;
use Math::Trig;
use Math::Geometry::Planar;

use Class::XSAccessor {
    accessors => [ qw(x y r r_l r_r v_r v_m d_x d_y d_u d_l d_d d_r shape gpc) ],
};

use SDL::Events;
use SDLx::App;
use Asteroids::Bullets::Bullet;

sub new {
    my ($class, $app) = @_;

    my $self = bless {}, ref($class) || $class;

    $self->x($app->stash->{field}->w / 2);
    $self->y($app->stash->{field}->h / 2);
    $self->r(0);
    $self->v_r(3); # player's speed
    $self->v_m(0);
    $self->d_x(0); # direction x
    $self->d_y(0); # direction y
    $self->d_u(0); # up pressed
    $self->d_l(0); # left pressed
    $self->d_d(0); # down pressed
    $self->d_r(0); # right pressed
    
    $self->r_l(0); # right pressed
    $self->r_r(0); # right pressed
    
    $self->shape([
         0.0, -6.0,
         4.0,  4.5,
         0.0,  3.0,
        -4.0,  4.5
    ]);
    
    $app->add_event_handler( \&event );
    $app->add_move_handler( \&move );
    $app->add_show_handler( \&show );
    
    $app->stash->{player} = $self;

    return $self;
}

sub event {
    my ( $e, $app ) = @_;
    if ( $e->type == SDL_KEYUP ) {
        if($app->stash->{player}->d_u && ($e->key_sym == SDLK_w || $e->key_sym == SDLK_UP)) {
            # when 'up'-key is released, we switch back to 'down'-direction if that key is still pressed
            $app->stash->{player}->v_m( 0 );
        }
        elsif($app->stash->{player}->r_l && ($e->key_sym == SDLK_a || $e->key_sym == SDLK_LEFT)) {
            $app->stash->{player}->r_l( 0 );
        }
        elsif($app->stash->{player}->d_d && ($e->key_sym == SDLK_s || $e->key_sym == SDLK_DOWN)) {
            $app->stash->{player}->d_d( 0 );
            $app->stash->{player}->d_y( -1 * $app->stash->{player}->d_u );
        }
        elsif($app->stash->{player}->r_r && ($e->key_sym == SDLK_d || $e->key_sym == SDLK_RIGHT)) {
            $app->stash->{player}->r_r( 0 );
        }
    }
    elsif ( $e->type == SDL_KEYDOWN ) {
        if($e->key_sym == SDLK_w || $e->key_sym == SDLK_UP) {
            $app->stash->{player}->d_u( 1 );
            $app->stash->{player}->d_y( -1 );
            $app->stash->{player}->v_m( 3 );
        }
        elsif($e->key_sym == SDLK_a || $e->key_sym == SDLK_LEFT) {
            $app->stash->{player}->r_l( 1 );
        }
        elsif($e->key_sym == SDLK_s || $e->key_sym == SDLK_DOWN) {
            $app->stash->{player}->d_d( 1 );
            $app->stash->{player}->d_y( 1 );
        }
        elsif($e->key_sym == SDLK_d || $e->key_sym == SDLK_RIGHT) {
            $app->stash->{player}->r_r( 1 );
        }
        elsif($e->key_sym == SDLK_SPACE) {
            push(@{$app->stash->{bullets}},
                Asteroids::Bullets::Bullet->new( $app->stash->{player}->x + $app->stash->{field}->x,
                                                 $app->stash->{player}->y + $app->stash->{field}->y,
                                                 $app->stash->{player}->r));
        }
    }
}

sub move {
    my ( $delta, $app, $t ) = @_;
    
    if($app->stash->{player}->r_l) {
        $app->stash->{player}->r( $app->stash->{player}->r - $app->stash->{player}->r_l * $app->stash->{player}->v_r);
    }
    else {
        $app->stash->{player}->r( $app->stash->{player}->r - $app->stash->{player}->r_r * -$app->stash->{player}->v_r);
    }
    
    my $r = $app->stash->{player}->r;
    
    $app->stash->{player}->x( $app->stash->{player}->x + sin(deg2rad($r)) * $app->stash->{player}->v_m );
    $app->stash->{player}->y( $app->stash->{player}->y - cos(deg2rad($r)) * $app->stash->{player}->v_m );
    
    $app->stash->{player}->x( $app->stash->{player}->x % $app->stash->{field}->w );
    $app->stash->{player}->y( $app->stash->{player}->y % $app->stash->{field}->h );
    
    my $sr = sin(deg2rad($r));
    my $cr = cos(deg2rad($r));

    $app->stash->{player}->shape([
        3 *  $sr * 6 + $app->stash->{player}->x + $app->stash->{field}->x,
        3 * -$cr * 6 + $app->stash->{player}->y + $app->stash->{field}->y,
        3 *  sin(deg2rad(40 - $r)) * 6 + $app->stash->{player}->x + $app->stash->{field}->x,
        3 *  cos(deg2rad(40 - $r)) * 6 + $app->stash->{player}->y + $app->stash->{field}->y,
        3 * -$sr * 2 + $app->stash->{player}->x + $app->stash->{field}->x,
        3 *  $cr * 2 + $app->stash->{player}->y + $app->stash->{field}->y,
        3 * -sin(deg2rad(40 + $r)) * 6 + $app->stash->{player}->x + $app->stash->{field}->x,
        3 *  cos(deg2rad(40 + $r)) * 6 + $app->stash->{player}->y + $app->stash->{field}->y
    ]);
    
    my $p = Math::Geometry::Planar->new;
    $p->polygons([[
        [$app->stash->{player}->shape->[0], $app->stash->{player}->shape->[1]],
        [$app->stash->{player}->shape->[2], $app->stash->{player}->shape->[3]],
        [$app->stash->{player}->shape->[4], $app->stash->{player}->shape->[5]],
        [$app->stash->{player}->shape->[6], $app->stash->{player}->shape->[7]]
    ]]);
    
    $app->stash->{player}->gpc($p->convert2gpc($p));
}

sub show {
    my ( $delta, $app ) = @_;

    if($app->stash->{player}->gpc) {
        if(my @i = Gpc2Polygons(GpcClip('INTERSECTION', $app->stash->{field_gpc}, $app->stash->{player}->gpc))) {
            my $polygon_refs                = $i[0]->polygons;
            my $polygon_ref                 = ${$polygon_refs}[0];
            my @points                      = @{$polygon_ref};
            @{$app->stash->{player}->shape} = ();
            
            foreach(@points) {
                push(@{$app->stash->{player}->shape}, @{$_});
            }
        }
    }
    
    $app->draw_polygon( $app->stash->{player}->shape, 0xFFFFFFFF, 1 );
    $app->draw_polygon( $app->stash->{player}->shape, 0xFFFFFFFF, 1 );
}

1;
