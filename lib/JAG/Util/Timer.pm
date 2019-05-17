
package JAG::Util::Timer;

use strict;
use warnings;
use Time::HiRes;


sub new {
	my($class, %args) = @_;

    my $self = {
        badge  => $args{badge} || 'PERF',
		timers => {},
		error  => undef,
    };

	bless $self, ref($class) || $class;

	return $self;
}

# Sets self error and returns undef if name already in use.
# Otherwise returns timer hash.
# Description optional.
sub start {
	my($self, $name, $description) = @_;

	my $timer = $self->{timers}->{$name};

	if ($timer) {
		$self->error('Cannot set an already running timer; clear first.');
		return;
	}

	$timer = { description => $description || '' };
	$self->{timers}->{$name} = $timer;
	$timer->{start} = [Time::HiRes::gettimeofday()];

	return $timer;
}

sub clear {
	my($self, $name) = @_;
	$self->{timers}->{$name} = 0;
}

sub get {
	my($self, $name) = @_;
	return $self->{timers}->{$name};
}

sub end {
	my($self, $name) = @_;

	my $timer = $self->{timers}->{$name};

	unless($timer) {
		$self->error("Timer '$name' not set!") unless $timer;
		return;
	}

	$timer->{elapsed} = Time::HiRes::tv_interval( $timer->{start} );

	return $timer;
}

# This is just a suggestion; grab timer data yourself if you want...
sub as_string {
	my($self, $name, $message) = @_;
	$message = $message || '';

	return $self->error() if $self->error();

	my $timer = $self->{timers}->{$name};

	return "Timer '$name' not set!" unless $timer;

	return "$self->{badge} | $name | $timer->{elapsed} | $message";
}

# Combine end() with as_string()
sub end_string {
	my($self, $name, $message) = @_;
	$message = $message || "done" ;

	$self->end($name);

	return $self->as_string($name, $message);
}

sub error {
	my($self, $message) = @_;

	if(!$self->{error} && defined $message) {
		$self->{error} = $message;
	}

	return $self->{error};
}

sub clear_error {
	shift->{error} = undef;
}

1;


__END__

=head1 NAME

JAG::Util::Timer - minimal (no Moose; just Timer::HiRes) Timer for timing stuff.

=head1 SYNOPSIS

Add this around stuff you want to time:

	$timer = JAG::Util::Timer->new('PERF');

	$timer->start('cool code');

	# ... cool code goes here ...

	print $timer->end_string('cool code')

=head1 DESCRIPTION

Intended to do time running sections of code and give a consistent output.

Multiple timers can be started at the same time, often nested.

=head1 NOTES

Yes, other timers exist, but this is my favorite, since I know the author. :)

=cut

