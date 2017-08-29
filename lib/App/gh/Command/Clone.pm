package App::gh::Command::Clone;
# ABSTRACT: clone repository

# TODO   gh clone yanick/MoobX
# TODO   gh clone MoobX
  
use 5.10.0;

use strict;
use warnings;

use Git::Wrapper;

use MooseX::App::Command;

extends 'App::gh';

with 'App::gh::Git';

parameter project => (
    is            => 'ro',
    documentation => 'project to clone',
    required      => 1,
);
# TODO coerce url from name (and error if no good)

has project_url => (
    is   => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;

        my $project = $self->project;

        unless( -1 < index $project, '/' ) {
            $project = join '/', $self->github_username, $project;
        };

        'ssh://git@github.com/' . $project;
    },
);



# TODO take in the extra args and pass them to clone
# TODO add the option to clone via https/ssh
# TODO: -k, --forks     also fetch forks.

sub run {
    my( $self ) = @_;

    $self->git->clone( 
        $self->project_url,
        @{ $self->extra_argv || [] }
    );

    $self->git->print_all;
}

1;

__END__


=head1 DESCRIPTION

Clones a GitHub repository. The target repo can
either be of the form 'C<user/project>' or 'C<project>',
in which case it will be assumed to be yours.

Options types after a double-dash (C<-->) will b
e passed to the underlying C<git clone> command 
directly.  E.g.,

    gh clone MoobX -- --origin mine


=cut

__END__

sub run {
    my $self = shift;
    my $user = shift;
    my $repo;
    if( $user =~ /\// ) {
        ($user, $repo) = split /\//, $user;
    } else {
        $repo = shift;
    }

    unless( $user && $repo ) {
        die "Usage: gh clone [user] [repo]\n";
    }

    my $uri = generate_repo_uri($user, $repo, $self);

    my @command = build_git_clone_command($uri,$self);

    print 'Cloning ', $uri,  "...\n";
    my $cmd = join ' ', @command;
    qx($cmd);

    # fetch forks
    if( $self->{with_fork} ) {
        my $dirname = basename($uri,'.git');

        # get networks
        my $repos = App::gh->github->repos->set_default_user_repo($user,$repo);
        my @forks = $repos->forks;
        if( @forks ) {
            print "Found " , scalar(@forks) , " forks to fetch...\n";
            chdir $dirname;
            for my $fork ( @forks ) {
                my ($full_name,$clone_url,$login) =
                        ($fork->{full_name},$fork->{clone_url},$fork->{owner}->{login});
                print "===> Adding remote $login => $clone_url\n";
                qx(git remote add $login $clone_url);
                print "===> Fetching fork $full_name...\n";
                run_git_fetch $login;
                qx(git fetch $login);
            }
        }
    }
}

1;
