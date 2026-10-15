class_name RewardGenerator
extends RefCounted
## Card rewards after a won fight (Role 2, called by Role 4).
## Offers 3 different cards; each slot rolls its rarity with the odds in
## data/rules.json (60% Common, 33% Uncommon, 7% Rare). The player may skip.
##
## Usage:
##   var choices := RewardGenerator.generate_choices(rng)
##   deck.add_card(choices[picked_index].id)


## Rolls one rarity using the configured odds.
static func roll_rarity(rng: RandomNumberGenerator) -> String:
	var odds := GameRules.rarity_odds()
	var total := 0.0
	for r in odds:
		total += float(odds[r])
	var roll := rng.randf() * total
	var running := 0.0
	for r in ["Common", "Uncommon", "Rare"]:
		running += float(odds.get(r, 0.0))
		if roll < running:
			return r
	return "Common"


## Returns `count` distinct reward cards (CardData). Falls back to another
## rarity if a rarity runs out of unused cards.
static func generate_choices(rng: RandomNumberGenerator, count: int = -1) -> Array[CardData]:
	if count < 0:
		count = GameRules.reward_choice_count()
	var chosen: Array[CardData] = []
	var pool := CardDatabase.get_reward_pool()
	count = mini(count, pool.size())
	while chosen.size() < count:
		var rarity := roll_rarity(rng)
		var options: Array[CardData] = []
		for c in CardDatabase.get_cards_by_rarity(rarity):
			if not chosen.has(c):
				options.append(c)
		if options.is_empty():
			for c in pool:
				if not chosen.has(c):
					options.append(c)
		chosen.append(options[rng.randi_range(0, options.size() - 1)])
	return chosen
