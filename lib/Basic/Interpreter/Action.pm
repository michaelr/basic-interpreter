package Basic::Interpreter::Action;
use Moose;
use namespace::autoclean;
use feature ':5.10';

our $DEBUG = 1;

# default action simply concatenates strings
sub do_default {
    shift; return shift;    
    #say Data::Dumper->Dump([ [@_] ],[ 'default action' ]); # if $DEBUG;
    #return join('', grep { defined } @_[1..$#_])
    #return '';
}

sub do_verb_print {
    my ($stash, $token, @outputlist) = @_;
    #say Data::Dumper->Dump([ [@_] ],[ 'default action' ]); # if $DEBUG;

    print join ',', @outputlist;
    print  "\n";
}

sub do_string {
    #say Data::Dumper->Dump([ [@_] ],[ 'do_string' ]); # if $DEBUG;
    my ( undef, $str) = @_;

    return $str;
}

__PACKAGE__->meta->make_immutable;

1;
