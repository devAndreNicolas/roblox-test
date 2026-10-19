# Bingo Match Technical Design

**Status:** Draft, updated with the onboarding implementation
**Behavior source:** [Match specification](spec.md) · [Onboarding and call pacing](onboarding-and-call-pacing.spec.md)
**Product test:** [MVP plan](../../docs/MVP.md)

## Runtime ownership

- The server owns portal enrollment, queue state, countdowns, participant snapshots, card generation, the call sequence, called values, marks, and winner/draw outcome.
- The client renders snapshots and sends mark/skip intent. It never decides whether a mark is valid or who won. Camera movement and the card reveal are local presentation.
- Shared configuration holds the published minimum, Studio-only solo override, countdown, intro/kickoff, call cadence, and result duration.
- The server creates the simple lobby set, queue portal, and Bingo MC NPC at runtime. The portal's `ProximityPrompt` is range-checked and rate-limited on the server.

## Project mapping

```text
src/shared/
  GameConfig.luau
src/server/
  init.server.luau
  Services/
    RoundService.luau             -- authoritative queue + match loop
    LobbyWorldService.luau        -- lobby, portal, MC NPC and staging
src/client/
  init.client.luau
  Controllers/
    BingoController.luau          -- lobby/card UI, captions, cutscene camera
ReplicatedStorage/Remotes
  RoundUpdate (server -> client)
  MarkCell (client -> server)
  RequestSnapshot (client -> server, rate-limited)
  SkipScene (client -> server, validated match id + participant membership)
```

## State model

```text
LobbyWaiting -> LobbyCountdown -> MatchIntro -> CallingNumbers -> RoundComplete
      ^                |              |                |                |
      |                +-- queue too small             |                |
      +------------------------------------------------+----------------+
```

Players spawn in the lobby and explicitly toggle queue membership at the portal. The server locks and removes queued players from the waiting set when the countdown ends. Those players get a card and move to the match area. New or unqueued players remain in the lobby; they can join the next queue while a match runs.

`MatchIntro` lasts up to eight seconds if any participant has not yet played in this server session, otherwise three seconds. A player can locally skip the camera scene; the server shortens the shared intro once every participant has skipped. The first-call UI still repeats the simple instructions. During `CallingNumbers`, the server announces the first number immediately, then starts the five-second interval. `RoundComplete` freezes the result, presents the MC result scene, returns participants to the lobby after eight seconds, and starts another countdown only if enough players joined the queue.

## State and events

The authoritative server state is stored in ordinary Luau tables for this server session. It keeps a queue membership set, participant cards, called-number lookup set, and ordered call list. First-match tutorial completion is session-local and is removed when the player leaves.

The client requests a snapshot after connecting its update listener. Snapshots include queue membership, phase/countdown, match id, card, calls, result, and whether the player needs the full tutorial. Updates are sent each second during countdowns, cutscenes, calls, and results so the UI can render countdowns and progress.

The client sends a cell index and match id for marks; it never sends card values or a claimed result. The server validates type, finite values, bounds, phase, participant membership, called membership, and request frequency. The skip request only affects the intro for a current participant in the matching match id.

## Failure handling

- Countdown and intro tasks are guarded by generation or match identifiers so an old task cannot start a later round.
- A leaving player is removed from queue and participant maps; a countdown cancels if the queue drops below the minimum.
- If every participant leaves during intro or play, the match is cancelled and remaining queued players can start a fresh countdown.
- The server range-checks and rate-limits portal interactions; it ignores malformed and stale skip/mark requests.
- If a client misses an update, it can request a fresh snapshot when its UI initializes.
- No persistence or recovery across server shutdown is needed for this MVP.

## Studio override

Published servers require two queued players. `RunService:IsStudio()` gates the one-player development override so clients cannot enable it.
