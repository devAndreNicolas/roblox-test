# 003 — Bingo Noir: Mistério no Ar

**Status:** Implemented in source; solo Studio verification recorded, full multiplayer/device and cohort validation pending. Style and cohort appeal remain hypotheses until playtested.
**Source:** [Owner playtest feedback](research/playtest-feedback.md) and [source audit](research/code-audit.md).
**Baseline:** [001 Bingo Match](../001-bingo-match/spec.md) · [002 UI improvements](../002-ui-improvements/spec.md).
**Delivery:** [Plan](plan.md) · [Tasks](tasks.md) · [Validation](validation.md).

## Problem and intended outcome

The owner reports that the current map feels empty, ugly, buggy, and annoying. The prototype has a floor, a simple stage and desk, a neon portal, and a block-built MC. The feedback does not identify exact runtime bug steps, so the visual deficiencies are actionable now while bug fixes must be based on reproduction.

Make children and teenagers feel that they entered a memorable televised Bingo event. The lobby is backstage; joining a match carries participants into a theatrical noir TV studio where an original MC hosts Bingo. Use a family-friendly, stylized mystery inspired by 1990s Batman animation and dark Art Deco: bold silhouettes, midnight blue, amber spotlights, ivory cards, and restrained burgundy accents. Preserve one fair, simple Bingo ruleset and make every gameplay action readable. The shared setting should support ages 5–17; playtests must check children ages 5–8, children ages 9–12, and teenagers ages 13–17 separately where feasible.

## Proposed visual direction

Use **Bingo Noir: Mistério no Ar** as the working identity. The reference is theatrical noir and dark Art Deco, with strong geometric framing and readable pools of light; it is not horror, supernatural fiction, crime roleplay, or a puzzle game. Keep the mystery in the staging, silhouettes, announcer voice, and reveals. Retain friendly proportions, bright ivory gameplay surfaces, clear signage, and expressive reactions so younger players can follow the action. The MC is an original master of ceremonies, not a detective or radio host.

| Token | Direction | Use |
|---|---|---|
| Midnight blue | `#101A33` | Studio background and framing |
| Deep blue | `#233B68` | Structural panels and secondary surfaces |
| Amber | `#F2B84B` | Spotlights, active call emphasis, route accents |
| Ivory | `#FFF4D8` | Bingo card, readable surfaces and text on dark panels |
| Burgundy | `#7D3048` | Small dramatic accent and result framing |
| Ink | `#172033` | Text on ivory surfaces |

UI typography uses Oswald for short titles and Gotham for functional text, numbers, instructions, and captions. UI keeps the contrast and responsive rules owned by 002. In-world geometry and lighting reinforce the same palette without reducing card or call readability.

