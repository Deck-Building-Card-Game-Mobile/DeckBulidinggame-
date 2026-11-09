
class_name EncounterManager
extends RefCounted

## ROLE 4 - ENCOUNTER MANAGEMENT
## Stores dungeon encounters and creates enemies.
## Expanded to nine encounters, including three elites
## and a two-phase final boss.

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
        "kind": "elite",
        "name": "Armored Sentinel",
        "hp": 65,
        "damage": 10,
        "block": 12
    },
    {
        "kind": "rest",
        "name": "Rest Area"
    },
    {
        "kind": "battle",
        "name": "Skeleton Guard",
        "hp": 48,
        "damage": 10
    },
    {
        "kind": "elite",
        "name": "Venomfang",
        "hp": 75,
        "damage": 12,
        "block": 8
    },
    {
        "kind": "battle",
        "name": "Crypt Knight",
        "hp": 58,
        "damage": 11
    },
    {
        "kind": "elite",
        "name": "Abyssal Champion",
        "hp": 90,
        "damage": 14,
        "block": 12
    },
    {
        "kind": "boss",
        "name": "Dungeon Warden",
        "hp": 85,
        "damage": 13,
        "phase_2_name": "Dungeon Warden - Awakened",
        "phase_2_hp": 110,
        "phase_2_damage": 17,
        "phase_2_block": 15
    }
]


# --------------------------------------------------
# ENCOUNTER LOOKUP
# --------------------------------------------------

static func encounter_count() -> int:
    return ENCOUNTERS.size()


static func has_encounter(index: int) -> bool:
    return index >= 0 and index < encounter_count()


static func get_encounter(index: int) -> Dictionary:
    if not has_encounter(index):
        return {}

    return ENCOUNTERS[index].duplicate(true)


static func is_rest(index: int) -> bool:
    var encounter := get_encounter(index)
    return encounter.get("kind", "") == "rest"


static func is_boss(index: int) -> bool:
    var encounter := get_encounter(index)
    return encounter.get("kind", "") == "boss"


static func is_elite(index: int) -> bool:
    var encounter := get_encounter(index)
    return encounter.get("kind", "") == "elite"


static func is_battle(index: int) -> bool:
    var encounter := get_encounter(index)
    var kind: String = str(encounter.get("kind", ""))

    return kind == "battle" or kind == "elite" or kind == "boss"


# --------------------------------------------------
# ENEMY CREATION
# --------------------------------------------------

# Supports both older calls:
# create_enemy(index)
#
# And the updated Run Manager:
# create_enemy(index, boss_phase)

static func create_enemy(index: int, boss_phase: int = 1) -> Enemy:
    if not is_battle(index):
        return null

    var encounter := get_encounter(index)

    var kind: String = str(encounter.get("kind", "battle"))
    var enemy_name: String = str(encounter.get("name", "Unknown Enemy"))
    var enemy_hp: int = int(encounter.get("hp", 30))
    var enemy_damage: int = int(encounter.get("damage", 6))
    var enemy_block: int = int(encounter.get("block", 5))

    if kind == "boss" and boss_phase == 2:
        enemy_name = str(
            encounter.get("phase_2_name", "Dungeon Warden - Awakened")
        )
        enemy_hp = int(encounter.get("phase_2_hp", enemy_hp))
        enemy_damage = int(encounter.get("phase_2_damage", enemy_damage))
        enemy_block = int(encounter.get("phase_2_block", enemy_block))

    var actions: Array = []

    match kind:
        "elite":
            actions = create_elite_actions(
                enemy_name,
                enemy_damage,
                enemy_block
            )

        "boss":
            actions = create_boss_actions(
                enemy_damage,
                enemy_block,
                boss_phase
            )

        _:
            actions = create_regular_actions(
                enemy_damage,
                enemy_block
            )

    return Enemy.new(
        enemy_name,
        enemy_hp,
        actions
    )


# --------------------------------------------------
# REGULAR ENEMY ACTIONS
# --------------------------------------------------

