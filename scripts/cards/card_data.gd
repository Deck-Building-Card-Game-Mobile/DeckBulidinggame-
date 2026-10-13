class_name CardData
extends RefCounted
## The fixed definition of one card (one row of data/cards.json).
## Never modified at runtime. A copy of a card in the player's deck is a
## CardInstance, which points back to one of these.

const TYPE_ATTACK := "Attack"
const TYPE_SKILL := "Skill"
const TYPE_POWER := "Power"

const RARITY_STARTER := "Starter"
const RARITY_COMMON := "Common"
const RARITY_UNCOMMON := "Uncommon"
const RARITY_RARE := "Rare"

var id: String
var name: String
var type: String
var cost: int
var rarity: String
var archetype: String
var text: String
var exhaust: bool
## True when the player must pick an enemy to play this card.
var targets_enemy: bool
## List of effect dictionaries, e.g. {"op": "damage", "amount": 6, "target": "target"}.
## See docs/CARD_SYSTEM.md for every op.
var effects: Array
## Keywords to show as tap-to-explain on the card (see data/keywords.json).
var keywords: Array
## Extra balance points for effects the price list can't measure ("Other value" column).
var balance_other_value: float
var notes: String

var upgraded_text: String
var upgraded_effects: Array
var upgraded_cost: int

## How many copies go in the starter deck (0 for non-starter cards).
var starter_copies: int


static func from_dict(d: Dictionary) -> CardData:
	var c := CardData.new()
	c.id = d["id"]
	c.name = d["name"]
	c.type = d["type"]
	c.cost = int(d["cost"])
	c.rarity = d["rarity"]
	c.archetype = d["archetype"]
	c.text = d["text"]
	c.exhaust = bool(d.get("exhaust", false))
	c.targets_enemy = bool(d.get("targets_enemy", false))
	c.effects = _normalize_effects(d.get("effects", []))
	c.keywords = d.get("keywords", [])
	c.balance_other_value = float(d.get("balance_other_value", 0))
	c.notes = d.get("notes", "")
	var up: Dictionary = d.get("upgraded", {})
	c.upgraded_text = up.get("text", c.text)
	c.upgraded_effects = _normalize_effects(up.get("effects", d.get("effects", [])))
	c.upgraded_cost = int(up.get("cost", c.cost))
	c.starter_copies = int(d.get("starter_copies", 0))
	return c


## JSON numbers arrive as floats; convert whole-number amounts to ints so
## combat math stays integer.
static func _normalize_effects(list: Array) -> Array:
	var out: Array = []
	for e in list:
		var copy: Dictionary = (e as Dictionary).duplicate(true)
		for key in ["amount", "hits", "heal_on_kill", "factor"]:
			if copy.has(key):
				copy[key] = int(copy[key])
		out.append(copy)
	return out


func is_attack() -> bool:
	return type == TYPE_ATTACK


func is_power() -> bool:
	return type == TYPE_POWER


func is_starter() -> bool:
	return rarity == RARITY_STARTER
