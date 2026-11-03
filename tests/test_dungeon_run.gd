
extends TestCase

## ROLE 4 - DUNGEON TESTS
## Tests encounter configuration, combat setup,
## deck persistence, rewards, and healing rules.


func test_encounter_count() -> void:
    check_eq(EncounterManager.encounter_count(), 5)


func test_first_encounter() -> void:
    var encounter := EncounterManager.get_encounter(0)

    check_eq(encounter["kind"], "battle")
    check_eq(encounter["name"], "Dungeon Slime")
    check_eq(encounter["hp"], 30)


func test_encounter_sequence() -> void:
    check_eq(EncounterManager.next_encounter(0), 1)
    check_eq(EncounterManager.next_encounter(1), 2)
    check_eq(EncounterManager.next_encounter(2), 3)
    check_eq(EncounterManager.next_encounter(3), 4)
    check_eq(EncounterManager.next_encounter(4), 5)


func test_rest_area() -> void:
    check(EncounterManager.is_rest(2))
    check(not EncounterManager.is_battle(2))
    check(not EncounterManager.is_boss(2))


func test_boss_encounter() -> void:
    check(EncounterManager.is_boss(4))
    check(EncounterManager.is_battle(4))
    check(not EncounterManager.is_boss(0))


func test_dungeon_completion() -> void:
    check(not EncounterManager.dungeon_completed(0))
    check(not EncounterManager.dungeon_completed(4))
    check(EncounterManager.dungeon_completed(5))


func test_invalid_encounter() -> void:
    check(not EncounterManager.has_encounter(-1))
    check(not EncounterManager.has_encounter(5))
    check(EncounterManager.get_encounter(99).is_empty())


func test_create_enemy() -> void:
    var enemy := EncounterManager.create_enemy(0)

    check(enemy != null)

    if enemy != null:
        check_eq(enemy.display_name, "Dungeon Slime")
        check_eq(enemy.max_hp, 30)
        check_eq(enemy.current_intent()["amount"], 6)


func test_create_boss() -> void:
    var boss := EncounterManager.create_enemy(4)

    check(boss != null)

    if boss != null:
        check_eq(boss.display_name, "Dungeon Warden")
        check_eq(boss.max_hp, 85)
        check_eq(boss.current_intent()["amount"], 13)


func test_rest_has_no_enemy() -> void:
    check(EncounterManager.create_enemy(2) == null)


func test_starting_deck() -> void:
    var deck := Deck.create_starter()

    check_eq(deck.size(), 10)


func test_card_reward() -> void:
    var deck := Deck.create_starter()
    var starting_size := deck.size()

    var rng := RandomNumberGenerator.new()
    rng.seed = 12345

    var rewards := RewardGenerator.generate_choices(rng)

    check_eq(rewards.size(), 3)

    if not rewards.is_empty():
        deck.add_card(rewards[0].id)
        check_eq(deck.size(), starting_size + 1)


func test_hp_carries_into_combat() -> void:
    var deck := Deck.create_starter()
    var combat := CombatState.new()

    combat.start(
        deck,
        45,
        [EncounterManager.create_enemy(0)]
    )

    check_eq(combat.player.hp, 45)


func test_deck_carries_between_battles() -> void:
    var deck := Deck.create_starter()
    var rewards := CardDatabase.get_reward_pool()

    if rewards.is_empty():
        check(false, "Reward pool is empty")
        return

    deck.add_card(rewards[0].id)

    var size_after_reward := deck.size()

    var combat := CombatState.new()

    combat.start(
        deck,
        55,
        [EncounterManager.create_enemy(1)]
    )

    check_eq(deck.size(), size_after_reward)
    check_eq(combat.player.hp, 55)


func test_rest_healing() -> void:
    var hp := 44
    var max_hp := GameRules.player_max_hp()

    hp = mini(max_hp, hp + 20)

    check_eq(hp, 64)

    hp = mini(max_hp, hp + 20)

    check_eq(hp, 70)


func test_encounter_configuration_matches_run_manager() -> void:
    var script = load(
        "res://scripts/dungeon/run_manager.gd"
    )

    check(script != null)

    if script == null:
        return

    var run_encounters: Array = script.ENCOUNTERS

    check_eq(
        run_encounters.size(),
        EncounterManager.encounter_count()
    )

    for index in range(run_encounters.size()):
        check_eq(
            run_encounters[index],
            EncounterManager.get_encounter(index)
        )
