package App::gh::Command::Page;

use 5.10.0;

use warnings;
use strict;

use Path::Tiny;
use Moose::Util::TypeConstraints 'enum';

use MooseX::App::Command;

extends 'App::gh';

with 'App::gh::Role::Git';

=encoding utf8

=head1 NAME

App::gh::Command::Page - create a GitHub page

=head1 DESCRIPTION

Creates, if not already present, an empty
C<gh-pages> branch, seeds it with a 
F<index.html> file and push it to the C<origin>. 

If the subcommand C<open> is given, the main GitHub page
will be opened via the default browser using L<Browser::Open>. 
Another project can also be given as an argument. E.g.

    gh page open yanick/MoobX

See L<http://pages.github.com/> for more details
about GitHub pages.

=cut

option origin => (
    is => 'ro',
    documentation => 'remote repository',
);

parameter subcommand => (
    is => 'ro',
    isa => enum(['open']),
    documentation => 'open main GitHub page in browser',
);

# TODO document how to change that in the config
has index_template => (
    is => 'ro',
    lazy => 1,
    default => <<'END',
<html>
    <head></head>
    <body></body>
</html>
END
);

sub run {
    my $self = shift;

    if( $self->subcommand eq 'open' ) {
        my ( $repo ) = eval { @{ $self->extra_argv } };

        unless ( $repo ) {
            my( $remote ) = $self->git->config( 'branch.gh-pages.remote', { get => 1 } )
                or die "no remote found for branch 'gh-pages'\n";

            ($repo) = grep { /^$remote/ } $self->git->remote({ v => 1 });

            $repo =~ s/ \S+$//;
            $repo =~ s/\.git$//;
            my @parts = split '/', $repo;
            shift @parts while @parts > 2;
            $repo = join '/', splice @parts, -2;
        }

        my( $user, $repo ) = split '/', $repo;

        my $url = sprintf "http://%s.github.com/%s", $user, $repo;

        require Browser::Open;

        Browser::Open::open_browser( $url );

        return;
    }

    die <<'END' if $self->git->status->is_dirty;
checkout has some modified or untracked files. Please commit or 
stash them before you can create the 'gh-pages' branch.
END

    # already there? Okay, then
    if ( grep { /gh-pages/ } $self->git->branch ) {
        $self->git->checkout( 'gh-pages' );
        return;
    }

    $self->git->checkout( '--orphan', 'gh-pages' );
    $self->git_print_all;

    my $index = path('index.html');

    $self->git->rm( '.', { cached => 1, r => 1 });
    $self->git_print_all;

    unless( $index->exists ) {
        say "creating index.html";
        $index->spew( $self->index_template );
    }

    $self->git->add( 'index.html' );
    $self->git_print_all;

    $self->git->commit( '--message' => 'initial gh-pages commit' );
    $self->git_print_all;

    $self->git->stash( '--all' );
    $self->git_print_all;

    if( my $origin = $self->origin ) {
        $self->git->push( $origin, '--set-upsteam' );
        $self->git_print_all;
    }
    

}

1;

__END__
