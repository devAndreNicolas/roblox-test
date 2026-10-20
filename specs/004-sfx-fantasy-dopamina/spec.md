# 004 — Match Feedback and Bingo Race

**Status:** Implemented in source; solo Studio checks partially recorded, multiplayer/device/player acceptance pending.
**Source:** [Playtest feedback](research/playtest-feedback.md). **Audience lens:** [Player personas](../player-personas.md).

## Problem and intended outcome

The owner liked the new atmosphere but reported that repeatedly marking numbers during a match feels monotonous. They suggested more satisfying effects and sounds for a valid mark, plus a list showing who is closest to winning, with tension around first and second place. This is one person's report, not evidence that a particular effect releases dopamine or improves retention.

The intended outcome is that a player can immediately feel and understand **“my mark counted”** and can see the race toward Bingo without losing sight of the call or card. We will test whether that makes the round more engaging for both children and teenagers.

## Product decisions for this MVP

- Preserve the existing 75-ball, full-card, server-authoritative rules, match capacity, and Bingo Noir art direction.
- Treat a mark as a small satisfying beat: immediate confirmation on the marked square, a short visual echo toward personal progress, and one distinct local sound. Keep the call smaller and the Bingo win clearly larger.
- Show an in-match **Bingo Race** ordered by *confirmed marks remaining*. There are 24 markable squares because the center is free. A player with fewer remaining is closer to Bingo; a tie is shown as a tie, never as an invented first-versus-second gap.
- Give the leader and next rank a restrained stage-style highlight. When a leader has three or fewer remaining, make the race more prominent; at one remaining, show a brief “ONE TO BINGO” cue. The cue does not imply the next call will complete the card.
- Keep the race compact while playing. On wider screens it shows the first and second rank groups plus the local player; an optional expandable list shows all participants. On narrow screens the collapsed view retains the local player and leader information, and expansion must be dismissible without covering the card by default.
- Build the MVP with native Roblox UI tweens, light/particle effects already used by the game, and replaceable licensed or original audio. No new external art pipeline or purchased asset is required for the first pass.

## Experience beat and visual language

An eligible tap gets a quiet amber pending outline. On confirmation, the square briefly grows and settles into its green stamp; a small amber glint travels toward the player's “X to Bingo” count as that number changes. The proposed beat lasts roughly 0.3–0.5 seconds, with a soft percussive click and a short rising two-note cue. Use the existing midnight/ivory/amber palette and reserve the brighter spotlight and longer musical phrase for an actual Bingo result. The sound and motion are prototypes to tune by listening and playtesting; they must not delay the next tap.

The race uses an amber spotlight edge for the lead group and a quieter ivory edge for the next distinct rank. At three remaining, a brief edge sweep signals the approach; at one remaining, “ONE TO BINGO” appears in text. If several players tie for a rank, the compact panel summarizes the tied group and the expanded list names everyone. This communicates competition without assigning a false order or flooding the card with effects.

## Functional requirements

### Mark feedback

- **FB-01 Confirmed only:** A tap may show a subtle pending state, but the rewarding stamp, progress increment, and mark sound happen only after the server confirms that specific cell. A rejected, duplicate, uncalled, or stale-match request never plays the success beat.
- **FB-02 Layered response:** Each accepted local mark gives one short square animation, one brief progress motion, and one local sound. The card number remains readable throughout. Repeated snapshots cannot replay the response for the same mark.
- **FB-03 Hierarchy:** New calls remain prominent; ordinary marks feel rewarding but do not interrupt marking the next number. The last three marks may add anticipation, while the completed card and server result get the strongest celebration. A client never announces a winner from its own count.
- **FB-04 Comfort and controls:** Effects use no rapid flashing or screen shake. They do not require sound, color, or animation timing to understand. Players can turn effects sound off independently of music; both controls remain reachable during a match. Mute settings last for the current client session.
- **FB-05 Asset fallback:** If an audio asset is unavailable or fails to load, marking, progress, and the match continue with readable visual feedback. Sound choices and volumes are replaceable without changing game rules.

### Bingo Race

- **RACE-01 Server progress:** The server computes public progress from confirmed participant cards. The free square is excluded. The client receives only user ID, display name, confirmed marked count, and remaining count for each active participant; no opponent card numbers or unmarked positions are exposed.
- **RACE-02 Fair ordering:** Sort by fewest remaining. Participants with equal remaining count share the same displayed rank. The next rank uses competition ranking (two tied first means the next player is third). Name or user ID may stabilize row order within a tie, but must not imply a lead.
- **RACE-03 Freshness:** Every accepted mark updates the participant's own card and the race promptly for all current participants. Join, departure, new match, and round completion remove or replace stale rows. A disconnected player no longer appears as an active contender.
- **RACE-04 Match context:** The race is visible only to current participants while the match is live. The lobby/backstage view does not become a spectator leaderboard. The local player is clearly identified even when outside the leading ranks. For a solo Studio round, the race shows only the local player and no false second place.
- **RACE-05 Readable pressure:** First and second rank groups have distinct labels and restrained accents; tied groups explicitly say they are tied. “X to Bingo” is shown as text and changes only on a confirmed mark. At three or fewer remaining, the current leader gets a stronger but brief cue; at one remaining, the cue is brief and appears once per transition, not on every snapshot. Effects never obscure the call, card, or input targets.
- **RACE-06 Result boundary:** The race freezes or yields to the authoritative results view when the round ends. No race update after `RoundComplete` can contradict the named winner or draw.

## Acceptance scenarios

1. **Accepted mark:** Given a called unmarked cell, when the server accepts the tap, the cell stamps once, progress decreases by one remaining, the race updates for participants, and one local mark sound plays if effects sound is on.
2. **Rejected or delayed mark:** Given an uncalled, duplicate, stale, or rejected tap, the pending state clears, no success cue plays, and neither the count nor the race moves. A slow accepted response still produces one confirmation when it arrives.
3. **Tied race:** Given two players at the same remaining count, both show the same rank with a tie label. The next player is ranked after both; no second-place badge appears when second place does not exist.
4. **Near finish:** Given a leader moving from four to three remaining, the race briefly highlights the milestone. At one remaining it shows “ONE TO BINGO” once. Other players can still read the call and mark normally.
5. **Mute and fallback:** Given effects muted or an unavailable sound, visible text, stamp, and counts still communicate the outcome. Music can be controlled independently.
6. **Lifecycle:** Given a player leaving, a new match starting, or a draw/win ending the round, standings reflect only the correct match and the results view stays authoritative.
7. **Phone and gamepad:** The race can be read or expanded on a phone and navigated by gamepad without blocking card cells or the called number.

## Scope boundaries and hypotheses

This feature does not change the win condition, call pacing, queue system, cards, rewards, economy, or matchmaking. It does not introduce streak bonuses or imply that a player can buy or speed up progress. The exact sound mix, the three-remaining threshold, and whether visible standings improve the match are hypotheses to adjust after playtests. Measure comprehension, mark fatigue, comfort, and replay choice rather than claiming a biological effect.
