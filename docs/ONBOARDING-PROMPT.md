# Onboarding Prompt

You are joining the team working on Dungeon Deck, a mobile deck-building card game that's easy to pick up and not too complex, where players build and customize their own deck.

## Tech

- Godot 4.7 with GDScript. It's a free, easy setup.
- To run: clone the repo on main, import the project into Godot, and press F5.

## What the game does

- Turns, players, energy and resources, playing cards, applying effects, and combat.
- Enemies that get harder as the run goes on.
- Win or lose, no ties.
- Card data, effects, and adding or removing cards from your deck, so you can do whatever you want with it.
- A main menu and basic UI that's readable and easy to control on mobile.
- Dungeon progression with battles, rest areas, and bosses, plus rewards along the way.

## Key rules (from data/rules.json)

- Draw 5 cards on the first turn, then 1–3 cards each turn after. 3 energy per turn, max hand of 10.
- Reward card odds: 60% Common, 31% Uncommon, 7% Rare, 2% Legendary.

## Main systems

Combat, cards, dungeon, and run management.

## Open question

Online play is a maybe. The team hasn't decided.

## Known issues (short list)

- Card removal: `Deck.remove_card()` exists, but no screen calls it.
- Saving a run: the save and load functions exist, but nothing calls them. Closing the game loses the run.
- Keyword tap-to-explain isn't hooked up to the cards on screen.
- No dungeon map yet. The run is a fixed list of nine encounters.
- No Android or iOS export has been set up.
- A full nine-encounter playthrough was never fully verified.

## Main priority

A phone build comes first, so we can see how everything runs on a real phone before building more.

## Where to look next

Repo: https://github.com/Deck-Building-Card-Game-Mobile/DeckBulidinggame- (read it directly if you can). See `docs/HANDOFF.md` and `docs/KNOWN_ISSUES.md`.

## How our test went

Our first test got the basics right but couldn't see the known issues. After we added a short known-issues list and the main priority, the second test improved a lot. It still mentioned two docs it couldn't actually open.
