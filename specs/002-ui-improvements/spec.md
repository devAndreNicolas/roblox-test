# 002 — Bingo UI, Bug Fixes, and Feature Refactor

**Status:** Revised proposal; implementation pending.
**Source:** [Owner playtest feedback](research/playtest-feedback.md).
**Delivery:** [Plan](plan.md) · [Tasks](tasks.md) · [Bug audit](research/code-audit.md) · [Validation](validation.md).
**Baseline:** [001 Bingo Match](../001-bingo-match/spec.md).

## Problem and intended outcome

The owner reports that overlapping, context-insensitive UI makes the game difficult to play and enjoy. They also explicitly request feature-based code, reusable presentation, and separation of responsibilities. These are actionable defects and engineering requirements. We do not need additional customer research to prioritize them.

The current client constructs every screen, handles remote updates, animates the camera, and renders the card in one module. Source inspection identifies concrete layout and lifecycle defects; the audit distinguishes code evidence from problems that still require Studio reproduction.

Deliver three outcomes together:

1. **UI:** a coherent Bingo presentation that makes the world, MC, card, and next action understandable.
2. **Bug fixes:** reliable layout, camera, feedback, and transitions across roles, phases, and repeated rounds.
3. **Refactor:** cohesive feature modules with explicit ownership, inputs, outputs, and cleanup.

## Scope and decisions

Cover loading, lobby exploration, queue/countdown, first and repeat introductions, local scene skip, active calls, results, return to lobby, respawn, and repeated initialization. Include world-space signs and captions where they compete with screen UI.

Retain the established game: portal opt-in, two-player public minimum, Studio solo override, 10-second countdown, 5×5 card/free center, full-card win, five-second default calls, eight-second results, and server authority. Correctness fixes may change faulty implementation and misleading copy.

Proposed visual direction: **Bingo Club**, a friendly game-show setting with a paper card, stamped marks, and a distinctive numbered call ball. Mobile portrait is the layout stress case; desktop and mobile landscape are equally required delivery targets. These are working design decisions, adjustable during review.

Exclude economy, persistence, new Bingo variants, global matchmaking, custom asset production, and framework adoption. Refactoring includes server responsibilities involved in this flow; it is not an unrestricted rewrite.

## Player context matrix

Presentation depends on server phase **and local membership**, plus whether the local scene has finished. A global phase alone cannot select the player's screen.

| Context | Visible and important | Interaction | Camera |
|---|---|---|---|
| Waiting for snapshot | Small loading status; world remains visible | Retry after a bounded wait | Normal |
| Lobby, not queued | Compact portal guidance and queue count | Move to/use portal | Normal |
| Queued, awaiting minimum | Queue confirmation; players needed; how to leave | Move/use portal to leave | Normal |
| Countdown, queued | Time to start and queue membership | Leave before participant lock | Normal |
| Countdown, not queued | Join this match before countdown ends | Use portal to join | Normal |
| Another match active, nonparticipant | Next-match queue status only | Join/leave next queue | Normal |
| Participant, first intro | MC, readable instruction, card reveal, skip | Skip scene; card is read-only | Scene camera |
| Participant, repeat intro | Brief welcome and card preview | Skip; card is read-only | Scene camera for up to 3 seconds |
| Intro locally finished/skipped, server still in intro | Card preview, rule reminder, waiting status | No marking until live calls | Normal |
| Participant, calls | Current call, playable card, next-call cue, compact history | Mark eligible squares | Normal |
| Participant, results scene | MC and explicit outcome; result countdown | Skip scene locally | Scene camera for up to 3 seconds |
| Results scene finished/skipped | Outcome and remaining time to lobby | No marking | Normal |
| Returned to lobby | Portal guidance; actual queue status | Explicitly rejoin through portal | Normal |

No lobby panel is a full-screen modal. The player must see and reach the portal. During scenes, the MC's face and the card reveal must not be covered by duplicate captions or unrelated panels.

## Requirements

### UI and interaction

