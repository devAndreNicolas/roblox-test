# Figma → Roblox UI import plan

## Goal

Bring every approved Bingo Noir UI component, visual state, and exportable asset into the Roblox project so the appearance can be edited in Studio. Keep game rules, live values, navigation, input handling, purchases, rewards, and network contracts in Luau.

This is an import and migration plan. It does not change game code or purchase behavior.

## Source file

Figma file: [BINGO NOIR UI kit](https://www.figma.com/design/fQwb2sLFJWrImkI0HcwBNf/FigBloxUI-%E2%80%94-Figma-to-Roblox--Comunidade-?node-id=0-1)

| Figma board | Node ID | Use |
| --- | --- | --- |
| Desktop shared HUD | `6:9554` | Desktop composition reference |
| Mobile shared HUD | `6:9616` | Mobile composition reference |
| Production & accessibility | `6:9432` | Contrast, safe area, sizing, and implementation rules |
| Feedback & audio artwork | `6:9189` | Audio icon artwork, notifications, loading and error states |
| Component specimens | `6:8857` | Button, panel, eligibility, tab, scroll, and focus references |
| Foundations | `6:8664` | Color, type, spacing, and visual tokens |
| Native component library | `6:10107` | Reusable masters and visual variants |

Known component IDs from the initial readable Figma context:

| Component | Node ID |
| --- | --- |
| Primary button | `6:10855` |
| Music on | `6:10868` |
| Effects off | `6:10883` |
| MC Bribe HUD panel | `6:11347` |
| MC Bribe button | `6:10126` |

The Figma MCP Starter plan reached its tool-call limit during inventory. Exact node IDs for the remaining individual masters and variants are pending. Do not guess these IDs; fill them from Figma when calls are available again. The family inventory and Roblox destinations below are already grounded in `INVENTORY.md` and the existing project tree.

## Import rules

- Keep clickable controls as native Roblox `GuiButton` instances. Keep labels, numbers, timers, balances, player names, prices, and card numbers as editable native text.
- Export raster or vector artwork only for visuals that cannot be represented well with native Roblox UI. Upload artwork to Roblox and use permanent asset IDs; never leave temporary Figma URLs in runtime properties.
- Preserve the existing instance names used by Luau as binding contracts until a screen is migrated and verified.
- Store screen templates in `assets/ui/BingoGuiDesign.rbxmx` and world templates in `assets/ui/WorldGuiTemplates.rbxmx`. Keep scripts and game logic outside design models.
- Keep the current fallback implementation until each migrated screen passes its integration checks.
- Use responsive native constraints and layout components where they fit. Use desktop/mobile variants only for meaningful layout changes.

## Work packages

### W0 — Complete the component manifest

For every row in `INVENTORY.md`, record the Figma master node, required variant nodes, exportable assets, Roblox destination path, and runtime state source. Mark reference-only boards as documentation, not runtime UI. Resolve all pending Figma node IDs before bulk import.

### W1 — Foundations and asset pipeline

| Figma family | Roblox destination | Notes |
| --- | --- | --- |
| Color/type/spacing foundations | `BingoGuiDesign > VisualStates`, `src/client/UI/Theme.luau` | Map tokens to Roblox properties and verify available/fallback fonts. |
| Brand and decorative marks | `BingoGuiDesign` and world templates | Keep wordmark artwork separate from dynamic game text. |
| Icons and card/offer artwork | Existing `ImageLabel` slots and `assets/bingo/` source catalog | Upload to Roblox, record permanent asset IDs, preserve transparent padding and aspect ratio. |

### W2 — Reusable components and states

Import the component masters and variants described by `BTN-01`–`BTN-16` and `EL-01`–`EL-16` in `INVENTORY.md`. Place shared templates under `BingoGuiDesign > Components` where current controllers clone them, or within the matching screen template where they are not shared.

This package includes button states, panels, navigation tabs, shop offer rows, card cells/themes, audio controls, call/race/history modules, rewards HUD, feedback/notification surfaces, and world UI references. For repeated content such as the 25 card cells, shop rows, and player rankings, Studio owns the reusable template and Luau clones and fills it with live data.

### W3 — Assemble existing game screens

| Screen/template | Current controller or owner | Figma source |
| --- | --- | --- |
| Shared HUD and Lobby | `BingoController` + `LobbyView` + `RewardShopController` | Desktop/mobile shared HUD and approved components |
| Intro | `BingoController` + `IntroView` | Caption, card, button, and surface components |
| Match | `BingoController` + `MatchView` + `BingoCard` | Call status, card, race, history, Bribe, and audio components |
| Results | `BingoController` + `ResultsView` | Outcome, feedback, card and action components |
| Shop/rewards | `RewardShopController` | Navigation, offers, previews, notices, balance and milestone components |
| World UI | `BingoWorld` + `ScenePresenter` | Signage, queue prompt, call display and MC dialogue components |

The Figma file currently provides a composed shared HUD plus reusable component/design-system boards. Assemble the rest of the existing screens from approved components; do not treat the reference/specification boards as in-game screens.

### W4 — Move presentation ownership to Studio

Current screen modules construct live GUI trees in Luau. `VisualDesign` applies authored properties to matching Studio instances, and `BingoCard` clones the `Components > CardCell` prefab. Migrate screen by screen so each controller clones the matching Studio template and binds existing state/render/input behavior to it. Luau may create repeated instances from Studio-authored prefabs and set dynamic properties; it should not define a component's visual identity.

After each screen is validated, retire only that screen's duplicate visual-construction path. Keep a fallback during that screen's migration.

### W5 — Validate and version each batch

For each work package:

1. Save the Studio-authored model as `.rbxmx` under `assets/ui/`.
2. Review the Git diff and commit the asset and manifest in a small commit.
3. Check desktop and mobile layouts, safe areas, clipping, text fit, and image loading in Studio.
4. Check that all controls still invoke their existing actions and expose focus/touch behavior.
5. Confirm live balances, prices, progress, card numbers, player rows, and match states still come from current Luau state.
6. Keep the fallback until the in-Studio check succeeds.

## Completion criteria

- Every interactive and non-button family in `INVENTORY.md` has an exact Figma node/variant mapping and a Roblox destination.
- Every runtime image uses an approved, permanent Roblox asset ID.
- All current screens and world UI use Studio-authored visual templates, including responsive rules and reusable variants.
- Luau controllers preserve current gameplay, shop, purchase, reward, referral, and navigation contracts while binding to the templates.
- No temporary Figma asset URL or design-only reference board is shipped as runtime content.
- Each migrated screen has been inspected in Studio before its fallback is removed.
