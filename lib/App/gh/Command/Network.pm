package App::gh::Command::Network;
# ABSTRACT: show the network of a repository

use 5.10.0;
use warnings;
use strict;

use MooseX::App::Command;
extends 'App::gh';
with 'App::gh::Git';

=head1 USAGE

    gh network
    gh network App-gh
    gh network yanick/App-gh

=head1 DESCRIPTION 

If no repository is given, uses the remote that
the current branch tracks.

A partial repository path is extended with your github
username.

=cut

parameter repository => (
    is => 'ro',
    documentation => 'target repo',
    default => sub {
        my $self = shift;
        
        $self->git_tracking_remote;
    },
    trigger => sub {
        my ( $self, $value ) = @_;
        return if $value =~ m!/!;

        $self->repository( $self->github_username . '/' . $value );
    },
);


sub run {
    my $self = shift;

    my %info = $self->api->repos->get( split '/', $self->repository );

    %info = %{ $info{source} } if $info{source};

    say sprintf "%s %dW %dF %s",
        $info{owner}{login}, $info{watchers}, $info{forks}, $info{updated_at};

    my @forks = $self->api->repos->forks(split '/', $info{full_name});

    # TODO sort forks by time
    # TODO have option to have time in human durations (3 years ago)

    for ( @forks ) {
        my %info = %$_;
        $info{updated_at} =~ s/T.*//; # don't really need that precision
        say sprintf "\t%s %dW %dF\t%s",
            $info{owner}{login}, $info{watchers}, $info{forks}, $info{updated_at};
    }


    return;

}

1;
