class_name CombatState
extends RefCounted
## One fight: turn order, energy, playing cards, enemy turns, win/lose.
##
## This is the reference implementation of the rules in the card spreadsheet,
## written so every card can be played and tested. Role 1 (combat) owns this
## file going forward; Role 3 (UI) listens to its signals; Role 4 creates it
## for each battle and reads `result` when it ends.
##
## Typical use:
##   var combat := CombatState.new()
##   combat.start(run_deck, run_hp, [Enemy.new("Slime", 18, [...])])
##   combat.play_card(combat.piles.hand[0], 0)   # card, target enemy index
##   combat.end_player_turn()                    # enemies act, next turn starts
##   if combat.result == CombatState.RESULT_WON: ...
##
## Animating the enemy turn (UI): set manual_enemy_turn = true before start().
## end_player_turn() then stops at the start of the enemy turn, and the UI
## steps through it one enemy at a time:
##   combat.end_player_turn()
##   while combat.next_enemy_action():   # one enemy acts per call
##       await play_enemy_animation()    # listen to enemy_acted / damage_dealt
## The last call ends the round and starts the player's next turn.
##
## A round
##   1. Player turn start: lose all block -> Poison ticks -> energy refills
##      (+Berserker Rage) -> Bulwark's delayed block -> Iron Skin block ->
##      Black Plague poisons all enemies -> draw 5.          [turn_started]
##   2. Player plays cards.
##   3. Player turn end: discard hand, Sharpen bonus expires. [player_turn_ended]
##   4. Enemy turn, one enemy at a time:                      [enemy_turn_started]
##      lose block -> Poison ticks -> act on its intent.     [enemy_acted]
##   5. Round end: everyone's Weak/Vulnerable -1 (ones an enemy applied this
##      round skip this countdown), enemies show their next intent. [round_ended]

enum Phase { NOT_STARTED, PLAYER_TURN, ENEMY_TURN, OVER }

signal phase_changed(phase: Phase)
signal turn_started(turn: int)
signal player_turn_ended(turn: int)
signal enemy_turn_started(turn: int)
## intent is the action the enemy just took (its next one is current_intent()).
signal enemy_acted(enemy: Enemy, intent: Dictionary)
signal round_ended(turn: int)
signal energy_changed(energy: int)
signal card_played(card: CardInstance, target: Enemy)
signal card_rejected(card: CardInstance, reason: String)
signal damage_dealt(source: Combatant, target: Combatant, hp_lost: int, blocked: int)
signal discard_requested(count: int)
signal combat_ended(result: String)
signal combat_log(message: String)

const RESULT_NONE := ""
const RESULT_WON := "won"
const RESULT_LOST := "lost"

## Power ids used by Power cards (see data/cards.json).
const POWER_IRON_SKIN := "iron_skin"
const POWER_ENVENOM := "envenom"
const POWER_THORN_ARMOR := "thorn_armor"
const POWER_BLACK_PLAGUE := "black_plague"
const POWER_BERSERKER_RAGE := "berserker_rage"

var player: Combatant
var enemies: Array[Enemy] = []
var piles: CardPiles
var rng: RandomNumberGenerator

var turn: int = 0
var energy: int = 0
var result: String = RESULT_NONE
var phase: Phase = Phase.NOT_STARTED
## True only during the player's turn (kept for older code; prefer `phase`).
var is_player_turn: bool:
	get:
		return phase == Phase.PLAYER_TURN

## When true, end_player_turn() waits for the UI to call next_enemy_action()
## for each enemy. When false (tests, simulation), the whole enemy turn runs at once.
var manual_enemy_turn: bool = false
## Enemies that still have to act this enemy turn, in order.
var _enemy_queue: Array[Enemy] = []

## Active powers: power id -> total amount (playing the same power twice stacks).
var powers: Dictionary = {}
## Sharpen: extra damage on the first hit of the next Attack this turn.
var next_attack_bonus: int = 0
## Bulwark: block gained at the start of the next player turn.
var pending_block_next_turn: int = 0
## Quick Thinking: cards the player still has to discard (UI calls choose_discard()).
var pending_discards: int = 0
## Optional: Callable(hand: Array[CardInstance], count: int) -> Array[CardInstance].
## If set, discards are chosen immediately (AI, tests) instead of waiting for the UI.
var discard_chooser: Callable


## Starts the fight and the first player turn.
## player_hp carries over from the run; pass -1 for full HP.
func start(deck: Deck, player_hp: int, p_enemies: Array, p_rng: RandomNumberGenerator = null,
		player_max_hp: int = -1) -> void:
	rng = p_rng if p_rng != null else RandomNumberGenerator.new()
	var max_hp := player_max_hp if player_max_hp > 0 else GameRules.player_max_hp()
	player = Combatant.new("Player", max_hp, player_hp)
	enemies.clear()
	for e in p_enemies:
		enemies.append(e)
	piles = CardPiles.new(deck, rng)
	turn = 0
	result = RESULT_NONE
	powers.clear()
	next_attack_bonus = 0
	pending_block_next_turn = 0
	pending_discards = 0
	_enemy_queue.clear()
	phase = Phase.NOT_STARTED
	_start_player_turn()


