extends TestCase
## Every card in the set, played in a real CombatState, does what its text says.

var combat: CombatState
var dummy: Enemy


func before_each() -> void:
	combat = _fight([_dummy()])
	dummy = combat.enemies[0]


func _dummy(hp: int = 100, intents: Array = [{"type": "attack", "amount": 6}]) -> Enemy:
	return Enemy.new("Dummy", hp, intents)


## A fight with an empty deck so each test controls the hand exactly.
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


# ------------------------------------------------------------ starters

func test_strike() -> void:
	_play("S01")
	check_eq(dummy.hp, 94)
	check_eq(combat.energy, 2)
	_play("S01", 0, true)
	check_eq(dummy.hp, 85)


func test_defend() -> void:
	_play("S02")
	check_eq(combat.player.block, 5)
	_play("S02", 0, true)
	check_eq(combat.player.block, 13)


func test_lantern_bash() -> void:
	_play("S03")
	check_eq(dummy.hp, 95)
	check_eq(dummy.get_status("vulnerable"), 1)
	_play("S01")
	check_eq(dummy.hp, 86, "Strike on Vulnerable: 6 x 1.5 = 9")


# ------------------------------------------------------------ commons

func test_slash_and_heavy_swing() -> void:
	_play("C01")
	check_eq(dummy.hp, 91)
	_play("C04")
	check_eq(dummy.hp, 76)
	check_eq(combat.energy, 0)


func test_quick_jab_is_free() -> void:
	_play("C02")
	check_eq(dummy.hp, 97)
	check_eq(combat.energy, 3)


func test_cleave_hits_all() -> void:
	combat = _fight([_dummy(), _dummy(), _dummy(5)])
	_play("C03", -1)
	check_eq(combat.enemies[0].hp, 94)
	check_eq(combat.enemies[1].hp, 94)
	check(not combat.enemies[2].is_alive())


func test_twin_strike_hits_twice_with_strength() -> void:
	_play("C05")
	check_eq(dummy.hp, 92)
	combat.player.add_status("strength", 2)
	_play("C05")
	check_eq(dummy.hp, 80, "(4 + 2) x 2")


func test_poisoned_blade_and_venom_fang() -> void:
	_play("C06")
	check_eq(dummy.hp, 97)
	check_eq(dummy.get_status("poison"), 4)
	_play("C08")
	check_eq(dummy.get_status("poison"), 6)
	check_eq(combat.energy, 2)


func test_shield_slam() -> void:
	_play("C07")
	check_eq(dummy.hp, 96)
	check_eq(combat.player.block, 4)


func test_pommel_strike_draws() -> void:
	_stock_draw_pile(3)
	_play("C09")
	check_eq(dummy.hp, 95)
	check_eq(combat.piles.hand.size(), 1)


func test_torch_swing() -> void:
	_play("C10", 0, true)
	check_eq(dummy.hp, 92)
	check_eq(dummy.get_status("vulnerable"), 2)


func test_block_cards() -> void:
	_play("C11")
	check_eq(combat.player.block, 7)
	_play("C12")
	check_eq(combat.player.block, 19)


func test_dodge_roll() -> void:
	_stock_draw_pile(2)
	_play("C13")
	check_eq(combat.player.block, 4)
	check_eq(combat.piles.hand.size(), 1)


func test_toxic_vial() -> void:
	_play("C14")
	check_eq(dummy.get_status("poison"), 6)


func test_bandage_heals_and_exhausts() -> void:
	combat = _fight([_dummy()], 50)
	var card := _play("C15", -1)
	check_eq(combat.player.hp, 54)
	check_eq(combat.player.block, 4)
	check(combat.piles.exhaust_pile.has(card))
	check(not combat.piles.discard_pile.has(card))


func test_heal_cannot_exceed_max() -> void:
	combat = _fight([_dummy()], 69)
	_play("R05", -1)
	check_eq(combat.player.hp, 70)