- **UI-01 Context:** Implement every row in the context matrix. Hidden screens receive no input. Loading ends only after a usable snapshot; after five seconds without one, show a retry action rather than an indefinite spinner.
- **UI-02 Composition:** Give the MC, card, call, captions, actions, and feedback reserved layout regions. Text and buttons must not intersect. Scene composition can deliberately overlay a background, but cannot obscure its focal subject or controls.
- **UI-03 Responsive:** Support 360×640 and 390×844 portrait, 844×390 landscape, and 1280×720 and 1920×1080 desktop, accounting for Roblox top bar, device safe areas, and touch controls. At these sizes, all 25 cells and the current call remain accessible without scrolling the card.
- **UI-04 Readability:** Card numbers and essential instructions are at least 16 UI pixels; secondary captions at least 14. Interactive cells/buttons target at least 44×44 UI pixels. Reduce decoration and secondary history before shrinking primary controls. Long player names wrap or truncate with the outcome still understandable.
- **UI-05 Identity:** Use a consistent theme with role-based colors, typography, spacing, surfaces, and focus/pressed/disabled states. The signature call ball and stamped card marks give this game an identifiable visual language. Color alone cannot communicate a mark, error, or win.
- **UI-06 Card:** Distinguish free, unmarked, pending, and server-confirmed marks. A pending animation may acknowledge input but must not count as a confirmed mark. Invalid or rate-limited requests must not leave a cell stuck pending. Marking is disabled during intro and results; earlier called numbers remain markable. During intro, the card is a read-only preview: tapping it or the surrounding scene does not mark or skip. Only the clearly labeled **Skip intro** action skips that player's scene.
- **UI-07 World UI:** Portal prompts remain available to eligible lobby players. Nearby world billboards and the MC's overhead caption must not duplicate or obstruct screen dialogue during a scene. Apply presentation suppression locally, so other players retain their correct context.
- **UI-08 Feedback:** Show explicit success/error/information styles, without guessing severity from words. Transient feedback stays visible for three seconds or until replaced by a newer notice; routine snapshots do not erase it. A match change clears obsolete notices.

### Bugs and scene lifecycle

- **FIX-01 Layout:** Resolve B01–B03 in the audit: fixed-height overflow, button/text overlap, and competing scene/world presentation. Make layouts correct at all target sizes before visual polish is accepted.
- **FIX-02 Scene lifetime:** Key scenes by match and scene type. A repeated snapshot updates data without replaying a scene or revealing its skip button again after completion. Show a scene action only while that local scene is active.
- **FIX-03 Exit:** On skip, natural completion, phase change, participant loss, character replacement, camera replacement, or feature destruction, cancel scene work and release camera ownership. Old callbacks cannot change the new scene or current camera.
- **FIX-04 Shared timing:** Skipping intro ends only that player's camera presentation immediately. They wait for the authoritative calling phase; the server may advance once all current participants explicitly skip. Leaving players must no longer block that decision. Skipping results changes neither the winner nor the eight-second server result period.
- **FIX-05 Duration:** First intro presentation lasts up to eight seconds; repeat intro and results presentation up to three. Cap local duration to time remaining when entering late. In a mixed first-time/repeat group, a returning player can finish their short scene while the shared intro continues.
- **FIX-06 Clock and copy:** Drive progress from the configured interval supplied with state, not a client literal. Countdown copy must accurately distinguish joining the current open queue from waiting for the next locked match.
- **FIX-07 Recovery:** Reinitializing the feature cannot duplicate UI, listeners, mark requests, or scene tasks. Respawn must reconnect presentation to the current character and authoritative membership. Delayed character placement must recheck membership and match after yielding.

### Feature architecture

- **ARCH-01 Ownership:** Organize Bingo code under a Bingo feature in client, server, and shared roots. Shared contains types/configuration, never authoritative mutable state. Place feature-specific views and components inside the feature.
- **ARCH-02 Interfaces:** Define module interfaces and ownership in the plan. View modules render supplied data and emit intents. They cannot access remotes, mutate the shared snapshot, or decide accepted marks.
- **ARCH-03 Lifecycle:** Construction happens through explicit initialization, not at module import. Start/mount is idempotent or rejects duplicate startup safely. Destroy disconnects owned connections and cancels tweens, tasks, and local input handlers.
- **ARCH-04 Server:** Separate game rules/card generation from networking, world construction, and match orchestration. One module owns each mutable state collection. Match lifecycle, queue changes, and winning remain server-authoritative and non-yielding at their decision points.
- **ARCH-05 Reuse:** Reuse the Bingo card in intro/play/results where appropriate. Share theme and genuinely repeated control behavior. Do not force a two-consumer rule for modules that isolate complex lifecycle responsibilities, or create generic utility dumping grounds and pass-through wrappers.

## Acceptance and completion

The [validation matrix](validation.md) is the observable acceptance contract. Each task links to requirement IDs, bug IDs, and validation cases.

Completion requires working UI, resolved blocker/high-priority audited defects, feature modules matching their documented interfaces, and recorded visual/runtime evidence. Moving files or matching a palette alone is insufficient. Static inspection is not a passing Studio result.

## Relationship to 001 and proposed clarifications

001 remains the game-rule baseline. This proposal refines presentation and resolves two ambiguous behaviors for multiplayer:

- A player can join the current queue until participant lock, including during countdown. Only arrivals after lock wait for the next match.
- Reading the tutorial does not hold a shared match indefinitely. Keep a concise instruction visible throughout a player's first active round; skipping the scene does not remove it. This replaces 001's ambiguous “unless the player chooses to continue reading” exception with an explicit shared-timer behavior.

If adopted, update those clauses in 001 and its current architecture plan as implementation lands. Neither document should claim the proposed refactor is already implemented.
