# Python reference

Python idioms and smells per review angle, with the tools that measure them. It refines the
general checklist; an item that sharpens a general one names its `GEN-` ID. Cite an item by
its ID (`PY-CQ2`) in a candidate's rule line.

**Checked:** 2026-11-20, against docs.python.org, peps.python.org, typing.python.org, the
devguide and the tools' own documentation (full list under [Sources](#sources)).
**Targets:** the supported versions, Python 3.11 to 3.15. Items that need a newer minimum
than 3.11 carry it: `(3.12+)`, `(3.13+)`, `(3.14+)`, `(3.15+)`.

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

- **PY-E1 Read the version before any version-marked item.** The project declares it in
  `requires-python` under `[project]` in `pyproject.toml`; its lower bound decides which marked
  items apply. Tools may check another version: Ruff's `target-version` takes precedence over
  `requires-python`; mypy's `python_version` and pyright's `pythonVersion` default to the
  interpreter running them. When they disagree or nothing is declared, a version-marked
  candidate is uncertain (GEN-E4). *Source:* PEP 621 § `requires-python`; Ruff settings
  § `target-version`; mypy configuration § `python_version`; pyright configuration.
- **PY-E2 Version marks.** `(3.12+)`: type parameter syntax and the `type` statement,
  `@typing.override`, `itertools.batched`. `(3.13+)`: `@warnings.deprecated`, `TypeIs`,
  `ReadOnly`. `(3.14+)`: deferred evaluation of annotations, `except A, B:` without
  parentheses (when there is no `as`), the `SyntaxWarning` for control flow leaving `finally`, template strings.
  `(3.15+)`: `lazy` imports, `frozendict`, `sentinel`, UTF-8 as the default encoding,
  unpacking in comprehensions. Unmarked items work on 3.11 (`Self`, `Never`, `assert_never`,
  `asyncio.TaskGroup`, `datetime.UTC`). *Source:* What's new in Python 3.12, 3.14, 3.15;
  typing module; warnings module.
- **PY-E3 Supported versions.** As checked, 3.11 to 3.15 are supported; 3.10 reached end of
  life on 2026-10-01. A project pinned to an unsupported version is named as a version gap in
  the review document, not raised as a finding. *Source:* Status of Python versions.
- **PY-E4 The project's own style guide and tool configuration win (GEN-E2).** PEP 8 itself
  says a project-specific guide takes precedence. Read `[tool.ruff]` (or `ruff.toml`,
  `.ruff.toml`), `[tool.mypy]` (or `mypy.ini`, `.mypy.ini`, `setup.cfg`) and `[tool.pyright]`
  (or `pyrightconfig.json`, which wins over `pyproject.toml`). A rule the project disabled or
  suppressed is not a finding. *Source:* PEP 8 § A Foolish Consistency is the Hobgoblin of
  Little Minds; Ruff settings; mypy configuration; pyright configuration.
- **PY-E5 Newer syntax is not a finding by itself.** Code that runs on the declared version
  and reads clearly is not raised because a newer construct exists, unless a project rule
  requires it. Formatting is the formatter's (see [Tools and metrics](#tools-and-metrics)).

## SOLID

- **PY-SO1 Parameters typed with concrete classes the function barely uses.** A function
  annotated to take a concrete class, or `list`/`dict`, where it uses a small part. *Why:*
  callers cannot pass another implementation, and tests need the real class. *Fix:* annotate
  the parameter with an abstract type (`Iterable`, `Mapping`, `Sequence`) or a
  `typing.Protocol` that lists only what the function uses. Refines GEN-SO5, GEN-SO6.
  *Source:* Typing best practices § Arguments and return types; typing module § `Protocol`.
- **PY-SO2 Union return types.** A function returning `A | B` that every caller must
  `isinstance`-check. *Why:* the checks spread to every call site. *Fix:* one return type, or
  separate functions. Refines GEN-SO3. *Source:* Typing best practices § Arguments and return
  types.
- **PY-SO3 Overrides nobody checks** `(3.12+)`. A subclass method meant to override a base
  method, without `@typing.override`. *Why:* when the base method is renamed or removed, the
  subclass method silently stops overriding. *Fix:* `@override`, so the type checker reports
  a method that overrides nothing; there is no run-time check. Refines GEN-SO4. *Source:*
  typing module § `override`; What's new in Python 3.12.
