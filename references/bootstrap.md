# Flow A — Bootstrap a repository

## Steps

1. Confirm repo root (git init if needed — ask first, don't init silently
   over an existing non-git project).
2. Fill `assets/AGENTS.md.template` placeholders:
   - `{{TEST_COMMAND}}` — the project's actual test invocation. Ask if not
     obvious from the stack (don't guess `pytest` for a project that turns
     out to use `unittest` or `go test`).
   - `{{COMMIT_TYPES}}` — default: `feat, fix, docs, refactor, test, chore,
     release`. Ask only if the project has an existing convention to match.
3. Write the filled template to `AGENTS.md` at the repo root. This is the
   single source of truth — OpenCode, Antigravity, Codex and Cursor read
   it natively.
4. Write `CLAUDE.md` at the repo root containing exactly one line:

   ```
   @AGENTS.md
   ```

   Claude Code does not read `AGENTS.md` natively (still true as of Claude
   Code 2.1.x, July 2026, despite a heavily-upvoted request); this import
   is Anthropic's own documented workaround. A symlink
   (`ln -s AGENTS.md CLAUDE.md`) also works and is equally official, but
   needs developer mode or elevated permissions on Windows — prefer the
   import unless the user asks otherwise.

   **Never copy the contract prose into both files.** Two copies of a
   contract is two contracts, and they will diverge.
5. Offer, don't force, the commit-msg hook:
   > "Quiero instalar un git hook que rechace commits que no sigan
   > conventional commits — así la regla no depende de que el agente se
   > acuerde. ¿Lo instalo?"
   If yes: copy `scripts/commit-msg-hook.sh` to `.git/hooks/commit-msg`,
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
