#!/usr/bin/perl -w

use lib 'lib/';
use Modern::Perl '2016';
use Test::Most;
use Data::Dumper;
use BlockStacking::LayerSearchTree;


subtest 'search tree add' => sub {
    my $stree = BlockStacking::LayerSearchTree->new();
    ok(defined $stree, 'Made a SearchTree');

    my $keys = [3,4,5,6];
    $stree->add($keys, $keys);
    my $expected = {3=>{4=>{5=>{6=>$keys}}}};
    my $ok = cmp_deeply($stree->{tree}, $expected, 'Correctly keyed');

    my $more = [3,4,5,7];
    $stree->add($more, $keys);
    $expected = {3=>{4=>{5=>{6=>$keys, 7=>$keys}}}};
    $ok &&= cmp_deeply($stree->{tree}, $expected, 'Correctly keyed');

    my $more2 = [3,4,5,7];
    $stree->add($more, $more2);
    $expected = {3=>{4=>{5=>{6=>$keys, 7=>$more2}}}};
    $ok &&= cmp_deeply($stree->{tree}, $expected, 'Correctly keyed');

    print Dumper($stree->{tree}) unless $ok;

};


subtest 'search tree find other' => sub {
    my $stree = BlockStacking::LayerSearchTree->new();
    ok(defined $stree, 'Made a SearchTree');

    my @tests = (
        { data => [3,6,9,12] },
        { data => [4.5,9,12], exp_data => {3 => 1, 7.5 => 1, 12 => 1} },
        { data => [3,7.5,12], exp_data => {4.5 => 1, 9 => 1, 12 => 1} },
    );

    my $width = 12;

    # Prepare layers and SearchTree...
    for my $test (@tests) {
        my %hash;
        for my $item (@{$test->{data}}) {
            $hash{$item} = 1;
        }

        $test->{layer} = {
            width => $width,
            width_hash => \%hash,
        };

        if ($test->{exp_data}) {
            $test->{expected} = [{
                width => $width,
                width_hash => $test->{exp_data},
            }];
        } else {
            $test->{expected} = [];
        }

        $stree->add($test->{data}, $test->{layer});
    }

    # Now test stackable
    for my $test (@tests) {
        my $layer = $test->{layer};

        my $found = $stree->find_stackable($layer);

        my $ok = cmp_deeply($found, $test->{expected}, 'expected found');
        print Dumper( {
            data => $test->{data}, found => $found, expected => $test->{expected} } ) unless $ok;
    }
};

done_testing();

