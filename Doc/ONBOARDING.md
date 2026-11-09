# Dungeon Deck â€” Complete Developer and Codebase Onboarding Guide

**From Zero Programming Experience to Understanding, Maintaining, and Improving Dungeon Deck**

**Game engine:** Godot 4
**Programming language:** GDScript
**Project repository:** https://github.com/Deck-Building-Card-Game-Mobile/DeckBulidinggame-
**Original integrated version:** Commit `ee1349d`
**Audience:** New students, beginner programmers, experienced developers, and future maintainers

---

# 1. Welcome

## 1.1 Purpose of This Document

Welcome to Dungeon Deck!

This guide is intended for anyone who wants to understand, modify, maintain, debug, or expand the project.

**No previous programming experience is required.**

This is not simply an installation guide or a description of what the game does. It is intended to teach developers how the project is programmed, how its systems communicate, and how to contribute new functionality.

The guide combines two learning goals:

**Beginner programming education**

Learn how to write GDScript, use the Godot engine, understand programming concepts, and create simple game functionality.

**Project-specific technical onboarding**

Understand the actual Dungeon Deck source code, its architecture, important functions, dependencies, gameplay data, and modification procedures.

By the end, a new developer should be able to:

- Read and understand basic GDScript.
- Navigate the Godot editor.
- Create scenes, nodes, scripts, and signals.
- Understand the project's main classes.
- Trace a player action through multiple scripts.
- Understand the card, combat, dungeon, and interface systems.
- Identify where gameplay behavior is implemented.
- Add or modify cards and enemies.
- Extend existing systems without duplicating logic.
- Debug errors and investigate unexpected behavior.
- Run tests and verify changes.
- Contribute safely to the repository.

For general project documentation, development history, and team responsibilities, see `Doc/README.md`.

## 1.2 How to Use This Guide

The guide is organized into progressive parts.

| Part | Subject | Intended audience |
|---|---|---|
| 1 | Getting started | Everyone |
| 2 | Programming fundamentals | Beginners |
| 3 | GDScript and Godot fundamentals | Beginners |
| 4 | Project architecture | Everyone |
| 5 | Detailed source-code walkthrough | Everyone |
| 6 | How the systems connect | Everyone |
| 7 | Modifying and extending the game | Contributors |
| 8 | Debugging and testing | Contributors |
| 9 | Development workflow and maintenance | Contributors |
| 10 | Reference material and learning exercises | Everyone |

Experienced developers can begin with Part 4.

New programmers should begin with Part 2 and complete the exercises before attempting substantial changes.

---

# Part 1 â€” Getting Started

## 2. What Is Dungeon Deck?

Dungeon Deck is a turn-based dungeon roguelike deck-building game.

The player progresses through a sequence of encounters, fights enemies using cards, collects rewards, upgrades their deck, and attempts to defeat the final boss.

The integrated dungeon contains nine encounters:

| Encounter | Name | Type |
|---|---|---|
| 1 | Dungeon Slime | Regular battle |
| 2 | Cave Rat | Regular battle |
| 3 | Armored Sentinel | Elite |
| 4 | Rest Area | Rest |
| 5 | Skeleton Guard | Regular battle |
| 6 | Venomfang | Elite |
| 7 | Crypt Knight | Regular battle |
| 8 | Abyssal Champion | Elite |
| 9 | Dungeon Warden | Two-phase boss |

The player begins with 70 maximum HP and a starter deck containing five Strike cards, four Defend cards, and one Lantern Bash.

The game has multiple systems that work together to create this experience.

The main systems are:

- User interface
- Dungeon progression
- Combat
- Cards and decks
- Enemies
- Rewards
- Game rules

Understanding how those systems communicate is the primary goal of this guide.

## 3. Required Software

### 3.1 Godot

Godot is the game engine used to develop and run Dungeon Deck.

The original integrated project was checked using Godot 4.7.2.

Download a compatible Godot 4 editor from:

https://godotengine.org/download/

### 3.2 Visual Studio Code

Visual Studio Code is a text editor that can be used to read and modify GDScript files.

https://code.visualstudio.com/

It is optional because Godot has a built-in script editor.

For beginners, the Godot editor is particularly useful because it provides direct access to scenes, nodes, signals, and scripts.

### 3.3 Git

Git is used to track changes and collaborate on the project.

https://git-scm.com/

You do not need to understand every Git command immediately, but you should learn the basic workflow before submitting changes.

## 4. Downloading and Opening the Project

Clone the repository:

```powershell
git clone https://github.com/Deck-Building-Card-Game-Mobile/DeckBulidinggame-.git
```

Enter the project directory:

```powershell
cd DeckBulidinggame-
```

The original integrated handoff was developed on:

```powershell
git switch feature/ui-development
```

Future contributors should confirm the team's current development branch before starting work.

### Open in Godot

1. Launch Godot.
2. Select **Import**.
3. Find the repository folder.
4. Select `project.godot`.
5. Open the project.
6. Wait for resources to finish importing.
7. Press **F5** to run the game.

The main scene is:

`res://scenes/ui/main_menu.tscn`

### Open in VS Code

From the project directory:

```powershell
code .
```

This opens the entire repository.

---

# Part 2 â€” Programming Fundamentals for Complete Beginners

## 5. What Is Programming?

Programming means writing instructions that a computer executes.

For example, when a player clicks an attack card, the game needs instructions to:

1. Detect the click.
2. Identify the card.
3. Check whether the player can use it.
4. Subtract energy.
5. Apply the card's effects.
6. Update the enemy.
7. Refresh the interface.
8. Check whether combat has ended.

These instructions are written using a programming language.

Dungeon Deck uses **GDScript**, Godot's scripting language.

## 6. Your First Program

Create a temporary scene with a Node, attach a script, and enter:

```gdscript
extends Node

func _ready() -> void:
    print("Hello, Dungeon Deck!")
```

Run the scene using **F6**.

Expected output:

```text
Hello, Dungeon Deck!
```

### Understanding the Code

`extends Node` means the script inherits from Godot's Node class.

`func` declares a function.

`_ready()` is automatically called when the node is ready.

`-> void` means the function does not return a value.

`print()` displays text in the Output panel.

The indented line belongs to the function.

**Important:** GDScript uses indentation to organize code. Incorrect indentation can cause errors.

## 7. Variables

Variables store information.

```gdscript
var health = 70
var player_name = "Hero"
var is_alive = true
```

Variables can change.

```gdscript
var health = 70

health = health - 10

print(health)
```

Output:

```text
60
```

### Typed Variables

Dungeon Deck frequently uses typed variables.

```gdscript
var health: int = 70
var damage: int = 10
var name: String = "Slime"
var defeated: bool = false
```

Common types:

| Type | Purpose | Example |
|---|---|---|
| `int` | Whole number | `70` |
| `float` | Decimal number | `2.5` |
| `String` | Text | `"Strike"` |
| `bool` | True or false | `true` |
| `Array` | Ordered collection | `[1, 2, 3]` |
| `Dictionary` | Key/value collection | `{"hp": 30}` |

### Constants

A constant is a value that should not be reassigned.

```gdscript
const MAX_HEALTH = 70
```

Dungeon Deck uses constants for scene paths, combat results, and other fixed definitions.

## 8. Mathematics in Code

GDScript supports ordinary arithmetic.

```gdscript
var health = 70
var damage = 12

health = health - damage

print(health)
```

Output:

```text
58
```

Operators:

| Operator | Meaning |
|---|---|
| `+` | Addition |
| `-` | Subtraction |
| `*` | Multiplication |
| `/` | Division |
| `%` | Remainder |

Game mechanics use these operations for health, energy, block, damage, and other values.

## 9. Conditions

Conditions allow a program to make decisions.

```gdscript
var health = 0

if health <= 0:
    print("Defeated")
else:
    print("Still alive")
```

