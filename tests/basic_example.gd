extends Node


@onready var gm: GameMaster = $GameMaster


func _ready() -> void:
	# Connect a preview interceptor and an outcome listener
	gm.action_preview.connect(_on_action_preview)
	gm.action_resolved.connect(_on_action_resolved)
	
	# Spawn a couple of entities
	var hero_id = gm.entities.add_entity([CharacterSheet.new()])
	var enemy_id = gm.entities.add_entity([CharacterSheet.new()])
	
	# Run the action through the GM
	gm.attempt(AttackAction.new(hero_id, enemy_id))


func _on_action_preview(action: RpgAction) -> void:
	if action is AttackAction:
		# Tweak the action data before execution
		# This can be handled by the action itself or an external system
		action.damage_mod = -1


func _on_action_resolved(outcome: Outcome) -> void:
	print_debug(outcome.get_message())


## RpgComponent example
class CharacterSheet extends RpgComponent:
	@export var attack := RpgStat.new(4, 10)
	@export var defense := RpgStat.new(0, 10)
	@export var health := RpgStat.new(10)


## RpgAction example
class AttackAction extends RpgAction:
	var attacker_id: int
	var target_id: int
	var damage_mod := 0

	func _init(my_attacker_id: int, my_target_id: int) -> void:
		attacker_id = my_attacker_id
		target_id = my_target_id

	func attempt(gm: GameMaster) -> bool:
		var attacker_stats = gm.entities.get_component(CharacterSheet, attacker_id)
		var target_stats = gm.entities.get_component(CharacterSheet, target_id)

		var roll := DicePool.roll(1, attacker_stats.attack.value, damage_mod)
		var damage := maxi(roll - target_stats.defense.value, 0)
		target_stats.health.value -= damage

		resolved.emit(Outcome.new(self, damage))
		return true
