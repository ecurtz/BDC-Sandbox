class_name Armour
extends RpgComponent

@export var cost:int = 0
@export var value:int = 0
var modifier:int = 0

static var clothing: Armour
static func _static_init() -> void:
	clothing = Armour.new()
	clothing.resource_name = "Basic Clothing"
	clothing.value = 6

class SaveAction extends RpgAction:
	var armour: Armour
	var against: Weapon.Roll
	
	const FAILED:int = -1

	func _init(armour:Armour, against:Weapon.Roll) -> void:
		self.armour = armour
		self.against = against
	
	func attempt(gm: GameMaster) -> bool:
		var roll = DicePool.roll(1, 6)
		
		# Accept positive or negative rend values
		var rend = absi(against.weapon.rend)
		if ((roll + armour.modifier - rend) < armour.value):
			roll = FAILED
		
		var outcome = SaveOutcome.new(self, roll)
		resolved.emit(outcome)
		return true
		
	func _to_string():
		if (armour.resource_name):
			return "Armour Save for " + armour.resource_name
		else:
			return "Armour Save"

class SaveOutcome extends Outcome:
	func get_message() -> String:
		if is_failure():
			return "%s failed" % [source]
		
		return "%s succeded with roll %d" % [source, result]
