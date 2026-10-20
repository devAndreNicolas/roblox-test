# Bingo Match Specification

**Status:** Implemented prototype; verify against the playtest before treating these choices as validated.
**Purpose:** Define the observable player experience and game rules for the first Bingo feature.
**Related:** [Technical plan](plan.md) · [Validation plan](validation.md) · [Original playtest feedback](research/playtest-feedback.md)

## Product outcome

A first-time player can join a match, understand what Bingo is and how to play, follow each call, mark their card, and tell who won. The group can play another round without restarting the server.

## Scope

One Roblox server hosts one active match at a time. Players use a lobby portal to queue, receive individual cards, hear the same calls, mark their own cards, see a result, and return to the lobby. The match includes an MC NPC, a short first-match tutorial cutscene, brief repeat-match and result scenes, readable captions, and enough time to act on each call.

No persistent progression, economy, global matchmaking, or paid advantages are included.

## Terms

- **Lobby:** Shared area where players wait and join the next match.
- **Queue:** Players who interacted with the Bingo portal and are waiting for a match.
- **Participant:** A queued player locked into a match when its countdown ends.
- **Call:** A number announced to all participants in the active match.
- **Mark:** A server-accepted selection on a participant's own card.

## Requirements

### Join and start

- **MUST** spawn joining players in a lobby and show a clearly labeled Bingo portal.
- **MUST** add a player to the queue only after they interact with the portal.
- **MUST** show queue status, queued-player count, and countdown near the portal.
- **MUST** require two queued players in published servers before starting.
- **MUST** cap each match at eight participants; additional queued players keep their FIFO position for the next match.
- **MUST** begin a visible 10-second countdown when the minimum is met and cancel it if the queue drops below two.
- **MUST** lock the participant list when the countdown ends.
- **MUST** tell late arrivals and unqueued players that they can join the next match; they do not enter the active match.
- **MUST** let nonparticipants remain in and use the lobby while a match is active, and let them queue for the next match.
- **MAY** allow a one-player development override in Studio only.

### Explain and present the game

- **MUST** show an MC NPC in the match space and use it as the presenter.
- **MUST** play a first-match introduction before the first number call, showing the MC and revealing the player's card.
- **MUST** explain in short, concrete language: find the number the MC calls, tap or click that square, and fill every number to win.
- **MUST** explain that the center square is free and already marked.
- **MUST** keep the instruction visible long enough to read before calls begin; the opening scene is at most 8 seconds unless the player chooses to continue reading.
- **MUST** keep a short reminder visible before the first call if the player skips the camera scene.
- **MUST** provide skip or continue control and restore normal camera control when a scene ends or is skipped.
- **MUST** use a short kickoff scene (up to 3 seconds) in later matches during the same server session.
- **MUST** show captions for instructions, calls, and results; voice is optional and cannot be the only way to understand.
- **MUST** present the winner or draw in a results scene of up to 3 seconds; keep the readable result screen visible for 8 seconds total.

### Cards and calls

- **MUST** deal one server-generated 5×5 card to each participant at match start.
- **MUST** use standard ranges: B 1–15, I 16–30, N 31–45, G 46–60, O 61–75.
- **MUST** select values without replacement within each column and mark the center N square free from the start.
- **MUST** create one shuffled sequence containing each number from 1 through 75 exactly once and share its order with all participants.
- **MUST** show each call prominently with its column letter (for example, “B — 12”) and keep it visible until the next call.
- **MUST** have the MC announce each call while the number is visible, with the card still available for play.
- **MUST** use a configurable 5-second default interval between calls for the next playtest and show a simple cue for the next call.
- **MUST** retain recent calls and allow players to mark any previously called number during the match.

### Marks and outcome

- **MUST** let a participant request a mark by identifying a cell on their own card.
- **MUST** accept a mark only during active play when its number has been called, or when it is the free center.
- **MUST** reject malformed cell identifiers, uncalled numbers, duplicate marks, requests from nonparticipants, and requests after the match ends.
- **MUST** determine card completion and the winner on the server. The first valid full card wins.
- **MUST** end as a draw if all 75 calls are used without a winner.
- **MUST** clearly distinguish the local player's win, another player's win, and a draw.

### Lifecycle

- **MUST** show the result for 8 seconds, then return remaining players to the lobby.
- **MUST** begin another 10-second countdown only when at least two players are queued again.
- **MUST** remove a leaving player's queue or match state without interrupting other participants.
- **MUST NOT** persist cards, wins, or match state between server sessions.

## Acceptance scenarios

### First-time player understands the goal

**Given** a player enters their first match in this server session  
**When** the MC presents the card and instructions  
**Then** the player can see how to find and mark a called number and what completes a win  
**And** the first call does not begin until the instruction has been presented.

### Players join through the portal

**Given** players are in the lobby  
**When** the second player joins the queue at the Bingo portal  
**Then** both see the queue count and a 10-second countdown  
**And** if the queue drops below two before it ends, the countdown is cancelled.

### A match has a clear size and overflow stays queued

**Given** ten players are queued when the countdown ends
**When** the match starts
**Then** the first eight queued players enter the match
**And** the remaining two stay queued in their original order for the next match
**And** those two are told that the current match is full and they are queued next.

### Late arrival waits for the next match

**Given** a match is active  
**When** another player joins the server  
**Then** that player sees the lobby and a next-match message  
**And** does not receive a card in the active match.

### Player has time to respond to a call

**Given** the MC announces a number  
**When** the 5-second call interval is active  
**Then** the number and card remain visible  
**And** the player can mark it or any earlier called number before the next call.

### First full card wins

**Given** the match is active  
**When** an accepted mark completes a participant's card  
**Then** the server records that participant as the winner and ends the match  
**And** later mark requests cannot change the result.

### Exhausted calls produce a draw

**Given** all 75 numbers were called and no card is complete  
**When** the last call interval ends  
**Then** the MC presents a draw and the result screen remains visible for 8 seconds.

## Open questions for the next playtest

- Is a full card a satisfying win condition at the current pace?
- Can new players understand the tutorial without help, and does the 5-second interval feel comfortable?
- Does the portal make queue membership and the next match clear?
