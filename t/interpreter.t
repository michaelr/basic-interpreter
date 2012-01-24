use strict;
use warnings;
use Test::More;
use Test::Exception;
use Test::Output;

use ok 'Basic::Interpreter';

my $interpreter = Basic::Interpreter->new();

stdout_is(
    sub {
        $interpreter->interpret(qq{ print "hello world";}),;
    },
    "hello world\n",
    'interpreted print "hello world" program ok'
);

stdout_is(
    sub {
        $interpreter->interpret(qq{ print "hello world";print "hello world"}),;
    },
    "hello world\nhello world\n",
    'interpreted two statements on one line ok'
);

stdout_is(
    sub {
        $interpreter->interpret(qq{ print "hello world"\nprint "hello world";}),;
    },
    "hello world\nhello world\n",
    'interpreted two statements seperated by EOL on one line ok'
);

stdout_is(
    sub {
        $interpreter->interpret(qq{
print "hello world"\n
print "hello world";}),;
    },
    "hello world\nhello world\n",
    'interpreted two statements seperated by EOL on one line ok with vertical whitespace at the beginning'
);


stdout_is(
    sub {
        $interpreter->interpret(qq{ print "hello world"\nprint "hello world";}),;
    },
    "hello world\nhello world\n",
    'interpreted two statements seperated by EOL on one line ok'
);

stdout_is(
    sub {
        $interpreter->interpret(qq{ print "hello ", "world"}),;
    },
    "hello world\n",
    'pass two strings to print',
);

done_testing;
