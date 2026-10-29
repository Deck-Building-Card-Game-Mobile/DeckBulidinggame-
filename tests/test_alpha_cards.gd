extends TestCase
## The alpha set's new mechanics (Retain, Legendaries, new effects and powers),
## plus a check that every one of the 128 cards can be played, normal and upgraded.

var combat: CombatState
var dummy: Enemy


func before_each() -> void:
	combat = _fight([_dummy()])
	dummy = combat.enemies[0]


func _dummy(hp: int = 100, intents: Array = [{"type": "attack", "amount": 6}]) -> Enemy:
	return Enemy.new("Dummy", hp, intents)


func _fight(enemies: Array, player_hp: int = 70) -> CombatState:
	var c := CombatState.new()
	var rng := RandomNumberGenerator.new()
	rng.seed = 1
	c.start(Deck.new(), player_hp, enemies, rng)
	return c


func _give(id: String, upgraded: bool = false) -> CardInstance:
	var card := CardInstance.new(id, upgraded)
	combat.piles.hand.append(card)
	return card


func _play(id: String, target: int = 0, upgraded: bool = false) -> CardInstance:
	var card := _give(id, upgraded)
	check(combat.play_card(card, target), "could not play %s: %s" % [id, combat.why_cannot_play(card, target)])
	return card


func _stock_draw_pile(n: int) -> void:
	for i in n:
		combat.piles.draw_pile.append(CardInstance.new("S01"))


# ------------------------------------------------------------ every card

func test_every_card_plays_normal_and_upgraded() -> void:
	for data in CardDatabase.get_all_cards():
		for upgraded in [false, true]:
			combat = _fight([_dummy(300), _dummy(300)])
			combat.discard_chooser = func(hand: Array, n: int) -> Array: return hand.slice(0, n)
			_stock_draw_pile(12)
			combat.energy = 10
			var card := _give(data.id, upgraded)
			var label := "%s%s" % [data.id, "+" if upgraded else ""]
			check(combat.play_card(card, 0), "%s: %s" % [label, combat.why_cannot_play(card, 0)])
			check_eq(combat.energy, 10 - card.get_cost() + _energy_gained(card), "energy after %s" % label)
			if card.is_power():
				check(combat.piles.powers_in_play.has(card), "%s should stay in play" % label)
			elif card.is_exhaust():
				check(combat.piles.exhaust_pile.has(card), "%s should exhaust" % label)
			else:
				check(combat.piles.discard_pile.has(card), "%s should be discarded" % label)
			var cards := combat.piles.total_cards()
			combat.end_player_turn()
			combat.end_player_turn()
			check_eq(combat.piles.total_cards(), cards, "%s: cards lost over two turns" % label)


func _energy_gained(card: CardInstance) -> int:
	var n := 0
	for e in card.get_effects():
		if e["op"] == "gain_energy":
			n += int(e["amount"])
	return n


# ------------------------------------------------------------ Retain

func test_retain_card_stays_in_hand() -> void:
	_stock_draw_pile(10)                  # so the discarded card isn't reshuffled back in
	var keep := _give("C33")
	var other := _give("S01")
	combat.end_player_turn()
	check(combat.piles.hand.has(keep), "Hunker Down kept")
	check(combat.piles.discard_pile.has(other), "Strike discarded as normal")
	check_eq(combat.piles.hand.size(), 6, "5 new cards + the retained one")


func test_master_plan_keeps_whole_hand() -> void:
	_play("R19", -1)
	var a := _give("S01")
	var b := _give("S02")
	combat.end_player_turn()
	check(combat.piles.hand.has(a) and combat.piles.hand.has(b))


# ------------------------------------------------------------ commons / uncommons

func test_buckler_bash_uses_block() -> void:
	combat.player.gain_block(10)
	_play("C34")
	check_eq(dummy.hp, 90)
	combat.player.add_status("strength", 2)
	combat.energy = 1
	_play("C34")
	check_eq(dummy.hp, 78, "block 10 + 2 Strength")


