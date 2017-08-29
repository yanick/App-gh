package App::gh::Command::Delete;
#ABSTRACT: delete a repository

use 5.10.0;

use warnings;
use strict;

use MooseX::App::Command;

extends 'App::gh';
with 'App::gh::Git';

use IO::Prompt::Simple;

# TODO pick it up from the local repo
# TODO --rm to remove the local instance as well

=head1 USAGE

    gh delete App-gh
    gh delete yanick/App-gh

=head1 DESCRIPTION

If the repo name is partial, assumes you are the owner.

Note: if you are using a token, make sure that it has 
the 'delete repository' permission enabled.

=cut

parameter repository => (
    is => 'ro',
    documentation => 'repo to delete',
);

sub run {
    my $self = shift;

    my $repo = $self->repository;

    $repo = $self->github_username . '/' . $repo
        if -1 == index $repo, '/';

    say "Are you SURE you want to delete the repo '$repo'?";
    
    my $answer = prompt 'If you are, type in the name of the doomed repo';

    return say "not matching, aborting" unless $answer eq $repo;

    my $result = $self->api->repos->delete( split '/', $repo );

    if( $result ) {
        say "repo deleted";
    }
    else {
        die "deletion failed\n";
    }
}





1;
