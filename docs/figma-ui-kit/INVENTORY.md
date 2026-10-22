# Existing UI inventory and Figma component IDs

This inventory maps the current implementation, including hidden and conditional states. Repeated instances share a Figma component. Paths start at `StarterGui > BingoGuiDesign` unless noted. Buttons remain native Roblox controls so their click, gamepad and focus behavior stays intact.

## Interactive controls — design each use and its states

| ID | Existing instances / action | Required visual variants |
| --- | --- | --- |
| `BTN-01 Action` | `Content > LobbyView > LobbyStatus > Action` = Try again; `Content > IntroView > Caption > Action` and `Content > ResultsView > Outcome > Action` = Skip scene | normal, hover, pressed, focus, disabled; short/long labels |
| `BTN-02 OpenShop` | `RewardsShop > RewardsHud > OpenShop` | normal, hover, pressed, focus, shop-open cue |
| `BTN-03 CloseShop` | `RewardsShop > ShopPanel > Header > CloseShop` | normal, hover, pressed, focus; compact mobile |
| `BTN-04 ShopTab` | `RewardsShop > ShopPanel > Categories > Fichas/Cartelas/Poderes/Convites` = Tickets/Cards/Power-ups/Invites | selected, unselected, hover, pressed, focus, narrow mobile |
| `BTN-05 BuyRobux` | three Ticket pack rows; five purchasable card theme rows and theme showcase; MC Bribe row | available, unavailable/unconfigured, processing, success, owned/hidden context; price text remains dynamic |
| `BTN-06 BuyTickets` | card theme rows and theme showcase where Ticket purchase is allowed; MC Bribe row | affordable, insufficient Tickets, processing, success, owned/hidden context |
| `BTN-07 Equip` | five card theme rows and theme showcase | owned/available, equipped, hover, pressed, focus; absent for unowned themes |
| `BTN-08 Inspect` | five card theme rows: `Inspect` = See in game | normal, hover, pressed, focus |
| `BTN-09 Invite` | `RewardsShop > ShopPanel > Catalog > invite > SendInvite` | normal, pressed, focus, unavailable/error feedback |
| `BTN-10 UseBribe` | `RewardsShop > UseSuborn` during match | no stock, available, used by this player, match limit reached, announcement in progress, focus; live stock and 0/2 count |
| `BTN-11 RaceExpand` | `Content > MatchView > BingoRace > ExpandRace` | collapsed, expanded, hover, pressed, focus |
| `BTN-12 MusicToggle` | `MusicToggle` | on, off, hover, pressed, focus; separate icons; controller currently changes text only |
| `BTN-13 EffectsToggle` | `EffectsToggle` | on, off, hover, pressed, focus; separate icons; controller currently changes text only |
| `BTN-14 CardCell` | 25 cells inside each `BingoCard > Cells`; shared design source is `Components > CardCell` | uncalled, called/markable, pending, marked, free star, focus, pressed, unavailable; keep numerals native |
| `BTN-15 ShopShade` | `RewardsShop > ShopShade`, clicking outside closes shop | backdrop surface and tap-outside affordance; no visible button label |
| `BTN-16 QueuePrompt` | `ReplicatedStorage > WorldGuiTemplates > QueuePrompt` | join queue, leave queue, gamepad/keyboard/touch affordance, unavailable; Roblox engine owns prompt behavior |

`BuyFichas` is the Luau instance name for `BTN-06 BuyTickets`; keep the player-facing word **Tickets**. The five theme rows are Blue Dossier, Stage Star, Club Seal, On Air and Gala Velvet. Ticket purchase is hidden for the two Robux-exclusive themes. The Classic theme is free and has no shop row.

## Non-button component families

| ID | Existing elements | States and exportable art |
| --- | --- | --- |
| `EL-01 TypographyBrand` | Lobby brand/live, shop masthead, section headings, captions, helper text, numeric labels | display, body, utility, live indicator, readable numbers; logo/wordmark only if it improves the identity |
| `EL-02 Surfaces` | `LobbyStatus`, `Caption`, `Outcome`, `Call`, `BingoRace`, `ShopPanel`, `ShopShade`, catalog entries, `Feedback` | base panel, ticket edge, strokes, divider, modal backdrop, scroll clipping; light/dark/attention surfaces |
| `EL-03 LobbyStatus` | brand, live, title, instructions, queue count, retry action | connecting, not queued, queued, countdown, full/current round, connection delayed |
| `EL-04 ShowCaption` | intro MC speaker, instruction, skip, starting-soon message; result eyebrow/title/detail/skip | intro speaking/waiting; win/loss/draw, own win highlight |
| `EL-05 BingoCard` | classic card in intro and match; same card in shop showcase | full card, BINGO header, 5x5 grid, theme frame, focus/marks, loading art fallback; native dynamic content |
| `EL-06 CardThemes` | `classic`, `dossier_blue`, `stage_star`, `club_seal`, `on_air`, `velvet_gala` | six isolated decorative frames; transparent center; same art in shop/intro/match |
| `EL-07 CallStatus` | `Content > MatchView > Call` with `CallBall`, `Caption`, `Timing`, `Track > Progress` | ready/unknown, called B-I-N-G-O number, countdown, pulse, paused for MC Bribe |
| `EL-08 Race` | `BingoRace` summary plus `AllPlayers` list with up to eight ranked rows | leader, second, self, ties, one-to-Bingo, expanded/collapsed, near-win pulse |
| `EL-09 History` | `HistorySurface`, `GoldRule`, recent calls, reminder | empty, one to four calls, compact mobile, hidden at short heights |
| `EL-10 BribeAnnouncement` | `Content > MatchView > SubornAnnouncement`, MC speech and next public number | starting/announcing/completing; do not imply automatic mark or guaranteed win |
| `EL-11 RewardsHud` | `RewardsHud` balance, next milestone and OpenShop; `ShopPanel > Rail` balance, seven dots, daily note, Studio note | loading, daily ready/completed, step 1–7, data unavailable; no punitive streak |
| `EL-12 ShopNavigation` | Shop header/close, four tabs, section heading/copy, scroll area, commerce note, `Notice` | each selected tab, scroll, mobile width, unavailable products, message |
| `EL-13 OfferCards` | Ticket packs `fichas_120/350/800`; `earn`; `theme_showcase`; five theme rows; `suborn`; `invite` | available/unavailable, affordable/insufficient, owned/equipped, stock, sample preview; isolated icons for packs and Bribe |
| `EL-14 Feedback` | `Feedback > Message`, Shop `Notice > Text`, marks/stamps/glints, near-win emphasis | info, success, error, pending, marked, win; communicate without sound or color alone |
| `EL-15 AudioControls` | `MusicToggle`, `EffectsToggle` | on/off icons and optional compact text, desktop/mobile |
| `EL-16 WorldUI` | `ReplicatedStorage > WorldGuiTemplates`: `PortalSign`, `HowToPlayGui`, `WinPosterGui`, `BackstageTitleGui`, `CallDisplay`, `MCDialogue`, `QueuePrompt` | long/short text, dynamic number, join/leave, distant legibility; flat front-view art per surface |

## Existing asset references

- Card-frame sources: `assets/bingo/card-skins/source/` (five PNGs); Classic is native UI.
- Offer icons: `assets/bingo/offer-icons/` (three Ticket packs, five themes, MC Bribe).
- Existing Studio visual templates: `assets/ui/BingoGuiDesign.rbxmx` and `assets/ui/WorldGuiTemplates.rbxmx`.

These references show current subjects and integration slots. New Figma artwork may replace their appearance. Keep live data as native text and UI.
