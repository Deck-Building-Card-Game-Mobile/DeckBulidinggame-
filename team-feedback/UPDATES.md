# Dungeon Deck — Integration Changes and Role 3 Updates

## Purpose

This document tracks the changes made on the `feature/ui-development` branch while integrating and testing the team's systems.

Some code from different systems was modified to make sure the UI, combat, cards, and dungeon progression work together correctly.

These changes are available for teammates to review, test, and provide feedback.

---

## Role 3 — UI/UX and Gameplay Updates

### Recent Changes

**Main Menu and Settings**
- Main Menu connected to the dungeon run system.
- Settings menu includes Master, Music, and SFX volume controls.

**Combat HUD**
- Displays player HP, block, and energy.
- Displays enemy HP, block, and upcoming actions.
- Supports card selection, playing cards, and ending turns.
- Integrated with dungeon progression.

**Card Retention and Manual Discard**
- Unused cards remain in the player's hand between turns.
- Maximum hand size is 10 cards.
- Added a manual discard button.
- Discarding does not provide additional energy or card draws.
- Discarded cards can return after reshuffling.

**Updated Card Draw Balance**

The first turn starts with 5 cards.

For subsequent turns:

| Cards Drawn | Probability |
|---|---|
| 1 card | 35% |
| 2 cards | 50% |
| 3 cards | 15% |

This adjustment was made because drawing five cards every turn made combat too easy.

**Dungeon Integration**
- Combat HUD works with the Run Manager.
- Player HP and deck changes carry between encounters.
- Card rewards are available after battles.
- Rest Area supports healing or card upgrades.
- Five encounters are currently available, ending with the Dungeon Warden boss.

---

## Additional Integration Details

### Card and Deck System
- Connected card drawing and discarding with the Combat HUD.
- Preserved unused cards between turns.
- Added support for manual discarding without spending energy or drawing replacement cards.
- Added a maximum hand size of 10.
- The discard pile can be reshuffled into the draw pile when needed.

### Dungeon Encounters
The current integrated run includes:

1. Slime
2. Cave Rat
3. Rest Area
4. Skeleton Guard
5. Dungeon Warden (Boss)

### Rewards and Progression
- Card rewards are available after combat.
- Players can choose rewards that affect their deck.
- Rest Areas allow healing or upgrading cards.
- Player HP and deck changes persist throughout the run.

---

## Feedback Requested From Teammates

### Role 1 — Combat
- Does the new card draw rate feel balanced?
- Should enemies become stronger as the dungeon progresses?
- Are any cards too powerful when retained between turns?

### Role 2 — Cards and Deck System
- Does manual discarding work correctly with all card effects?
- Should any cards have special retention or discard rules?
- Are the current card rewards and upgrades balanced?

### Role 4 — Dungeon and Run Management
- Should we add more encounters or alternate paths?
- Are the Rest Area and card rewards balanced?
- Should dungeon progression offer more variety?

### General Feedback

Please test the updated gameplay and share suggestions about:

- Combat difficulty
- Card draw probabilities
- UI readability and mobile responsiveness
- Dungeon pacing
- Bugs or unexpected behavior
- Integration between different systems

---

## How to Submit Feedback

Please read `team-feedback/FeedBack.md` for the full feedback submission instructions.

**Every feedback submission must include:**
- Your name
- Your role number
- The feature or system being reviewed
- The problem or suggested change
- Why the change is needed
- The expected result

You can create your own Markdown feedback file inside the `team-feedback` folder.

---

## Current Branch

These changes are currently on the `feature/ui-development` branch and are ready for team review.

The purpose of this branch is to test the integrated game, identify problems, and make improvements before merging changes into `main`.
