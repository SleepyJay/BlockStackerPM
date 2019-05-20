
package BlockStacking::LayerSearchTree;

use strict;
use warnings;


sub new {
	my($class, %args) = @_;

    my $self = {
		error  => undef,
		tree   => {},
    };

	bless $self, ref($class) || $class;

	return $self;
}

sub add {
	my ($self, $keys, $value) = @_;

	my $node = $self->{tree};
	my $key_last = @$keys - 1;
	for my $i (0 .. $key_last) {
		my $key = $keys->[$i];

		if ($i == $key_last) {
			$node->{$key} = $value;
		}
		else {
			$node->{$key} = {} unless $node->{$key};
			$node = $node->{$key};
		}
	}
}

sub find_stackable {
	my ($self, $layer) = @_;

	my @found;
	my @queue = ($self->{tree});

	my $last = 0;
	my $width = $layer->{width};
	my $hash = $layer->{width_hash};
    while (my $node = shift @queue) {
        for my $key (keys %$node) {
            if($key == $width) {
                push @found, $node->{$key};
                last;
            }
            else {
                next if exists $hash->{$key};
                push @queue, $node->{$key};
            }
        }
        last if $last;
    }

	return \@found;
}


1;


__END__

=head1 NAME

BlockStacking::LayerSearchTree

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 NOTES

=cut

