#!/usr/bin/perl

# Counting walls is by far the more efficent usage, by orders of magnitude, but walls are not actually stored.
# Building walls actually produces walls, but is VERY slow.

# If `--print_walls` is True, you will get walls. A LOT of walls, like ~900,000 walls (for default)!
# They would look something like this
# (you can sorta see the overlaping principle, even just with numbers):
# W: [
# [3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3],
# [4.5, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4.5],
# [3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3],
# [4.5, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4.5]
# ]

# Use lib here for simplicity.
use lib 'lib/';
use Modern::Perl '2016';
use Getopt::Long;
use Readonly;
use BlockStacking::Engine;
use JAG::Util::Timer;


# Not currently supporting different size blocks
Readonly my $SM_BLOCK => 3;
Readonly my $LG_BLOCK => 4.5;

Readonly my $TIME_BLOCKS =>'build blocks';
Readonly my $TIME_LAYERS =>'build layers';
Readonly my $TIME_WALLS  =>'calc walls  ';

my ($arg_width, $arg_height) = @ARGV ? @ARGV : (27, 7);

die 'Must specify both width and height, or neither' unless (defined $arg_width && defined $arg_height);

my $opt_build_walls = 0;
my $opt_print_walls = 0;
my $opt_one_wall    = 0;

GetOptions (
    "build_walls" => \$opt_build_walls,
    "print_walls" => \$opt_print_walls,
    "one_wall"    => \$opt_one_wall,
) or die("Error in command line arguments\n");

print "Building walls $arg_width W x $arg_height H using block sizes [$SM_BLOCK, $LG_BLOCK]\n";

my $timer = JAG::Util::Timer->new(badge => 'BlockStacking');
my $engine = BlockStacking::Engine->new( blocks => [$SM_BLOCK, $LG_BLOCK] );

# FYI: in the original code, blocks were represented by actual (tiny) objects, but that's not needed in Perl.
# $timer->start($TIME_BLOCKS);
# my $block_count = $engine->build_blocks($SM_BLOCK, $LG_BLOCK);
# print $timer->end_string($TIME_BLOCKS, "Blocks built: $block_count\n");

$timer->start($TIME_LAYERS);
my $layer_count = $engine->build_layers($arg_width);
print $timer->end_string($TIME_LAYERS, "Layers built: $layer_count");

my $wall_count = 0;
$timer->start($TIME_WALLS);

if ($opt_build_walls || $opt_one_wall || $opt_print_walls) {
    $wall_count = $engine->build_walls($arg_height);
}
else {
    $wall_count = $engine->count_walls($arg_height);
}

print $timer->end_string($TIME_WALLS, "Walls of $arg_width x $arg_height built: $wall_count");

if ($opt_print_walls){
    for my $wall ($engine->walls->@*) {
        print "W: $wall\n";
    }
}
elsif ($opt_one_wall) {
    my $wall = $engine->walls->[0];

    print 'First wall created: [';

    for my $layer  ($wall->layers->@*) {
        print "\t$layer\n";
    }

    print ']';
}


