package App::gh::Command::Fork;
# ABSTRACT: fork a repository

# TODO add --add-remote that defaults to true/false depending 
# if we're forking something related to the current repo
# (see alter_repo attribute)

# TODO gh fork --clone somebody/project

# TODO allow different protocols
#   gh fork --protocol=ssh ...

# TODO fork to a different org
#   gh fork --org blah

=head1 USAGE

    gh fork
    gh fork yanick
    gh fork yanick/App-gh    

=head1 DESCRIPTION

Without a repo name, will fork the remote tracked
by the current branch and add the forked repo as a
new remote.

A parameter without a slash will be taken as the remote
to fork. 

A parameter with a slash (i.e., "owner/repo") is
considered to be the repo to fork. In this case no remote
will be added to the current local repo.

=cut

use 5.10.0;

use strict;
use warnings;

use MooseX::App::Command;

extends 'App::gh';

with 'App::gh::Git';

with 'App::gh::Role::Format' => {
    formats => [qw/ default json /],
};

# TODO
# option clone => (
#     is  => 'ro',
#     isa => 'Bool',
#     documentation => 'also clone the fork locally',
# );

has alter_repo => (
    is      => 'rw',
    default => 0,
);

parameter repository => (
    is => 'ro',
    documentation => 'repo to fork',
);

sub expanded_repository {
    my ( $self ) = @_;

    my $name = $self->repository;

    unless( $name ) {
        my ( $tracking ) = $self->git->RUN( 'status', '-sb' );
        $self->alter_repo(1);

        return unless $tracking =~ m!##.*?\.\.\.([^/]+)!;
        $name = $1;
    }

    if( -1 == index $name, '/' ) {
        my( $remote )= $self->git->config( '--get', "remote.$name.url" );
        return unless $remote =~ m#([^:/]+/[^/.]+)(?:\.git)?$#;
        $name = $1;
        $self->alter_repo(1);
    }

    return $name;
}

sub print_default {
    my ( $self, $fork ) = @_;
    
    $self->render_string(
        "{{#color 'blue'}}repo forked:{{/color}} {{ html_url }}",
        $fork
    );
}

sub run {
    my $self = shift;

    my $repo = $self->expanded_repository;

    say "forking ", $repo, "...";
    
    my $fork = $self->api->repos->create_fork( split '/', $repo );t

    $self->print_formatted($fork);

    if( $self->git and $self->alter_repo ) {
        say sprintf "adding fork as remote '%s'...", $self->github_username;
        $self->git->remote( 'add', $self->github_username, $fork->{ssh_url} );
    }
}


1;
