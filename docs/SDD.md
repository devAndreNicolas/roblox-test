# Roblox Bingo — Software Design Document

**Status:** Draft v0.1  
**Purpose:** A lightweight design for a small Roblox game experiment. This is a working agreement, not a commitment to a large production build.

> This file is the game's **Software Design Document** and background rationale. It is not, by itself, a Spec-Driven Development workflow. The behavior source of truth is now [the match specification](../specs/bingo-match/spec.md); implementation order is in [the task checklist](../specs/bingo-match/tasks.md), with technical decisions in [the technical design](../specs/bingo-match/design.md). Keep those artifacts aligned as behavior is implemented and verified.

## 1. Product idea

A social, quick-play Bingo minigame. Players join a Roblox server, receive a card, listen for numbers called by the game, mark matching squares, and race to complete the entire card. The first valid player to complete it wins the round.

The initial business question is whether this simple loop is fun enough for players to stay for another round and invite or play alongside friends. The game should be cheap to build and easy to change while we learn.

## 2. Goals and non-goals

### Goals

- Make the rules understandable within one round, including for a first-time player.
- Support multiple players playing the same round in one Roblox server.
- Make number calls, cards, marks, and winner decisions trustworthy and consistent.
- Keep the first experiment small enough to iterate on quickly.
- Leave room for later changes to round pacing, social play, rewards, and presentation.

### Non-goals for this design

- Persistent progression, currency, inventory, trading, or paid advantages.
- Global matchmaking or cross-server rounds.
- Ranked/competitive systems, moderation features beyond Roblox defaults, or complex anti-cheat.
- A realistic physical bingo hall. The first version can use a simple lobby and a clear card UI.

## 3. Assumptions to validate

These are deliberately provisional; the MVP plan can change them.

- A round uses a 5×5 card with the standard B, I, N, G, O number columns.
- The center square is free and counts as marked.
- A full card wins; completing a row or other pattern does not.
- The server calls numbers without replacement, and all players in that server hear the same sequence.
- Players choose when to mark a matching called number. The server checks that the square is eligible.
- Each player has one card per round.
- A Roblox server hosts one match at a time. Players enter a lobby; those who join during a match wait there for the next one.
- No progress needs to survive leaving the server during the experiment.

## 4. Player experience

1. Player joins a lobby and sees a short explanation, the waiting player count, and whether the server is waiting for players or counting down.
2. Once the minimum player count is reached, a lobby countdown begins. Players in the lobby when it ends enter the same match and receive their cards.
3. When the match starts, each player sees their card and the shared called-number display.
4. The server announces numbers at a steady pace. The player selects a square matching a number already called.
5. The client gives immediate visual feedback for a mark request; the server confirms or rejects it.
6. When a valid card is complete, the server ends the match and announces the winner.
7. Players see a brief result, then return to the lobby. Players waiting there are included when the next lobby countdown begins.

The interface must keep the card, most recent call, and round status easy to read on touch screens as well as desktop. Detailed layout and pacing are MVP planning decisions.

## 5. Rules and game state

### Round phases

`LobbyWaiting → LobbyCountdown → CallingNumbers → RoundComplete → LobbyWaiting/LobbyCountdown`

- **LobbyWaiting:** show instructions and the waiting player count until the configured minimum is present.
- **LobbyCountdown:** show the time until match start. If the player count falls below the minimum, cancel the countdown and return to LobbyWaiting. When it ends, lock the participants and deal their cards.
- **CallingNumbers:** deal cards, call numbers, and accept mark requests.
- **RoundComplete:** freeze marks and show the result. If the number pool is exhausted without a winner, end as a draw. Then return players to the lobby and start another countdown when enough players are waiting.

The minimum player count and all durations are tunable configuration, not assumptions embedded across scripts. The initial published-game minimum is two players. A one-player Studio-only development override can exercise the loop without changing the intended public flow.

### Card and number model

- A card is generated on the server and is unique to its player for the round.
- Use standard 75-ball ranges: B 1–15, I 16–30, N 31–45, G 46–60, O 61–75.
- Each column has five values; the N center is a free square. Values in a column are sampled without replacement.
- The call sequence is a shuffled list of 1–75, consumed once per call.
- The server stores each card, called-number set, marked squares, and round phase. The client receives only what it needs to render and play.

### Mark validation and winner selection

