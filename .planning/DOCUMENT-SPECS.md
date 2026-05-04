# DOCUMENT-SPECS — Document Format Specification

> This document defines naming rules, section structures, and required fields for all documents under `.planning/`.
> Before creating or modifying any `.planning/` document, you must first read the corresponding specification section in this document.

---

## General Rules

### File Naming Overview

**Project-level Documents (placed in `.planning/` root directory):**

| Document | Naming | Location |
|----------|--------|----------|
| Workflow Spec | `WORKFLOW.md` | `.planning/WORKFLOW.md` |
| Document Format Spec | `DOCUMENT-SPECS.md` | `.planning/DOCUMENT-SPECS.md` |
| Project Description | `PROJECT.md` | `.planning/PROJECT.md` |
| Project-level Research | `PROJECT-RESEARCH.md` | `.planning/PROJECT-RESEARCH.md` (optional, PSR-Researcher project-level scan output) |
| Pitfall List | `PITFALLS.md` | `.planning/research/PITFALLS.md` |
| Framework Review | `FRAMEWORK-REVIEW.md` | `.planning/FRAMEWORK-REVIEW.md` |

**Milestone-level Documents (placed under `.planning/milestones/VN/`, VN is milestone number e.g., V1, V2):**

| Document | Naming | Example |
|----------|--------|---------|
| Roadmap | `ROADMAP.md` | `.planning/milestones/V1/ROADMAP.md` |
| Requirements List | `REQUIREMENTS.md` | `.planning/milestones/V1/REQUIREMENTS.md` |
| State Tracking | `STATE.md` | `.planning/milestones/V1/STATE.md` |
| Milestone Research | `RESEARCH.md` | `.planning/milestones/V1/RESEARCH.md` |
| Milestone Summary | `SUMMARY.md` | `.planning/milestones/V1/SUMMARY.md` |

**Phase-level Documents (placed under `.planning/milestones/VN/phases/0N-name/`, N is Phase number, XX is Plan number):**

| Document | Naming | Example |
|----------|--------|---------|
| Discussion Conclusions | `0N-CONTEXT.md` | `03-CONTEXT.md` |
| Discussion Log | `0N-DISCUSSION-LOG.md` | `03-DISCUSSION-LOG.md` |
| Phase Research | `0N-RESEARCH.md` | `03-RESEARCH.md` |
| Execution Plan | `0N-PLAN-XX.md` | `03-PLAN-01.md` |
| Code Review | `0N-REVIEW.md` | `03-REVIEW.md` |
| User Testing | `0N-UAT.md` | `03-UAT.md` |
| Phase Summary | `0N-SUMMARY.md` | `03-SUMMARY.md` |

**Reference Documents (project maintained, workflow does not require reading):**

| Document | Location |
|----------|----------|
| Architecture Design | `.planning/research/ARCHITECTURE.md` |
| Feature Analysis | `.planning/research/FEATURES.md` |
| Tech Stack | `.planning/research/STACK.md` |
| Research Summary | `.planning/research/SUMMARY.md` |
| Codebase Snapshots | `.planning/codebase/ARCHITECTURE.md` etc. |

### Metadata Header

Each Phase-specific document starts with YAML front matter:

```yaml
---
phase: N
created: YYYY-MM-DDTHH:MM
updated: YYYY-MM-DDTHH:MM
---
```

### Content Rules

- All comments use Chinese
- References to other documents or files use relative paths
- Decision numbering format: `D-01`, `D-02`... (independently numbered per Phase)

---

# Project-level Documents

---

## PROJECT.md — Project Description

**Purpose:** Records the project's core design, constraints, and architecture direction. The "thought anchor" of the entire project. Any sub-agent obtains the full project picture from this document without requiring the user to repeat descriptions.

**Creator:** Main agent (Sub-workflow F)
**Maintainer:** Main agent (Sub-workflow D milestone wrap-up updates "Current Codebase State" section)
**Readers:** Main agent (Step 1, conversation recovery), PSR-Researcher sub-agent