Comparison operators:

| Operator | Meaning |
|---|---|
| `==` | Equal |
| `!=` | Not equal |
| `>` | Greater than |
| `<` | Less than |
| `>=` | Greater than or equal |
| `<=` | Less than or equal |

**Remember:** `=` assigns a value. `==` compares values.

### Example: Card Energy

```gdscript
var energy = 2
var card_cost = 3

if energy >= card_cost:
    print("Play card")
else:
    print("Not enough energy")
```

Output:

```text
Not enough energy
```

Dungeon Deck's Combat State uses more complete validation logic, but this illustrates the same principle.

## 10. Functions

A function is a reusable collection of instructions.

```gdscript
func calculate_damage() -> int:
    return 10 + 3
```

Call the function:

```gdscript
var damage = calculate_damage()
print(damage)
```

Output:

```text
13
```

### Parameters

Functions can receive information.

```gdscript
func calculate_damage(base: int, bonus: int) -> int:
    return base + bonus
```

Call:

```gdscript
print(calculate_damage(10, 5))
```

Output:

```text
15
```

### Return Values

`return` sends a value back to the code that called the function.

```gdscript
func is_defeated(health: int) -> bool:
    return health <= 0
```

### Questions to Ask When Reading a Function

- What is its name?
- What parameters does it receive?
- What does it calculate or modify?
- Does it call another function?
- What does it return?
- Who calls it?

These questions are useful throughout the Dungeon Deck source code.

## 11. Arrays

Arrays store ordered collections.

```gdscript
var enemies = ["Slime", "Rat", "Skeleton"]
```

Access an item:

```gdscript
print(enemies[0])
```

Output:

```text
Slime
```

Array indices begin at zero.

Add an item:

```gdscript
enemies.append("Guardian")
```

Count items:

```gdscript
print(enemies.size())
```

Dungeon Deck uses arrays for cards, enemies, and dungeon encounters.

## 12. Loops

Loops repeat instructions.

```gdscript
var enemies = ["Slime", "Rat", "Skeleton"]

for enemy in enemies:
    print(enemy)
```

Output:

```text
Slime
Rat
Skeleton
```

Another example:

```gdscript
for i in range(3):
    print(i)
```

Output:

```text
0
1
2
```

Loops are useful for processing multiple cards or enemies.

## 13. Dictionaries

Dictionaries store information using keys.

```gdscript
var enemy = {
    "name": "Dungeon Slime",
    "hp": 30,
    "damage": 6
}
```

Read a value:

```gdscript
print(enemy["hp"])
```

Output:

```text
30
```

Change a value:

```gdscript
enemy["hp"] = 40
```

Dungeon Deck uses dictionaries extensively in encounter definitions and enemy intentions.

## 14. Classes and Objects

A class is a blueprint for creating objects.

Example:

```gdscript
class_name PracticeEnemy
extends RefCounted

var health: int = 30
var damage: int = 6

func attack() -> int:
    return damage
```

Create an object:

```gdscript
var enemy = PracticeEnemy.new()

print(enemy.health)
print(enemy.attack())
```

Output:

```text
30
6
```

### What Is an Object?

An object is an individual instance of a class.

A class describes the general behavior.

An object contains its own data.

Dungeon Deck uses classes such as:

- `Deck`
- `CardInstance`
- `CardData`
- `CombatState`
- `Combatant`
- `Enemy`

### Inheritance

Inheritance allows one class to reuse behavior from another.

For example, `Enemy` extends `Combatant`.

This means an Enemy inherits common combat functionality and adds enemy-specific behavior.

### `class_name`

`class_name` makes a class accessible elsewhere in GDScript.

### `static func`

A static function belongs to the class rather than an individual object.

For example:

```gdscript
EncounterManager.create_enemy(0)
```

This calls the function directly on the Encounter Manager class.

### `RefCounted`

`RefCounted` is a Godot base class for objects whose lifetime is managed through reference counting.

Many of Dungeon Deck's nonvisual gameplay classes extend `RefCounted`.

They do not need to exist as nodes in the scene tree.

## 15. Comments

Comments are explanations written for developers.

```gdscript
# The player's starting health
var health = 70
```

Godot ignores comments when executing code.

Use comments to explain decisions or complicated behavior.

---

# Part 3 â€” Learning Godot

## 16. Scenes and Nodes

Godot organizes games using scenes and nodes.

A scene contains nodes arranged in a hierarchy.

Example:

```text
MainMenu (Control)
    |
    +-- TitleLabel (Label)
    |
    +-- NewGameButton (Button)
    |
    +-- SettingsButton (Button)
```

A scene defines what exists.

A script defines behavior.

Dungeon Deck uses:

`scenes/ui/main_menu.tscn`

for the Main Menu scene.

And:

`scripts/ui/main_menu.gd`

for its behavior.

## 17. Important Node Types

| Node | Purpose |
|---|---|
| `Node` | Basic nonvisual node |
| `Control` | Base class for UI elements |
| `Button` | Clickable interface button |
| `Label` | Displays text |
| `VBoxContainer` | Arranges children vertically |
| `HBoxContainer` | Arranges children horizontally |
| `PanelContainer` | UI panel container |
| `ColorRect` | Colored rectangle |
| `ScrollContainer` | Scrollable interface region |

The project uses many of these node types in its menus and combat interface.

## 18. The Scene Tree

The scene tree is the hierarchy of active nodes.

A node can have parents and children.

For example:

```gdscript
add_child(card_ui)
```

adds a child node.

```gdscript
queue_free()
```

schedules a node for removal.

Dungeon Deck uses these operations when creating the Run Manager, displaying interfaces, and removing old screens.

## 19. `_ready()`, `_process()`, and `_input()`

### `_ready()`

```gdscript
func _ready() -> void:
    print("Ready")
```

Runs when the node is ready in the scene tree.

### `_process(delta)`

```gdscript
func _process(delta: float) -> void:
    pass
```

Runs every rendered frame.

`delta` represents the elapsed time since the previous frame.

### `_input(event)`

Can receive input events.

For ordinary UI buttons, using the Button's `pressed` signal is often simpler.

Dungeon Deck's turn-based gameplay is primarily driven by player actions and signals.

## 20. Node References

Example:

```gdscript
@onready var health_label: Label = $HealthLabel
```

`@onready` delays the assignment until the node is ready.

`$HealthLabel` identifies a child node.

Change its text:

```gdscript
health_label.text = "HP: 70"
```

Dungeon Deck's Combat HUD includes a reference such as:

```gdscript
@onready var player_health_label: Label = $PlayerPanel/PlayerInfo/HealthLabel
```

This path must match the node hierarchy inside the scene.

**Warning:** Renaming or moving scene nodes can break script references.

## 21. Signals

Signals allow objects to notify other objects when something happens.

Declare a signal:

```gdscript
signal enemy_defeated
```

Connect it:

```gdscript
enemy_defeated.connect(_on_enemy_defeated)
```

Emit it:

```gdscript
enemy_defeated.emit()
```

Handle it:

```gdscript
func _on_enemy_defeated() -> void:
    print("Enemy defeated!")
```

### How Signals Work in Dungeon Deck

The Combat State declares:

```gdscript
signal combat_ended(result: String)
```

When combat finishes, it emits the signal.

The Run Manager listens for it and decides what happens next.

Signals are important because they let different systems communicate without putting all functionality into one script.

## 22. Loading Scripts and Scenes

Godot supports `preload()`.

Example:

```gdscript
const CARD_SCENE = preload("res://scenes/ui/card_ui.tscn")
```

Create an instance:

```gdscript
var card_ui = CARD_SCENE.instantiate()
```

Add it:

```gdscript
add_child(card_ui)
```

The `res://` prefix refers to the project's resource directory.

