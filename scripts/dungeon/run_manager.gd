
extends Control

## ROLE 4 - DUNGEON PROGRESSION AND INTEGRATION

const COMBAT_SCENE = preload("res://scenes/ui/combat_hud.tscn")

# Prototype dungeon sequence.
const ENCOUNTERS: Array[Dictionary] = [
    {"kind": "battle", "name": "Dungeon Slime", "hp": 30, "damage": 6},
    {"kind": "battle", "name": "Cave Rat", "hp": 36, "damage": 8},
    {"kind": "rest"},
    {"kind": "battle", "name": "Skeleton Guard", "hp": 48, "damage": 10},
    {"kind": "boss", "name": "Dungeon Warden", "hp": 85, "damage": 13},
]

var deck: Deck
var current_hp: int
var encounter_index: int = 0
var status: String = "not_started"
var rng := RandomNumberGenerator.new()
var combat_hud: Control
var choices: Array[CardData] = []


func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    rng.randomize()
    start_new_run()


# START / RESTART
func start_new_run() -> void:
    deck = Deck.create_starter()
    current_hp = GameRules.player_max_hp()
    encounter_index = 0
    status = "playing"
    show_encounter()


# DUNGEON PROGRESSION
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
        "Encounter %d / %d" % [encounter_index + 1, ENCOUNTERS.size()]
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


# COMBAT INTEGRATION
func start_battle() -> void:
    clear_screen()

    var encounter: Dictionary = ENCOUNTERS[encounter_index]

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
    add_child(combat_hud)

    combat_hud.set_anchors_and_offsets_preset(
        Control.PRESET_FULL_RECT
    )

    # Reuse the CombatState initialized by the existing HUD.
    # Replace its demo battle before the first visible frame.
    var combat: CombatState = combat_hud.combat

    combat.combat_ended.connect(_on_battle_finished)

    combat.start(
        deck,
        current_hp,
        [enemy],
        rng
    )

    combat_hud._refresh_hud()


# SAVE BATTLE RESULT
func _on_battle_finished(result: String) -> void:
    if combat_hud == null:
        return

    current_hp = combat_hud.combat.player.hp

    call_deferred("resolve_battle", result)


func resolve_battle(result: String) -> void:
    if status != "playing":
        return

    if result == CombatState.RESULT_LOST or current_hp <= 0:
        finish_run(false)
        return

    if result != CombatState.RESULT_WON:
        return

    if ENCOUNTERS[encounter_index]["kind"] == "boss":
        finish_run(true)
        return

    choices = RewardGenerator.generate_choices(rng)
    show_rewards()


# CARD REWARDS
func show_rewards() -> void:
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
        "Choose one card to add to your deck, or skip:"
    )

    for choice_index in range(choices.size()):
        var card := choices[choice_index]

        var label := "%s (%s, %d energy) - %s" % [
            card.name,
            card.rarity,
            card.cost,
            card.text
        ]

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
    if choice_index >= 0 and choice_index < choices.size():
        deck.add_card(choices[choice_index].id)

    choices.clear()
    advance_encounter()


# REST AREA
func show_rest() -> void:
    var panel := create_panel("Rest Area")

    add_text(
        panel,
        "HP: %d / %d" % [
            current_hp,
            GameRules.player_max_hp()
        ]
    )

    add_text(panel, "Choose one action:")

    add_button(
        panel,
        "Rest: Recover 20 HP",
        rest_and_continue
    )

    var upgradable := deck.get_upgradable_cards()

    if not upgradable.is_empty():
        add_text(panel, "Or upgrade a card:")

        for card in upgradable:
            add_button(
                panel,
                "Upgrade " + card.get_name(),
                Callable(self, "upgrade_and_continue").bind(card)
            )


func rest_and_continue() -> void:
    current_hp = mini(
        GameRules.player_max_hp(),
        current_hp + 20
    )

    advance_encounter()


func upgrade_and_continue(card: CardInstance) -> void:
    if not deck.upgrade_card(card):
        return

    advance_encounter()


# NEXT ENCOUNTER
func advance_encounter() -> void:
    encounter_index += 1
    show_encounter()


# WIN / LOSE
func finish_run(won: bool) -> void:
    status = "won" if won else "lost"

    var panel := create_panel(
        "DUNGEON CLEARED!" if won else "RUN DEFEATED"
    )

    add_text(
        panel,
        "Encounters completed: %d / %d" % [
            encounter_index + (1 if won else 0),
            ENCOUNTERS.size()
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
    get_tree().change_scene_to_file(
        "res://scenes/ui/main_menu.tscn"
    )


# SIMPLE UI HELPERS
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


func add_text(panel: VBoxContainer, message: String) -> void:
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
