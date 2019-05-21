
package BlockStacking::Engine;

use Modern::Perl '2016';
use Moose;
use BlockStacking::Wall;
use BlockStacking::Layer;
use BlockStacking::LayerSearchTree;

has blocks        => ( is => 'rw', default => sub { [] } );
has layers        => ( is => 'rw', default => sub { [] } );
has walls         => ( is => 'rw', default => sub { [] } );
has current_width => ( is => 'rw', default => 0 );
has search_tree   => ( is => 'rw', default => sub { BlockStacking::LayerSearchTree->new() } );

sub build_layers {
    my($self, $width) = @_;

    # Don't rebuild layers if called again with same width
    return if $self->current_width == $width;

    my @queue;
    my @final;

    for my $block_size ($self->blocks->@*) {
        next if $block_size > $width;

        my $layer = BlockStacking::Layer->new();
        $layer->add($block_size);

        push @queue, $layer;
    }

    while (@queue) {
        # attempt to reduce memory pressure
        my @next_queue;

        for my $layer (@queue) {
            for my $block ($self->blocks->@*) {
                next if ($layer->{width} + $block) > $width;

                # lazy clone (loop over to make sure they are not refs):
                my $new_layer = BlockStacking::Layer->new();
                for my $blk ($layer->{blocks}->@*) {
                    $new_layer->add($blk);
                }
                $new_layer->add($block);

                if ($new_layer->{width} == $width) {
                    push @final, $new_layer;
                }
                else {
                    push @next_queue, $new_layer;
                }
            }
        }

        @queue = @next_queue;
    }

    $self->current_width($width);
    $self->layers(\@final);

    for my $layer (@final) {
        $self->search_tree->add($layer->{width_values}, $layer);
    }

    $self->precache_layers();
    return scalar $self->layers->@*;
}

sub precache_layers {
    my $self = shift;

    my $search_tree = $self->{search_tree};

    for my $layer ($self->layers->@*) {
        $layer->{can_be_stacked} = $search_tree->find_stackable($layer);
    }
}

sub build_walls {
    my($self, $height) = @_;

    my @queue;
    my @final;

    for my $layer ($self->layers->@*) {
        my $wall = BlockStacking::Wall->new( layers => [$layer] );
        push @queue, $wall;
    }

    if ($height == 1) {
        $self->walls(\@queue);
        return;
    }

    while (@queue) {
        my @next_queue; # attempt to reduce memory pressure
        for my $wall (@queue) {
            my $top = $wall->top();
            for my $layer ($top->{can_be_stacked}->@*) {
                my $new_wall = BlockStacking::Wall->new(layers => $wall->layers);
                $new_wall->add($layer);

                if ($new_wall->height == $height) {
                    push @final, $new_wall;
                }
                else {
                    push @next_queue, $new_wall;
                }
            }
        }

        @queue = @next_queue;
    }

    $self->walls(\@final);

    return $self->wall_count;
}

sub count_walls {
    my($self, $height) = @_;

    return 0 if $height <= 0;

    return scalar $self->layers->@* if $height == 1;

    my $total = 0;
    for my $h (-$height .. -2) {
        $h = -$h;
        for my $layer ($self->layers->@*) {
            if ($h == $height) {
                my $count = scalar($layer->{can_be_stacked}->@*);
                $layer->{levels}->{$h} = $count;
            }
            else {
                my $count = 0;
                for my $stackable ($layer->{can_be_stacked}->@*) {
                    #print Dumper($stackable->levels->{$h + 1}); use Data::Dumper;
                    $count += $stackable->{levels}->{$h + 1} || 0;
                }
                $layer->{levels}->{$h} = $count;
            }
        }
    }

    # I know this seems weird that I'm using 2, but it represents the
    # running sum of combinations of stacking TO that level, i.e. from 1->2.
    for my $layer ($self->layers->@*) {
        $total += $layer->{levels}->{2} || 0;
    }

    return $total;
}

sub wall_count{
    my($self) = @_;

    return scalar $self->walls->@* // 0;
}


1;
