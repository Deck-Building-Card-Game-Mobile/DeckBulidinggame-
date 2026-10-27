# DeckBulidinggame-

DUNGEON ROGUELIKE DECK-BUILDING GAME
FOUR-PERSON TEAM ROLES AND RESPONSIBILITIES

PROJECT OVERVIEW
Our team is developing a mobile dungeon roguelike deck-building game. Players use cards to battle enemies, earn new cards, improve their decks, and progress through dungeon encounters toward a final boss. The game should be easy for beginners to learn while offering strategic variety.

ROLE 1: GAMEPLAY & COMBAT DEVELOPER (Ahmed Zeyad Abou Agina)
Main responsibility: Develop the rules and systems that control battles.

Responsibilities:
- Implement turn-based combat and turn order.
- Manage player and enemy health, damage, defense, and healing.
- Implement the energy or resource system used to play cards.
- Apply card effects during combat in coordination with Role 2.
- Develop enemy actions and basic combat behavior.
- Determine victory and defeat conditions for individual battles.
- Test combat calculations and turn transitions.

Expected deliverable:
A playable battle system where the player can use cards, enemies can respond, and battles end correctly.

ROLE 2: CARD & DECK SYSTEM DEVELOPER (Zack Ellis)
Main responsibility: Develop the underlying card and deck mechanics.

Responsibilities:
- Define card information, such as name, type, cost, and effect.
- Create and manage the player's deck, hand, draw pile, and discard pile.
- Implement card drawing, shuffling, and discarding.
- Implement card effects and coordinate their execution with Role 1.
- Support adding and removing cards from a deck.
- Handle card rewards that modify the deck during a run.
- Test card movement, deck changes, and card-related rules.

Expected deliverable:
A functioning card system that supports drawing, playing, discarding, shuffling, and modifying a deck.

ROLE 3: UI/UX & MOBILE DEVELOPER (Tommy Lenot)
Main responsibility: Build the mobile interface and make the game easy to understand and use.

Responsibilities:
- Create the main game screens and navigation.
- Display cards, card descriptions, health, energy, and enemy information.
- Implement player interactions for selecting and playing cards.
- Design and display the dungeon map and encounter choices.
- Provide clear visual feedback for damage, defense, rewards, and unavailable actions.
- Make layouts readable and controls usable on mobile devices.
- Test usability and screen layouts on target devices.

Expected deliverable:
A usable mobile interface through which players can navigate the game, understand their cards, and participate in battles.

ROLE 4: DUNGEON PROGRESSION & INTEGRATION DEVELOPER
Main responsibility: Develop the structure of a complete dungeon run and coordinate system integration.

Responsibilities:
- Implement dungeon progression and encounter sequencing.
- Support different encounter types, such as battles, rest areas, and bosses, as agreed by the team.
- Manage transitions between encounters and battles.
- Trigger rewards after successful encounters in coordination with Role 2.
- Track run state, including progress, remaining health, and completion status.
- Implement restarting a run after victory or defeat.
- Connect gameplay, cards, and UI into one working application.
- Coordinate integration testing and mobile builds; all members remain responsible for testing their own work.

Expected deliverable:
A complete playable run that connects battles, rewards, dungeon progression, and the final outcome.

HOW THE ROLES WORK TOGETHER
- Role 3 captures the player's interaction with a card.
- Role 2 supplies the card's information and effect.
- Role 1 applies the effect and updates the battle state.
- Role 4 advances the run when a battle ends and coordinates rewards.
- All four members contribute code, tests, documentation, GitHub updates, and integration support.

CARD SYSTEM
The 43-card set, rules and keywords from docs/design/Dungeon_Card_Set_v1.xlsx are built in as
data (data/*.json) and GDScript (scripts/cards, scripts/combat). See docs/CARD_SYSTEM.md for how
each role uses it. Run the tests with:
  godot --headless --path . --import
  godot --headless --path . --script res://tests/run_tests.gd


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

### Feedback Requested From Teammates

**Role 1 — Combat**
- Does the new card draw rate feel balanced?
- Should enemies become stronger as the dungeon progresses?
- Are any cards too powerful when retained between turns?

**Role 2 — Cards and Deck System**
- Does manual discarding work correctly with all card effects?
- Should any cards have special retention or discard rules?
- Are the current card rewards and upgrades balanced?

**Role 4 — Dungeon and Run Management**
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

These changes are currently on the `feature/ui-development` branch and are ready for team review.
