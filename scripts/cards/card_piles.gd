class_name CardPiles
extends RefCounted
## The card zones during one fight (Role 2): draw pile, hand, discard pile,
## exhaust pile, and powers in play.
##
## Built from a copy of the run Deck, so exhausting or discarding a card in a
## fight never removes it from the player's real deck.
## The top of the draw pile is the END of the draw_pile array.

signal hand_changed
signal piles_shuffled

var draw_pile: Array[CardInstance] = []
var hand: Array[CardInstance] = []
var discard_pile: Array[CardInstance] = []
var exhaust_pile: Array[CardInstance] = []
## Power cards stay here for the rest of the fight once played.
var powers_in_play: Array[CardInstance] = []

var max_hand_size: int
var rng: RandomNumberGenerator


func _init(deck: Deck = null, p_rng: RandomNumberGenerator = null) -> void:
	rng = p_rng if p_rng != null else RandomNumberGenerator.new()
	max_hand_size = GameRules.max_hand_size()
	if deck != null:
		for c in deck.cards:
			draw_pile.append(c.duplicate_card())
		shuffle_draw_pile()


func shuffle_draw_pile() -> void:
	# Fisher-Yates with our own RNG so seeded runs are reproducible.
	for i in range(draw_pile.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp := draw_pile[i]
		draw_pile[i] = draw_pile[j]
		draw_pile[j] = tmp
	piles_shuffled.emit()


## Moves the discard pile into the draw pile and shuffles it.
func reshuffle_discard_into_draw() -> void:
	draw_pile.append_array(discard_pile)
	discard_pile.clear()
	shuffle_draw_pile()


## Draws up to `count` cards. If the draw pile runs out, the discard pile is
## shuffled in. If the hand is full, extra drawn cards go straight to the
## discard pile. Returns the cards that reached the hand.
func draw(count: int) -> Array[CardInstance]:
	var drawn: Array[CardInstance] = []
	for i in count:
		if draw_pile.is_empty():
			if discard_pile.is_empty():
				break
			reshuffle_discard_into_draw()
		var card: CardInstance = draw_pile.pop_back()
		if hand.size() >= max_hand_size:
			discard_pile.append(card)
		else:
			hand.append(card)
			drawn.append(card)
	if not drawn.is_empty():
		hand_changed.emit()
	return drawn


## Takes a card out of the hand (when it is played). Returns false if absent.
func take_from_hand(card: CardInstance) -> bool:
	var i := hand.find(card)
	if i == -1:
		return false
	hand.remove_at(i)
	hand_changed.emit()
	return true


func discard_from_hand(card: CardInstance) -> bool:
	if not take_from_hand(card):
		return false
	discard_pile.append(card)
	return true


## End of turn: the hand goes to the discard pile, except Retain cards
## (or every card, when retain_all is true: Master Plan).
func discard_hand(retain_all: bool = false) -> void:
	if retain_all:
		return
	var kept: Array[CardInstance] = []
	for card in hand:
		if card.is_retain():
			kept.append(card)
		else:
			discard_pile.append(card)
	hand = kept
	hand_changed.emit()


## Where a card goes after it resolves: exhaust pile, powers, or discard.
func send_played_card(card: CardInstance) -> void:
	if card.is_power():
		powers_in_play.append(card)
	elif card.is_exhaust():
		exhaust_pile.append(card)
	else:
		discard_pile.append(card)


## Total cards across every zone (should equal the deck size).
func total_cards() -> int:
	return draw_pile.size() + hand.size() + discard_pile.size() + exhaust_pile.size() + powers_in_play.size()