- **PY-SO4 Open-ended dispatch over a closed set.** A recurring `match` or `isinstance` chain
  over a known union whose last branch falls through silently. *Why:* a new member of the
  union reaches the fallback unnoticed. *Fix:* end the chain with `assert_never(value)`, so the
  type checker reports an unhandled member. Refines GEN-SO3. *Source:* typing module
  § `assert_never`.

## DRY and duplication

- **PY-DR1 Hand-rolled standard facilities.** A memo dictionary where `functools.cache` or
  `lru_cache` serves; a chunking loop where `itertools.batched` `(3.12+)` serves; a hand-made
  UTC `tzinfo` where `datetime.UTC` serves. *Why:* a second, less tested version of a library
  feature. *Fix:* the library facility. Refines GEN-DR4. *Source:* functools module; What's
  new in Python 3.12; datetime module.
- **PY-DR2 One type spelled out repeatedly.** The same long union or generic annotation
  repeated across signatures. *Why:* every copy changes together. *Fix:* one alias; with the
  `type` statement `(3.12+)`. Refines GEN-DR2. *Source:* typing module § Type aliases; What's
  new in Python 3.12 (PEP 695).
- **PY-DR3 Copied test methods for each input.** Test methods identical except for
  parameters. *Why:* every copy changes with the arrangement. *Fix:* one test looping over the
  cases inside `self.subTest(...)`, which reports each failing case by its parameters; or the
  test runner's own parameterization where the project uses one (pytest:
  `@pytest.mark.parametrize`). Refines GEN-DR5. *Source:* unittest module § Distinguishing
  test iterations using subtests; pytest: How to parametrize fixtures and test functions.
- **PY-DR4 Hand-made sentinels** `(3.15+)`. Several modules defining their own
  `_MISSING = object()` markers. *Fix:* the built-in `sentinel`, which keeps identity on copy,
  pickles and works in type expressions. Refines GEN-DR4. *Source:* What's new in Python 3.15
  (PEP 661).

## Architecture and layering

- **PY-AR1 Reaching into internals.** Importing another module's `_private` names, or using
  a name a module merely imported (`from pkg.mod import os`). *Why:* PEP 8 treats undocumented
  and underscore names, and imported names, as internal; they change without notice. *Fix:*
  import from the module that defines the public name, or expose what callers need on the
  public surface. Refines GEN-AR6. *Source:* PEP 8 § Public and Internal Interfaces.
- **PY-AR2 Undeclared public surface.** A package used by other packages with no `__all__`
  and no leading underscores on internal names. *Why:* callers cannot tell what is safe to
  use. *Fix:* declare `__all__` and prefix internal names. Minor. Refines GEN-AR6. *Source:*
  PEP 8 § Public and Internal Interfaces.
- **PY-AR3 Import cycle hidden by local imports.** An import moved into a function to dodge
  a circular import. *Why:* the modules still depend on each other; the cycle fails as soon as
  one uses `from module import name` at the top. *Fix:* break the cycle (GEN-AR3). *Source:*
  Programming FAQ § What are the best practices for using import in a module?
- **PY-AR4 Wildcard imports.** `from module import *` outside a deliberate re-export of an
  internal module's API. *Why:* it is unclear which names exist, and linters cannot find
  undefined ones. *Fix:* explicit imports. *Source:* PEP 8 § Imports; Programming FAQ
  § What are the best practices for using import in a module?
- **PY-AR5 Tools checking another version than the project declares.** `requires-python`
  missing, or Ruff `target-version`, mypy `python_version` or pyright `pythonVersion` set to
  a different version than its lower bound. *Why:* each tool checks against a different
  language. *Fix:* declare `requires-python` and drop or align the tool overrides. *Source:*
  PEP 621; Ruff settings § `target-version`; mypy configuration; pyright configuration.

## Code quality and readability

- **PY-CQ1 Catching too much.** A bare `except:`, or a `try` block much wider than the call
  that can fail. *Why:* a bare `except:` also catches `SystemExit` and `KeyboardInterrupt`; a
  wide `try` hides unrelated bugs. *Fix:* `except Exception:` at most, the specific exception
  where known, and a `try` around only the failing call. Refines GEN-CQ5. *Source:* PEP 8
  § Programming Recommendations.
- **PY-CQ2 Mutable default argument.** `def f(items=[])` or `={}`. *Why:* the default is
  created once and shared by every call that mutates it. *Fix:* default to `None` and create
  the object inside. Refines GEN-CQ11. *Source:* Programming FAQ § Why are default values
  shared between objects?
