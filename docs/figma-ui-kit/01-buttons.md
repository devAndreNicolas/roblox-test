# Figma prompt 01 — every existing button, as reusable components

Paste `SKILL.md` first. Then paste the prompt below. It asks Figma to work through all button IDs **one at a time**; the first output is only `BTN-01`. The complete list is here so the system does not forget a control later.

```text
Use the Bingo Noir component design skill and the button inventory below. We are building a Figma component library, not composing any screens. Create exactly one button family at a time, starting with BTN-01. After each family, stop for my visual corrections. When I say “next button”, advance to the next ID without changing approved families.

For each button family create:
- An editable master component and a Figma variant grid for every listed state.
- Real English example labels with both short and longest realistic text.
- Desktop and mobile size guidance; touch target, keyboard/gamepad focus, contrast and text-fit notes.
- Native Roblox implementation guidance: keep the clickable TextButton/GuiButton and its dynamic text as native UI. Export only custom icons, ornamental backplates or other isolated art as transparent PNGs.
- A handoff table: component ID, Roblox instance name, state property, asset filename if any, and the exact visual elements I should edit in Studio.
- No full screens, modal assembly, background scene, fictional buttons or baked-in prices.

BUTTON INVENTORY AND STATES

BTN-01 Action: shared “Try again” in LobbyStatus and “Skip scene” in Intro Caption / Results Outcome. Normal, hover, pressed, gamepad focus, disabled; labels of different lengths. The retry version appears only after connection delay.

BTN-02 OpenShop: “OPEN SHOP” in RewardsHud. Normal, hover, pressed, focus. Must fit beside Tickets balance and next milestone in a compact HUD.

BTN-03 CloseShop: “CLOSE ×” in shop Header. Normal, hover, pressed, focus, compact mobile. Do not rely only on the × symbol.

BTN-04 ShopTab: four labels “TICKETS”, “CARDS”, “POWER UPS”, “INVITES”. Selected, unselected, hover, pressed, focus, narrow mobile. This is a tab bar component, but design each tab without assembling the shop.

BTN-05 BuyRobux: used by the three Ticket packs, five purchasable card theme rows, selected card showcase and MC Bribe. Available, product unavailable/unconfigured, processing, success, already owned context. Use placeholder dynamic price examples “49 ROBUX” and “149 ROBUX”; do not bake price into artwork. The platform supplies the real price.

BTN-06 BuyTickets: Luau name BuyFichas, player-facing copy uses TICKETS. Used for three earnable card themes, selected eligible card showcase and MC Bribe. Affordable, insufficient Tickets, processing, success, owned/hidden context. Example labels “300 TICKETS” and “650 TICKETS”. No Ticket button for Robux-exclusive themes.

BTN-07 Equip: on owned card-theme rows and selected showcase. Available “EQUIP”, active “EQUIPPED” or “EQUIPPED FOR MATCH”, hover, pressed, focus. An unowned theme shows purchase options instead.

BTN-08 Inspect: “SEE IN GAME ›” on each purchasable card-theme row. Normal, hover, pressed, focus. It selects the large in-game card preview.

BTN-09 Invite: “INVITE A FRIEND”. Normal, hover, pressed, focus, platform unavailable/error feedback. The reward is only granted after the invited friend completes an eligible match.

BTN-10 UseBribe: match HUD “BRIBE THE MC” / “BRIBE (stock) · used/2”. Available, zero stock, already used by this player, match cap reached, announcement running, pressed, focus. This action changes the next public call for everyone; it never auto-marks a square.

BTN-11 RaceExpand: “BINGO RACE ▼/▲”. Collapsed, expanded, hover, pressed, focus. Must clearly reveal or hide the AllPlayers ranking list.

BTN-12 MusicToggle: “Music: On/Off”. On, off, hover, pressed, focus; distinct on/off icon art. The existing clickable instance is a TextButton named MusicToggle, so keep icon and label as children or native properties rather than replacing its class.

BTN-13 EffectsToggle: “Effects: On/Off”. Same state set and construction rule as MusicToggle, with clearly different iconography from music.

BTN-14 CardCell: the shared clickable cell prefab used 25 times per Bingo card. Native number or free star must stay editable. Uncalled/unavailable, called/markable, pending, marked, free star, hover/focus, pressed and mark celebration. Use shape, contrast and stamp together; color alone must not carry state.

BTN-15 ShopShade: the dim backdrop that closes the shop when tapped. Design the backdrop surface and its visual separation, but no visible CTA, text or extra close icon.

BTN-16 QueuePrompt: the Roblox world ProximityPrompt named QueuePrompt. Design a small visual reference for “Join / leave queue”, keyboard E, gamepad X and touch affordance. This is an engine prompt; keep action/object text native and do not promise a custom prompt skin without a later implementation decision.

Start now with BTN-01 only. Show its variants and export/handoff notes, then wait.
```

For Figma follow-ups, send `next button` after approving an ID, or `revise BTN-XX: ...` to change that component without advancing.
