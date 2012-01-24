package Basic::Interpreter::Grammar;

use strict;
use warnings;
use base 'Exporter';

our @EXPORT = qw(basic_grammar basic_rules);

sub basic_grammar {
    return {
        start => 'PROGRAM',
        actions => 'Basic::Interpreter::Action',
        default_action => 'do_default',
        rules => basic_rules()
    };
}

sub basic_rules {
    return [
        {
            lhs => 'PROGRAM',
            rhs => [qw(NEWLINE LINES)],
        },
        {
            lhs => 'PROGRAM',
            rhs => [qw(LINES)],
        },
        {
            lhs => 'LINES',
            rhs => [qw(LINES LINE)],
        },
        {
            lhs => 'LINES',
            rhs => [qw(LINE)],
        },
        {
            lhs => 'LINE',
            rhs => [qw(STATEMENTS NEWLINE)],
        },
        {
            lhs => 'LINE',
            rhs => [qw(STATEMENTS)],
        },

        {
            lhs => 'STATEMENTS',
            rhs => [qw(STATEMENTS SEMICOLON STATEMENT )],
        },
        {
            lhs => 'STATEMENTS',
            rhs => [qw(STATEMENT SEMICOLON)],
        },

        {
            lhs => 'STATEMENTS',
            rhs => [qw(STATEMENT)],
        },
        {
            lhs => 'STATEMENT',
            rhs => [qw(PRINT OUTPUTLIST)],
            action => 'do_verb_print',
        },
        {
            lhs => 'OUTPUTLIST',
            rhs => [qw(OUTPUTLIST COMMA OUTPUTLIST_ITEM)],
        },
        {
            lhs => 'OUTPUTLIST',
            rhs => [qw(OUTPUTLIST_ITEM)],
        },
        {
            lhs => 'OUTPUTLIST_ITEM',
            rhs => [qw(STRING)],
            action => 'do_string',
        },

    ];
}
