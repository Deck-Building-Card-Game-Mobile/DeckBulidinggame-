# Handoff

## Known issues

See `docs/KNOWN_ISSUES.md` for what's not built or not verified yet.

- Card removal: `Deck.remove_card()` exists, but no screen calls it.
- Saving a run: the save and load functions exist, but nothing calls them. Closing the game loses the run.
- Keyword tap-to-explain isn't hooked up to the cards on screen.
- No dungeon map yet. The run is a fixed list of nine encounters.
- No Android or iOS export has been set up.
- A full nine-encounter playthrough was never fully verified.

## Open questions

- Should players be able to pause the game mid-fight, or only in between fights?
- Should Android or iOS builds come first? I would personally pick Android, because the App Store is a mess to deal with, from experience.

## Unplanted seeds

- Quick Run mode: three fights and a boss, and after each fight you choose a card to add to your deck. There are save points at the end of each fight, so you can stop and come back to the run later.

## What's next

Next should be a mobile build, just to see how everything works. Start by creating an Android export preset in Godot under Project → Export, since there is no `export_presets.cfg` yet. Then we can focus more on the UI and the dungeon map. The build comes first.
