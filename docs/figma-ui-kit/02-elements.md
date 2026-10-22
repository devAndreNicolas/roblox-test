# Figma prompt 02 — every remaining UI element, one family at a time

Paste `SKILL.md` first. Complete or approve the button library before starting these families. The prompt below covers non-button elements, **without assembling screens**.

```text
Use the Bingo Noir component design skill. Build the remaining UI component library one family at a time. Start with EL-01 only. Stop after each family and wait for “next element” or my corrections. Reuse the approved button masters instead of redrawing buttons. Do not compose full lobby, match or shop screens yet.

For every element family deliver an editable Figma master, the listed state variants, desktop/mobile sizing rules, real English sample content, a Roblox Studio instance mapping, and a list of isolated export files. Keep dynamic text, numbers, timers, prices, balances and player names native/editable. Export art only when native Roblox frames, text, strokes, gradients and constraints cannot express it well.

EL-01 Typography and brand primitives
Create the Bingo Noir wordmark treatment, live indicator, display headings, body copy, utility labels, player names, timers and large Bingo numerals as a type system. Show short and long English copy, mobile minimum size and fallback fonts available in Roblox. These primitives serve LobbyStatus, ShopPanel, MatchView, ResultsView and world signage. Do not create a screen.

EL-02 Surfaces and decorative primitives
Create reusable dark/light panel surfaces, paper inset, ticket edge, gold rule, outline, muted backdrop, scroll edge and attention surface. Map them to LobbyStatus, Caption, Outcome, Call, BingoRace, ShopPanel, ShopShade, catalog entries and Feedback. Variants: normal, selected, success, warning/error, disabled. Keep ornaments away from live numbers and prices.

EL-03 Lobby status module
Design the standalone LobbyStatus card with brand, LIVE indicator, title, short instruction, queue count and approved BTN-01 retry action. Variants: connecting, not queued, queued, match countdown, current match full / next queue, connection delayed. A child must understand where to go: the amber portal. Do not design the 3D room or full HUD.

EL-04 Show caption and outcome module
Design the intro MC caption with speaker label, instruction, Skip scene and Starting soon states. Design the reusable Outcome result card with eyebrow, title, detail and Skip scene: own win, another player win, draw. Add restrained reveal-motion notes. Keep both modules separate; no full screen.

EL-05 Native Bingo card structure
Design one editable 5×5 BingoCard component: B-I-N-G-O header, 25 native cells using approved BTN-14, free center star, outer border, ThemeArtwork layer and layout safe area. Variants: preview, active, mark pending, mark confirmed, art loading/fallback, near win. Demonstrate compact mobile and large desktop, with all numbers readable and no decorative art covering cells.

EL-06 Card theme art collection
Design six separate decorative card-frame components and individual transparent exports: classic, dossier_blue (Blue Dossier), stage_star (Stage Star), club_seal (Club Seal), on_air (On Air), velvet_gala (Gala Velvet). Keep the large center and a safe inset transparent for the native grid and header. No words, numbers, marks, prices or background. Show the same theme at shop-preview and match sizes, but export each theme only once. Use the existing five PNGs as subject references, not as mandatory final artwork.

EL-07 Current call module
Design CallBall and the surrounding Call panel as separate reusable components: MC/unknown state, called letter and number, next-call timer, progress track, new-number pulse and paused-for-bribe state. The letter/number/timer are native text. At mobile size, the number must dominate the module.

EL-08 Bingo Race module
Design collapsed summary and expanded AllPlayers ranking list for up to eight players. Include leader, second place, self, tied ranks, one-to-Bingo and near-win celebration. Reuse BTN-11 RaceExpand. Player names can be long. Show compact mobile and desktop modules, not a match screen.

EL-09 Recent calls and reminder module
Design HistorySurface with the recent four calls and one concise gameplay reminder. Variants: no calls, one call, four calls, narrow mobile, short-screen hidden state. The calls are native dynamic text; the gold rule is decoration.

EL-10 MC Bribe announcement module
Design the standalone SubornAnnouncement overlay and MC caption treatment. Show who triggered it, the next public number, that everyone can mark it, and the pause before play resumes. Variants: entering, announced, leaving. Never suggest automatic marking or guaranteed victory.

EL-11 Rewards HUD and seven-step milestone track
Design the compact RewardsHud with Tickets balance, next milestone and approved BTN-02 OpenShop. Separately design the ShopPanel Rail with balance, current/next milestone, seven progress dots, explanatory note and Studio/demo note. Variants: loading, ready to earn today, earned today, steps 1–7, unavailable. The track does not reset when a day is missed. Do not assemble the shop.

EL-12 Shop navigation primitives
Design the standalone shop Header, four-tab Categories rail using approved BTN-04, SectionTitle/SectionCopy, Catalog scroll container, CommerceNote and Notice message surface. Variants: each selected category, product unavailable, info/success/error notice, desktop/mobile width. Do not place offer rows inside the final shop layout.

EL-13 Offer card library
Design independent offer-card components, not a shop page: Ticket pack Handful +120, Bundle +350, Case +800; EARN ON STAGE explanation; theme_showcase with a real BingoCard; individual theme row for Blue Dossier, Stage Star, Club Seal, On Air, Gala Velvet; MC Bribe item with stock and limits; Club Seal invite reward card. Reuse approved BuyRobux, BuyTickets, Equip, Inspect and Invite buttons. Show ownership, affordability, unavailable price, premium-only and equipped variants. Provide isolated icon exports for three packs, five themes and Bribe.

EL-14 Feedback and celebration primitives
Design the short Feedback message and shop Notice with info/success/error variants. Also design cell stamp, glint, mark confirmation, near-win emphasis and win celebration as restrained isolated components or animation notes. Each state must remain understandable without sound or color alone. No large modal for routine feedback.

EL-15 Audio controls
Design MusicToggle and EffectsToggle as a paired component family using approved BTN-12 and BTN-13. Produce separate transparent music-on, music-off, effects-on and effects-off icons. Show compact mobile and desktop sizes. Keep the underlying native TextButton for interaction and gamepad focus.

EL-16 World-space UI set
Design each existing world UI surface separately: PortalSign, HowToPlayGui, WinPosterGui, BackstageTitleGui, CallDisplay, MCDialogue and QueuePrompt. Signs need flat front-view art and room for native dynamic text. CallDisplay must handle B-I-N-G-O letter plus number; MCDialogue must fit short and long lines; QueuePrompt is a Roblox engine control. Validate legibility at a distance against a dark TV-studio background. Do not create 3D geometry or NPC art.

Begin with EL-01 only and wait for review. When I say “next element”, advance in the listed order.
```

After all families are approved, a separate prompt can assemble each game screen using only these approved masters. Keep screen composition out of this component phase.
