
package BlockStacking::Layer;

use Modern::Perl '2016';

# De-Moosed it for speed...

sub new {
    my($class, %args) = @_;

    my $self = {
        blocks => [],
        width  => 0,
        can_be_stacked  => {},
        levels => {},
        width_values => [],
        width_hash => {},
        key => '',
    };

    bless $self, ref($class) || $class;

    $self->BUILD($args{blocks});

    return $self;
}

sub BUILD {
    my ($self, $new_blocks) = @_;
    $self->add_many( $new_blocks );
}

sub add {
    my ($self, $block) = @_;

    push $self->{blocks}->@*, $block;
    $self->{width} += $block;
    push $self->{width_values}->@*, $self->{width};
    $self->{width_hash}->{ $self->{width} } = 1;
}

sub add_many {
    my ($self, $blocks) = @_;

    for my $block (@$blocks) {
        $self->add($block);
    }
}

sub check_can_stack {
    my ($self, $layer) = @_;

    my $width = $self->{width};

    my $next_start = 0;
    for my $w ( @{ $self->{width_values} } ) {
        last if $w == $width;
        for my $v ($layer->{width_values}->@*) {
            if($w == $v) {
                # if matching, they cannot stack
                return 0;
            }
        }
    }

    return 1;
}

sub to_key {
    my $self = shift;

    unless($self->{key}) {
        $self->{key} = join(',', $self->{blocks}->@*);
    }

    return $self->{key};
}

1;
