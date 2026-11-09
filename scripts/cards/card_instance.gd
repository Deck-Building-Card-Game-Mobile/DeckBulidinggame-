class_name CardInstance
extends RefCounted
## One physical copy of a card in the player's deck. Five Strikes in the deck
## are five CardInstances that share the same CardData.
## Upgrading changes only this copy.

static var _next_uid: int = 1

## Unique per copy, so the UI and the deck can tell identical cards apart.
var uid: int
var card_id: String
var upgraded: bool = false


func _init(p_card_id: String = "", p_upgraded: bool = false) -> void:
	uid = _next_uid
	_next_uid += 1
	card_id = p_card_id
	upgraded = p_upgraded


func get_data() -> CardData:
	return CardDatabase.get_card(card_id)


func get_name() -> String:
	return get_data().name + ("+" if upgraded else "")


func get_cost() -> int:
	var d := get_data()
	return d.upgraded_cost if upgraded else d.cost


func get_text() -> String:
	var d := get_data()
	return d.upgraded_text if upgraded else d.text


func get_effects() -> Array:
	var d := get_data()
	return d.upgraded_effects if upgraded else d.effects


func get_type() -> String:
	return get_data().type


func is_attack() -> bool:
	return get_data().is_attack()


func is_power() -> bool:
	return get_data().is_power()


func is_exhaust() -> bool:
	var d := get_data()
	return d.upgraded_exhaust if upgraded else d.exhaust


func is_retain() -> bool:
	return get_data().retain


func is_unique() -> bool:
	return get_data().unique


func targets_enemy() -> bool:
	return get_data().targets_enemy


func can_upgrade() -> bool:
	return not upgraded


func upgrade() -> bool:
	if upgraded:
		return false
	upgraded = true
	return true


## A fresh copy with a new uid (used when a fight copies the run deck).
func duplicate_card() -> CardInstance:
	return CardInstance.new(card_id, upgraded)


func _to_string() -> String:
	return "%s#%d" % [get_name(), uid]
