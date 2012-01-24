use strict;
use warnings;
use Test::More;
use Test::Exception;

use ok 'Basic::Interpreter::Lexer';


# basic behavior
{
    my $lexer;
    lives_ok { $lexer = Basic::Interpreter::Lexer->new() }
             'creating lexer lives 1';
    can_ok $lexer, qw(source_text tokenizer pos next_token);
    
    $lexer->source_text('/* bla */');
    is $lexer->source_text, '/* bla */', 'setting source text works';
    is ref $lexer->tokenizer, 'CODE', 'tokenizer is a coderef';
    ok !defined $lexer->pos, 'pos initially undefined';
    
    my $old_tokenizer = $lexer->tokenizer;
    
    $lexer->source_text('/* foo */');
    is $lexer->source_text, '/* foo */', 'changing source text works';
    ok $old_tokenizer ne $lexer->tokenizer, 'tokenizer freshly created';
}

# lexing tokens
{
    my $lexer;
    lives_ok { $lexer = Basic::Interpreter::Lexer->new() }
             'creating lexer lives 2';
             
    # empty string
    $lexer->source_text('');
    ok !defined $lexer->next_token, 'empty: eof is undef';
    ok !defined $lexer->next_token, 'empty: eof reported repeatedly';
    ok !defined $lexer->next_token, 'empty: eof reported more than twice';
    
    # eof discovery
    $lexer->source_text('"hello world"');
    is_deeply $lexer->next_token, 
              [ STRING => 'hello world' ], 
              'string recognized';
    ok !defined $lexer->next_token, 'simple: eof is undef';
    ok !defined $lexer->next_token, 'simple: eof reported repeatedly';
    ok !defined $lexer->next_token, 'simple: eof reported more than twice';
    
    # misc scenarios
    my @token_tests = (
        {
            name   => 'string',
            source => ' "hello world"',
            tokens => [ [STRING => 'hello world'] ],
        },
        {
            name   => 'print string',
            source => q{ print "hello world"},
            tokens => [ [ VERB => 'PRINT' ], [STRING => 'hello world'] ],
        },
        {
            name   => 'print the string "PRINT"',
            source => q{ PRINT "PRINT"},
            tokens => [ [ VERB => 'PRINT' ], [STRING => 'PRINT'] ],
        },

        {
            name   => 'number',
            source => '42 41. 40.3',
            tokens => [ [NUMBER => '42'], [NUMBER => '41.'], [NUMBER => '40.3'], ],
        },
        {
            name   => 'statement separators',
            source => 
qq{print "1";print "2"
print "3"},
            tokens => [
                [ VERB        => 'PRINT' ],
                [ STRING      => '1' ],
                [ 'SEMICOLON' => ';' ],
                [ VERB        => 'PRINT' ],
                [ STRING      => '2' ],
                [ 'EOL' ],
                [ VERB        => 'PRINT' ],
                [ STRING      => '3' ],
            ],
        },
        {
            name   => 'single letter terminals',
            source => '{}()[];:,.#>*/+-$&',
            tokens => [ 
              ['OPEN_CURLY'   => '{'],  ['CLOSE_CURLY'  => '}'],
              ['OPEN_PAREN'   => '('],  ['CLOSE_PAREN'  => ')'],
              ['OPEN_BRACKET' => '['],  ['CLOSE_BRACKET'=> ']'],
              ['SEMICOLON'    => ';'],  ['COLON'        => ':'],
              ['COMMA'        => ','],  ['DOT'          => '.'],
              ['HASH'         => '#'],  ['GT'           => '>'],
              ['SPLASH'       => '*'],  ['SLASH'        => '/'],
              ['PLUS'         => '+'],  ['MINUS'        => '-'],
              ['DOLLAR'       => '$'],  ['AMPERSAND'    => '&'],
            ],
        },
        {
            name => 'comments',
            source => qq{REM blahblbah\nprint "asdf"\n},
            tokens => [ [ VERB => 'PRINT' ], [ STRING => 'asdf' ], [ 'EOL' ] ],
        },
    );
    
    foreach my $test_case (@token_tests) {
        $lexer->source_text($test_case->{source});
        my $i = 1;
        foreach my $token (@{$test_case->{tokens}}) {
            my $read_token = $lexer->next_token;
            
            if (scalar @$read_token == 2
                && ref($read_token->[1]) =~ m{Value}xms
                && $read_token->[1]->can('as_string')
                ) {
                $read_token->[1] = $read_token->[1]->as_string;
            }
            is_deeply $read_token, $token, "$test_case->{name}: token $i";
            $i++;
        }
        ok !defined $lexer->next_token, "$test_case->{name}: eof";
    }
}

done_testing;