**Art reference:** The 1990s *Batman: The Animated Series* used noir framing, angular silhouettes, and Art Deco influences; a retrospective describes the combination as “Dark Deco.” We use those broad staging principles as inspiration for our original family-friendly Bingo studio. ([Art of the Title retrospective](https://www.artofthetitle.com/title/batman-the-animated-series/); [Eric Radomski interview](https://dcanimated.com/2012/10/producer-eric-radomski-discusses-twenty-years-of-batman-the-animated-series/))

### Presentation rhythm and player feedback

The show builds anticipation through a short, repeatable sequence: the MC cues a call, the called number becomes the clear focal point, and the player's card confirms a mark only after the server accepts it. A Bingo result gets a larger stage and celebration beat that names the winner and shows why the result was earned. The call and card remain visible during every beat. Keep per-call and mark effects short so the repeated loop stays readable; reserve the strongest visual moment for Bingo. Predictable feedback should make action and outcome legible, while player excitement and return intent remain questions for playtests rather than assumed psychological effects.

## Scope

Improve the server-created 3D lobby and match space, player wayfinding, portal presentation, stage, MC presentation, ambient atmosphere, and generated-world lifecycle. Use Roblox-native geometry, materials, lighting, UI instances, and effects; do not require external models, textures, or custom meshes for the MVP. Use a temporary Creator Store instrumental broadcast-jazz track during prototyping; the founder plans to replace it with original music. Keep sound optional for comprehension and provide a way to mute it. Keep the existing portal queue rules intact.

Do not redesign the Bingo rules, add progression/economy/global matchmaking, build a new UI framework, or create custom paid assets. Screen UI and camera/caption behavior remain in 002. Any new runtime defect needs a reproducible case before a fix is accepted.

## Requirements

### World layout and atmosphere

- **WORLD-01 Identity:** The experience reads as a purposeful televised Bingo event, not a generic flat test map. The backstage, queue portal, studio, and match area share a coherent style.
- **WORLD-02 Wayfinding:** From the lobby spawn, a new player can see and reach the Bingo portal. The portal looks interactive; the stage and play area are visually distinct from the waiting area.
- **WORLD-03 Play space:** Keep clear walking paths between spawn, portal, and match area. The host and called number remain visible from each participant position. Up to eight avatars can occupy match positions without forced overlap, blocking the host, or standing outside the play area.
- **WORLD-04 Set dressing:** Add a small number of purposeful details (for example, bingo cards/balls, seating, event signage, trim, and warm fixtures) that support the event fantasy. Decoration must not obscure prompts, captions, player movement, or the host.
- **WORLD-05 Lighting and motion:** Use lighting and a few subtle ambient cues to give the room depth and energy. Keep motion calm and localized; essential information never depends on a particle, color, flicker, or sound being noticed.
- **WORLD-06 MC presentation:** Give the MC an intentional, readable visual identity. The MC visibly responds to number calls and the match outcome, with a restrained idle presence between events. Captions continue to communicate all essential information for muted players and players who cannot read animation cues.
- **WORLD-07 Performance:** The scene uses bounded, static geometry and restrained effects. It must not add per-frame server work for decoration or create unnecessary physics interactions.

### Runtime reliability

- **WORLD-08 Spawn and seating:** Spawn the player on a stable lobby surface; place participants at the intended match position after character availability. Respawn and late character loading cannot leave a player below the floor, outside the lobby, or at a stale match seat.
- **WORLD-09 Generated-world ownership:** Create or reuse only the Bingo-owned world root. Repeated service initialization must not duplicate the scene. A stale version of the generated map must be refreshed predictably, and unrelated Workspace objects must not be removed.
- **WORLD-10 Interaction safety:** Portal prompt activation remains reachable and understandable on keyboard, gamepad, and touch. Environment geometry cannot obstruct the prompt or make the portal's server-side proximity validation disagree with the visible activation range.
- **WORLD-11 Failure clarity:** Missing optional presentation elements (MC model, decor, lighting or animation) cannot stop queueing or a match; use the available captions/stage as a fallback. If the queue portal itself is unavailable, fail clearly without crashing match services.
- **WORLD-12 Bug evidence:** Fixes for reported “buggy/annoying” behavior must link to a reproduced trigger and expected/actual outcome in the audit or validation record. Do not mark an unspecified issue as fixed.
- **WORLD-13 Studio identity:** The match takes place on a theatrical noir TV set, while players waiting for a match remain in separate backstage space. Waiting players do not see or control a spectator view of the active match in this MVP.
- **WORLD-14 Cohesive art direction:** The set uses stylized dark Art Deco forms, midnight blue and amber as dominant colors, ivory gameplay surfaces, and restrained burgundy accents. It feels mysterious and theatrical while remaining family friendly and non-horror.
- **WORLD-15 Original host:** An original, clearly readable MC hosts the show and reacts to calls and results. Host presentation never replaces the called number, card feedback, or captions.
- **WORLD-16 Audio:** Temporary instrumental broadcast jazz may play in the studio. Sound is secondary to visual instructions, can be muted, and must not gate play or rewards. The temporary track is replaceable by original founder-created music.
- **WORLD-17 Player stations:** An active participant is seated at one of eight stations facing the MC. The server assigns and owns station placement, and restores the participant to their station if they become unseated while still active. The client sinks normal jump input for comfort. Participants remain seated until the match ends; there is no voluntary in-match exit action in this MVP. A player who disconnects is removed through the existing participant cleanup.
- **WORLD-18 Effects:** Each call and accepted mark receives brief, restrained feedback. A Bingo win receives a clearly stronger celebration. Effects clarify cause and effect, remain short, and never hide gameplay information.
- **WORLD-19 Cause and effect:** The called number is visible before a mark can be confirmed; a card mark is shown as accepted only after server confirmation; the result presentation identifies the winner and winning outcome. World reactions complement the UI behavior owned by 002.
- **AUD-01 Shared appeal:** The same world identity and fair match flow serve children under 13 and teenagers ages 13–17. The setting gives each cohort a clear route into play and a reason to enjoy the event; age-specific appeal is validated through observation rather than assumed from the art direction.
- **AUD-02 Independent participation:** Essential world cues remain understandable without chat, sound, color distinction, or animation timing. Coordinate call, card, and result readability with feature 002; the world must not introduce a competing instruction channel.

## Acceptance scenarios

### Player recognizes and reaches Bingo

**Given** a new player spawns in the lobby  
**When** they look around and move toward Bingo without developer help  
**Then** the portal is visible and recognizable as the way to join  
**And** the route does not cross blocked or visually confusing space.

### Match space feels hosted and remains playable

**Given** a match starts with eight players  
**When** they arrive at their match positions  
**Then** the MC and stage remain visible from every position  
**And** avatars can move without crowding, falling, or blocking the called number presentation.

### Noir show atmosphere supports rather than distracts

**Given** a player is waiting or playing  
**When** ambient lighting, motion, or sound cues run  
**Then** they reinforce a theatrical, family-friendly noir TV Bingo show  
**And** they do not hide gameplay information, obstruct movement, or make the environment uncomfortable.

### One noir Bingo show welcomes children and teens

**Given** a child or teenager enters the experience without developer help  
**When** they explore the lobby and join a match  
**Then** the world makes the route, host, and shared Bingo event easy to understand  
**And** participation does not depend on chat or hearing audio  
**And** playtest observations record whether the visual tone feels enjoyable to that age cohort.

### Backstage and studio have clear roles

**Given** a player is waiting or has joined the current match  
**When** the match is active  
**Then** waiting players remain in backstage and participants are seated in the studio facing the MC  
**And** the player can identify whether they are waiting or participating without a spectator camera.

### Seated match remains understandable

**Given** a participant has been placed at a station  
**When** calls and marks occur  
**Then** they remain at their assigned seat until the match ends  
**And** each call and accepted mark has brief visible feedback, with a stronger but readable winner celebration.
**And** the card shows a confirmed mark only after server acceptance.

### Audio is optional

**Given** a participant has muted audio or cannot hear the temporary music  
**When** the MC calls numbers and a match ends  
**Then** the participant can follow every essential action from visual UI and captions.

### World initialization is repeatable

**Given** the Bingo service is initialized more than once or a stale generated world exists  
**When** the world adapter starts  
**Then** exactly one current Bingo scene exists  
**And** unrelated Workspace content remains untouched.

### A bug report becomes reproducible

**Given** a player reports a scenario bug  
**When** the team records and reproduces it  
**Then** the report includes device, location, action, expected behavior, actual behavior, and relevant output  
**And** the fix is checked against that trigger and a gameplay regression case.

## Product assumptions to validate

- Does the stylized noir studio feel intriguing to both younger children and teens without feeling scary or too childish?
- Does backstage separation create a clear wait state, or does it make the wait feel empty? The MVP has no spectator view; test whether clear queue status is enough.
- Does remaining seated through a match feel comfortable and understandable? Current worst-case configured full-card duration is about 6m31s including intro and results; the player can leave Roblox, which triggers disconnect cleanup.
- Is the brief call/mark feedback noticeable without becoming distracting, and does the stronger Bingo celebration feel earned?
- Does the selected temporary Creator Store track, [Smooth Ambient Jazz Piano & Gentle Trumpet](https://create.roblox.com/store/asset/101443293051695), fit the show across age cohorts? It loaded and played in a solo Studio session; replace it with the founder's original track when ready.
- Which specific runtime issue did “buggy and annoying” refer to? Add steps/video/device details to the research feedback when available.

## Exit criteria

Complete the world design and implementation, then record Studio evidence for backstage navigation, the studio reveal, eight-player seating, input lock, portal interaction, repeated initialization, respawn/placement, audio mute, and participant versus waiting-player visibility. A code review or one desktop screenshot alone does not establish an immersive or reliable scenario.
