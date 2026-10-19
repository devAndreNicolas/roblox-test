# Bingo Match Implementation Tasks

**Source:** [Specification](spec.md), [onboarding and call pacing](onboarding-and-call-pacing.spec.md), and [technical design](design.md)
**Status:** Implementation updated in the worktree; Studio/runtime verification is pending. Check a task only after its implementation and verification are complete.

## Slice A — Authoritative match loop

- [ ] Require a two-player minimum in published servers and keep solo override Studio-only.
- [ ] Implement explicit portal queue enrollment and a visible lobby countdown.
- [ ] Lock queued participants at match start; route late arrivals to the next queue.
- [ ] Generate server-owned cards and a shuffled no-repeat 1–75 call sequence.
- [ ] Validate marks, determine the full-card winner, and handle exhausted calls as a draw.
- [ ] Handle player join/leave and stale requests across match transitions.

## Slice B — Player-facing loop

- [ ] Show the queue count, waiting/starting status, and countdown.
- [ ] Show the local player's card, latest call, recent call history, and match state.
- [ ] Send cell mark intent and render server-confirmed marks and rejection feedback.
- [ ] Show winner/draw result and return participants to the lobby after 8 seconds.
- [ ] Make controls usable on desktop and a phone-sized viewport.

## Slice C — Onboarding and call pacing

- [ ] Build the MC NPC, opening tutorial cutscene, short repeat-match kickoff, and results cutscene.
- [ ] Reveal the card during the introduction; add skip/continue and restore the camera afterward.
- [ ] Present readable MC captions for the tutorial, calls, and results.
- [ ] Use a configurable five-second default call interval and show time until the next call.

## Slice D — Verify against the spec

- [ ] Verify the portal queue, published minimum, countdown cancellation, solo Studio behavior, and late-arrival flow.
- [ ] Verify NPC, cutscene, tutorial skip, card reveal, camera restore, and repeat-match kickoff.
- [ ] Verify calls, card ranges/uniqueness/free center, marks, first winner, draw, and repeated matches.
- [ ] Complete desktop and touch-oriented playthroughs before the friend test.

## Slice E — Product learning session

- [ ] Run a 3–8 friend session using the [MVP playtest notes](../../docs/MVP.md).
- [ ] Record comprehension, round completion, voluntary replay, and the main friction points.
- [ ] Revise copy, scene length, and call interval from observed comprehension and response time.
