# Bingo Match Technical Plan

**Status:** Implemented prototype; update this plan when the architecture changes.
**Input:** [Feature specification](spec.md)
**Validation:** [Playtest plan](validation.md)

## Architecture boundaries

- **Server authority:** queue enrollment, countdowns, participants, cards, calls, accepted marks, and results are held and decided by the server.
- **Client presentation:** UI, captions, local camera movement, card reveal, and player input live on the client. Client requests express intent; they never establish game truth.
- **Shared configuration:** tunable rules and timing values live in `src/shared/GameConfig.luau`.
- **Runtime world:** the server builds the prototype lobby, queue portal, and MC NPC.
- **Lifetime:** match and onboarding state lasts only for the server session. No data store is needed.

## Current Rojo mapping

```text
src/
├── shared/
│   └── GameConfig.luau
├── server/
│   ├── init.server.luau
│   └── Services/
│       ├── RoundService.luau       # queue and authoritative match loop
│       └── LobbyWorldService.luau  # lobby, portal, MC NPC, staging
└── client/
    ├── init.client.luau
    └── Controllers/
        └── BingoController.luau    # UI, card, captions, camera scenes
```

Rojo maps these roots to `ReplicatedStorage.Shared`, `ServerScriptService.Server`, and `StarterPlayer.StarterPlayerScripts.Client`. The server creates the remotes and lobby objects at runtime.

## State flow

```text
LobbyWaiting -> LobbyCountdown -> MatchIntro -> CallingNumbers -> RoundComplete
      ^                |              |                |                |
      |                +-- queue too small             |                |
      +------------------------------------------------+----------------+
```

At countdown completion, the server locks the queued participants, deals cards, and starts an intro. The first match for each player in the server session gets the full tutorial, up to 8 seconds; repeat matches get a kickoff of up to 3 seconds. Calls then begin at the configured interval. A result is presented, then participants return to the lobby after 8 seconds. Players may queue for the next match while another match is active.

## Network contract

- `RoundUpdate` sends snapshots and state changes from server to client.
- `MarkCell` sends a cell index and match id as player intent.
- `RequestSnapshot` asks for current state after the client initializes.
- `SkipScene` requests a skip for the current participant and matching match id.

Validate payload types, finite values, bounds, phase, match id, participant membership, called-number eligibility, and request frequency on the server. The portal prompt is also range-checked and rate-limited.

## Failure handling

- Guard asynchronous countdown, intro, call, and result work with a generation or match identifier so stale tasks cannot affect a later match.
- Remove a departing player from queue and participant state. Cancel a countdown if the queue drops below the minimum.
- Cancel the match if all participants leave; let remaining queued players enter a fresh countdown when eligible.
- Let clients request a fresh snapshot if they miss an update.
- Treat camera scenes and result delivery as presentation; game state remains authoritative if a client disconnects.

## Design choices to revisit only with evidence

- One active match per server, one card per participant, and a full-card win.
- A 5-second call interval and 8-second result display.
- Session-local first-match tutorial state.
- Server-created prototype world and NPC instead of custom authored assets.
