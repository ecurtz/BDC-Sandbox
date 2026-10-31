class_name Weapon
extends RpgComponent

@export var cost:int = 0

@export var attacks:int = 0
@export var rend:int = 0
@export var damage:String = ""
@export var critical_damage:String = ""

func _to_string():
	if (resource_name):
		return resource_name
	else:
		return "Weapon"
		
class Roll:
	var attacker: Fighter
	var defender: Fighter
	var weapon: Weapon
	var value: int
	
	func _init(attacker:Fighter, defender:Fighter, weapon:Weapon, roll:int) -> void:
		self.attacker = attacker
		self.defender = defender
		self.weapon = weapon
		self.value = roll
	
	func can_crit() -> bool:
		return weapon.is_crit.call(self)
	
	func can_hit() -> bool:
		return weapon.is_hit.call(self)
	
	func can_parry(vs:Roll) -> bool:
		return weapon.is_parry.call(self, vs)
	
	func calculate_damage() -> int:
		var damage = ""
		if (can_crit()):
			damage = weapon.critical_damage
		elif (can_hit()):
			damage = weapon.damage
		else:
			return 0
		
		var dice_names = ["d3", "d6"]
		var dice_values = [DicePool.roll(1, 3), DicePool.roll(1, 6)]
		
		var expression = Expression.new()
		if (expression.parse(damage, dice_names) != OK):
			push_error(expression.get_error_text())
			return 0
		
		var result = expression.execute(dice_values, self)
		if (expression.has_execute_failed()):
			push_error(expression.get_error_text())
			return 0
		
		return int(result)
	
	func estimate_damage() -> float:
		var damage = ""
		if (can_crit()):
			damage = weapon.critical_damage
		elif (can_hit()):
			damage = weapon.damage
		else:
			return 0
		
		var dice_names = ["d3", "d6"]
		var dice_values = [2, 3.5]
		
		var expression = Expression.new()
		if (expression.parse(damage, dice_names) != OK):
			push_error(expression.get_error_text())
			return 0
		
		var result = expression.execute(dice_values, self)
		if (expression.has_execute_failed()):
			push_error(expression.get_error_text())
			return 0
		
		return float(result)

class HitAction extends RpgAction:
	var roll: Roll
	var damage: int
	
	const MISSED:int = 0
	const PARRIED:int = -1
	const ARMOUR_SAVE:int = -2
	
	func _init(roll:Roll) -> void:
		self.roll = roll
	
	func attempt(gm: GameMaster) -> bool:
		damage = roll.calculate_damage()
		
		var armour_save = Armour.SaveAction.new(roll.defender.armour_set, roll)
		gm.action_resolved.connect(_on_action_resolved)
		gm.attempt(armour_save)
		gm.action_resolved.disconnect(_on_action_resolved)
		
		var outcome = HitOutcome.new(self, damage)
		resolved.emit(outcome)
		return true
	
	func _on_action_resolved(outcome: Outcome) -> void:
		if ((outcome is Armour.SaveOutcome) && outcome.is_success()):
			damage = ARMOUR_SAVE
		
	func _to_string():
		if (roll.weapon.resource_name):
			return "Hit with %s (%d)" % [roll.weapon.resource_name, roll.value]
		else:
			return "Hit (%d)" % [roll.value]

class HitOutcome extends Outcome:
	func get_message() -> String:
		var hit = source as Weapon.HitAction

		if is_failure():
			if (result == HitAction.MISSED):
				return "%s missed" % [hit.roll.weapon]
			if (result == HitAction.PARRIED):
				return "%s was parried" % [hit.roll.weapon]
			if (result == HitAction.ARMOUR_SAVE):
				return "%s was blocked by armour" % [hit.roll.weapon]
		
		return "%s hit by %s for %d damage" % [hit.roll.defender, hit.roll.weapon, result]

class ParryAction extends RpgAction:
	var roll: Roll
	var against: Roll
	var parry: int
	
	const FAILED:int = -1

	func _init(roll:Roll, against:Roll) -> void:
		self.roll = roll
		self.against = against
	
	func attempt(gm: GameMaster) -> bool:
		parry = DicePool.roll(1, 6)
		if (parry  < 2):
			parry = FAILED
		
		var outcome = ParryOutcome.new(self, parry)
		resolved.emit(outcome)
		return true
	
	func _to_string():
		if (roll.weapon.resource_name):
			return "Parried with %s (%d)" % [roll.weapon.resource_name, roll.value]
		else:
			return "Parry (%d)" % [roll.value]

class ParryOutcome extends Outcome:
	func get_message() -> String:
		if is_failure():
			return "%s failed with result %d" % [source, result]
		
		return "%s succeded with result %d" % [source, result]

var is_crit: Callable = generic_is_crit
func generic_is_crit(roll:Roll) -> bool:
	return (roll.value == 6)

var is_hit: Callable = generic_is_hit
func generic_is_hit(roll:Roll) -> bool:
	if (roll.weapon is MeleeWeapon):
		return (roll.value >= roll.attacker.blade)
	if (roll.weapon is RangedWeapon):
		return (roll.value >= roll.attacker.bow)
	return false

var is_parry: Callable = generic_is_parry
func generic_is_parry(roll:Roll, vs:Roll) -> bool:
	return false