func test_rebuke_reads_intent() -> void:
	_play("C39")
	check_eq(combat.player.block, 4)
	check_eq(dummy.get_status("weak"), 2)
	combat = _fight([_dummy(100, [{"type": "block", "amount": 5}])])
	dummy = combat.enemies[0]
	_play("C39")
	check_eq(dummy.get_status("weak"), 0, "enemy isn't attacking")


func test_steadfast_blocks_now_and_next_turn() -> void:
	_play("C38", -1)
	check_eq(combat.player.block, 5)
	combat.end_player_turn()
	check_eq(combat.player.block, 3)


func test_wild_swing_hits_a_random_enemy() -> void:
	combat = _fight([_dummy(), _dummy()])
	_play("C32", -1)
	var total_lost := 200 - combat.enemies[0].hp - combat.enemies[1].hp
	check_eq(total_lost, 12)


func test_energy_next_turn() -> void:
	_play("U36", -1)
	check_eq(combat.player.block, 4)
	combat.end_player_turn()
	check_eq(combat.energy, 4)
	combat.end_player_turn()
	check_eq(combat.energy, 3, "only one turn")


func test_entrench_doubles_block_and_triggers_thorn_armor() -> void:
	combat.energy = 10
	_play("R01", -1)                  # Thorn Armor
	combat.player.gain_block(7)
	_play("U23", -1)
	check_eq(combat.player.block, 14)
	check_eq(dummy.hp, 97, "gaining block from Entrench triggers Thorn Armor")


func test_bane_bonus_against_poisoned() -> void:
	_play("U29")
	check_eq(dummy.hp, 93)
	dummy.add_status("poison", 1)
	_play("U29")
	check_eq(dummy.hp, 79, "7 + 7")


func test_exploit_weakness_bonus_against_vulnerable() -> void:
	_play("R22")
	check_eq(dummy.hp, 92)
	dummy.add_status("vulnerable", 1)
	combat.energy = 1
	_play("R22")
	check_eq(dummy.hp, 68, "(8 + 8) x 1.5")


func test_venom_burst_damage_equals_poison() -> void:
	dummy.add_status("poison", 9)
	_play("U34")
	check_eq(dummy.hp, 91)
	check_eq(dummy.get_status("poison"), 9, "Poison isn't used up")


func test_map_of_the_depths_draws_extra() -> void:
	_stock_draw_pile(10)
	_play("U17", -1)
	combat.end_player_turn()
	check_eq(combat.piles.hand.size(), 6)


func test_bloodlust_gains_strength_every_turn() -> void:
	_play("U19", -1)
	combat.end_player_turn()
	check_eq(combat.player.get_status("strength"), 1)
	combat.end_player_turn()
	check_eq(combat.player.get_status("strength"), 2)


func test_toxic_aura() -> void:
	_play("U28", -1)
	combat.end_player_turn()
	check_eq(dummy.get_status("poison"), 1)


# ------------------------------------------------------------ rares

func test_limit_break_doubles_strength() -> void:
	combat.player.add_status("strength", 3)
	var card := _play("R09", -1)
	check_eq(combat.player.get_status("strength"), 6)
	check(combat.piles.exhaust_pile.has(card))
	var up := _play("R09", -1, true)
	check_eq(combat.player.get_status("strength"), 12)
	check(combat.piles.discard_pile.has(up), "upgraded Limit Break doesn't exhaust")


func test_barricade_keeps_block() -> void:
	_play("R12", -1)
	combat.player.gain_block(20)
	combat.end_player_turn()
	check_eq(combat.player.block, 14, "20 - 6 from the attack, nothing removed")
	check_eq(combat.player.hp, 70)


func test_pandemic() -> void:
	combat = _fight([_dummy(), _dummy()])
	combat.enemies[1].add_status("poison", 3)
	_play("R15", -1)
	check_eq(combat.enemies[0].get_status("poison"), 4)
	check_eq(combat.enemies[1].get_status("poison"), 10, "(3 + 2) x 2")


