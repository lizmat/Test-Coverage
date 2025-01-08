use v6.*;  # we need IO::Path.stem

use Test;  # for is test-assertion trait
use Code::Coverage:ver<0.0.3+>:auth<zef:lizmat>;
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

    PROCESS::<$CODE-COVERAGE> := Code::Coverage.new(
      :targets(%meta<provides>.keys),
      :runners(paths $prefix.add("t"), :file(*.ends-with(".rakutest" | ".t"))),
      :extra<-I.>
    )
}

# Provide easy run support
my sub run(|c) is export { CC.run(|c) }

my sub coverage-at-least($boundary) is export is test-assertion {
    my $coverables := CC.coverables.values.map(*.line-numbers.elems).sum;
    my $missed     := CC.missed.values.sum;
    my $coverage   := sprintf '%.2f', 100 - 100 * $missed / $coverables;
    ok $coverage >= $boundary, "Coverage $coverage% > $boundary%";
}

my sub uncovered-at-most($boundary) is export is test-assertion {
    my $missing := CC.missed.values.sum;
    ok $missing <= $boundary, "Uncovered $missing < $boundary lines";
}

# Helper role to print if called in sink context
my role print-if-sunk { method sink() { print "\n" ~ self } }

my sub report() is export {
    my str @parts = "Coverage Report of "
      ~ DateTime.now.Str.substr(0,19).split("T")
      ~ ":\n\n";

    my $cc := CC;
    my %coverage := $cc.coverage;
    my %missed   := $cc.missed;
    for $cc.coverables {
        my $key       := .key;
        my $coverable := .value;
        my $target    := $coverable.target;
        @parts.push: "$target (%coverage{$key}):\n";

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
