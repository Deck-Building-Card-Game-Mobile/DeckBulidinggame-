extends TestCase
## Card data matches the design spreadsheet and is internally consistent.

const KNOWN_OPS := ["damage", "block", "heal", "draw", "gain_energy", "lose_hp", "apply_status",
	"multiply_status", "next_attack_bonus", "block_next_turn", "discard", "power",
	"energy_next_turn", "multiply_block", "echo_next_attack", "invulnerable", "extra_turn"]
const KNOWN_POWERS := ["iron_skin", "envenom", "thorn_armor", "black_plague", "berserker_rage",
	"draw_per_turn", "strength_per_turn", "barricade", "poison_boost", "retain_hand",
	"double_attack_damage", "hp_loss_per_turn", "poison_no_decay"]
const KNOWN_STATUSES := ["poison", "weak", "vulnerable", "strength"]


func test_card_counts_match_sheet() -> void:
	check_eq(CardDatabase.get_all_cards().size(), 128)
	check_eq(CardDatabase.get_cards_by_rarity("Starter").size(), 3)
	check_eq(CardDatabase.get_cards_by_rarity("Common").size(), 55)
	check_eq(CardDatabase.get_cards_by_rarity("Uncommon").size(), 40)
	check_eq(CardDatabase.get_cards_by_rarity("Rare").size(), 22)
	check_eq(CardDatabase.get_cards_by_rarity("Legendary").size(), 8)
	check_eq(CardDatabase.get_reward_pool().size(), 125)


func test_archetype_counts() -> void:
	var counts := {}
	for c in CardDatabase.get_all_cards():
		counts[c.archetype] = counts.get(c.archetype, 0) + 1
	check_eq(counts.keys().size(), 5, "Neutral + 4 archetypes")
	check_eq(counts.get("Neutral", 0), 16)
	for a in ["Brawler", "Guardian", "Venom", "Tactician"]:
		check_eq(counts.get(a, 0), 28, a)


func test_legendaries_are_unique() -> void:
	for c in CardDatabase.get_all_cards():
		check_eq(c.unique, c.is_legendary(), "Unique flag on %s" % c.id)
		if c.unique:
			check("Unique" in c.keywords, "%s missing Unique keyword" % c.id)
	var by_arch := {}
	for c in CardDatabase.get_cards_by_rarity("Legendary"):
		by_arch[c.archetype] = by_arch.get(c.archetype, 0) + 1
	check_eq(by_arch, {"Brawler": 2, "Guardian": 2, "Venom": 2, "Tactician": 2})


func test_retain_cards_show_the_keyword() -> void:
	var n := 0
	for c in CardDatabase.get_all_cards():
		if c.retain:
			n += 1
			check("Retain" in c.keywords, "%s missing Retain keyword" % c.id)
			check(c.text.contains("Retain"), "%s text doesn't say Retain" % c.id)
	check_eq(n, 10)


func test_every_card_is_well_formed() -> void:
	for c in CardDatabase.get_all_cards():
		check(c.name != "" and c.text != "" and c.upgraded_text != "", "%s missing text" % c.id)
		check(c.type in ["Attack", "Skill", "Power"], "%s bad type" % c.id)
		check(c.cost >= 0 and c.cost <= 3, "%s bad cost" % c.id)
		check(not c.effects.is_empty() and not c.upgraded_effects.is_empty(), "%s has no effects" % c.id)
		check(c.upgraded_effects != c.effects or c.upgraded_cost != c.cost or c.upgraded_exhaust != c.exhaust,
			"%s upgrade does nothing" % c.id)
		var needs_target := false
		for list in [c.effects, c.upgraded_effects]:
			for e in list:
				check(e["op"] in KNOWN_OPS, "%s unknown op %s" % [c.id, e["op"]])
				if e.has("status"):
					check(e["status"] in KNOWN_STATUSES, "%s unknown status" % c.id)
				if e["op"] == "power":
					check(e["power"] in KNOWN_POWERS, "%s unknown power" % c.id)
					check(c.is_power(), "%s has a power effect but isn't a Power" % c.id)
				if e.get("target", "") == "target":
					needs_target = true
		check_eq(c.targets_enemy, needs_target, "targets_enemy on %s" % c.id)


func test_card_keywords_have_rules() -> void:
	for c in CardDatabase.get_all_cards():
		for kw in c.keywords:
			check(Keywords.has_keyword(kw), "%s keyword '%s' has no rule text" % [c.id, kw])
	check(Keywords.get_rule("Poison").contains("loses HP"))


func test_balance_matches_spreadsheet() -> void:
	var expected := GameRules.load_json("res://tests/expected_balance.json")
	for c in CardDatabase.get_all_cards():
		var exp: Dictionary = expected[c.id]
		check_eq(BalanceCalculator.value(c), exp["value"], "value of %s" % c.id)
		check_eq(BalanceCalculator.budget(c), exp["budget"], "budget of %s" % c.id)
		check_eq(BalanceCalculator.status(c), exp["status"], "status of %s" % c.id)


func test_rules_match_sheet() -> void:
	check_eq(GameRules.player_max_hp(), 70)
	check_eq(GameRules.energy_per_turn(), 3)
	check_eq(GameRules.cards_drawn_per_turn(), 5)
	var odds := GameRules.rarity_odds()
	check_eq(float(odds["Common"]) + float(odds["Uncommon"]) + float(odds["Rare"]) + float(odds["Legendary"]), 1.0)
	check_eq(float(odds["Legendary"]), 0.02)