## 23. Creating a Button From Scratch

Create a temporary scene with:

```text
Control
    |
    +-- TestButton (Button)
```

Attach this script to the Control:

```gdscript
extends Control

@onready var test_button: Button = $TestButton

func _ready() -> void:
    test_button.pressed.connect(_on_test_button_pressed)

func _on_test_button_pressed() -> void:
    print("Button clicked!")
```

Run the scene.

Click the button.

Expected output:

```text
Button clicked!
```

This is the same general event-driven programming concept used in the project's menus and combat controls.

---

# Part 4 â€” Dungeon Deck Architecture

## 24. The Four Main Systems

Dungeon Deck is divided into several cooperating systems.

### UI System

Displays information and receives input.

Important files:

- `scripts/ui/main_menu.gd`
- `scripts/ui/settings_menu.gd`
- `scripts/ui/combat_hud.gd`
- `scripts/ui/card_ui.gd`

### Dungeon System

Controls the overall run and encounter sequence.

Important files:

- `scripts/dungeon/run_manager.gd`
- `scripts/dungeon/encounter_manager.gd`

### Combat System

Controls turns, combatants, attacks, status effects, and battle outcomes.

Important files:

- `scripts/combat/combat_state.gd`
- `scripts/combat/combatant.gd`
- `scripts/combat/enemy.gd`
- `scripts/combat/effect_resolver.gd`

### Card System

Controls card definitions, card instances, decks, card piles, and rewards.

Important files:

- `scripts/cards/card_data.gd`
- `scripts/cards/card_instance.gd`
- `scripts/cards/card_database.gd`
- `scripts/cards/deck.gd`
- `scripts/cards/card_piles.gd`
- `scripts/cards/reward_generator.gd`
- `scripts/cards/game_rules.gd`
- `scripts/cards/keywords.gd`
- `scripts/cards/balance_calculator.gd`

## 25. Overall Execution Flow

```text
Player launches Dungeon Deck
            |
            v
        Main Menu
            |
            v
        New Game
            |
            v
       Run Manager
            |
            v
     Encounter Manager
            |
            v
     Encounter selected
            |
       +----+----+
       |         |
       v         v
     Rest      Battle
       |         |
       |         v
       |      Combat HUD
       |         |
       |         v
       |      Combat State
       |         |
       |    +----+----+
       |    |         |
       |    v         v
       |  Cards     Enemies
       |    |         |
       |    +----+----+
       |         |
       |         v
       |    Battle result
       |         |
       |         v
       |      Run Manager
       |         |
       |    +----+----+
       |    |         |
       |    v         v
       |  Rewards   Defeat
       |    |
       +----+
            |
            v
     Next encounter
            |
            v
       Final boss
            |
            v
      Run completion
```

## 26. Source Code Directory Guide

```text
DeckBulidinggame-/
|
+-- project.godot
|
+-- data/
|   +-- cards.json
|   +-- keywords.json
|   +-- rules.json
|
+-- scenes/
|   +-- ui/
|   |   +-- main_menu.tscn
|   |   +-- settings_menu.tscn
|   |   +-- combat_hud.tscn
|   |   +-- card_ui.tscn
|   |
|   +-- dungeon/
|       +-- run_manager.tscn
|
+-- scripts/
|   +-- ui/
|   +-- dungeon/
|   +-- combat/
|   +-- cards/
|
+-- tests/
|   +-- run_tests.gd
|   +-- test_*.gd
|
+-- docs/
|   +-- CARD_SYSTEM.md
|   +-- design/
|
+-- Doc/
|   +-- README.md
|   +-- ONBOARDING.md
|
+-- README.md
+-- HOW_TO_PLAY.md
+-- VISION.md
+-- STAKEHOLDERS.md
```

The `Doc/` directory is the intended location for the two new handoff documents.

The root README and existing documentation may describe earlier versions of the game. When descriptions disagree, inspect the current implementation and tests.

---

# Part 5 â€” Detailed Source Code Walkthrough

## 27. Main Menu: Where the Game Begins

Open:

`scripts/ui/main_menu.gd`

Find:

```gdscript
func _on_new_game_pressed() -> void:
```

This function runs when the player selects New Game.

The actual implementation includes:

```gdscript
var run_manager := Control.new()

run_manager.set_script(RUN_MANAGER_SCRIPT)

get_tree().root.add_child(run_manager)
```

### Line-by-Line Explanation

`Control.new()` creates a new Control node.

`set_script()` attaches the Run Manager script.

`get_tree().root` accesses the scene tree's root node.

`add_child()` adds the Run Manager to the active scene tree.

When the Run Manager enters the tree, Godot calls its `_ready()` function.

The Main Menu then removes itself with `queue_free()`.

### Why This Matters

The Main Menu does not manage combat directly.

Its job is to transition into the dungeon system.

If New Game stops working, inspect:

1. The button's signal connection.
2. `_on_new_game_pressed()`.
3. `RUN_MANAGER_SCRIPT`.
4. Whether the Run Manager is added to the scene tree.
5. Whether the Run Manager initializes successfully.

## 28. Run Manager: Controlling the Dungeon

Open:

`scripts/dungeon/run_manager.gd`

This is one of the most important scripts in the project.

### Important Variables

```gdscript
var deck: Deck
var current_hp: int = 0
var encounter_index: int = 0
var status: String = "not_started"

var rng := RandomNumberGenerator.new()

var combat_hud: Control

var boss_phase: int = 1
```

| Variable | Meaning |
|---|---|
| `deck` | Player's deck throughout the run |
| `current_hp` | Health carried between encounters |
| `encounter_index` | Current encounter position |
| `status` | Current run state |
| `rng` | Random number generator |
| `combat_hud` | Active combat interface |
| `boss_phase` | Current final boss phase |

### `start_new_run()`

```gdscript
func start_new_run() -> void:
```

This function initializes a new dungeon run.

It creates the starter deck using `Deck.create_starter()`, initializes health through the game rules, resets progression, and displays the first encounter.

**Where to modify starting conditions:** Begin here and inspect the associated GameRules and Deck functions.

### `show_encounter()`

```gdscript
func show_encounter() -> void:
```

This determines what the player sees next.

It checks the run's state and current encounter.

A rest encounter leads to `show_rest()`.

A battle encounter leads to `show_intro()`.

### `start_battle()`

```gdscript
func start_battle() -> void:
```

This function connects dungeon progression to combat.

It creates the current enemy using:

```gdscript
var enemy: Enemy = EncounterManager.create_enemy(
    encounter_index,
    boss_phase
)
```

It then starts the battle through the Combat HUD:

```gdscript
combat_hud.start_dungeon_battle(
    deck,
    current_hp,
    [enemy],
    rng
)
```

The Run Manager supplies the information required for combat.

It does not calculate all combat damage itself.

### `_on_battle_finished()`

```gdscript
func _on_battle_finished(result: String) -> void:
```

This receives the result of a battle.

The Run Manager obtains the player's remaining health and prepares to resolve the outcome.

### `resolve_battle()`

```gdscript
func resolve_battle(result: String) -> void:
```

This handles what happens after combat.

Depending on the outcome, it may:

- End the run after defeat.
- Transition to the second boss phase.
- Complete the dungeon.
- Display card rewards.
- Continue progression.

### `show_rewards()`

Displays reward choices.

### `select_reward()`

Processes the selected reward.

### Duplicate Reward Handling

The integrated Run Manager also contains:

- `show_duplicate_reward_choice()`
- `add_duplicate_reward()`
- `upgrade_duplicate_reward()`
- `complete_reward_selection()`
- `get_upgradable_copies()`
- `get_grouped_upgradable_cards()`

These functions handle reward interactions involving duplicate cards and upgrade choices.

If modifying how duplicate rewards behave, inspect these functions together rather than changing only the initial reward selection.

