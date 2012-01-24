#!/usr/bin/env perl

use strict;
use warnings;
use FindBin '$Bin';
use lib "$FindBin::Bin/../lib";
use File::Slurp;
use Basic::Interpreter;

my $filename = shift || die "usage: $0 filename\n";

my $interpreter = Basic::Interpreter->new();

my $src = read_file( $filename );
#warn $src;
#warn $src;
#$interpreter->interpret( $src );
#$src = qq{PRINT "hello world"} ;
$interpreter->interpret( $src );
#$interpreter->interpret( 
#qq{print "hello world";print "hello world" });
