extends TestCase
## Card data matches the design spreadsheet and is internally consistent.

const KNOWN_OPS := ["damage", "block", "heal", "draw", "gain_energy", "lose_hp", "apply_status",
	"multiply_status", "next_attack_bonus", "block_next_turn", "discard", "power"]
const KNOWN_POWERS := ["iron_skin", "envenom", "thorn_armor", "black_plague", "berserker_rage"]
const KNOWN_STATUSES := ["poison", "weak", "vulnerable", "strength"]


func test_card_counts_match_sheet() -> void:
	check_eq(CardDatabase.get_all_cards().size(), 43)
	check_eq(CardDatabase.get_cards_by_rarity("Starter").size(), 3)
	check_eq(CardDatabase.get_cards_by_rarity("Common").size(), 20)
	check_eq(CardDatabase.get_cards_by_rarity("Uncommon").size(), 14)
	check_eq(CardDatabase.get_cards_by_rarity("Rare").size(), 6)
	check_eq(CardDatabase.get_reward_pool().size(), 40)


func test_archetype_counts() -> void:
	var counts := {}
	for c in CardDatabase.get_all_cards():
		counts[c.archetype] = counts.get(c.archetype, 0) + 1
	check_eq(counts.keys().size(), 5, "Neutral + 4 archetypes")
	for a in ["Brawler", "Guardian", "Venom", "Tactician"]:
		check(counts.get(a, 0) >= 7, "%s has too few cards" % a)


func test_every_card_is_well_formed() -> void:
	for c in CardDatabase.get_all_cards():
		check(c.name != "" and c.text != "" and c.upgraded_text != "", "%s missing text" % c.id)
		check(c.type in ["Attack", "Skill", "Power"], "%s bad type" % c.id)
		check(c.cost >= 0 and c.cost <= 3, "%s bad cost" % c.id)
		check(not c.effects.is_empty() and not c.upgraded_effects.is_empty(), "%s has no effects" % c.id)
		check(c.upgraded_effects != c.effects or c.upgraded_cost != c.cost, "%s upgrade does nothing" % c.id)
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
	check_eq(float(odds["Common"]) + float(odds["Uncommon"]) + float(odds["Rare"]), 1.0)
