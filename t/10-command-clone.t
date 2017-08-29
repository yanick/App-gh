use strict;
use warnings;

use Test::More tests => 1;

use Capture::Tiny qw/ capture_stdout /;
use List::AllUtils qw/ pairs /;

use App::gh::Command::Clone;

use lib 't/lib';
use Utils;

use Test::MockObject;

my $fake_git = Test::MockObject->new;

$fake_git->mock( clone => sub {
    shift;
    push @App::gh::TEST_GIT_EXEC, [ clone => @_ ];
})->set_true('print_all');

subtest 'full name' => sub {
    App::gh::Command::Clone->new( 
        git     => $fake_git,
        project => 'yanick/MoobX'
    )->run;

    is_deeply \@App::gh::TEST_GIT_EXEC, [ 
        [ 'clone', 'ssh://git@github.com/yanick/MoobX' ]
    ] or diag explain \@App::gh::TEST_GIT_EXEC;
    
};

subtest 'just project' => sub {
    local @App::gh::TEST_GIT_EXEC;

    App::gh::Command::Clone->new( 
        git     => $fake_git,
        project => 'MoobX',
        github_username => 'yanick'
    )->run;

    is_deeply \@App::gh::TEST_GIT_EXEC, [ 
        [ 'clone', 'ssh://git@github.com/yanick/MoobX' ]
    ] or diag explain \@App::gh::TEST_GIT_EXEC;
    
};
