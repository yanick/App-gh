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

sub git_tracking_remote {
    my $self = shift;

    my ( $tracking ) = $self->git->RUN( 'status', '-sb' );

    return unless $tracking =~ m!##.*?\.\.\.([^/]+)!;
    my $name = $1;

    my( $remote )= $self->git->config( '--get', "remote.$name.url" );
    return unless $remote =~ m#([^:/]+/[^/.]+)(?:\.git)?$#;
    $name = $1;

    return $name;
}


1;

__END__ 
