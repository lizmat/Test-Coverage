[![Actions Status](https://github.com/lizmat/Test-Coverage/actions/workflows/linux.yml/badge.svg)](https://github.com/lizmat/Test-Coverage/actions) [![Actions Status](https://github.com/lizmat/Test-Coverage/actions/workflows/macos.yml/badge.svg)](https://github.com/lizmat/Test-Coverage/actions) [![Actions Status](https://github.com/lizmat/Test-Coverage/actions/workflows/windows.yml/badge.svg)](https://github.com/lizmat/Test-Coverage/actions)

NAME
====

Test::Coverage - Check test files for sufficient coverage

SYNOPSIS
========

```raku
# in xt/coverage.rakutest
use Test::Coverage;

plan 2;

coverage-at-least 80;  # ok if at least 80% of lines is covered

uncovered-at-most 10;  # ok if at most 10 lines are not covered
```

DESCRIPTION
===========

The `Test::Coverage` distribution provides an easy way for Raku module developers to see whether the test-suite of their module covers as much as possible of the code of their module.

As such it exports subroutines to allow easy checking in a test script that lives in the "xt" directory, so that it will only be run by the author.

Note that as such, this does **not** add any dependencies to a module, **not** even for testing as "test-depends" as these tests should only be run by the author in normal circumstances.

By default, all of the test files in the "t" directory, and its subdirectories (extensions `.rakutest` and `.t`) will be run against all of the unique files provided by the `provides` section in the `META6.json` file.

For convenience, all of the features of the `Test` module are also exported by this module.

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

must-be-complete
----------------

```raku
# in xt/coverage.rakutest
use Test::Coverage;

must-be-complete;
```

The `must-be-complete` subroutine can be called as the **only** subroutine in a coverage test file. It sets the `plan` at `1`, counts as a single test, and passes the test if **all** the coverable lines have been covered. This is usually used for very small modules, and only as a insurance against accidental regressions.

If the test does **not** pass, then the `source-with-coverage` and `report` subroutines will be called to give the onlooker an idea of what is going wrong.

default-coverage-setup
----------------------

```raku
default-coverage-setup;

# run the actual tests and calculate coverage
run;

coverage-at-least 80;  # ok if at least 80% of lines is covered
uncovered-at-most 10;  # ok if at most 10 lines are not covered
```

The `default-coverage-setup` subroutine sets up the underlying [`Code::Coverage`](https://raku.land/zef:lizmat/Code::Coverage) object, sets the `$*CODE-COVERAGE` environment variable with it and returns that.

In most situations this is not needed, as any call to the `coverage-at-least` and `uncovered-at-most` subroutines will trigger the setup and running of the tests automatically.

run
---

```raku
my $*CODE-COVERAGE := Code::Coverage.new(...);

run;

# check results
```

The `run` subroutine runs the tests and updates any information in the `Code::Coverage` object that should be available in the `$*CODE-COVERAGE` environment variable.

It is only needed if some non-standard setup is needed, or if you need to run the tests in a non-standard way:

```raku
default-coverage-setup;

run("foo");
run("bar");

# check results
```

report
------

```raku
report                          # show report if test failed
  unless uncovered-at-most 10;  # ok if at most 10 lines are not covered
```

The `report` subroutine will print a report of the coverage tests if called in sink context. It is typically only called if a test fails.

If not in sink context, will return the string of the report:

```raku
mail report, :to<coverage@reports.org>;
```

source-with-coverage
--------------------

```raku
source-with-coverage;  # produce as sibling dir to script

source-with-coverage($dir);
```

The `source-with-coverage` subroutine will produce the annotated source of all targets in the given directory (as an `IO::Path`) with the `.rakucov` extension. If called without any argument, will assume a directory with the same name (but without extension) as the name of the script one directory up from where the test-file resides.

So e.g. a script in `xt/coverage.rakutest` in a `Foo::Bar` distribution would create a directory `xt/coverage/Foo` and write the annotated source in `xt/coverage/Foo/Bar.rakucov`.

Note: if you're making use of this feature, it's probably wise to add `*.rakucov` to the `.gitignore` file.

SEE ALSO
========

The [`App:RaCoCo`](https://raku.land/zef:atroxaper/App::RaCoCo) distribution provides similar functionality, but is more app oriented rather than test file-based.

AUTHOR
======

Elizabeth Mattijsen <liz@raku.rocks>

Source can be located at: https://github.com/lizmat/Test-Coverage . Comments and Pull Requests are welcome.

If you like this module, or what I'm doing more generally, committing to a [small sponsorship](https://github.com/sponsors/lizmat/) would mean a great deal to me!

COPYRIGHT AND LICENSE
=====================

Copyright 2025 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

