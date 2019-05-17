
package BlockStacking::Layer;

use Modern::Perl '2016';
use Moose;

has blocks => ( is => 'rw', isa => 'ArrayRef', default => sub { [] });
has width => ( is => 'rw', default => 0 );

has can_be_stacked => ( is => 'rw', isa => 'HashRef', default => sub { {} } );
has cannot_stack => ( is => 'rw', isa => 'HashRef', default => sub { {} } );
has levels => ( is => 'rw', isa => 'HashRef', default => sub { {} } );
has width_hash => ( is => 'rw', isa => 'HashRef', default => sub { {} } );

sub BUILD {
    my $self = shift;
    for my $block ($self->blocks->@*) {
        $self->width( $self->width() + $block );
    }
}

sub add {
    my ($self, $block) = @_;

    push $self->{blocks}->@*, $block;
    $self->width( $self->width() + $block );
    $self->width_hash->{$self->width}++;
}

sub add_many {
    my ($self, $blocks) = @_;

    for my $block (@$blocks) {
        $self->add($block);
    }
}

sub check_can_stack {
    my ($self, $layer) = @_;

    for my $w (keys $self->width_hash->%*) {
        # When at the full width, they will always (correctly) align.
        next if $self->width == $w;

        # This means they align, so cannot stack.
        return 0 if $layer->width_hash->{$w};
    }

    # All widths (except the full width) are not the same width, so they overlap everywhere.
    return 1;
}

sub to_key {
    my $self = shift;

    return join(',', $self->blocks->@*);
}

1;
