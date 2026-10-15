class_name Enemy
extends Combatant
## An enemy with a repeating list of intents, shown to the player one turn
## ahead. Enemy content and AI belong to Role 1; this is the minimum the
## card rules need (Parry reads the intent, damage and statuses hit enemies).
##
## Intent dictionaries:
##   {"type": "attack", "amount": 6, "hits": 1}
##   {"type": "block",  "amount": 5}
##   {"type": "buff",   "status": "strength", "amount": 2}       # on itself
##   {"type": "debuff", "status": "weak", "amount": 1}           # on the player

const INTENT_ATTACK := "attack"
const INTENT_BLOCK := "block"
const INTENT_BUFF := "buff"
const INTENT_DEBUFF := "debuff"

signal intent_changed(intent: Dictionary)

var intents: Array = []
var intent_index: int = 0


func _init(p_name: String = "", p_max_hp: int = 1, p_intents: Array = []) -> void:
	super(p_name, p_max_hp)
	intents = p_intents
	if intents.is_empty():
		intents = [{"type": INTENT_ATTACK, "amount": 6}]


func current_intent() -> Dictionary:
	return intents[intent_index % intents.size()]


func intends_to_attack() -> bool:
	return current_intent().get("type", "") == INTENT_ATTACK


func advance_intent() -> void:
	intent_index = (intent_index + 1) % intents.size()
	intent_changed.emit(current_intent())