static func create_regular_actions(
    damage: int,
    block_amount: int
) -> Array:
    return [
        {
            "type": Enemy.INTENT_ATTACK,
            "amount": damage,
            "hits": 1
        },
        {
            "type": Enemy.INTENT_BLOCK,
            "amount": block_amount
        }
    ]


# --------------------------------------------------
# ELITE ENEMY ACTIONS
# --------------------------------------------------

static func create_elite_actions(
    enemy_name: String,
    damage: int,
    block_amount: int
) -> Array:
    match enemy_name:
        "Armored Sentinel":
            return [
                {
                    "type": Enemy.INTENT_BLOCK,
                    "amount": block_amount
                },
                {
                    "type": Enemy.INTENT_ATTACK,
                    "amount": damage,
                    "hits": 1
                },
                {
                    "type": Enemy.INTENT_BUFF,
                    "status": Combatant.STRENGTH,
                    "amount": 2
                },
                {
                    "type": Enemy.INTENT_ATTACK,
                    "amount": damage,
                    "hits": 2
                }
            ]

        "Venomfang":
            return [
                {
                    "type": Enemy.INTENT_ATTACK,
                    "amount": damage,
                    "hits": 1
                },
                {
                    "type": Enemy.INTENT_DEBUFF,
                    "status": Combatant.WEAK,
                    "amount": 2
                },
                {
                    "type": Enemy.INTENT_ATTACK,
                    "amount": maxi(1, damage - 4),
                    "hits": 2
                },
                {
                    "type": Enemy.INTENT_BLOCK,
                    "amount": block_amount
                }
            ]

        "Abyssal Champion":
            return [
                {
                    "type": Enemy.INTENT_ATTACK,
                    "amount": damage,
                    "hits": 1
                },
                {
                    "type": Enemy.INTENT_DEBUFF,
                    "status": Combatant.VULNERABLE,
                    "amount": 2
                },
                {
                    "type": Enemy.INTENT_BUFF,
                    "status": Combatant.STRENGTH,
                    "amount": 3
                },
                {
                    "type": Enemy.INTENT_ATTACK,
                    "amount": damage + 4,
                    "hits": 1
                },
                {
                    "type": Enemy.INTENT_BLOCK,
                    "amount": block_amount
                }
            ]

    return create_regular_actions(damage, block_amount)


# --------------------------------------------------
# TWO-PHASE FINAL BOSS
# --------------------------------------------------

static func create_boss_actions(
    damage: int,
    block_amount: int,
    boss_phase: int
) -> Array:
    if boss_phase == 2:
        return [
            {
                "type": Enemy.INTENT_ATTACK,
                "amount": damage,
                "hits": 1
            },
            {
                "type": Enemy.INTENT_BUFF,
                "status": Combatant.STRENGTH,
                "amount": 3
            },
            {
                "type": Enemy.INTENT_ATTACK,
                "amount": maxi(1, damage - 5),
                "hits": 2
            },
            {
                "type": Enemy.INTENT_DEBUFF,
                "status": Combatant.VULNERABLE,
                "amount": 2
            },
            {
                "type": Enemy.INTENT_BLOCK,
                "amount": block_amount
            }
        ]

    return [
        {
            "type": Enemy.INTENT_ATTACK,
            "amount": damage,
            "hits": 1
        },
        {
            "type": Enemy.INTENT_BLOCK,
            "amount": block_amount
        },
        {
            "type": Enemy.INTENT_ATTACK,
            "amount": maxi(1, damage - 3),
            "hits": 2
        },
        {
            "type": Enemy.INTENT_BUFF,
            "status": Combatant.STRENGTH,
            "amount": 2
        }
    ]


# --------------------------------------------------
# DUNGEON PROGRESSION HELPERS
# --------------------------------------------------

static func next_encounter(index: int) -> int:
    return mini(index + 1, encounter_count())


static func dungeon_completed(index: int) -> bool:
    return index >= encounter_count()
