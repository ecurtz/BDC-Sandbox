class_name RangedWeapon
extends Weapon

@export var range:int

enum TRAITS {
	ARCANE = (1 << 0),
	BLAST = (1 << 1),
	FLAME = (1 << 2),
	HEAVY = (1 << 3),
	MISFIRE = (1 << 4),
	ONE_USE = (1 << 5),
	POISON = (1 << 6),
	RARE = (1 << 7),
	UNWIELDY = (1 << 8),
	VOLLEY = (1 << 9)
	}
@export_flags ("Arcane", "Blast", "Flame", "Heavy", "Misfire", "One-use",
	"Poison", "Rare", "Unwieldy", "Volley") var traits:int

func has_trait(to_test:TRAITS) -> bool:
	return (traits & to_test)

func _init() -> void:
	self.is_crit = ranged_is_crit
	self.is_hit = ranged_is_hit

func ranged_is_crit(roll:Weapon.Roll) -> bool:
	if (roll.value == 6):
		return true
	if (has_trait(TRAITS.ARCANE) && (roll.value == 5)):
		return true
	
	return false

func ranged_is_hit(roll:Weapon.Roll) -> bool:
	if (roll.value >= roll.attacker.bow):
		return true
	
	return false

func roll_dice(attacker:Fighter) -> Array[int]:
	var pool = DicePool.new()
	
	pool.add(attacks, 6)
	
	return pool.roll_each()
