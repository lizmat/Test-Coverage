use v6.*;  # we need IO::Path.stem

use Test;  # for is test-assertion trait
use Code::Coverage:ver<0.0.5+>:auth<zef:lizmat>;
use paths:ver<10.1+>:auth<zef:lizmat>;
use META::constants:ver<0.0.5+>:auth<zef:lizmat> $?DISTRIBUTION;

# Return a valid Code::Coverage object
my sub CC() {

    # Custom setup done externally, or before
    with $*CODE-COVERAGE {
        $_
    }

    # Need to do automatic setup now, setting the dynamic variable
    else {
        my $cc := default-coverage-setup;
        $cc.run;
        $cc
    }
}

# Return a Code::Coverage object with default settings
my sub default-coverage-setup() is export {
    my $prefix := $*PROGRAM.parent(2);
    my $io     := $prefix.add("META6.json");
    my %meta   := Rakudo::Internals::JSON.from-json($io.slurp);

    my $file   := *.ends-with(".rakutest" | ".t");
    my @runners = paths $prefix.add("t"), :$file;

    my $program := $*PROGRAM.absolute;
    @runners.append: paths($prefix.add("xt"), :$file).grep(* ne $program);

    PROCESS::<$CODE-COVERAGE> := Code::Coverage.new(
      :targets(%meta<provides>.keys), :@runners, :extra<-I.>
    )
}

# Provide easy run support
my sub run(|c) is export { CC.run(|c) }

# Test by coverage percentage
my sub coverage-at-least($boundary) is export is test-assertion {
    my $max-lines := CC.max-lines;
    my $missed    := CC.num-missed-lines;
    my $coverage  := sprintf '%.2f', 100 - 100 * $missed / $max-lines;
    ok $coverage >= $boundary, "Coverage $coverage% >= $boundary%";
}

# Test by number of lines not covered
my sub uncovered-at-most($boundary) is export is test-assertion {
    my $missing := CC.num-missed-lines;
    ok $missing <= $boundary, "Uncovered $missing <= $boundary lines";
}

# Coverage must be 100%
my sub must-be-complete() is export is test-assertion {
    nok CC.num-missed-lines, 'is coverage complete?';
}

# Helper role to print if called in sink context
my role print-if-sunk { method sink() { print "\n" ~ self } }

my sub report() is export {
    my str @parts;

    my $proc := &CORE::run($*EXECUTABLE, "--version", :out);
    @parts.push: $proc.out.slurp unless $proc.exitcode;
    @parts.push: "Coverage Report of "
      ~ DateTime.now.Str.substr(0,19).split("T")
      ~ "\n";

    my $cc := CC;
    my %coverage := $cc.coverage;
    my %missed   := $cc.missed;
    for $cc.coverables {
        my $key       := .key;
        my $coverable := .value;
        my $target    := $coverable.target;
        my $coverage  := %coverage{$key} // "100%";
        @parts.push: "\n$target ($coverage):\n";

        my $missed := %missed{$key};
        @parts.push: "  Missed $missed.elems() lines out of $coverable.line-numbers.elems():\n";
        @parts.push: $missed.Str.naive-word-wrapper.indent(2) ~ "\n";
    }

    @parts.push: "\nProduced by " ~ NAME ~ " (" ~ VERSION ~ ")\n";

    @parts.join but print-if-sunk;
}

my sub source-with-coverage(
  IO::Path:D $dir = $*PROGRAM.sibling($*PROGRAM.stem)
) is export {
    mkdir($dir);

    my $cc := CC;
    for $cc.coverables {
        my $target := .value.target;

        # Only report module type targets
        unless $target.contains('/' | '\\') {
            my $io := $dir.add($target.subst('::',"/",:g) ~ '.rakucov');
            mkdir $io.parent;
            $io.spurt: $cc.annotated(.key);
        }
    }
}

# Also export all Test features
BEGIN EXPORT::DEFAULT::{.key} := .value for Test::EXPORT::DEFAULT::;

# vim: expandtab shiftwidth=4