- **PY-CQ3 Wrong comparisons.** `== None` or `!= None`; `type(x) == T`. *Fix:* `is None`,
  `is not None`; `isinstance(x, T)`. *Source:* PEP 8 § Programming Recommendations.
- **PY-CQ4 Mixed returns.** Some `return` statements return a value and others return
  nothing, or the function can fall off the end. *Why:* the implicit `None` is easy to miss.
  *Fix:* return an expression everywhere, with an explicit `return None`. *Source:* PEP 8
  § Programming Recommendations.
- **PY-CQ5 Control flow leaving `finally`.** `return`, `break` or `continue` inside a
  `finally` block. *Why:* it silently cancels any active exception. From 3.14 the compiler
  emits a `SyntaxWarning`. *Fix:* move the statement out of `finally`. Refines GEN-CQ5.
  *Source:* PEP 8 § Programming Recommendations; What's new in Python 3.14 (PEP 765).
- **PY-CQ6 Resources without `with`.** A file, lock or connection opened and closed by hand.
  *Why:* the close is skipped on an exception path. *Fix:* a `with` statement. Refines
  GEN-CQ9. *Source:* PEP 8 § Programming Recommendations.
- **PY-CQ7 Names against PEP 8, where the project has no rule.** Functions and variables in
  `lower_case`, classes in `CapWords`, module constants in `UPPER_CASE`, error exceptions
  ending in `Error`, one leading underscore for non-public members; a `lambda` bound to a
  name instead of a `def`. Minor. Refines GEN-CQ1. *Source:* PEP 8 § Naming Conventions,
  § Programming Recommendations.
- **PY-CQ8 `Any` as an escape hatch.** `Any` where `object` would serve (the value is
  accepted but not used as a specific type), or spreading through signatures. *Why:* `Any` is
  assignable to and from every type, so it switches type checking off where it flows. *Fix:*
  `object` for "accepts anything"; a precise type otherwise. *Source:* Typing best practices
  § Using `Any` and `object`; typing module § `Any`.
- **PY-CQ9 Naive UTC times.** `datetime.utcnow()` or `utcfromtimestamp()`, deprecated since
  3.12. *Why:* many `datetime` methods treat naive objects as local time. *Fix:*
  `datetime.now(UTC)` and `fromtimestamp(ts, tz=UTC)`. Refines GEN-CQ11. *Source:* datetime
  module; What's new in Python 3.12 § Deprecated.
- **PY-CQ10 Text I/O without an encoding.** `open()` in text mode without `encoding=`.
  *Why:* the default changed: from 3.15 it is UTF-8 regardless of the environment, before
  that it is not, so the same code reads files differently by version. *Fix:* pass
  `encoding=` explicitly. *Source:* What's new in Python 3.15 (PEP 686).
- **PY-CQ11 Lost tasks and coroutines.** A coroutine called without `await`, or the result of
  `asyncio.create_task()` not kept. *Why:* the coroutine never runs; the event loop holds only
  weak references, so an unreferenced task may be garbage-collected before it finishes.
  *Fix:* `await` it, or keep the task in a collection until done. Refines GEN-CQ11. *Source:*
  asyncio tasks § `create_task`; Developing with asyncio § Detect never-awaited coroutines.

## Security

- **PY-SE1 SQL from string formatting.** A query built with `%`, `.format()`, an f-string or
  concatenation from variables. *Fix:* the DB-API placeholders, passing values as the second
  argument to `execute()`. Refines GEN-SE1. *Source:* sqlite3 module § How to use placeholders
  to bind values in SQL queries.
- **PY-SE2 Shell injection.** `subprocess` with `shell=True` and a command built from input.
  *Fix:* pass an argument list without `shell=True`; where a shell is unavoidable, quote with
  `shlex.quote()` on platforms where it applies. Refines GEN-SE1. *Source:* subprocess module
  § Security Considerations.
- **PY-SE3 Unpickling untrusted data.** `pickle.load(s)` on data that could come from
  outside or be tampered with. *Why:* malicious pickle data executes arbitrary code. *Fix:*
  `json` for untrusted data, or sign with `hmac` and verify before loading. Refines GEN-SE1.
  *Source:* pickle module (warning).
- **PY-SE4 `random` for secrets.** Tokens, passwords or keys from the `random` module.
  *Fix:* the `secrets` module. Refines GEN-SE4. *Source:* random module (warning).
