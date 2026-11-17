# Dungeon Deck — Known Issues and Unfinished Work

Written for the team taking over the project (November 2026).

## Not built yet

- **Card removal.** `Deck.remove_card()` exists, but no screen calls it.
- **Saving a run.** `Deck.to_save_data()` and `Deck.from_save_data()` exist, but
  nothing calls them. Closing the game loses the run.
- **Keyword tap-to-explain.** `data/keywords.json` and `Keywords.get_rule()`
  exist, but a card on screen shows only its name, cost and text.
- **Dungeon map and encounter choices.** The run is a fixed list of nine
  encounters in `scripts/dungeon/encounter_manager.gd`.
- **Mobile builds.** There is no `export_presets.cfg`, so no Android or iOS
  export has been set up. Create presets in Godot under Project → Export.

## Not verified

- A full nine-encounter playthrough (all three elites and both boss phases) was
  never independently verified. See section 12 of `Doc/README.md`.
- Run the test suite before you change anything, so you know your starting
  point: `godot --headless --path . --script res://tests/run_tests.gd`
- Role 4's feedback in `team-feedback/role4-feedback.md` is still marked
  "Pending Review". It asks for explanations of End Turn and Discard Mode,
  clearer feedback on playable cards, and better use of the combat screen.

## Places where code, data and docs disagree

- **Draw odds are in code, not data.** `data/rules.json` sets
  `cards_drawn_per_turn` to 5, which is used only on the first turn. The later
  odds (1 card 35%, 2 cards 50%, 3 cards 15%) are written directly in
  `scripts/combat/combat_state.gd`.
- **Enemy HP in `data/rules.json` is not used by the game.** The `enemies`
  block (normal 12–25, elite 40–60, boss 130) is read only by the simulation
  test. Real enemy stats are in `EncounterManager.ENCOUNTERS`: regular enemies
  30–58 HP, elites 65–90, boss 85 then 110. The balance note in
  `docs/CARD_SYSTEM.md` is based on the 25 HP test enemy.
- **`legendary_choice_after` is not read.** It lists "elite" and "boss", but the
  elite-only rule is written directly in `scripts/dungeon/run_manager.gd`, and
  the boss fight gives no reward.
- **Retain has no visible effect.** Every unplayed card now stays in hand, so
  the Retain flag on 11 cards, and Master Plan's "keep your whole hand", change
  nothing. Decide whether to drop the keyword or bring back end-of-turn discard.

## Stale or unused files

- `web-export/` is a web build from before the dungeon grew to nine encounters.
  The `gh-pages` branch is older still (22 October 2026). Rebuild before
  sharing a web link.
- `scenes/dungeon/run_manager.tscn` is not loaded by the game. The main menu
  attaches `scripts/dungeon/run_manager.gd` to a new node directly.
