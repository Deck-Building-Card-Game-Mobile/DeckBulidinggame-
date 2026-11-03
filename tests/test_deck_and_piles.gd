extends TestCase
## Deck building and card movement during a fight (Role 2).


func _seeded(seed_value: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng


func test_starter_deck() -> void:
	var deck := Deck.create_starter()
	check_eq(deck.size(), 10)
	check_eq(deck.count_of("S01"), 5)
	check_eq(deck.count_of("S02"), 4)
	check_eq(deck.count_of("S03"), 1)


func test_add_remove_upgrade() -> void:
	var deck := Deck.create_starter()
	var changes := [0]
	deck.deck_changed.connect(func(): changes[0] += 1)
	var slash := deck.add_card("C01")
	check_eq(deck.size(), 11)
	check(deck.upgrade_card(slash))
	check(not deck.upgrade_card(slash), "can't upgrade twice")
	check_eq(slash.get_name(), "Slash+")
	check_eq(slash.get_text(), "Deal 12 damage.")
	check(deck.remove_card(deck.cards[0]))
	check_eq(deck.size(), 10)
	check(not deck.remove_card(CardInstance.new("S01")), "removing a card not in the deck fails")
	check(deck.remove_card_by_uid(slash.uid))
	check_eq(deck.count_of("C01"), 0)
	check_eq(changes[0], 4)


func test_upgraded_cost() -> void:
	var rage := CardInstance.new("R06")
	check_eq(rage.get_cost(), 1)
	rage.upgrade()
	check_eq(rage.get_cost(), 0)


func test_save_and_load() -> void:
	var deck := Deck.create_starter()
	deck.upgrade_card(deck.cards[0])
	deck.add_card("R02", true)
	var copy := Deck.from_save_data(deck.to_save_data())
	check_eq(copy.size(), 11)
	check(copy.cards[0].upgraded)
	check_eq(copy.cards[10].card_id, "R02")
	check(copy.cards[10].upgraded)


func test_fight_uses_copies() -> void:
	var deck := Deck.create_starter()
	var piles := CardPiles.new(deck, _seeded(1))
	check_eq(piles.draw_pile.size(), 10)
	piles.draw(5)
	piles.exhaust_pile.append(piles.hand.pop_back())
	check_eq(deck.size(), 10, "exhausting in a fight doesn't touch the run deck")
	for c in piles.draw_pile:
		check(not deck.cards.has(c))


func test_draw_reshuffles_discard() -> void:
	var piles := CardPiles.new(Deck.create_starter(), _seeded(2))
	check_eq(piles.draw(5).size(), 5)
	piles.discard_hand()
	check_eq(piles.draw(5).size(), 5)
	piles.discard_hand()
	check_eq(piles.draw_pile.size(), 0)
	check_eq(piles.draw(3).size(), 3, "discard is shuffled back in")
	check_eq(piles.discard_pile.size(), 0)
	check_eq(piles.total_cards(), 10)


func test_draw_with_nothing_left() -> void:
	var piles := CardPiles.new(Deck.create_starter(), _seeded(3))
	check_eq(piles.draw(20).size(), 10)
	check_eq(piles.hand.size(), 10)


func test_hand_limit_sends_extras_to_discard() -> void:
	var deck := Deck.new()
	for i in 14:
		deck.add_card("S01")
	var piles := CardPiles.new(deck, _seeded(4))
	piles.draw(14)
	check_eq(piles.hand.size(), GameRules.max_hand_size())
	check_eq(piles.discard_pile.size(), 4)


func test_shuffle_is_seeded() -> void:
	var deck := Deck.create_starter()
	deck.add_card("C01")
	deck.add_card("U01")
	var a := CardPiles.new(deck, _seeded(42))
	var b := CardPiles.new(deck, _seeded(42))
	var ids_a := a.draw_pile.map(func(c): return c.card_id)
	var ids_b := b.draw_pile.map(func(c): return c.card_id)
	check_eq(ids_a, ids_b)


func test_played_card_destinations() -> void:
	var piles := CardPiles.new()
	var power := CardInstance.new("U06")
	var exhaust := CardInstance.new("C15")
	var normal := CardInstance.new("S01")
	piles.send_played_card(power)
	piles.send_played_card(exhaust)
	piles.send_played_card(normal)
	check(piles.powers_in_play.has(power))
	check(piles.exhaust_pile.has(exhaust))
	check(piles.discard_pile.has(normal))


func test_rewards() -> void:
	var rng := _seeded(7)
	var counts := {"Common": 0, "Uncommon": 0, "Rare": 0, "Legendary": 0}
	for i in 3000:
		var choices := RewardGenerator.generate_choices(rng)
		check_eq(choices.size(), 3)
		check(choices[0] != choices[1] and choices[1] != choices[2] and choices[0] != choices[2], "rewards repeat")
		for c in choices:
			check(not c.is_starter(), "starter card offered as reward")
			counts[c.rarity] += 1
	var total := 9000.0
	check(absf(counts["Common"] / total - 0.60) < 0.03, "common rate %s" % (counts["Common"] / total))
	check(absf(counts["Uncommon"] / total - 0.31) < 0.03, "uncommon rate %s" % (counts["Uncommon"] / total))
	check(absf(counts["Rare"] / total - 0.07) < 0.02, "rare rate %s" % (counts["Rare"] / total))
	check(absf(counts["Legendary"] / total - 0.02) < 0.01, "legendary rate %s" % (counts["Legendary"] / total))


func test_unique_cards_limited_to_one_copy() -> void:
	var deck := Deck.create_starter()
	check(deck.add_card("L01") != null)
	check(deck.add_card("L01") == null, "second Legendary copy refused")
	check_eq(deck.count_of("L01"), 1)
	check(not deck.can_add_card("L01"))
	check(deck.can_add_card("L02"))
	check(deck.add_card("C01") != null and deck.add_card("C01") != null, "normal cards can repeat")


func test_rewards_skip_owned_legendaries() -> void:
	var deck := Deck.create_starter()
	for c in CardDatabase.get_cards_by_rarity("Legendary"):
		if c.id != "L05":
			deck.add_card(c.id)
	var rng := _seeded(9)
	for i in 300:
		var choices := RewardGenerator.generate_choices(rng, -1, deck, true)
		check_eq(choices[0].id, "L05", "only Legendary left to offer")
		for c in choices.slice(1):
			check(not c.is_legendary(), "owned Legendary offered")


func test_elite_reward_guarantees_a_legendary() -> void:
	var rng := _seeded(10)
	for i in 200:
		var choices := RewardGenerator.generate_choices(rng, -1, Deck.create_starter(), true)
		check_eq(choices.size(), 3)
		check(choices[0].is_legendary())
	var deck := Deck.create_starter()
	for c in CardDatabase.get_cards_by_rarity("Legendary"):
		deck.add_card(c.id)
	var fallback := RewardGenerator.generate_choices(rng, -1, deck, true)
	check_eq(fallback.size(), 3, "still 3 choices when every Legendary is owned")


func test_retain_cards_stay_in_hand() -> void:
	var piles := CardPiles.new()
	var keep := CardInstance.new("C33")   # Hunker Down: Retain
	var normal := CardInstance.new("S01")
	piles.hand.append(keep)
	piles.hand.append(normal)
	piles.discard_hand()
	check_eq(piles.hand, [keep] as Array[CardInstance])
	check(piles.discard_pile.has(normal))
	piles.discard_hand(true)
	check(piles.hand.has(keep), "retain_all keeps everything")
