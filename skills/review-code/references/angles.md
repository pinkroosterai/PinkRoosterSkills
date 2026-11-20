# Angle catalog

The angles a review runs, each with its checklist, the files it takes and what lies outside
its lane. A reviewer's brief carries its angle's section pasted whole, so each section stands
on its own.

## Contents

- [Choosing the angles](#choosing-the-angles)
- [What every angle shares](#what-every-angle-shares)
- [SOLID](#solid) — core
- [DRY and duplication](#dry-and-duplication) — core
- [Architecture and layering](#architecture-and-layering) — core
- [Code quality and readability](#code-quality-and-readability) — core
- [Security](#security) — optional
- [Testing](#testing) — optional
- [Performance](#performance) — optional

## Choosing the angles

The four core angles run on every review. The three optional angles run only when the
developer asks for them, by name or plainly ("check security too", "and the tests"). The
main session never adds an optional angle on its own. The review document may suggest one —
when reviewers' out-of-angle notes point at it — giving those notes as the reason, without
reporting them as findings.

The catalog is closed. When the developer asks for an angle it does not hold, say so, name
the nearest angle if there is one, and ask whether to run with it or with the core angles
alone.

An optional angle requested for code it barely applies to (performance on a small CLI) still
runs; the review document says when the angle found little in scope.

## What every angle shares

- The code is reviewed against the codebase's own evident or documented design, not an ideal
  imposed from outside. A documented project convention is never a finding.
- Test code is in scope for every angle and held to that angle's checklist (duplicated setup
  is DRY's; an unreadable test is code quality's). Test adequacy and design belong to the
  testing angle and are not reviewed when it was not requested.
- Configuration and build files go to an angle only where its section says so; otherwise
  they are skipped as non-source.
- A metric — complexity, duplication percentage, coverage — appears only from tool output in
  the brief, never estimated.
- An evident defect seen in passing (a wrong condition, an ignored error result) that is not
  in the reviewer's angle goes under "Out of angle" for code quality.

## SOLID

**Question:** are responsibilities and dependencies arranged so that a change has one reason
and one place to happen?

**Takes:** source files and their tests.

- **Single responsibility** — a class or module that changes for several unrelated reasons:
  domain rules mixed with I/O, formatting, persistence or transport; a type whose name needs
  "And" or a vague "Manager", "Helper" or "Util" to cover what it does.
- **Open/closed** — a conditional over a type code or kind that recurs across the codebase
  and must be edited for every new variant, where variants do get added.
- **Liskov substitution** — subtypes that throw "not supported", ignore or strengthen the
  base contract, or force callers to check the concrete type before using them.
- **Interface segregation** — an interface whose implementers stub out members, or whose
  clients use a small part of it while depending on all of it.
- **Dependency inversion** — high-level policy that constructs or reaches statically for
  low-level details (database, HTTP, file system, clock, environment) so it cannot be
  substituted or tested in isolation.

**Not a finding:** an abstraction missing where there is one implementation and no second in
sight; small scripts and glue code held to enterprise structure.

**Outside the lane:** duplicated logic (DRY); dependency direction between modules or layers
(architecture); naming and readability (code quality); speculative abstraction that is not
needed (code quality).

## DRY and duplication

**Question:** is each piece of knowledge — a rule, a calculation, a format, a constant —
represented once?

**Takes:** source files and their tests.

- Copied or near-copied blocks: the same logic with renamed variables, within a file or
  across files.
- One business rule, validation, constant or format encoded in several places that must
  change together.
- Parallel structures kept in step by hand: the same switch over one enum in many places,
  mirrored type hierarchies, a schema restated in code.
- Re-implementation of something the codebase, its framework or the standard library already
  provides.
- Duplicated setup and fixtures across tests.

Duplication crosses module groups. Search beyond the manifest for the other copies, and raise
the candidate on the manifest file, citing every location found.

**Not a finding:** incidental similarity — code that looks alike but encodes different
knowledge and changes for different reasons; deliberate duplication across a boundary that
keeps two modules independent (separate types per layer, a copied contract between
services), when the boundary is evident or documented.

**Outside the lane:** how responsibilities are split inside a class (SOLID); which module
should own the shared code, when that changes dependency direction (architecture).

## Architecture and layering

**Question:** do the modules depend on each other in the intended direction, behind clear
boundaries?

**Takes:** source files and their tests, plus build and project manifests — project files,
package manifests, dependency declarations — because they record the dependency direction
between modules.

First establish the intended architecture from the project's instructions and documents,
the directory and project structure and the manifests, and state it in the evidence of every
candidate. Then check:

- **Dependency direction** — core or domain code that imports infrastructure, UI or framework
  code; a lower layer referencing a higher one; a project reference or package dependency in a
  manifest that contradicts the layering.
- **Cycles** — modules, packages or projects that depend on each other, directly or through a
  chain.
- **Leaky boundaries** — persistence or transport types (ORM entities, request objects, wire
  formats) passing through the core; framework types in the domain model.
- **Misplaced logic** — business rules in controllers, UI handlers, scripts or queries.
- **Bypassed boundaries** — callers reaching into another module's internals instead of its
  public surface.
- **Module cohesion** — a module of unrelated features; a shared "common" or "utils" module
  that everything depends on and that changes with everything.
- **Composition** — wiring and configuration scattered through the code; global mutable state
  or singletons shared across modules.

**Not a finding:** a flat, pragmatic structure in a small codebase with no documented
layering. Review against the architecture the codebase evidently intends, not one imposed
on it.

**Outside the lane:** class-level responsibilities and dependency inversion inside one
module (SOLID); duplicated code (DRY).

## Code quality and readability

**Question:** can a maintainer read this code, understand what it does and change it safely?

**Takes:** source files and their tests.

- **Naming** — names that mislead, disagree with what the code does, or vary for one concept.
- **Size and shape** — functions and methods long or deeply nested enough to hide their
  logic; long parameter lists; boolean flag parameters that switch behaviour.
- **Conditionals and literals** — tangled conditions; unexplained magic numbers and strings.
- **Error handling** — swallowed or overly broad catches, ignored error results, errors
  without context, inconsistent error strategies within one module.
- **Dead weight** — unreachable code, commented-out code, unused parameters, members and
  imports.
- **Comments** — comments that contradict the code or restate it; intent left unexplained
  where the code cannot carry it.
- **Hidden effects** — side effects in getters or innocent-looking calls; shared mutable
  state; resources opened without a clear release.
- **Speculative generality** — indirection, options or abstractions with no current use.
- **Evident defects** — a wrong operator or condition, an off-by-one, an ignored return
  value that matters, seen while reading.

**Not a finding:** anything the project's formatter or linter enforces automatically (its
output appears as tool metrics instead); stylistic preferences no project rule or reference
states.

**Outside the lane:** duplicated logic (DRY); responsibilities and dependencies of a class
(SOLID); module boundaries (architecture); security weaknesses (security).

## Security

Optional: runs only when requested.

**Question:** can untrusted input, a missing check or a leaked secret compromise the system?

**Takes:** source files and their tests, plus configuration files (application settings,
deployment, container and CI configuration).

- **Untrusted input to sinks** — input crossing a trust boundary and reaching a query, shell
  command, file path, template, deserializer or outbound request without validation or
  parameterization.
- **Authentication and authorization** — entry points without the checks their neighbours
  have; authorization decided on the client; object access without an ownership check.
- **Secrets** — credentials, keys or tokens in code or configuration. Cite the location;
  never reproduce the value.
- **Cryptography** — home-made schemes, fast hashes for passwords, fixed IVs or salts,
  non-cryptographic randomness for tokens.
- **Exposure** — sensitive data in logs, error messages or responses.
- **Unsafe defaults** — debug modes, permissive CORS, disabled certificate validation,
  over-broad permissions in configuration.
- **Vulnerable dependencies** — only from an existing audit tool's output in the brief, never
  from memory.

**Not a finding:** a weakness with no reachable path from untrusted input. When reachability
cannot be traced, say so; the validator decides between valid and uncertain.

**Outside the lane:** general error-handling quality (code quality); structural coupling
(architecture).

## Testing

Optional: runs only when requested.

**Question:** do the tests catch the regressions that matter, reliably?

**Takes:** test files with the source they test, plus test configuration (test runner,
coverage and fixture configuration).

- **Gaps** — core logic, error paths or boundaries with no test beside them. Coverage figures
  only from tool output.
- **Weak tests** — tests that cannot fail, assert nothing meaningful, or assert implementation
  details instead of behaviour; mocks so broad the test checks the mocks.
- **Flakiness** — dependence on time, randomness, ordering, network, the file system or state
  shared between tests.
- **Design** — tests that are hard to read: unclear arrangement, several behaviours in one
  test, opaque fixtures.
- **Configuration** — test configuration that hides failures: skipped suites, swallowed
  errors, thresholds that cannot be met or never fail.

**Not a finding:** a missing test for trivial code (plain accessors, generated members).
Tests are not run by the reviewer; only step 3 runs existing tools.

**Outside the lane:** production code that is hard to test because of its dependencies
(SOLID, dependency inversion); duplicated setup when testing was not requested (DRY).

## Performance

Optional: runs only when requested.

**Question:** does the code do avoidable work on paths that matter?

**Takes:** source files and their tests.

- **Algorithmic** — nested iteration over collections that grow with input; repeated linear
  lookups where a keyed structure fits; queries issued per item (N+1).
- **I/O** — calls inside loops that could be batched; chatty remote or database access.
- **Concurrency** — blocking calls on asynchronous paths; waiting synchronously on
  asynchronous work.
- **Memory** — unbounded caches or buffers; whole datasets loaded where streaming fits.
- **Resources** — connections, clients or handles created per call instead of reused, or
  never released.

Evidence names why the path matters (an entry point, a loop over request data, a hot path the
project documents). Timings and allocation figures only from tool output.

**Not a finding:** micro-optimizations on code with no evidence it is on a path that matters.

**Outside the lane:** readability of the slow code (code quality); its structure (SOLID,
architecture).