func test_scout_ahead() -> void:
	_stock_draw_pile(5)
	_play("C16", -1, true)
	check_eq(combat.piles.hand.size(), 3)


func test_smoke_bomb_weakens_all_enemies() -> void:
	combat = _fight([_dummy(), _dummy()])
	_play("C17", -1)
	for e in combat.enemies:
		check_eq(e.get_status("weak"), 2)
	combat.end_player_turn()
	check_eq(combat.player.hp, 62, "two weak attacks: floor(6 x 0.75) = 4 each")
	check_eq(combat.enemies[0].get_status("weak"), 1)


func test_sharpen_boosts_next_attack_only() -> void:
	_play("C18", -1)
	check_eq(combat.energy, 3)
	_play("S02", -1)                     # a Skill doesn't use the bonus
	_play("S01")
	check_eq(dummy.hp, 91, "6 + 3")
	_play("S01")
	check_eq(dummy.hp, 85, "bonus is used up")


func test_sharpen_expires_at_end_of_turn() -> void:
	_play("C18", -1)
	combat.end_player_turn()
	check_eq(combat.next_attack_bonus, 0)


func test_sharpen_only_first_hit_of_twin_strike() -> void:
	_play("C18", -1)
	_play("C05")
	check_eq(dummy.hp, 89, "7 + 4")


func test_deep_breath() -> void:
	_stock_draw_pile(3)
	var card := _play("C19", -1)
	check_eq(combat.piles.hand.size(), 1)
	check(combat.piles.exhaust_pile.has(card))


func test_stand_firm() -> void:
	_play("C20")
	check_eq(combat.player.block, 5)
	check_eq(dummy.get_status("weak"), 1)


# ------------------------------------------------------------ uncommons

func test_expose() -> void:
	_play("U01")
	check_eq(dummy.hp, 95)
	check_eq(dummy.get_status("vulnerable"), 2)


func test_shield_bash() -> void:
	_play("U02")
	check_eq(dummy.hp, 92)
	check_eq(combat.player.block, 7)


func test_whirling_blade_and_venom_cloud() -> void:
	combat = _fight([_dummy(), _dummy()])
	_play("U03", -1)
	check_eq(combat.enemies[1].hp, 89)
	combat.energy = 3
	_play("U04", -1)
	check_eq(combat.enemies[0].get_status("poison"), 7)
	check_eq(combat.enemies[1].get_status("poison"), 7)


func test_rally() -> void:
	var card := _play("U05", -1)
	check_eq(combat.energy, 4)
	check(combat.piles.exhaust_pile.has(card))
	_stock_draw_pile(2)
	_play("U05", -1, true)
	check_eq(combat.energy, 5)
	check_eq(combat.piles.hand.size(), 1)


func test_iron_skin_power() -> void:
	var card := _play("U06", -1)
	check(combat.piles.powers_in_play.has(card))
	check_eq(combat.player.block, 0, "not this turn")
	combat.end_player_turn()
	check_eq(combat.player.block, 4)


func test_battle_cry() -> void:
	_stock_draw_pile(2)
	_play("U07", -1)
	check_eq(combat.player.get_status("strength"), 2)
	check_eq(combat.piles.hand.size(), 1)
	_play("S01")
	check_eq(dummy.hp, 92)
	combat.end_player_turn()
	check_eq(combat.player.get_status("strength"), 2, "Strength lasts the whole fight")


func test_bloodletter_heals_on_kill() -> void:
	combat = _fight([_dummy(10), _dummy()], 50)
	_play("U08", 0)
	check(not combat.enemies[0].is_alive())
	check_eq(combat.player.hp, 55)
	combat.energy = 2
	_play("U08", 1)
	check_eq(combat.player.hp, 55, "no kill, no heal")


func test_envenom() -> void:
	_play("U09", -1)
	_play("S01")
	check_eq(dummy.get_status("poison"), 1)
	_play("C05")
	check_eq(dummy.get_status("poison"), 3, "each hit poisons")


