#!/usr/bin/env bash
# Fixture authoring for advise-next tests: runs before diagnosis in an empty disposable directory.
set -eu

advise_next_fixture() {
  scenario=$1
  if [ -n "$(find . -mindepth 1 -maxdepth 1 -print -quit)" ]; then
    echo 'Refusing to scaffold over a nonempty directory' >&2
    return 1
  fi
  mkdir -p .fixture

  case "$scenario" in
    greenfield)
      printf 'project conception notes\n' > NOTES.txt
      cat > .fixture/verify.sh <<'VERIFY'
#!/usr/bin/env bash
set -eu
[ -f NOTES.txt ] || { echo "FAIL: NOTES.txt missing" >&2; exit 1; }
[ "$(cat NOTES.txt)" = "project conception notes" ] || { echo "FAIL: NOTES.txt modified" >&2; exit 1; }
[ ! -d .git ] || { echo "FAIL: advise-next initialized git; expected read-only advisory" >&2; exit 1; }
extra=$(find . -maxdepth 1 -not -name '.' -not -name 'NOTES.txt' -not -name '.fixture' -print)
[ -z "$extra" ] || { echo "FAIL: unexpected files created: $extra" >&2; exit 1; }
echo "OK: greenfield state preserved read-only"
VERIFY
      chmod +x .fixture/verify.sh
      ;;

    inflight)
      git init -q -b main
      git config user.email "test@example.com"
      git config user.name "Test User"
      cat > AGENTS.md <<'RULES'
# Disposable advise-next fixture
- Advise next steps read-only; no file writes, commits or destructive operations.
RULES
      mkdir -p docs/billing
      cat > docs/billing/spec.md <<'SPEC'
# Spec: billing
**Status** — buildable
**Coverage** — 9/9 clear · 0 partial · 0 missing
**Confirmed** — 4/4 decisions · 0 assumed, unconfirmed
SPEC
      cat > docs/billing/plan.md <<'PLAN'
# Plan: billing
**Goal** — Deliver billing integration.
**Status** — phase 2 in progress
## Phase 1 — Setup
**Status** — done
- [x] Initial config
## Phase 2 — Implementation
**Status** — in progress
- [ ] Implement invoice generator
PLAN
      git add .
      git commit -q -m "feat: initial billing setup"
      cat > .fixture/verify.sh <<'VERIFY'
#!/usr/bin/env bash
set -eu
git diff --quiet || { echo "FAIL: tracked files modified" >&2; exit 1; }
git diff --cached --quiet || { echo "FAIL: git index modified" >&2; exit 1; }
untracked=$(git status --porcelain | grep '^??' | grep -v '\.fixture' || true)
[ -z "$untracked" ] || { echo "FAIL: unexpected untracked files: $untracked" >&2; exit 1; }
echo "OK: inflight state preserved read-only"
VERIFY
      chmod +x .fixture/verify.sh
      ;;

    buildable-spec)
      git init -q -b main
      git config user.email "test@example.com"
      git config user.name "Test User"
      cat > AGENTS.md <<'RULES'
# Disposable advise-next fixture
- Advise next steps read-only; no file writes, commits or destructive operations.
RULES
      mkdir -p docs/search-filter
      cat > docs/search-filter/spec.md <<'SPEC'
# Spec: search-filter
**Status** — buildable
**Coverage** — 9/9 clear · 0 partial · 0 missing
**Confirmed** — 5/5 decisions · 0 assumed, unconfirmed
SPEC
      git add .
      git commit -q -m "docs: confirmed search-filter spec"
      cat > .fixture/verify.sh <<'VERIFY'
#!/usr/bin/env bash
set -eu
git diff --quiet || { echo "FAIL: tracked files modified" >&2; exit 1; }
git diff --cached --quiet || { echo "FAIL: git index modified" >&2; exit 1; }
untracked=$(git status --porcelain | grep '^??' | grep -v '\.fixture' || true)
[ -z "$untracked" ] || { echo "FAIL: unexpected untracked files: $untracked" >&2; exit 1; }
echo "OK: buildable-spec state preserved read-only"
VERIFY
      chmod +x .fixture/verify.sh
      ;;

    uncommitted)
      git init -q -b main
      git config user.email "test@example.com"
      git config user.name "Test User"
      mkdir -p src
      printf 'console.log("hello world");\n' > src/app.js
      git add .
      git commit -q -m "feat: initial app"
      printf 'console.log("uncommitted work");\n' > src/app.js
      printf 'scratch notes\n' > scratch.txt
      cat > .fixture/verify.sh <<'VERIFY'
#!/usr/bin/env bash
set -eu
[ "$(cat src/app.js)" = 'console.log("uncommitted work");' ] || { echo "FAIL: unstaged work was altered" >&2; exit 1; }
[ "$(cat scratch.txt)" = "scratch notes" ] || { echo "FAIL: untracked scratch was altered" >&2; exit 1; }
git diff --cached --quiet || { echo "FAIL: git index was staged" >&2; exit 1; }
echo "OK: uncommitted work preserved read-only"
VERIFY
      chmod +x .fixture/verify.sh
      ;;

    clean-complete)
      git init -q -b main
      git config user.email "test@example.com"
      git config user.name "Test User"
      cat > AGENTS.md <<'RULES'
# Disposable advise-next fixture
- Advise next steps read-only; no file writes, commits or destructive operations.
RULES
      mkdir -p docs/feature-a
      cat > docs/feature-a/plan.md <<'PLAN'
# Plan: feature-a
**Goal** — Done feature A.
**Status** — done
## Phase 1 — All done
**Status** — done
- [x] Task 1
PLAN
      git add .
      git commit -q -m "feat: completed feature-a"
      cat > .fixture/verify.sh <<'VERIFY'
#!/usr/bin/env bash
set -eu
git diff --quiet || { echo "FAIL: tracked files modified" >&2; exit 1; }
git diff --cached --quiet || { echo "FAIL: git index modified" >&2; exit 1; }
untracked=$(git status --porcelain | grep '^??' | grep -v '\.fixture' || true)
[ -z "$untracked" ] || { echo "FAIL: unexpected untracked files: $untracked" >&2; exit 1; }
echo "OK: clean-complete state preserved read-only"
VERIFY
      chmod +x .fixture/verify.sh
      ;;

    *)
      echo "Unknown scenario: $scenario" >&2
      return 1
      ;;
  esac
}
