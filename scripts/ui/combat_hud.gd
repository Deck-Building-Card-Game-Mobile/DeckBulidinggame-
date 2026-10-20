
extends Control

# Combat HUD for Dungeon Deck.
# Uses the existing card and combat systems.

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

var combat: CombatState
var selected_enemy_index: int = 0


func _ready() -> void:
	print("Combat HUD loaded successfully!")

	# Remove the temporary card buttons.
	for child in card_hand.get_children():
		card_hand.remove_child(child)
		child.queue_free()

	# Connect the End Turn button.
	end_turn_button.pressed.connect(_on_end_turn_pressed)

	# Start a test battle using the real combat system.
	_start_test_battle()


func _start_test_battle() -> void:
	# Create the real starter deck.
	var starter_deck: Deck = Deck.create_starter()

	# Create a test enemy with alternating actions.
	var enemy_actions: Array = [
		{"type": "attack", "amount": 8, "hits": 1},
		{"type": "block", "amount": 5}
	]

	var test_enemy: Enemy = Enemy.new(
		"Dungeon Slime",
		40,
		enemy_actions
	)

	# Create the combat state.
	combat = CombatState.new()

	# Connect combat signals.
	combat.turn_started.connect(_on_turn_started)
	combat.energy_changed.connect(_on_energy_changed)
	combat.card_played.connect(_on_card_played)
	combat.card_rejected.connect(_on_card_rejected)
	combat.damage_dealt.connect(_on_damage_dealt)
	combat.discard_requested.connect(_on_discard_requested)
	combat.combat_ended.connect(_on_combat_ended)

	# Start the battle.
	combat.start(
		starter_deck,
		GameRules.player_max_hp(),
		[test_enemy]
	)

	_refresh_hud()


func _refresh_hud() -> void:
	if combat == null or combat.player == null:
		return

	# Update player information.
	player_health_label.text = "HP: %d / %d" % [
		combat.player.hp,
		combat.player.max_hp
	]

	player_block_label.text = "Block: %d" % combat.player.block

	energy_label.text = "Energy: %d / %d" % [
		combat.energy,
		GameRules.energy_per_turn()
	]

	# Update enemy information.
	if not combat.enemies.is_empty():
		var enemy: Enemy = combat.enemies[selected_enemy_index]

		# Combatant uses display_name, not name.
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

	# Update End Turn button.
	end_turn_button.disabled = (
		combat.is_over()
		or not combat.is_player_turn
		or combat.pending_discards > 0
	)

	# Update the player's hand.
	_refresh_card_hand()


func _format_enemy_intent(intent: Dictionary) -> String:
	var intent_type: String = str(intent.get("type", "unknown"))
	var amount: int = int(intent.get("amount", 0))

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


func _refresh_card_hand() -> void:
	# Remove previously generated card buttons.
	for child in card_hand.get_children():
		card_hand.remove_child(child)
		child.queue_free()

	if combat.piles == null:
		return

	# Update hand title.
	if combat.pending_discards > 0:
		hand_title.text = "CHOOSE A CARD TO DISCARD"
	else:
		hand_title.text = "YOUR HAND"

	# Create buttons from actual cards in the player's hand.
	for card in combat.piles.hand:
		var card_button := Button.new()

		card_button.custom_minimum_size = Vector2(140, 135)

		card_button.text = "%s\nCost: %d\n%s" % [
			card.get_name(),
			card.get_cost(),
			card.get_text()
		]

		card_button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		card_button.clip_text = true

		# Enable cards based on available energy and targeting.
		if combat.pending_discards > 0:
			card_button.disabled = false
		else:
			var target_index: int = (
				selected_enemy_index if card.targets_enemy() else -1
			)

			card_button.disabled = not combat.can_play(
				card,
				target_index
			)

		# Connect each card button to the correct card instance.
		card_button.pressed.connect(
			_on_card_pressed.bind(card)
		)

		card_hand.add_child(card_button)


func _on_card_pressed(card: CardInstance) -> void:
	if combat == null or combat.is_over():
		return

	# Handle cards that require choosing a discard.
	if combat.pending_discards > 0:
		if combat.choose_discard(card):
			_refresh_hud()
		return

	# Determine whether the card needs an enemy target.
	var target_index: int = -1

	if card.targets_enemy():
		target_index = selected_enemy_index

	# Play the card through the existing combat system.
	var played: bool = combat.play_card(card, target_index)

	if played:
		print("Played card: ", card.get_name())

	_refresh_hud()


func _on_end_turn_pressed() -> void:
	if combat == null or combat.is_over():
		return

	combat.end_player_turn()
	_refresh_hud()


func _on_turn_started(turn: int) -> void:
	print("Turn started: ", turn)
	call_deferred("_refresh_hud")


func _on_energy_changed(_energy: int) -> void:
	call_deferred("_refresh_hud")


func _on_card_played(_card: CardInstance, _target: Enemy) -> void:
	call_deferred("_refresh_hud")


func _on_card_rejected(_card: CardInstance, reason: String) -> void:
	print("Cannot play card: ", reason)


func _on_damage_dealt(
	_source: Combatant,
	_target: Combatant,
	_hp_lost: int,
	_blocked: int
) -> void:
	call_deferred("_refresh_hud")


func _on_discard_requested(_count: int) -> void:
	call_deferred("_refresh_hud")


func _on_combat_ended(result: String) -> void:
	print("Combat finished: ", result)
	call_deferred("_refresh_hud")
