# Dungeon Deck — Project Documentation

## 1. Project Overview

**Dungeon Deck** is a dungeon roguelike deck-building game developed using Godot 4 and GDScript.

Players use a deck of cards to fight enemies in turn-based combat, obtain rewards, upgrade their cards, and progress through a dungeon toward a final boss.

The project combines four major systems developed collaboratively by the team:

- Gameplay and combat
- Card and deck management
- User interface and player interactions
- Dungeon progression and system integration

The game is designed to be approachable for new players while providing strategic decisions through card selection, resource management, enemy intentions, and dungeon progression.

## 2. Development Technologies

| Technology | Purpose |
|---|---|
| Godot 4 | Game engine and scene management |
| GDScript | Gameplay and application programming |
| JSON | Card definitions, keywords, and game rules |
| Git | Version control |
| GitHub | Team collaboration and source code management |
| Visual Studio Code | Code editing |
| Python | Supporting card-balance tooling |

The project is configured to use Godot's GL Compatibility renderer and includes a web-export directory.

## 3. Team Members and Responsibilities

### Role 1 — Gameplay and Combat Developer

**Ahmed Zeyad Abou Agina**

Responsible for the game's turn-based combat mechanics.

Primary contributions include:

- Combat state management and turn sequencing
- Player and enemy health, damage, and blocking
- Energy management and card-play rules
- Enemy actions and intentions
- Status effects and combat calculations
- Victory and defeat detection
- Combat-related testing

Important files:

- `scripts/combat/combat_state.gd`
- `scripts/combat/combatant.gd`
- `scripts/combat/enemy.gd`
- `scripts/combat/effect_resolver.gd`

### Role 2 — Card and Deck System Developer

**Zack Ellis**

Responsible for the game's card data and deck mechanics.

Primary contributions include:

- Card definitions, costs, effects, and rarities
- Deck creation and modification
- Draw, hand, discard, and exhaust piles
- Card shuffling and movement between piles
- Card upgrades and reward generation
- Card-balance calculations and supporting tests

Important files:

- `scripts/cards/card_data.gd`
- `scripts/cards/card_database.gd`
- `scripts/cards/card_instance.gd`
- `scripts/cards/card_piles.gd`
- `scripts/cards/deck.gd`
- `scripts/cards/reward_generator.gd`
- `scripts/cards/balance_calculator.gd`

### Role 3 — UI/UX and Mobile Developer

**Tommy Lenot**

Responsible for the game's player-facing interface and gameplay interaction.

Primary contributions include:

- Main menu and settings menu
- Master, Music, and SFX volume controls
- Combat HUD and player information
- Card display and player interactions
- Enemy health, block, and intent displays
- Manual card-discard controls
- Card-retention and draw-balance integration
- Integration of the UI with dungeon progression
- Gameplay feedback and interface improvements

Important files:

- `scenes/ui/main_menu.tscn`
- `scenes/ui/settings_menu.tscn`
- `scenes/ui/combat_hud.tscn`
- `scenes/ui/card_ui.tscn`
- `scripts/ui/main_menu.gd`
- `scripts/ui/settings_menu.gd`
- `scripts/ui/combat_hud.gd`
- `scripts/ui/card_ui.gd`

### Role 4 — Dungeon Progression and Integration Developer

**Aayush Lohani**

Responsible for dungeon progression, encounter management, and integration between the major game systems.

Primary responsibilities and integrated contributions include:

- Dungeon encounter sequencing
- Regular enemy, elite, rest, and boss encounters
- Dungeon run-state management
- Transitions between combat and rewards
- Carrying player health and deck changes between encounters
- Rest-area decisions
- Final boss progression
- Run completion, defeat, and restart handling
- Integration feedback and testing

Important files:

- `scripts/dungeon/encounter_manager.gd`
- `scripts/dungeon/run_manager.gd`
- `scenes/dungeon/run_manager.tscn`

The final integrated branch also contains changes made during cross-role integration. File ownership does not imply that only one team member contributed to a particular file.

## 4. Game Architecture

The game is organized into interconnected systems.

### Main Menu

The application starts at:

`scenes/ui/main_menu.tscn`

The main menu provides access to starting a new run, settings, and quitting the application.

Selecting New Game initializes the dungeon run manager.

### Dungeon Run Manager

The Run Manager coordinates the overall dungeon experience.

Its responsibilities include:

