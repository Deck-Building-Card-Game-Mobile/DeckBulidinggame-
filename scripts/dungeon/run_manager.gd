
extends Control

## DUNGEON PROGRESSION AND INTEGRATION
## Role 4's progression system, integrated with Role 3's UI.
## Includes grouped rest upgrades and duplicate reward choices.

const COMBAT_SCENE: PackedScene = preload(
    "res://scenes/ui/combat_hud.tscn"
)

const MAIN_MENU_SCENE: String = (
    "res://scenes/ui/main_menu.tscn"
)

const ENCOUNTERS: Array[Dictionary] = [
    {"kind": "battle", "name": "Dungeon Slime", "hp": 30, "damage": 6},
    {"kind": "battle", "name": "Cave Rat", "hp": 36, "damage": 8},
    {"kind": "rest"},
    {"kind": "battle", "name": "Skeleton Guard", "hp": 48, "damage": 10},
    {"kind": "boss", "name": "Dungeon Warden", "hp": 85, "damage": 13},
]

var deck: Deck
var current_hp: int = 0
var encounter_index: int = 0
var status: String = "not_started"

var rng := RandomNumberGenerator.new()
var combat_hud: Control
var choices: Array[CardData] = []

var battle_result_pending: bool = false

# Used while the player decides what to do with a duplicate.
var pending_reward_id: String = ""


func _ready() -> void:
    set_anchors_and_offsets_preset(
        Control.PRESET_FULL_RECT
    )

    rng.randomize()
    start_new_run()


# --------------------------------------------------
# START / RESTART
# --------------------------------------------------

func start_new_run() -> void:
    clear_screen()

    deck = Deck.create_starter()
    current_hp = GameRules.player_max_hp()

    encounter_index = 0
    status = "playing"

    choices.clear()
    pending_reward_id = ""
    battle_result_pending = false

    print("New dungeon run started.")

    show_encounter()


# --------------------------------------------------
# DUNGEON PROGRESSION
# --------------------------------------------------

func show_encounter() -> void:
    if status != "playing":
        return

    if current_hp <= 0:
        finish_run(false)
        return

    if encounter_index >= ENCOUNTERS.size():
        finish_run(true)
        return

    var encounter: Dictionary = ENCOUNTERS[encounter_index]

    if encounter["kind"] == "rest":
        show_rest()
    else:
        show_intro(encounter)


func show_intro(encounter: Dictionary) -> void:
    var panel := create_panel(
        "Encounter %d / %d" % [
            encounter_index + 1,
            ENCOUNTERS.size()
        ]
    )

    add_text(panel, str(encounter["name"]))

    add_text(
        panel,
        "Your HP: %d / %d | Deck: %d cards" % [
            current_hp,
            GameRules.player_max_hp(),
            deck.size()
        ]
    )

    add_button(panel, "Enter Battle", start_battle)


# --------------------------------------------------
# COMBAT INTEGRATION
# --------------------------------------------------

func start_battle() -> void:
    if status != "playing":
        return

    if battle_result_pending:
        return

    if encounter_index >= ENCOUNTERS.size():
        return

    var encounter: Dictionary = ENCOUNTERS[encounter_index]

    if encounter["kind"] == "rest":
        return

    clear_screen()
    battle_result_pending = true

    var actions: Array = [
        {
            "type": "attack",
            "amount": int(encounter["damage"]),
            "hits": 1
        },
        {
            "type": "block",
            "amount": 5
        }
    ]

    var enemy := Enemy.new(
        str(encounter["name"]),
        int(encounter["hp"]),
        actions
    )

    combat_hud = COMBAT_SCENE.instantiate()

    # Must be set before add_child(), which triggers _ready().
    combat_hud.dungeon_mode = true

    add_child(combat_hud)

    combat_hud.set_anchors_and_offsets_preset(
        Control.PRESET_FULL_RECT
    )

    combat_hud.combat.combat_ended.connect(
        _on_battle_finished
    )

    print("Starting dungeon battle: ", encounter["name"])

    combat_hud.start_dungeon_battle(
        deck,
        current_hp,
        [enemy],
        rng
    )


# --------------------------------------------------
# BATTLE RESULTS
# --------------------------------------------------

func _on_battle_finished(result: String) -> void:
    if not battle_result_pending:
        return

    if combat_hud == null:
        return

    if combat_hud.combat == null:
        return

    if combat_hud.combat.player == null:
        return

    current_hp = combat_hud.combat.player.hp
    battle_result_pending = false

    call_deferred("resolve_battle", result)


