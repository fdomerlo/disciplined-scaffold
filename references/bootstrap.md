# Flow A — Bootstrap a repository

## Steps

### Option 1 — Automated via script (Recommended)

Run `scripts/init.sh` from this skill (resolves templates and paths automatically):

```bash
bash <path-to-skill>/scripts/init.sh --test-cmd "<TEST_COMMAND>" [--with-hook] [--project-name "<NAME>"]
```

Options:
- `-t, --test-cmd`: Test suite command (e.g. `pytest`, `npm test`, `cargo test`).
- `--with-hook`: Automatically installs and activates `.git/hooks/commit-msg`.
- `-p, --project-name`: Explicit project name (defaults to target directory name).
- `-d, --target-dir`: Target repository root (defaults to `.`).
- `-f, --force`: Overwrite existing contract files if re-initializing.

### Option 2 — Manual step-by-step (Fallback)

1. Confirm repo root (git init if needed — ask first, don't init silently
   over an existing non-git project).
2. Fill `assets/AGENTS.md.template` placeholders:
   - `{{PROJECT_NAME}}` — name of the repository/project.
   - `{{TEST_COMMAND}}` — the project's actual test invocation. Ask if not
     obvious from the stack (don't guess `pytest` for a project that turns
     out to use `unittest` or `go test`).
   - `{{COMMIT_TYPES}}` — default: `feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert, release`.
     Ask only if the project has an existing convention to match.
3. Write the filled template to `AGENTS.md` at the repo root. This is the
   single source of truth — OpenCode, Antigravity, Codex and Cursor read
   it natively.
4. Write `CLAUDE.md` at the repo root containing exactly one line:

   ```
   @AGENTS.md
   ```

   Claude Code uses `CLAUDE.md` as its entry point; this `@AGENTS.md`
   import is Anthropic's documented pattern to include external markdown
   rules without duplicate maintenance. A symlink (`ln -s AGENTS.md CLAUDE.md`)
   also works and is equally valid, but needs developer mode or elevated
   permissions on Windows — prefer the import directive unless requested otherwise.

   **Never copy the contract prose into both files.** Two copies of a
   contract is two contracts, and they will diverge.
5. Offer, don't force, the commit-msg hook:
   - **EN**: `"I can install a git commit-msg hook that rejects commits not following Conventional Commits, so discipline doesn't rely solely on agent memory. Shall I install it?"`
   - **ES**: `"Puedo instalar un git hook que rechace commits que no sigan Conventional Commits, así la regla no depende solo de la memoria del agente. ¿Lo instalo?"`
   If yes: copy `<skill-dir>/scripts/commit-msg-hook.sh` to `.git/hooks/commit-msg`,
   `chmod +x`, and tell the user it can be bypassed with
   `git commit --no-verify` (say this — a hook nobody knows how to bypass
   in an emergency gets deleted instead of respected).
6. Report what was written and stop. Don't start writing project code in
   the same turn unless the user asked for that too.

## Why each rule in the contract exists (for when the user asks)

- **Conventional commits** — makes the history itself a queryable log of
  intent; a `git log --oneline` becomes a changelog draft for free.
- **Test before first change, after every logical unit** — the cheapest
  possible check against an agent's unstated assumption that something
  still works.
- **Never leave the suite red at a commit boundary** — a red commit means
  the next session (agent or human) inherits a broken baseline with no
  signal of whose change broke it.
- **Atomic commits, one concern each** — makes `git revert` a real option
  instead of a surgical mess.
- **The plan-mode clause** (see `plan-cycle.md`) — is what upgrades this
  contract from "good habits" to "governs multi-session work," the moment
  the task outgrows a single sitting.
