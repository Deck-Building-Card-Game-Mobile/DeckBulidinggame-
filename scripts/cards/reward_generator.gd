class_name RewardGenerator
extends RefCounted
## Card rewards after a won fight (Role 2, called by Role 4).
## Offers 3 different cards; each slot rolls its rarity with the odds in
## data/rules.json (60% Common, 31% Uncommon, 7% Rare, 2% Legendary).
## The player may skip.
##
## Usage:
##   var choices := RewardGenerator.generate_choices(rng, -1, deck)
##   deck.add_card(choices[picked_index].id)
##   # After an elite or the boss, one choice is always a Legendary:
##   var choices := RewardGenerator.generate_choices(rng, -1, deck, true)
##
## Pass the player's deck so Unique cards (Legendaries) they already own
## are never offered again.


## Rolls one rarity using the configured odds.
static func roll_rarity(rng: RandomNumberGenerator) -> String:
	var odds := GameRules.rarity_odds()
	var total := 0.0
	for r in odds:
		total += float(odds[r])
	var roll := rng.randf() * total
	var running := 0.0
	for r in ["Common", "Uncommon", "Rare", "Legendary"]:
		running += float(odds.get(r, 0.0))
		if roll < running:
			return r
	return "Common"


## Returns `count` distinct reward cards (CardData). Falls back to another
## rarity if a rarity runs out of cards that can still be offered.
## deck: skips Unique cards already in it. guarantee_legendary: the first
## choice is a Legendary (elite and boss rewards), if any are left to offer.
static func generate_choices(rng: RandomNumberGenerator, count: int = -1, deck: Deck = null,
		guarantee_legendary: bool = false) -> Array[CardData]:
	if count < 0:
		count = GameRules.reward_choice_count()
	var chosen: Array[CardData] = []
	var pool: Array[CardData] = []
	for c in CardDatabase.get_reward_pool():
		if deck == null or deck.can_add_card(c.id):
			pool.append(c)
	count = mini(count, pool.size())
	if guarantee_legendary and count > 0:
		var legendaries := _available(pool, chosen, CardData.RARITY_LEGENDARY)
		if not legendaries.is_empty():
			chosen.append(legendaries[rng.randi_range(0, legendaries.size() - 1)])
	while chosen.size() < count:
		var options := _available(pool, chosen, roll_rarity(rng))
		if options.is_empty():
			options = _available(pool, chosen, "")
		chosen.append(options[rng.randi_range(0, options.size() - 1)])
	return chosen


## Cards in the pool not already chosen; rarity "" means any rarity.
static func _available(pool: Array[CardData], chosen: Array[CardData], rarity: String) -> Array[CardData]:
	var out: Array[CardData] = []
	for c in pool:
		if (rarity == "" or c.rarity == rarity) and not chosen.has(c):
			out.append(c)
	return out