### `show_rest()`

Displays the rest area.

The integrated rest area allows the player to heal or upgrade a card.

Related functions include:

```gdscript
rest_and_continue()
upgrade_group_and_continue()
```

### `advance_encounter()`

```gdscript
func advance_encounter() -> void:
```

The important operations are:

```gdscript
encounter_index += 1
boss_phase = 1
show_encounter()
```

The encounter index increases, the boss phase resets, and the next encounter is displayed.

### `finish_run()`

```gdscript
func finish_run(won: bool) -> void:
```

Handles run completion or defeat.

### Additional UI Helpers

The Run Manager also includes functions such as:

```gdscript
clear_screen()
create_panel()
add_text()
add_button()
```

These construct and update the run's interface.

**Important:** The Run Manager is responsible for both progression and some dynamically constructed dungeon UI.

## 29. Encounter Manager: Defining the Dungeon

Open:

`scripts/dungeon/encounter_manager.gd`

This class defines the encounter sequence and constructs enemies.

### Encounter Data

Near the top:

```gdscript
const ENCOUNTERS: Array[Dictionary] = [
    ...
]
```

Each dictionary represents an encounter.

The first encounter is:

```gdscript
{
    "kind": "battle",
    "name": "Dungeon Slime",
    "hp": 30,
    "damage": 6
}
```

### Understanding the Dictionary

`kind` identifies the encounter type.

`name` is the displayed enemy name.

`hp` is the enemy's health.

`damage` is used when constructing its attacks.

Some encounters include additional properties such as `block`.

### Encounter Indexing

Arrays begin at zero.

Therefore:

| Array index | Encounter |
|---|---|
| 0 | Dungeon Slime |
| 1 | Cave Rat |
| 2 | Armored Sentinel |
| 3 | Rest Area |
| 4 | Skeleton Guard |
| 5 | Venomfang |
| 6 | Crypt Knight |
| 7 | Abyssal Champion |
| 8 | Dungeon Warden |

### Encounter Lookup Functions

Important functions include:

```gdscript
encounter_count()
has_encounter(index)
get_encounter(index)
is_rest(index)
is_boss(index)
is_elite(index)
is_battle(index)
```

These help other systems inspect encounter definitions.

### Creating an Enemy

Find:

```gdscript
static func create_enemy(
    index: int,
    boss_phase: int = 1
) -> Enemy:
```

This function:

1. Checks the encounter.
2. Reads the configuration.
3. Determines enemy statistics.
4. Handles second-phase boss statistics when needed.
5. Creates an appropriate action sequence.
6. Constructs an Enemy object.
7. Returns the Enemy.

### Enemy Action Functions

The Encounter Manager includes:

```gdscript
create_regular_actions()
create_elite_actions()
create_boss_actions()
```

These construct enemy intention sequences.

An attack intention can be represented by a dictionary containing fields such as:

```gdscript
{
    "type": Enemy.INTENT_ATTACK,
    "amount": damage,
    "hits": 1
}
```

The Enemy class stores intentions, and the Combat State executes them.

### Adding an Encounter

To add an encounter:

1. Inspect the existing `ENCOUNTERS` schema.
2. Add a dictionary with the appropriate fields.
3. Choose the encounter type.
4. Determine its statistics.
5. Reuse an existing action pattern or implement a new one.
6. Check special encounter-index assumptions.
7. Verify rewards, progression, and boss behavior.
8. Update tests and documentation.

**Warning:** Inserting encounters changes the indices of later encounters. Review all logic that depends on encounter order.

## 30. Combat HUD: Connecting Player Input to Combat

Open:

`scripts/ui/combat_hud.gd`

This script controls the combat interface.

It displays player health, energy, cards, enemies, and combat information.

### Node References

The script contains references such as:

```gdscript
@onready var player_health_label: Label = $PlayerPanel/PlayerInfo/HealthLabel
```

These paths correspond to nodes inside:

`scenes/ui/combat_hud.tscn`

### `_ready()`

The HUD initializes its combat-related state and connects signals.

It supports both standalone testing and dungeon integration.

In dungeon mode, the Run Manager provides the actual deck, health, enemies, and random number generator.

### `start_dungeon_battle()`

```gdscript
func start_dungeon_battle(
    run_deck: Deck,
    player_hp: int,
    enemies: Array,
    run_rng: RandomNumberGenerator
) -> void:
```

This passes the run's information into the Combat State.

The important call is:

```gdscript
combat.start(
    run_deck,
    player_hp,
    enemies,
    run_rng
)
```

### `_on_card_pressed()`

```gdscript
func _on_card_pressed(card: CardInstance) -> void:
```

This handles a card selection.

The function must account for different interaction modes.

For example, the player may be selecting a card to discard rather than playing it.

For ordinary card play, the HUD calls:

```gdscript
combat.play_card(card, target_index)
```

### `_on_end_turn_pressed()`

```gdscript
func _on_end_turn_pressed() -> void:
```

This checks whether ending the turn is permitted and calls the Combat State's turn-ending logic.

### Updating the HUD

Important functions include:

```gdscript
_refresh_hud()
_refresh_card_hand()
_format_enemy_intent()
```

These update the visible interface.

### Combat Signals

The HUD contains handlers such as:

```gdscript
_on_turn_started()
_on_energy_changed()
_on_card_played()
_on_card_rejected()
_on_damage_dealt()
_on_discard_requested()
_on_combat_ended()
```

These handlers respond to changes in the Combat State.

### When to Modify the HUD

Modify this file when changing:

- Card clicking and selection.
- Displayed health or energy.
- Combat buttons.
- Enemy intention presentation.
- Card hand rendering.
- Discard controls.
- Combat result screens.
- UI feedback.

Do not duplicate the Combat State's core rules in the HUD.

## 31. Combat State: The Battle Rules Engine

Open:

`scripts/combat/combat_state.gd`

This is the central rules engine for individual battles.

### Important Variables

```gdscript
var player: Combatant
var enemies: Array[Enemy] = []
var piles: CardPiles

var turn: int = 0
var energy: int = 0

var result: String = RESULT_NONE
```

### Starting Combat

Find:

```gdscript
func start(
```

This initializes the battle.

It creates the player's combatant, stores the enemies, creates combat card piles, resets combat state, and starts the first turn.

### Turn Management

Important functions include:

```gdscript
_start_player_turn()
end_player_turn()
_start_enemy_turn()
next_enemy_action()
_end_round()
```

These functions coordinate the player and enemy phases.

### Playing a Card

Find:

```gdscript
func play_card(
    card: CardInstance,
    target_index: int = -1
) -> bool:
```

The actual implementation begins by checking:

```gdscript
var reason := why_cannot_play(card, target_index)
```

If the card cannot be played, it emits a rejection signal and returns `false`.

If the card is valid, the system identifies the target.

It removes the card from the hand:

```gdscript
piles.take_from_hand(card)
```

It spends energy:

```gdscript
energy -= card.get_cost()
```

It emits the energy update:

```gdscript
energy_changed.emit(energy)
```

Then it executes the card effect:

```gdscript
EffectResolver.resolve(
    self,
    card,
    target,
    attack_bonus
)
```

After the effect, the card is sent to its destination:

```gdscript
piles.send_played_card(card)
```

The Combat State emits `card_played` and checks whether the battle has ended.

### Special Attack Behavior

The integrated code also handles certain additional attack effects, such as repeating an attack through an echo mechanic.

When modifying card execution, read the complete `play_card()` function rather than assuming every card resolves only once.

### Card Validation

Important functions include:

```gdscript
why_cannot_play()
can_play()
```

These determine whether a card is legal to play.

### Discarding

Important functions include:

```gdscript
choose_discard()
manually_discard_card()
request_discard()
```

These coordinate card-discard interactions.

### Damage

