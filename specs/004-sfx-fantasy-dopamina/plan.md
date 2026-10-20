# 004 — Technical Plan

**Status:** Implemented in source; solo Studio checks partially recorded, wider acceptance pending. **Behavior contract:** [Spec](spec.md). **Baseline source audit:** [Code audit](research/code-audit.md).

## Server data and match lifecycle

Keep `BingoService` as the owner of truth. Add a small standings projection to each participant snapshot in `BingoTypes`: `{userId, displayName, markedCount, remaining, rank}`. Count only non-free, server-confirmed marks. Compute rank from remaining; use competition ranking for ties and stable user ID ordering within a tie. Build the projection once per broadcast or cache it until participant progress changes, rather than recounting eight cards for each recipient every heartbeat. Keep it absent for nonparticipants.

On a successful mark, broadcast the updated snapshot to all participants immediately, including the marking player, while preserving the existing success notice for that player. Keep the periodic snapshot for timers and reconnects. Rebuild standings when a player leaves; initialize at match start; stop live race updates at `RoundComplete`. The server still alone determines Bingo. No new remotes or client-to-server ranking messages are needed.

## Client confirmation and effects

In `BingoController`, compare successive snapshots within the same `sessionId` and `matchId` to detect a newly confirmed local mark. Key the response to a specific cell transition from unmarked to marked. Do not emit mark sound or a celebration from the tap, pending state, first snapshot after reconnect, or routine repeated snapshot. If several confirmations arrive in one recovery snapshot, coalesce into one brief cue while updating every cell. Process feedback before pending entries are cleared; a two-second pending timeout must not suppress a later valid server confirmation.

Give `BingoCard` one focused API for playing a confirmed-cell response, or feed it an explicit confirmed index from the controller. Keep ordinary rendering idempotent so timer refreshes cannot restart tweens. Use native `TweenService`, UI strokes/scales, and a short progress marker. No long full-screen animation is needed. Use existing `Theme` tokens and the 003 world lighting/particle vocabulary. Avoid script-created effects in the server world for every private mark, which would multiply across players.

Extend `ShowAudio` into a local music/effects mix with separate toggles. Keep a single reusable sound pool or short-lived sounds with bounded overlap, and duck music briefly for a confirmed mark, near-win cue, or result if listening review shows masking. Place sound IDs, volumes, and timings in one replaceable configuration. The implementation uses free Roblox Creator Store prototype sounds [soft click](https://create.roblox.com/store/asset/16480568148) and [low bell](https://create.roblox.com/store/asset/16480570986); their actual mix and playback in the published place still need review. UI feedback must remain complete if playback fails.

## Race UI

Make a `BingoRace` component owned by `MatchView`. It receives the server projection and local user ID; it does not compute competitors' progress from guessed client actions. Display compact first and second rank groups plus “YOU” while playing; allow all active participants to be revealed on demand. Make ties and groups explicit. On narrow viewports, keep the collapsed state small and place expansion where it can be closed and the card remains readily accessible. On wide viewports, use the available left-side information area without reducing card size or covering the called ball. The `ResultsView` retains the authoritative outcome and hides the live race.

Track transition cues by `sessionId`, `matchId`, player ID, and remaining count so a repeated snapshot does not replay a leader or one-away animation. Only play a near-win cue when progress crosses its threshold; do not play it when joining an in-progress match or restoring the UI from a snapshot. Calls, local marks, and result cues take priority over race cues. All race states use text labels alongside color and motion.

## Delivery order

1. Add server standings projection and immediate post-mark update.
2. Add client confirmed-mark event detection and compact race UI.
3. Add short visual/audio feedback and independent effects mute.
4. Integrate lead/near-win transitions and responsive expansion.
5. Review the whole call → mark → race → result loop in Studio, then playtest for fatigue and excitement with players.

Keep this change inside the existing Bingo feature boundaries. Add a component only for the race presentation; no new state machine or remote layer is necessary.
