package Basic::Interpreter;
use Moose;
use namespace::autoclean;
use feature ':5.10';

use Marpa::XS;

use Basic::Interpreter::Action;
use Basic::Interpreter::Grammar;
use Basic::Interpreter::Lexer;

our $DEBUG = 0; # 0 = off, 1 = verbose, 2 = more verbose

has grammar => (
    is => 'rw',
    isa => 'HashRef',
    default => sub { +{ %{basic_grammar()} } }, # shallow copy
);

sub interpret {
    my ($self, $source_code) = @_;

    say 'Starting Interpreter...' if $DEBUG;

    my $lexer = Basic::Interpreter::Lexer->new( { source_text => $source_code } );

    my $grammar = Marpa::XS::Grammar->new($self->grammar);
    $grammar->precompute;
    
    my $recognizer = Marpa::XS::Recognizer->new( { grammar => $grammar } );

    while (my $token = $lexer->next_token) {
        if (defined $recognizer->read( @$token )) {
            say "reading Token: @$token" if $DEBUG;
            say "expecting: " . join(', ', @{$recognizer->terminals_expected}) if $DEBUG > 1;
        } else {
            die "Error reading Token: @$token, " .
                'expecting: ' . join(', ', @{$recognizer->terminals_expected});
            ### TODO: find line, column and quote context
        };
    }
    
    return $recognizer->value();
}

__PACKAGE__->meta->make_immutable;

1;
