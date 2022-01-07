grammar Day24;

INPUT: 'inp';
INSTRUCTION : ('add'|'mul'|'mod'|'div'|'eql');
TARGET : [w-z];
VALUE : [-]?[0-9]+;

command: INSTRUCTION ' ' TARGET ' ' (TARGET|VALUE);
input: INPUT ' ' TARGET;

line: command '\n'
    | input '\n';

program: line+;
