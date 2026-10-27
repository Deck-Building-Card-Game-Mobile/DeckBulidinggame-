
extends Control

# Combat HUD for Dungeon Deck.
# Supports standalone testing and dungeon progression.

const CARD_UI_SCENE: PackedScene = preload("res://scenes/ui/card_ui.tscn")
const MAIN_MENU_SCENE: String = "res://scenes/ui/main_menu.tscn"
const COMBAT_SCENE: String = "res://scenes/ui/combat_hud.tscn"

@onready var player_health_label: Label = $PlayerPanel/PlayerInfo/HealthLabel
@onready var player_block_label: Label = $PlayerPanel/PlayerInfo/BlockLabel
@onready var energy_label: Label = $PlayerPanel/PlayerInfo/EnergyLabel

@onready var enemy_title: Label = $EnemyPanel/EnemyInfo/EnemyTitle
@onready var enemy_health_label: Label = $EnemyPanel/EnemyInfo/EnemyHealthLabel
@onready var enemy_block_label: Label = $EnemyPanel/EnemyInfo/EnemyBlockLabel
@onready var enemy_intent_label: Label = $EnemyPanel/EnemyInfo/EnemyIntentLabel

@onready var card_hand: HBoxContainer = $BottomPanel/BottomLayout/HandScroll/CardHand
@onready var end_turn_button: Button = $BottomPanel/BottomLayout/ControlsRow/EndTurnButton
@onready var hand_title: Label = $BottomPanel/BottomLayout/ControlsRow/HandTitle

# Combat state.
var combat: CombatState
var selected_enemy_index: int = 0

# False = standalone test battle.
# True = Run Manager controls combat and progression.
@export var dungeon_mode: bool = false

# Manual discard mode.
var discard_mode: bool = false
var discard_mode_button: Button

# Result screen.
var result_overlay: ColorRect
var result_panel: PanelContainer
var result_title: Label
var result_message: Label
var result_action_button: Button


func _ready() -> void:
	print("Combat HUD loaded successfully!")

	# Remove temporary cards from the scene.
	for child in card_hand.get_children():
		card_hand.remove_child(child)
		child.queue_free()

	end_turn_button.pressed.connect(_on_end_turn_pressed)

	# Add a discard button without modifying the scene file.
	_create_discard_button()

	# Create the result screen.
	_create_result_overlay()

	# Create combat state and connect signals once.
	combat = CombatState.new()
	_connect_combat_signals()

	if dungeon_mode:
		print("Combat HUD running in dungeon mode.")
		end_turn_button.disabled = true
	else:
		print("Combat HUD running in standalone test mode.")
		_start_test_battle()


# --------------------------------------------------
# MANUAL DISCARD CONTROLS
# --------------------------------------------------

func _create_discard_button() -> void:
	discard_mode_button = Button.new()
	discard_mode_button.name = "DiscardModeButton"
	discard_mode_button.text = "DISCARD MODE"
	discard_mode_button.custom_minimum_size = Vector2(135, 40)
	discard_mode_button.toggle_mode = true
	discard_mode_button.button_pressed = false
	discard_mode_button.tooltip_text = (
		"Select cards to discard without playing them. "
		+ "Discarding gives no energy or other reward."
	)

	var controls_row: Container = end_turn_button.get_parent()

	controls_row.add_child(discard_mode_button)

	controls_row.move_child(
		discard_mode_button,
		end_turn_button.get_index()
	)

	discard_mode_button.pressed.connect(_on_discard_mode_pressed)


func _on_discard_mode_pressed() -> void:
	if combat == null or combat.is_over():
		discard_mode = false
		_refresh_hud()
		return

	if combat.phase != CombatState.Phase.PLAYER_TURN:
		discard_mode = false
		_refresh_hud()
		return

	if combat.pending_discards > 0:
		discard_mode = false
		_refresh_hud()
		return

	discard_mode = discard_mode_button.button_pressed
	_refresh_hud()


func _refresh_discard_controls() -> void:
	if discard_mode_button == null:
		return

	if combat == null or combat.piles == null:
		discard_mode = false
		discard_mode_button.disabled = true
		discard_mode_button.button_pressed = false
		return

	# Use simple checks to avoid multiline expression parse errors.
	var can_discard: bool = false

	if not combat.is_over():
		if combat.phase == CombatState.Phase.PLAYER_TURN:
			if combat.pending_discards == 0:
				if not combat.piles.hand.is_empty():
					can_discard = true

	if not can_discard:
		discard_mode = false

	discard_mode_button.disabled = not can_discard
	discard_mode_button.button_pressed = discard_mode

	if discard_mode:
		discard_mode_button.text = "CANCEL DISCARD"
	else:
		discard_mode_button.text = "DISCARD MODE"


# --------------------------------------------------
# COMBAT INITIALIZATION
# --------------------------------------------------

