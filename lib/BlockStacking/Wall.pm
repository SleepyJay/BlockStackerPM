package BlockStacking::Wall;

use Modern::Perl '2016';
use Moose;

has layers => ( is => 'rw', isa => 'ArrayRef', default => sub { [] } );

sub height {
    my ($self) = shift;

    return scalar $self->layers->@*;
}

sub add {
    my ($self, $layer) = @_;
    push $self->layers->@*, $layer;
}

sub add_many {
    my ($self, $layers) = @_;

    for my $layer (@$layers) {
        $self->add($layer);
    }
}

sub top {
    my ($self) = @_;

    return $self->layers->[-1];
}

1;