func resolve_battle(result: String) -> void:
    if status != "playing":
        return

    if result == CombatState.RESULT_LOST or current_hp <= 0:
        finish_run(false)
        return

    if result != CombatState.RESULT_WON:
        push_warning("Unexpected combat result: %s" % result)
        return

    if encounter_index >= ENCOUNTERS.size():
        return

    var encounter: Dictionary = ENCOUNTERS[encounter_index]

    if encounter["kind"] == "boss":
        finish_run(true)
        return

    choices = RewardGenerator.generate_choices(rng)
    show_rewards()


# --------------------------------------------------
# CARD REWARDS
# --------------------------------------------------

func show_rewards() -> void:
    pending_reward_id = ""

    var panel := create_panel("Battle Won!")

    add_text(
        panel,
        "Remaining HP: %d / %d" % [
            current_hp,
            GameRules.player_max_hp()
        ]
    )

    add_text(
        panel,
        "Choose one card to add to your deck:"
    )

    for choice_index in range(choices.size()):
        var card: CardData = choices[choice_index]
        var owned: int = deck.count_of(card.id)

        var label := "%s (%s, %d energy) - %s" % [
            card.name,
            card.rarity,
            card.cost,
            card.text
        ]

        if owned > 0:
            label += "  [Owned: %d]" % owned

        add_button(
            panel,
            label,
            Callable(self, "select_reward").bind(choice_index)
        )

    add_button(
        panel,
        "Skip Reward",
        Callable(self, "select_reward").bind(-1)
    )


func select_reward(choice_index: int) -> void:
    if status != "playing":
        return

    if choice_index < 0:
        choices.clear()
        advance_encounter()
        return

    if choice_index >= choices.size():
        return

    var selected: CardData = choices[choice_index]
    var owned: int = deck.count_of(selected.id)

    # New card: add it immediately.
    if owned == 0:
        deck.add_card(selected.id)
        print("Added new card: ", selected.name)

        choices.clear()
        advance_encounter()
        return

    # Duplicate: let the player decide how to use it.
    pending_reward_id = selected.id
    show_duplicate_reward_choice(selected)


func show_duplicate_reward_choice(card: CardData) -> void:
    var panel := create_panel("Duplicate Card Reward")

    add_text(panel, card.name)

    add_text(
        panel,
        "You already own %d copy/copies." % [
            deck.count_of(card.id)
        ]
    )

    add_text(panel, card.text)

    add_text(
        panel,
        "Choose how to use this reward:"
    )

    add_button(
        panel,
        "Add Another Copy",
        add_duplicate_reward
    )

    var upgradable: Array[CardInstance] = (
        get_upgradable_copies(card.id)
    )

    if not upgradable.is_empty():
        add_button(
            panel,
            "Upgrade Existing Copy",
            upgrade_duplicate_reward
        )
    else:
        add_text(
            panel,
            "All existing copies are already upgraded."
        )

    add_button(
        panel,
        "Back to Rewards",
        show_rewards
    )


func add_duplicate_reward() -> void:
    if status != "playing":
        return

    if pending_reward_id.is_empty():
        return

    deck.add_card(pending_reward_id)

    print(
        "Added another copy of ",
        pending_reward_id,
        ". Total: ",
        deck.count_of(pending_reward_id)
    )

    complete_reward_selection()


func upgrade_duplicate_reward() -> void:
    if status != "playing":
        return

    if pending_reward_id.is_empty():
        return

    var upgradable: Array[CardInstance] = (
        get_upgradable_copies(pending_reward_id)
    )

    if upgradable.is_empty():
        return

    # Upgrade one existing copy rather than adding a new card.
    var card: CardInstance = upgradable[0]

    if not deck.upgrade_card(card):
        return

    print("Upgraded existing card: ", card.get_name())

    complete_reward_selection()


func complete_reward_selection() -> void:
    pending_reward_id = ""
    choices.clear()
    advance_encounter()


# --------------------------------------------------
# CARD LOOKUP HELPERS
# --------------------------------------------------

func get_upgradable_copies(
    card_id: String
) -> Array[CardInstance]:
    var result: Array[CardInstance] = []

    for card in deck.cards:
        if card.card_id == card_id and card.can_upgrade():
            result.append(card)

    return result


func get_grouped_upgradable_cards() -> Dictionary:
    # Groups copies by their card ID.
    # Example: five Strikes become one entry.
    var groups: Dictionary = {}

    for card in deck.get_upgradable_cards():
        if not groups.has(card.card_id):
            groups[card.card_id] = {
                "name": card.get_name(),
                "count": 0
            }

        groups[card.card_id]["count"] += 1

    return groups


# --------------------------------------------------
# REST AREA
# --------------------------------------------------