Important functions include:

```gdscript
calculate_attack_damage()
deal_attack_damage()
_direct_damage()
```

These implement damage-related behavior.

Other functions handle block and status effects.

### Combat Completion

Important functions include:

```gdscript
_check_end()
_finish()
```

When combat ends, the Combat State emits:

```gdscript
combat_ended(result)
```

The Run Manager receives the result.

## 32. Combatant and Enemy Classes

Open:

`scripts/combat/combatant.gd`

and:

`scripts/combat/enemy.gd`

### Combatant

A Combatant represents an entity participating in combat.

It provides shared functionality for health, block, and status effects.

### Enemy

An Enemy extends Combatant.

It adds enemy-specific behavior, including intentions.

Important fields include:

```gdscript
var intents: Array = []
var intent_index: int = 0
```

### `current_intent()`

Returns the enemy's current intended action.

### `advance_intent()`

Moves the enemy to the next intention.

### Responsibility Breakdown

| Component | Responsibility |
|---|---|
| Encounter Manager | Defines enemy configuration and action patterns |
| Enemy | Stores enemy state and intentions |
| Combat State | Executes actions and combat rules |
| Combat HUD | Displays enemy information |

If an enemy behaves incorrectly, determine which of these responsibilities is involved before editing code.

## 33. Card Database: Loading Card Definitions

Open:

`scripts/cards/card_database.gd`

The card definitions are stored in:

`data/cards.json`

### `_ensure_loaded()`

```gdscript
static func _ensure_loaded() -> void:
```

Loads card definitions and caches them.

### `get_card()`

```gdscript
static func get_card(id: String) -> CardData:
```

Returns the definition associated with a card ID.

### Other Functions

```gdscript
reload()
has_card()
get_all_cards()
get_cards_by_rarity()
get_cards_by_archetype()
get_reward_pool()
```

These support card lookup and reward generation.

**Important:** If you change card JSON data, ensure the data matches the format expected by the parser.

## 34. CardData Versus CardInstance

Open:

`scripts/cards/card_data.gd`

and:

`scripts/cards/card_instance.gd`

### CardData

Represents the definition of a card.

It describes properties such as:

- Card ID.
- Name.
- Cost.
- Type.
- Rarity.
- Effects.
- Upgrade information.

Think of CardData as a blueprint.

### CardInstance

Represents one individual copy of a card.

Important fields include:

```gdscript
var uid: int
var card_id: String
var upgraded: bool = false
```

A CardInstance retrieves its definition through the Card Database.

### Why This Separation Matters

Suppose the player's deck contains five Strike cards.

They share the same underlying card definition.

However, they are separate card instances.

This allows one Strike to be upgraded without automatically upgrading every Strike.

## 35. Deck: Persistent Cards During a Run

Open:

`scripts/cards/deck.gd`

The Deck stores the player's card collection for the dungeon run.

Important operations include:

```gdscript
Deck.create_starter()
deck.add_card(card_id)
deck.remove_card(card)
deck.upgrade_card(card)
```

The Run Manager keeps the Deck between encounters.

When a player receives a reward, the selected card is added to or used to modify the persistent Deck.

## 36. CardPiles: Temporary Card Locations During Combat

Open:

`scripts/cards/card_piles.gd`

This class manages card locations during one battle.

Important collections include:

```gdscript
draw_pile
hand
discard_pile
exhaust_pile
powers_in_play
```

### Important Functions

```gdscript
draw(count)
shuffle_draw_pile()
reshuffle_discard_into_draw()
take_from_hand(card)
discard_from_hand(card)
discard_hand(retain_all)
send_played_card(card)
```

### How Combat Piles Are Created

The CardPiles implementation creates copies of the run Deck's card instances for combat.

This is important because temporary combat actions should not accidentally delete or exhaust cards from the persistent run Deck.

### Drawing Cards

The `draw()` function moves cards from the draw pile to the hand.

If the draw pile becomes empty, it can reshuffle the discard pile into the draw pile.

It also respects the maximum hand size.

### Deck Versus CardPiles

| Deck | CardPiles |
|---|---|
| Exists across encounters | Exists for a battle |
| Stores run-owned cards | Stores temporary combat copies |
| Receives card rewards | Handles drawing and discarding |
| Stores upgrades | Handles exhaust and active powers |

Confusing these two classes can cause difficult bugs.

## 37. Effect Resolver: Executing Card Effects

Open:

`scripts/combat/effect_resolver.gd`

Find:

```gdscript
static func resolve(
    combat: CombatState,
    card: CardInstance,
    target: Enemy,
    attack_bonus: int = 0
) -> void:
```

This interprets and executes the card's effects.

The Combat State decides whether a card can be played.

The Effect Resolver decides how the card's effects are applied.

### Example: Attack Card

```text
Player clicks attack card
        |
        v
CombatHUD._on_card_pressed()
        |
        v
CombatState.play_card()
        |
        v
Check play requirements
        |
        v
Remove card from hand
        |
        v
Spend energy
        |
        v
EffectResolver.resolve()
        |
        v
Combat damage operations
        |
        v
Enemy health/block updated
        |
        v
Combat outcome checked
        |
        v
HUD refreshed
```

### Adding a New Effect

Before implementing a new effect:

1. Search existing cards for similar behavior.
2. Inspect the current Effect Resolver.
3. Determine whether existing combat operations can be reused.
4. Define the effect's data format.
5. Implement any missing behavior.
6. Add tests.
7. Verify the interface reflects the effect.

Avoid duplicating combat formulas inside the UI.

## 38. Reward Generator

Open:

`scripts/cards/reward_generator.gd`

Find:

```gdscript
static func generate_choices(
    rng: RandomNumberGenerator,
    count: int = -1,
    deck: Deck = null,
    guarantee_legendary: bool = false
) -> Array[CardData]:
```

This generates eligible card reward choices.

It uses the Card Database, rarity rules, and random selection.

Passing the Deck allows reward generation to consider cards already owned by the player.

The `guarantee_legendary` parameter supports a guaranteed eligible Legendary choice when applicable.

### Reward Flow

```text
Combat victory
      |
      v
RunManager.resolve_battle()
      |
      v
RewardGenerator.generate_choices()
      |
      v
RunManager.show_rewards()
      |
      v
Player selects reward
      |
      v
RunManager.select_reward()
      |
      v
Deck updated
      |
      v
Next encounter
```

### Changing Rewards

To change rarity probabilities, inspect:

- `data/rules.json`
- `scripts/cards/game_rules.gd`
- `scripts/cards/reward_generator.gd`

To change card eligibility, inspect:

- `CardDatabase.get_reward_pool()`
- `RewardGenerator.generate_choices()`

To change the reward interface, inspect the Run Manager's reward functions.

## 39. The Two-Phase Final Boss

The final boss uses two phases.

The Run Manager tracks:

```gdscript
var boss_phase: int = 1
```

The Encounter Manager stores separate phase-two configuration values.

When the first phase is defeated, the Run Manager transitions to phase two without advancing the encounter index.

The next enemy is created using:

```gdscript
EncounterManager.create_enemy(
    encounter_index,
    boss_phase
)
```

After phase two is defeated, the run completes.

### Important Compatibility Warning

The Run Manager calls `create_enemy()` with two arguments.

Therefore, the Encounter Manager must support:

```gdscript
static func create_enemy(
    index: int,
    boss_phase: int = 1
) -> Enemy:
```

A previous integration error occurred when the function signature and its caller did not match.

When changing parameters, search for every caller before committing.

---

# Part 6 â€” How the Systems Connect

## 40. Complete New Game Flow

```text
Main Menu
    |
    v
_on_new_game_pressed()
    |
    v
Create Run Manager
    |
    v
RunManager._ready()
    |
    v
start_new_run()
    |
    +-- Create starter Deck
    |
    +-- Initialize player health
    |
    +-- Reset encounter index
    |
    +-- Reset boss phase
    |
    v
show_encounter()
```