func test_envenom_ignores_skills_and_blocked_hits() -> void:
	_play("U09", -1)
	_play("U10")                         # Parry is a Skill
	check_eq(dummy.get_status("poison"), 0)
	dummy.gain_block(20)
	_play("C02")
	check_eq(dummy.get_status("poison"), 0, "fully blocked")


func test_parry_reads_intent() -> void:
	_play("U10")
	check_eq(combat.player.block, 6)
	check_eq(dummy.hp, 95)
	combat = _fight([_dummy(100, [{"type": "block", "amount": 5}])])
	dummy = combat.enemies[0]
	_play("U10")
	check_eq(dummy.hp, 100, "enemy isn't attacking")


func test_reckless_charge_ignores_block() -> void:
	combat.player.gain_block(10)
	_play("U11")
	check_eq(dummy.hp, 92)
	check_eq(combat.player.hp, 68)
	check_eq(combat.energy, 3)


func test_quick_thinking_waits_for_discard_choice() -> void:
	_stock_draw_pile(5)
	var asked := [0]
	combat.discard_requested.connect(func(n): asked[0] = n)
	_play("U12", -1)
	check_eq(combat.piles.hand.size(), 3)
	check_eq(asked[0], 1)
	check_eq(combat.pending_discards, 1)
	var other := _give("S02")
	check(not combat.can_play(other), "must discard first")
	combat.end_player_turn()
	check_eq(combat.turn, 1, "can't end turn while a discard is pending")
	check(combat.choose_discard(combat.piles.hand[0]))
	check_eq(combat.pending_discards, 0)
	check_eq(combat.piles.hand.size(), 3)
	check(combat.can_play(other))


func test_quick_thinking_with_chooser() -> void:
	_stock_draw_pile(5)
	combat.discard_chooser = func(hand: Array, n: int) -> Array: return hand.slice(0, n)
	_play("U12", -1, true)
	check_eq(combat.piles.hand.size(), 3, "drew 4, discarded 1")
	check_eq(combat.pending_discards, 0)


func test_bulwark_blocks_now_and_next_turn() -> void:
	_play("U13", -1)
	check_eq(combat.player.block, 10)
	combat.end_player_turn()
	check_eq(combat.player.hp, 70, "6 damage blocked")
	check_eq(combat.player.block, 5, "old block gone, 5 new")
	combat.end_player_turn()
	check_eq(combat.player.block, 0, "only one turn")


func test_catalyst() -> void:
	_play("C14")
	_play("U14")
	check_eq(dummy.get_status("poison"), 12)
	combat.energy = 1
	_play("U14", 0, true)
	check_eq(dummy.get_status("poison"), 36)


# ------------------------------------------------------------ rares

func test_thorn_armor() -> void:
	combat.energy = 3
	_play("R01", -1)
	_play("S02", -1)
	check_eq(dummy.hp, 97)
	check_eq(combat.player.block, 5)


func test_thorn_armor_triggers_on_iron_skin() -> void:
	combat.energy = 10
	_play("R01", -1)
	_play("U06", -1)
	combat.end_player_turn()
	check_eq(dummy.hp, 97, "Iron Skin block at turn start triggers Thorn Armor")


func test_thorn_armor_ignores_vulnerable_and_strength() -> void:
	combat.energy = 10
	combat.player.add_status("strength", 5)
	dummy.add_status("vulnerable", 2)
	_play("R01", -1)
	_play("S02", -1)
	check_eq(dummy.hp, 97)


func test_adrenaline() -> void:
	_stock_draw_pile(2)
	var card := _play("R02", -1)
	check_eq(combat.energy, 4)
	check_eq(combat.piles.hand.size(), 1)
	check(combat.piles.exhaust_pile.has(card))


func test_executioners_axe() -> void:
	_play("R03")
	check_eq(dummy.hp, 82)
	combat = _fight([_dummy()])
	combat.enemies[0].lose_hp(60)
	dummy = combat.enemies[0]
	_play("R03")
	check_eq(dummy.hp, 4, "40 HP is below half: 36 damage")


