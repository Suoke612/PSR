﻿﻿# WORKFLOW — Universal Development Workflow Specification

> This document defines the standard Phase-driven development process. Applicable to any project following a "Discuss → Research → Plan → Execute → Review → Test → Complete" cycle.

---

## 0. Three-Layer Architecture

This project uses a **Project → Milestone → Phase → Plan** hierarchy:

| Layer | Responsibility | Lifecycle | Document Location |
|-------|---------------|-----------|-------------------|
| **Project** | Vision, core values, architectural constraints | Entire project | `.planning/PROJECT.md` |
| **Milestone** | Version scope: which Phases, which requirements | One version cycle | `.planning/milestones/VN/` |
| **Phase** | Single feature module: discuss → implement → deliver | Days to weeks | `.planning/milestones/VN/phases/0N-name/` |
| **Plan** | Smallest execution unit within a Phase (1-3 files) | Minutes to hours | `0N-PLAN-XX.md` (inside Phase directory) |

**Key Principles:**
- PROJECT.md is self-contained — project vision and constraints, no milestone lists or requirement inventories
- Milestone Phase breakdown and requirements are managed separately under `.planning/milestones/VN/`
- Each new milestone begins by creating milestone directory and documents via Sub-workflow G

---

## 1. Main Workflow (10 Steps)

Execute in strict order when entering a new Phase or continuing the current Phase.

### Step Checklist

| Check Condition | When Not Done | When Done |
|----------------|---------------|-----------|
| `0N-CONTEXT.md` doesn't exist | **Enter discussion mode** (Steps 1-2) | → Next step |
| `0N-RESEARCH.md` doesn't exist | **Launch PSR-Researcher sub-agent** (Step 3) | → Next step |
| `0N-PLAN-*.md` doesn't exist | **Create plans** (Step 4) | → Next step |
| PLAN not fully executed | **Execute next PLAN** (Step 5) | → Next step |
| All PLANs executed | **Launch PSR-Reviewer → create/update `0N-REVIEW.md`** (Step 6) | → Next step |
| REVIEW.md contains 🔴 items | **Launch PSR-Fixer sub-agent** (Step 7) | → Next step |
| UAT not executed | **Create UAT.md → notify user to test** (Step 8) | → Next step |
| User feedback indicates issues | **Fix based on feedback** (Step 9) → return to Step 6 | → Next step |
| All UAT passed | **Confirm completion** (Step 10) | Phase complete |

---

### Steps 1-2: Discussion & Gray Area Clearing

**Trigger:** CONTEXT.md doesn't exist.

**Discussion Granularity Principle:** Exhaustively design every system and interface in detail. Discuss until **every decision is concrete enough to directly write code**. Uncertain data fields, process steps, interaction conventions → keep asking, leave no gray areas.

**Main agent executes:**

1. Read `.planning/PROJECT.md` to understand project vision and constraints
2. Find current milestone from PROJECT.md (e.g., V1), read `.planning/milestones/VN/STATE.md` to confirm current state
3. Read `.planning/milestones/VN/ROADMAP.md` to confirm Phase scope and dependencies
4. Read `.planning/milestones/VN/REQUIREMENTS.md` to confirm requirement details
5. Read all completed Phase documents that the current Phase depends on — **prioritize SUMMARY.md**, then read CONTEXT.md and REVIEW.md as needed (understand existing decisions and lessons)
   - **Special attention:** Check SUMMARY.md's "Known Limitations" for deferred fix items targeting this Phase — these are inherited fix items from previous Phases that must be included in this Phase's execution plan.
