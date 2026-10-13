class_name GameRules
extends RefCounted
## Global tuning numbers from data/rules.json (the "Rules" tab of
## docs/design/Dungeon_Card_Set_v1.xlsx).
##
## Usage:  GameRules.player_max_hp()   GameRules.get_rules()["budget"]
## Change numbers in data/rules.json, not in code.

const RULES_PATH := "res://data/rules.json"

static var _rules: Dictionary = {}


static func get_rules() -> Dictionary:
	if _rules.is_empty():
		_rules = load_json(RULES_PATH)
	return _rules


## Forces a reload (useful after editing the JSON while the game runs).
static func reload() -> void:
	_rules = {}


static func player_max_hp() -> int:
	return int(get_rules()["player"]["max_hp"])


static func energy_per_turn() -> int:
	return int(get_rules()["player"]["energy_per_turn"])


static func cards_drawn_per_turn() -> int:
	return int(get_rules()["player"]["cards_drawn_per_turn"])


static func max_hand_size() -> int:
	return int(get_rules()["player"]["max_hand_size"])


static func weak_multiplier() -> float:
	return float(get_rules()["status_multipliers"]["weak_damage_dealt"])


static func vulnerable_multiplier() -> float:
	return float(get_rules()["status_multipliers"]["vulnerable_damage_taken"])


static func reward_choice_count() -> int:
	return int(get_rules()["rewards"]["choices_per_reward"])


static func rarity_odds() -> Dictionary:
	return get_rules()["rewards"]["rarity_odds"]


## Array of {"card_id": String, "count": int}.
static func starter_deck_list() -> Array:
	return get_rules()["starter_deck"]


static func load_json(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	assert(file != null, "Could not open %s" % path)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	assert(parsed is Dictionary, "%s is not a JSON object" % path)
	return parsed
