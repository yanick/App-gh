package App::gh::Command::Fork;
# ABSTRACT: fork a repository

# TODO gh fork  (do it for the current repo)
# TODO gh fork somebody/project
# TODO gh fork --clone somebody/project

# TODO allow different protocols
#   gh fork --protocol=ssh ...

# TODO fork to a different org
#   gh fork --org blah

=head1 USAGE

    gh fork yanick/MoobX    

=cut

use 5.10.0;

use strict;
use warnings;

use MooseX::App::Command;

extends 'App::gh';

option clone => (
    is  => 'ro',
    isa => 'Bool',
    documentation => 'clone your fork locally',
);

parameter repository => (
    is => 'ro',
    required => 1,
    documentation => 'repo to fork',
);

sub run {
    my $self = shift;
    
    # TODO what if repo doesn't exist?
    # TODO test - if repo already forked
    my $fork = $self->api->repos->create_fork( split '/', $self->repository );

    use DDP;
    p $fork;

    say "repo forked";
    # TODO provide url
    # TODO if forking the local repo, add the fork as a remote
}


1;