**Principle:** Self-contained — no milestone lists, no Phase breakdowns, no requirement inventories. Those belong in milestone-level documents. No hard line limit, but aim for "a new reader can understand the full project picture in one read." Design summary can be detailed, constraints and decisions stay concise.

**Section Structure:**

```markdown
# {Project Name}

## Project Overview
<!-- One sentence + one paragraph description, the project's elevator pitch -->

## Design Summary
<!-- ★ Core body section. Complete project design content —
     game genre/theme/core mechanics/core loop/system composition/
     gameplay flow/worldbuilding/characters/progression/numerical direction...
     This is the complete description of "what this project specifically does."
     Length unlimited, as long as it's clear.
     Ingested from user's existing documents, or built up through guided discussion.
     Subsequent milestone agents get context from here. -->

## Core Value
<!-- Project's unique selling points, why it's worth doing -->

## Reference Works & Design References
<!-- List of reference games, each with key borrow points -->

## Constraints
<!-- Table: constraint type / content / reason -->

## Current Codebase State
<!-- Brief description of existing systems and implemented capabilities, updated each milestone wrap-up -->

## Architecture Design Direction
<!-- Signal-driven / ECS / JSON config and other core patterns -->

## Key Architecture Decisions
<!-- Table: decision / rationale / status.
     Project-level design philosophy choices, not changing with milestones -->

## Evolution Rules
<!-- How this document is maintained: when to update, who updates, what to update -->
```

**Required Fields:** Project Overview, Design Summary, Constraints, Current Codebase State.

---

## PROJECT-RESEARCH.md — Project-level Research Report

**Purpose:** Complete scan results of the entire project codebase. Optional, created only when Sub-workflow F assesses need.

**Creator:** PSR-Researcher sub-agent (Sub-workflow F — project-level research)
**Readers:** Main agent (conversation recovery), milestone-level PSR-Researcher

**Lifecycle:** Can be selectively updated or overwritten at each milestone wrap-up (Sub-workflow D).

**Section Structure:**

```markdown
# {Project Name} — Project Research

## TL;DR
<!-- 3-5 line summary -->

## Project Codebase Overview
<!-- List all modules by directory with their responsibilities -->

## Existing Infrastructure
<!-- Autoloads, config systems, startup flow, etc. -->

## Architecture Compliance Overview
<!-- Global check against CLAUDE.md architectural constraints -->

## Project-level Risks
<!-- Cross-milestone architectural risks -->
```

**Required Fields:** TL;DR, Project Codebase Overview.

---

## PITFALLS.md — Pitfall List

**Purpose:** Records known fatal pitfalls, prevention strategies, and corresponding Phases in project development. One of the review bases for PSR-Researcher and PSR-Reviewer.

**Location:** `.planning/research/PITFALLS.md`

**Creator:** Main agent (Sub-workflow F, creates empty template or initial list)
**Maintainer:**
- When new pitfalls discovered during any Phase execution, main agent appends
- After Sub-workflow C (framework review), confirmed new pitfalls are recorded
**Readers:**
- PSR-Researcher sub-agent (Step 3, checks item by item after scanning)
- PSR-Reviewer sub-agent (Step 6, checks against pitfalls when reviewing code)
- Main agent (Step 1 discussion, checks pitfalls this Phase might trigger)

**Section Structure:**

```markdown
# Pitfall List — {Project Name}

## 🔴 Fatal Pitfalls (P0 — Project could fail)
### N. {Pitfall Name}
- Warning Signs: {what symptoms}
- Prevention Strategies:
  - {specific measures}
  - ...
- Corresponding Phase: {which Phase needs attention}

## 🟡 Serious Pitfalls (P1 — Affects playability)
<!-- Same structure as above -->

## 🟢 Moderate Pitfalls (P2 — Affects development efficiency)
<!-- Same structure as above -->

## Pitfall-Phase Mapping Table
<!-- Table: pitfall / P-level / corresponding Phase / brief prevention -->
```

