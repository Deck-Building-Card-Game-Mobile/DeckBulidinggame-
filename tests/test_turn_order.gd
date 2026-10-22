extends TestCase
## Turn order, phases, the stepped enemy turn, and how long Weak / Vulnerable last.


func _fight(enemies: Array, player_hp: int = 70, manual: bool = false) -> CombatState:
	var c := CombatState.new()
	c.manual_enemy_turn = manual
	var rng := RandomNumberGenerator.new()
	rng.seed = 1
	c.start(Deck.new(), player_hp, enemies, rng)
	return c


func _enemy(n: String, hp: int, intents: Array) -> Enemy:
	return Enemy.new(n, hp, intents)


func _play(c: CombatState, id: String, target: int = 0) -> void:
	var card := CardInstance.new(id)
	c.piles.hand.append(card)
	check(c.play_card(card, target), "could not play %s: %s" % [id, c.why_cannot_play(card, target)])


## Records every turn-order signal as a short string, in order.
func _record(c: CombatState) -> Array[String]:
	var log: Array[String] = []
	c.turn_started.connect(func(t): log.append("turn_started %d" % t))
	c.player_turn_ended.connect(func(t): log.append("player_turn_ended %d" % t))
	c.enemy_turn_started.connect(func(t): log.append("enemy_turn_started %d" % t))
	c.enemy_acted.connect(func(e, intent): log.append("enemy_acted %s %s" % [e.display_name, intent["type"]]))
	c.round_ended.connect(func(t): log.append("round_ended %d" % t))
	c.combat_ended.connect(func(r): log.append("combat_ended %s" % r))
	return log


# ---------------------------------------------------------------- phases

func test_phase_follows_the_round() -> void:
	var c := _fight([_enemy("A", 100, [{"type": "block", "amount": 3}])], 70, true)
	check_eq(c.phase, CombatState.Phase.PLAYER_TURN)
	check(c.is_player_turn, "is_player_turn still works")
	check(c.end_player_turn(), "turn ends")
	check_eq(c.phase, CombatState.Phase.ENEMY_TURN)
	check(not c.is_player_turn)
	check(c.next_enemy_action(), "A acts")
	check(not c.next_enemy_action(), "round ends")
	check_eq(c.phase, CombatState.Phase.PLAYER_TURN)
	check_eq(c.turn, 2)


func test_signal_order_in_one_round() -> void:
	var c := _fight([
		_enemy("A", 100, [{"type": "attack", "amount": 5}]),
		_enemy("B", 100, [{"type": "block", "amount": 4}]),
	])
	var log := _record(c)
	c.end_player_turn()
	check_eq(log, [
		"player_turn_ended 1",
		"enemy_turn_started 1",
		"enemy_acted A attack",
		"enemy_acted B block",
		"round_ended 1",
		"turn_started 2",
	] as Array[String])


func test_manual_enemy_turn_steps_one_enemy_at_a_time() -> void:
	var c := _fight([
		_enemy("A", 100, [{"type": "attack", "amount": 5}]),
		_enemy("B", 100, [{"type": "attack", "amount": 7}]),
	], 70, true)
	c.end_player_turn()
	check_eq(c.player.hp, 70, "nobody has acted yet")
	check(c.next_enemy_action())
	check_eq(c.player.hp, 65, "only A has acted")
	check(c.next_enemy_action())
	check_eq(c.player.hp, 58, "B has acted")
	check_eq(c.turn, 1, "still the enemy turn until the next call")
	check(not c.next_enemy_action(), "no one left")
	check_eq(c.turn, 2)
	check(not c.next_enemy_action(), "does nothing during the player turn")


func test_cannot_act_during_enemy_turn() -> void:
	var c := _fight([_enemy("A", 100, [{"type": "attack", "amount": 5}])], 70, true)
	c.end_player_turn()
	var card := CardInstance.new("S01")
	c.piles.hand.append(card)
	check_eq(c.why_cannot_play(card, 0), "It's not your turn.")
	check_eq(c.why_cannot_end_turn(), "It's not your turn.")
	check(not c.end_player_turn(), "can't end the turn twice")


func test_cannot_end_turn_while_discard_pending() -> void:
	var c := _fight([_enemy("A", 100, [{"type": "attack", "amount": 5}])])
	c.piles.hand.append(CardInstance.new("S01"))
	c.request_discard(1)
	check_eq(c.why_cannot_end_turn(), "Choose a card to discard first.")
	check(not c.can_end_turn())


