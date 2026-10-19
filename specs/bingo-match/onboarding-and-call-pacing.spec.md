# Bingo Onboarding and Call Pacing Specification

**Status:** Draft for discussion  
**Purpose:** Reduce first-match confusion and give players enough time to understand and act on each call.  
**Related:** [Match specification](spec.md) · [Technical design](design.md) · [Implementation tasks](tasks.md)

## Problem

The first playtest exposed two barriers: players did not understand what Bingo is, what to do, or how to win; and calls moved too quickly to read the number, find it on the card, and mark it. The current loop assumes the player already understands the game.

## Product outcome

A first-time player can enter a match, explain the goal in their own words, identify the latest called number, and mark a matching cell before the next call. The experience should be understandable to a young child using short, concrete language.

## Scope

This spec covers the path from the shared lobby to the first live number calls, cutscenes and MC presentation, call readability and pacing, and clear match-end feedback. It does not change the Bingo rules: each player still has an individual card, everyone receives the same calls, and the first full card wins.

## Player journey

1. The player sees a clearly labeled portal in the lobby and enters its queue by interacting with it.
2. The portal communicates whether it is waiting for players or counting down, and shows how many players are queued.
3. The player has the existing lobby countdown to join before the participant list is locked. Players arriving after lock wait for the next match.
4. At match start, an MC NPC welcomes the players in an opening cutscene. The scene explains the goal and controls while the card is revealed.
5. The MC announces each number. The latest number remains prominent while the player has time to find and mark it. A brief camera or character beat adds presentation without interrupting play.
6. The next number is not announced until the call display interval ends. Players can still mark any previously called number during that interval.
7. A short results cutscene shows the MC announcing the winner or draw, then the player returns to the lobby flow.

## Requirements

### Portal and queue

- **MUST** give the entry point a visible, plain-language label that communicates how to join Bingo.
- **MUST** let players explicitly join the waiting queue by interacting with the portal.
- **MUST** show queue status, queued-player count, and countdown in a way that a queued player can see.
- **MUST** explain that a player who arrives after the participant list is locked will play in the next match.
- **MUST** preserve the published-server minimum-player rule and countdown cancellation behavior from the match spec.
- **MUST** keep queued players in the lobby while the match is in progress; they must not be added to the current match.

### MC NPC and cutscenes

- **MUST** include a visible in-world MC NPC in the match space; the MC is the presenter for the match.
- **MUST** play an opening tutorial cutscene before the first call of a player's first match in the server session.
- **MUST** have the opening cutscene show the MC explaining how to play while the player's card is revealed and highlighted.
- **MUST** include a short kickoff scene on later matches in the same session, but do not replay the full tutorial unless the player requests help.
- **MUST** present the MC's instructions and calls as readable dialogue or captions; voice acting may supplement the text but cannot be the only way to understand the game.
- **MUST** include a brief results cutscene in which the MC announces the winner or draw.
- **MUST** target a maximum duration of 8 seconds for the first introduction, and 3 seconds for later kickoffs and results.
- **MUST** provide a skip or continue control during cutscenes. Skipping must not omit the game instructions from the player's first match; keep a concise reminder visible before the first call.
- **MUST** return control to the player and restore the normal gameplay camera when each cutscene ends or is skipped.
- **SHOULD** stage the MC with a small camera move and character gestures rather than hiding the Bingo card for the whole scene.

### First-match explanation

- **MUST** communicate all of the following in plain language: find the number on your card, tap or click it to mark it, and fill every number on your card to win.
- **MUST** explain that the center free space is already marked, if that rule remains visible to players.
- **MUST** allow the player to see and read the explanation before calls begin; do not overlap explanation text with live calls.
- **MUST** finish the introductory cutscene within 8 seconds unless the player chooses to continue reading a displayed explanation.

### Calls and action time

- **MUST** present each called number in large, high-contrast text with its Bingo column letter (for example, “B — 12”).
- **MUST** have the MC NPC announce each number while the matching on-screen call is visible; player input and card visibility remain available.
- **MUST** keep the latest call visible until it is replaced by the next call.
- **MUST** give players a configurable reading and marking interval between calls.
- **MUST** use a 5-second default interval for the first revised playtest, replacing the current 1.5-second cadence.
- **MUST** show a simple visible cue for when the next call is coming, such as a progress bar or brief countdown.
- **MUST** preserve access to the card and recent calls during the full interval.
- **MUST** allow marks for any number already called, regardless of which call is currently displayed.

### Match outcome

- **MUST** use direct result text that says who won or that no one completed a card.
- **MUST** visually distinguish the player's own win from another player's win or a draw.
- **MUST** let the MC announce the result in the results cutscene while the same result remains readable on screen.

## Suggested beginner copy

Use this as a starting point; wording can be tuned after observing players:

> “Welcome to Bingo! Look for the number I call on your card. Tap or click that square to mark it. Fill every number to win. The middle square is free!”

For each call:

> “B — 12!”

Keep the number on screen while the player searches and marks.

## Acceptance scenarios

### MC cutscenes present the match

**Given** a player enters their first match in this server session  
**When** the match starts  
**Then** a visible MC NPC presents an opening cutscene  
**And** the player sees the card revealed as the instructions are explained  
**And** the cutscene ends or can be skipped, returning camera and control to the player before the first call.

**Given** a match ends with a winner or draw  
**When** the result is shown  
**Then** the MC presents a short results cutscene and readable result text remains visible.

### Player joins through the portal

**Given** the player is in the lobby  
**When** they interact with the Bingo portal  
**Then** they see that they joined the queue  
**And** they can see the player count and countdown or waiting status.

### Player has time to respond to a call

**Given** a call has just been announced  
**When** the call interval is active  
**Then** the latest number and the card remain visible  
**And** the player can mark a matching called number  
**And** the next call does not appear before the configured interval ends.

### Earlier calls remain playable

**Given** a number was called earlier in the same match  
**When** the player marks its matching cell during a later call interval  
**Then** the server accepts the mark if all existing match rules are satisfied.

### Match result is clear

**Given** a player wins or the match ends in a draw  
**When** the result is presented  
**Then** the player can tell whether they won, another participant won, or there was a draw.

## Product decisions

- The MVP includes an MC NPC, an opening tutorial cutscene, brief MC call presentation, and a results cutscene. Keep the staging small enough to build and iterate quickly.
- The revised first-playtest call interval is 5 seconds. After the next session, adjust based on whether players can read, search, and mark comfortably.
- The source feedback asks players to enter via a portal. The current single-queue portal is sufficient for this MVP.
- First-time status should be session-local for this test. Do not add persistent onboarding data unless replay testing shows the introduction gets in the way.