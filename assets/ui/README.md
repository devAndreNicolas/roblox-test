# Studio-owned game UI

The current look of the game is versioned in two Studio-editable models:

- `BingoGuiDesign.rbxmx` -> `StarterGui > BingoGuiDesign` (screen UI: lobby, intro, match, results, shop, rewards, cartelas, audio controls and feedback).
- `WorldGuiTemplates.rbxmx` -> `ReplicatedStorage > WorldGuiTemplates` (world signs, MC dialogue, number display and queue prompt).
- `asset-manifest.json` -> source PNGs and permanent Roblox image IDs currently referenced by UI. Figma node attribution is intentionally blank until those exact nodes are read and confirmed.

`BingoGuiDesign` is disabled so it does not appear twice during play. The existing Luau controllers still own text, numbers, visibility, navigation, responsive fallback layout, interaction, purchases and rewards. `VisualDesign` applies Studio-authored appearance to the live GUI. If the design model is missing, the old GUI still works. The world GUI templates are cloned by `BingoWorld`; its old construction path is the fallback.

The shared `UI.StudioTemplate` module resolves and clones Studio-authored instances from `BingoGuiDesign`; it also supplies design tokens and card-prefab lookups. Runtime-cloned screens/components now include `Content > LobbyView`, `Content > IntroView`, `Content > ResultsView`, `RewardsShop > RewardsHud`, the root `MusicToggle` and `EffectsToggle`, `RewardsShop > UseSuborn`, and the complete `RewardsShop > ShopPanel` with its shade, tabs, catalog rows, offer art, and notice surface. Controllers bind live text, state, actions and prices to those named instances. The shop's native offer images and layout are stored in the template; Luau still owns purchase prompts, balances, eligibility, tab state and dynamic values. Intro and the shop showcase keep their dynamic Bingo card renderer and replace the template card placeholder at runtime. Existing code-built controls remain the fallback if templates are absent or incomplete. MatchView and world interfaces are not migrated yet.

The shared audio controls use Studio-authored icon, label and state children. Luau updates the current icon/state and rearranges the controls for compact portrait matches; the template remains the place to edit their visual hierarchy, fonts, colors and decoration.

## Edit a screen interface

1. In Explorer, open `StarterGui > BingoGuiDesign`. Temporarily set `Enabled = true` to preview in Studio edit mode. Hide views you are not editing with their `Visible` property. Restore `Enabled = false` before export.
2. Edit the actual instances in Studio: positions, sizes, fonts, text sizes, backgrounds, images, corners, strokes, gradients, padding, constraints and decoration. Add a `UISizeConstraint` or `UIAspectRatioConstraint` when you need it. Use scale-based `UDim2` values for responsive sizing. Check both phone and desktop in Studio's Device Emulator.
3. For card art, change the `ThemeArtwork.Image` under `RewardsShop > ShopPanel > Catalog > <theme id> > Preview`. The same image is used on the card in the match. The `Preview` and `Paper` background colors supply the theme's accent and paper. Edit `Content > MatchView > BingoCard` for the classic card.
4. For colors that change with gameplay state (marked cells, selected tabs, disabled purchases, notices), edit `VisualStates` color values. These values feed the Luau state rendering. Dynamic text and numbers remain controlled by Luau.
   For the shape, font, stroke, stamp and effects shared by all 25 card cells, edit `Components > CardCell`. The card controller clones this one prefab for every cell in the lobby preview, shop and match. The visible cells in the disabled design are layout previews; edit the prefab for a shared change.
5. To move or resize an element controlled by an existing responsive `Layout` function, change its `Position` or `Size` in Studio. A change from the saved `BaselinePosition` or `BaselineSize` makes the Studio value take precedence. Leave the baseline attributes alone. Unchanged elements keep their current mobile layout. A changed `TextSize` similarly uses `BaselineTextSize`.

The hierarchy inside `BingoGuiDesign` mirrors the live `BingoGui`. Names and classes of existing controls are binding keys. Do not rename or delete them until their Luau controller is migrated too. New decorative GUI objects and native layout components can be added inside existing containers. This is a migration layer: the old controllers still construct their legacy tree so purchases, rewards and interactions retain their existing references.

## Edit a world interface

Open `ReplicatedStorage > WorldGuiTemplates`. Each `BillboardGui`, `SurfaceGui` and `ProximityPrompt` is a prefab. Edit its appearance and prompt text in Studio. The server clones each prefab into the generated world. Keep each template's name and the `Text` label inside signs because the server fills that label with live information. Set `Adornee` only on the live clone; the server assigns it.

## Save Studio edits into Git

Rojo reads `.rbxmx` files but does **not** save Studio edits back to disk. To prevent a Rojo sync from replacing an unsaved edit:

1. Disconnect the Rojo plugin before editing a mapped design or prefab.
2. Select the **root** `BingoGuiDesign` ScreenGui or `WorldGuiTemplates` Folder in Explorer. Use **Save to File...** and save as `.rbxmx`, replacing the corresponding file in this folder. Preserve the root name. Export both roots separately if you edited both.
3. Restore `BingoGuiDesign.Enabled = false` before exporting. Inspect the Git diff and commit the `.rbxmx` file. Avoid committing other Studio-only changes accidentally.
4. Reconnect Rojo using `studio.project.json`. The server port can vary; use the one printed by `rojo serve`. Check that the edited template still exists once, your changes remain, and the game still opens. If a source diff is wrong, use Git to restore the previous `.rbxmx` file and sync again.

The `.rbxm` conversion project files in this folder are for assistant-driven binary exports from `SerializationService`. The temporary `.rbxm` and base64 files are removed after conversion. You can export `.rbxmx` directly from Studio; no conversion is needed for manual edits. `tests/ui-sync-pilot/README.md` records the round-trip validation and the earlier overwrite experiment.

## Safe migration boundary

The shop, reward, currency and purchase contracts stay in Luau. Do not put logic or scripts inside the design models. They are visual sources. The old UI constructors and world GUI construction remain as fallbacks while this Studio-managed presentation layer is in use.
