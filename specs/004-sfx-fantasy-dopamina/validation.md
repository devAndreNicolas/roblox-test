# 004 — Validation Plan

**Status:** Partial solo Studio checks recorded on 2026-10-20; multiplayer, real phone/gamepad, published audio, and player acceptance remain open. **Spec:** [Match Feedback and Bingo Race](spec.md).

Record place/build, participant count, viewport/device, sound setting, steps, expected and actual result, console output, and screenshot/video reference. Mark each case pass, fail, or not run.

| ID | Scenario | Pass condition |
|---|---|---|
| V01 Mark loop and hierarchy | Observe several calls and accepted marks, then a near-win and result. | A single short mark response follows each server confirmation; call and card stay legible; near-win is distinct; result remains the strongest beat. |
| V02 Validation, delay, and repeat | Tap uncalled/marked cells, send a stale match request, delay acceptance, reconnect or receive repeat snapshots. | No false reward or race increment; a late accepted mark responds once; repeated snapshots do not replay it. |
| V03 Ranking and tie cases | Run 2–8 clients; create equal counts, a sole leader, multiple tied leaders, a departure, and a new match. | Counts are server-correct; ties share rank; no false second place; stale players and old matches disappear. |
| V04 Layout and accessibility | Check narrow/wide viewports, touch, gamepad focus, sound off, and reduced attention to motion. | Race and local progress remain understandable in text; expansion is dismissible; card/call are never covered by default; no rapid flash or forced camera motion. |
| V05 Visibility and lifecycle | Check a participant, queued nonparticipant, solo Studio override, win, and draw. | Only participants see live race; solo has no invented opponent; authoritative result overrides race. |
| V06 Audio robustness | Toggle music and effects independently; try unavailable audio asset and overlapping marks/calls. | Toggles work during play; mix remains intelligible; visual confirmation and match flow survive asset failure. |
| V07 Product playtest | Observe unassisted rounds with children 5–8, 9–12, and teenagers 13–17 separately where feasible, including Bingo newcomers. | Capture direct quotes and observed behavior: did they understand a mark counted, notice who was close, feel motivated or discouraged, tire of sounds, and choose another round? Treat a small sample as directional. |

Do not mark “dopamine” or retention as validated from a single enthusiastic response. The owner report establishes a friction point and design hypothesis; player behavior must determine whether the solution helps.

## Recorded Studio checks — 2026-10-20

Environment: connected **BINGO Experimental** place `105504891926354`, Studio solo Play, one client, desktop viewport capture `1622×663`. Studio MCP captures `004_lobby_initial`, `004_match_after_mark`, `004_race_expanded_fixed`, and `004_synthetic_narrow_fixed` are session captures, not repository image files. The narrow capture used a temporary `375×600` client content frame on desktop; it was not a touch or device emulator run. Play was stopped after inspection, so the temporary frame size was discarded.

| Case | Status and observation |
|---|---|
| V01 | **Partial:** a called card number accepted through the UI changed its square to the green checked state and the race from 24 to 23 remaining. The shorter mark cue and music ducking were added after this capture and still need listening review. Near-win and result beats were not reached. |
| V02 | **Not run:** rejected, delayed, duplicate, stale, and reconnect cases need explicit observation. |
| V03 | **Partial:** solo round showed only the local player and “Solo round”; the expandable list first exposed an oversized empty panel, which was corrected to size to visible rows and scroll for larger groups. Ties, departures, and multiple clients were not checked. |
| V04 | **Partial:** a temporary narrow `375×600` desktop content frame showed call, card, compact race, status placement, and audio buttons in separate vertical bands after a spacing correction. Actual phone touch, gamepad focus, and other device sizes were not checked. |
| V05 | **Partial:** solo participant saw the live race; lobby/backstage did not show it. Nonparticipant during an active multiplayer round, draw, and result handoff were not checked. |
| V06 | **Partial:** the mark click and bell assets reported `IsLoaded=true` in the Studio client. Music remained on after Effects was switched off. Published-place playback, audible mix, fallback failure, and the final shortened/ducked cue need review. |
| V07 | **Not run:** no unassisted child or teenager playtest has been performed. |

No 004 script error was observed in the Studio console during these checks. Studio emitted CorePackages `FoundationProvider` warnings and an unrelated `rbxassetid://203785492` asset-type warning; the observed 004 click and bell asset IDs loaded. These observations do not establish that the experience is error-free across clients.
