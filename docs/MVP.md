# Roblox Bingo — First MVP Plan

**Status:** Proposed  
**Design reference:** [System design](SDD.md) · [Match specification](../specs/bingo-match/spec.md) · [Implementation tasks](../specs/bingo-match/tasks.md)  
**Purpose:** Build the smallest playable version that can tell us whether people understand the loop and want another round.

## 1. MVP question

After one round, do players understand how to play, and do they choose to play another round with the group?

This is a first learning signal, not a market size or business validation. The MVP should make that question observable without spending time on progression, monetization, or a large world.

## 2. Target test

- **First cohort:** 3–8 friends in a private server or coordinated test session.
- **Platforms:** Desktop and at least one phone/tablet playthrough.
- **Session:** Aim for 10–15 minutes, including setup, two or more rounds, and a short debrief.
- **Development fallback:** Use the one-player Studio-only override to check the flow without a group. Treat solo play as a functional check, not evidence of social replay value.

## 3. MVP decisions

Use these defaults for the first playable; change them if the first session shows a problem.

| Decision | MVP default | Why |
|---|---|---|
| Win condition | First player to fill the full 5×5 card | Matches the original game idea. |
| Card | Standard 75-ball BINGO ranges; free center | Familiar rules and simple validation. |
| Number calls | One shared call every 1.5 seconds, configurable | Keeps the test moving while preserving time to mark. |
| Marking | Manual tap/click; any previously called number may be marked later | Keeps the game interactive without punishing a missed call. |
| Cards | One server-generated card per player per round | Smallest fair multiplayer setup. |
| Match start | Players wait in a lobby; start a 10-second countdown when at least two are waiting | Gives the group a clear start point and time to get ready. |
| Player count | Two-player minimum in a published server; one-player Studio-only override | Preserves a multiplayer match while keeping solo development practical. |
| Join in progress | Arrive in the lobby and wait for the next match; do not spectate or join the active card set | Keeps each match's participants and start fair and easy to understand. |
| Round transition | 8-second results screen, then return everyone to the lobby | Waiting players are grouped for the next countdown. |
| Rewards | No currency, XP, inventory, or paid items | They are not needed to answer the MVP question. |
| Persistence | None | Nothing in this experiment needs to survive a session. |

Call cadence, minimum players, and countdown lengths live in shared configuration so they can be tuned without rewriting match logic. If the lobby count drops below two before the start countdown ends, cancel it and return to waiting. At match start, lock the participants; anyone joining later waits in the lobby. After a result, return all remaining players to the lobby. Start the next countdown once two or more players are waiting.

## 4. Included scope

### Player-facing

- A simple, readable bingo screen with the 5×5 card, current call, recent call history, round phase/countdown, and result.
- A brief instruction visible before or during the first round: mark numbers that have been called; first full card wins.
- Tap/click a card cell to request a mark. Valid marks show clearly; invalid marks receive a small, understandable response.
- Clear start, winner/draw, and next-round transitions.
- Mobile-friendly card cells with sufficiently large touch targets.
- A minimal lobby/spawn area showing the waiting player count, waiting/starting status, and start countdown. No elaborate map or physical bingo props are required.

### Game/system

- Server-owned round state, call sequence, per-player cards, accepted marks, and winner decision.
- Per-column card generation without duplicate values in a column; the free center is pre-marked.
- One shuffled 1–75 call sequence per round, with no repeated calls.
- Client receives a full initial snapshot and incremental updates for calls, marks, and round results.
- Server validates each mark against player, round phase, card cell, called set, and prior marks; reject malformed or too-frequent requests.
- If all numbers are called without a full card, show a draw and return players to the lobby. Begin another match only after the minimum group is waiting.
- Remove a departing player's match state. Put new arrivals in the lobby queue for the next match.

## 5. Explicitly out of scope

- Saving wins, streaks, settings, or player profiles.
- Shops, Robux purchases, boosts, paid cards, or other monetization.
- Daily quests, levels, unlocks, collections, leaderboards, or badges.
- Multiple bingo variants, custom patterns, power-ups, teams, or multiple cards per player.
- Global matchmaking, cross-server play, or a separate queueing system.
- Advanced analytics pipeline, dashboards, or automated experiment assignment.
- A polished 3D bingo hall, NPC caller, elaborate animation, voice-over, or custom art production.

