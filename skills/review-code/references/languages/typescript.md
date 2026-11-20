# TypeScript and JavaScript reference

TypeScript and JavaScript idioms and smells per review angle, with the tools that measure
them. It refines the general checklist; an item that sharpens a general one names its `GEN-`
ID. Cite an item by its ID (`TS-CQ3`) in a candidate's rule line.

**Checked:** 2026-11-20, against typescriptlang.org, the TypeScript blog, typescript-eslint.io
and the ESLint, Node.js, npm, Vitest and Jest documentation (list under [Sources](#sources)).
**Targets:** TypeScript 6.0 and 7.0; advice holds on both unless marked `(TS 7.0)`. Plain
JavaScript files are covered; `(JS)` marks a note that differs for them, `(Node)` an item
about the Node.js runtime.

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

- **TS-E1 Read the versions and the compiler settings first.** The TypeScript version is the
  `typescript` entry in `package.json` (an npm alias such as
  `"typescript": "npm:@typescript/typescript6"` means 6.0). The Node.js version is in
  `engines`, which is advisory unless `engine-strict` is set. Whether `.js` files are ES
  modules follows the nearest `package.json` `"type"`. Read `tsconfig.json` and every file it
  `extends`: the strictness flags decide which TypeScript items can apply. When versions are
  unknown, a version-marked candidate is uncertain (GEN-E4). *Source:* Announcing TypeScript
  7.0; npm package.json § engines; Node.js packages § `"type"`; TSConfig reference § extends.
- **TS-E2 TypeScript 7.0 changes** `(TS 7.0)`. Defaults: `strict` true, `module` esnext,
  `noUncheckedSideEffectImports` true, `types` `[]`, `rootDir` `./`. No longer supported:
  `target: es5`, `downlevelIteration`, `moduleResolution` `node`, `node10` and `classic`,
  `module` `amd`, `umd`, `systemjs` and `none`, `baseUrl`, `esModuleInterop` or
  `allowSyntheticDefaultImports` set to `false`, `alwaysStrict` set to `false`. 7.0 ships no
  programmatic API; one is expected in 7.1. *Source:* Announcing TypeScript 7.0.
- **TS-E3 JavaScript files** `(JS)`. The compiler checks `.js` files only with `allowJs` and
  `checkJs`; otherwise TypeScript-only items do not apply to them, and the ESLint core rules
  named below still do. *Source:* TSConfig reference § allowJs, § checkJs.
- **TS-E4 The project's configuration wins (GEN-E2).** `tsconfig.json`, the ESLint flat
  config (`eslint.config.js`, `.mjs`, `.cjs`, `.ts`, `.mts`, `.cts`, found by searching up from
  each file) and the test runner's configuration are project rules. A rule the project turned
  off, or a line it suppressed, is not a finding. *Source:* ESLint configuration files.
- **TS-E5 Newer syntax is not a finding by itself**, and formatting is the formatter's.

## SOLID

- **TS-SO1 Switches over a union without an exhaustiveness check.** A `switch` or `if` chain
  over a union or enum, repeated across the code, with no `never` check. *Why:* a new member
  reaches no branch and nothing reports it. *Fix:* a discriminated union (a shared literal
  property such as `kind`) and a `default` that assigns the value to `never`, so adding a
  member is a compile error; typescript-eslint `switch-exhaustiveness-check` reports the gap.
  Refines GEN-SO3. *Source:* Handbook § Narrowing (Exhaustiveness checking); typescript-eslint:
  switch-exhaustiveness-check.
- **TS-SO2 Overrides without `override`.** Subclass methods that replace base methods without
  the `override` keyword. *Why:* when the base method is renamed, the subclass gets out of
  sync silently. *Fix:* `noImplicitOverride` and the `override` keyword. Refines GEN-SO4.
  *Source:* TSConfig reference § noImplicitOverride.
- **TS-SO3 Optional-property bags instead of variants.** One type with optional fields that
  only some cases use, read with `!`. *Why:* the type cannot say which fields belong together,
  and the assertions break when code moves. *Fix:* a discriminated union with required fields
  per variant. Refines GEN-SO5. *Source:* Handbook § Narrowing (Discriminated unions).

## DRY and duplication

- **TS-DR1 Types restated by hand.** A type that copies the fields of another, or restates a
  function's parameters or result. *Why:* the copies drift. *Fix:* derive it with `Pick`,
  `Omit`, `Partial`, `Parameters`, `ReturnType` or `Awaited`. Refines GEN-DR3. *Source:*
  Handbook § Utility Types.
- **TS-DR2 Copied tests per input.** Test cases identical except for their values. *Fix:*
  `test.each` (Vitest), or the project runner's equivalent. Refines GEN-DR5. *Source:* Vitest
  API § test.each.

## Architecture and layering

- **TS-AR1 Deep imports into another package.** Importing `pkg/internal/file.js` rather than
  the package's entry points. *Why:* when the package declares `"exports"`, unlisted subpaths
  are encapsulated and throw `ERR_PACKAGE_PATH_NOT_EXPORTED`; without it, internals become a
  de-facto API. *Fix:* import from an exported entry point, and give each internal package an
  `"exports"` map. Refines GEN-AR6. *Source:* Node.js packages § Main entry point export,
  § Subpath exports.
- **TS-AR2 Type-only imports kept at run time.** Imports used only as types, written as value
  imports. *Why:* with `verbatimModuleSyntax`, imports without a `type` modifier stay in the
  output, so a type-only dependency becomes a run-time module dependency.
  *Fix:* `import type`. Refines GEN-AR3. *Source:* TSConfig reference § verbatimModuleSyntax.
- **TS-AR3 Strictness switched off in a manifest.** `strict`, `strictNullChecks` or
  `noImplicitAny` set to `false` in `tsconfig.json`, or turned off in one package of a
  workspace. *Why:* with `strictNullChecks` off, `null` and `undefined` are effectively ignored
  and fail at run time. *Fix:* enable them, package by package. *Source:* TSConfig reference
  § strict, § strictNullChecks.
- **TS-AR4 Configuration TypeScript 7.0 rejects** `(TS 7.0)`. Any option listed as no longer
  supported under TS-E2, or a setup that relied on the old `types` default (all `@types`
  packages included). *Why:* 7.0 treats them as hard errors, or drops the global types.
  *Fix:* the replacements the release names: `moduleResolution` `nodenext` or `bundler`,
  `module` `esnext` or `preserve`, `paths` relative to the project root, `types` listing the
  packages needed (`["*"]` restores the old behaviour).
  *Source:* Announcing TypeScript 7.0.
- **TS-AR5 Settings copied between tsconfig files.** *Fix:* a shared base file the others
  `extends`; project `references` where packages build separately. *Source:* TSConfig
  reference § extends, § references.

## Code quality and readability

- **TS-CQ1 `any`.** Explicit `any`, or implicit `any` where `noImplicitAny` is off. *Why:*
  `any` disables type checking for the value and everything read from it. *Fix:* `unknown`
  narrowed before use, or the precise type. *Source:* Handbook § Everyday Types (`any`,
  `noImplicitAny`); typescript-eslint: no-explicit-any.
- **TS-CQ2 Assertions in place of narrowing.** `as` casts and postfix `!` used to quiet
  errors. *Why:* both are erased at compile time; a wrong assertion produces no exception,
  just a wrong value later. *Fix:* narrow with checks or a discriminated union. *Source:*
  Handbook § Everyday Types (Type Assertions, Non-null Assertion Operator); typescript-eslint:
  no-non-null-assertion.
- **TS-CQ3 Floating promises.** A promise-valued statement that is not awaited, returned, or
  given a rejection handler. *Why:* its rejection is ignored and operations run out of order;
  `void` marks it but does not handle the rejection. *Fix:* `await` it, return it, or add
  `.catch()`; combine arrays with `Promise.all` or `Promise.allSettled`. Refines GEN-CQ5.
  *Source:* typescript-eslint: no-floating-promises.
- **TS-CQ4 Promises where none is expected.** An async function passed as a void callback
  (`forEach`, event handlers), or a promise tested in a condition (`if (promise)`). *Why:* the
  caller never awaits it, and the condition is always true. *Fix:* a `for...of` loop with
  `await`, or a handler that catches its own errors; await the value before testing it.
  Refines GEN-CQ11. *Source:* typescript-eslint: no-misused-promises.
- **TS-CQ5 Loose equality** `(JS)`. `==` and `!=`. *Why:* they coerce types by obscure rules.
  *Fix:* `===` and `!==`. Refines GEN-CQ11. *Source:* ESLint: eqeqeq.
- **TS-CQ6 Unchecked index access.** Array or record lookups used as if always defined. *Fix:*
  `noUncheckedIndexedAccess`, which adds `undefined` to index results, and a check at each use.
  *Source:* TSConfig reference § noUncheckedIndexedAccess.
- **TS-CQ7 Caught values assumed to be `Error`.** `catch (e)` code reading `e.message` with
  no check. *Why:* anything can be thrown. *Fix:* `useUnknownInCatchVariables` (part of
  `strict`) and an `instanceof` check. Refines GEN-CQ5. *Source:* TSConfig reference
  § useUnknownInCatchVariables.

## Security

- **TS-SE1 Shell commands from input** `(Node)`. `child_process.exec` or `execSync`, or
  `execFile` with `shell` enabled, given a command built from input. *Why:* shell
  metacharacters run arbitrary commands. *Fix:* `execFile` or `spawn` without a shell and
  with an argument array. Refines GEN-SE1. *Source:* Node.js child_process § exec, § execFile.
- **TS-SE2 Code from strings.** `eval()`, or `setTimeout`/`setInterval` given a string.
  *Why:* the string is interpreted as code, with security and performance costs. *Fix:* pass
  a function; parse data instead of evaluating it. Refines GEN-SE1. *Source:* ESLint:
  no-implied-eval.
- **TS-SE3 Weak randomness for tokens** `(Node)`. Security values from a source not
  documented as cryptographically strong. *Fix:* `crypto.randomBytes` (documented as
  cryptographically strong). Refines GEN-SE4. *Source:* Node.js crypto § randomBytes.
- **TS-SE4 Regular expressions open to ReDoS.** A pattern with nested quantifiers (`(a+)*`),
  overlapping alternatives (`(a|a)*`) or backreferences, run on request input. *Why:* the
  engine can take exponential time and stall the server. *Fix:* a pattern without those
  constructs, or `indexOf` for a plain match. Refines GEN-SE1. *Source:* Node.js: Don't
  Block the Event Loop § ReDoS.
- **TS-SE5 Vulnerable dependencies.** Raise only from `npm audit` (or the package manager's
  audit) output in the brief. *Source:* npm audit.

## Testing

- **TS-TE1 Real time in tests.** Tests that wait on real `setTimeout` or read the real clock.
  *Why:* slow and dependent on when they run. *Fix:* `vi.useFakeTimers()` and
  `vi.setSystemTime()`, with `vi.useRealTimers()` afterwards. Refines GEN-TE4. *Source:*
  Vitest: Mocking timers; Vitest `vi` API.
- **TS-TE2 Environment changed by hand.** Tests assigning `process.env` directly. *Why:* the
  change leaks into later tests. *Fix:* `vi.stubEnv()` and `vi.unstubAllEnvs()`. Refines
  GEN-TE4. *Source:* Vitest `vi` API § stubEnv, § unstubAllEnvs.
- **TS-TE3 Spies never restored.** `vi.spyOn` or Jest mocks left in place across tests.
  *Fix:* `vi.restoreAllMocks()` in teardown, or Jest's `restoreMocks: true` (default `false`).
  Refines GEN-TE4. *Source:* Vitest `vi` API § restoreAllMocks; Jest configuration
  § restoreMocks.
- **TS-TE4 Committed `.only` or `.skip`.** *Why:* `.only` stops the rest of the suite from
  running and `.skip` hides tests; Vitest fails in CI on `.only` unless `allowOnly` is set.
  *Fix:* remove them, or record why a test is skipped. Refines GEN-TE6. *Source:* Vitest API
  § test.only, § test.skip.
- **TS-TE5 Copied tests per input.** *Fix:* `test.each`. Refines GEN-TE5. *Source:* Vitest
  API § test.each.

## Performance

- **TS-PE1 Synchronous APIs on a server path** `(Node)`. Synchronous file system calls,
  `crypto.pbkdf2Sync`, `crypto.randomFillSync`, `zlib.*Sync` or `child_process.*Sync` in
  request handling. *Why:* while the event loop is blocked, no other client is served. *Fix:*
  the asynchronous versions. Refines GEN-PE3. *Source:* Node.js: Don't Block the Event Loop.
- **TS-PE2 Large work on the event loop** `(Node)`. CPU-heavy loops, or `JSON.parse` and
  `JSON.stringify` on large client input. *Fix:* partition the work, offload it to a worker
  pool, and bound input size. Refines GEN-PE3, GEN-PE4. *Source:* Node.js: Don't Block the
  Event Loop.
- **TS-PE3 Independent awaits in a loop.** `await` inside a loop whose iterations do not
  depend on each other. *Why:* each operation waits for the previous one. *Fix:* start them
  together and `await Promise.all(...)`. Not a finding for serial, dependent, retrying,
  rate-limited or resource-bounded loops. Refines GEN-PE2. *Source:* ESLint: no-await-in-loop.
- **TS-PE4 A child process per request** `(Node)`. *Why:* requests arrive faster than
  processes can be managed. *Fix:* a fixed pool of workers. Refines GEN-PE5. *Source:*
  Node.js: Don't Block the Event Loop § Offloading.

## Tools and metrics

**Detect.** `tsconfig.json`; an ESLint flat config; typescript-eslint in `devDependencies`
and its typed presets (`recommendedTypeChecked`) with `parserOptions.projectService` or
`project`; a Vitest config (`vitest.config.*`, else `vite.config.*`); a Jest config
(`jest.config.*` or the `"jest"` key in `package.json`). *Source:* typescript-eslint: Linting
with Type Information; ESLint configuration files; Vitest config; Jest configuration.

**The TypeScript 7.0 caveat.** typescript-eslint supports TypeScript `>=4.8.4 <6.1.0`, and
7.0 has no programmatic API. Type-aware rules run against 6.0, through the
`@typescript/typescript6` package aliased as `typescript`. A project whose `typescript`
resolves to 7.0 without that alias cannot run typed lint rules: list them as not run, and do
not assume they ran on the 7.0 compiler. Untyped rules are unaffected. *Source:* Announcing
TypeScript 7.0; typescript-eslint dependency versions.

**Run, under the review boundary:**

| Command | Status | Why |
|---|---|---|
| `npx tsc --noEmit -p <tsconfig>` | Run after inspecting the tsconfig chain | Emits no output files; with `incremental` or `composite` it may write `.tsbuildinfo`. Runs whichever compiler `typescript` resolves to (`tsc6` is the 6.0 binary) |
| `npx eslint <paths>` (no `--fix`) | Run after inspecting the config | The config is a JavaScript module and runs when loaded. `--fix` writes files — never pass it. Writes `.eslintcache` only with `--cache`. Exit 1 means lint errors |
| `npx vitest run` | Not run unless the tests' effects were inspected | Executes test code. Plain `vitest` enters watch mode in an interactive terminal |
| Jest | Not run unless the tests' effects were inspected | Executes test code |
| `npm run <script>` | Not run | Runs arbitrary commands, plus matching `pre` and `post` scripts; run the tool directly instead |
| `npm audit` | Not run unless the developer allows network access | Sends the dependency list to the registry. `npm audit fix` installs and rewrites the lockfile — never run it |

Formatter output is reported as tool metrics, never as findings. *Source:* TSConfig reference
§ noEmit, § incremental; Announcing TypeScript 7.0; ESLint command line interface; Vitest CLI;
npm scripts; npm audit.

**Metrics.** ESLint core rules report these only when the project's config enables them;
never change the config for the review. The project's configured limits override the
defaults.

| Rule | Measures | Documented default |
|---|---|---|
| `complexity` | Cyclomatic complexity of a function | 20 |
| `max-depth` | Nesting depth of blocks | 4 |
| `max-params` | Parameters of a function | 3 |
| `max-lines-per-function` | Lines in a function, blank and comment lines included | 50 |

When they did not run, the metric reads "not measured". *Source:* ESLint rules complexity,
max-depth, max-params, max-lines-per-function.

## Sources

Read 2026-11-20: whole pages or the cited sections.

- Announcing TypeScript 7.0 — https://devblogs.microsoft.com/typescript/announcing-typescript-7-0/
- TSConfig reference — https://www.typescriptlang.org/tsconfig/
- Handbook § Everyday Types — https://www.typescriptlang.org/docs/handbook/2/everyday-types.html
- Handbook § Narrowing — https://www.typescriptlang.org/docs/handbook/2/narrowing.html
- Handbook § Utility Types — https://www.typescriptlang.org/docs/handbook/utility-types.html
- typescript-eslint: Linting with Type Information — https://typescript-eslint.io/getting-started/typed-linting/
- typescript-eslint dependency versions — https://typescript-eslint.io/users/dependency-versions/
- typescript-eslint rules — https://typescript-eslint.io/rules/ (no-floating-promises, no-misused-promises, no-explicit-any, no-non-null-assertion, switch-exhaustiveness-check)
- ESLint configuration files — https://eslint.org/docs/latest/use/configure/configuration-files
- ESLint command line interface — https://eslint.org/docs/latest/use/command-line-interface
- ESLint rules — https://eslint.org/docs/latest/rules/ (complexity, max-depth, max-params, max-lines-per-function, no-await-in-loop, eqeqeq, no-implied-eval)
- Node.js child_process — https://nodejs.org/api/child_process.html
- Node.js crypto — https://nodejs.org/api/crypto.html
- Node.js packages — https://nodejs.org/api/packages.html
- Node.js: Don't Block the Event Loop — https://nodejs.org/en/learn/asynchronous-work/dont-block-the-event-loop
- npm package.json — https://docs.npmjs.com/cli/v11/configuring-npm/package-json
- npm scripts — https://docs.npmjs.com/cli/v11/using-npm/scripts
- npm audit — https://docs.npmjs.com/cli/v11/commands/npm-audit
- Vitest CLI — https://vitest.dev/guide/cli.html
- Vitest config — https://vitest.dev/config/
- Vitest API — https://vitest.dev/api/
- Vitest `vi` API — https://vitest.dev/api/vi.html
- Vitest: Mocking timers — https://vitest.dev/guide/mocking/timers
- Jest configuration — https://jestjs.io/docs/configuration