func is_over() -> bool:
	return result != RESULT_NONE


func living_enemies() -> Array[Enemy]:
	var out: Array[Enemy] = []
	for e in enemies:
		if e.is_alive():
			out.append(e)
	return out


func get_power(power_id: String) -> int:
	return int(powers.get(power_id, 0))


# ---------------------------------------------------------------- turns

func _start_player_turn() -> void:
	if is_over():
		return
	turn += 1
	_set_phase(Phase.PLAYER_TURN)
	player.clear_block()
	player.tick_poison()
	if _check_end():
		return
	energy = GameRules.energy_per_turn() + get_power(POWER_BERSERKER_RAGE)
	energy_changed.emit(energy)
	if pending_block_next_turn > 0:
		player_gain_block(pending_block_next_turn)
		pending_block_next_turn = 0
	if get_power(POWER_IRON_SKIN) > 0:
		player_gain_block(get_power(POWER_IRON_SKIN))
	if get_power(POWER_BLACK_PLAGUE) > 0:
		for e in living_enemies():
			e.add_status(Combatant.POISON, get_power(POWER_BLACK_PLAGUE))
	piles.draw(GameRules.cards_drawn_per_turn())
	turn_started.emit(turn)
	_log("Turn %d: %d energy, %d cards in hand" % [turn, energy, piles.hand.size()])


## Why the player can't end the turn right now, or "" if they can.
## Use it to grey out the End Turn button.
func why_cannot_end_turn() -> String:
	if is_over():
		return "The fight is over."
	if phase != Phase.PLAYER_TURN:
		return "It's not your turn."
	if pending_discards > 0:
		return "Choose a card to discard first."
	return ""


func can_end_turn() -> bool:
	return why_cannot_end_turn() == ""


## Ends the player's turn and starts the enemy turn. Unless manual_enemy_turn
## is set, the enemies all act and the next player turn starts before this
## returns. Returns false (and does nothing) if the turn can't end yet.
func end_player_turn() -> bool:
	if not can_end_turn():
		return false
	piles.discard_hand()
	next_attack_bonus = 0
	player_turn_ended.emit(turn)
	_start_enemy_turn()
	if not manual_enemy_turn:
		while next_enemy_action():
			pass
	return true


func _start_enemy_turn() -> void:
	_set_phase(Phase.ENEMY_TURN)
	_enemy_queue = living_enemies()
	enemy_turn_started.emit(turn)


## One step of the enemy turn: the next living enemy loses its block, takes
## Poison, and (if it survives) does its intent. Returns true after an enemy
## takes its step, so call it again. When no enemies are left to act, it ends
## the round, starts the player's next turn and returns false. Also returns
## false if it isn't the enemy turn or the fight ended.
func next_enemy_action() -> bool:
	if phase != Phase.ENEMY_TURN:
		return false
	while not _enemy_queue.is_empty():
		var e: Enemy = _enemy_queue.pop_front()
		if not e.is_alive():
			continue
		e.clear_block()
		e.tick_poison()
		if _check_end():
			return false
		if e.is_alive():
			var intent := e.current_intent()
			_do_intent(e, intent)
			enemy_acted.emit(e, intent)
			if _check_end():
				return false
		return true
	_end_round()
	return false


func _end_round() -> void:
	for e in living_enemies():
		e.decrement_turn_statuses()
		e.advance_intent()
	player.decrement_turn_statuses()
	round_ended.emit(turn)
	_start_player_turn()


func _do_intent(e: Enemy, intent: Dictionary) -> void:
	var amount := int(intent.get("amount", 0))
	match intent.get("type", ""):
		Enemy.INTENT_ATTACK:
			var hits := int(intent.get("hits", 1))
			_log("%s attacks for %d%s" % [e.display_name, amount, " x%d" % hits if hits > 1 else ""])
			for i in hits:
				deal_attack_damage(e, player, amount, 0)
		Enemy.INTENT_BLOCK:
			_log("%s blocks %d" % [e.display_name, amount])
			e.gain_block(amount)
		Enemy.INTENT_BUFF:
			var status: String = intent.get("status", Combatant.STRENGTH)
			_log("%s gains %d %s" % [e.display_name, amount, status])
			e.add_status(status, amount, true)
		Enemy.INTENT_DEBUFF:
			var status: String = intent.get("status", Combatant.WEAK)
			_log("%s applies %d %s" % [e.display_name, amount, status])
			# Applied during the enemy turn, so it skips this round's countdown.
			player.add_status(status, amount, true)


# ---------------------------------------------------------------- playing cards

## Why a card can't be played right now, or "" if it can.
func why_cannot_play(card: CardInstance, target_index: int = -1) -> String:
	if is_over():
		return "The fight is over."
	if phase != Phase.PLAYER_TURN:
		return "It's not your turn."
	if pending_discards > 0:
		return "Choose a card to discard first."
	if not piles.hand.has(card):
		return "That card isn't in your hand."
	if card.get_cost() > energy:
		return "Not enough energy."
	if card.targets_enemy():
		if target_index < 0 or target_index >= enemies.size() or not enemies[target_index].is_alive():
			return "Choose an enemy."
	return ""


