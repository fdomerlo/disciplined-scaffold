# Flow C — Close a phase, or close a cycle

Two related jobs. Read the whole file: the phase close is the common one,
the cycle close runs once at the end and catches what the phase closes
could not see.

---

## C1 — Closing a phase

Runs when a phase's work is done, **before** anyone starts the next one.

### Tick the boxes — but only what you can demonstrate

Go through that phase's acceptance criteria in `PLAN-N.md` and mark
`- [ ]` → `- [x]` for each one that is **demonstrably** met. The word is
load-bearing:

- A criterion backed by a test: the test exists and passes *now*, in this
  working tree — you ran it, you are not remembering that you ran it.
- A criterion backed by a command's output: you ran the command in this
  session.
- A criterion that needs a human to look at something (a live host, an
  IDE, a rendered page): **leave it unticked** and say so explicitly in
  the report — "F2 criterion 3 needs your check in a real OpenCode
  session; left unticked." An agent ticking a box only a human can verify
  is the single worst failure mode of this whole file.

Never tick a box in a phase other than the one that just closed. Never
tick a box because the work "obviously" satisfies it. If you find yourself
reasoning about why a criterion is *effectively* met, that is the signal
to leave it open and raise it.

**Be honest about what this is.** Ticking a checkbox is a cooperative act
with nothing verifying it — the same agent that did the work marks its own
homework. It makes state visible; it does not make it true. If the user
needs completion that cannot be faked, that is `context-guard`'s
deterministic task parser, not this.

### Then write the phase report

Immediately below the ticked criteria, or in chat if the user prefers the
plan to stay clean — ask once and remember the preference for the cycle:

- Files changed (a table, not prose).
- Tests added, each with **what attack or regression it guards against**,
  not just its name.
- Any deviation from the plan, with the reasoning. A deviation is not a
  failure; an *unreported* deviation is.
- Anything discovered that belongs to a later cycle → it goes to the
  plan's "Out of scope", not into the next phase.
- Open questions for the human.

Then stop. Do not start the next phase — the human audits the diff first.

---

## C2 — Closing a cycle

Runs after the last phase, or whenever the user asks "what's left?".
This is the pass that catches drift between what the plan said and what
the repo actually became.

1. **Unticked boxes.** List every criterion still `- [ ]` across all
   phases, with which phase it belongs to. For each: is it genuinely not
   done, done-but-unverifiable-by-you, or obsolete because the design
   changed mid-cycle? Say which — a stale unticked box is as misleading as
   a wrongly ticked one.
2. **Reality vs. plan.** Read the actual diff of the cycle (`git log`,
   `git diff` against the branch point). Is there anything in the repo
   that no phase asked for? Anything a phase asked for that is not in the
   repo? Both are findings, and the second one is the reason this pass
   exists.
3. **Scope leaks.** Did anything from "Out of scope" get built anyway?
   Name it. That is not necessarily wrong — but it must be a decision, not
   a discovery six weeks later.
4. **Leftovers.** Everything real that remains — unbuilt work, follow-ups
   discovered along the way, deferred decisions — gets written down where
   the user actually keeps things, in this order of preference: an
   existing `BACKLOG.md`, a new section at the end of the plan, or issues
   if the project uses them. Ask which if it is not obvious. **Do not
   silently open a new `PLAN-N+1.md`** — starting the next cycle is the
   user's decision, not the closing report's.
5. **The honest verdict, in two or three lines.** Did this cycle do what
   it set out to do? If not, what part, and was it because the plan was
   wrong or because the work was harder than it looked? Both answers are
   useful; only the vague one ("mostly done, some follow-ups") is not.

A cycle close never modifies code. It reads, ticks nothing new by itself
beyond what C1 already justified, and reports.