1. Creating the player's starting deck.
2. Initializing player health and run progress.
3. Determining the current dungeon encounter.
4. Starting battles through the Combat HUD.
5. Processing battle outcomes.
6. Offering rewards after applicable victories.
7. Handling rest areas and card upgrades.
8. Advancing to the next encounter.
9. Displaying victory or defeat results.

### Encounter Manager

The Encounter Manager stores encounter definitions and creates enemy instances.

It determines enemy statistics, encounter types, and enemy action patterns.

### Combat System

The combat system manages turn order, energy, card effects, health, block, status effects, and enemy actions.

### Card and Deck System

The card system supplies the player's cards and manages their movement through draw, hand, discard, and exhaust piles.

### Combat HUD

The Combat HUD presents the battle state to the player and forwards player interactions to the combat system.

### Overall Gameplay Flow

```text
Main Menu
    |
    v
Start New Run
    |
    v
Run Manager
    |
    v
Encounter Manager
    |
    +---- Regular Battle
    |
    +---- Elite Battle
    |
    +---- Rest Area
    |
    +---- Final Boss
    |
    v
Combat HUD / Combat System
    |
    v
Battle Result
    |
    +---- Defeat ---> Run Ends
    |
    +---- Victory
              |
              +---- Rewards / Progression
              |
              v
         Next Encounter
              |
              v
         Dungeon Completion
```

## 5. Dungeon Progression

The latest integrated encounter configuration contains nine encounters.

| Encounter | Name | Type |
|---|---|---|
| 1 | Dungeon Slime | Regular Battle |
| 2 | Cave Rat | Regular Battle |
| 3 | Armored Sentinel | Elite Battle |
| 4 | Rest Area | Rest |
| 5 | Skeleton Guard | Regular Battle |
| 6 | Venomfang | Elite Battle |
| 7 | Crypt Knight | Regular Battle |
| 8 | Abyssal Champion | Elite Battle |
| 9 | Dungeon Warden | Final Boss |

### Elite Enemies

Three elite encounters provide more challenging battles.

**Armored Sentinel** uses blocking, attacks, and Strength buffs.

**Venomfang** uses attacks, Weak debuffs, and blocking.

**Abyssal Champion** uses attacks, Vulnerable debuffs, Strength buffs, and blocking.

Elite victories offer card rewards with a guaranteed Legendary option when an eligible Legendary card is available.

### Final Boss

The Dungeon Warden has two phases.

**Phase 1 — Dungeon Warden**

- 85 HP
- Base attack damage of 13
- Attack, block, and buff actions

**Phase 2 — Dungeon Warden - Awakened**

- 110 HP
- Base attack damage of 17
- Additional defensive and offensive actions
- Strength buffs and Vulnerable debuffs

Defeating the first phase advances the boss encounter to its second phase.

Defeating the second phase completes the dungeon run.

### Rest Area

The Rest Area allows the player to choose between:

- Recovering 20 HP, limited by maximum health.
- Upgrading an eligible card in the deck.

## 6. Card and Deck System

Cards are defined through structured data and loaded into the game by the card system.

The project includes a 128-card alpha set, with supporting rules and keywords.

Cards have properties such as:

- Name and identifier
- Energy cost
- Card type
- Rarity
- Effects
- Upgrade information
- Special flags and keywords

### Card Types

**Attack:** Primarily deals damage.

**Skill:** Provides defensive, utility, healing, or other effects.

**Power:** Provides an ongoing effect during combat.

### Card Rarities

The supported rarities include:

- Common
- Uncommon
- Rare
- Legendary

Legendary cards have special reward and uniqueness rules.

### Card Piles

The system manages:

- Draw pile
- Hand
- Discard pile
- Exhaust pile
- Powers in play

The maximum hand size is 10 cards.

When necessary, cards from the discard pile can be reshuffled into the draw pile.

### Starting Deck

The documented starting deck contains 10 cards:

| Card | Quantity |
|---|---|
| Strike | 5 |
| Defend | 4 |
| Lantern Bash | 1 |

The player's starting maximum health is 70 HP.

## 7. Combat System

Combat is turn-based.

The player uses cards to attack, defend, and apply effects while enemies perform actions according to their intentions.

### Energy

Energy limits the number and combination of cards a player can use during a turn.

The standard turn energy is 3.

### Health and Block

Health represents remaining survivability.

Block absorbs applicable incoming damage.

Player health carries between dungeon encounters, making defensive decisions important throughout a run.

### Enemy Intentions

Enemies can display intentions such as:

- Attack
- Block
- Buff
- Debuff

These intentions allow players to anticipate enemy actions and plan their turns.

### Status Effects