func can_play(card: CardInstance, target_index: int = -1) -> bool:
	return why_cannot_play(card, target_index) == ""


## Plays a card from the hand. target_index is the enemy index for cards
## that target an enemy (ignored otherwise). Returns true if it was played.
func play_card(card: CardInstance, target_index: int = -1) -> bool:
	var reason := why_cannot_play(card, target_index)
	if reason != "":
		card_rejected.emit(card, reason)
		return false
	var target: Enemy = enemies[target_index] if card.targets_enemy() else null
	piles.take_from_hand(card)
	energy -= card.get_cost()
	energy_changed.emit(energy)
	_log("Played %s" % card.get_name())
	var attack_bonus := 0
	if card.is_attack():
		attack_bonus = next_attack_bonus
		next_attack_bonus = 0
	EffectResolver.resolve(self, card, target, attack_bonus)
	piles.send_played_card(card)
	card_played.emit(card, target)
	_check_end()
	return true


## The UI calls this once per card when pending_discards > 0.
func choose_discard(card: CardInstance) -> bool:
	if pending_discards <= 0 or not piles.discard_from_hand(card):
		return false
	pending_discards -= 1
	return true


## Called by EffectResolver for the "discard" effect.
func request_discard(count: int) -> void:
	count = mini(count, piles.hand.size())
	if count <= 0:
		return
	if discard_chooser.is_valid():
		var picks: Array = discard_chooser.call(piles.hand.duplicate(), count)
		for c in picks.slice(0, count):
			piles.discard_from_hand(c)
	else:
		pending_discards += count
		discard_requested.emit(count)


# ---------------------------------------------------------------- damage

## Attack damage after Strength, Sharpen, Weak and Vulnerable (rounded down).
func calculate_attack_damage(attacker: Combatant, defender: Combatant, base: int, bonus: int = 0) -> int:
	var dmg := float(base + attacker.get_status(Combatant.STRENGTH) + bonus)
	if attacker.has_status(Combatant.WEAK):
		dmg *= GameRules.weak_multiplier()
	if defender.has_status(Combatant.VULNERABLE):
		dmg *= GameRules.vulnerable_multiplier()
	return maxi(0, floori(dmg))


## An attack hit. Returns the HP the defender lost.
## from_attack_card: true when the hit comes from one of the player's Attack
## cards (Envenom only triggers on those).
func deal_attack_damage(attacker: Combatant, defender: Combatant, base: int, bonus: int = 0,
		multiplier: int = 1, from_attack_card: bool = false) -> int:
	if not defender.is_alive():
		return 0
	var dmg := calculate_attack_damage(attacker, defender, base, bonus) * multiplier
	var block_before := defender.block
	var lost := defender.take_damage(dmg)
	damage_dealt.emit(attacker, defender, lost, block_before - defender.block)
	# Envenom: the player's Attack cards that get through block apply Poison.
	if from_attack_card and lost > 0 and defender.is_alive() and get_power(POWER_ENVENOM) > 0:
		defender.add_status(Combatant.POISON, get_power(POWER_ENVENOM))
	return lost


## Damage that isn't an attack (Thorn Armor): no Strength, Weak or Vulnerable.
func _direct_damage(source: Combatant, defender: Combatant, amount: int) -> int:
	if not defender.is_alive():
		return 0
	var block_before := defender.block
	var lost := defender.take_damage(amount)
	damage_dealt.emit(source, defender, lost, block_before - defender.block)
	return lost


## Every way the player gains block goes through here so Thorn Armor triggers.
func player_gain_block(amount: int) -> int:
	var gained := player.gain_block(amount)
	if gained > 0 and get_power(POWER_THORN_ARMOR) > 0:
		var targets := living_enemies()
		if not targets.is_empty():
			var t := targets[rng.randi_range(0, targets.size() - 1)]
			_direct_damage(player, t, get_power(POWER_THORN_ARMOR))
	return gained


func random_living_enemy() -> Enemy:
	var targets := living_enemies()
	if targets.is_empty():
		return null
	return targets[rng.randi_range(0, targets.size() - 1)]


# ---------------------------------------------------------------- end of fight

func _check_end() -> bool:
	if is_over():
		return true
	if not player.is_alive():
		_finish(RESULT_LOST)
	elif living_enemies().is_empty():
		_finish(RESULT_WON)
	return is_over()


func _finish(r: String) -> void:
	result = r
	_enemy_queue.clear()
	_set_phase(Phase.OVER)
	_log("Combat %s on turn %d" % [r, turn])
	combat_ended.emit(r)


func _set_phase(p: Phase) -> void:
	if phase == p:
		return
	phase = p
	phase_changed.emit(p)


func _log(msg: String) -> void:
	combat_log.emit(msg)
