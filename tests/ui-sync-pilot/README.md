# Studio GUI round-trip pilot

`PilotGui` is a disabled `ScreenGui` in `StarterGui`. It is a sync test, not a
game feature. The existing game UI and shop remain code-driven during this
pilot. `default.project.json` is unchanged.

## Source of truth

`PilotGui.rbxmx` is the versioned visual template. The Studio instance is the
editing surface. Rojo reads the file and can replace properties inside the
mapped template; it does not export Studio edits back to Git automatically.

The Studio-only project maps only `StarterGui.PilotGui` and sets
`$ignoreUnknownInstances: true` on `StarterGui`, so unrelated siblings in
`StarterGui` are retained. The mapped `PilotGui` is still controlled by its
`.rbxmx` file.

## Edit and export

1. Disconnect Rojo in Studio before editing the mapped GUI. Select
   `StarterGui > PilotGui`; set `Enabled` to true temporarily to preview it.
2. Edit its layout, fonts, images, or colors in the Studio Properties panel.
3. Export the **ScreenGui itself** as `PilotGui.rbxmx` using **Save to File...**,
   then inspect `git diff`. Alternatively, the assistant can serialize the
   selected GUI with Studio's `SerializationService`, convert the temporary
   `.rbxm` to `.rbxmx` with Rojo, and inspect the diff. The temporary binary
   file is not committed.
4. Reconnect Rojo to the existing Studio project on port 34873. Confirm the
   edited appearance remains and that there is only one `PilotGui`.
5. Make a second visual edit and repeat to prove Studio remains the editor.

Do not change the `.rbxmx` while Studio has unexported edits to the same GUI.
Commit only a reviewed XML diff. Use Git to restore the previous template if
the sync result is wrong.

## Pilot acceptance

- `PilotGui` remains editable in Studio after a Studio -> `.rbxmx` -> Git ->
  Rojo -> Studio round trip.
- An unrelated `StarterGui` sibling is retained during synchronization.
- No duplicate `PilotGui` appears.
- The legacy GUI, purchase flow, currencies, and rewards are untouched.

Report observed results before requesting separate authorization to migrate
`RewardShopGui`.
