# General checklist

Language-neutral smells, each with why it hurts and the usual fix. It applies to every file
in every run, beside the language references; for a language with no bundled reference it is
the whole standard, together with the angle checklist and the project's rules.

A reviewer's brief carries two sections of this file, pasted: **Every angle** and the section
for its own angle. Cite an item by its ID (`GEN-CQ3`) in a candidate's rule line.

## Contents

- [Every angle](#every-angle)
- [SOLID](#solid)
- [DRY and duplication](#dry-and-duplication)
- [Architecture and layering](#architecture-and-layering)
- [Code quality and readability](#code-quality-and-readability)
- [Security](#security)
- [Testing](#testing)
- [Performance](#performance)

## Every angle

- **GEN-E1 The codebase's own conventions are the yardstick.** Where no reference or project
  rule decides a question of style or structure, the pattern most of the codebase follows is
  the norm, and a finding is a departure from it that costs something. Never a preference.
- **GEN-E2 Project rules win.** A pattern the project's instructions document or require is
  not a finding, whatever this checklist says. A finding that rests on a project rule cites it.
- **GEN-E3 No language advice from memory.** For a file with no language reference, raise only
  what this checklist, the angle checklist or a project rule supports. Language idioms that no
  bundled source states are left out; the review document marks these files as reviewed
  against reduced standards.
- **GEN-E4 Versions decide.** Advice that depends on a language, framework or runtime version
  applies only when the project's declared version supports it. When the version is unknown
  or newer than a reference targets, the finding is uncertain rather than asserted.
- **GEN-E5 Evidence is the code.** Every finding cites a location read in this run, describes
  what the code does there and states a concrete consequence. A metric comes only from tool
  output.
- **GEN-E6 Secrets stay out of the record.** A credential or key is cited by location only.
- **GEN-E7 Generated and vendored code is not the project's design.** A finding about it, when
  the developer asked for it to be reviewed, targets the generator's input or the vendoring
  decision, not the output.

## SOLID

- **GEN-SO1 Mixed responsibilities.** One unit (class, module, file) holds domain rules and
  also I/O, persistence, transport or presentation. *Why:* unrelated changes collide in one
  place and the rules cannot be exercised without the I/O. *Fix:* separate the rules from the
  effects, the rules taking plain inputs and returning plain results.
- **GEN-SO2 Catch-all type.** A type named "Manager", "Helper", "Util", "Service" or "Common"
  whose members share no data or purpose. *Why:* it attracts every new concern and depends on
  everything. *Fix:* move each group of members to the type whose data it uses.
- **GEN-SO3 Repeated type switch.** The same conditional over a kind or type code appears in
  several places and each new variant edits all of them. *Why:* a missed branch is a silent
  defect. *Fix:* one dispatch point — polymorphism, a table or a map from kind to behaviour.
- **GEN-SO4 Refused inheritance.** A subtype or implementation throws "not supported", does
  nothing, or ignores the contract its base promises; callers test the concrete type. *Why:*
  substitution breaks at run time, far from the cause. *Fix:* narrow the base contract, split
  the hierarchy, or use composition.
- **GEN-SO5 Fat interface.** Implementers stub out members, or clients use a small part of a
  large interface. *Why:* every change to the interface touches clients that do not use it.
  *Fix:* split it by client need.
- **GEN-SO6 Hard-wired details.** Policy code constructs or reaches globally for a database,
  network client, file system, clock, random source or environment. *Why:* it cannot be
  tested or reused without the real thing. *Fix:* pass the dependency in, behind the narrowest
  interface the policy needs.

## DRY and duplication

- **GEN-DR1 Copied block.** The same logic, possibly with renamed variables, in two or more
  places. *Why:* fixes land in one copy and the copies drift. *Fix:* extract one function or
  type and call it from each place; cite every copy.
- **GEN-DR2 Scattered rule.** One business rule, validation, limit, format or constant is
  encoded separately in several places. *Why:* the places disagree after the first change.
  *Fix:* one named definition that every use refers to.
- **GEN-DR3 Hand-synchronised structures.** Parallel lists, enums, switch statements or type
  hierarchies that must be edited together. *Why:* the coupling is invisible until one is
  missed. *Fix:* derive one from the other, or merge them.
- **GEN-DR4 Reinvented facility.** Code re-implements what the codebase, its framework or the
  standard library already provides. *Why:* a second, less tested version of the same thing.
  *Fix:* use the existing facility; name it in the fix.
- **GEN-DR5 Duplicated test setup.** The same arrangement repeated across tests. *Why:* a
  change to the setup touches every test. *Fix:* a shared builder or fixture, keeping each
  test's distinctive values visible in the test.

Incidental similarity — code that looks alike but encodes different knowledge — is not a
finding, nor is duplication that deliberately keeps two modules independent.

## Architecture and layering

- **GEN-AR1 Inward dependency broken.** Core or domain code imports infrastructure, UI,
  transport or framework code. *Why:* the core cannot change, be tested or be reused without
  its outer layers. *Fix:* the core defines the interface it needs; the outer layer
  implements it.
- **GEN-AR2 Manifest contradicts the layering.** A project reference or package dependency
  runs against the intended direction. *Why:* the build permits what the design forbids, and
  the next change uses it. *Fix:* remove the reference and move the shared piece to the layer
  both may depend on.
- **GEN-AR3 Dependency cycle.** Two modules depend on each other, directly or through a chain.
  *Why:* neither can change or be understood alone. *Fix:* extract what both need, or invert
  one dependency.
- **GEN-AR4 Leaking types.** Persistence entities, request or response objects or wire formats
  travel through the core. *Why:* a storage or protocol change ripples into business logic.
  *Fix:* map at the boundary to types the core owns.
- **GEN-AR5 Logic in the wrong layer.** Business rules in controllers, handlers, views,
  scripts or queries. *Why:* the rule is duplicated by the next entry point and untestable
  without the transport. *Fix:* move it into the domain or application layer and call it.
- **GEN-AR6 Reaching past the boundary.** Callers use another module's internals rather than
  its public surface. *Why:* the module cannot change its internals safely. *Fix:* expose
  what callers need on the public surface, or move the caller's logic into the module.
- **GEN-AR7 Dumping-ground module.** A shared module of unrelated pieces that most of the
  codebase depends on. *Why:* every change to it risks everything. *Fix:* move each piece to
  the module that uses it, or to a cohesive shared module of its own.
- **GEN-AR8 Ambient state.** Global mutable state or singletons shared across modules;
  wiring scattered through the code. *Why:* hidden coupling and order-dependent behaviour.
  *Fix:* compose dependencies in one place and pass them explicitly.

## Code quality and readability

- **GEN-CQ1 Misleading name.** A name that says something other than what the code does, or
  several names for one concept. *Why:* readers act on the name. *Fix:* rename to what it
  does, consistently.
- **GEN-CQ2 Overlong or deeply nested unit.** A function long or nested enough that its steps
  cannot be seen at once. *Why:* defects hide in the branches. *Fix:* extract named steps,
  return early on guard conditions. Size figures only from tool output.
- **GEN-CQ3 Flag and long parameter lists.** Boolean parameters that switch behaviour, or long
  lists of parameters that travel together. *Why:* call sites cannot be read and arguments
  get swapped. *Fix:* separate functions per behaviour; a parameter object for values that
  travel together.
- **GEN-CQ4 Unexplained literal.** A number or string whose meaning is not evident and which
  may recur. *Why:* intent is lost and copies drift. *Fix:* a named constant.
- **GEN-CQ5 Swallowed or vague error.** An empty or overly broad catch, an ignored error
  result, an error rethrown without context. *Why:* failures surface late, far from the
  cause, or not at all. *Fix:* handle the specific error, or let it propagate with context.
- **GEN-CQ6 Dead weight.** Unreachable code, commented-out code, unused parameters, members
  or imports. *Why:* readers maintain and reason about code that does nothing. *Fix:* delete
  it; version control keeps the history.
- **GEN-CQ7 Lying or empty comment.** A comment that contradicts the code or only restates
  it; non-obvious intent left unexplained. *Why:* the reader trusts the wrong source. *Fix:*
  correct or delete the comment; explain why, not what.
- **GEN-CQ8 Hidden effect.** A getter, constructor or innocent-looking call that writes state,
  performs I/O or depends on call order. *Why:* callers cannot predict what a call does.
  *Fix:* make the effect explicit in the name and signature, or move it out.
- **GEN-CQ9 Unreleased resource.** A file, connection or lock acquired without a release on
  every path. *Why:* leaks and deadlocks under error paths. *Fix:* the language's scoped
  release construct, or a release in a finally path.
- **GEN-CQ10 Speculative generality.** Parameters, options, hooks or abstractions no caller
  uses. *Why:* cost now for a need that may never come. *Fix:* remove until a caller needs it.
- **GEN-CQ11 Evident defect.** A wrong operator or comparison, an off-by-one bound, a
  condition that is always true or false, a result that is computed and dropped. *Why:* wrong
  behaviour. *Fix:* the corrected expression, with the case it fixes.

## Security

- **GEN-SE1 Untrusted input reaches a sink.** Input from a request, file, message or user
  flows into a query, command, path, template, deserializer or outbound URL without
  validation or parameterization. *Fix:* parameterize, or validate against an allow-list at
  the boundary.
- **GEN-SE2 Missing access check.** An entry point lacks the authentication or authorization
  its neighbours apply, or an object is fetched by identifier without an ownership check.
  *Fix:* apply the project's existing check at that entry point.
- **GEN-SE3 Embedded secret.** A credential, key or token in code or configuration. Cite the
  location only. *Fix:* load it from the project's secret store or environment, and rotate it.
- **GEN-SE4 Weak cryptography or randomness.** Home-made schemes, fast hashes for passwords,
  fixed IVs or salts, non-cryptographic random values for tokens. *Fix:* the platform's
  vetted primitive for the purpose.
- **GEN-SE5 Sensitive data exposed.** Secrets or personal data in logs, error messages or
  responses. *Fix:* redact at the point of output.
- **GEN-SE6 Unsafe default.** Debug modes, permissive cross-origin rules, disabled certificate
  validation or over-broad permissions in configuration that ships. *Fix:* the safe setting,
  with the unsafe one confined to local development.

A weakness needs a reachable path from untrusted input; when the path cannot be traced, the
finding is uncertain.

## Testing

- **GEN-TE1 Untested core.** Core logic, an error path or a boundary condition with no test.
  *Fix:* name the behaviour to test and where. Coverage figures only from tool output.
- **GEN-TE2 Test that cannot fail.** No assertion, an assertion on a value the test itself
  set, or an assertion that holds for any result. *Fix:* assert the behaviour's observable
  outcome.
- **GEN-TE3 Testing the mocks.** Mocks so broad, or assertions so tied to internal calls, that
  the test checks the implementation rather than the behaviour. *Fix:* assert outcomes; mock
  only at the boundaries.
- **GEN-TE4 Flaky dependence.** Reliance on wall-clock time, randomness, ordering, network,
  shared files or state left by another test. *Fix:* inject the clock or seed, isolate the
  state, fake the network.
- **GEN-TE5 Muddled test.** Several behaviours in one test, or an arrangement so long the
  behaviour under test is hidden. *Fix:* one behaviour per test, with a name that states it.
- **GEN-TE6 Configuration that hides failure.** Skipped suites, tests excluded without
  reason, errors swallowed by the runner, thresholds that never fail. *Fix:* restore the
  check, or document why it is off.

## Performance

- **GEN-PE1 Growing nested work.** Nested iteration or repeated linear search over
  collections that grow with input. *Fix:* index once in a keyed structure.
- **GEN-PE2 Per-item remote call.** A query or remote call inside a loop (N+1). *Fix:* batch,
  or fetch the set once.
- **GEN-PE3 Blocking on an asynchronous path.** A blocking call, or a synchronous wait on
  asynchronous work, on a path meant to stay responsive. *Fix:* await or offload it.
- **GEN-PE4 Unbounded memory.** Caches or buffers with no limit; whole datasets loaded where
  streaming would serve. *Fix:* a bound and an eviction rule, or streaming.
- **GEN-PE5 Resource churn.** Clients, connections or handles created per call instead of
  reused. *Fix:* create once and share, within the resource's lifetime rules.

A performance finding says why the path matters — an entry point, a loop over request data,
a hot path the project documents. Timings and allocation figures only from tool output.
