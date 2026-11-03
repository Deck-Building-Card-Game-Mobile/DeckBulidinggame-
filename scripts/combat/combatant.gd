class_name Combatant
extends RefCounted
## Anything with HP in a fight: the player or an enemy.
## Holds HP, block and statuses (Poison, Weak, Vulnerable, Strength).
## Keyword rules are in data/keywords.json.

signal hp_changed(new_hp: int, max_hp: int)
signal block_changed(new_block: int)
signal status_changed(status: String, new_amount: int)
signal died
signal invulnerable_changed(is_invulnerable: bool)

const POISON := "poison"
const WEAK := "weak"
const VULNERABLE := "vulnerable"
const STRENGTH := "strength"

## Statuses that count down by 1 at the end of each round (after the enemies act).
const TURN_STATUSES := [WEAK, VULNERABLE]

var display_name: String
var max_hp: int
var hp: int
var block: int = 0
var statuses: Dictionary = {}
## Invulnerable (Unbreakable): take_damage() does nothing while this is true.
## CombatState turns it off at the start of the player's next turn.
var invulnerable: bool = false:
	set(value):
		if invulnerable != value:
			invulnerable = value
			invulnerable_changed.emit(value)
## Turn statuses that skip their next countdown because they were applied
## during the enemy turn (so 1 Vulnerable from an enemy still lasts through
## the next enemy turn). status -> true.
var _skip_countdown: Dictionary = {}


func _init(p_name: String = "", p_max_hp: int = 1, p_hp: int = -1) -> void:
	display_name = p_name
	max_hp = p_max_hp
	hp = p_max_hp if p_hp < 0 else mini(p_hp, p_max_hp)


func is_alive() -> bool:
	return hp > 0


func is_below_half_hp() -> bool:
	return hp * 2 < max_hp


func get_status(status: String) -> int:
	return int(statuses.get(status, 0))


func has_status(status: String) -> bool:
	return get_status(status) > 0


## skip_next_countdown: true when the status lands during the enemy turn, so
## Weak / Vulnerable aren't counted down at the end of that same round.
func add_status(status: String, amount: int, skip_next_countdown: bool = false) -> void:
	set_status(status, get_status(status) + amount)
	if skip_next_countdown and status in TURN_STATUSES and has_status(status):
		_skip_countdown[status] = true


func set_status(status: String, amount: int) -> void:
	# Only Strength may go negative; everything else stops at 0.
	if amount < 0 and status != STRENGTH:
		amount = 0
	if amount == 0:
		statuses.erase(status)
		_skip_countdown.erase(status)
	else:
		statuses[status] = amount
	status_changed.emit(status, amount)


## Returns the block actually gained.
func gain_block(amount: int) -> int:
	if amount <= 0 or not is_alive():
		return 0
	block += amount
	block_changed.emit(block)
	return amount


func clear_block() -> void:
	if block != 0:
		block = 0
		block_changed.emit(block)


## Damage that block can stop. Returns the HP actually lost.
func take_damage(amount: int) -> int:
	if amount <= 0 or not is_alive() or invulnerable:
		return 0
	var absorbed := mini(block, amount)
	if absorbed > 0:
		block -= absorbed
		block_changed.emit(block)
	return lose_hp(amount - absorbed)


## HP loss that ignores block (Poison, Reckless Charge). Returns HP lost.
func lose_hp(amount: int) -> int:
	if amount <= 0 or not is_alive():
		return 0
	var lost := mini(hp, amount)
	hp -= lost
	hp_changed.emit(hp, max_hp)
	if hp <= 0:
		died.emit()
	return lost


## Returns the HP actually restored (can't go over max HP).
func heal(amount: int) -> int:
	if amount <= 0 or not is_alive():
		return 0
	var restored := mini(max_hp - hp, amount)
	if restored > 0:
		hp += restored
		hp_changed.emit(hp, max_hp)
	return restored


## Start of this combatant's turn: lose HP equal to Poison, then Poison - 1
## (unless decay is false: Heart of the Hydra). Returns the HP lost.
func tick_poison(decay: bool = true) -> int:
	var p := get_status(POISON)
	if p <= 0:
		return 0
	var lost := lose_hp(p)
	if decay:
		set_status(POISON, p - 1)
	return lost


## End of the round: Weak and Vulnerable go down by 1, except ones applied
## during this round's enemy turn, which skip this countdown once.
func decrement_turn_statuses() -> void:
	for s in TURN_STATUSES:
		if not has_status(s):
			continue
		if _skip_countdown.has(s):
			_skip_countdown.erase(s)
		else:
			set_status(s, get_status(s) - 1)