- **PY-SE5 Plain hashes for passwords.** `hashlib.sha256(password)` and the like, or MD5 or
  SHA-1 where collisions matter. *Why:* naive hashes are not resistant to brute force; MD5 and
  SHA-1 have known collision weaknesses. *Fix:* `hashlib.pbkdf2_hmac` or `hashlib.scrypt`
  with a salt of 16 or more bytes from `os.urandom()`. Refines GEN-SE4. *Source:* hashlib
  module § Key derivation.
- **PY-SE6 Checks done with `assert`.** Authorization or input validation written as
  `assert`. *Why:* no code is emitted for `assert` under `-O`. *Fix:* an explicit `if` that
  raises. Refines GEN-SE2. *Source:* Language reference § The `assert` statement.
- **PY-SE7 Untrusted XML.** Parsing attacker-controlled XML. *Why:* denial of service, local
  file access and network connections are possible; Expat older than 2.7.2 may be open to
  entity-expansion attacks, and `xmlrpc` to decompression bombs. *Fix:* check
  `pyexpat.EXPAT_VERSION`, and do not accept compressed XML-RPC input from untrusted sources.
  Refines GEN-SE1. *Source:* XML processing modules § XML security.
- **PY-SE8 Vulnerable dependencies.** Raise only from a dependency audit tool's output in the
  brief, never from memory (general checklist).

## Testing

- **PY-TE1 Mocks without a spec.** `Mock()` or `patch()` replacing a real object without
  `spec`, `autospec=True` or `create_autospec()`. *Why:* the mock accepts calls with wrong
  signatures and attributes the real object lacks, so the test passes when production code
  would fail. *Fix:* autospec the mock. Refines GEN-TE3. *Source:* unittest.mock § Quick
  guide (auto-speccing), § `patch`.
- **PY-TE2 Patching the wrong name.** `patch()` targeting where an object is defined while
  the code under test looked it up elsewhere (`from module import name`). *Why:* the code
  under test still calls the real object. *Fix:* patch the name where it is looked up.
  Refines GEN-TE2. *Source:* unittest.mock § Where to patch.
- **PY-TE3 Coroutine tests that never run.** `async def` test methods on a plain
  `unittest.TestCase`. *Why:* the coroutine is created and never awaited, and returning a
  value from a test method is deprecated since 3.11. *Fix:* `IsolatedAsyncioTestCase`, or the
  project's async test plugin. Refines GEN-TE2. *Source:* unittest module
  § `IsolatedAsyncioTestCase`, § Basic example; Developing with asyncio § Detect never-awaited
  coroutines.
- **PY-TE4 Loops without subtests.** A test looping over cases with plain assertions. *Why:*
  the first failure stops the loop and hides which case failed. *Fix:* wrap each iteration in
  `self.subTest(...)`. Refines GEN-TE5. *Source:* unittest module § Distinguishing test
  iterations using subtests.

