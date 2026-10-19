# 002 — Delivery Tasks

**Status:** Specification and static audit prepared; implementation and runtime verification pending.
**Links:** [Spec](spec.md) · [Plan](plan.md) · [Audit](research/code-audit.md) · [Validation](validation.md).
Check a task after its stated outcome is demonstrated. Record verification separately from implementation; do not mark Studio cases passed based on code review.

## A. Baseline and contracts

- [ ] **T01** Reproduce baseline B01–B12 at their stated triggers; retain source-confirmed labels when runtime reproduction is unavailable. Record viewport, phase, role, and evidence. **V01–V12**.
- [ ] **T02** Define shared BingoConfig/BingoTypes and add typed notice, call interval, and phase-duration snapshot fields with producer/consumer migration together. Preserve remote names/request shapes. **UI-08, FIX-06, ARCH-01; V07, V10**.
- [ ] **T03** Implement pure role/phase/local-scene presentation derivation covering every context-matrix row. Include mixed cohorts and nonparticipants during an active match. **UI-01, FIX-02; V01, V05**.

## B. Client lifecycle and bug fixes

- [ ] **T04** Extract BingoRemoteClient and an explicit, idempotent BingoController lifecycle. Create UI during mount, own all listeners, and provide Destroy. **ARCH-02/03, B10; V09**.
- [ ] **T05** Implement ScenePresenter with durable completion, phase-aware exit, current-camera/character replacement handling, bounded durations, local skip, and cancellable delayed work. **FIX-02–05, B04–B06; V04, V05, V08**.
- [ ] **T06** Add snapshot timeout/retry and a missing-stage fallback. Ensure retry reuses one feature instance. **UI-01, FIX-07, B12; V11**.
- [ ] **T07** Implement structured notices with three-second lifetime and configuration-driven progress. Correct countdown enrollment copy. **UI-08, FIX-06, B07–B09; V02, V07**.

## C. UI and components

- [ ] **T08** Implement the proposed Bingo Club theme and reusable ActionButton/StatusMessage behavior, including focus/pressed/disabled styles. Record the adopted token values. **UI-05; V03, V12**.
- [ ] **T09** Implement BingoCard preview/play/read-only modes, stamp/free/pending states, server-confirmed rendering, and pending cleanup. Implement CallBall in the match feature. **UI-04–06, ARCH-05; V03, V06**.
- [ ] **T10** Implement compact LobbyView: visible world/portal, queued versus unqueued status, accurate join-now/next-match guidance. **UI-01/02, B08; V01, V02**.
- [ ] **T11** Implement IntroView: unobstructed MC, separate caption/skip areas, readable card reveal, post-skip waiting and first-round reminder. Suppress competing billboards locally. **UI-02/07, B02/B03; V03–V05**.
- [ ] **T12** Implement MatchView with portrait and short-landscape compositions, distinct call/card/history regions, safe areas and controls at target sizes. **UI-02–06, B01; V03, V06**.
- [ ] **T13** Implement ResultsView with own-win/other-win/draw states, long-name handling, separate camera and result lifetimes, and honest skip wording. **UI-01/04, FIX-02/04/05; V04, V12**.
- [ ] **T14** Remove old UI construction once all views are connected. Confirm hidden views cannot receive input and repeated snapshots do not replay presentation effects. **ARCH-02/03; V01, V09**.

## D. Server feature refactor

- [ ] **T15** Extract BingoRules with explicit random input, card/call generation, validation, and completion calculations. Preserve final-call opportunity and first-valid-winner semantics. **ARCH-04; V10**.
- [ ] **T16** Extract BingoQueue and BingoTransport; keep phase/participant/call/result ownership in BingoService. Preserve public minimum, rate limits, payload validation, disconnect handling, and countdown invalidation. **ARCH-04; V02, V10**.
- [ ] **T17** Move the world adapter into the Bingo feature and guard character placement across delayed spawn, phase change, and leave. Keep presentation suppression local to each client. **FIX-07, B11; V08**.
- [ ] **T18** Update entrypoints and all requires to the feature structure. Remove migrated legacy files and unused Hello only after reference checks. Start/Destroy must not duplicate remotes or listeners. **ARCH-01/03; V09**.

## E. Acceptance and documentation

- [ ] **T19** Execute meaningful pure-module checks for context derivation, card rules, queue lifecycle, and completion/skip state; run the available Luau type/build checks. Record tools actually available and results. **V01, V02, V05, V10**.
- [ ] **T20** Execute Studio validation V01–V12, including two-player/mixed-role cases, target viewports, late initialization, respawn, and three consecutive rounds. Capture before/after evidence for layout/camera defects.
- [ ] **T21** Review final visuals for legibility, distinct Bingo identity, readable captions, and useful hierarchy; address any remaining gameplay obstruction before calling the work complete.
- [ ] **T22** Update 001's implemented architecture and clarified queue/tutorial clauses, record validation evidence, and mark 002 implemented versus verified accurately.

Dependencies: T01–T03 establish contracts; T04 enables T05–T07; T08–T09 support T10–T14; T15 precedes T16–T18. T19–T22 close the work after integration. No implementation or verification checkbox is complete in this spec-authoring change.