## 41. Complete Battle Startup Flow

```text
RunManager.show_encounter()
    |
    v
show_intro()
    |
    v
start_battle()
    |
    v
EncounterManager.create_enemy()
    |
    v
Enemy object created
    |
    v
Combat HUD initialized
    |
    v
start_dungeon_battle()
    |
    v
CombatState.start()
    |
    v
Player turn begins
```

## 42. Complete Card Execution Flow

```text
Player selects card
    |
    v
CombatHUD._on_card_pressed()
    |
    v
CombatState.play_card()
    |
    +-- why_cannot_play()
    |
    +-- Select target
    |
    +-- Remove card from hand
    |
    +-- Spend energy
    |
    v
EffectResolver.resolve()
    |
    v
Apply combat effects
    |
    v
Move card to appropriate pile
    |
    v
Emit signals
    |
    v
Refresh HUD
    |
    v
Check battle outcome
```

## 43. Complete Battle Completion Flow

```text
CombatState._check_end()
    |
    v
CombatState._finish()
    |
    v
combat_ended signal
    |
    v
RunManager._on_battle_finished()
    |
    v
RunManager.resolve_battle()
    |
    +-- Defeat
    |
    +-- Rewards
    |
    +-- Boss phase transition
    |
    +-- Dungeon completion
    |
    v
advance_encounter() when appropriate
```

## 44. Important State Ownership

Different systems store different kinds of information.

| Information | Owner |
|---|---|
| Dungeon encounter position | Run Manager |
| Player health between battles | Run Manager |
| Persistent card collection | Deck |
| Current hand and draw pile | CardPiles |
| Current turn and energy | Combat State |
| Enemy combat state | Enemy / Combatant |
| Card definitions | Card Database / CardData |
| Card upgrade state | CardInstance |
| Displayed interface | Combat HUD |
| Reward selection | Reward Generator and Run Manager |

Before modifying a variable, determine which class owns it.

---

# Part 7 â€” Learning to Modify and Extend the Project

## 45. Exercise 1: Change an Enemy's Health

Open:

`scripts/dungeon/encounter_manager.gd`

Find the Dungeon Slime:

```gdscript
{
    "kind": "battle",
    "name": "Dungeon Slime",
    "hp": 30,
    "damage": 6
}
```

Change:

```gdscript
"hp": 30
```

to:

```gdscript
"hp": 35
```

Save the file.

Run the game.

Start a new run and observe the enemy's health.

### What You Learned

The Encounter Manager stores enemy configuration.

The Run Manager requests the enemy.

The Encounter Manager creates it.

The Combat State receives it.

The Combat HUD displays it.

Restore the original value unless you intend to keep the change.

## 46. Exercise 2: Write a Damage Function

Create a temporary Node script:

```gdscript
extends Node

func calculate_damage(base: int, bonus: int) -> int:
    return base + bonus

func _ready() -> void:
    var damage = calculate_damage(10, 5)
    print("Damage: ", damage)
```

Expected output:

```text
Damage: 15
```

Now improve the function:

```gdscript
func calculate_damage(base: int, bonus: int) -> int:
    var total = base + bonus

    if total < 0:
        total = 0

    return total
```

This is a beginner exercise, not a replacement for Dungeon Deck's existing combat calculations.

## 47. Exercise 3: Create a Practice Enemy Class

Create a temporary script named `practice_enemy.gd`:

```gdscript
class_name PracticeEnemy
extends RefCounted

var name: String
var health: int
var damage: int

func _init(
    enemy_name: String,
    enemy_hp: int,
    enemy_damage: int
) -> void:
    name = enemy_name
    health = enemy_hp
    damage = enemy_damage

func take_damage(amount: int) -> void:
    health = max(0, health - amount)

func is_defeated() -> bool:
    return health <= 0
```

Test it from a temporary Node script:

```gdscript
extends Node

func _ready() -> void:
    var enemy = PracticeEnemy.new(
        "Practice Slime",
        30,
        6
    )

    enemy.take_damage(10)

    print(enemy.health)
    print(enemy.is_defeated())
```

Expected output:

```text
20
false
```

This teaches classes, constructors, methods, and object state.

The real project already has an Enemy class with additional behavior.

## 48. Exercise 4: Add a New Enemy

Suppose you want to add a Stone Guardian.

Open:

`scripts/dungeon/encounter_manager.gd`

Study the existing encounter dictionaries.

An illustrative regular encounter is:

```gdscript
{
    "kind": "battle",
    "name": "Stone Guardian",
    "hp": 45,
    "damage": 9,
    "block": 4
}
```

Before adding it, confirm that its fields match the current encounter schema.

Then:

1. Choose where the encounter belongs.
2. Add the dictionary.
3. Choose an action pattern.
4. Check encounter ordering.
5. Check special boss logic.
6. Check reward progression.
7. Run tests.
8. Play the encounter manually.

If you add a new action type, you may also need to update the Combat State and the HUD's intention formatting.

## 49. Exercise 5: Add a New Card

Adding a card involves multiple systems.

### Step 1: Inspect Existing Data

Open:

`data/cards.json`

Find a card similar to the one you want.

Study its structure.

### Step 2: Add a Definition

Create a new entry following the existing JSON schema.

For a beginner, reuse an already-supported effect.

### Step 3: Understand the Loading Process

```text
cards.json
    |
    v
CardDatabase
    |
    v
CardData
    |
    v
CardInstance
    |
    v
Deck
    |
    v
CardPiles
    |
    v
CombatState
    |
    v
EffectResolver
```

### Step 4: Check Its Effect

If the effect already exists, verify that the new card uses the correct data structure.

If the effect is new, implement it in the Effect Resolver and any supporting combat methods.

### Step 5: Check Upgrades

If the card can be upgraded, verify the upgraded data and individual CardInstance behavior.

### Step 6: Check Rewards

Confirm that the card is eligible for the intended reward pool.

### Step 7: Test

Verify:

- Card loading.
- Name and cost.
- UI rendering.
- Target selection.
- Energy usage.
- Effect execution.
- Upgrade behavior.
- Card pile movement.
- Reward eligibility.

## 50. Exercise 6: Create a New UI Feature

Suppose you want to add a button that displays help information.

First, create a temporary scene with a Button and Label.

Example:

```gdscript
extends Control

@onready var help_button: Button = $HelpButton
@onready var help_label: Label = $HelpLabel

func _ready() -> void:
    help_button.pressed.connect(_on_help_pressed)

func _on_help_pressed() -> void:
    help_label.text = "Play cards to defeat enemies!"
```

Once you understand the example, inspect the real Main Menu or Combat HUD scene.

When modifying a real scene:

1. Add the required node.
2. Give it a descriptive name.
3. Reference it in the script.
4. Connect its signal.
5. Implement the behavior.
6. Test it.
7. Verify that existing controls still work.

## 51. Exercise 7: Add a New Card Mechanic

For a more advanced task, suppose you want a card that grants additional block under certain conditions.

Before coding:

1. Search existing card definitions for block effects.
2. Read their handling in `effect_resolver.gd`.
3. Identify the CombatState or Combatant methods that grant block.
4. Determine whether the new mechanic can reuse those methods.
5. Add new effect data only if needed.
6. Implement missing logic in the correct class.
7. Test different combat states.
8. Verify the HUD updates.
9. Add regression tests.

The goal is to extend existing systems rather than create duplicate implementations.

## 52. Where to Make Common Changes