**Required Fields:** Pitfall-Phase Mapping Table.

---

## FRAMEWORK-REVIEW.md — Framework Review Report

**Purpose:** Output of Sub-workflow C (framework review), records global architecture health.

**Creator:** PSR-Reviewer sub-agent (framework review mode)
**Readers:** Main agent (reads after Sub-workflow C completes, converts to plan append)
**Lifecycle:** Each framework review overwrites previous report (same file, no accumulation)

**Section Structure:**

```markdown
# Framework Review Report — {Project Name}

**Review Date:** YYYY-MM-DD

## Architecture Health Score

| Dimension | Score (1-10) | Issues | Brief |
|-----------|-------------|--------|-------|
| Signal Communication Compliance | | | |
| System Decoupling | | | |
| Data Purity | | | |
| Code Style Consistency | | | |
| Document Consistency | | | |

## 🔴 Architecture-Level Issues
<!-- List item by item -->

## 🟡 Technical Debt
<!-- List item by item -->

## Improvement Roadmap
<!-- Arranged by priority -->
```

**Required Fields:** Architecture Health Score table, 🔴 and 🟡 at minimum have headers (can be empty).

---

# Milestone-level Documents

All milestone-level documents go under `.planning/milestones/VN/`.

---

## .planning/milestones/VN/ROADMAP.md — Milestone Roadmap

**Purpose:** Defines all Phase breakdowns, dependencies, and success criteria within this milestone.

**Creator:** Main agent (Sub-workflow G)
**Maintainer:** Main agent (Sub-workflow A adds new Phases)
**Readers:** Main agent (Step 1), PSR-Researcher sub-agent (milestone-level research)

**Section Structure:**

```markdown
# Roadmap — {Milestone Name}

**Milestone Goal:** {one sentence}

## Phase Overview
<!-- Table: # / Phase / Goal / REQ count / Success Criteria count -->

## Phase N: {Name}
<!-- Goal -->
<!-- Requirements: REQ-ID, ... -->
<!-- Success Criteria: 1. ... 2. ... -->
<!-- Dependencies: Phase M / None -->

## Dependency Graph
<!-- ASCII dependency diagram -->
```

**Required Fields:** Milestone Goal, Phase Overview table, each Phase's goal and success criteria.

---

## .planning/milestones/VN/REQUIREMENTS.md — Milestone Requirements List

**Purpose:** Single-point record of all requirements for this milestone, tracking implementation status.

