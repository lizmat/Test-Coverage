[![Actions Status](https://github.com/lizmat/Test-Coverage/actions/workflows/linux.yml/badge.svg)](https://github.com/lizmat/Test-Coverage/actions) [![Actions Status](https://github.com/lizmat/Test-Coverage/actions/workflows/macos.yml/badge.svg)](https://github.com/lizmat/Test-Coverage/actions) [![Actions Status](https://github.com/lizmat/Test-Coverage/actions/workflows/windows.yml/badge.svg)](https://github.com/lizmat/Test-Coverage/actions)

NAME
====

Test::Coverage - Check test files for sufficient coverage

SYNOPSIS
========

```raku
# in xt/coverage.rakutest
use Test::Coverage;

coverage-at-least 80;  # ok if at least 80% of lines is covered

uncovered-at-most 10;  # ok if at most 10 lines are not covered
```

DESCRIPTION
===========

The `Test::Coverage` distribution provides an easy way for Raku module developers to see whether the test-suite of their module covers as much as possible of the code of their module.

As such it exports subroutines to allow easy checking in a test script that lives in the "xt" directory, so that it will only be run by the author.

Note that as such, this does **not** add any dependencies to a module, **not** even for testing as "test-depends" as these tests should only be run by the author in normal circumstances.

By default, all of the test files in the "t" directory, and its subdirectories (extensions `.rakutest` and `.t`) will be run against all of the unique files provided by the `provides` section in the `META6.json` file.

SUBROUTINES
===========

coverage-at-least
-----------------

```raku
coverage-at-least 80;  # ok if at least 80% of lines is covered
```

The `coverage-at-least` subroutine counts as a single test, and reports a passed test if the percentage of lines covered by the tests in the module reached the given amount (or more).

uncovered-at-most
-----------------

```raku
uncovered-at-most 10;  # ok if at most 10 lines are not covered
```

The `uncovered-at-most` subroutine counts as a single test, and reports a passed test if the number of lines **not** covered by the tests in the module is less then or equal to the number given.

default-coverage-setup
----------------------

```raku
my $*CC = default-coverage-setup;  

# run the actual tests and calculate coverage
$*CC.run;

coverage-at-least 80;  # ok if at least 80% of lines is covered
uncovered-at-most 10;  # ok if at most 10 lines are not covered
```

The `default-coverage-setup` subroutine sets up the underlying [`Code::Coverage`](https://raku.land/zef:lizmat/Code::Coverage) object, and returns that.

In most situations this is not needed, as any call to the `coverage-at-least` and `uncovered-at-most` subroutines will trigger the setup and running automatically.

AUTHOR
======

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/Test-Coverage . Comments and Pull Requests are welcome.

If you like this module, or what I'm doing more generally, committing to a [small sponsorship](https://github.com/sponsors/lizmat/) would mean a great deal to me!

COPYRIGHT AND LICENSE
=====================

Copyright 2025 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

