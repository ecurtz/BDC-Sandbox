class_name Fighter
extends RpgComponent

@export var cost:int = 0
@export var experience:int = 0

@export var move:int = 5
@export var blade:int = 4
@export var bow:int = 4
@export var armour:int = 6
@export var initiative:int = 3
@export var willpower:int = 3

@export var life:int = 3
var health:RpgStat

@export var melee_weapon_1:MeleeWeapon
@export var melee_weapon_2:MeleeWeapon
@export var armour_set:Armour
@export var ranged_weapon:RangedWeapon
@export var item_1:Item
@export var item_2:Item

@export var logic:FighterLogic

enum VETERAN_SKILLS {
	DUAL_WIELDER = (1 << 0),
	SHOOTING_DRILLS = (1 << 1),
	GREAT_WEAPONS = (1 << 2),
	UNSHAKEABLE = (1 << 3),
	TOUGH_BASTARD = (1 << 4),
	FAST_LEARNER = (1 << 5),
	DUELLIST = (1 << 6),
	STEADY_AIM = (1 << 7)
	}
@export_flags ("Dual Wielder", "Shooting Drills",
	"Great Weapons", "Unshakeable", "Tough Bastard",
	"Fast Learner", "Duellist", "Steady Aim") var skills:int

func has_skill(test:int) -> bool:
	return (skills & test)
	
enum FLAGS {
	BLOODIED = (1 << 0),
	CHARGING = (1 << 1),
	GUARDED = (1 << 2),
	EMPOWERED = (1 << 3),
	POISONED = (1 << 4),
	TAKEN_OUT = (1 << 5)
	}
var flags:int

func has_flag(to_test:FLAGS) -> bool:
	return (flags & to_test)
func set_flag(to_set:FLAGS) -> void:
	flags = (flags | to_set)
func clear_flag(to_clear:FLAGS) -> void:
	flags = (flags & ~to_clear)

var engagements:Array[Fighter] = []

var rolls:Array[Weapon.Roll] = []
	

func _init() -> void:
	health = RpgStat.new(life, 20, 0)
	
	if (!logic):
		logic = FighterLogic.Soldier.new()
		
	if (!melee_weapon_1):
		melee_weapon_1 = MeleeWeapon.unarmed_strike.duplicate(true)
		
	if (!armour_set):
		armour_set = Armour.clothing.duplicate(true)
	
	# add armour modifier for shield here

func _to_string():
	if (resource_name):
		return resource_name
	else:
		return "Fighter"

func engage(opponent: Fighter) -> void:
	if (!engagements.has(opponent)):
		engagements.append(opponent)

func disengage(opponent: Fighter) -> void:
	engagements.erase(opponent)

func roll_initiative(opponent: Fighter) -> int:
	return initiative + DicePool.roll(1, 6)

func roll_melee(opponent: Fighter) -> Array[Weapon.Roll]:
	rolls.clear()
	
	if (melee_weapon_1):
		var dice:Array[int] = melee_weapon_1.roll_dice(self)
		print(self, " rolls ", dice, " with ", melee_weapon_1)
		for die in dice:
			rolls.append(Weapon.Roll.new(self, opponent, melee_weapon_1, die))
		
	if (melee_weapon_2):
		var dice:Array[int] = melee_weapon_2.roll_dice(self)
		print(self, " rolls ", dice, " with ", melee_weapon_2)
		for die in dice:
			rolls.append(Weapon.Roll.new(self, opponent, melee_weapon_2, die))
		
	return rolls

func choose_melee_action(rolls:Array[Weapon.Roll], vs:Array[Weapon.Roll]) -> RpgAction:
	return logic.choose_melee_roll(rolls, vs)
	
func roll_ranged(opponent: Fighter) -> Array[Weapon.Roll]:
	rolls.clear()
	
	if (ranged_weapon):
		var dice:Array[int] = ranged_weapon.roll_dice(self)
		for die in dice:
			rolls.append(Weapon.Roll.new(self, opponent, ranged_weapon, die))
	
	return rolls

func choose_ranged_action(rolls:Array[Weapon.Roll]) -> RpgAction:
	return logic.choose_ranged_roll(rolls)