The client sends a request to mark a square, identified by a stable row/column or cell index. The server accepts only if the player is in the active round, the cell belongs to their card, the number has been called (or the cell is free), and the cell is not already marked. The server updates state and checks the full-card condition. A player cannot declare their own win.

If two requests arrive close together, the server processes each state change in order. The first valid completed card wins; subsequent requests see the completed phase and are rejected. All client input is untrusted.

## 6. System design

The existing project uses Rojo and separates shared, server, and client code. Keep that boundary:

```text
ReplicatedStorage
└── Shared
    ├── GameConfig          -- tunable rules and timings
    └── Types               -- shared data shapes, if useful
ServerScriptService
└── Server
    ├── init.server         -- startup/composition root
    └── Services
        └── RoundService    -- authoritative round, cards, calls, marks, winner
ReplicatedStorage
└── Remotes                 -- server-created/validated client communication
StarterPlayerScripts
└── Client
    ├── init.client         -- startup/composition root
    └── Controllers
        └── BingoController -- card UI, call display, user mark requests
StarterGui
└── Bingo UI                -- visual interface may be built in Studio or Rojo
```

The exact folder mapping can evolve with the project; avoid introducing layers that do not yet have a job.

### Authority and communication

- **Server owns:** phase/timers, card generation, call sequence, called numbers, accepted marks, and winner.
- **Client owns:** presentation and input only. It may optimistically animate a click, but it cannot commit a mark or determine a winner.
- **Server → clients:** round snapshot/state changes, new call, mark result, and round result. Prefer events for updates; clients can reconstruct the UI from snapshots after joining or recovering.
- **Client → server:** mark-cell intent only. Validate payload type, cell bounds, phase, eligibility, and request frequency.
- Create remotes from server code or define them in the Rojo tree. Do not trust client-created instances or client-reported card values.

### Data lifetime

All game data is in server memory and scoped to a round. No DataStore is needed for the experiment. On player removal, discard their active card and state. Persistent stats should only be added if the MVP shows they help the learning goal.

## 7. Failure and edge cases

- A player leaves during a round: remove their card; continue for remaining players.
- A player joins during a match: put them in the lobby, show that they are queued for the next match, and do not give them a card in the active match.
- The lobby countdown starts when enough players are waiting; if the count drops below the minimum, cancel it and resume waiting.
- A mark is invalid or stale: reject it and resync that player's card state without disrupting the round.
- A player disconnects after completing a card but before result delivery: the server still completes the round; result UI is best-effort.
- No one wins before all numbers are called: report no winner/draw and start a new round.
- Server shuts down: the round ends; no state is persisted.

## 8. Product learning

Treat this as a prototype, not proof of a business by itself. For the first experiment, observe whether players understand the loop, complete rounds, and choose to play another. Candidate measures for the MVP are round completion, rematch/next-round participation, time to first valid mark, and qualitative feedback. Instrumentation and decision thresholds are intentionally deferred to the MVP plan so we do not build analytics before choosing what decision we need to make.

## 9. Risks and mitigations

| Risk | Mitigation |
|---|---|
| Players do not notice or understand calls | Keep the latest call prominent and retain a compact call history; test comprehension in the first play session. |
| Manual marking feels slow on mobile | Make every square a large touch target; test on a phone-sized viewport before adding features. |
| Players can fake marks or wins | Keep card state and winner checks on the server; validate every request against the called set. |
| Rounds feel too long or too short | Keep call cadence and intermission configurable; tune through play sessions. |
| Too few players in an early test | Use the Studio-only solo override during development; invite a group for the social playtest. |

## 10. Open decisions for MVP planning

1. What is the smallest audience and test cohort: friends, public server discovery, or both?
2. Is a two-player minimum right for the first public test, or should we raise it?
3. How fast should calls happen, and should players be able to mark missed calls later?
4. Is “full card” the intended win condition, or should the first playable use a shorter pattern to reduce round time?
5. What single signal would make us keep iterating: another round played, session length, friend joins, or direct feedback?
6. What is the minimum visual identity and lobby needed to make the test feel inviting?

## 11. MVP planning sequence

After agreeing on the open decisions, define the MVP as a short vertical slice: round state and card generation, shared calls, validated marking and winner, readable UI, then a small play session with a clear learning question. Keep this SDD as the architecture and rules baseline; put the prioritized scope, acceptance criteria, and test plan in a separate MVP plan.
