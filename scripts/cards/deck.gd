class_name Deck
extends RefCounted
## The player's deck for the whole run (Role 2).
## Rewards add cards, shops/events remove them, rest spots upgrade them.
## A fight never changes this list; it works on copies (see CardPiles).

signal deck_changed

var cards: Array[CardInstance] = []


## A new Deck with the starter list from data/rules.json
## (5 Strike, 4 Defend, 1 Lantern Bash).
static func create_starter() -> Deck:
	var deck := Deck.new()
	for entry in GameRules.starter_deck_list():
		for i in int(entry["count"]):
			deck.cards.append(CardInstance.new(entry["card_id"]))
	return deck


func size() -> int:
	return cards.size()


## False when the card is Unique (every Legendary) and the deck already has it.
func can_add_card(card_id: String) -> bool:
	if not CardDatabase.has_card(card_id):
		return false
	return not (CardDatabase.get_card(card_id).unique and count_of(card_id) > 0)


## Adds a new copy. Returns null (and adds nothing) if it would break the
## one-copy limit on Unique cards.
func add_card(card_id: String, upgraded: bool = false) -> CardInstance:
	assert(CardDatabase.has_card(card_id), "Unknown card id %s" % card_id)
	if not can_add_card(card_id):
		return null
	var inst := CardInstance.new(card_id, upgraded)
	cards.append(inst)
	deck_changed.emit()
	return inst


## Removes one specific copy. Returns false if it isn't in the deck.
func remove_card(card: CardInstance) -> bool:
	var i := cards.find(card)
	if i == -1:
		return false
	cards.remove_at(i)
	deck_changed.emit()
	return true


func remove_card_by_uid(uid: int) -> bool:
	var card := find_by_uid(uid)
	return card != null and remove_card(card)


## Upgrades one specific copy. Returns false if it was already upgraded.
func upgrade_card(card: CardInstance) -> bool:
	if not cards.has(card) or not card.upgrade():
		return false
	deck_changed.emit()
	return true


func find_by_uid(uid: int) -> CardInstance:
	for c in cards:
		if c.uid == uid:
			return c
	return null


func count_of(card_id: String) -> int:
	var n := 0
	for c in cards:
		if c.card_id == card_id:
			n += 1
	return n


func get_upgradable_cards() -> Array[CardInstance]:
	var out: Array[CardInstance] = []
	for c in cards:
		if c.can_upgrade():
			out.append(c)
	return out


## Plain data for saving a run: [{"card_id": "S01", "upgraded": false}, ...]
func to_save_data() -> Array:
	var out: Array = []
	for c in cards:
		out.append({"card_id": c.card_id, "upgraded": c.upgraded})
	return out


static func from_save_data(data: Array) -> Deck:
	var deck := Deck.new()
	for entry in data:
		deck.cards.append(CardInstance.new(entry["card_id"], bool(entry.get("upgraded", false))))
	return deck