func test_black_plague() -> void:
	combat = _fight([_dummy(), _dummy()])
	_play("R04", -1)
	check_eq(combat.enemies[0].get_status("poison"), 0)
	combat.end_player_turn()
	check_eq(combat.enemies[0].get_status("poison"), 3)
	check_eq(combat.enemies[1].get_status("poison"), 3)


func test_phoenix_feather() -> void:
	combat = _fight([_dummy()], 40)
	var card := _play("R05", -1)
	check_eq(combat.player.hp, 47)
	check_eq(combat.player.block, 5)
	check(combat.piles.exhaust_pile.has(card))


func test_berserker_rage() -> void:
	_play("R06", -1)
	check_eq(combat.energy, 2)
	combat.end_player_turn()
	check_eq(combat.energy, 4)
	var free := _give("R06", true)
	check_eq(free.get_cost(), 0)


# ------------------------------------------------------------ rules

func test_needs_energy() -> void:
	combat.energy = 1
	var card := _give("C04")
	check(not combat.play_card(card, 0))
	check_eq(combat.why_cannot_play(card, 0), "Not enough energy.")
	check(combat.piles.hand.has(card))


func test_needs_living_target() -> void:
	combat = _fight([_dummy(1), _dummy()])
	_play("S01", 0)
	var card := _give("S01")
	check(not combat.can_play(card, 0), "dead enemy")
	check(not combat.can_play(card, -1), "no target")
	check(combat.can_play(card, 1))


func test_block_absorbs_then_clears() -> void:
	_play("S02", -1)
	combat.end_player_turn()
	check_eq(combat.player.hp, 69, "6 damage - 5 block")
	check_eq(combat.player.block, 0)


func test_poison_ticks_on_enemy_turn_and_ignores_block() -> void:
	_play("C14")
	dummy.gain_block(10)
	combat.end_player_turn()
	check_eq(dummy.hp, 94)
	check_eq(dummy.get_status("poison"), 5)


func test_vulnerable_wears_off() -> void:
	_play("S03")
	combat.end_player_turn()
	check_eq(dummy.get_status("vulnerable"), 0)


func test_enemy_block_and_buff_intents() -> void:
	combat = _fight([_dummy(100, [{"type": "block", "amount": 8}, {"type": "buff", "status": "strength", "amount": 2}, {"type": "attack", "amount": 5, "hits": 2}])])
	dummy = combat.enemies[0]
	combat.end_player_turn()
	check_eq(dummy.block, 8)
	_play("S01")
	check_eq(dummy.hp, 100)
	check_eq(dummy.block, 2)
	combat.end_player_turn()
	check_eq(dummy.block, 0, "enemy block clears at its turn")
	check_eq(dummy.get_status("strength"), 2)
	combat.end_player_turn()
	check_eq(combat.player.hp, 56, "2 hits of 5 + 2")


func test_weak_on_player() -> void:
	combat = _fight([_dummy(100, [{"type": "debuff", "status": "weak", "amount": 2}])])
	dummy = combat.enemies[0]
	combat.end_player_turn()
	_play("S01")
	check_eq(dummy.hp, 96, "floor(6 x 0.75)")


func test_win_and_loss() -> void:
	combat = _fight([_dummy(5)])
	var ended := [""]
	combat.combat_ended.connect(func(r): ended[0] = r)
	_play("S01")
	check_eq(combat.result, CombatState.RESULT_WON)
	check_eq(ended[0], "won")
	check(not combat.can_play(_give("S01"), 0))
	combat = _fight([_dummy(100, [{"type": "attack", "amount": 50}])], 40)
	combat.end_player_turn()
	check_eq(combat.result, CombatState.RESULT_LOST)


func test_hp_carries_in_from_run() -> void:
	combat = _fight([_dummy()], 33)
	check_eq(combat.player.hp, 33)
	check_eq(combat.player.max_hp, 70)
