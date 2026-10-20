# 002 — Implementation Plan

**Status:** Proposed; grounded in [source audit](research/code-audit.md).
**Contract:** [Specification](spec.md) · [Tasks](tasks.md) · [Validation](validation.md).

## 1. Delivery strategy

Fix behavior and reorganize its owning modules in bounded slices. First establish state/lifecycle ownership, then replace the UI one context at a time. Extract server rules and transport before changing their surrounding orchestration. Keep the working game runnable after each slice.

The existing Rojo mappings already separate client/server/shared. Keep those mappings; update entrypoint requires and internal module paths. No framework or package manager is needed for this change.

## 2. Visual design proposal

**Subject:** a social Bingo club presented by an MC. **Main job:** help a new player follow a call and mark a paper card.

The signature is a large numbered call ball beside a cream paper card; confirmed marks look like ink stamps with a check/ring. Reserve visual energy for the new call, accepted mark, card reveal, and winner. Scene captions use a quiet readable surface, not another competing game panel.

| Token | Proposed value / use |
|---|---|
| Stage | #233CB9, restrained blue accent/background for scene framing |
| Paper | #FFF8E7, card and light surfaces |
| Ink | #16243A, primary text and outlines on light surfaces |
| Mark | #17775B, accepted marks with a visible check/ring |
| Spotlight | #F7C65B, current call/free-space emphasis, dark text |
| Alert | #D6485C, error accent accompanied by explicit text/icon |
| Typography | Rounded bold display for short headings; legible bold numerals; Gotham body/captions. Scale: 14 secondary, 16 body, 24 heading, 36–48 call number. |
| Spacing | 4/8/12/16/24 UI pixels; consistent padding and gaps |
| Surfaces | Paper card, compact status strip, caption panel; avoid wrapping every label in its own pill |
| Motion | Short call/mark feedback; card reveal and camera motion are cancellable and optional for comprehension |

Verify contrast in actual UI. Error/mark colors need not be used as small text on dark surfaces. Use text/icons as well as color. Shared primitives include focused/pressed/disabled states; actions retain the same label and meaning across contexts.

### Layout sketches

Lobby: leave the world and portal visible. A compact status strip communicates membership and the next action.

Portrait calling:

```text
[ current call ball | next-call cue ]
[ B   I   N   G   O                 ]
[       5 × 5 playable card         ]
[ recent calls / short rule reminder]
[ reserved feedback and safe area  ]
```

Short landscape calling:

```text
[ call ball + timing ] [ B I N G O         ]
[ short reminder    ] [ 5 × 5 card        ]
[ recent calls      ] [                   ]
[ feedback          ] [                   ]
```

Scene:

```text
[       unobstructed MC/camera area       ]
[ card preview in its own reserved area  ]
[ readable MC caption ] [ skip scene     ]
```

During intro, reuse the same card module in preview mode; during calls, use interactive mode. Results own a dedicated outcome composition, rather than a banner laid over the active card. Optional final-card recap is read-only.

Use available safe width/height to select stacked versus side-by-side composition. Short height is a breakpoint condition even when width is large. Reflow history/captions before shrinking the card. Avoid a minimum container height larger than the usable viewport, and avoid uniform scaling that reduces touch targets below the spec.

## 3. Feature layout and interfaces

```text
src/
  client/
    init.client.luau
    Features/Bingo/
      BingoController.luau
      BingoRemoteClient.luau
      PresentationState.luau
      ScenePresenter.luau
      Views/
        LobbyView.luau
        IntroView.luau
        MatchView.luau
        ResultsView.luau
      Components/
        BingoCard.luau
        CallBall.luau
    UI/
      Theme.luau
      ActionButton.luau
      StatusMessage.luau
  server/
    init.server.luau
    Features/Bingo/
      BingoService.luau
      BingoQueue.luau
      BingoRules.luau
      BingoTransport.luau
      BingoWorld.luau
  shared/
    Features/Bingo/
      BingoConfig.luau
      BingoTypes.luau
```

This groups by the Bingo domain. Lobby/intro/match/results are views within that domain. Cross-feature UI primitives live outside it; Bingo-specific card and ball stay inside it.

