# Roblox Bingo Project Constitution

These principles guide every feature specification and implementation plan in this repository.

## Product principles

1. **Understandable before feature-rich.** A new player should know what to do, why to do it, and what happens next without developer narration.
2. **Fast learning cycles.** Build only what helps test the core social Bingo loop; keep choices easy to tune after playtests.
3. **Fair shared play.** Every participant gets the same calls, while each player gets an individual card and a server-validated result.

## Engineering principles

1. **Server is authoritative.** The server owns match phases, queue membership, cards, calls, marks, and winners. Client requests are untrusted intent.
2. **Keep boundaries useful.** Separate shared configuration, server game rules, and client presentation. Add a module or abstraction when it has a clear responsibility.
3. **Prefer session scope for the experiment.** Do not add persistence, economy, global matchmaking, or analytics infrastructure until a product question requires it.
4. **Tune through observation.** Keep player count, pacing, and scene durations configurable when they need to respond to playtest evidence.

## Specification workflow

- Each feature has one numbered folder under `specs/`.
- `spec.md` is the behavior source of truth; `plan.md` records implementation and architecture; `tasks.md` tracks delivery and verification.
- Put feature-specific product validation in `validation.md` and retain source feedback under `research/`.
- Update the spec before changing behavior. Keep plan and tasks aligned with the implemented code and clearly distinguish implementation from verification.
- Do not create extra artifacts unless they answer a real question for this project.
