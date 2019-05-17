#!/usr/bin/perl -w

use Modern::Perl '2016';
use lib 'lib/';
use BlockStacking::Engine;
use Test::Most;
use JAG::Util::Timer;
use Readonly;

# Not currently supporting different size blocks
Readonly my $SM_BLOCK => 3;
Readonly my $LG_BLOCK => 4.5;

my $SLOW_OK = 1;
my $MAX_SECS = 8;

subtest 'run wall counts' => sub {

    my @tests = (
        {name => 'Build 7.5 x 0',  width => 7.5, height => 0,  expected => 0},
        {name => 'Build 7.5 x 1',  width => 7.5, height => 1,  expected => 2},
        {name => 'Build 7.5 x 2',  width => 7.5, height => 2,  expected => 2},
        {name => 'Build  12 x 3',  width => 12,  height => 3,  expected => 4},
        {name => 'Build  27 x 5',  width => 27,  height => 5,  expected => 7958},
        {name => 'Build  48 x 2',  width => 48,  height => 2,  expected => 37120},
        {name => 'Build  48 x 4',  width => 48,  height => 4,  expected => 10178548},
        {name => 'Build  48 x 6',  width => 48,  height => 6,  expected => 3919649942},
        {name => 'Build  48 x 8',  width => 48,  height => 8,  expected => 1722438038790},
        {name => 'Build  48 x 10', width => 48,  height => 10, expected => 806844323190414},
        {name => 'Build  48 x 12', width => 48,  height => 12, expected => 392312088153557198}, # 392,312,088,153,557,198
    );

    for my $test (@tests) {
        if (!$SLOW_OK and $test->{width} > 27) {
            say "Skipping long tests (width: $test->{width}) while SLOW_OK is false\n";
            next;
        }

        my $timer = JAG::Util::Timer->new(badge => 'BlockStacking');
        my $engine = BlockStacking::Engine->new( blocks => [$SM_BLOCK, $LG_BLOCK] );

        my $badge = 'Full build';

        $timer->start($badge);
        $engine->build_layers($test->{width});
        my $actual = $engine->count_walls($test->{height});

        print $timer->end_string($badge, "Testing: $test->{name} ==> $actual\n");
    }
};

done_testing();


