# 003 — Scenario Delivery Tasks

**Status:** Source implementation integrated; solo Studio checks recorded in validation.md. Eight-client, device, full-result, and cohort checks remain open.
**Links:** [Spec](spec.md) · [Plan](plan.md) · [Audit](research/code-audit.md) · [Validation](validation.md).
Check a task only after its stated outcome is demonstrated. Do not mark visual or runtime behavior complete from source inspection alone.

## A. Direction and baseline

- [x] **T01** Agree the provisional Bingo Noir / theatrical dark Art Deco direction, family-friendly tone, palette, original MC, temporary instrumental jazz, and native Roblox asset approach. Validate appeal with child and teen cohorts before treating it as proven. **WORLD-01/05/13–16; AUD-01**.
- [ ] **T02** Record baseline screenshots from backstage spawn, portal approach, studio reveal, and all eight participant positions. Note Studio lighting/device settings and current navigation or interaction failures. **WORLD-02/03/10/13; V01/V02**.
- [ ] **T03** For each specific “buggy/annoying” symptom available, record reproduction steps, device, expected/actual outcome, and relevant output. Keep un-reproduced symptoms open. **WORLD-12; V06**.

## B. Environment and navigation

- [ ] **T04** Build distinct backstage and noir TV studio spaces, with a clear portal, readable queue state, and a match-start transition into the studio. Waiting players have no spectator view. **WORLD-01/02/13; V01/V02**.
- [ ] **T05** Add restrained Art Deco geometry, midnight blue/amber lighting, ivory play surfaces, and burgundy accents; preserve sightlines, readable signs, and walkable paths. **WORLD-04/05/07/14; V01/V02/V04**.
- [ ] **T06** Stage and seat up to eight participants facing the host/call area. Sink normal jump input, re-seat active participants if they become unseated, restore controls at all exits, and verify respawn/membership behavior. **WORLD-03/08/17; V02/V03**.
- [ ] **T07** Rework portal presentation and interaction placement so the prompt is visible, approachable, and consistent with server proximity checks on keyboard, gamepad, and touch. **WORLD-02/10; V01/V03**.

## C. Host and atmosphere

- [ ] **T08** Replace or refine the block-built MC as an original noir show host; provide idle and call/result reactions with caption fallback. **WORLD-06/15; V04/V05**.
- [ ] **T09** Add short call/mark feedback, a stronger Bingo celebration, and optional temporary instrumental jazz with mute control. Ensure call-to-card cause and effect is clear, marks show confirmation only after server acceptance, cues are restrained, and no comprehension depends on sound. **WORLD-05/07/16/18/19; V04**.

## D. Runtime reliability and acceptance

- [ ] **T10** Add ownership/version-aware world initialization and cleanup. Verify stale Bingo-owned geometry updates without duplicating the scene or deleting unrelated Workspace content. **WORLD-09; V05**.
- [ ] **T11** Verify initial spawn, delayed character load, respawn, participant placement, and return to lobby against current authoritative membership. **WORLD-08; V03**.
- [ ] **T12** Verify missing optional decor/animation does not prevent portal use or a Bingo match. **WORLD-11; V05**.
- [ ] **T13** Complete the Studio visual/runtime matrix, including input lock/restore, seat lifecycle, temporary audio/mute, and backstage separation; record outcomes, screenshots, device/viewport settings, and console output. **V01–V06**.
- [ ] **T14** Run unassisted playtests with children and teenagers as separate cohorts, splitting child observations into ages 5–8 and 9–12 where feasible. Ask where they would queue, whether the noir tone feels fun or scary, what felt blocked/annoying, whether calls and marks make sense, and whether they would play another round. Store observations separately from interpretation. **V06/V07; AUD-01/02**.

The source now contains backstage and studio geometry, eight Seat stations, host call/result reactions, visual call/mark feedback, local music/mute, and participant jump suppression. Checkboxes stay open where the full stated outcome still needs Studio or player evidence.