**Creator:** Main agent (Sub-workflow G — creates lightweight skeleton)
**Filler:** Main agent (Step 10 — fills in this Phase's REQ entries and Traceability when each Phase completes)
**Maintainer:** Main agent (Sub-workflow B requirement changes)
**Readers:** Main agent (Step 1, Step 4), PSR-Researcher sub-agent

**Lifecycle:** Sub-workflow G creates lightweight skeleton (milestone design summary + empty Traceability table only).
Each REQ gets filled in during Step 10 when its Phase completes. This document gradually fills out as the milestone progresses.

**Section Structure:**

```markdown
# Requirements — {Milestone Name}

## Milestone Design Summary
<!-- ★ Core body section. Specific game content this milestone implements.
     Filled during Sub-workflow G creation. Aligned with PROJECT.md's design summary, but focused on this milestone's scope. -->

## v1 Requirements
### {Domain} — {Description}
<!-- Each REQ filled in during Step 10 when its Phase completes:
     - [x] **{DOMAIN}-NN**: {one-line description}
     REQ-ID format: domain prefix (SYS/WORLD/ITEM/BUILD/POP/PROD/PATH/ECON/UI)
     + two-digit number, e.g., SYS-01, POP-03.
     Step 10 also updates Traceability table.
     Sub-workflow G does NOT expand REQ — REQ details are decided per Phase in main workflow Steps 1-2. -->

## V1 Out of Scope (deferred from this milestone)
<!-- Deferred items identified during milestone discussion. Each must include:
     - Requirement name
     - Which version it's deferred to
     - Deferral reason -->

## v2 Requirements (deferred)
<!-- Subsequent version requirements with assigned REQ-IDs -->

## Out of Scope (permanently excluded)
<!-- Permanently out, with reasons -->

## Traceability
<!-- Table: REQ-ID / Requirement / Phase / Status.
     Sub-workflow G creates with header row only.
     Each Phase completion appends rows via Step 10. -->
```

**Required Fields:** Milestone Design Summary, Traceability table header (at Sub-workflow G time).
**Important:** Each deferred item in V1 Out of Scope must include a "deferral reason" — not just a title.
**REQ Fill Timing:** Not expanded during Sub-workflow G. Each Phase's Step 10 fills its REQs into v1 Requirements and appends to Traceability table.

---

## .planning/milestones/VN/STATE.md — Milestone State

**Purpose:** Workflow state tracking for this milestone. Main agent reads on each access to confirm current position.

**Creator:** Main agent (Sub-workflow G)
**Maintainer:** Main agent (Step 10, recovery flow, Sub-workflow D)
**Readers:** Main agent (each conversation start, Step 1)

**Section Structure:**

```markdown
# STATE — {Milestone Name}

**Last Updated:** YYYY-MM-DD HH:MM

## Current State
- Milestone: VN
- Current Phase: N (name)
- Phase Status: ⬜ Not started / 🟡 In progress / 🟢 Complete
- Current Step: {step number}-{step name}

## Phase Progress
<!-- Table: Phase / Name / Status / REQ count / Completion Date -->

## Decision Records
<!-- Key architecture decision summary (cross-Phase visible) -->

## Recent Actions
<!-- Completed and pending action list -->
```

**Required Fields:** Current State, Phase Progress table.

---

## .planning/milestones/VN/RESEARCH.md — Milestone Research

**Purpose:** Macro impact analysis for all Phases in this milestone.

**Creator:** PSR-Researcher sub-agent (Sub-workflow G)
**Readers:** Main agent (Steps 1-2), subsequent Phase PSR-Researchers

**Section Structure:**

```markdown
# Milestone VN: {Milestone Name} — Research

## TL;DR
<!-- 3-5 line summary, includes macro architecture recommendations -->

## Systems Affected Across All Phases
<!-- List systems that will be modified by multiple Phases, note which Phases affect them -->

## Signals/Interfaces to Reserve
<!-- What current infrastructure needs to reserve to support subsequent Phases -->

## Unified Architecture Decision Recommendations
<!-- Cross-Phase unified design decisions -->

## Milestone-level Risks
<!-- Check against PITFALLS.md, note milestone-level risks -->
```

**Required Fields:** TL;DR, Systems Affected Across All Phases.

---

## .planning/milestones/VN/SUMMARY.md — Milestone Summary

**Purpose:** Aggregate summary after milestone completion, recording deliverables and remaining items.

**Creator:** Main agent (Sub-workflow D)
**Readers:** Main agent (reference when entering next milestone), humans

**Section Structure:**

```markdown
# Milestone VN: {Milestone Name} — Execution Summary

## Status
<!-- ✅ Complete / ⚠️ Partially complete -->

## Phase Execution Overview
<!-- Table: Phase / Name / Status / REQ count / Files Delivered -->

## Deliverables List
<!-- Group by Phase, list all new/modified files and their purposes -->

## Requirement Coverage Overview
<!-- REQ-ID / Requirement / Phase / Status -->

## Architecture Decision Overview
<!-- Cross-Phase summary of all D-XX decisions and their implementation status -->

## Known Limitations & Remaining Items
<!-- Unimplemented requirements, deferred features, technical debt -->
<!-- Note which need to be handled in next milestone -->
<!-- Aggregate unresolved known limitation items from all Phase SUMMARYs -->

## Performance Metrics Summary
<!-- Key performance data -->
```

**Required Fields:** Phase Execution Overview, Requirement Coverage Overview.

---

# Phase-level Documents

All Phase-level documents go under `.planning/milestones/VN/phases/0N-name/`.

---

## CONTEXT.md — Discussion Conclusions

**Purpose:** Records Phase discussion stage conclusions, serving as decision basis for all subsequent steps.

**Creator:** Main agent (Steps 1-2)
**Readers:** Main agent (Step 4 planning), PSR-Researcher sub-agent (Step 3), PSR-Reviewer sub-agent (Step 6)

**Section Structure:**

```markdown
# Phase N: {Phase Name} — Context

## Requirement Confirmation
<!-- Per-item confirmation of this Phase's requirements listed in ROADMAP, noting consensus and boundaries.
     Each requirement assigned a REQ-ID (format: {DOMAIN}-NN, e.g., SYS-01, POP-03),
     assigned on the spot during Steps 1-2 discussion, transcribed to REQUIREMENTS.md in Step 10. -->

## Architecture Decisions
<!-- D-01: Decision Title -->
<!--   Decision Content -->
<!--   Rationale -->
<!-- D-02: ... -->

## Interface Conventions
<!-- Added/modified signals, SystemRegistry query interfaces, data class public properties for this Phase -->

## Data Format Conventions
<!-- JSON config fields, data structure definitions -->

## Interaction with Existing Systems
<!-- List existing system interfaces this Phase needs to call -->

## Gray Areas
<!-- Items not fully decided during discussion, deferred decisions, noting impact scope and deferral reason -->

## Risk Points
<!-- Check against PITFALLS.md for pitfalls this Phase might trigger -->
```

**Required Fields:** Requirement Confirmation, Architecture Decisions (at least 1), Interface Conventions, Interaction with Existing Systems.

---

## DISCUSSION-LOG.md — Discussion Log

**Purpose:** Records the Q&A process during discussion stage, preserving context for recovery and understanding decision origins.

**Creator:** Main agent (Steps 1-2)
**Readers:** Main agent (Step 1 when reading dependency Phases), conversation recovery flow

**Section Structure:**

```markdown
# Phase N: {Phase Name} — Discussion Log

## Q&A Records
<!-- Q1: User question / Main agent question -->
<!-- A1: Answer -->
<!-- Q2: ... -->

## Unplanned Requirements
<!-- Sub-workflow A records, or new requirements generated during execution -->

## Deferred Fixes
<!-- Step 9 records: issue description / source Phase / target Phase / priority -->
```

**Required Fields:** Q&A Records.

---

## RESEARCH.md — Phase Research Report

**Purpose:** Records codebase exploration results, providing intelligence for plan creation.

**Creator:** PSR-Researcher sub-agent (Step 3)
**Readers:** Main agent (Step 4 planning), PSR-Reviewer sub-agent (Step 6)

**Section Structure:**

```markdown
# Phase N: {Phase Name} — Research

## TL;DR
<!-- 3-5 line summary, includes core findings and key decision recommendations. Total report line count at end of paragraph. -->

## Affected Files
<!-- Categorized as new/modified/read-only, list file paths -->

## Signals to Add
<!-- List signal names and signatures to add -->

## Interfaces to Modify
<!-- List existing System methods to add/modify -->

## Autoloads to Add
<!-- If any, note name and purpose -->

## Existing Code to Reuse
<!-- Existing code this Phase can reuse -->

## Potential Risks
<!-- Check against PITFALLS.md item by item -->

## Technical Solution Suggestions
<!-- Technical implementation suggestions for gray areas -->
```

**Required Fields:** TL;DR, Affected Files, Signals to Add, Interfaces to Modify.

---

## PLAN-XX.md — Execution Plan

**Purpose:** Single Wave execution scheme.

**Creator:** Main agent (Step 4)
**Readers:** Main agent (Step 5 execution), PSR-Reviewer sub-agent (Step 6), Main agent (Step 8 extract verification conditions)

**Section Structure:**

```markdown
# PLAN-XX: {Plan Name}

## Requirements Covered
<!-- REQ-ID list -->

## Dependencies
<!-- Preceding PLAN number or completed Phases -->

## Inputs
<!-- List of files that must be read before execution -->

## Outputs
<!-- List of files to be added/modified after execution -->

## Execution Steps
<!-- 1. Create xxx -->
<!-- 2. Modify xxx -->
<!-- 3. ... -->

## Impact of Modifying Existing Files
<!-- If modifications involved, note files needing impact scope confirmation and their callers -->

## Verification Conditions
<!-- How to verify correctness after this Wave completes -->

## Execution Record
<!-- Main agent appends after execution -->
```

**Required Fields:** Requirements Covered, Outputs, Verification Conditions.

---

## REVIEW.md — Code Review Report

**Purpose:** Check code item by item against architectural constraints.

**Creator:** PSR-Reviewer sub-agent (Step 6)
**Readers:** PSR-Fixer sub-agent (Step 7), Main agent (confirm no 🔴 before Step 8)

**Section Structure:**

```markdown
# Phase N: {Phase Name} — Code Review

## 🔴 Must Fix
<!-- Each item:
- File: {path}:{line}
- Violation: {what constraint violated}
- Current: {current code}
- Fix: {what should be done}
-->

## 🟡 Suggested Fix
<!-- Doesn't violate architecture constraints but doesn't follow best practices -->

## 🟢 Passed Items
<!-- Check against PLAN verification conditions item by item -->

## Summary
<!-- Total N items, 🔴 M, 🟡 K, 🟢 P -->

## Fixer Execution Record
<!-- PSR-Fixer sub-agent appends -->
```

**Required Fields:** 🔴, 🟡, 🟢 at minimum have headers (can be empty).

---

## UAT.md — User Acceptance Test Checklist

**Purpose:** Compiled from each PLAN's "verification conditions," for manual testing.

**Creator:** Main agent (Step 8)
**Readers:** User (test execution), Main agent (Steps 9 and 10)

**Section Structure:**

```markdown
# Phase N: {Phase Name} — UAT

## Test Environment
<!-- Prerequisites: version, launch method, initial state -->

## Test Items
<!-- 1. {Test Name} -->
<!--    Expected: {expected result} -->
<!--    Source: 0N-PLAN-XX Verification Condition -->
<!--    Result: ⬜ Pass / ❌ Fail (user fills in) -->

## Test Results Summary
<!-- Main agent summarizes -->
```

**Required Fields:** Test Items (at least 1). Each test item must note its source PLAN.

---

## SUMMARY.md — Phase Execution Summary

**Purpose:** One-page summary after Phase completion, letting subsequent Phases and humans quickly understand what was delivered.

**Creator:** Main agent (Step 10)
**Readers:** Main agent (subsequent Phase Step 1 prioritized reading), humans

**Section Structure:**

```markdown
# Phase N: {Phase Name} — Execution Summary

## Status
<!-- ✅ Complete / ⚠️ Partially complete (note unimplemented items) -->

## Plan Execution Overview
<!-- Table: Wave / Plan / Status / File count -->

## Deliverables List
<!-- Categorized list of all new/modified files and their purposes -->

## Requirement Coverage
<!-- REQ-ID / Requirement / Status (✅/⚠️/❌) -->

## Architecture Decision Implementation
<!-- D-XX: Decision / Status -->

## Code Review Summary
<!-- See 0N-REVIEW.md — 🔴/🟡/🟢 counts -->
<!-- If remaining 🟡 or ⚠️, note here -->

## Known Limitations
<!-- Unimplemented requirements, deferred features, technical debt, cross-Phase deferred fix items -->
<!-- Include gray areas from CONTEXT.md and future ideas discovered during discussion that exceed this Phase's scope → note target Phase or "deferred to subsequent milestone" -->

### Deferred Fix Items (list)
<!-- Format: issue description / source Phase / target Phase / priority (P0-P2) -->
<!-- Example: Kitchen drainage logic needs sewer system integration / Phase 2 / Phase 5 / P1 -->
```

**Required Fields:** Plan Execution Overview, Requirement Coverage, Code Review Summary.
