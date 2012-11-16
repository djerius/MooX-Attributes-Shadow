use inc::Module::Install;

name 'MooX-Attributes-Shadow';
all_from 'lib/MooX/Attributes/Shadow.pm';

author_tests 'xt';
author_requires 'Test::NoBreakpoints';
author_requires 'Test::Perl::Critic';
author_requires 'Test::Pod::Coverage';
author_requires 'Test::Pod';

tests_recursive;

test_requires 'Test::More';
test_requires 'Test::Exception';

requires 'Moo';
requires 'Moo::Role';
requires 'MooX::Types::MooseLike' => 0.11;
requires 'Params::Check';


WriteAll;
