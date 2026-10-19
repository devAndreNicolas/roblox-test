# Bingo Match Technical Design

**Status:** Draft  
**Behavior source:** [Match specification](spec.md)  
**Product test:** [MVP plan](../../docs/MVP.md)

## Runtime ownership

- The server owns lobby state, countdowns, participant snapshots, card generation, the call sequence, called values, marks, and winner/draw outcome.
- The client renders the server state and sends mark intent. It never decides whether a mark is valid or who won.
- Shared configuration holds tunable minimum players, countdown durations, and call interval. The one-player development override must be Studio-only.

## Suggested project mapping

Use the existing Rojo split and keep the first implementation small:

```text
src/shared/
  GameConfig.luau             -- shared tunables and shared data types
src/server/
  init.server.luau            -- startup/composition root
  services/RoundService.luau  -- lobby + match state and authoritative rules
src/client/
  init.client.luau             -- startup/composition root
  controllers/BingoController.luau -- lobby, card, calls, results, mark intent
ReplicatedStorage/Remotes
  RoundUpdate (server -> clients)
  MarkCell (client -> server)
  RequestSnapshot (client -> server, rate-limited)
```

Exact Rojo mappings may need a small adjustment to `default.project.json`; do not move unrelated project files as part of this feature.

## State model

```text
LobbyWaiting -> LobbyCountdown -> CallingNumbers -> RoundComplete
      ^                |                                  |
      |                +-- player count < 2 --------------+
      +---------------------------------------------------+
```

`LobbyWaiting` and `LobbyCountdown` track waiting players. When the countdown ends, snapshot participants and initialize their cards. During `CallingNumbers`, only that snapshot participates. `RoundComplete` freezes the result, then returns remaining players to the lobby. An empty server remains in `LobbyWaiting`.

## State and events

The authoritative server state should be ordinary Luau tables scoped to the current server session. Keep a called-number lookup set for mark validation and an ordered call list for display/history. Store each player's card and marked cells on the server.

The client requests an initial snapshot after connecting its `RoundUpdate` listener. This avoids losing the server's `PlayerAdded` snapshot if the LocalScript starts later. Rate-limit snapshot requests on the server.

The client needs:

- A complete lobby or match snapshot on joining/rejoining UI state.
- Lobby count/status/countdown updates.
- On match start, the local player's card and participant-facing match state.
- Each new call and a list or sequence for recent call history.
- Accepted/rejected mark feedback and authoritative card updates.
- Winner/draw and result countdown.

Use a server-to-client event for snapshots and updates, and a client-to-server event for mark intent. Prefer an explicit cell index or row/column pair; never accept client-supplied number values, cards, or winner claims. Validate types, index bounds, participant membership, phase, called membership, and request frequency on the server.

## Card generation and win check

Build each column by sampling five distinct values from its configured range, then arrange into a 5×5 card. Reserve the center N cell as free and marked. Keep the server copy as authority; the client gets a rendering snapshot. A full-card check should inspect all non-free cells after each newly accepted mark.

## Failure handling

- Countdown task must be cancellable or guarded by a countdown generation/token so a cancelled countdown cannot start a match later.
- A leaving player is removed from the waiting set and current match map. A leave during countdown can cancel it if fewer than two remain.
- Reject stale mark requests after state transitions; do not let a client replay a previous match's request into a new match. Include a round identifier in updates and mark requests.
- If a client misses an update, provide a fresh snapshot on request/rejoin or when the UI initializes.
- No persistence or recovery across server shutdown is needed for this MVP.

## Studio override

The published behavior stays at a two-player minimum. Keep solo-start behavior behind a Studio check or a development-only config path that cannot be toggled by clients. The exact mechanism should be confirmed against the current Roblox project setup during implementation.
