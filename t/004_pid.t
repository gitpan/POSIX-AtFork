#!perl
use strict;
use warnings;
use Test::More tests => 10;
use Test::SharedFork;
use POSIX::AtFork qw(:ALL);
use POSIX qw(getpid);

my $prepare = 0;
my $parent  = 0;
my $child   = 0;

my $parent_pid = $$;

pthread_atfork(
    sub { $prepare++ },
    sub { $parent++; is $$, $parent_pid },
    sub { $child++;  is $$, getpid() },
);

my $pid = Test::SharedFork->fork;
die "Failed to fork: $!" if not defined $pid;

if($pid != 0) {
    is $$, $parent_pid;

    is $prepare, 1, '&prepare in parent';
    is $parent,  1, '&parent in parent';
    is $child,   0, '&child in parent';
    waitpid $pid, 0;
    exit;
}
else {
    is $$, getpid();

    is $prepare, 1, '&prepare in child';
    is $parent,  0, '&parent in child';
    is $child,   1, '&child in child';
    exit;
}


