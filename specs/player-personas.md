# Bingo Player Personas — Collaborative Draft

**Status:** Proto-persona hypotheses plus secondary market research; not validated audience profiles.
**Purpose:** Give us a shared way to discuss whose needs the Bingo MVP and its scenario should serve. Use this document when reviewing feature specs, but do not treat a hypothesis as a requirement until we confirm it through discussion or playtests.
**Research inputs:** [Roblox platform and competitor research](#roblox-audience-and-bingo-market-research), [001 first playtest feedback](001-bingo-match/research/playtest-feedback.md), [002 owner feedback](002-ui-improvements/research/playtest-feedback.md), [003 scenario feedback](003-fantasy-scenario/research/playtest-feedback.md), and [004 match feedback](004-sfx-fantasy-dopamina/research/playtest-feedback.md).

## What we know so far

All current feedback comes from the owner describing their own play experience. The first playtest report is one source; the later notes may describe the same person and play session, so they are not independent evidence. We have not yet interviewed or observed a range of players. Confidence in audience-level claims is therefore **low**.

The owner directly reported:

- Difficulty understanding Bingo, the goal, and what action to take.
- Too little time to read the called number and mark the card.
- A desire for an MC who explains the game and hosts the match.
- A UI that feels confusing and visually crowded.
- A scenario that feels empty and unattractive; “buggy and annoying” without reproduction steps.
- After the scenario update, an atmosphere they liked but repetitive marking during the match; they suggested stronger mark feedback and visibility into who is close to Bingo.

These statements are useful evidence about one play experience. They do not yet establish the age, habits, motivations, or preferences of the game's broader audience.

## Audience decision

**Product decision from the owner:** We want both children and teenagers to enjoy the same Bingo game.

For planning, treat the intended audience as **children under 13 and teenagers ages 13–17**. Roblox divides children further into Kids (5–8) and Select (9–15) account types, so “children” is too broad to assume one reading level or one play style. Adults may also play, but are not a primary persona for this MVP.

This is a product choice, not a finding that all of these ages already enjoy our game. The available Bingo examples do not publish player ages. We should validate children 5–8, children 9–12, and teenagers 13–17 as separate playtest cohorts when feasible. Access to the Roblox Kids catalog for ages 5–8 may require the experience to pass Roblox's selection process, in addition to having age-appropriate content.

**Shared experience hypothesis:** Keep one fair Bingo ruleset and one clear hosted show identity. Make the next action and call easy to understand at a glance, then use personality, competition, and celebration so the experience can feel fun to different ages. Core participation must not depend on chat; under-nine Roblox Kids accounts have communication disabled by default.

## Roblox audience and Bingo market research

**Researched:** 2026-10-20. Roblox platform data below is official where stated; per-experience usage counts come from third-party trackers reading public Roblox data and are time-sensitive snapshots.

### Is Roblox mostly children or teenagers?

It is a large mixed-age platform, with both children and teenagers representing substantial audiences:

- Roblox reported **123 million average daily active users (DAUs)** and **29 billion hours** in Q2 2026. By the end of that quarter, **57% of global DAUs had age-checked**. Among that age-checked group, Roblox reported **35% under 13, 38% ages 13–17, and 27% ages 18+**. Teenagers 13–17 were the largest single reported band, but these percentages describe the age-checked subset, not a proven representative split of all Roblox players. They also do not tell us how many players are ages 5–8 versus 9–12. ([Q2 2026 shareholder letter / SEC filing](https://www.sec.gov/Archives/edgar/data/1315098/000162828026051059/ex991-robloxq22026earnin.htm))
- Roblox now has **Roblox Kids accounts for ages 5–8** and **Roblox Select accounts for ages 9–15**. These account types use age-appropriate catalogs and different communication defaults; Kids accounts have communication off by default. A game aimed at very young children may need to meet Roblox's extra selection criteria to be available in those catalogs. ([Roblox Kids and Select rollout](https://ir.roblox.com/news/news-details/2026/Roblox-Kids-and-Roblox-Select-Accounts-Now-Available-Worldwide/default.aspx), [account launch details](https://ir.roblox.com/news/news-details/2026/Roblox-Introduces-New-Age-Based-Accounts-and-Expanded-Parental-Controls-for-Users-Under-16/))
- Roblox's Creator Dashboard can show **our own experience's** monthly active audience by age, country, gender, and language. Once our game has enough players, this is more useful for choosing an audience than guessing from platform-wide data. ([Roblox demographics analytics](https://create.roblox.com/docs/production/analytics/demographics))

**What this means:** We should not decide “kids” versus “teens” from platform size alone. The evidence supports designing a readable, accessible game for a broad age range, then checking which players actually arrive and return. “Explain it so a five-year-old can understand” can be a clarity bar without making ages 5–8 our target market.

### Do Bingo games have a real Roblox audience?

Yes. There is already a large, direct Bingo audience, but the public data does not reveal those games' player ages.

| Experience | What it offers | Public usage signal found | What we can learn |
|---|---|---|---|
| [Bloxy Bingo](https://www.roblox.com/games/5244411056/Bloxy-Bingo) | American 75-ball, British 90-ball, Lotería, and Arcade Bingo; custom markers, mascots, themes, calls and dances; private servers for parties. | Rolimon's page read on 2026-10-20 showed about **2,666 playing**, **508M visits**, **1.37M favorites**, and an **84.1% rating**. It reports an 80-player server limit and an estimated 18.37-minute average playtime. These are third-party snapshots/derived stats, not Roblox-published audience demographics. ([Rolimon's stats](https://www.rolimons.com/game/5244411056)) | Classic Bingo can support a durable, large Roblox experience. The product wraps the base game in format variety, social play, identity/customization, and party options. An 80-player server limit does not mean 80 players share every individual round. |
| [50 Player BINGO!](https://www.roblox.com/games/131479356121251/50-Player-BINGO) | Fast Bingo for 50 competitors, with cash, card unlocks, and a leaderboard. | SpawnScope recorded about **4,838 concurrent players and 53M visits on 2026-09-29**, with a reported **22.7K concurrent-player peak on 2026-08-15**. It was a newly launched experience and its activity changed quickly. ([SpawnScope snapshot and history](https://spawnscope.com/games/50-player-bingo/)) | A fresh, high-capacity, fast-paced Bingo variant can attract a large burst of attention. The spike is not proof of stable long-term retention or an age segment. |

These examples show that “Bingo is too old-fashioned for Roblox” would be a poor assumption. They do **not** show that a bare classic round is enough: the prominent examples add speed/variety, a social wrapper, player identity, progression, or large shared rooms. That suggests we need to test our own hook—currently a friendly MC, clear teaching, and a hosted Bingo-club atmosphere—rather than copy their full feature sets.

### Market and evidence limitations

- Roblox is not one audience. Its platform-wide daily reach is enormous, but that does not tell us how many people will discover or choose our game.
- Roblox's age split is currently published for age-checked users; the other 43% of DAUs at the end of Q2 2026 were not in that measured subset. Do not apply the age-checked percentages to every DAU as if they were a direct census.
- Public Roblox pages and third-party trackers do not provide reliable player-age breakdowns for Bloxy Bingo or 50 Player BINGO. We cannot claim “Bingo players are kids” or “Bingo players are teens” from the current research.
- Visits are repeatable joins, not unique players. Concurrent-player counts are snapshots and can swing with updates, time zones, events, and discovery placement. Long-term demand should be judged with retention and return-play data, not lifetime visits alone.
- Roblox's largest potential audience does not make our current eight-player match size, 10-second queue countdown, or five-second calls automatically right. Those are product hypotheses to test. Bloxy Bingo's 80 is server capacity; 50 Player BINGO's title explicitly promotes a 50-player competition. Our queue/match architecture is deliberately a smaller MVP and should be revisited if waiting or social energy becomes the leading problem.
- After launch, use Creator Dashboard demographics and our own funnel/retention data where available. Do not add analytics infrastructure before there is a clear decision those measurements will change.

## Proto-persona hypotheses

These are behavior-based lenses for product discussion, not fictional biographies. We avoid invented ages, genders, and backstories. We will merge, revise, or remove them when player evidence disagrees.

### 1. The Bingo newcomer

**Evidence status:** The strongest current hypothesis, based on one owner playtest report. Still unvalidated beyond that report.

**Situation**  
Joins a Roblox Bingo match without knowing the rules or the game's interaction flow.

**Job to be done**  
“When I enter a Bingo game, help me understand what the caller says, what I should do with my card, and how I can win, so I can start playing without someone explaining it to me.”

**Needs**

- Quickly understand how to join a match, read a call, mark a square, and win.
- Have enough time to find a number and act on the card.
- See the MC and game space as welcoming and purposeful.

**Likely friction to investigate**

- Unfamiliar language or too many instructions at once.
- Missing a call or uncertainty about which square can be marked.
- A confusing portal, crowded presentation, or long wait before playing.

**Design lens for the scenario spec**  
Can this player tell where to go, who is hosting the game, and what happens next without developer narration? Does the room help them notice the portal and the match stage?

### 2. The child player

**Evidence status:** Audience is an explicit product target; needs below are hypotheses. The owner playtest did not report the player's age, and there is no child playtest data yet.

**Situation**  
Joins Bingo with limited familiarity with the rules and may be using a Roblox Kids or Select account. The 5–8 and 9–12 groups must be checked separately; we do not assume they play or read the same way.

**Job to be done**  
“Help me see what the caller wants me to do and let me take part without needing to read a long explanation or ask someone in chat.”

**Needs to validate**

- Concrete instructions paired with a visible example of a number being called and marked.
- A stable, readable game space where the host, card, and next action are easy to find.
- Clear feedback for a mark, waiting, and winning that does not depend on chat, color alone, or sound.

**Likely friction to investigate**

- Text-heavy instructions, small numbers, competing visual effects, or too little time to respond.
- Unclear queue and match boundaries.
- Assuming access to free-form chat or a user communicating with strangers.

**Design lens for the scenario spec**  
Can the child find Bingo, understand the immediate goal, and feel included in the hosted match with visual and plain-language guidance?

### 3. The teen player

**Evidence status:** Teenagers are a large Roblox cohort in age-checked platform data, but there is no direct evidence about teens playing Bingo or our game.

**Situation**  
Joins a Roblox experience for a quick social or competitive session, alone or with friends. Whether teens will choose Bingo over other minigames is an open product question.

**Job to be done**  
“Give me a fair, easy-to-join match with enough anticipation and personality that I want to compete and play another round.”

**Needs to validate**

- A brisk, understandable flow with visible progress and a satisfying result.
- A distinctive presentation that feels like a deliberate Roblox game, not just an instructional activity.
- Social expression and competition that remain fun with or without chat.

**Likely friction to investigate**

- A long period of passive number calls or waiting.
- Presentation that feels too young for their taste, or a generic room with no memorable identity.
- A result that feels random or unearned because the player cannot follow the calls and mark opportunities.

**Design lens for the scenario spec**  
Does the world feel like a lively event teens choose to join, while keeping the call and card as the center of play?

### 4. The friend-group competitor

**Evidence status:** Product hypothesis based on the intended social multiplayer loop; no direct player evidence yet.

**Situation**  
Enters a server with friends or joins a group already playing Bingo.

**Job to be done**  
“Give us a simple shared game where we can anticipate calls, compete fairly, react to each other's progress, and decide to play another round together.”

**Needs to test**

- A common host, call, and match rhythm that the group can follow together.
- Clear winner and result moments that feel satisfying to share.
- A lobby that feels like part of the event between matches.

**Likely friction to investigate**

- A match that feels too long or too quiet to sustain group energy.
- Players split across server instances or left waiting without understanding their turn.
- Environmental details or effects that distract from the group and the Bingo calls.

**Design lens for the scenario spec**  
Does the space feel like a social Bingo event, and can players see the host and shared activity from where they play?

### 5. The next-up player

**Evidence status:** System-driven hypothesis from the proposed eight-player cap and one active match per server; no direct player evidence yet.

**Situation**  
Arrives after a match locks its participants or waits in the queue because the current match already has eight players.

**Job to be done**  
“Tell me clearly when I can play and make waiting feel intentional, so I know whether to stay, join the next round, or leave.”

**Needs to test**

- Understand that the active match is closed and whether they are queued for the next one.
- See where to wait and what is happening in the current match, if observation is supported.
- Have a clear choice to stay queued or leave.

**Likely friction to investigate**

- Waiting in an empty-feeling lobby for a long full-card match.
- Unclear queue position or mistaken belief that they joined the current match.
- Nothing meaningful to notice or do while waiting.

**Design lens for the scenario spec**  
Does backstage make the queue state and next step clear without requiring a spectator feature?

## Decisions for the current scenario experiment

- **One shared audience:** children under 13 and teenagers ages 13–17 remain intended audiences. Observe ages 5–8, 9–12, and 13–17 separately where feasible; appeal is not yet validated.
- **Working tone:** theatrical noir TV mystery inspired by 1990s Batman animation, family friendly and non-horror. The 003 spec defines the visual execution. Test whether the style feels intriguing and readable to each cohort.
- **World roles:** backstage is the waiting area; active participants enter a separate studio. Waiting players do not spectate in this MVP. Validate whether queue information and backstage make waiting understandable.
- **Participation:** up to eight participants are seated facing the MC and remain seated until the match ends. There is no in-match leave action; disconnect is still possible. Validate comfort, especially against the configured worst-case round length.
- **Audio and feedback:** optional instrumental broadcast jazz, muteable and replaceable with founder-created music. Calls and accepted marks get short feedback; Bingo gets a stronger celebration. Essential information remains visual.
- **Assets:** use Roblox-native world geometry, materials, lighting, UI instances, and effects for the MVP. Temporary Creator Store music is the only planned external asset dependency.

Other audience questions remain open: friend-group versus solo acquisition, Kids catalog eligibility, and whether the noir identity increases repeat play. These decisions require player evidence or a later product discussion.

## How we will validate these hypotheses

For the next playtests, recruit children and teenagers as separate cohorts, with children's observations split into ages 5–8 and 9–12 where feasible. Include both Bingo newcomers and players who already know Bingo, and note whether each came alone or with friends. Follow Roblox requirements and obtain appropriate parent/guardian permission for research with minors. Record behavior before explaining anything: where they go, how they join, when they understand the goal, what they do while waiting, whether they stay through a match, and whether they choose another round.

After the round, ask open questions before offering explanations:

1. What did you think you were supposed to do when you joined?
2. What was happening when you felt confused, bored, or excited?
3. What did you expect to happen while waiting for a match?
4. Would you play another round now? What makes you say that?

Record each participant separately in the appropriate feature's `research/` folder. Add quotes and observations first; update these personas only after patterns repeat across players. Do not infer a persona from one vivid comment.

## Review notes

Use the questions above to revise this draft together. Use the child and teen personas as separate lenses to analyze [003 — Bingo Noir: Mistério no Ar](003-fantasy-scenario/spec.md). Look for one shared world that supports both, then validate visual and pacing choices with both age groups rather than treating the broad target as proof that one design automatically works for everyone.
