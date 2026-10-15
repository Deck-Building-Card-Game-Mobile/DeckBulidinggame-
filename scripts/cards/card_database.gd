class_name CardDatabase
extends RefCounted
## Loads every card definition from data/cards.json once and serves lookups.
##
## Usage:
##   var strike: CardData = CardDatabase.get_card("S01")
##   var commons: Array[CardData] = CardDatabase.get_cards_by_rarity("Common")

const CARDS_PATH := "res://data/cards.json"

static var _cards: Dictionary = {}       # id -> CardData
static var _order: Array[String] = []    # ids in file order


static func _ensure_loaded() -> void:
	if not _cards.is_empty():
		return
	var data := GameRules.load_json(CARDS_PATH)
	for d in data["cards"]:
		var card := CardData.from_dict(d)
		assert(not _cards.has(card.id), "Duplicate card id %s" % card.id)
		_cards[card.id] = card
		_order.append(card.id)


static func reload() -> void:
	_cards = {}
	_order = []


static func has_card(id: String) -> bool:
	_ensure_loaded()
	return _cards.has(id)


static func get_card(id: String) -> CardData:
	_ensure_loaded()
	assert(_cards.has(id), "Unknown card id %s" % id)
	return _cards[id]


static func get_all_cards() -> Array[CardData]:
	_ensure_loaded()
	var out: Array[CardData] = []
	for id in _order:
		out.append(_cards[id])
	return out


static func get_cards_by_rarity(rarity: String) -> Array[CardData]:
	var out: Array[CardData] = []
	for c in get_all_cards():
		if c.rarity == rarity:
			out.append(c)
	return out


static func get_cards_by_archetype(archetype: String) -> Array[CardData]:
	var out: Array[CardData] = []
	for c in get_all_cards():
		if c.archetype == archetype:
			out.append(c)
	return out


## Cards that can appear as rewards (everything except starter cards).
static func get_reward_pool() -> Array[CardData]:
	var out: Array[CardData] = []
	for c in get_all_cards():
		if not c.is_starter():
			out.append(c)
	return out
