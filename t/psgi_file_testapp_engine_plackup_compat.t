use strict;
use warnings;
use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More;
use Plack::Test;
use TestApp;
use HTTP::Request::Common;

my $warning;
local $SIG{__WARN__} = sub { $warning = $_[0] };

TestApp->setup_engine('PSGI');
my $app = sub { TestApp->run(@_) };

like $warning, qr/You are running Catalyst\:\:Engine\:\:PSGI/,
  'got deprecation alert warning';

test_psgi $app, sub {
    my $cb = shift;
    eval {
        my $TIMEOUT_IN_SECONDS = 5;
        local $SIG{ALRM} = sub { die "alarm\n" };
        alarm($TIMEOUT_IN_SECONDS);

        my $res = $cb->(GET "/");
        is $res->content, "root index", 'got expected content';
        like $warning, qr/env as a writer/, 'got deprecation alert warning';

        alarm(0);
        1
    } || fail "$@ problem";
};

done_testing;