| Desired change | Start here |
|---|---|
| New Game behavior | `main_menu.gd` |
| Starting health | `run_manager.gd`, `game_rules.gd`, `rules.json` |
| Starting deck | `deck.gd` |
| New enemy | `encounter_manager.gd` |
| Enemy action pattern | `encounter_manager.gd`, `enemy.gd` |
| Enemy turn execution | `combat_state.gd` |
| Card definitions | `cards.json` |
| Card loading | `card_database.gd` |
| Card effects | `effect_resolver.gd` |
| Card upgrades | `card_instance.gd`, `deck.gd`, card data |
| Drawing and discarding | `card_piles.gd`, `combat_state.gd` |
| Energy and turn rules | `combat_state.gd`, `game_rules.gd` |
| Card rewards | `reward_generator.gd`, `run_manager.gd` |
| Rest area | `run_manager.gd` |
| Boss phases | `run_manager.gd`, `encounter_manager.gd` |
| Combat UI | `combat_hud.gd`, `combat_hud.tscn` |
| Menu UI | `main_menu.gd`, `main_menu.tscn` |
| Card appearance | `card_ui.gd`, `card_ui.tscn` |

---

# Part 8 â€” Debugging and Testing

## 53. What Is Debugging?

Debugging is the process of identifying and correcting problems in code.

Examples include:

- A button does nothing.
- An enemy fails to appear.
- A card cannot be played.
- Damage is incorrect.
- A reward does not appear.
- The dungeon does not advance.
- The game produces a script error.

The best approach is to follow the actual execution path until you find where the expected behavior stops.

## 54. Using `print()`

You can temporarily print variable values.

```gdscript
print("Current HP: ", current_hp)
print("Encounter: ", encounter_index)
```

You can also check whether a function runs:

```gdscript
func example_function() -> void:
    print("Function executed")
```

Godot's Output panel displays the results.

For more complex debugging, use breakpoints and the Godot Debugger.

## 55. Debugging: New Game Does Not Start

Follow:

```text
main_menu.gd
    |
    v
_on_new_game_pressed()
    |
    v
Run Manager created
    |
    v
RunManager._ready()
    |
    v
start_new_run()
```

Check the button connection, script preload, scene tree insertion, and initialization.

## 56. Debugging: Enemy Does Not Appear

Follow:

```text
RunManager.start_battle()
    |
    v
EncounterManager.create_enemy()
    |
    v
Enemy.new()
    |
    v
CombatHUD.start_dungeon_battle()
    |
    v
CombatState.start()
```

Check the encounter index and enemy configuration.

## 57. Debugging: Card Cannot Be Played

Follow:

```text
CombatHUD._on_card_pressed()
    |
    v
CombatState.play_card()
    |
    v
why_cannot_play()
```

Check:

- Player energy.
- Target selection.
- Current turn.
- Card requirements.
- Pending discard interactions.

## 58. Debugging: Card Plays but Has No Effect

Follow:

```text
CardInstance.get_effects()
    |
    v
EffectResolver.resolve()
    |
    v
CombatState / Combatant
```

Check whether the effect data matches an implemented effect handler.

## 59. Debugging: Rewards Are Missing

Follow:

```text
RunManager.resolve_battle()
    |
    v
RewardGenerator.generate_choices()
    |
    v
RunManager.show_rewards()
```

Check reward eligibility and the available card pool.

## 60. Debugging: Dungeon Does Not Advance

Follow:

```text
CombatState.combat_ended
    |
    v
RunManager._on_battle_finished()
    |
    v
RunManager.resolve_battle()
    |
    v
Reward or boss handling
    |
    v
RunManager.advance_encounter()
```

Remember that the first boss phase should not advance the encounter index.

## 61. Reading Error Messages

Error messages often identify:

- The file containing the error.
- The line number.
- The type of error.
- What went wrong.

If a function receives the wrong number of arguments:

1. Open the function definition.
2. Read its parameters.
3. Search for its callers.
4. Compare the arguments.
5. Correct the mismatch.
6. Run the project again.

## 62. Searching the Project

In VS Code, press:

**Ctrl + Shift + F**

Search for:

```text
create_enemy
```

to find enemy creation and its callers.

Search:

```text
combat_ended
```

to find signal declarations, connections, and emissions.

Search:

```text
play_card
```

to trace card interactions.

### How to Trace a Signal

Identify:

1. Where the signal is declared.
2. Where it is connected.
3. Where it is emitted.
4. Which function receives it.

This is an essential skill for understanding Godot projects.

## 63. Automated Testing

The project includes:

`tests/run_tests.gd`

Run the test suite:

```powershell
godot --headless --path . --script res://tests/run_tests.gd
```

If Godot is not on PATH, use its full executable path.

### Script Compilation Check

```powershell
godot --headless --path . --editor --quit
```

This checks whether the project loads in headless editor mode.

**Important:** A successful compilation check does not guarantee that every gameplay path works correctly.

The final integrated version passed an editor compilation check, but a complete nine-encounter runtime playthrough was not independently verified as part of that check.

## 64. Tests to Review

The repository includes tests for several systems, including:

- `test_alpha_cards.gd`
- `test_card_data.gd`
- `test_cards_in_combat.gd`
- `test_deck_and_piles.gd`
- `test_dungeon_run.gd`
- `test_simulation.gd`
- `test_turn_order.gd`

Review the relevant tests before changing a subsystem.

### What to Test After a Change

| Modified code | What to verify |
|---|---|
| Encounter Manager | Enemy creation and progression |
| Run Manager | Rewards, rest, boss phases, run completion |
| Combat State | Turns, energy, damage, results |
| Effect Resolver | Card effect correctness |
| Deck | Adding, removing, upgrading |
| CardPiles | Drawing, discarding, reshuffling |
| Reward Generator | Rarity and eligibility |
| Combat HUD | Buttons, labels, card interaction |

When changing shared functionality, run the full test suite as well as the relevant gameplay scenario.

---

# Part 9 â€” Safe Development and Maintenance

## 65. Development Rules

### Rule 1: Respect System Responsibilities

Do not place core combat calculations inside the Main Menu.

Do not place dungeon progression inside the Card Database.

Put functionality in the class responsible for it.

### Rule 2: Preserve Function Compatibility

When changing a function signature, search for every caller.

For example:

```gdscript
EncounterManager.create_enemy(
    encounter_index,
    boss_phase
)
```

depends on the Encounter Manager supporting both arguments.

### Rule 3: Keep Card Data and Logic Separate

Card definitions belong in the data system.

Card execution belongs in the combat system.

Card display belongs in the UI system.

### Rule 4: Understand Persistent Versus Temporary State

The Deck persists across encounters.

CardPiles represents temporary battle card locations.

The Run Manager stores progression and health between encounters.

The Combat State stores current battle information.

### Rule 5: Reuse Existing Functions

Before writing new logic, search the codebase for an existing function that performs the same operation.

Duplicated rules can lead to inconsistent behavior.

### Rule 6: Test After Changing Rules

Changes to drawing, damage, energy, rewards, or enemy actions may affect multiple systems.

Update tests when behavior changes intentionally.

### Rule 7: Keep Documentation Current

If you add encounters, change interfaces, or introduce new mechanics, update this guide and the project documentation.

## 66. Git Workflow

Check the repository state:

```powershell
git status
```

Fetch changes:

```powershell
git fetch origin
```

Create a feature branch from the team's designated development branch:

```powershell
git switch -c feature/my-improvement
```

After making and testing changes:

```powershell
git add path/to/changed-file
git commit -m "Describe the improvement"
git push -u origin feature/my-improvement
```

Submit a pull request for review.

Do not force-push shared branches without authorization.

Avoid committing unrelated temporary practice files.

## 67. Known Limitations and Areas to Review

Future maintainers should review:

**Complete runtime validation**

The final integration passed an editor compilation check. A complete end-to-end playthrough of all nine encounters should still be verified.

**Gameplay balance**

Enemy statistics, card effects, reward probabilities, and progression difficulty may require further balancing.