The combat implementation supports effects including:

- Strength
- Weak
- Vulnerable
- Poison
- Other card-specific effects

### Card Retention and Drawing

The integrated gameplay updates include retaining unused cards between turns and supporting manual discarding.

The updated card-draw balance is:

| Turn | Cards Drawn | Probability |
|---|---|---|
| First turn | 5 | Guaranteed |
| Subsequent turns | 1 | 35% |
| Subsequent turns | 2 | 50% |
| Subsequent turns | 3 | 15% |

Manual discarding does not itself grant additional energy or replacement cards.

These changes were introduced to reduce the advantage of repeatedly drawing large hands.

## 8. Rewards and Deck Progression

After applicable battle victories, the player is presented with card rewards.

The reward generator selects cards according to rarity rules and eligibility restrictions.

The configured standard rarity probabilities are:

| Rarity | Probability |
|---|---|
| Common | 60% |
| Uncommon | 31% |
| Rare | 7% |
| Legendary | 2% |

Elite victories guarantee a Legendary reward option when an eligible card is available.

The reward system also supports duplicate-card decisions and card upgrades.

Players may skip rewards when permitted.

Deck changes persist throughout the current dungeon run.

## 9. User Interface

The user interface connects the underlying gameplay systems to player actions.

### Main Menu

Provides New Game, Settings, and Quit options.

### Settings Menu

Provides audio controls for Master, Music, and SFX volume.

### Combat HUD

Displays information including:

- Player HP
- Player block
- Available energy
- Enemy HP
- Enemy block
- Enemy intentions
- Cards in hand
- End Turn control
- Discard Mode control

### Card Interface

Displays card information and supports card selection and interaction.

### Dungeon and Reward Screens

The Run Manager displays encounter introductions, reward choices, rest-area actions, and run-completion results.

## 10. Project Directory Structure

```text
Dungeon Deck/
|
|-- Doc/
|   |-- README.md
|
|-- data/
|   |-- cards.json
|   |-- keywords.json
|   |-- rules.json
|
|-- docs/
|   |-- CARD_SYSTEM.md
|   |-- design/
|
|-- scenes/
|   |-- dungeon/
|   |-- ui/
|
|-- scripts/
|   |-- cards/
|   |-- combat/
|   |-- dungeon/
|   |-- ui/
|
|-- tests/
|
|-- tools/
|
|-- team-feedback/
|
|-- web-export/
|
|-- project.godot
|-- README.md
|-- HOW_TO_PLAY.md
|-- VISION.md
|-- STAKEHOLDERS.md
```

## 11. Installation and Running the Game

### Requirements

- Godot 4.7-compatible editor
- A computer capable of running Godot
- Git, if cloning the repository

### Instructions

1. Clone or download the project repository.
2. Open Godot.
3. Import the project's `project.godot` file.
4. Allow Godot to import project resources.
5. Run the project using the Play Project button.
6. Select New Game to begin the dungeon.

The configured starting scene is:

`res://scenes/ui/main_menu.tscn`

### GitHub Repository

https://github.com/Deck-Building-Card-Game-Mobile/DeckBulidinggame-

## 12. Testing and Validation

The repository includes automated tests covering multiple systems, including:

- Card data
- Deck and card piles
- Card effects during combat
- Turn order
- Dungeon runs
- Card balance and simulations

The test runner is located at:

`tests/run_tests.gd`

A standard headless test command is:

```powershell
godot --headless --path . --script res://tests/run_tests.gd
```

The integrated project was also checked using Godot 4.7.2 in headless editor mode.

The latest reported editor initialization completed without script errors.

**Validation limitation:** A successful editor check does not establish that every gameplay path has passed testing. A complete nine-encounter playthrough, all elite battles, both boss phases, and final reward behavior have not been independently verified as part of the final integration.

## 13. Development and Integration History

The project was developed collaboratively, with different team members responsible for separate but interconnected systems.

Development included:

1. Establishing the dungeon roguelike deck-building concept.
2. Defining team roles and system responsibilities.
3. Implementing card data, deck mechanics, and combat rules.
4. Building the main menu, settings, and combat interface.
5. Connecting player interactions to the combat system.
6. Developing dungeon encounters and run progression.
7. Integrating rewards, card upgrades, and persistent run health.
8. Adjusting card retention, discarding, and drawing behavior.
9. Expanding the dungeon configuration from five to nine encounters.
10. Adding three elite enemies and a two-phase final boss.
11. Resolving script integration errors and performing a Godot editor compilation check