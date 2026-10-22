# Card System

The 43 cards, rules and keywords from `docs/design/Dungeon_Card_Set_v1.xlsx`,
built into the game as data plus GDScript. Nothing here needs a scene to run;
it is all plain classes, so it works the same from UI, tests or a bot.

## Files

| Path | What it is | Main owner |
|---|---|---|
| `data/cards.json` | Every card: cost, rarity, archetype, text, effects, upgraded version, keywords | Role 2 |
| `data/rules.json` | Player HP/energy/draw, enemy HP ranges, budget formula, effect prices, reward odds, starter deck | Role 2 |
| `data/keywords.json` | Rules text for tap-to-explain | Role 2 / 3 |
| `scripts/cards/` | `CardData`, `CardDatabase`, `CardInstance`, `Deck`, `CardPiles`, `RewardGenerator`, `BalanceCalculator`, `Keywords`, `GameRules` | Role 2 |
| `scripts/combat/` | `Combatant`, `Enemy`, `CombatState`, `EffectResolver` | Role 1 (with Role 2) |
| `tests/` | Headless tests (86) | everyone |
| `tools/export_expected_balance.py` | Copies the sheet's balance results into the tests | Role 2 |

`data/cards.json` is the source of truth for the game. The spreadsheet stays
the design and balance tool, and `test_balance_matches_spreadsheet` fails if
the two disagree.

## Running the tests

```
godot --headless --path . --import          # first time only, builds the class cache
godot --headless --path . --script res://tests/run_tests.gd
```

Exit code 0 means everything passed. The simulation test also prints the
starter deck's win rate and average fight length.

## How each role uses it

**Role 4 (run / progression)** owns the run-level objects:

```gdscript
var deck := Deck.create_starter()           # 5 Strike, 4 Defend, 1 Lantern Bash
var hp := GameRules.player_max_hp()         # 70

# Each battle
var combat := CombatState.new()
combat.combat_ended.connect(_on_battle_ended)
combat.start(deck, hp, [Enemy.new("Cave Rat", 22, [{"type": "attack", "amount": 7}])], rng)

func _on_battle_ended(result: String) -> void:
    hp = combat.player.hp
    if result == CombatState.RESULT_WON:
        var choices := RewardGenerator.generate_choices(rng)   # 3 CardData, skippable
        # after the player picks: deck.add_card(choices[i].id)

# Rest site / shop
deck.upgrade_card(card)       # or deck.remove_card(card)
# Saving
var save := deck.to_save_data()  # -> Deck.from_save_data(save)
```

**Role 3 (UI)** reads state and calls two methods:

```gdscript
for card in combat.piles.hand:
    name_label.text = card.get_name()       # "Slash+" when upgraded
    cost_label.text = str(card.get_cost())
    text_label.text = card.get_text()
    for kw in card.get_data().keywords:     # tap-to-explain
        add_tooltip(kw, Keywords.get_rule(kw))
    greyed_out = not combat.can_play(card, selected_enemy)

combat.play_card(card, enemy_index)         # enemy_index = -1 if not card.targets_enemy()
combat.end_player_turn()
```

Show `combat.why_cannot_play(card, target)` as feedback ("Not enough energy.").
Enemy intent: `enemy.current_intent()`. Damage preview:
`combat.calculate_attack_damage(combat.player, enemy, base)`.

Signals for feedback and animation: `turn_started`, `energy_changed`,
`card_played`, `card_rejected`, `damage_dealt`, `combat_ended`, plus
`hp_changed`, `block_changed` and `status_changed` on every `Combatant`, and
`hand_changed` on `combat.piles`.

Turn flow signals: `phase_changed(phase)`, `player_turn_ended(turn)`,
`enemy_turn_started(turn)`, `enemy_acted(enemy, intent)` and `round_ended(turn)`.
`combat.phase` is `PLAYER_TURN`, `ENEMY_TURN` or `OVER`. Grey out the End Turn
button with `combat.can_end_turn()` (reason: `why_cannot_end_turn()`).

To animate the enemy turn one enemy at a time, set
`combat.manual_enemy_turn = true` before `start()`, then:

```gdscript
combat.end_player_turn()
while combat.next_enemy_action():     # one enemy acts per call
    await play_enemy_animation()      # use enemy_acted / damage_dealt
# the last call ended the round and started the player's next turn
```

Without it (tests, simulation), `end_player_turn()` runs the whole enemy turn at once.

Quick Thinking is the only card that needs a choice: on `discard_requested(count)`,
let the player tap cards and call `combat.choose_discard(card)` for each.
Playing cards and ending the turn are blocked until that's done.

**Role 1 (combat)** owns `scripts/combat/`. `CombatState` already handles turn
order, energy, block, statuses, powers and win/lose so every card works.
Enemy content and smarter AI still need to be designed: an enemy is currently a
repeating list of intents (`attack`, `block`, `buff`, `debuff`).

**Role 2 (cards)**: to add a card, add an object to `data/cards.json`
using the existing effect ops (the list is at the top of
`scripts/combat/effect_resolver.gd`), add the row to the sheet, run
`tools/export_expected_balance.py`, and add a test in
`tests/test_cards_in_combat.gd`. `BalanceCalculator.report()` prints every
card's value and budget.

## Rules decisions made while coding

The sheet didn't specify these, so they follow common genre conventions.
Change them in one place if the team disagrees.

- **Turn order:** at the start of your turn you lose your block, Poison ticks,
  energy refills, then Bulwark / Iron Skin block, Black Plague, and you draw 5.
  Enemies act one at a time in order; each loses its block and takes Poison
  right before it acts, and an enemy killed by Poison doesn't act.
- **Weak / Vulnerable** go down by 1 at the end of each round, after the
  enemies act. 1 Vulnerable you put on an enemy lasts for the rest of your turn
  and its turn. One an enemy puts on you skips that round's countdown, so
  1 Vulnerable from an enemy lasts through its next attack and 1 Weak lasts for
  your next turn. (Before this rule, 1 Vulnerable from an enemy did nothing.)
- **Damage** = (base + Strength + Sharpen) x 0.75 if Weak x 1.5 if Vulnerable,
  rounded down. Poison and Thorn Armor ignore Strength, Weak and Vulnerable.
  Poison and Reckless Charge ignore block.
- **Sharpen** adds to the first hit of your next Attack only (Twin Strike gets +3 once).
- **Envenom** triggers on each hit from an Attack card that gets past block.
- **Thorn Armor** triggers every time you gain block, including Iron Skin and Bulwark.
- **Hand limit** is 10. Cards drawn with a full hand go to the discard pile.
- **Exhaust** removes a card for that fight only; the run deck is never changed by a fight.
- **Powers** stack if you play two of the same.

## Balance note

The simulation shows the starter deck beats a normal enemy (12–25 HP from the
Rules tab) in about **2 turns**, while the sheet targets **3–4**. Raising
`normal_hp_min` / `normal_hp_max` in `data/rules.json` to roughly 35–45 would
hit the target. Left unchanged for the team to decide.
