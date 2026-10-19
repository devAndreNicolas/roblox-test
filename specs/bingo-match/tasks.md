# Bingo Match Implementation Tasks

**Source:** [Specification](spec.md) and [technical design](design.md)  
**Status:** Code is drafted in the worktree; Studio/runtime verification is pending. Check a task only after its implementation and verification are complete.

## Slice A — Authoritative match loop

- [ ] Add shared configuration for minimum players, Studio-only solo override, lobby countdown, call cadence, and result duration.
- [ ] Implement server lobby waiting/countdown and cancel the countdown when fewer than two players remain.
- [ ] Snapshot and lock participants at match start; route new arrivals to the lobby for the next match.
- [ ] Generate server-owned cards and a shuffled no-repeat 1–75 call sequence.
- [ ] Implement call updates, mark validation, full-card winner detection, and draw handling.
- [ ] Handle player join/leave and stale requests across match transitions.

## Slice B — Player-facing loop

- [ ] Show lobby count, waiting/starting status, and countdown.
- [ ] Show the local player's card, latest call, recent call history, and match state.
- [ ] Send cell mark intent and render server-confirmed marks and rejection feedback.
- [ ] Show winner/draw result and return players to the lobby after 8 seconds.
- [ ] Make controls usable on desktop and a phone-sized viewport.

## Slice C — Verify against the spec

- [ ] Verify lobby waits for two players in a published-behavior configuration.
- [ ] Verify countdown reset on player drop and one-player override in Studio only.
- [ ] Verify late arrivals wait for the next match and leaving players do not break one.
- [ ] Verify identical calls, card ranges/uniqueness/free center, and no-repeat call sequence.
- [ ] Verify valid/invalid/stale marks, first winner, draw, and repeated matches.
- [ ] Complete one desktop and one touch-oriented playthrough before the friend test.

## Slice D — Product learning session

- [ ] Run a 3–8 friend session using the [MVP playtest notes](../../docs/MVP.md).
- [ ] Record comprehension, round completion, voluntary replay, and the main friction points.
- [ ] Update the spec if observed behavior changes the intended rules; create follow-up tasks for code changes.