6. Read the project's CLAUDE.md or equivalent architecture constraints document
7. Read `.planning/research/PITFALLS.md` (if it exists)
8. Ask the user questions covering the following dimensions (pursue each until no gray areas remain):
   - **Feature boundaries:** What this Phase does/doesn't do, inputs and outputs
   - **Data fields:** Field names/types/defaults/constraints for each data class
   - **Process steps:** How many steps in the core flow, preconditions/actions/postconditions for each step
   - **Interface conventions:** New/modified signal names and signatures, System public method parameters and return values
   - **Interaction conventions:** Call relationships between this Phase and existing systems — who calls whom, how, when
   - **Data formats:** JSON config file schemas, field meanings, example values
   - **Edge cases:** When not to trigger, when to error, when to degrade gracefully
9. Confirm requirements with user item by item, **assign REQ-IDs on the spot**
   (Format: `{DOMAIN}-NN`, domain prefixes: SYS/WORLD/ITEM/BUILD/POP/PROD/PATH/ECON/UI)
10. Proactively explore gray areas — based on discussed content, infer potential edge cases, exceptions, and implicit interactions with other systems the user may have missed, ask user to confirm
11. Create `0N-CONTEXT.md` (discussion conclusions, including architecture decision numbers D-01~D-N and requirement list with assigned REQ-IDs)
12. Create `0N-DISCUSSION-LOG.md` (discussion process record)
13. Confirm with user: **"If you don't need to discuss more for this Phase, let me know, and I'll start Step 3 (Research)."**
    - If user has more to add → return to Step 8 to continue discussion
    - If user confirms done → discussion phase complete, CONTEXT.md and DISCUSSION-LOG.md are finished

**Required documents to read:**
- `.planning/PROJECT.md`
- `.planning/milestones/{current_milestone}/STATE.md`
- `.planning/milestones/{current_milestone}/ROADMAP.md`
- `.planning/milestones/{current_milestone}/REQUIREMENTS.md`
- `.planning/milestones/{current_milestone}/RESEARCH.md` (if milestone research is complete)
- Dependency Phase's SUMMARY.md → CONTEXT.md → REVIEW.md (in priority order)
- Project's CLAUDE.md
- `.planning/research/PITFALLS.md` (if exists)

---

### Step 3: Research & Exploration

**Trigger:** CONTEXT.md exists but RESEARCH.md doesn't.

**Executor: PSR-Researcher sub-agent.**

The PSR-Researcher sub-agent scans the codebase, analyzes impact scope, checks PITFALLS, and outputs a research report. The main agent simply tells it the current Phase directory and CONTEXT.md path. PSR-Researcher writes its findings to `0N-RESEARCH.md` in the Phase directory.

---

### Step 4: Plan Creation

**Trigger:** CONTEXT.md + RESEARCH.md exist but PLAN-*.md doesn't.

**Main agent executes:**

1. Read `0N-CONTEXT.md` (discussion conclusions)
2. Read `0N-RESEARCH.md` (research conclusions)
3. Break down into N Waves (each Wave has independently verifiable output)
4. One PLAN file per Wave (`0N-PLAN-01.md`, `0N-PLAN-02.md`...)

**PLAN Decomposition Principles:**
- Data definitions before system logic (create data classes first, then processing systems)
- Independent PLANs can be marked as no-dependency (execution order arbitrary, main agent executes sequentially)
- Each PLAN produces no more than 3 files
- If a PLAN involves modifying existing files, mark "impact confirmation needed" in the PLAN (reference Step 3 RESEARCH.md's "Affected Files" section; if RESEARCH.md doesn't cover the file, note that Step 5 needs supplementary research)

---

### Step 5: Plan Execution

**Trigger:** PLAN files exist and not marked "completed."

**Main agent rules per PLAN:**

1. Read the PLAN file
2. If PLAN involves modifying existing files → **confirm impact scope first**:
   - Check Step 3 RESEARCH.md's "Affected Files" section:
     - **Covered:** earlier PLANs in this Phase haven't modified the file or its callers → trust Step 3 research, proceed directly
     - **Not covered:** or earlier PLANs have already modified related code → launch PSR-Researcher for supplementary research, modify after confirmation
