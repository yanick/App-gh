package App::gh;

use warnings;
use strict;

use MooseX::App qw/ ConfigHome Color /;

with 'App::gh::API';

app_namespace 'App::gh::Command';

option github_user => (
    documentation => 'your github username',
    isa => 'Str',
    is => 'ro',
    lazy => 1,
    default => sub {
        die qq{'github_user' required but not found in config file\n};
    },
);

__PACKAGE__->meta->make_immutable;

__END__
