#!/usr/bin/perl -w

use lib 'lib/';
use Modern::Perl '2016';
use Test::Most;
use BlockStacking::Layer;


subtest 'check stacking layers' => sub {
    my @tests = (
        { width => 12, blocks_a => [3,3,3,3],   blocks_b => [4.5,4.5,3], stacks => 0 },
        { width => 12, blocks_a => [3,4.5,4.5], blocks_b => [4.5,4.5,3], stacks => 1 },
    );

    for my $test (@tests) {
        my $layer_a = BlockStacking::Layer->new( blocks => $test->{blocks_a} );
        my $layer_b = BlockStacking::Layer->new( blocks => $test->{blocks_b} );
        my $can_stack = $layer_a->check_can_stack($layer_b);

        is($layer_a->{width}, $test->{width}, "Width ($test->{width}) is correct for A.");
        is($layer_b->{width}, $test->{width}, "Width ($test->{width}) is correct for B.");
        is($can_stack, $test->{stacks}, "Correct stackable value");
    }

};

done_testing();
