# Specifications

This folder contains the behavior contracts for the Roblox Bingo project. Project-wide product and engineering principles live in [the constitution](../.specify/memory/constitution.md); reusable document shapes live in [.specify/templates](../.specify/templates).

## Feature folders

Use a zero-padded number and short feature name, for example `001-bingo-match/`. Each accepted feature should have one canonical set of artifacts:

Current feature folders:

- `001-bingo-match/` — implemented prototype; Studio verification checklist remains open.
- [002-ui-improvements](002-ui-improvements/spec.md) — revised proposal covering UI, audited bug fixes, and feature refactoring; includes a technical plan, traceable tasks, and a validation matrix.

```text
specs/
├── README.md
└── 001-bingo-match/
    ├── spec.md          # player-visible behavior and acceptance scenarios
    ├── plan.md          # architecture and implementation decisions
    ├── tasks.md         # implementation and verification checklist
    ├── validation.md    # acceptance, regression, or product playtest checks
    └── research/        # source feedback and observations, when available
```

## Working loop

1. Capture the player problem and intended outcome in `spec.md`.
2. Resolve ambiguous behavior and acceptance scenarios before implementation.
3. Record the code and runtime approach in `plan.md`.
4. Break delivery and verification into `tasks.md`.
5. Implement against the spec, then verify scenarios in Studio.
6. Keep raw observations in `research/`; update requirements only after discussing what the evidence means.

Folders containing only `research/` are feedback intake, not approved feature specifications. Triage that feedback before adding requirements or a plan.

The feature artifact names follow the organization used by GitHub Spec Kit, with a lightweight workflow that fits this small game. It does not require installing or running the Spec Kit CLI.