| Module | Interface and implementation ownership |
|---|---|
| BingoController | Start/Destroy; owns latest accepted snapshot and composition. Routes intents through the remote client, renders view models, coordinates scene entry/exit. Does not construct detailed UI trees. |
| BingoRemoteClient | Connect(snapshot callback), requestSnapshot(), markCell(matchId, cellIndex), skipIntro(matchId), Destroy. Owns remote references/subscription and bounded initial-sync retry. No view references. |
| PresentationState | Pure derive(snapshot, localSceneState) -> presentation model. Centralizes role/phase selection, visibility, labels, and allowed actions. No Instances/remotes/timers. |
| ScenePresenter | Play(key, duration, onComplete), Stop(reason), Destroy. Owns camera capture, tween, completion, character/camera listeners, and local world-caption suppression. Completion callback cannot outlive its scene. |
| Views | Mount(parent, intents), Render(model), Destroy. Own layout and local UI handlers. Instances created during Mount, not require. Hide/inactivate old view before showing new one; rendering is repeatable without scene side effects. |
| BingoCard | Create(parent, onMarkIntent), Render(card, mode, pending, calledSet), Destroy. Owns the grid, preview/play/read-only modes, per-cell eligibility/mark visuals, and input. During play, only unmarked cells in calledSet are selectable. Does not import remotes. |
| UI primitives | Small interfaces for consistent theme, actions, and notices. StatusMessage owns notice expiry. Avoid generic instance-factory abstractions unless real repetition warrants them. |
| BingoService | Start/Destroy; owns phase, match id, participants/cards, calls, results, deadlines and generation guards. Coordinates queue, rules, transport, and world. One authoritative match owner. |
| BingoQueue | Join/Leave/Contains/Count/TakeEligible/Clear; sole owner of queue membership. Service determines when enrollment is permitted and when countdown/lock occurs. No world/remote access. |
| BingoRules | GenerateCard(random), ShuffleCalls(random), ValidateMark(card, calledSet, index), IsComplete(card). Domain calculations with explicit inputs; no Players, remotes, task waits, or world changes. Service commits accepted marks. |
| BingoTransport | Start(command handlers), SendSnapshot/Broadcast, RemovePlayer, Destroy. Owns remote creation, payload shape guards, per-player rate limits and subscriptions. Service validates phase/membership/match and decides outcomes. |
| BingoWorld | Start, UpdateQueue, UpdateMC, PlacePlayer, Destroy. Adapts existing lobby/NPC construction and staging. Placement re-resolves destination/character after waits using current service state. Teardown affects only owned objects/listeners. |
| Shared | One definition of Phase, CardCell, Snapshot, Result, Notice, plus configuration. No mutable game state and no client-importable server implementation. |

Dependency direction: entrypoints -> feature orchestration -> feature modules -> shared types/config and UI primitives. Views depend on supplied models and callbacks; they cannot import the orchestration module. Avoid circular requires and legacy pass-through controllers after migration.

## 4. State, timing, and network

Retain remote names and existing client request argument order: RoundUpdate, MarkCell(matchId, cellIndex), RequestSnapshot(), SkipScene(matchId). Update the snapshot producer and consumer together for:

- callIntervalSeconds: authoritative denominator for call progress.
- phaseDurationSeconds: duration for current intro/countdown/results context.
- notice: optional structured {id, kind, text}, with kind success/error/info. StatusMessage keeps a notice until local expiry and ignores repeat IDs.

Keep timeRemaining authoritative in each snapshot. Local monotonic elapsed time may interpolate the bar between snapshots, clamped at zero; only a server update advances game phase/call. Do not invent a called number when a client timer expires.
MarkCell(matchId, cellIndex) can change only the caller's card. A valid accepted mark cannot advance the call timer; only the server deadline announces the next number. The client derives cell eligibility from the full calledNumbers list and sends no mark request for an uncalled cell. A completed card can transition the match to results.

Local scene state is keyed by matchId and scene kind, with idle/playing/completed/skipped states. Scene completion never resets simply because a new snapshot arrives. Keep scene duration distinct from server phase duration.

After local intro completion, show the card and concise reminder until the server permits marking. Retain the reminder throughout the first active match. A result-scene skip restores the camera but keeps the outcome visible until the server returns participants to the lobby.

Pending cell feedback is cosmetic. Clear it on confirmation/rejection, phase/match change, or a bounded two-second timeout; never infer acceptance from a timeout or automatically resend mark requests.

## 5. Lifecycle and failure handling

- Camera entry saves the relevant camera reference, type, subject, and field of view. Exit cancels its tween/tasks, restores saved state when valid, or binds normal gameplay to the current character. Replacing a camera/character exits the old scene without restarting it.
- Generation guards protect asynchronous callbacks. Completion for an old scene cannot hide a new view or restore the wrong camera.
- Views own and disconnect their connections. Controllers own feature lifetimes. Start called twice yields one functioning instance; Destroy followed by Start is supported for lifecycle verification.
- Missing NPC/camera objects trigger a caption/card fallback, no endless wait. Scene instructions remain available even if camera staging cannot run.
- Server placement rechecks player presence, character identity, and current phase/membership after each yield. A stale destination cannot override a later lobby return.
- All winner decisions occur without yielding between validation, accepted mark, and terminal state transition. Countdown cancellation, last-participant departure, and repeated startup remain guarded.

## 6. Migration and compatibility

1. Establish validation cases and capture baseline failures without changing game behavior.
2. Introduce shared types/config, pure presentation derivation, remote adapter, and explicit mount/cleanup. Route existing presentation through these interfaces while replacing its side effects.
3. Implement ScenePresenter and correct B04–B06/B10 before adding more animation.
4. Build the card and four views with the responsive visual system; retire the old all-in-one construction path. Correct B01–B03/B07–B09/B12.
5. Extract server rules/queue/transport/world into the feature, preserving service-owned state transitions and correcting B11. Move configuration requires in client and server together.
6. Remove superseded files only after callers have migrated. Confirm the unused Hello module has no references before removing it.
7. Run the validation matrix, capture visual evidence, and update 001's current mapping and clarified behavior.

The acceptance surface is the module interface and player journey. Verification must exercise phase selection, rules, cleanup, and race behavior; checking that a file exists or testing individual theme constants is not useful coverage.
