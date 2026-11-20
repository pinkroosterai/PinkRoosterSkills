# C# reference

C# and .NET idioms and smells per review angle, with the tools that measure them. It
refines the general checklist; an item that sharpens a general one names its `GEN-` ID. Cite
an item by its ID (`CS-PE1`) in a candidate's rule line.

**Checked:** 2026-11-20, against Microsoft Learn (full list under [Sources](#sources)).
**Targets:** .NET 10 (LTS) with C# 14 as the baseline; .NET 11 (STS) with C# 15. Items that
need a newer version than a project may use carry a mark: `(C# 15+)`, `(C# 14+)`, `(.NET 8+)`.

## Contents

- [Every angle](#every-angle)
- [SOLID](#solid)
- [DRY and duplication](#dry-and-duplication)
- [Architecture and layering](#architecture-and-layering)
- [Code quality and readability](#code-quality-and-readability)
- [Security](#security)
- [Testing](#testing)
- [Performance](#performance)
- [Tools and metrics](#tools-and-metrics)
- [Sources](#sources)

## Every angle

- **CS-E1 Read the version before any version-marked item.** The target framework is
  `<TargetFramework>` or `<TargetFrameworks>` in `*.csproj` or `Directory.Build.props`. The
  default C# version follows it: C# 14 for `net10.0`, C# 15 for `net11.0`. A `<LangVersion>`
  overrides it; a language version newer than the target framework's is unsupported. Apply a
  marked item only when the declared version reaches it; otherwise the candidate is
  uncertain (GEN-E4). *Source:* Configure C# language version; What's new in C# 14; What's
  new in C# 15.
- **CS-E2 Version marks.** `(C# 15+)`: union types, closed hierarchies, collection expression
  arguments, extension indexers, labeled `break`/`continue`. `(C# 14+)`: extension members,
  null-conditional assignment, `field`-backed properties, `partial` events and constructors.
  `(C# 8+)`: nullable reference types, `using` declarations. Never recommend the C# 15 memory-safety feature: it needs `<LangVersion>preview</LangVersion>`.
  *Source:* C# version history; What's new in C# 15.
- **CS-E3 Supported runtimes.** As checked, .NET 11 and .NET 10 are the supported versions,
  both until November 2028. A project targeting an older .NET is named as a version gap in
  the review document, not raised as a finding. *Source:* Releases and support for .NET.
- **CS-E4 The project's analyzer configuration is a project rule (GEN-E2).** `.editorconfig`
  and `.globalconfig` entries (`dotnet_diagnostic.<ID>.severity`, naming rules),
  `<Nullable>`, `<AnalysisLevel>`, `<AnalysisMode>`, `<TreatWarningsAsErrors>` and
  `#pragma warning disable` decide what the project accepts. A rule the project set to
  `none` or suppressed is not a finding. *Source:* Code analysis overview § Suppress a
  warning, § Enable additional rules.
- **CS-E5 Newer syntax is not a finding by itself.** Code that compiles on the declared
  version and reads clearly is not raised because a newer construct exists, unless a project
  rule requires that construct. Formatting and layout are the formatter's (see
  [Tools and metrics](#tools-and-metrics)).

## SOLID

- **CS-SO1 Many injected dependencies.** A constructor taking many services. *Why:* the DI
  guidelines name it a sign that the class has too many responsibilities. *Fix:* move groups
  of responsibilities, with the dependencies they use, into new classes. Refines GEN-SO1; no
  count is a threshold. *Source:* DI guidelines § Design services for dependency injection.
- **CS-SO2 Constructed or static dependencies.** A service that `new`s the services it
  depends on, or keeps stateful static classes and members. *Why:* couples it to one
  implementation, scatters configuration, and blocks substitution in tests. *Fix:* constructor
  injection of the abstraction, registered in the composition root. Refines GEN-SO6.
  *Source:* DI guidelines § Design services for dependency injection; .NET dependency
  injection overview.
- **CS-SO3 Service locator.** `GetService`/`GetRequiredService` on an injected
  `IServiceProvider` outside the composition root, or an injected factory that resolves
  dependencies at run time. *Why:* hides what the class needs and mixes inversion-of-control
  strategies. *Fix:* inject the dependency itself. Refines GEN-SO6. *Source:* DI guidelines
  § Recommendations.
- **CS-SO4 Ambient clock.** Policy code reading `DateTime.Now`, `DateTime.UtcNow` or
  `DateTimeOffset.UtcNow`. *Why:* the behaviour cannot be tested at a chosen time. *Fix:*
  inject `TimeProvider` `(.NET 8+)`; on an older framework, a seam interface. Refines GEN-SO6.
  *Source:* TimeProvider overview; Unit testing best practices § Handle stub static references
  with seams.
- **CS-SO5 Recurring switch over a closed set of subtypes** `(C# 15+)`. The same `switch`
  over the direct subtypes of one base, repeated where variants are added. *Why:* a missed arm
  is a silent defect. *Fix:* a `closed` base class or a `union` type, so the compiler checks
  each `switch` expression for exhaustiveness. A `closed` class is implicitly abstract and
  can be derived from only in its own assembly, so it fits only when the base is never
  instantiated and every direct subtype lives there; it covers direct descendants only, so
  mark intermediate ones too. Below C# 15, use GEN-SO3's fix. *Source:* What's new in C# 15
  § Union types, § Closed hierarchies.

Liskov substitution and interface segregation have no C#-specific item here; GEN-SO4 and
GEN-SO5 apply as written.

## DRY and duplication

- **CS-DR1 Hand-written argument guards.** Repeated `if (x is null) throw new
  ArgumentNullException(...)` and range checks. *Why:* the checks dominate small members and
  prevent inlining; the helpers are simpler. *Fix:* the static throw helpers
  (`ArgumentNullException.ThrowIfNull`, `ArgumentException.ThrowIfNullOrEmpty`,
  `ArgumentOutOfRangeException.ThrowIfNegative` and the rest), where the target framework has
  them; analyzer rules CA1510–CA1513 find the candidates. Refines GEN-DR4. *Source:*
  Exception best practices § Use exception builder methods; MS Learn: CA1510.
- **CS-DR2 One exception built in several places.** The same exception type and message
  constructed in several members. *Why:* the same construction code repeated. *Fix:*
  one builder method that creates and returns it.
  Refines GEN-DR1. *Source:* Exception best practices § Use exception builder methods.
- **CS-DR3 Home-grown clock abstraction** `(.NET 8+)`. A project-defined `IClock` or
  `IDateTimeProvider` where `TimeProvider` is available. *Why:* GEN-DR4's second, less tested
  version of a platform facility. *Fix:* `TimeProvider`, with
  `FakeTimeProvider` in tests. Not a finding where a project rule keeps its own. Refines
  GEN-DR4. *Source:* What's new in the .NET 8 runtime § Time abstraction; TimeProvider
  overview.
- **CS-DR4 Copied tests that differ only in data.** Test methods repeating one arrangement
  with other inputs. *Why:* a change to the arrangement touches every copy, and a failure
  does not say which case broke. *Fix:* one parameterized test (xUnit `[Theory]` with
  `[InlineData]`, or
  the test framework's data rows). Refines GEN-DR5. *Source:* Unit testing best practices
  § Avoid multiple Act tasks.
- **CS-DR5 The same subtype switch kept in step by hand** `(C# 15+)`. Several `switch`
  statements over one closed set of subtypes edited together. *Why:* a missed one is a silent
  defect. *Fix:* a `closed` hierarchy or `union` so a missing arm is reported at compile time;
  `closed` fits only when the base is never instantiated and every direct subtype is in its
  assembly. Below C# 15, GEN-DR3's fix. *Source:* What's new
  in C# 15 § Union types, § Closed hierarchies.

## Architecture and layering

Apply these only where the codebase evidently intends the layering they assume (see the
angle checklist).

- **CS-AR1 Core project references outer layers.** In a core/infrastructure/UI split, the
  core project holds a `<ProjectReference>` to the infrastructure or UI project, or a
  `<PackageReference>` to an implementation package such as a data-access provider. *Why:*
  the core should depend on nothing infrastructural; infrastructure implements interfaces the
  core defines. *Fix:* move the interface into the core and the implementation out. Refines
  GEN-AR1, GEN-AR2. *Source:* Common web application architectures § Clean architecture.
- **CS-AR2 Infrastructure used outside the composition root.** UI-layer code instantiating or
  statically calling infrastructure types instead of the core's interfaces. *Why:* the
  implementation can no longer be swapped for tests or a new requirement. *Fix:* limit
  references to infrastructure types to the composition root (`Program.cs` or `Startup`).
  Refines GEN-AR6. *Source:* Common web application architectures § Clean architecture.
- **CS-AR3 Captive dependency.** A singleton that takes a scoped service, or a scoped service
  resolved outside any scope. *Why:* the shorter-lived service lives as long as the singleton.
  *Fix:* align the lifetimes; scope validation (`validateScopes: true`) reports the mismatch.
  *Source:* DI guidelines § Captive dependency, § Scoped service as singleton.
- **CS-AR4 Composition outside the root.** `BuildServiceProvider` called while registering
  services, or `IApplicationBuilder.ApplicationServices` kept in a static for use elsewhere.
  *Why:* mixing static access with DI loses DI's benefits. *Fix:* registration overloads that receive the `IServiceProvider`; constructor injection.
  Refines GEN-AR8. *Source:* DI guidelines § Recommendations.
- **CS-AR5 Data and configuration in the container.** Per-user data or "data holder" objects
  registered as services, or configuration read ad hoc. *Fix:* the options pattern for
  configuration; request the actual item through DI. *Source:* DI guidelines
  § Recommendations.
- **CS-AR6 Unpinned language version in a manifest.** `<LangVersion>latest</LangVersion>`, or
  a version newer than the target framework's default. *Why:* `latest` changes with the
  installed compiler, so builds differ between machines; a newer version than the framework's
  is unsupported. *Fix:* drop `LangVersion` and let the framework decide, or pin a supported
  number. *Source:* Configure C# language version.
- **CS-AR7 Shared build settings repeated per project.** The same property (target framework,
  language version, nullable context, analysis level) set in many project files. *Fix:* one
  `Directory.Build.props` above them. *Source:* Configure C# language version § Configure
  multiple projects.

## Code quality and readability

- **CS-CQ1 General catch.** `catch (Exception)`, `catch (SystemException)` or a bare `catch`
  without an exception filter, that does not rethrow. *Why:* hides run-time problems and
  makes debugging harder. *Fix:* catch the specific exception, or rethrow as the last
  statement. Refines GEN-CQ5. *Source:* MS Learn: CA1031; C# coding conventions § Language
  guidelines.
- **CS-CQ2 Rethrow that loses the stack.** `throw ex;` inside a `catch`. *Why:* the stack
  trace restarts at the rethrow and the calls between it and the original throw are lost.
  *Fix:* `throw;`, or `ExceptionDispatchInfo.Capture` when rethrowing outside the handler.
  Refines GEN-CQ5. *Source:* Exception best practices § Capture and rethrow exceptions
  properly (CA2200).
- **CS-CQ3 `async void` outside event handlers.** *Why:* its exceptions cannot be caught
  by the caller, it is hard to test, and callers cannot tell it is asynchronous. *Fix:*
  return `Task`. *Source:* Async scenarios § Return 'async void' only from event handlers.
- **CS-CQ4 Disposal gaps.** A local `IDisposable` not disposed on every path; a
  `try`/`finally` whose only job is `Dispose`; a class holding a disposable field without
  implementing `IDisposable` or `IAsyncDisposable`. *Why:* the resource is released at some
  indeterminate time, or never. *Fix:* a `using` statement, or a `using` declaration
  `(C# 8+)`; implement the interface and dispose the field. A class must not dispose a dependency the DI
  container gave it. Refines GEN-CQ9. *Source:* MS Learn: CA2000, CA1001; C# coding
  conventions § `try-catch` and `using` statements; DI guidelines § General `IDisposable`
  guidelines.
- **CS-CQ5 Silenced null analysis** `(C# 8+)`. `!` used to quiet warnings, `#nullable disable` regions,
  or `<Nullable>` off in one project while the rest enable it. *Why:* `!` has no run-time
  effect; each one is a place the compiler can no longer protect. *Fix:* a null check, a
  `?` annotation, or a nullable-analysis attribute such as `[NotNullWhen(true)]`. *Source:*
  Resolve nullable warnings § Adjust annotations; Nullable reference types § Override the
  warnings with `!`; Null-forgiving operator.
- **CS-CQ6 Exceptions from unexpected places.** Throwing from `Equals`, `GetHashCode`,
  `ToString`, static constructors or equality operators, or from a `finally` block. *Why:*
  callers do not expect these to fail. *Fix:* remove the throw from these members and
  from `finally`. *Source:*
  Exception best practices § Don't raise exceptions from unexpected places (CA1065), § Don't
  raise exceptions in finally clauses (CA2219).
- **CS-CQ7 Late argument validation.** A task-returning method that validates arguments
  inside its asynchronous part, so the exception appears only when the task is awaited.
  *Fix:* validate before the first `await`. *Source:* Exception best practices § Throw
  argument validation exceptions synchronously.
- **CS-CQ8 Wrong exception type.** Throwing a general type (`Exception`, `SystemException`,
  `ApplicationException`), a runtime-reserved type (`NullReferenceException`,
  `IndexOutOfRangeException` and the like), or a new custom type where a predefined one fits.
  *Why:* callers must catch everything, and the original error is hard to find. *Fix:*
  `ArgumentException` or a derived type (`ArgumentNullException`,
  `ArgumentOutOfRangeException`) for bad arguments, `InvalidOperationException` for a wrong
  object state, `ObjectDisposedException` after disposal; a custom type only when none
  applies. *Source:* Exception best practices § Use predefined exception types; MS Learn:
  CA2201.
- **CS-CQ9 Names against the project's conventions.** Where `.editorconfig` naming rules
  (IDE1006) or the codebase's dominant pattern (GEN-E1) decide, they win. Otherwise the
  defaults are PascalCase for types and members, an `I` prefix on interfaces and an `Async`
  suffix on asynchronous methods. Field prefixes (`_`, `s_`) are a team convention the
  sources disagree on; never raise one without a project rule. Refines GEN-CQ1. *Source:* C#
  identifier naming § Naming conventions; Code-style naming rules § Default naming styles;
  Async scenarios § Add "Async" suffix; Framework Design Guidelines § Names of fields.
- **CS-CQ10 Flag or `goto` to leave nested loops** `(C# 15+)`. *Why:* the flag is checked
  at every level and hides the intended control flow. *Fix:* labeled `break` or
  `continue` on the target loop; style rule IDE0410 reports it. *Source:* What's new in C# 15
  § Labeled `break` and `continue`.

## Security

- **CS-SE1 SQL from strings.** `CommandText` built by concatenation, interpolation or
  `String.Format` from values not fixed at compile time. *Fix:* a parameterized command or a
  stored procedure with parameters. Refines GEN-SE1. *Source:* MS Learn: CA2100, CA3001.
- **CS-SE2 Process started from request input.** *Fix:* do not start processes from user
  input; otherwise validate against a known safe set of characters and length. Refines
  GEN-SE1. *Source:* MS Learn: CA3006.
- **CS-SE3 Insecure deserializer.** `BinaryFormatter`, `NetDataContractSerializer` or
  `LosFormatter`. *Why:* insecure and cannot be made secure; from .NET 9 the in-box
  `BinaryFormatter` throws on use. *Fix:* a safe serializer that never lets the payload choose
  the type. Refines GEN-SE1. *Source:* MS Learn: CA2300; BinaryFormatter security guide.
- **CS-SE4 Predictable randomness.** `System.Random` producing a security-sensitive value.
  *Fix:* `RandomNumberGenerator`. Refines GEN-SE4. *Source:* MS Learn: CA5394.
- **CS-SE5 Broken algorithms.** `MD5`, `DES` or `RC2`. *Fix:* a current algorithm for the
  purpose (the rule's examples use SHA-256 and AES). Refines GEN-SE4. *Source:* MS Learn:
  CA5351.
- **CS-SE6 Certificate validation disabled.** A `ServerCertificateValidationCallback` that
  always returns `true`. Refines GEN-SE6. *Source:* MS Learn: CA5359.
- **CS-SE7 Vulnerable packages.** Raise only from NuGet audit output in the brief (warnings
  NU1901–NU1904 from a restore, or `dotnet package list --vulnerable`). *Source:* NuGet
  auditing § Warning codes.

## Testing

- **CS-TE1 Logic in tests.** `if`, `while`, `for`, `switch` or string building inside a test.
  *Why:* logic makes a bug in the test itself likely, and a test that cannot be trusted has
  no value. *Fix:* split into several plain tests.
  Refines GEN-TE2, GEN-TE5. *Source:* Unit testing best practices § Avoid coding logic in unit
  tests.
- **CS-TE2 Several acts in one test.** *Why:* a failure does not show which act failed, and
  asserts after the first failure never run. *Fix:* one act per test, a parameterized test for
  input variants. Refines GEN-TE5. *Source:* Unit testing best practices § Avoid multiple Act
  tasks.
- **CS-TE3 Real clock in tested code.** *Why:* the result depends on when the suite runs.
  *Fix:* inject `TimeProvider` and use
  `FakeTimeProvider` in the test `(.NET 8+)`; never mix `TimeProvider.System` with the fake in
  one test. Refines GEN-TE4. *Source:* Unit testing best practices § Handle stub static
  references with seams; Testing with FakeTimeProvider § Best practices.
- **CS-TE4 Private methods tested directly.** *Why:* a correct private result does not show
  that the public caller uses it correctly. *Fix:* test the public method that calls them.
  Refines GEN-TE3. *Source:* Unit testing best practices § Validate private methods with
  public methods.
- **CS-TE5 Infrastructure in unit tests.** Unit tests that need a database, file system or
  network. *Why:* slow and brittle tests. *Fix:* inject the dependency and fake it; keep integration tests in a separate
  project. Refines GEN-TE4. *Source:* Unit testing best practices § Avoid infrastructure
  dependencies.
- **CS-TE6 Names that hide the behaviour.** Where the codebase has no naming pattern of its
  own, a test name states the method, the scenario and the expected behaviour, so a failure
  names the scenario that broke. Minor.
  Refines GEN-TE5. *Source:* Unit testing best practices § Follow test naming standards.

## Performance

- **CS-PE1 Blocking on asynchronous work.** `.Result`, `.Wait()`,
  `.GetAwaiter().GetResult()`, `Task.WaitAll`, `Task.WaitAny` or `Thread.Sleep` on an
  asynchronous path. *Why:* deadlock under a single-threaded synchronization context and
  thread-pool starvation in ASP.NET Core. *Fix:* `await`, `Task.WhenAll`, `Task.WhenAny`,
  `Task.Delay`. Refines GEN-PE3. *Source:* Async scenarios § Review considerations; Common
  async bugs § Deadlocks from blocking on async code; ASP.NET Core best practices § Avoid
  blocking calls.
- **CS-PE2 Synchronous calls in asynchronous methods.** A task-returning method calling a
  synchronous API that has an `Async` counterpart, or ASP.NET Core code calling `Task.Run`
  and awaiting it at once. *Why:* the synchronous call blocks a thread; the `Task.Run` adds
  thread-pool scheduling without preventing the block. *Fix:* await the asynchronous API;
  drop the `Task.Run`. Refines
  GEN-PE3. *Source:* MS Learn: CA1849; ASP.NET Core best practices § Avoid blocking calls.
- **CS-PE3 Cancellation not forwarded.** A method with a `CancellationToken` calling methods
  that accept one without passing it. *Why:* cancelled work keeps running. *Fix:* forward the
  token. *Source:* MS Learn: CA2016.
- **CS-PE4 `HttpClient` per request.** *Why:* each instance has its own connection pool;
  under load the ports run out. *Fix:* a long-lived client with `PooledConnectionLifetime`
  set, or clients from `IHttpClientFactory`. Refines GEN-PE5. *Source:* HttpClient guidelines
  § Recommended use, § Pooled connections.
- **CS-PE5 Deferred sequence enumerated twice.** An `IEnumerable<T>` from a query or iterator
  enumerated more than once. *Why:* the work, possibly a database query, runs each time.
  *Fix:* materialize once. Refines GEN-PE1, GEN-PE2. *Source:* MS Learn: CA1851.
- **CS-PE6 Strings built in loops.** Repeated concatenation inside a loop over much text.
  *Fix:* `StringBuilder`. *Source:* C# coding conventions § String data.
- **CS-PE7 Large responses buffered.** Downloading 50 MB or more through the buffering
  `HttpClient` methods. *Fix:* stream the content (`GetStreamAsync`, or
  `HttpCompletionOption`). Refines GEN-PE4. *Source:* HttpClient class § Buffering and request
  lifetime.
- **CS-PE8 Disposable transients from the root container.** *Why:* the container holds every
  instance until it is disposed, a memory leak. *Fix:* resolve within a scope, or use a
  factory and dispose the instance. Refines GEN-PE4. *Source:* DI guidelines § Disposable
  transient services captured by container.

## Tools and metrics

**Detect.** The SDK analyzers (CA quality rules, IDE style rules) are on by default for
.NET 5 and later unless `<EnableNETAnalyzers>false</EnableNETAnalyzers>`. Read `<AnalysisLevel>`,
`<AnalysisMode>`, `<EnforceCodeStyleInBuild>`, `<TreatWarningsAsErrors>` and
`<CodeAnalysisTreatWarningsAsErrors>` in the project files and `Directory.Build.props`;
`dotnet_diagnostic` severities in `.editorconfig` and `.globalconfig`; a `CodeMetricsConfig.txt`
included as `AdditionalFiles`; and third-party analyzer `PackageReference`s (StyleCop,
Roslynator, Meziantou, xUnit analyzers, SonarAnalyzer). Cite no third-party rule: none is
sourced here. *Source:* Code analysis overview.

**Run, under the review boundary:**

| Command | Status | Why |
|---|---|---|
| `dotnet build --no-restore` | Run only when `obj/project.assets.json` exists and the project files, `Directory.Build.props`/`.targets` and custom targets have been inspected | Writes `bin/` and `obj/`; runs the project's MSBuild targets, analyzers and source generators. Without `--no-restore` it restores, which reaches package feeds |
| `dotnet format --verify-no-changes --no-restore` | Run after the same inspection | Exits non-zero if any file would be formatted, without formatting it; it still compiles and runs the project's analyzers. Plain `dotnet format` rewrites sources — never run it |
| `dotnet test` | Not run unless the tests' effects were inspected | Executes test code |
| `dotnet package list --vulnerable` | Not run unless the developer allows network access | Queries the audit sources over the network |

IDE style diagnostics appear in a command-line build only when `EnforceCodeStyleInBuild` is
true and the rule has warning or error severity. Report formatter output as tool metrics,
never as findings. *Source:* dotnet build § Implicit restore; dotnet format § Options;
dotnet restore; dotnet package list § Options; Code analysis overview § Code-style analysis.

**Metrics.** The metric rules are off by default, and `AnalysisMode` `All` or
`AnalysisLevel` `latest-all` does not enable them; they run only when the project sets a
`dotnet_diagnostic` severity for them. Never enable them for the review. Read
`CodeMetricsConfig.txt` first: it overrides these documented defaults.

| Rule | Metric | Documented default |
|---|---|---|
| CA1502 | Cyclomatic complexity of a method | reports above 25 |
| CA1505 | Maintainability index | reports below 10 |
| CA1506 | Class coupling (unique type references) | above 95 for types, 40 for other symbols |
| CA1501 | Depth of inheritance | reports at 5 or more levels |

When they did not run, complexity, maintainability and coupling read "not measured".
*Source:* MS Learn: CA1501, CA1502, CA1505, CA1506; Code analysis overview § Enable
additional rules.

## Sources

Microsoft Learn pages, read 2026-11-20: whole pages or the cited sections. "MS Learn: CAxxxx" is
`https://learn.microsoft.com/dotnet/fundamentals/code-analysis/quality-rules/caxxxx`.

- C# coding conventions — https://learn.microsoft.com/dotnet/csharp/fundamentals/coding-style/coding-conventions
- C# identifier naming — https://learn.microsoft.com/dotnet/csharp/fundamentals/coding-style/identifier-names
- Framework Design Guidelines, names of type members — https://learn.microsoft.com/dotnet/standard/design-guidelines/names-of-type-members
- Code-style naming rules — https://learn.microsoft.com/dotnet/fundamentals/code-analysis/style-rules/naming-rules
- Configure C# language version — https://learn.microsoft.com/dotnet/csharp/language-reference/configure-language-version
- C# version history — https://learn.microsoft.com/dotnet/csharp/whats-new/csharp-version-history
- What's new in C# 14 — https://learn.microsoft.com/dotnet/csharp/whats-new/csharp-14
- What's new in C# 15 — https://learn.microsoft.com/dotnet/csharp/whats-new/csharp-15
- Releases and support for .NET — https://learn.microsoft.com/dotnet/core/releases-and-support
- Code analysis overview — https://learn.microsoft.com/dotnet/fundamentals/code-analysis/overview
- Async scenarios — https://learn.microsoft.com/dotnet/csharp/asynchronous-programming/async-scenarios
- Common async bugs — https://learn.microsoft.com/dotnet/standard/asynchronous-programming-patterns/common-async-bugs
- ASP.NET Core best practices — https://learn.microsoft.com/aspnet/core/fundamentals/best-practices
- Exception best practices — https://learn.microsoft.com/dotnet/standard/exceptions/best-practices-for-exceptions
- Nullable reference types — https://learn.microsoft.com/dotnet/csharp/fundamentals/null-safety/nullable-reference-types
- Resolve nullable warnings — https://learn.microsoft.com/dotnet/csharp/fundamentals/null-safety/common-tasks/resolve-warnings
- Null-forgiving operator — https://learn.microsoft.com/dotnet/csharp/language-reference/operators/null-forgiving
- DI guidelines — https://learn.microsoft.com/dotnet/core/extensions/dependency-injection-guidelines
- .NET dependency injection overview — https://learn.microsoft.com/dotnet/core/extensions/dependency-injection/overview
- Common web application architectures — https://learn.microsoft.com/dotnet/architecture/modern-web-apps-azure/common-web-application-architectures
- TimeProvider overview — https://learn.microsoft.com/dotnet/standard/datetime/timeprovider-overview
- Testing with FakeTimeProvider — https://learn.microsoft.com/dotnet/core/extensions/timeprovider-testing
- What's new in the .NET 8 runtime — https://learn.microsoft.com/dotnet/core/whats-new/dotnet-8/runtime
- Unit testing best practices — https://learn.microsoft.com/dotnet/core/testing/unit-testing-best-practices
- HttpClient guidelines — https://learn.microsoft.com/dotnet/fundamentals/networking/http/httpclient-guidelines
- HttpClient class — https://learn.microsoft.com/dotnet/api/system.net.http.httpclient
- BinaryFormatter security guide — https://learn.microsoft.com/dotnet/standard/serialization/binaryformatter-security-guide
- NuGet auditing — https://learn.microsoft.com/nuget/concepts/auditing-packages
- dotnet build — https://learn.microsoft.com/dotnet/core/tools/dotnet-build
- dotnet format — https://learn.microsoft.com/dotnet/core/tools/dotnet-format
- dotnet restore — https://learn.microsoft.com/dotnet/core/tools/dotnet-restore
- dotnet package list — https://learn.microsoft.com/dotnet/core/tools/dotnet-package-list
