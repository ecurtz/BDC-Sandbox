class_name MeleeWeapon
extends Weapon

enum TRAITS {
	ARCANE = (1 << 0),
	BLUDGEON = (1 << 1),
	BRACE = (1 << 2),
	GUARD = (1 << 3),
	HEAVY = (1 << 4),
	NATURAL = (1 << 5),
	OFF_HAND = (1 << 6),
	ONE_USE = (1 << 7),
	POISON = (1 << 8),
	RARE = (1 << 9),
	SCARE = (1 << 10),
	TWO_HANDED = (1 << 11),
	UNWIELDY = (1 << 12),
	WRAP = (1 << 13)
	}
@export_flags ("Arcane", "Bludgeon", "Brace", "Guard", "Heavy",
	"Natural", "Off-hand", "One-use", "Poison", "Rare", "Scare",
	"Two-handed", "Unwieldy", "Wrap") var traits:int

func has_trait(to_test:TRAITS) -> bool:
	return (traits & to_test)

enum FLAGS {
	USED = (1 << 7)
	}
var flags:int = 0

func has_flag(to_test:FLAGS) -> bool:
	return (flags & to_test)
func set_flag(to_set:FLAGS) -> void:
	flags = (flags | to_set)
func clear_flag(to_clear:FLAGS) -> void:
	flags = (flags & ~to_clear)

static var unarmed_strike: MeleeWeapon
static func _static_init() -> void:
	unarmed_strike = MeleeWeapon.new()
	unarmed_strike.resource_name = "Unarmed Strike"
	unarmed_strike.attacks = 2
	unarmed_strike.damage = "1"
	unarmed_strike.critical_damage = "1"
	unarmed_strike.traits = TRAITS.NATURAL

func _init() -> void:
	self.is_crit = melee_is_crit
	self.is_hit = melee_is_hit
	self.is_parry = melee_is_parry

func melee_is_crit(roll:Weapon.Roll) -> bool:
	if (roll.value == 6):
		return true
	if (has_trait(TRAITS.ARCANE) && (roll.value == 5)):
		return true
	
	return false

func melee_is_hit(roll:Weapon.Roll) -> bool:
	if (roll.value >= roll.attacker.blade):
		return true
	
	return false

func melee_is_parry(roll:Weapon.Roll, vs:Weapon.Roll) -> bool:
	if (has_trait(TRAITS.WRAP)):
		return false
	if (vs.weapon.has_trait(TRAITS.WRAP)):
		return false
	if (has_trait(TRAITS.NATURAL)):
		return false
	
	if (self.is_crit.call(roll)):
		return true
	if (vs.weapon.is_crit.call(vs)):
		return false
	
	if (self.is_hit.call(roll)):
		return true
	
	if (has_trait(TRAITS.GUARD) && !roll.attacker.has_flag(Fighter.FLAGS.GUARDED)):
		return true
	
	return false

func roll_dice(attacker:Fighter, offhand:bool = false) -> Array[int]:
	var pool = DicePool.new()
	
	if (offhand):
		if (has_trait(TRAITS.OFF_HAND)):
			pool.add(1, 6)
			if (attacker.has_skill(Fighter.VETERAN_SKILLS.DUAL_WIELDER)):
				pool.add(1, 6)
	else:
		for i in attacks:
			pool.add(1, 6)
	
	return pool.roll_each()