The items below apply where the project tests with pytest (see
[Tools and metrics](#tools-and-metrics) for how to tell).

- **PY-TE5 Setup repeated instead of a fixture.** The same arrangement written out in many
  tests. *Fix:* a `@pytest.fixture`, placed in a `conftest.py` when tests in several modules
  need it, with the narrowest scope that fits (the default `function` scope builds it per
  test). Refines GEN-DR5, GEN-TE5. *Source:* pytest: How to use fixtures § Scope: sharing fixtures
  across classes, modules, packages or session.
- **PY-TE6 Copied tests per input.** Test functions identical except for their data. *Fix:*
  `@pytest.mark.parametrize`, which runs the test once per case and reports a failure by its
  case ID. Refines GEN-TE5. *Source:* pytest: How to parametrize fixtures and test functions.
- **PY-TE7 Tests changing real state.** Tests that set environment variables, change the
  working directory, patch attributes or edit `sys.path` by hand, or write to fixed paths.
  *Why:* the change leaks into later tests, which then depend on order. *Fix:* the
  `monkeypatch` fixture (`setattr`, `setenv`, `delenv`, `chdir`, `syspath_prepend`), whose
  changes are undone when the test finishes; `tmp_path` for a directory unique to each test.
  Refines GEN-TE4. *Source:* pytest: How to monkeypatch/mock modules and environments; How to
  use temporary directories and files in tests.
- **PY-TE8 Fixtures that can leave state behind.** A fixture performing several
  state-changing steps before its `yield`, or a teardown written as code after the test body.
  *Why:* if a setup step raises, its teardown code does not run. *Fix:* yield fixtures, each
  limited to one state-changing action, so pytest tears down every fixture that succeeded.
  Refines GEN-TE4. *Source:* pytest: How to use fixtures § Teardown/Cleanup, § Safe
  teardowns.
- **PY-TE9 Hidden or shared arrangement.** An `autouse=True` fixture, or a `module`- or
  `session`-scoped fixture holding mutable state that tests change. *Why:* an autouse fixture
  affects every test in its reach without being named; a wide-scoped fixture lives until the
  end of its scope, so one test's change is seen by the next. *Fix:* request the fixture
  explicitly, narrow its scope, or make the shared object read-only. Refines GEN-TE4,
  GEN-TE5. *Source:* pytest: How to use fixtures § Scope: sharing fixtures across classes, modules,
  packages or session; § Autouse fixtures.

## Performance

- **PY-PE1 Strings built with `+=` in loops.** *Why:* only CPython makes in-place string
  concatenation fast, and not in every case. *Fix:* collect parts and `''.join()` them.
  *Source:* PEP 8 § Programming Recommendations.
- **PY-PE2 Blocking the event loop.** CPU-heavy or otherwise blocking code called directly
  inside a coroutine. *Why:* every task and I/O operation on the loop waits for it. *Fix:* run
  it in an executor through `loop.run_in_executor()` or `asyncio.to_thread()`.
  Refines GEN-PE3. *Source:* Developing with asyncio § Running Blocking Code; asyncio tasks
  § `to_thread`.
- **PY-PE3 Unbounded or instance-pinning caches.** `functools.cache` or
  `lru_cache(maxsize=None)` on input that keeps growing; either cache on a method. *Why:* the
  cache grows without bound and holds every argument, including `self`, keeping instances
  alive. *Fix:* a bounded `lru_cache(maxsize=...)`, or `functools.cached_property` for
  argument-less methods. Refines GEN-PE4. *Source:* functools module; Programming FAQ § How
  do I cache method calls?
- **PY-PE4 Concurrent tasks left running after a failure.** `asyncio.gather` over subtasks
  where one failure should stop the rest. *Why:* `gather` does not cancel the remaining tasks;
  they keep consuming resources. *Fix:* `asyncio.TaskGroup`, which cancels the rest when one
  fails. Refines GEN-PE5. *Source:* asyncio tasks § Task Groups, § Running Tasks
  Concurrently.
- **PY-PE5 Imports moved into functions for start-up time** `(3.15+)`. *Fix:* a `lazy import`
  at module scope, which keeps the dependency visible at the top of the module; `lazy` is not
  allowed inside functions, classes or `try` blocks. *Source:* What's new in Python 3.15
  (PEP 810); Programming FAQ § What are the best practices for using import in a module?

## Tools and metrics

**Detect.** Configuration in `pyproject.toml` (`[tool.ruff]`, `[tool.mypy]`,
`[tool.pyright]`) or the tools' own files (`ruff.toml`, `.ruff.toml`, `mypy.ini`,
`.mypy.ini`, `setup.cfg`, `pyrightconfig.json`), and the tools listed among the development
dependencies. A tool that is configured but not installed in the project's environment is
listed as not run; never install it. A project uses pytest when it has a pytest
configuration (`pytest.toml` or `.pytest.toml`, `pytest.ini` or `.pytest.ini`, a
`[tool.pytest]` or `[tool.pytest.ini_options]` table in `pyproject.toml`, `[pytest]` in
`tox.ini`, `[tool:pytest]` in `setup.cfg`; the first match wins), `conftest.py` files, or
pytest among its development dependencies. *Source:* Ruff settings; mypy configuration;
pyright configuration; pytest: Configuration § Initialization: determining rootdir and
configfile.

**Run, under the review boundary:**

| Command | Status | Why |
|---|---|---|
| `ruff check --no-fix` | Run after inspecting its configuration | Writes only its cache (`.ruff_cache` unless `cache-dir` or `RUFF_CACHE_DIR` moves it). `--no-fix` matters: a project with `fix = true` would otherwise rewrite files |
| `ruff format --check` | Run after the same inspection | Writes no files; exit 1 when files would be reformatted. Plain `ruff format` rewrites files — never run it |
| `mypy` with the project's configuration | Run after inspecting its configuration | Writes its cache (`.mypy_cache` by default) |
| `pyright` with the project's configuration | Run after inspecting its configuration | Default mode `standard`; checks against the running interpreter unless `pythonVersion` is set |
| `pytest` | Not run unless its effects were inspected and are local | Executes test code and fixtures. `conftest.py` files act as local plugins, every installed plugin loads automatically, and autouse fixtures run for every test. Inspect `addopts` in the configuration, each `conftest.py`, the fixtures and the installed plugins first. It also writes `.pytest_cache` and temporary directories under its base temp directory (the last 3 runs are kept) |
| Any other test runner | Not run unless the tests' effects were inspected | Executes test code |
| A dependency audit | Not run unless the developer allows network access | Queries vulnerability databases over the network |

Formatter output is reported as tool metrics, never as findings. *Source:* Ruff settings
§ `fix`, § `cache-dir`; Ruff formatter; mypy configuration § `cache_dir`; pyright
configuration; pytest: How to install and use plugins; How to use fixtures § Autouse
fixtures; How to re-run failed tests and maintain state between test runs; How to use
temporary directories and files in tests.

**Metrics.** Ruff reports these only when the project's rule selection includes them; never
change the selection for the review. The project's configured limits override the defaults.

| Rule | Measures | Setting | Documented default |
|---|---|---|---|
| C901 | McCabe complexity of a function | `lint.mccabe.max-complexity` | 10 |
| PLR0912 | Branches in a function | `lint.pylint.max-branches` | 12 |
| PLR0913 | Arguments of a function | `lint.pylint.max-args` | 5 |
| PLR0915 | Statements in a function | `lint.pylint.max-statements` | 50 |

When they did not run, the metric reads "not measured". *Source:* Ruff settings
§ `lint.mccabe`, § `lint.pylint`; Ruff rules C901, PLR0912, PLR0913, PLR0915.

## Sources

Read 2026-11-20: whole pages or the cited sections.

- Status of Python versions — https://devguide.python.org/versions/
- PEP 8 — https://peps.python.org/pep-0008/
- PEP 621 — https://peps.python.org/pep-0621/
- What's new in Python 3.12 — https://docs.python.org/3/whatsnew/3.12.html
- What's new in Python 3.14 — https://docs.python.org/3/whatsnew/3.14.html
- What's new in Python 3.15 — https://docs.python.org/3.15/whatsnew/3.15.html
- Programming FAQ — https://docs.python.org/3/faq/programming.html
- Language reference, simple statements — https://docs.python.org/3/reference/simple_stmts.html
- typing module — https://docs.python.org/3/library/typing.html
- Typing best practices — https://typing.python.org/en/latest/reference/best_practices.html
- warnings module — https://docs.python.org/3/library/warnings.html
- datetime module — https://docs.python.org/3/library/datetime.html
- functools module — https://docs.python.org/3/library/functools.html
- asyncio tasks — https://docs.python.org/3/library/asyncio-task.html
- Developing with asyncio — https://docs.python.org/3/library/asyncio-dev.html
- unittest module — https://docs.python.org/3/library/unittest.html
- unittest.mock — https://docs.python.org/3/library/unittest.mock.html
- sqlite3 module — https://docs.python.org/3/library/sqlite3.html
- subprocess module — https://docs.python.org/3/library/subprocess.html
- pickle module — https://docs.python.org/3/library/pickle.html
- random module — https://docs.python.org/3/library/random.html
- hashlib module — https://docs.python.org/3/library/hashlib.html
- XML processing modules — https://docs.python.org/3/library/xml.html
- Ruff settings — https://docs.astral.sh/ruff/settings/
- Ruff formatter — https://docs.astral.sh/ruff/formatter/
- Ruff rules C901, PLR0912, PLR0913, PLR0915 — https://docs.astral.sh/ruff/rules/ (complex-structure, too-many-branches, too-many-arguments, too-many-statements)
- mypy configuration — https://mypy.readthedocs.io/en/stable/config_file.html
- pyright configuration — https://github.com/microsoft/pyright/blob/main/docs/configuration.md
- pytest: How to use fixtures — https://docs.pytest.org/en/stable/how-to/fixtures.html
- pytest: How to parametrize fixtures and test functions — https://docs.pytest.org/en/stable/how-to/parametrize.html
- pytest: How to monkeypatch/mock modules and environments — https://docs.pytest.org/en/stable/how-to/monkeypatch.html
- pytest: How to use temporary directories and files in tests — https://docs.pytest.org/en/stable/how-to/tmp_path.html
- pytest: Configuration — https://docs.pytest.org/en/stable/reference/customize.html
- pytest: How to install and use plugins — https://docs.pytest.org/en/stable/how-to/plugins.html
- pytest: How to re-run failed tests and maintain state between test runs — https://docs.pytest.org/en/stable/how-to/cache.html
