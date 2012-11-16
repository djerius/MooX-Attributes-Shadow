use inc::Module::Install;

name 'MooX-Attributes-Shadow';
all_from 'lib/MooX/Attributes/Shadow.pm';

author_tests 'xt';
author_requires 'Test::NoBreakpoints';

tests_recursive;

test_requires 'Test::Deep';
test_requires 'Test::More';
test_requires 'Test::Exception';

requires 'Moo';
requires 'Moo::Role';
requires 'MooX::Types::MooseLike' => 0.11;
requires 'Params::Check';


WriteAll;
