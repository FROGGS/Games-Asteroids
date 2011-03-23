#!perl

use strict;
use warnings;

use Imager;
use Imager::Screenshot;
use Math::Geometry::Planar;

use SDL 2.531_03;
use SDL::Events;
use SDL::Mouse;
use SDL::Video;
use SDL::VideoInfo;
use SDL::Surface;
use SDLx::App;
use SDLx::Surface;

use lib 'lib';
use Asteroids::Player;
use Asteroids::Bullets;
use Asteroids::Enemies;

# initializing video and retrieving current video resolution
SDL::init(SDL_INIT_VIDEO);
my $video_info           = SDL::Video::get_video_info();
my $screen_w             = $video_info->current_w;
my $screen_h             = $video_info->current_h;
$ENV{SDL_VIDEO_CENTERED} = 'center';
my $app                  = SDLx::App->new( width => $screen_w, height => $screen_h,
                                           depth => 32, title => "Asteroids", color => 0x000000FF,
                                           flags => SDL_HWSURFACE|SDL_DOUBLEBUF|SDL_NOFRAME, eoq => 1 );
draw_screenshot();

$app->draw_rect( [ ($screen_w - 1024) / 2 - 1, ($screen_h - 600) / 2 - 1, 1026, 602 ], 0xFFFFFFFF);
$app->stash->{field}     = SDL::Rect->new( ($screen_w - 1024) / 2, ($screen_h - 600) / 2, 1024, 600 );
my $a = Math::Geometry::Planar->new;
$a->polygons([[
    [$app->stash->{field}->x - 1,                       $app->stash->{field}->y - 1],
    [$app->stash->{field}->x + $app->stash->{field}->w, $app->stash->{field}->y - 1],
    [$app->stash->{field}->x + $app->stash->{field}->w, $app->stash->{field}->y + $app->stash->{field}->h],
    [$app->stash->{field}->x - 1,                       $app->stash->{field}->y + $app->stash->{field}->h]
]]);
$app->stash->{field_gpc} = $a->convert2gpc($a);

$app->add_show_handler( sub { $app->draw_rect( $app->stash->{field}, 0 ) } );
Asteroids::Player->new( $app );

$app->stash->{bullets}   = [];
$app->add_move_handler( \&Asteroids::Bullets::move );
$app->add_show_handler( \&Asteroids::Bullets::show );

$app->stash->{enemies}   = [];
$app->add_move_handler( \&Asteroids::Enemies::move );
$app->add_show_handler( \&Asteroids::Enemies::show );
push(@{$app->stash->{enemies}}, Asteroids::Enemies::Asteroid->new(rand($app->stash->{field}->w), rand($app->stash->{field}->h))) for(0..5);

$app->add_event_handler( sub { my $e = shift; $app->stop if $e->type == SDL_KEYDOWN && $e->key_sym == SDLK_ESCAPE; } );
$app->add_show_handler( sub { $app->update } );

$app->run();

sub draw_screenshot {
    my $img = Imager::Screenshot::screenshot();
    $img->filter(type=>"gaussian", stddev=>3);
    my $file;
    for my $format ( qw( png gif jpeg tiff ppm ) ) {
        if ($Imager::formats{$format}) {
            $file = "_temp.$format";
            $img->write( file => $file );
            last;
        }
    }
    
    if($file && -e $file) {
        my $background = SDLx::Surface->load( $file );
        $background->blit( $app ) if $background;
        $app->update;
        unlink( $file );
    }
}
