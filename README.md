# PSR Workflow — Document-Driven Development for AI-Assisted Coding

> 📖 [**中文版 (Chinese Version)**](ZH/PSR-README.md)

> **P**hase-driven development + **S**ub-agents + **R**ecovery = Prevents AI from demolishing your house while fixing a pipe.

---

## What is PSR?

PSR is a **document-driven state machine workflow** designed for AI-assisted development. It breaks the development process into 10 explicit steps, uses file existence to determine progress, and employs 3 dedicated sub-agents for quality control.

Core idea: **File exists = step complete.** The main agent checks the directory at each step, knows exactly what to do, and never gets lost.

---

## What Problems Does It Solve?

| Pain Point | PSR's Solution |
|------------|---------------|
| New conversation — AI forgot where we left off | Reads STATE.md + file timestamps, auto-recovers state |
| AI writes code without understanding the codebase | Step 3 forces sub-agent to scan codebase, output research report |
| New feature breaks existing systems | Step 6 forces code review, Step 7 auto-fixes architecture violations |
| Bug found but depends on unimplemented system — can't fix | Step 9 deferred fix mechanism — record, inherit, don't block |
| Feature scope keeps growing out of control | Discuss per Phase to granularity where every decision is directly codable |
| Code quality degrades over iterations | Every Phase passes three gates: review → fix → UAT |
| Mid-project — don't know how to integrate | Sub-workflow F Mode C (project reconnection) directly integrates |
| Returning after months — completely forgot the context | Recovery flow + reconnection mechanism, rebuilds context from documents |

---

## Why PSR?

### vs. Raw AI Coding

- **State never lost:** Documents live on disk — recoverable even when conversations disappear
- **Quality never degrades:** Every Phase enforces review and fixes — violations don't accumulate
- **Context never explodes:** 3-layer architecture separates concerns — CLAUDE.md stays lean

### vs. Traditional PM Tools

- **Zero setup:** Just a bunch of Markdown files — no tools to install
- **AI-native:** Sub-agents auto-read CLAUDE.md for project rules — switch projects without reconfiguring sub-agents
- **Solo-optimized:** No multi-person ceremony — each step is just the next thing to do

---

## Who Is It For?

- **Solo game developers:** One person + AI building a project, needs structure without process overhead
- **Solo software developers:** Works for any solo-led software project, not just games
- **AI coding explorers:** Want to use AI systematically for development, not just "write it and see"
- **Long-term maintainers:** Project might pause for weeks/months — need to rebuild context when returning

**Not for:** Large multi-person teams (need heavier workflows), one-off scripting tasks.

---

## Core Architecture

### Three-Layer Document Structure

```
Project (.planning/PROJECT.md)       ← Vision, design summary, constraints (1 page)
  └─ Milestone (milestones/VN/)      ← Version scope, Phase breakdown, requirements
       └─ Phase (phases/0N-name/)    ← Single feature module: discuss → deliver (10 steps)
            └─ Plan (0N-PLAN-XX.md)  ← Smallest execution unit (1-3 files)
```

- **Project** defines "what, what constraints, what tech"
- **Milestone** defines "which Phases in this version, which requirements"
- **Phase** is where the real work happens — discuss, research, plan, execute, review, test
- **Plan** is the minimum execution unit — max 3 files per plan

### Three Sub-Agents

| Sub-Agent | Does | Permissions |
|-----------|------|-------------|
| **PSR-Researcher** | Scans codebase, analyzes impact scope, checks pitfalls | Read-only code, writes RESEARCH.md |
| **PSR-Reviewer** | Reviews code against architecture constraints, outputs graded report | Read-only code, writes REVIEW.md |
| **PSR-Fixer** | Reads 🔴 items, fixes one by one, max 3 rounds | Can modify code |

All sub-agents get review standards from `CLAUDE.md` — switch projects by changing only one file, sub-agents need no reconfiguration.

---

## Core Workflow (10 Steps)

```
Step 1-2: Discuss & clear gray areas  →  Create CONTEXT.md + DISCUSSION-LOG.md
Step 3:   Research & explore          →  PSR-Researcher outputs RESEARCH.md
Step 4:   Create plans                →  Main agent creates PLAN-*.md
Step 5:   Execute plans               →  Main agent implements PLANs one by one
Step 6:   Code review                 →  PSR-Reviewer outputs REVIEW.md
Step 7:   Fix blockers                →  PSR-Fixer eliminates 🔴 items (max 3 rounds)
Step 8:   User acceptance testing     →  Create UAT.md → user manually tests
Step 9:   Fix errors                  →  Fix based on feedback / can't fix → defer
Step 10:  Confirm completion          →  Create SUMMARY.md → update STATE.md → commit
```

The main agent uses a **checklist** to auto-determine which step to execute — file missing? Execute. File exists? Skip. No need to memorize steps.

---

## Command Reference

### Daily Development