func show_rest() -> void:
    var panel := create_panel(
        "Encounter %d / %d - Rest Area" % [
            encounter_index + 1,
            ENCOUNTERS.size()
        ]
    )

    add_text(
        panel,
        "HP: %d / %d" % [
            current_hp,
            GameRules.player_max_hp()
        ]
    )

    add_text(
        panel,
        "Choose one action:"
    )

    add_button(
        panel,
        "Rest: Recover 20 HP",
        rest_and_continue
    )

    add_text(
        panel,
        "OR upgrade one card:"
    )

    var groups: Dictionary = get_grouped_upgradable_cards()

    if groups.is_empty():
        add_text(
            panel,
            "No cards are currently available to upgrade."
        )
        return

    # Scrollable list prevents long decks from overflowing.
    var scroll := ScrollContainer.new()
    scroll.custom_minimum_size = Vector2(340, 0)
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL

    # Limit height while allowing scrolling.
    scroll.custom_minimum_size.y = 220

    panel.add_child(scroll)

    var options := VBoxContainer.new()
    options.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    options.add_theme_constant_override("separation", 8)
    scroll.add_child(options)

    for card_id in groups.keys():
        var group: Dictionary = groups[card_id]

        var caption := "Upgrade %s (%d available)" % [
            str(group["name"]),
            int(group["count"])
        ]

        add_button(
            options,
            caption,
            Callable(self, "upgrade_group_and_continue").bind(
                str(card_id)
            )
        )


func upgrade_group_and_continue(card_id: String) -> void:
    if status != "playing":
        return

    var available: Array[CardInstance] = (
        get_upgradable_copies(card_id)
    )

    if available.is_empty():
        return

    # Upgrade the first eligible copy of this card type.
    if not deck.upgrade_card(available[0]):
        return

    print("Rest area upgrade: ", available[0].get_name())

    advance_encounter()


func rest_and_continue() -> void:
    if status != "playing":
        return

    current_hp = mini(
        GameRules.player_max_hp(),
        current_hp + 20
    )

    print("Rested. Current HP: ", current_hp)

    advance_encounter()


# --------------------------------------------------
# NEXT ENCOUNTER
# --------------------------------------------------

func advance_encounter() -> void:
    if status != "playing":
        return

    encounter_index += 1

    print("Advancing to encounter ", encounter_index + 1)

    show_encounter()


# --------------------------------------------------
# WIN / LOSE
# --------------------------------------------------

func finish_run(won: bool) -> void:
    if status != "playing":
        return

    status = "won" if won else "lost"
    battle_result_pending = false
    pending_reward_id = ""

    print("Dungeon run finished: ", status)

    var panel := create_panel(
        "DUNGEON CLEARED!" if won else "RUN DEFEATED"
    )

    add_text(
        panel,
        "Encounters completed: %d / %d" % [
            mini(
                encounter_index + (1 if won else 0),
                ENCOUNTERS.size()
            ),
            ENCOUNTERS.size()
        ]
    )

    add_text(
        panel,
        "Final HP: %d / %d" % [
            maxi(current_hp, 0),
            GameRules.player_max_hp()
        ]
    )

    add_text(
        panel,
        "Final deck: %d cards" % deck.size()
    )

    add_button(
        panel,
        "Start New Run",
        start_new_run
    )

    add_button(
        panel,
        "Back to Main Menu",
        go_to_menu
    )


func go_to_menu() -> void:
    var error: Error = get_tree().change_scene_to_file(
        MAIN_MENU_SCENE
    )

    if error != OK:
        push_error(
            "Failed to return to main menu: %s" % error
        )
        return

    queue_free()


# --------------------------------------------------
# SIMPLE UI HELPERS
# --------------------------------------------------

func clear_screen() -> void:
    for child in get_children():
        remove_child(child)
        child.queue_free()

    combat_hud = null


func create_panel(heading: String) -> VBoxContainer:
    clear_screen()

    var center := CenterContainer.new()
    center.set_anchors_and_offsets_preset(
        Control.PRESET_FULL_RECT
    )
    add_child(center)

    var panel := VBoxContainer.new()
    panel.custom_minimum_size = Vector2(340, 0)
    panel.add_theme_constant_override("separation", 12)
    center.add_child(panel)

    add_text(panel, heading)

    return panel


func add_text(
    panel: VBoxContainer,
    message: String
) -> void:
    var label := Label.new()
    label.text = message
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    panel.add_child(label)


func add_button(
    panel: VBoxContainer,
    caption: String,
    action: Callable
) -> void:
    var button := Button.new()
    button.text = caption
    button.custom_minimum_size = Vector2(0, 48)
    button.pressed.connect(action)
    panel.add_child(button)