func _connect_combat_signals() -> void:
	combat.turn_started.connect(_on_turn_started)
	combat.energy_changed.connect(_on_energy_changed)
	combat.card_played.connect(_on_card_played)
	combat.card_rejected.connect(_on_card_rejected)
	combat.damage_dealt.connect(_on_damage_dealt)
	combat.discard_requested.connect(_on_discard_requested)
	combat.combat_ended.connect(_on_combat_ended)


func _start_test_battle() -> void:
	var starter_deck: Deck = Deck.create_starter()

	var enemy_actions: Array = [
		{"type": "attack", "amount": 8, "hits": 1},
		{"type": "block", "amount": 5}
	]

	var test_enemy: Enemy = Enemy.new(
		"Dungeon Slime",
		40,
		enemy_actions
	)

	discard_mode = false

	combat.start(
		starter_deck,
		GameRules.player_max_hp(),
		[test_enemy]
	)

	_refresh_hud()


# Called by Run Manager after the HUD is instantiated
# and dungeon_mode has been set to true.
func start_dungeon_battle(
	run_deck: Deck,
	player_hp: int,
	enemies: Array,
	run_rng: RandomNumberGenerator
) -> void:
	if not dungeon_mode:
		push_error(
			"Cannot start dungeon battle: HUD is not in dungeon mode."
		)
		return

	if combat == null:
		push_error("Cannot start dungeon battle: combat is null.")
		return

	selected_enemy_index = 0
	discard_mode = false
	result_overlay.visible = false

	combat.start(
		run_deck,
		player_hp,
		enemies,
		run_rng
	)

	_refresh_hud()


# --------------------------------------------------
# COMBAT HUD DISPLAY
# --------------------------------------------------

func _refresh_hud() -> void:
	if combat == null or combat.player == null:
		return

	player_health_label.text = "HP: %d / %d" % [
		combat.player.hp,
		combat.player.max_hp
	]

	player_block_label.text = "Block: %d" % combat.player.block

	energy_label.text = "Energy: %d / %d" % [
		combat.energy,
		GameRules.energy_per_turn()
	]

	if not combat.enemies.is_empty():
		selected_enemy_index = clampi(
			selected_enemy_index,
			0,
			combat.enemies.size() - 1
		)

		var enemy: Enemy = combat.enemies[selected_enemy_index]

		enemy_title.text = enemy.display_name

		enemy_health_label.text = "HP: %d / %d" % [
			enemy.hp,
			enemy.max_hp
		]

		enemy_block_label.text = "Block: %d" % enemy.block

		if enemy.is_alive():
			enemy_intent_label.text = _format_enemy_intent(
				enemy.current_intent()
			)
		else:
			enemy_intent_label.text = "Defeated"

	end_turn_button.disabled = not combat.can_end_turn()

	_refresh_discard_controls()
	_refresh_card_hand()


func _format_enemy_intent(intent: Dictionary) -> String:
	var intent_type: String = str(
		intent.get("type", "unknown")
	)

	var amount: int = int(
		intent.get("amount", 0)
	)

	match intent_type:
		"attack":
			var hits: int = int(intent.get("hits", 1))

			if hits > 1:
				return "Next Action: Attack %d x %d" % [
					amount,
					hits
				]

			return "Next Action: Attack %d" % amount

		"block":
			return "Next Action: Block %d" % amount

		"buff":
			return "Next Action: Buff %s +%d" % [
				str(intent.get("status", "")),
				amount
			]

		"debuff":
			return "Next Action: Debuff %s %d" % [
				str(intent.get("status", "")),
				amount
			]

		_:
			return "Next Action: Unknown"


# --------------------------------------------------
# CARD HAND
# --------------------------------------------------

func _refresh_card_hand() -> void:
	for child in card_hand.get_children():
		card_hand.remove_child(child)
		child.queue_free()

	if combat == null or combat.piles == null:
		return

	if combat.pending_discards > 0:
		hand_title.text = "CHOOSE A CARD TO DISCARD"
	elif discard_mode:
		hand_title.text = "DISCARD MODE - SELECT CARDS"
	else:
		hand_title.text = "YOUR HAND (%d/%d)" % [
			combat.piles.hand.size(),
			combat.piles.max_hand_size
		]

	for card in combat.piles.hand:
		var card_ui: Button = CARD_UI_SCENE.instantiate()

		card_hand.add_child(card_ui)
		card_ui.setup(card)

		if combat.pending_discards > 0:
			# Required discards from card effects.
			card_ui.disabled = false

		elif discard_mode:
			# Manual discarding does not require energy.
			card_ui.disabled = (
				combat.phase != CombatState.Phase.PLAYER_TURN
				or combat.is_over()
			)

		else:
			var target_index: int = (
				selected_enemy_index
				if card.targets_enemy()
				else -1
			)

			card_ui.disabled = not combat.can_play(
				card,
				target_index
			)

		card_ui.card_selected.connect(_on_card_pressed)


# --------------------------------------------------
# PLAYER ACTIONS
# --------------------------------------------------

