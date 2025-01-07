use Test;  # for is test-assertion trait
use Code::Coverage:ver<0.0.3+>:auth<zef:lizmat>;
use paths:ver<10.1+>:auth<zef:lizmat>;

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
    my $coverage   := 100 - 100 * $missed / $coverables;
    ok $coverage > $boundary, "Coverage $coverage% > $boundary%";
}

my sub uncovered-at-most($boundary) is export is test-assertion {
    my $missing := CC.missed.values.sum;
    ok $missing < $boundary, "Uncovered $missing < $boundary lines";
}

my sub report() is export {
    my $cc := CC;
    for $cc.coverables -> $coverable {
        my $key := $coverable.key;
        say "\n$coverable.value.target():";
        print $cc.annotated($key);
    }
}

# Also export all Test features
BEGIN EXPORT::DEFAULT::{.key} := .value for Test::EXPORT::DEFAULT::;

# vim: expandtab shiftwidth=4
