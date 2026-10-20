# Scenario Source Audit

**Purpose:** Separate what the playtest feedback says from what source inspection confirms.
**Inputs:** [Owner feedback](playtest-feedback.md); `src/server/Features/Bingo/BingoWorld.luau`; [002 UI proposal](../../002-ui-improvements/spec.md).

## Player-reported evidence

- The scenario feels empty.
- The scenario looks ugly.
- The experience feels buggy and annoying, but the feedback gives no trigger, steps, device, or expected/actual result.
- The intended improvement is a more immersive Bingo experience in the existing scenario.

These are owner observations, not a documented multi-player research result. The reported bugs need reproduction before being described as confirmed defects.

## Source-confirmed observations

| Area | Evidence in current source | Product effect / follow-up |
|---|---|---|
| Environment | `BingoWorld.buildWorld` creates a large flat lobby floor, a separate flat match platform, a basic stage, and a desk. It adds no surrounding walls, ceiling, seating, decorative landmarks, or environmental lighting. | Supports the “empty” feedback. Add a recognizable room silhouette, useful set dressing, and a readable visual path from spawn to queue portal and match stage. |
| MC | `createMC` constructs the host from primitive Parts and adds a Humanoid, but no rig animation or expression behavior is configured. | Supports the static/unfinished presentation concern. Give the host an intentional visual identity and lightweight idle/call/result reactions; keep required gameplay information in captions. |
| Portal | The portal is a neon frame and force-field part on the far side of the lobby, with a BillboardGui and ProximityPrompt. | The interaction exists, but the surrounding scene provides little visual guidance or feedback. Test approachability and recognition from the spawn point and mobile distance. |
| Match staging | Ten positions are defined; a match is limited to eight by the current config. Positions look toward the MC, but are hard-coded without seating or table geometry. | Seat players around a shared Bingo table/stage, preserve clear sightlines, and check that 8 avatars do not overlap or block access. |
| Iteration behavior | `buildWorld` reuses any `Workspace.BingoWorld` folder that contains the expected portal and MC. It does not compare a generated-world version or refresh the other geometry. | A stale or hand-edited runtime folder can make a new source-built environment appear unchanged. Track ownership/version and make rebuild behavior explicit without deleting unrelated Workspace content. |
| Annoying/buggy behavior | The feedback has no steps to reproduce; source inspection alone cannot identify which runtime issue the player encountered. | Capture device, location, action, expected result, actual result, and console output when reproducing; do not invent fixes for an unspecified symptom. |

## Boundary with feature 002

Feature 002 owns screen UI, camera-scene lifecycle, local suppression of world billboards/prompts, and the general UI refactor. This feature owns the 3D room, its spatial wayfinding, decorative/environment effects, MC model/animation behavior, and world construction lifecycle. Integrate against 002's world-caption rules; do not create competing screen UI here.
