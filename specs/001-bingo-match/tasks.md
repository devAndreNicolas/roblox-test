# Bingo Match Tasks

**Source:** [Specification](spec.md) and [technical plan](plan.md)
**Status:** Prototype implementation exists. Check items only after a fresh Studio verification; this checklist is not a claim that the current build passes every scenario.

## A. Match loop

- [ ] Confirm published servers require two queued players and Studio override stays Studio-only.
- [ ] Verify portal enrollment, visible queue count, countdown, and cancellation.
- [ ] Verify participant lock at match start and next-match handling for late arrivals.
- [ ] Verify the 8-player cap and that overflow remains queued in FIFO order for the next match.
- [ ] Verify server-generated cards, column ranges, unique values per column, and free center.
- [ ] Verify shared no-repeat calls, configurable pacing, marking rules, winner, and draw.
- [ ] Verify player join/leave and stale requests through repeated rounds.

## B. Onboarding and presentation

- [ ] Verify the portal copy explains how to enter the queue.
- [ ] Verify the first-match MC tutorial explains the goal and controls in plain language.
- [ ] Verify card reveal, scene skip/continue, reminder copy, and camera restoration.
- [ ] Verify repeat-match kickoff, MC call captions, and visible next-call timing.
- [ ] Verify winner and draw scenes, readable outcome, and return to lobby.

## C. Device and friend playtest

- [ ] Complete a desktop and phone-sized playthrough.
- [ ] Run the [validation plan](validation.md) with 3–8 players.
- [ ] Record comprehension, hesitation, round completion, replay choice, and direct feedback in [research/playtest-feedback.md](research/playtest-feedback.md).
- [ ] Update the specification and plan from observations before adding new scope.