func test_enemy_dying_to_poison_does_not_act() -> void:
	var c := _fight([
		_enemy("A", 3, [{"type": "attack", "amount": 20}]),
		_enemy("B", 100, [{"type": "attack", "amount": 5}]),
	], 70, true)
	c.enemies[0].add_status(Combatant.POISON, 5)
	var log := _record(c)
	c.end_player_turn()
	check(c.next_enemy_action(), "A's step: dies to Poison")
	check(not c.enemies[0].is_alive())
	check_eq(c.player.hp, 70, "A never attacked")
	check(c.next_enemy_action(), "B's step")
	check_eq(c.player.hp, 65)
	check(not log.has("enemy_acted A attack"))


func test_last_enemy_dying_to_poison_wins() -> void:
	var c := _fight([_enemy("A", 3, [{"type": "attack", "amount": 20}])], 70, true)
	c.enemies[0].add_status(Combatant.POISON, 5)
	c.end_player_turn()
	check(not c.next_enemy_action())
	check_eq(c.result, CombatState.RESULT_WON)
	check_eq(c.phase, CombatState.Phase.OVER)
	check_eq(c.player.hp, 70)


func test_player_dying_stops_the_enemy_turn() -> void:
	var c := _fight([
		_enemy("A", 100, [{"type": "attack", "amount": 10}]),
		_enemy("B", 100, [{"type": "block", "amount": 5}]),
	], 8)
	var log := _record(c)
	c.end_player_turn()
	check_eq(c.result, CombatState.RESULT_LOST)
	check_eq(c.phase, CombatState.Phase.OVER)
	check(not log.has("enemy_acted B block"), "B never acts")
	check(not log.has("turn_started 2"), "no next turn")
	check_eq(c.enemies[1].block, 0)


# ---------------------------------------------------------------- Weak / Vulnerable duration

func test_enemy_vulnerable_1_lasts_through_next_enemy_turn() -> void:
	var c := _fight([_enemy("A", 100, [
		{"type": "debuff", "status": "vulnerable", "amount": 1},
		{"type": "attack", "amount": 10},
	])])
	c.end_player_turn()
	check_eq(c.player.get_status(Combatant.VULNERABLE), 1, "still on at the start of your turn")
	c.end_player_turn()
	check_eq(c.player.hp, 55, "10 x 1.5")
	check_eq(c.player.get_status(Combatant.VULNERABLE), 0, "worn off after that enemy turn")


func test_enemy_weak_1_lasts_exactly_one_player_turn() -> void:
	var c := _fight([_enemy("A", 100, [
		{"type": "debuff", "status": "weak", "amount": 1},
		{"type": "block", "amount": 0},
	])])
	c.end_player_turn()
	_play(c, "S01")
	check_eq(c.enemies[0].hp, 96, "floor(6 x 0.75)")
	c.end_player_turn()
	check_eq(c.player.get_status(Combatant.WEAK), 0)
	_play(c, "S01")
	check_eq(c.enemies[0].hp, 90, "full damage next turn")


func test_player_vulnerable_on_enemy_still_lasts_one_round() -> void:
	# Lantern Bash: 1 Vulnerable on the enemy covers the rest of your turn and
	# the enemy's turn, then wears off. Unchanged by the countdown skip.
	var c := _fight([_enemy("A", 100, [{"type": "block", "amount": 0}])])
	c.enemies[0].add_status(Combatant.VULNERABLE, 1)
	_play(c, "S01")
	check_eq(c.enemies[0].hp, 91, "6 x 1.5")
	c.end_player_turn()
	check_eq(c.enemies[0].get_status(Combatant.VULNERABLE), 0)


func test_countdown_skip_is_used_once() -> void:
	var p := Combatant.new("P", 50)
	p.add_status(Combatant.VULNERABLE, 2, true)
	p.decrement_turn_statuses()
	check_eq(p.get_status(Combatant.VULNERABLE), 2, "skipped")
	p.decrement_turn_statuses()
	check_eq(p.get_status(Combatant.VULNERABLE), 1)
	p.decrement_turn_statuses()
	check_eq(p.get_status(Combatant.VULNERABLE), 0)
