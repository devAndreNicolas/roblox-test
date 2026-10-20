# 003 — Scenario Validation Plan

**Status:** Solo Studio smoke checks recorded on 2026-10-20; full acceptance remains open. Product appeal has not been validated with players.
**Requirements:** [Spec](spec.md) · [Source audit](research/code-audit.md).

## Evidence to capture

Record build/revision, Studio viewport and rendering settings, device profile, player count, steps, expected versus actual result, console output, and screenshot/video references. Capture backstage spawn-to-portal, studio reveal, stage/MC, and all participant stations. Mark each case pass, fail, or not run; do not infer mobile or eight-player behavior from one desktop session.

## Cases

| ID | Steps / trigger | Pass condition | Requirements |
|---|---|---|---|
| V01 Backstage navigation and identity | Spawn without instructions; identify the portal and queue state. Repeat from the furthest lobby point and phone viewport. | Player finds the route; backstage reads as a waiting area; active studio is not visible or available as a spectator view. | WORLD-01/02/13 |
| V02 Studio reveal and seating | Start a match with eight clients and observe transition, every station, and view toward MC/call. | Participants arrive at eight distinct stations facing the host; scene reads as theatrical noir TV and all gameplay remains visible. | WORLD-03/08/13/14/17 |
| V03 Prompt, spawn, seating, and respawn | Use portal on keyboard/gamepad/touch; test character delay and respawn both in lobby and match; attempt jump and attempt to leave the seat during a match; end match and attempt jump again. | Portal interaction is reachable; a participant who becomes unseated is restored to their station while active; input binding is restored after all exits; placement follows current server membership. | WORLD-08/10/17 |
| V04 Presentation, effects, and comfort | Observe host idle, calls, accepted/rejected marks, and winner; repeat with audio muted and test mute control. | Call/mark cues are brief, only server-accepted marks look confirmed, Bingo celebration is clearly stronger, nothing hides the card/call, and muted players understand every event. | WORLD-05/06/07/15/16/18/19 |
| V05 World lifecycle and fallback | Initialize twice; initialize with a stale Bingo world; remove optional decor or MC animation in a controlled development copy. | One current Bingo-owned scene is present, unrelated Workspace objects remain, optional presentation failures do not prevent queue/match flow, and cleanup removes only owned resources. | WORLD-09/11 |
| V06 Reproduced annoyance/bug | Replay each recorded issue from the reported device/location/action; also run normal join, match, result, and return flow. | Each fix resolves the documented expected/actual mismatch and introduces no regression to queue, match interaction, movement, or captions. Unknown symptoms stay open. | WORLD-08/10/12 |
| V07 Product playtest | Run unassisted sessions with children and teenagers as separate cohorts; where feasible, separate ages 5–8 from 9–12. Include Bingo newcomers and familiar players. Observe first destination, backstage wait, reveal, seat comfort, call/mark comprehension, excitement, and whether they choose another round. Ask if the set feels mysterious, fun, scary, or too young. | Record cohort, prior Bingo familiarity, individual observations, and direct quotes. Check whether the shared noir identity supports both groups; revise from repeated observed friction. A small cohort is directional, not market validation. Research with minors follows Roblox requirements and uses appropriate parent/guardian permission. | WORLD-01–06/13–19; AUD-01/02 |

## Recorded Studio checks — 2026-10-20

Environment: connected **BINGO Experimental** place `105504891926354`, Studio Play, one client, desktop viewport `1622×663`, Studio solo minimum override. Rendering quality setting was not captured. Roblox Studio MCP captures from this session: `bingo_lobby_v3`, `bingo_match_v3` (intro), and `bingo_match_v4` (calls). These IDs describe observed captures; they are not saved image files in the repository.

| Case | Status and observation |
|---|---|
| V01 | **Partial:** backstage floor, carpet, benches, instruction posters, portal, and queue sign appeared in the viewport. The portal was reached through a controlled character repositioning and the keyboard `E` action joined the queue. Unassisted wayfinding and phone viewport remain open. |
| V02 | **Partial:** one participant entered the studio and occupied `Station1`; the MC and call display were visible during intro and live calls. The generated world had one `BingoWorld` root, version `6`, and eight `Seat` instances. Eight-client sightlines and collisions remain open. |
| V03 | **Partial:** keyboard portal interaction worked. Pressing Space during the live match left the Humanoid seated in `Station1`. A server-triggered character reload returned the active participant to `Station1`. Gamepad, touch, delayed spawn, post-result release, and unexpected unseat recovery remain open. |
| V04 | **Partial:** the call display updated with the server call; a previously called card number became a confirmed green stamp after activation. The temporary jazz sound reported `IsLoaded=true` and `IsPlaying=true`; activating Music: Off set volume to zero. Winner celebration, audio listening review, and mute checks across devices remain open. |
| V05 | **Partial:** one current generated root was observed. Repeated startup, stale-version rebuild, optional-element fallback, and teardown remain open. |
| V06 | **Not run:** the original “buggy/annoying” report still lacks reproduction steps. No new Bingo script error appeared in the observed Studio console; this is a smoke check, not a bug closure. |
| V07 | **Not run:** child and teen cohort playtests remain to be organized. |

## Exit criteria

- All visual/runtime cases have recorded outcomes; unavailable devices or player counts remain “not run.”
- Eight-player sightlines and movement are shown in evidence.
- At least one unassisted player route from spawn to portal is observed.
- Every claimed bug fix links to a reproduced case; vague reports remain documented as unknown.
- Screen UI and scene/caption behavior are checked together with 002 but remain owned by that feature.
