class_name BalanceCalculator
extends RefCounted
## The spreadsheet's stat-budget formula, in code, so new or changed cards can
## be checked without opening the sheet. Numbers come from data/rules.json.
##
##   Budget = (cost x points_per_energy + base_card_value + rarity_bonus)
##            x exhaust_multiplier (if the card exhausts)
##   Value  = (sum(effect amount x price) + retain value + balance_other_value)
##            x power_multiplier for Power cards.
##
## Conditional parts of effects (Parry's intent check, Bloodletter's heal on
## kill, Sharpen, Catalyst, Envenom, Thorn Armor, discards) are not priced
## automatically; their worth lives in balance_other_value, as in the sheet.

const STATUS_BALANCED := "Balanced"
const STATUS_OVER := "Over budget"
const STATUS_UNDER := "Under budget"
const STATUS_STARTER_OK := "Starter (under on purpose)"
const STATUS_STARTER_STRONG := "Starter too strong"


## Base (non-upgraded) budget of a card.
static func budget(card: CardData) -> float:
	var b: Dictionary = GameRules.get_rules()["budget"]
	var bonus := float(b["rarity_bonus"].get(card.rarity, 0))
	var total := card.cost * float(b["points_per_energy"]) + float(b["base_card_value"]) + bonus
	if card.exhaust:
		total *= float(b["exhaust_multiplier"])
	return snappedf(total, 0.01)


## Base (non-upgraded) value of a card.
static func value(card: CardData) -> float:
	var b: Dictionary = GameRules.get_rules()["budget"]
	var p: Dictionary = GameRules.get_rules()["effect_prices"]
	var all_mult := float(b["all_enemies_multiplier"])
	var total := 0.0
	for e in card.effects:
		var amt := float(e.get("amount", 0))
		var all: bool = e.get("target", "") == "all_enemies"
		if e.has("if_intent"):
			continue  # conditional (Parry, Rebuke); priced in balance_other_value
		match e["op"]:
			"damage":
				# Damage that copies block or Poison has amount 0; priced in balance_other_value.
				total += amt * int(e.get("hits", 1)) * float(p["damage"]) * (all_mult if all else 1.0)
			"block", "block_next_turn":
				total += amt * float(p["block"])
			"heal":
				total += amt * float(p["heal"])
			"draw":
				total += amt * float(p["draw"])
			"gain_energy", "energy_next_turn":
				total += amt * float(p["energy"])
			"lose_hp":
				total -= amt * float(p["hp_loss"])
			"apply_status":
				total += amt * float(p[e["status"]]) * (all_mult if all else 1.0)
			"power":
				total += _power_value(e["power"], amt, p, all_mult)
	if card.retain:
		total += float(p.get("retain", 0))
	total += card.balance_other_value
	if card.is_power():
		total *= float(b["power_multiplier"])
	return snappedf(total, 0.01)


## Per-turn value of a power's measurable part.
static func _power_value(power: String, amt: float, p: Dictionary, all_mult: float) -> float:
	match power:
		"iron_skin":
			return amt * float(p["block"])
		"black_plague":
			return amt * float(p["poison"]) * all_mult
		"berserker_rage":
			return amt * float(p["energy"])
		"draw_per_turn":
			return amt * float(p["draw"])
		"strength_per_turn":
			return amt * float(p["strength"])
		"hp_loss_per_turn":
			return -amt * float(p["hp_loss"])
	# envenom, thorn_armor, barricade, poison_boost, retain_hand,
	# double_attack_damage, poison_no_decay: balance_other_value only
	return 0.0


static func difference(card: CardData) -> float:
	return snappedf(value(card) - budget(card), 0.01)


static func status(card: CardData) -> String:
	var diff := difference(card)
	if card.is_starter():
		return STATUS_STARTER_OK if diff < 0 else STATUS_STARTER_STRONG
	var tol := float(GameRules.get_rules()["budget"]["balanced_tolerance"])
	if absf(diff) <= tol:
		return STATUS_BALANCED
	return STATUS_OVER if diff > 0 else STATUS_UNDER


## One line per card, handy for printing a balance report.
static func report() -> Array[String]:
	var lines: Array[String] = []
	for c in CardDatabase.get_all_cards():
		lines.append("%s %-18s value %6.2f  budget %6.2f  %s" % [c.id, c.name, value(c), budget(c), status(c)])
	return lines
