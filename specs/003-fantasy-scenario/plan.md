# 003 — Bingo Noir Scenario Implementation Plan

**Status:** Implemented in source; solo Studio verification recorded, wider validation pending.
**Contract:** [Specification](spec.md) · [Tasks](tasks.md) · [Validation](validation.md).

## 1. Delivery strategy

Keep Bingo's existing boundaries. `BingoWorld` remains the server-owned adapter for world construction, spawn/seat destinations, portal lookup, and world status. Keep queue and match authority in the match service. Client-side camera/caption suppression and screen UI stay with feature 002. The active match is staged in a separate TV studio; waiting players remain backstage without spectator controls.

Deliver in small visual slices: first establish backstage, portal, studio silhouette, and the reveal/transition; then seat stations and the MC; then add lighting, effects, and optional temporary music. Revisit geometry at the full eight-player layout before adding decorative polish. Validate in Studio after each slice so visual improvements do not obscure movement or interaction. Keep one shared visual identity and check its tone with child and teen cohorts; avoid separate age-based rooms or rulesets.

## 2. Environment composition

Recommended layout:

```text
[Backstage lobby + spawn] — [Portal / queue]
                                  │ match start
                                  ▼
[TV studio: 8 seats facing MC + call display]
```

- Keep the lobby as backstage: legible queue state, a purposeful waiting environment, a visible portal, and no view/control of the active match. The studio is a separate presentation space reached by participants when the match starts.
- Keep backstage and studio as separated spaces in the existing server/place for the MVP. Use enclosure, entrances, and sightline control so waiting players cannot see the active match; do not add a new Roblox place, server teleport, or spectator camera for this scene pass.
- Shape the studio as stylized noir TV / dark Art Deco with geometric silhouettes, strong stage framing, midnight blue structure, amber spotlights, ivory play surfaces, and small burgundy accents. Keep lighting readable and family friendly; no horror imagery, threatening darkness, or strobing.
- Arrange eight participant stations facing the original MC and shared call display. Ensure the player cap of eight matches the usable stations and all stations preserve a clear view of gameplay.
- Keep a simple aisle from backstage spawn to portal. Distinguish waiting from participation using location, signage, and concise UI cues from 002.
- Keep the portal geometry and `IsNearQueuePortal` validation aligned; derive or share activation dimensions instead of letting decoration silently reduce usable range.
- The current MC is an original static Roblox-native show host with an event-driven arm gesture, dialogue, and stage spotlight. A full rig remains a later polish option. Keep text/call state owned by the server and animation as presentation only.

## 3. Runtime and asset approach

- Start with Roblox-native geometry, materials, SurfaceGui/BillboardGui already in use, and restrained built-in lighting/effects. Do not require external models, textures, meshes, or custom asset IDs for world construction.
- Use temporary Creator Store audio `rbxassetid://101443293051695` (*Smooth Ambient Jazz Piano & Gentle Trumpet*), which loaded and played in solo Studio. The local music control mutes it; all instructions remain visual. The founder's original music replaces this ID when available.
- Use short event-driven call and accepted-mark cues, plus a stronger Bingo celebration. Maintain contrast and keep the call/card visible throughout; no flashing or long camera lock.
- Seat participants at server-assigned stations. A local `ContextActionService` binding sinks normal jump input for the participant; the server remains authoritative about membership and placement, and re-seats a still-active participant when their Humanoid becomes unseated. On respawn, re-seat only if current participant membership remains valid. Release the input binding and seat enforcement at result completion, participant removal, disconnect, or feature teardown. There is no in-match leave control; disconnect remains possible. Do not depend on client input suppression as the security boundary.
- Group and name parts by purpose under a single Bingo-owned Workspace root. Set collision/query/touch behavior intentionally; decorative parts should not interfere with player movement or prompts.
- Add an explicit generated-world version/ownership marker. On startup, reuse a valid current scene; rebuild only the owned Bingo root when its version is stale. Do not clear the whole Workspace or silently adopt an unrelated folder.
- Track and clean up only resources created by the world adapter. Repeated `Start`/`Destroy` cycles cannot duplicate the scene or leave stale placement work.
- Treat missing decor or animation as a presentation fallback, not a match failure. Preserve plain captions for calls and results.
- Keep effects event-driven or static. Avoid a server Heartbeat loop for lights, signs, or decorative animation.

## 4. Interfaces to preserve

The world adapter provides world startup/destruction, backstage spawn, studio station destinations, portal proximity validation, queue sign updates, MC dialogue/call/outcome presentation, and delayed player placement. Add a typed destination/presentation interface only if required by the current service; preserve one owner for match membership and one owner for world construction. The client owns jump-input suppression while the server validates and re-applies participant placement; neither client UI nor seat state decides winners.

The existing match service remains the source of queue, match, participant, call, and result state. It sends state/text to the world adapter; the adapter does not decide who won or who can enter a match.

## 5. Dependencies and risks

- Coordinate portal sign and MC caption behavior with 002's world-UI suppression requirements to avoid duplicate or hidden status for the wrong local player.
- Coordinate world guidance with 002 so a newcomer can follow the call and next action through clear visual and text cues; the world should not require chat, sound, or color recognition.
- Appeal for children ages 5–8, children ages 9–12, and teens ages 13–17 is unvalidated. The noir style is a product choice to test, not a researched preference. Observe whether it reads as intriguing, clear, and family friendly across cohorts.
- A full 75-call match can hold a participant seated for about 6m31s at current configured timings. Monitor comfort and early exits in playtests; revise match pacing or seating if evidence shows friction.
- If a proper animated rig or suitable animation assets are unavailable, deliver a clean, static host silhouette with event-based presentation fallback rather than blocking the environment pass.
- Lighting and color can look different with Roblox rendering/device settings; review the actual Studio viewport and more than one client device profile. Music asset availability and moderation status can change; treat it as a replaceable prototype dependency.
- Exact “buggy/annoying” symptoms remain unknown. Keep those issues open until reproduced and recorded.
