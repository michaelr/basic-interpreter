package Basic::Interpreter::Lexer;

use Moose;
use namespace::autoclean;

has source_text => (
    is => 'rw',
    isa => 'Str',
    trigger => \&_refresh_tokenizer,
);

has tokenizer => (
    is => 'rw',
    isa => 'CodeRef',
    lazy => 1,
    builder => '_build_tokenizer',
);

has pos => (
    is => 'rw',
    isa => 'Int',
);

my %symbol_for_char = (
    '{' => 'OPEN_CURLY',    '}' => 'CLOSE_CURLY',
    '(' => 'OPEN_PAREN',    ')' => 'CLOSE_PAREN',
    '[' => 'OPEN_BRACKET',  ']' => 'CLOSE_BRACKET',
    ';' => 'SEMICOLON',     ':' => 'COLON',
    ',' => 'COMMA',         '.' => 'DOT',
    '#' => 'HASH',          '>' => 'GT',
    '*' => 'SPLASH',        '/' => 'SLASH',
    '+' => 'PLUS',          '-' => 'MINUS',
    '$' => 'DOLLAR',        '&' => 'AMPERSAND',
    "\n" => 'NEWLINE',
);

sub _refresh_tokenizer {
    my $self = shift;
    
    $self->tokenizer($self->_build_tokenizer);
}


sub _build_tokenizer {
    my $self = shift;
    
    my $text = $self->source_text;
    
    return sub {
        my $token = undef;
        
        while ((pos($text) // 0) < length $text) {
            
            next if $text =~ m{\G \h* }xmsgc; # skip horizontal whitespace
            next if $text =~ m{\G REM .*? \n }ximsgc;

            $text =~ m{\G (PRINT) \s}ximsgc
                and do { $token = [ 'PRINT' ]; last };

            $text =~ m{\G (") ((?:[^\\\1] | \\.)*?) \1 }xmsgc 
                and do { $token = [ STRING => $2 ]; last };

            $text =~ m{\G (\.\d+ | \d+ (?:\.\d*)?) }xmsgc
                and do { $token = [ NUMBER => $1 ]; last };
            
            $text =~ m{\G \n* }xmsgc
                and do { $token = [ 'NEWLINE' ]; last };

            my $pos = pos($text) || 0;
            my $char = substr($text,$pos,1);
            if (exists($symbol_for_char{$char})) {
                $token = [ $symbol_for_char{$char} => $char ];
            } else {
                $token = [ CHAR => $char ];
            }
            pos($text) = $pos+1;
            last;
        }
        
        $self->pos( pos($text) // 0 );
        return $token;
    };
}


sub next_token {
    my $self = shift;
    
    return $self->tokenizer->();
}

__PACKAGE__->meta->make_immutable;

1;
