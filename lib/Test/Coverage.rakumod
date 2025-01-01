use Test;  # for is test-assertion trait
use Code::Coverage:ver<0.0.2>:auth<zef:lizmat>;
use paths:ver<10.1>:auth<zef:lizmat>;

my $CC;
my sub CC() {

    # Custom setup done externally, or before
    with $*CODE-COVERAGE // $CC {
        $_
    }

    # Need to do automatic setup now
    else {
        $CC := default-coverage-setup;
        $CC.run;
        $CC
    }
}

# Return a Code::Coverage object with default settings
my sub default-coverage-setup() is export {
    my $prefix  := $*PROGRAM.parent(2);
    my $io      := $prefix.add("META6.json");
    my %meta    := Rakudo::Internals::JSON.from-json($io.slurp);
    my @targets := %meta<provides>.values.unique;
    my @runners  = paths
      $prefix.add("t"), :file(*.ends-with(".rakutest" | ".t"));

    Code::Coverage.new(:@targets, :@runners)
}

my sub coverage-at-least($boundary) is export is test-assertion {
    my $coverage := CC.coverage;
    ok $coverage > $boundary, "Coverage $coverage% > $boundary%";
}

my sub uncovered-at-most($boundary) is export is test-assertion {
    my $missing := CC.missing.values.sum;
    ok $missing < $boundary, "Uncovered $missing < $boundary lines";
}

=begin pod

=head1 NAME

Test::Coverage - Check test files for sufficient coverage

=head1 SYNOPSIS

=begin code :lang<raku>

# in xt/coverage.rakutest
use Test::Coverage;

coverage-at-least 80;  # ok if at least 80% of lines is covered

uncovered-at-most 10;  # ok if at most 10 lines are not covered

=end code

=head1 DESCRIPTION

The C<Test::Coverage> distribution provides an easy way for Raku
module developers to see whether the test-suite of their module
covers as much as possible of the code of their module.

As such it exports subroutines to allow easy checking in a test
script that lives in the "xt" directory, so that it will only
be run by the author.

Note that as such, this does B<not> add any dependencies to a
module, B<not> even for testing as "test-depends" as these tests
should only be run by the author in normal circumstances.

By default, all of the test files in the "t" directory, and its
subdirectories (extensions C<.rakutest> and C<.t>) will be run
against all of the unique files provided by the C<provides>
section in the C<META6.json> file.

=head1 SUBROUTINES

=head2 coverage-at-least

=begin code :lang<raku>

coverage-at-least 80;  # ok if at least 80% of lines is covered

=end code

The C<coverage-at-least> subroutine counts as a single test, and
reports a passed test if the percentage of lines covered by the
tests in the module reached the given amount (or more).

=head2 uncovered-at-most

=begin code :lang<raku>

uncovered-at-most 10;  # ok if at most 10 lines are not covered

=end code

The C<uncovered-at-most> subroutine counts as a single test, and
reports a passed test if the number of lines B<not> covered by
the tests in the module is less then or equal to the number given.

=head2 default-coverage-setup

=begin code :lang<raku>

my $*CC = default-coverage-setup;  

# run the actual tests and calculate coverage
$*CC.run;

coverage-at-least 80;  # ok if at least 80% of lines is covered
uncovered-at-most 10;  # ok if at most 10 lines are not covered

=end code

The C<default-coverage-setup> subroutine sets up the underlying
L<C<Code::Coverage>|https://raku.land/zef:lizmat/Code::Coverage>
object, and returns that.

In most situations this is not needed, as any call to the
C<coverage-at-least> and C<uncovered-at-most> subroutines will
trigger the setup and running automatically.

=head1 AUTHOR

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/Test-Coverage . Comments and
Pull Requests are welcome.

If you like this module, or what I'm doing more generally, committing to a
L<small sponsorship|https://github.com/sponsors/lizmat/>  would mean a great
deal to me!

=head1 COPYRIGHT AND LICENSE

Copyright 2025 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: expandtab shiftwidth=4
