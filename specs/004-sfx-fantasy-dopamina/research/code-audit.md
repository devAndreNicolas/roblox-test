# 004 — Source Audit

**Read:** 2026-10-20, before implementing 004. The statements below describe the baseline source, not the current implementation or a Studio verification.

- `src/server/Features/Bingo/BingoService.luau` owns participants, cards, match phase, accepted marks, and winner decisions. `snapshot()` sends the local card and calls but no public progress. A nonwinning accepted mark currently sends only the marking player an immediate success snapshot; others wait for the next periodic broadcast (up to about one second). Winner path already broadcasts.
- `src/shared/Features/Bingo/BingoTypes.luau` defines `Snapshot`; there is no standings projection type.
- `src/client/Features/Bingo/BingoController.luau` keeps mark requests pending for two seconds, then clears them. It receives snapshots, but has no dedicated confirmed-mark event. An effect tied only to pending state would miss a late accepted response.
- `src/client/Features/Bingo/Components/BingoCard.luau` already stamps a newly marked square with a short scale tween. It renders from confirmed card state; extending that response should preserve the server-confirmed boundary and avoid replay on routine render.
- `src/client/Features/Bingo/Views/MatchView.luau` has a call panel, card, and recent-call/reminder panel. A race component needs a deliberate responsive placement so it does not shrink the card or cover the call.
- `src/client/Features/Bingo/ShowAudio.luau` currently plays local music and provides one music toggle. There is no separate effects channel or effects mute.
- `src/shared/Features/Bingo/BingoConfig.luau` sets a five-second call interval and at most eight players per match. The center square is free, so full-card completion requires 24 confirmed non-free marks.
- `specs/003-fantasy-scenario/spec.md` already requires brief call/mark feedback, stronger Bingo celebration, and visible confirmation only after server acceptance. 004 deepens the in-match feedback and adds public race progress; it does not replace those constraints.