3. Reference existing code templates (search adjacent files, follow existing patterns)
4. Strictly follow project architectural constraints
5. After completion, append execution record at the end of the PLAN file:

```markdown
## Execution Record
- New files: xxx.gd (line count)
- Modified files: xxx.gd (+N lines, change description)
- Decisions: (record architecture-related judgments here)
- Not implemented: (if content was deferred, note and explain reason)
```

---

### Step 6: Review

**Trigger:** All PLANs executed.

**Executor: PSR-Reviewer sub-agent.**

The PSR-Reviewer sub-agent checks all new and modified code against architectural constraints and outputs a graded review report. The main agent simply tells it the Phase directory path. PSR-Reviewer writes the report to `0N-REVIEW.md` in the Phase directory (creates if not exists, overwrites if exists), with 🔴/🟡/🟢 three-level grading.

---

### Step 7: Fix Blockers

**Trigger:** REVIEW.md contains 🔴 items.

**Executor: PSR-Fixer sub-agent.**

The PSR-Fixer sub-agent reads 🔴 items from REVIEW.md, fixes violations one by one, verifies correctness, and appends execution records to REVIEW.md.

After fixing, the main agent reads execution records and confirms fixes are correct. If ⚠️ items exist (items the fixer couldn't fix), the main agent evaluates and decides on handling.

**Loop Rules:**
- After PSR-Fixer completes, main agent re-reads REVIEW.md
- If 🔴 items remain → launch PSR-Fixer again (max 3 rounds)
- If 🔴 items still remain after 3 rounds → main agent takes over, manual fix
- If all 🔴 become ⚠️ → main agent evaluates whether ⚠️ needs architectural decisions

---

### Step 8: User Acceptance Testing

**Trigger:** REVIEW.md has no 🔴 items.

**Main agent executes:**

1. Extract verification conditions from all PLAN files
2. Create `0N-UAT.md` (User Acceptance Test checklist)
3. Clearly inform user of test items and expected results
4. Wait for user feedback

---

### Step 9: Error Fixing

**Trigger:** User testing discovers issues.

**Main agent executes:**

1. Locate issues based on user feedback
2. Determine if fixable within current Phase:
   - **Fixable** → simple fix (≤1 file): main agent directly modifies / multi-file fix: launch PSR-Fixer sub-agent → execute Step 6 (re-review)
   - **Not fixable** (depends on not-yet-implemented Phase, or requires architecture-level decision) → record deferred fix:
     - Append "## Deferred Fixes" entry to DISCUSSION-LOG.md
     - Mark deferred fix in SUMMARY.md "Known Limitations" (issue + source Phase + target Phase + priority)
     - If new system requirement discovered → append to `.planning/milestones/VN/REQUIREMENTS.md` (find corresponding domain group, append in REQ-ID format, phase column in Traceability table points to target Phase)
     - If recurring trap pattern → append to .planning/research/PITFALLS.md
     - **Continue execution** (doesn't block current Phase pass judgment)

---

### Step 10: Confirm Completion

**Trigger:** All user tests pass.

**Main agent executes:**

1. Create `0N-SUMMARY.md`: Phase overview, requirement coverage, deliverables, code review summary
2. Update `.planning/milestones/{current_milestone}/STATE.md`: Phase status → 🟢 complete, point to next Phase, append decision records
3. Update `.planning/milestones/{current_milestone}/REQUIREMENTS.md`:
   - Transcribe REQ-IDs assigned in CONTEXT.md into v1 Requirements corresponding domain group (marked as [x])
   - Append all REQ rows for this Phase in Traceability table
4. Generate Conventional Commits format commit message, **show to user for confirmation** then commit to local repository

   **Commit message example:**
   ```
   feat(phase-3): Citizen & Economy System

   Added:
   - scripts/data/citizen_data.gd - Citizen data class
   - scripts/systems/citizen_system.gd - Citizen management system

   Modified:
   - scripts/systems/signal_bus.gd - Added citizen_spawned and 2 other signals

   Review: see .planning/milestones/V1/phases/03-citizen-economy/03-REVIEW.md
   ```

---

## 2. Sub-Workflows

### Sub-workflow A: Phase Adjustment

**Trigger:** User needs to add requirements, re-discuss, or split the current in-progress Phase.

First determine user intent, then execute the corresponding branch.

#### Branch 1: Append Requirements

**Trigger:** User proposes new requirements for the current Phase.

1. Append to DISCUSSION-LOG.md
2. Determine ownership: current Phase or new Phase?
3. If current Phase → launch PSR-Researcher to confirm impact → create new PLAN (number +1) → execute common wrap-up → return to main workflow checklist
4. If new Phase → execute common wrap-up → handle after Phase completion
5. **Never skip the research phase to write code directly**

#### Branch 2: Re-discuss

**Trigger:** User says "re-discuss Phase N" or thinks current discussion conclusions need adjustment.

1. Read existing `0N-CONTEXT.md`, `0N-DISCUSSION-LOG.md`, `0N-RESEARCH.md`
2. Re-discuss with user (following Steps 1-2 discussion granularity principle)
3. Overwrite `0N-CONTEXT.md` (new conclusions replace old ones)
4. Append to `0N-DISCUSSION-LOG.md` (mark `## Re-discussion (YYYY-MM-DD)`)
5. Use ask tool to prompt user: **"Are the old research report and plans still valid?"**
   - User chooses "Yes" → execute common wrap-up → return to main workflow checklist
   - User chooses "No" → delete `0N-RESEARCH.md` + all `0N-PLAN-*.md` + `0N-REVIEW.md` (if exists) → execute common wrap-up → return to main workflow checklist (checklist finds RESEARCH doesn't exist → triggers Step 3)
6. **Never skip the research phase to write code directly**

#### Branch 3: Phase Split

**Trigger:** User considers the current Phase too large and needs to split it into multiple Phases.

1. Discuss split plan with user (based on gray area analysis, dependency assessment, complexity evaluation)
2. After confirming the split plan, execute the following:
   a. Create new Phase directories (`0N-name/`)
   b. Create new Phase's CONTEXT.md and DISCUSSION-LOG.md (migrate relevant content from original Phase)
   c. Update ROADMAP.md: replace original Phase with split Phases
   d. Update STATE.md: update Phase progress table + recent action records
   e. Update REQUIREMENTS.md: reassign original Phase's REQ-IDs to new Phases
   f. After confirming all content has been fully migrated, delete the original Phase directory
3. Execute common wrap-up
4. Proceed to discuss the first split Phase

#### Common Wrap-up (shared by all branches)

After each branch completes, check whether the following documents need updates:

| Document | Update Condition |
|----------|-----------------|
| DISCUSSION-LOG.md | Always update (record discussion process and decisions) |
| STATE.md recent actions | Always update (record this operation) |
| ROADMAP.md | When Phase structure or dependencies change |
| REQUIREMENTS.md Traceability | When REQ assignments change |

---

### Sub-workflow B: Project Modification

**Trigger:** User needs to modify content of a completed Phase.

**Flow:**
1. Read all CONTEXT, PLAN, REVIEW, SUMMARY documents of the target Phase
2. Discuss modification scope and impact
3. Modify related documents (append revision records to DISCUSSION-LOG.md)
4. If new code needed → launch PSR-Researcher → create/modify PLAN → return to main workflow checklist
5. If only document modification → main agent directly updates
6. After completion, update target Phase's SUMMARY.md (append revision record with date and description)

---

### Sub-workflow C: Framework Review

**Trigger:** User says "review framework" or "check architecture health."

**Flow:**
1. Launch PSR-Reviewer sub-agent (specify framework review mode)
2. PSR-Reviewer reviews entire project, outputs report to `.planning/FRAMEWORK-REVIEW.md`
3. Main agent reads report, marks items needing fixes
4. Items needing fixes → convert to plan append (Sub-workflow A)
5. Notable traps → record in .planning/research/PITFALLS.md

---

### Sub-workflow D: Milestone Wrap-Up

**Trigger:** User says "milestone complete" or all Phases executed.

**Flow:**
1. Read all Phase SUMMARY.md files for current milestone, aggregate into milestone `.planning/milestones/VN/SUMMARY.md`
2. Update `.planning/PROJECT.md`: current codebase state, verified requirements, implemented capabilities
3. Clean up STATE.md history, keep decision summaries
4. Update static snapshot documents under codebase/ (if they exist)
5. Generate milestone summary, show to user for confirmation

---

### Sub-workflow E: Knowledge Base Update

**Trigger:** User says "update knowledge base."

**Flow:**
1. Scan current codebase directory structure
2. Cross-reference each document topic in `.planning/codebase/` directory, confirm which need updates
3. Update outdated document content
4. Update date at top of documents

**Note:** During daily development, PSR-Researcher sub-agent uses real-time scanning strategy and doesn't rely on static codebase snapshots. Knowledge base updates are only maintained as human-readable reference documents.

---

### Sub-workflow F: Project Initialization

**Trigger:** User starts a new project.

#### Entry Judgment

Before asking questions, first determine the user input type:

- **Mode A (Document Ingestion):** User provides existing design documents or detailed descriptions (e.g., "Here's the game I want to make, design doc below...")
- **Mode B (Guided Discussion):** User has only a one-liner or vague idea (e.g., "I want to make a coffee shop simulation game")
- **Mode C (Project Reconnection):** User already has `.planning/` directory and PROJECT.md, needs to re-examine project direction

#### Mode A: Document Ingestion

```
1. Read all documents/descriptions provided by user
2. Following PROJECT.md section structure, extract information from documents to fill each section:
   - Design Summary ← extract complete content like game type/mechanics/systems/gameplay from documents
   - Project Overview ← condense from design summary into one elevator pitch paragraph
   - Core Value ← identify core selling points from documents
   - Reference Works ← if documents mention reference games
   - Constraints ← if documents mention technical direction
3. Confirm with user section by section: "My understanding of your design is this, correct?"
4. For parts not covered by documents (tech stack, architecture style, performance targets),
   switch to Mode B with guided questions to supplement
5. Compile complete content, write to PROJECT.md
6. Create directory structure and CLAUDE.md
```

#### Mode B: Guided Discussion

Ask questions from macro to micro in three layers, summarize and confirm after each layer before moving to the next:

**Layer 1: Macro Positioning (3-5 questions)**
- What is the game genre and theme?
- Target platform and perspective?
- Core experience — what does the player do? What's the emotional tone?
- Describe this game to a friend in one sentence?
→ Compile into "Project Overview" and "Core Value" sections

**Layer 2: Meso Systems (5-8 questions)**
- What's the core loop? (Player does what → gets what → spends what → continues doing what)
- What are the main systems? (Name each and describe in one sentence)
- Feedback chains between systems?
- What games do you reference? What do you borrow from them?
→ Compile into "Design Summary" and "Reference Works" sections

**Layer 3: Micro Engineering (3-5 questions)**
- Tech stack? (Engine/Language/Platform)
- Performance targets?
- Architecture preference? (Signal-driven/ECS/Data-driven)
- Pixel art or hand-drawn?
→ Compile into "Constraints" and "Architecture Design Direction" sections

#### Mode C: Project Reconnection

**Trigger:** User already has `.planning/` directory and `PROJECT.md`, but encounters one of the following:
- Major shift in project direction (e.g., from RPG to simulation)
- Need to re-examine and adjust project vision and constraints
- Planning inherited from another project/template needs re-evaluation
- Resuming after extended hiatus, need to reconfirm project direction

**Flow:**
1. Read existing `.planning/PROJECT.md`, summarize current project state for user
2. Read all milestone directories (`.planning/milestones/VN/`), list each milestone's `STATE.md` status (completed/in-progress/not started)
3. Ask user:
   - What directions/assumptions have changed?
   - Which constraints need adjustment?
   - Which milestones are still valid?
4. Update `PROJECT.md` based on user feedback (rewrite design summary or constraints section)
5. Assess impact of changes on milestones:
   - Completed milestones → unaffected (preserved as-is)
   - In-progress milestones → mark "pending reconnection" in `STATE.md`, remind user to reconnect that milestone
   - Not-started milestones → mark "pending re-evaluation against new PROJECT.md" in `STATE.md`
6. Prompt user: "Project reconnected. To adjust milestones, say 'reconnect milestone VN'."

#### Shared Wrap-Up

**Directory Structure:**
```
.planning/
├── WORKFLOW.md          ← Copy from universal template
├── DOCUMENT-SPECS.md    ← Copy from universal template
├── PROJECT.md           ← New, containing complete design content
├── research/            ← Directory
│   └── PITFALLS.md      ← New (can be empty template with trap-Phase mapping table)
├── codebase/            ← Directory (empty initially, Sub-workflow E fills it)
└── milestones/          ← Directory (empty, waiting for Sub-workflow G to create specific milestones)
```

1. Read CLAUDE-template.md as template, create project-specific CLAUDE.md
2. Create all above files and directories
3. **Do NOT create ROADMAP.md / REQUIREMENTS.md / STATE.md** — these belong to the milestone level, created by Sub-workflow G
4. **Check whether PROJECT-RESEARCH.md exists:**
   - **Exists →** use ask tool to prompt user: "Found existing project-level research report. Has the project codebase undergone significant changes that require a re-scan?"
     - User chooses "Yes" → launch PSR-Researcher to redo project-level scan, overwrite `.planning/PROJECT-RESEARCH.md`
     - User chooses "No" → skip, continue normal reconnection
   - **Doesn't exist →** launch PSR-Researcher for project-level scan, output to `.planning/PROJECT-RESEARCH.md`

**After initialization, prompt user:** "Project skeleton created. If you have more detailed design documents, you can add them to PROJECT.md's design summary at any time. If no further adjustments needed, tell me 'start milestone V1' to enter Sub-workflow G."

---

### Sub-workflow G: Milestone Launch

**Trigger:** User says "start milestone VN" or milestone directory is empty.

#### Entry Judgment

Same as Sub-workflow F, first determine the user input type:

- **Mode A (Document Ingestion):** User provides milestone planning documents or detailed descriptions
- **Mode B (Guided Discussion):** User starts from scratch, needs AI guided discussion
- **Mode C (Milestone Reconnection):** User already has milestone directory, needs to adjust scope or direction

#### Shared First Step: Read Context

```
1. Read .planning/PROJECT.md — focus on "Design Summary" and "Constraints"
   → Understand the full project picture, don't ask user to re-describe what the project is
2. If PROJECT-RESEARCH.md exists, read it too
3. If current milestone is not V1, read the previous milestone's .planning/milestones/V{N-1}/SUMMARY.md
4. If .planning/milestones/VN/RESEARCH.md exists, read it too
```

#### Mode A: Document Ingestion

```
1. Read milestone planning provided by user
2. Extract Phase list and high-level goals from documents
3. Cross-check item by item against PROJECT.md constraints for consistency
4. Gap filling: use guided questions to supplement uncovered Phases
```
<!-- Note: Don't expand REQ details at this stage. REQ details belong to main workflow Steps 1-2, discussed per Phase. -->

#### Mode B: Guided Discussion

Starting from PROJECT.md's design summary, discuss this milestone's scope:

**Layer 1: Milestone Goals (2-3 questions)**
- What's the core deliverable of this version? What can players experience?
- From PROJECT.md's design summary, which systems are in scope for this milestone?
→ Compile into "Milestone Design Summary" section

**Layer 2: Phase Breakdown (3-5 questions)**
- How to break down the above systems into independent Phases? (One sentence goal per Phase)
- Dependency relationships between Phases?
- Success criteria for each Phase?
→ Create ROADMAP.md
<!-- Milestone discussion ends here. REQ details are not expanded here — left for main workflow Steps 1-2 per Phase.
     REQUIREMENTS.md is created as a lightweight skeleton, each REQ is filled in when its Phase completes. -->
→ Create REQUIREMENTS.md lightweight skeleton (includes milestone design summary + empty Traceability table)
→ Create STATE.md

#### Mode C: Milestone Reconnection

**Trigger:** User already has milestone directory (`.planning/milestones/VN/`), but encounters one of the following:
- Milestone scope has gotten out of control (too large/too small, needs significant Phase re-split)
- Implementation difficulties require scope reduction
- User's thinking has changed, Phase goals and dependencies need adjustment
- Project plan changes impact this milestone
- Resuming after extended hiatus, need to reconfirm milestone direction

**Flow:**
1. Read `.planning/milestones/VN/ROADMAP.md`, `REQUIREMENTS.md`, `STATE.md`, summarize current state for user
2. Read all Phase `SUMMARY.md` (completed) and `CONTEXT.md` (in-progress), summarize completed content and current progress
3. Ask user:
   - What assumptions have changed?
   - How does the scope need to adjust (expand/shrink/pivot)?
   - Which Phases are still valid?
4. Based on user feedback:
   - Update `ROADMAP.md`: adjust Phase breakdown, dependencies, success criteria
   - Update `REQUIREMENTS.md`: adjust requirement scope and Out of Scope
   - Update `STATE.md`: reset affected Phase status to ⬜, record reconnection action in recent actions
   - For in-progress Phases: append "## Reconnection Record" section at top of CONTEXT.md, noting original conclusions may be invalid
5. Launch PSR-Researcher sub-agent to update `.planning/milestones/VN/RESEARCH.md`
6. Prompt user: "Milestone VN reconnected. Affected Phases need re-discussion. Say 'start Phase N'."

#### Shared Wrap-Up

1. Create milestone directory and documents:

```
.planning/milestones/VN/
├── ROADMAP.md           ← Phase breakdown, dependencies, success criteria
├── REQUIREMENTS.md      ← Lightweight skeleton (milestone design summary + empty Traceability table,
│                           each REQ filled in during Step 10 when its Phase completes)
├── STATE.md             ← Milestone state tracking (current Phase, progress table, decision records)
└── phases/              ← Directory (empty, sub-directories created when Phases start)
```

2. **Launch PSR-Researcher sub-agent** for milestone-level research:
   - Input: PROJECT.md + .planning/milestones/VN/ROADMAP.md + current codebase
   - Output: `.planning/milestones/VN/RESEARCH.md`
   - Content: Macro impact analysis for all Phases in this milestone

3. Prompt user: "Milestone VN skeleton created. If no further adjustments to Phase breakdown or scope are needed, tell me 'start Phase N' to enter the first Phase."

---

## 3. Conversation Recovery Flow

**Trigger:** Any new conversation begins.

**Main agent executes:**

1. Read `.planning/PROJECT.md`, find current milestone (e.g., V1)
2. Read `.planning/milestones/{current_milestone}/STATE.md`
3. Find current Phase directory
4. List all documents sorted by modification time
5. Find newest document → determine current step
6. Report recovery state to user:

```
📋 Workflow Recovery
Milestone: V1
Phase: N — {name} ({status})
Phase directory: .planning/milestones/V1/phases/0N-name/
Latest document: {latest_document_path}
Assessment: {current_step}
Next step: {next_action}
Continue?
```

**Recovery Judgment Rules:**

| Latest Document | Assessment |
|----------------|------------|
| No Phase documents | Phase just started, enter Step 1 |
| CONTEXT.md | Discussion complete, enter Step 3 |
| RESEARCH.md | Research complete, enter Step 4 |
| PLAN file with complete execution record | Just executed a PLAN, continue execution or enter Step 6 |
| REVIEW.md contains 🔴 items | Review not passed, enter Step 7 |
| REVIEW.md has no 🔴 items | Review passed, enter Step 8 |
| UAT.md | Waiting for user test feedback |

**Reconnection Inquiry:**

After completing state recovery and reporting current progress, proactively ask the user:

> Need project-level reconnection (re-examine project direction), milestone-level reconnection (adjust current milestone scope), or continue the current Phase discussion?

- User says "reconnect project" → route to Sub-workflow F Mode C
- User says "reconnect milestone" or "reconnect milestone VN" → route to Sub-workflow G Mode C
- User says "continue discussion" → route to Sub-workflow A Branch 2 (Re-discuss)
- User says "continue" → enter corresponding step based on recovery judgment

---

## 4. Sub-Agent Invocation

This workflow depends on 3 sub-agents. When invoking them, simply tell them the current Phase directory path and specific task.

| Sub-agent | Purpose | When to Invoke |
|-----------|---------|---------------|
| **PSR-Researcher** | Scan codebase, analyze impact scope, output research report. Supports three-level research: Project-level (PROJECT-RESEARCH.md), Milestone-level (.planning/milestones/VN/RESEARCH.md), Phase-level (0N-RESEARCH.md) | Step 3, Step 5 (before modifying existing files), Sub-workflows A/B/F/G |
| **PSR-Reviewer** | Review code against architectural constraints, output graded report. Supports two modes: regular review (single Phase) and framework review (global) | Step 6, Sub-workflow C |
| **PSR-Fixer** | Read 🔴 items from REVIEW.md, fix one by one and verify, append execution records | Step 7, Step 9 (multi-file fixes) |

### Sub-Agent Selection Rules

"Research" and "search" are different tasks in the PSR workflow. Never substitute general-purpose search for PSR sub-agents:

| Scenario | Must Use | Forbidden |
|----------|---------|-----------|
| Sub-workflow F / Project Init / Project Reconnection | PSR-Researcher (Project-level) | search |
| Sub-workflow G / Milestone Launch / Milestone Reconnection | PSR-Researcher (Milestone-level) | search |
| Step 3 / Phase-level Research | PSR-Researcher (Phase-level) | search |
| Step 5 / Impact Confirmation Before Modifying Files | PSR-Researcher | search |
| Step 6 / Phase Review | PSR-Reviewer | search |
| Step 7 / Fix Blockers | PSR-Fixer | — |
| Sub-workflow C / Framework Review | PSR-Reviewer (Framework mode) | search |
| General Code Search (non-PSR workflow context) | search | — |

Core principle: **PSR sub-agents deeply analyze codebase architecture and planning documents; general-purpose search only does keyword matching — they are not interchangeable.**

---

## 5. Sub-Agent Failure Handling

1. Any sub-agent returns abnormal result (no output, incomplete output, obvious errors) → retry once
2. Second attempt also fails → main agent takes over that step
3. Record in DISCUSSION-LOG.md: "## Sub-agent Failure: {name} returned abnormal, main agent took over"

---

## 6. General Rules

1. **Documents as state machine** — file existence = step complete, non-existence = needs execution. Specific cases are governed by each step's trigger conditions in the workflow.
2. **All comments in Chinese**
3. **Stop and ask user when uncertain**
4. **Never skip research phase to write code directly**
5. **Never modify code without first confirming impact scope**
6. **All PLANs must go through review → fix → UAT flow after execution**
7. **Sub-agent output judged by files, not return messages** — main agent reads files to confirm results
8. **Three-layer architecture principle** — PROJECT.md stays self-contained; milestone documents under .planning/milestones/VN/; Phase documents under .planning/milestones/VN/phases/
