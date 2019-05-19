#!/usr/bin/perl -w

use lib 'lib/';
use Modern::Perl '2016';
use Test::Most;
use BlockStacking::Engine;
use BlockStacking::Layer;


subtest 'build layers' => sub {
    my $target_width = 27;

    my $engine = BlockStacking::Engine->new( blocks => [3, 4.5] );
    my $layer_count = $engine->build_layers($target_width);
    my $layer = $engine->layers->[0];

    is($layer_count, 65, "Correct layer count for width: $target_width");
    is($layer->{width}, 27, "Layer correct width set (bug fix)");

};

done_testing();