func test_malignancy_boosts_every_poison() -> void:
	combat.energy = 10
	_play("R16", -1)
	_play("C14")                      # Toxic Vial: 6 Poison
	check_eq(dummy.get_status("poison"), 7)
	_play("U09", -1)                  # Envenom
	_play("S01")
	check_eq(dummy.get_status("poison"), 9, "Envenom 1 + 1")
	_play("R04", -1)                  # Black Plague
	combat.end_player_turn()
	check_eq(dummy.get_status("poison"), 12, "8 after the tick, then Black Plague 3 + 1")


func test_explorers_kit() -> void:
	_stock_draw_pile(10)
	_play("R08", -1)
	combat.end_player_turn()
	check_eq(combat.player.block, 3)
	check_eq(combat.piles.hand.size(), 6)


# ------------------------------------------------------------ legendaries

func test_avatar_of_rage() -> void:
	combat.energy = 10
	_play("L01", -1)
	_play("S01")
	check_eq(dummy.hp, 88, "Strike x 2")
	_play("U10")                      # Parry is a Skill: not doubled
	check_eq(dummy.hp, 83)
	combat.end_player_turn()
	check_eq(combat.player.hp, 68, "Parry's 6 block stops the attack, then lose 2 at turn start")


func test_echo_strike_plays_next_attack_twice() -> void:
	_play("L02", -1)
	_play("S02", -1)                  # a Skill doesn't use the echo
	_play("S01")
	check_eq(dummy.hp, 88)
	combat.energy = 1
	_play("S01")
	check_eq(dummy.hp, 82, "echo used up")


func test_echo_with_sharpen_and_expiry() -> void:
	_play("C18", -1)                  # Sharpen +3
	_play("L02", -1)
	_play("S01")
	check_eq(dummy.hp, 85, "(6 + 3) then 6")
	_play("L02", -1, true)
	combat.end_player_turn()
	check_eq(combat.echo_attacks, 0, "echo expires at end of turn")


func test_unbreakable() -> void:
	combat = _fight([_dummy(100, [{"type": "attack", "amount": 50}])])
	var card := _play("L03", -1)
	check_eq(combat.player.block, 12)
	check(combat.player.invulnerable)
	check(combat.piles.exhaust_pile.has(card))
	combat.end_player_turn()
	check_eq(combat.player.hp, 70)
	check(not combat.player.invulnerable, "ends at the start of your next turn")
	combat.end_player_turn()
	check_eq(combat.player.hp, 20)


func test_eternal_bulwark() -> void:
	combat.energy = 3
	_play("L04", -1)
	combat.end_player_turn()
	check_eq(combat.player.block, 5)
	check_eq(combat.player.hp, 64, "no block yet on turn 1")
	combat.end_player_turn()
	check_eq(combat.player.hp, 63, "5 block soaks most of the 6")
	check_eq(combat.player.block, 5, "nothing left over, +5 new")
	combat.player.gain_block(10)
	combat.end_player_turn()
	check_eq(combat.player.block, 14, "15 - 6 attack, kept, +5")


func test_heart_of_the_hydra() -> void:
	_play("L05", -1)
	dummy.add_status("poison", 5)
	combat.end_player_turn()
	combat.end_player_turn()
	check_eq(dummy.get_status("poison"), 5)
	check_eq(dummy.hp, 90)


func test_plaguebearers_kiss() -> void:
	_play("L06")
	check_eq(dummy.hp, 95)
	check_eq(dummy.get_status("poison"), 15)


func test_chronomancers_hourglass() -> void:
	_play("L07", -1)
	combat.end_player_turn()
	check_eq(combat.turn, 2)
	check_eq(combat.player.hp, 70, "enemy didn't act")
	check(combat.is_player_turn)
	combat.end_player_turn()
	check_eq(combat.player.hp, 64, "normal turn after the extra one")


func test_grand_strategist() -> void:
	_stock_draw_pile(10)
	_play("L08", -1)
	combat.end_player_turn()
	check_eq(combat.energy, 4)
	check_eq(combat.piles.hand.size(), 6)
