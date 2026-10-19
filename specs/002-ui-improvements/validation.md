# 002 — Acceptance and Regression Matrix

**Status:** Planned; no Studio tests performed during this specification revision.
**Requirements:** [Spec](spec.md). **Known defects:** [Audit](research/code-audit.md).

## Environments and evidence

Use Studio device emulation at 360×640, 390×844, 844×390, 1280×720, and 1920×1080. Capture usable viewport/insets and whether Roblox touch controls are visible. Phone play remains a separate check when a physical device is available; emulation is not a claim of device testing.

Use at least two clients for participant/nonparticipant and mixed-cohort cases, plus three consecutive matches in one session. Exercise the published two-player setting explicitly; the solo Studio override cannot verify it.

For each case record: build/revision, environment, steps, expected versus actual outcome, pass/fail/not run, console errors, and evidence path or screenshot reference. Use controlled development fixtures for win/draw/late-state cases when necessary; do not leave production debug remotes or test shortcuts enabled.

## Cases

| ID | Steps / trigger | Pass condition | Requirements / bugs |
|---|---|---|---|
| V01 Context matrix | Traverse every matrix row; keep a second player unqueued/queued while another match is active; refresh snapshots in each phase. | Exactly the appropriate presentation is interactive. Nonparticipants retain lobby/next-match UI and never receive participant camera scenes. Repeated snapshots do not replay effects. | UI-01/02, FIX-02 |
| V02 Queue and countdown | With solo override disabled, join with one then two players; unqueued player joins during countdown; queued player leaves before lock; late arrival joins after lock. | Correct minimum/cancellation; pre-lock enrollment is for this match; post-lock enrollment is for next; copy matches actual membership. | FIX-06, ARCH-04, B08 |
| V03 Viewport and layout | At each target size, display lobby, intro, calls, and results; resize during reveal; enable touch controls; use long captions/names. | No unintended overlap/clipping; portal and scene focal area visible; current call/all cells accessible during play; active controls ≥44×44 and essential text ≥16 UI pixels. No screenshot pass based on desktop alone. | UI-02–07, FIX-01, B01–B03 |
| V04 Scene completion and skip | Let result scene finish naturally; receive several more result snapshots. Repeat with intro/result skip, and transition phase while tween is running. | Camera ownership released; skip stays hidden after completion; scene does not replay; intro skip waits for server if needed; result skip retains result until server ends eight-second display. | FIX-02–05, B04/B05 |
| V05 Mixed/repeated intro | New player and returning player enter together. One skips, then all skip. Repeat round with only returning players. Remove a participant during intro. | New player gets full instruction; returning local camera lasts ≤3s even when shared intro lasts longer; departed players cannot block shared skip; no marks before calls; tutorial reminder survives skip. | FIX-04/05, B06 |
| V06 Marks and visual states | Mark a called, earlier called, uncalled, duplicate and free cell; tap quickly; issue stale/nonparticipant request; end match during pending feedback. | Only server accepts changes; pending feedback resolves or expires, no stuck input; correct number/cell remains mapped after resizing; results/intro cannot submit marks. | UI-06, ARCH-02/04 |
| V07 Timing and feedback | Temporarily use a 7-second interval; observe progress. Trigger success/error/info notices immediately before a regular snapshot. Restore default after check. | Bar follows actual interval; no next call invented locally. Notice persists 3s unless replaced, uses explicit severity, and clears on match change. | UI-08, FIX-06, B07/B09 |
| V08 Lifecycle race | Respawn/change current camera during scene; delay root arrival across round end; leave while placement waits; finish one scene then immediately begin another. | New character/camera uses current context; old tween/callback cannot override it; delayed placement honors current membership; no stale teleport or stuck Scriptable camera. | FIX-03/07, B05/B11 |
| V09 Initialization and cleanup | Call Start twice; Destroy then Start; perform three match cycles. Inspect owned roots/connections via lifecycle instrumentation. | One UI root/subscription set; one intent per activation; destroyed views do not react; no accumulating tasks/connections or require cycles. | FIX-07, ARCH-01–03, B10 |
| V10 Game/server regression | Exercise seeded card/call generation, invalid payloads, rate limits, simultaneous final marks, final-call draw interval, countdown cancellation, all participants leaving. | Correct 75-ball ranges/no repeats/free center, first accepted full card wins once, final number gets full action interval, state/timers remain owned and guarded, no weakening of server checks. | ARCH-04; 001 baseline |
| V11 Recovery | Delay initial state/dependencies, retry after 5s, then restore availability; remove/unavailable stage for scene entry in controlled setup. | Actionable loading retry; no duplicate subscriptions; valid snapshot restores context. Text/card fallback works without camera/NPC availability. | UI-01, FIX-07, B12 |
| V12 Visual/product review | Inspect all outcomes with short/long names. Ask a player to find the portal, explain the goal, make a mark, and identify who won. | Hierarchy and Bingo identity are coherent; outcomes use explicit text; player can perform the flow without developer narration. Record actual confusion instead of averaging it away. | UI-04/05; product outcome |

## Exit criteria

- All P0/P1 bugs fixed and demonstrated; P2 items also resolved or explicitly documented with owner agreement and a narrow follow-up.
- All matrix cases have recorded outcomes. Unavailable environments remain “not run,” with the limitation visible.
- Static/type/build checks pass where tooling is available; core rules/presentation logic checked through their module interfaces.
- No new runtime errors during the exercised journeys.
- Source matches the documented feature ownership; actual behavior changes and clarifications are reconciled with 001.
- Visual review includes screenshots of compact layouts and scenes. A code-only review cannot establish visual acceptance.
