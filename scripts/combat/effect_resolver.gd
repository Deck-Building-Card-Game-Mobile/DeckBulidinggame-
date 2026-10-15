class_name EffectResolver
extends RefCounted
## Turns a card's effect list (data/cards.json) into changes to the fight.
## This is the meeting point of Role 2 (card effects) and Role 1 (battle state).
##
## Effect ops (every field besides "op" is listed):
##   damage            amount, target, hits=1, heal_on_kill, double_if_below_half, if_intent
##   block             amount
##   heal              amount
##   draw              amount
##   gain_energy       amount
##   lose_hp           amount                    (ignores block)
##   apply_status      status, amount, target    (poison / weak / vulnerable / strength)
##   multiply_status   status, factor, target    (Catalyst)
##   next_attack_bonus amount                    (Sharpen)
##   block_next_turn   amount                    (Bulwark)
##   discard           amount                    (Quick Thinking)
##   power             power, amount             (Power cards; see CombatState POWER_*)
##
## target: "target" (the enemy the player picked), "all_enemies",
##         "random_enemy", or "self" (the player).
## To add a new effect: add a case here, use it in data/cards.json, write a test.


static func resolve(combat: CombatState, card: CardInstance, target: Enemy, attack_bonus: int = 0) -> void:
	var bonus_left := attack_bonus
	for effect in card.get_effects():
		if combat.is_over():
			return
		var e: Dictionary = effect
		match e["op"]:
			"damage":
				_damage(combat, card, e, target, bonus_left)
				bonus_left = 0
			"block":
				combat.player_gain_block(e["amount"])
			"heal":
				combat.player.heal(e["amount"])
			"draw":
				combat.piles.draw(e["amount"])
			"gain_energy":
				combat.energy += e["amount"]
				combat.energy_changed.emit(combat.energy)
			"lose_hp":
				combat.player.lose_hp(e["amount"])
			"apply_status":
				for t in _targets(combat, e.get("target", "target"), target):
					t.add_status(e["status"], e["amount"])
			"multiply_status":
				for t in _targets(combat, e.get("target", "target"), target):
					t.set_status(e["status"], t.get_status(e["status"]) * int(e["factor"]))
			"next_attack_bonus":
				combat.next_attack_bonus += e["amount"]
			"block_next_turn":
				combat.pending_block_next_turn += e["amount"]
			"discard":
				combat.request_discard(e["amount"])
			"power":
				combat.powers[e["power"]] = combat.get_power(e["power"]) + int(e["amount"])
			_:
				push_error("Unknown effect op '%s' on card %s" % [e["op"], card.card_id])


static func _damage(combat: CombatState, card: CardInstance, e: Dictionary, picked: Enemy, bonus: int) -> void:
	for t in _targets(combat, e.get("target", "target"), picked):
		var enemy := t as Enemy
		# Parry: only hits if the enemy is about to attack.
		if e.has("if_intent") and (enemy == null or enemy.current_intent().get("type", "") != e["if_intent"]):
			continue
		var was_alive := t.is_alive()
		# Executioner's Axe: double damage against enemies below half HP.
		var mult := 2 if e.get("double_if_below_half", false) and t.is_below_half_hp() else 1
		for hit in int(e.get("hits", 1)):
			# Sharpen's bonus only applies to the first hit.
			var hit_bonus := bonus if hit == 0 else 0
			combat.deal_attack_damage(combat.player, t, e["amount"], hit_bonus, mult, card.is_attack())
		# Bloodletter: heal if this card killed the enemy.
		if e.has("heal_on_kill") and was_alive and not t.is_alive():
			combat.player.heal(e["heal_on_kill"])


static func _targets(combat: CombatState, kind: String, picked: Enemy) -> Array[Combatant]:
	var out: Array[Combatant] = []
	match kind:
		"self":
			out.append(combat.player)
		"all_enemies":
			for en in combat.living_enemies():
				out.append(en)
		"random_enemy":
			var r := combat.random_living_enemy()
			if r != null:
				out.append(r)
		_:
			if picked != null and picked.is_alive():
				out.append(picked)
	return out