**Documentation consistency**

Some earlier root documentation describes older gameplay configurations. Synchronize those descriptions with the current implementation.

**Mobile usability**

Review touch targets, layouts, screen sizes, and mobile interaction behavior on actual target devices.

**Testing coverage**

Expand tests for integration behavior, edge cases, boss phases, and newly introduced mechanics.

**Team feedback**

Review existing project feedback and design documents before making substantial design changes.

## 68. Suggested Future Improvements

Possible development directions include:

- Additional encounters.
- New card effects.
- Improved enemy intention presentation.
- Better combat animations.
- Additional accessibility options.
- Expanded mobile touch support.
- More dungeon events.
- Improved balance.
- Better tutorial screens.
- More automated tests.
- Additional game modes or progression features.

Before implementing a feature, determine which systems it affects and how the feature will be tested.

---

# Part 10 â€” Developer Reference and Learning Path

## 69. Important Function Reference

| Function | File | Purpose |
|---|---|---|
| `_on_new_game_pressed()` | `main_menu.gd` | Starts dungeon flow |
| `start_new_run()` | `run_manager.gd` | Initializes a run |
| `show_encounter()` | `run_manager.gd` | Selects current encounter |
| `start_battle()` | `run_manager.gd` | Starts a battle |
| `_on_battle_finished()` | `run_manager.gd` | Receives battle outcome |
| `resolve_battle()` | `run_manager.gd` | Resolves victory or defeat |
| `show_rewards()` | `run_manager.gd` | Displays rewards |
| `select_reward()` | `run_manager.gd` | Processes reward selection |
| `show_rest()` | `run_manager.gd` | Displays rest options |
| `advance_encounter()` | `run_manager.gd` | Advances dungeon progression |
| `finish_run()` | `run_manager.gd` | Ends a run |
| `create_enemy()` | `encounter_manager.gd` | Constructs an enemy |
| `create_regular_actions()` | `encounter_manager.gd` | Creates regular enemy actions |
| `create_elite_actions()` | `encounter_manager.gd` | Creates elite actions |
| `create_boss_actions()` | `encounter_manager.gd` | Creates boss actions |
| `start_dungeon_battle()` | `combat_hud.gd` | Initializes dungeon combat |
| `_on_card_pressed()` | `combat_hud.gd` | Handles card input |
| `_on_end_turn_pressed()` | `combat_hud.gd` | Handles End Turn |
| `_refresh_hud()` | `combat_hud.gd` | Updates combat display |
| `start()` | `combat_state.gd` | Initializes combat |
| `why_cannot_play()` | `combat_state.gd` | Validates card play |
| `play_card()` | `combat_state.gd` | Plays a card |
| `end_player_turn()` | `combat_state.gd` | Ends player turn |
| `calculate_attack_damage()` | `combat_state.gd` | Calculates attack damage |
| `deal_attack_damage()` | `combat_state.gd` | Applies attack damage |
| `current_intent()` | `enemy.gd` | Returns enemy intention |
| `advance_intent()` | `enemy.gd` | Advances intention sequence |
| `resolve()` | `effect_resolver.gd` | Executes card effects |
| `get_card()` | `card_database.gd` | Retrieves card definition |
| `get_reward_pool()` | `card_database.gd` | Retrieves eligible reward definitions |
| `create_starter()` | `deck.gd` | Creates starter deck |
| `draw()` | `card_piles.gd` | Draws cards |
| `reshuffle_discard_into_draw()` | `card_piles.gd` | Reshuffles discard pile |
| `generate_choices()` | `reward_generator.gd` | Generates reward choices |

## 70. Beginner-to-Contributor Learning Path

### Stage 1: Learn Programming

Read Sections 5â€“15.

Practice variables, conditions, functions, arrays, dictionaries, loops, and classes.

**Goal:** Understand basic GDScript.

### Stage 2: Learn Godot

Read Sections 16â€“23.

Create a scene, add nodes, attach scripts, and connect signals.

**Goal:** Understand how GDScript interacts with the engine.

### Stage 3: Read the Project

Read Sections 24â€“44.

Open the actual scripts and locate the functions described.

Follow the game from New Game through combat and progression.

**Goal:** Understand the architecture.

### Stage 4: Make Small Changes

Complete Exercises 1â€“3 and 6.

**Goal:** Gain experience modifying and executing code.

### Stage 5: Add Functionality

Complete Exercises 4, 5, and 7.

**Goal:** Extend the existing systems.

### Stage 6: Debug and Maintain

Read Sections 53â€“68.

Run tests, investigate errors, and review dependencies.

**Goal:** Contribute safely and independently.

## 71. Questions Every Developer Should Answer

After completing this guide, you should be able to explain:

1. What is a variable?
2. What is a function?
3. What is the difference between an array and a dictionary?
4. What is a class?
5. What does `extends` mean?
6. What does `class_name` do?
7. What is a Godot scene?
8. What is a node?
9. What does `_ready()` do?
10. What is a signal?
11. How does the Main Menu start a dungeon run?
12. Where is the starter deck created?
13. Which class stores the encounter list?
14. How are enemies constructed?
15. How does the Combat HUD start combat?
16. Which function validates a card?
17. Where is energy spent?
18. Where are card effects executed?
19. What is the difference between Deck and CardPiles?
20. How does the Run Manager learn combat has ended?
21. How are rewards generated?
22. How does the boss transition between phases?
23. How do you find every caller of a function?
24. How do you debug an unexpected result?
25. How do you test a new feature?

You do not need to memorize every function. You need to understand how to locate, read, and safely change the code.

## 72. Additional Learning Resources

**Official Godot documentation**

https://docs.godotengine.org/

**GDScript basics**

https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html

**Godot step-by-step tutorials**

https://docs.godotengine.org/en/stable/getting_started/step_by_step/index.html

**Project documentation**

- `Doc/README.md` â€” Overall project documentation.
- `Doc/ONBOARDING.md` â€” This developer onboarding guide.
- `docs/CARD_SYSTEM.md` â€” Card system reference.
- `HOW_TO_PLAY.md` â€” Player-facing gameplay instructions.
- `VISION.md` â€” Project vision.
- `STAKEHOLDERS.md` â€” Stakeholder information.
- `tests/` â€” Automated tests and examples of expected behavior.

## 73. First Contribution Checklist

Before making your first real contribution:

- [ ] Open the project successfully in Godot.
- [ ] Run the Main Menu.
- [ ] Complete the beginner GDScript exercises.
- [ ] Understand scenes, nodes, and signals.
- [ ] Read the Main Menu and Run Manager.
- [ ] Trace the battle startup process.
- [ ] Trace a card from the HUD to the Effect Resolver.
- [ ] Understand Deck versus CardPiles.
- [ ] Identify the files affected by your intended change.
- [ ] Create a feature branch.
- [ ] Make a small, focused change.
- [ ] Run the relevant tests.
- [ ] Manually verify the affected gameplay.
- [ ] Update documentation if needed.
- [ ] Review the changed files before committing.
- [ ] Submit the contribution for review.

## 74. Final Handoff Notes

Dungeon Deck was developed through multiple connected systems rather than one large script.

The most important skill for future maintainers is understanding how those systems cooperate.

When examining unfamiliar code, ask:

**What information enters this function?**

**What information does it change?**

**What other functions does it call?**

**Which system owns this behavior?**

**What other systems depend on it?**

**How can I test whether it works?**

Start with small experiments. Follow existing patterns. Reuse established functions whenever possible. Test changes before integrating them.

For a new programmer, the goal is to learn enough GDScript and Godot to understand the code.

For an experienced developer, the goal is to understand the architecture and safely extend it.

For future project teams, the goal is to preserve the work already completed while making Dungeon Deck better.

**Welcome to Dungeon Deck development.**
