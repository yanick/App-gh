package App::gh::Git;
# git interface for gh

use 5.10.0;

use strict;
use warnings;

use Moose::Role;

use Git::Wrapper;

has git => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        Git::Wrapper->new('.'); 
    },
);

sub git_print_all {
    my $self = shift;

    say for @{ $self->git->OUT };

    warn $_, "\n" for @{ $self->git->ERR };

};


1;

__END__ 
