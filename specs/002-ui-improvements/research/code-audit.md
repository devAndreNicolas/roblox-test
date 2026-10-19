# Code audit supporting 002

Inspected 2026-10-19. This is source analysis, not a Studio playtest. Line anchors refer to the pre-refactor files and will move during implementation. Preserve the raw [owner feedback](playtest-feedback.md).

Priority: **P0** prevents core play; **P1** breaks a phase or meaningful interaction; **P2** correctness/recovery issue that must be covered during this refactor. Runtime priority can be revised after reproduction.

| ID | Priority / evidence | Finding and trigger | Required outcome |
|---|---|---|---|
| B01 | P0; source-proven geometry | BingoController lines 241–242 allow gamePanel height 430. Card occupies y=96..456; history occupies y=390..422 at that height. They intersect, and the card extends past its parent. The 430 minimum also exceeds a 390-high landscape viewport before insets. | Layout based on available safe area; card/history/call have distinct regions at target sizes. |
| B02 | P1; source-proven geometry | callSubtext is at x=63% with height 50, y=18. Skip button occupies the top-right 92×30 at y=10. At width 540 their bounds overlap; at width 290 the skip button also reaches the main instruction's text box. | Dedicated action area separate from captions and card. |
| B03 | P1; presentation risk, reproduce visually | Intro uses the full gamePanel/card over the scene. LobbyWorldService.makeBillboard sets AlwaysOnTop=true, MaxDistance=100 for both portal and MC captions, with no per-player context suppression. | Compose MC and card intentionally; inspect world/screen text together and remove competing presentation locally. |
| B04 | P1; source-proven lifecycle | restoreGameplayCamera changes camera/token but does not mark the scene completed. render derives skip visibility from global phase and skippedSceneKey only. After the three-second results scene finishes, the next snapshot shows Continue again until server results end. | Local scene completion remains durable; completed scenes have no skip action and do not replay. |
| B05 | P1; source-proven missing exit handling | CallingNumbers and lobby branches do not immediately cancel a previous scene. There are no character/current-camera replacement handlers. Camera restoration depends on the original delayed callback. Early transitions or respawn can retain Scriptable ownership. Exact visual impact needs runtime reproduction. | Release ownership on every lifecycle exit, and prevent old callbacks from affecting a replacement camera/scene. |
| B06 | P1; source-proven duration mismatch | Intro always calls playCameraScene with server timeRemaining, regardless of isFirstMatch. Server chooses eight seconds if anyone is new, so a returning player's local scene can also last eight seconds. | Returning local scene ends within three seconds, while shared intro may continue. |
| B07 | P2; source-proven configuration drift | Calling progress divides timeRemaining by literal 5 instead of configured CALL_INTERVAL_SECONDS. | Changing the server interval changes the client's progress denominator without editing UI code. |
| B08 | P1; source-proven contradictory copy | Countdown message tells an unqueued player to join “the next one.” Server permits portal enrollment until countdown finishes. | Tell the player they can join this match while enrollment remains open. |
| B09 | P2; source-proven feedback behavior | toast.Text = snapshot.notice or empty clears notices on routine one-second snapshots. Severity uses string.find(notice, "not"), so meaning depends on English phrasing. | Typed notice severity and local expiry independent of ordinary snapshot refresh. |
| B10 | P1; source-proven lifecycle design defect | Module import constructs GUI and connects button handlers. BingoController.Start and RoundService.Start attach listeners with no duplicate-start guard or teardown. Calling Start twice duplicates update/request processing. | Explicit owned initialization/cleanup, one UI root and one set of listeners. |
| B11 | P2; race risk identified in source | RoundService.movePlayer captures destination before waiting for a character/root, then checks only whether player is still present. A phase/membership change while waiting can move a respawned player to an old destination. | Re-evaluate current membership/match and character identity after each yield before positioning. |
| B12 | P2; recovery gap identified in source | Client requests one initial snapshot and shows loading until one arrives. There is no timeout or retry path if initial synchronization fails or dependencies remain unavailable. | Bounded loading state with actionable retry; repeated attempts cannot duplicate feature initialization. |

## Contract and regression observations

- Card generation, shuffle, full-card detection, network validation, snapshots, queue, timers, player placement, and orchestration currently share RoundService. Extraction seams are visible in actual functions; server decomposition no longer needs to remain an unspecified future review.
- View construction, domain-shaped state, remote access, camera ownership, and render-time side effects share BingoController. The issue is coupled responsibilities, not its raw line count.
- Mark validation already checks phase, participant, match, finite index, called membership, and rate limit. Preserve these checks during extraction.
- The existing call loop allows a complete final-call interval before drawing. Preserve that opportunity; do not regress to ending immediately upon announcing the final number.
- First-match tutorial text, mixed cohorts, results camera duration, and server result duration are different concerns. A single phase flag is insufficient to own all of them.

## Evidence to collect during implementation

Capture each baseline defect at its listed trigger where possible. Mark it reproduced, source-confirmed, or not reproduced with environment details. After fixes, record the same case and viewport again. Do not fabricate before/after screenshots or mark a runtime case passed from source inspection alone.
