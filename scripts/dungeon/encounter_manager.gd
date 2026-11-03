
class_name EncounterManager
extends RefCounted

## ROLE 4 - ENCOUNTER MANAGEMENT
## Stores dungeon encounters and creates enemies.

const ENCOUNTERS: Array[Dictionary] = [
    {
        "kind": "battle",
        "name": "Dungeon Slime",
        "hp": 30,
        "damage": 6
    },
    {
        "kind": "battle",
        "name": "Cave Rat",
        "hp": 36,
        "damage": 8
    },
    {
        "kind": "rest"
    },
    {
        "kind": "battle",
        "name": "Skeleton Guard",
        "hp": 48,
        "damage": 10
    },
    {
        "kind": "boss",
        "name": "Dungeon Warden",
        "hp": 85,
        "damage": 13
    }
]


# Returns the number of encounters.
static func encounter_count() -> int:
    return ENCOUNTERS.size()


# Checks if an encounter index exists.
static func has_encounter(index: int) -> bool:
    return index >= 0 and index < encounter_count()


# Returns encounter information.
static func get_encounter(index: int) -> Dictionary:
    if not has_encounter(index):
        return {}

    return ENCOUNTERS[index].duplicate(true)


# Checks whether an encounter is a rest area.
static func is_rest(index: int) -> bool:
    var encounter := get_encounter(index)
    return encounter.get("kind", "") == "rest"


# Checks whether an encounter is the boss.
static func is_boss(index: int) -> bool:
    var encounter := get_encounter(index)
    return encounter.get("kind", "") == "boss"


# Checks whether an encounter involves combat.
static func is_battle(index: int) -> bool:
    var encounter := get_encounter(index)
    var kind: String = encounter.get("kind", "")

    return kind == "battle" or kind == "boss"


# Creates an enemy using the existing combat system.
static func create_enemy(index: int) -> Enemy:
    if not is_battle(index):
        return null

    var encounter := get_encounter(index)

    var actions: Array = [
        {
            "type": "attack",
            "amount": int(encounter["damage"]),
            "hits": 1
        },
        {
            "type": "block",
            "amount": 5
        }
    ]

    return Enemy.new(
        str(encounter["name"]),
        int(encounter["hp"]),
        actions
    )


# Finds the next encounter index.
static func next_encounter(index: int) -> int:
    return mini(index + 1, encounter_count())


# Checks whether all encounters are complete.
static func dungeon_completed(index: int) -> bool:
    return index >= encounter_count()