## 6. Acceptance criteria

The MVP is ready for a friend playtest when all of the following are true:

1. A player can join and identify the card, latest call, and how to mark a number without developer narration.
2. Players see a lobby while the server waits for at least two; reaching two starts a visible 10-second countdown.
3. If the waiting player count falls below two during countdown, it cancels. No match starts below the minimum in a published server.
4. Players in the lobby when countdown ends receive cards and enter one match; later arrivals remain in the lobby for the next match.
5. Every player in a match sees the same calls in the same order.
6. Each participant gets a server-generated card with valid column ranges, no duplicate number within a column, and a free center.
7. A player can mark a called number, including one called earlier; uncalled numbers cannot be marked.
8. A client cannot cause another player's card to change, invent a called number, or claim a win by sending a request.
9. The server detects a valid full card once and declares one winner; later mark requests cannot change the completed match.
10. A player who joins mid-match sees that they are waiting in the lobby for the next match; a departing player does not break the active match.
11. A no-winner match ends cleanly after the call pool is exhausted and returns players to the lobby.
12. Result and next-match transitions work repeatedly without restarting the server.
13. Card and call history remain usable at a phone-sized viewport; a player can mark cells by touch.

## 7. Build sequence

Keep each slice playable and small.

### Slice A — Round engine

- Add shared configuration and types.
- Implement round phases, card creation, shuffled calls, mark validation, winner detection, and player join/leave handling on the server.
- Expose the smallest remote surface needed for a state snapshot, updates, and mark intent.

**Exit:** Server state can run a complete round repeatedly, including a win and a draw, without depending on UI.

### Slice B — Playable interface

- Build the card, call display/history, phase labels, countdown, instructions, and result view.
- Connect UI input to the mark request and server-confirmed state.
- Add clear feedback for a valid mark, invalid mark, win, and draw.

**Exit:** A player can complete the loop in Studio with one player and understand what happened.

### Slice C — Multiplayer and device pass

- Run a multiplayer Studio session to confirm shared calls, separate cards, and one winner.
- Check join-in-progress and leave behavior.
- Check the main screen on a phone-sized viewport and make touch targets comfortable.
- Fix only issues that block understanding or completing another round.

**Exit:** The acceptance criteria above are met well enough for a small invited test.

### Slice D — Friend playtest

- Invite 3–8 people; do not explain more than the in-game instruction at the start.
- Observe the first round quietly, then let the group play at least one more.
- Ask a few short questions after play (below); record direct quotes and rough counts manually.

**Exit:** We have observations about comprehension, round completion, and voluntary replay, plus the top friction point to address.

## 8. Playtest notes and decision rule

Record manually for each participant:

- Did they understand the goal and how to mark without help?
- Did they complete or stay through a round?
- Did they choose to stay for another round?
- Where did they hesitate, mis-mark, or stop paying attention?
- Did they prefer a faster/slower caller or a different win condition?

Ask after play:

1. “What were you trying to do during the round?”
2. “What part felt confusing or slow?”
3. “Would you play one more round now? What would make you say yes?”

For this tiny cohort, treat the result as directional. A useful first signal is that most players can start marking without explanation, the group finishes at least one round, and several players choose another round. If players understand the rules but decline to replay, change the loop or pacing before adding progression. If they want to replay but marking/calls confuse them, fix clarity and controls first. Do not claim product-market fit from this test.

## 9. Main risks during the MVP

- **Full card takes too long:** Tune call cadence first; keep it configurable. If two rounds do not fit the session, discuss changing the win condition before building rewards.
- **Players miss calls:** Keep a recent-call history and allow late marking of called numbers.
- **UI feels cramped on mobile:** Prioritize the card and latest call; remove secondary decoration before shrinking targets.
- **Small cohort produces misleading feedback:** Use the test to find usability issues and replay intent, then run another session before making a larger investment.

## 10. Not doing yet

No gameplay code has been added as part of this plan. Implementation starts with Slice A after this scope is accepted or edited together. The existing project has a modified server entry file in the worktree; review that existing change before implementation rather than overwriting it as part of the MVP setup.