| You Say | Triggers |
|---------|----------|
| `Start Phase N` | Enter Steps 1-2 discussion |
| (Phase auto-advances during execution) | Steps 3→4→5→6→7→8 auto-flow |
| `Append requirement: {description}` | Sub-workflow A Branch 1 — add requirement to current Phase |
| `Re-discuss Phase N` | Sub-workflow A Branch 2 — re-discuss current Phase conclusions |
| `Modify Phase N: {description}` | Sub-workflow B — modify completed Phase |

### Project Management

| You Say | Triggers |
|---------|----------|
| `Initialize PSR workflow` or `Start new project` | Sub-workflow F — create project skeleton |
| `Start milestone V1` | Sub-workflow G — create milestone documents |
| `Milestone complete` | Sub-workflow D — wrap up current milestone |
| `Review framework` | Sub-workflow C — global architecture health check |
| `Update knowledge base` | Sub-workflow E — update codebase/ docs |

### Recovery & Reconnection

| You Say | Triggers |
|---------|----------|
| `Recover workflow` or new conversation starts | Recovery flow — auto-determine current step |
| `Reconnect project` | Sub-workflow F Mode C — re-examine project direction |
| `Reconnect milestone` or `Reconnect milestone V1` | Sub-workflow G Mode C — adjust milestone scope |

### Reconnection Quick Reference

| Your Situation | Use This |
|---------------|----------|
| Project direction changed (e.g., from RPG to sim) | `Reconnect project` |
| Milestone scope too big/small, need Phase re-split | `Reconnect milestone` |
| Returning after months, forgot where you were | `Recover workflow` (auto) |
| Requirement changes invalidated Phase plans | `Reconnect milestone` |
| Tech stack changed, architecture constraints need update | `Reconnect project` |

---

## Getting Started

### Want to integrate PSR into an existing project? Just 2 steps:

**Step 1:** Copy the `.planning/` directory to your project root.

**Step 2:** Tell AI:

> Read `.planning/WORKFLOW.md`, help me initialize the PSR workflow

The agent will:
- Read the workflow specification → execute Sub-workflow F
- Guide you through creating the project skeleton (PROJECT.md + CLAUDE.md + all directories)
- In all subsequent conversations, the agent auto-recovers PSR workflow state from CLAUDE.md

### Create Sub-Agents (Optional)

Create 3 sub-agents in Trae IDE (or any editor that supports sub-agents):
- **PSR-Researcher** — Researcher (see `PSRWORKFLOW/en/Agent-01-researcher.md`)
- **PSR-Reviewer** — Reviewer (see `PSRWORKFLOW/en/Agent-02-code-reviewer.md`)
- **PSR-Fixer** — Fixer (see `PSRWORKFLOW/en/Agent-03-fixer.md`)

The workflow works fine without sub-agents — the main agent will prompt you to manually take over the corresponding steps when needed.

---

## Directory Structure Overview

```
.planning/
├── WORKFLOW.md                  # ★ Workflow specification (core definition of PSR)
├── DOCUMENT-SPECS.md            # ★ Document format specification (structure & required fields)
├── PROJECT.md                   # Project vision, design summary, constraints, architecture direction
├── PROJECT-RESEARCH.md          # Project-level codebase research (optional)
├── FRAMEWORK-REVIEW.md          # Framework review report
├── research/
│   └── PITFALLS.md              # Pitfall list (known fatal issues + prevention strategies)
├── codebase/                    # Codebase analysis snapshots (human reference, optional)
└── milestones/                  # Milestone-level documents
    └── V1/
        ├── ROADMAP.md           # Phase breakdown + dependencies + success criteria
        ├── REQUIREMENTS.md      # Requirements list + traceability table
        ├── STATE.md             # State tracking (current Phase, progress, decision records)
        ├── RESEARCH.md          # Milestone-level macro impact analysis
        ├── SUMMARY.md           # Milestone summary (created at wrap-up)
        └── phases/
            └── 01-name/
                ├── 01-CONTEXT.md        # Discussion conclusions + architecture decisions
                ├── 01-DISCUSSION-LOG.md # Discussion process record
                ├── 01-RESEARCH.md       # Phase research report
                ├── 01-PLAN-01.md        # Execution plan (Wave 1)
                ├── 01-REVIEW.md         # Code review report
                ├── 01-UAT.md            # User acceptance test checklist
                └── 01-SUMMARY.md        # Phase execution summary
```

---

## Notes

1. **CLAUDE.md is the single source of rules** — sub-agents read behavioral standards from here; switching projects means changing one file
2. **Never skip research** — Step 3 forces codebase scanning, prevents writing code without understanding current state
3. **Never skip review** — Step 6 forces checking against architecture constraints, violations never accumulate
4. **Deferred fixes are never lost** — unfixable bugs are recorded in SUMMARY.md, subsequent Phases auto-inherit in Step 1
5. **Documents are the state** — sub-agents are judged by file output, not chat messages
6. **Add `.planning/` to `.gitignore`** — planning docs are local, not committed with code (or decide for yourself)

---

## Language Support

- English version: This file + all docs under `PSRWORKFLOW/en/`
- Chinese version: See [`PSRWORKFLOW/ZH/`](ZH/) directory
