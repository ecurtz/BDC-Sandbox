extends Node

@export var fighter_a:Fighter
@export var fighter_b:Fighter

@onready var gm: GameMaster = $GameMaster

func _ready() -> void:
	# Connect a preview interceptor and an outcome listener
	gm.action_preview.connect(_on_action_preview)
	gm.action_resolved.connect(_on_action_resolved)
	
	# Spawn the combat system and a couple of fighters
	var combat = find_child("CombatSystem")
	
	if (fighter_a):
		fighter_a = fighter_a.duplicate(true)
	else:
		fighter_a = Fighter.new()
		fighter_a.resource_name = "Fighter"
	fighter_a.resource_name += " A"
	if (fighter_b):
		fighter_b = fighter_b.duplicate(true)
	else:
		fighter_b = Fighter.new()
		fighter_b.resource_name = "Fighter"
	fighter_b.resource_name += " B"
	var id_a = gm.entities.add_entity([fighter_a])
	var id_b = gm.entities.add_entity([fighter_b])
	
	var round:int = 1
	while ((fighter_a.health.value > 0) && (fighter_b.health.value > 0)):
		print("Round ", round)
		combat.MeleeRound(fighter_a, fighter_b)
		round += 1

	if (fighter_a.health.value <= 0):
		print(fighter_a, " taken down")
	if (fighter_b.health.value <= 0):
		print(fighter_b, " taken down")

func _on_action_preview(action: RpgAction) -> void:
	if action is Weapon.HitAction:
		var hit = action as Weapon.HitAction

func _on_action_resolved(outcome: Outcome) -> void:
	print(outcome.get_message())