func _on_card_pressed(card: CardInstance) -> void:
	if combat == null or combat.is_over():
		return

	# Required discard effects take priority.
	if combat.pending_discards > 0:
		if combat.choose_discard(card):
			_refresh_hud()
		return

	# Manually discard instead of playing the card.
	if discard_mode:
		var discarded: bool = combat.manually_discard_card(card)

		if discarded:
			print("Manually discarded card: ", card.get_name())

		_refresh_hud()
		return

	var target_index: int = -1

	if card.targets_enemy():
		target_index = selected_enemy_index

	var played: bool = combat.play_card(
		card,
		target_index
	)

	if played:
		print("Played card: ", card.get_name())

	_refresh_hud()


func _on_end_turn_pressed() -> void:
	if combat == null or not combat.can_end_turn():
		return

	# Return to normal card-playing mode.
	discard_mode = false

	combat.end_player_turn()
	_refresh_hud()


# --------------------------------------------------
# COMBAT SIGNALS
# --------------------------------------------------

func _on_turn_started(turn: int) -> void:
	print("Turn started: ", turn)
	call_deferred("_refresh_hud")


func _on_energy_changed(_energy: int) -> void:
	call_deferred("_refresh_hud")


func _on_card_played(
	_card: CardInstance,
	_target: Enemy
) -> void:
	call_deferred("_refresh_hud")


func _on_card_rejected(
	_card: CardInstance,
	reason: String
) -> void:
	print("Cannot play card: ", reason)


func _on_damage_dealt(
	_source: Combatant,
	_target: Combatant,
	_hp_lost: int,
	_blocked: int
) -> void:
	call_deferred("_refresh_hud")


func _on_discard_requested(_count: int) -> void:
	# Required discard takes priority over manual discard mode.
	discard_mode = false
	call_deferred("_refresh_hud")


func _on_combat_ended(result: String) -> void:
	print("Combat finished: ", result)

	discard_mode = false
	call_deferred("_refresh_hud")

	# Run Manager handles dungeon battle results,
	# card rewards, progression, and final outcomes.
	if dungeon_mode:
		print("Combat result passed to dungeon progression.")
		return

	# Standalone testing keeps its own result screen.
	call_deferred("_show_combat_result", result)


# --------------------------------------------------
# RESULT SCREEN
# --------------------------------------------------

func _create_result_overlay() -> void:
	result_overlay = ColorRect.new()
	result_overlay.name = "ResultOverlay"
	result_overlay.color = Color(0.0, 0.0, 0.0, 0.75)

	result_overlay.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	result_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	result_overlay.visible = false

	add_child(result_overlay)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	result_overlay.add_child(center)

	result_panel = PanelContainer.new()
	result_panel.custom_minimum_size = Vector2(360, 260)
	center.add_child(result_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)

	result_panel.add_child(margin)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 18)
	margin.add_child(layout)

	result_title = Label.new()
	result_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_title.add_theme_font_size_override("font_size", 30)
	layout.add_child(result_title)

	result_message = Label.new()
	result_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(result_message)

	result_action_button = Button.new()
	result_action_button.custom_minimum_size = Vector2(200, 45)
	result_action_button.pressed.connect(
		_on_result_action_pressed
	)

	layout.add_child(result_action_button)

	var menu_button := Button.new()
	menu_button.text = "MAIN MENU"
	menu_button.custom_minimum_size = Vector2(200, 45)
	menu_button.pressed.connect(_on_main_menu_pressed)

	layout.add_child(menu_button)


func _show_combat_result(result: String) -> void:
	if dungeon_mode:
		return

	if result_overlay == null:
		return

	if result == CombatState.RESULT_WON:
		result_title.text = "VICTORY!"

		result_title.add_theme_color_override(
			"font_color",
			Color(0.3, 0.9, 0.4)
		)

		var defeated_enemy_name: String = "the enemy"

		if combat != null and not combat.enemies.is_empty():
			defeated_enemy_name = combat.enemies[0].display_name

		result_message.text = "You defeated %s!" % defeated_enemy_name
		result_action_button.text = "PLAY AGAIN"

	elif result == CombatState.RESULT_LOST:
		result_title.text = "DEFEAT"

		result_title.add_theme_color_override(
			"font_color",
			Color(1.0, 0.3, 0.3)
		)

		result_message.text = "Your adventure has ended."
		result_action_button.text = "RETRY"

	else:
		result_title.text = "COMBAT FINISHED"
		result_message.text = "The battle has ended."
		result_action_button.text = "PLAY AGAIN"

	result_overlay.visible = true


# --------------------------------------------------
# RESULT BUTTONS
# --------------------------------------------------

func _on_result_action_pressed() -> void:
	if dungeon_mode:
		return

	var error: Error = get_tree().change_scene_to_file(
		COMBAT_SCENE
	)

	if error != OK:
		push_error(
			"Failed to restart combat: %s" % error
		)


func _on_main_menu_pressed() -> void:
	var error: Error = get_tree().change_scene_to_file(
		MAIN_MENU_SCENE
	)

	if error != OK:
		push_error(
			"Failed to return to main menu: %s" % error
		)
