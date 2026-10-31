class_name CombatSystem
extends RpgSystem

func _ready() -> void:
	# to do - what's the right gdscript call for the base method?
	if get_parent() is GameMaster:
		get_parent().register_system(self)
	
	# Connect a preview interceptor and an outcome listener
	gm.action_preview.connect(_on_action_preview)
	gm.action_resolved.connect(_on_action_resolved)

func MeleeRound(attacker:Fighter, defender:Fighter) -> void:
	if (!attacker || !defender):
		return
	
	attacker.engage(defender)
	defender.engage(attacker)
	
	var attacker_has_init = true
	if (attacker.has_flag(Fighter.FLAGS.CHARGING)):
		if (defender.melee_weapon_1.has_trait(MeleeWeapon.TRAITS.BRACE)):
			attacker_has_init = false
	else:
		var attacker_init = attacker.initiative + DicePool.roll(1, 6)
		var defender_init = defender.initiative + DicePool.roll(1, 6)
		if (defender_init > attacker_init):
			attacker_has_init = false
	
	if (attacker_has_init):
		print(attacker, " has initiative")
	else:
		print(defender, " has initiative")
	
	var a_rolls = attacker.roll_melee(defender)
	var d_rolls = defender.roll_melee(attacker)

	var action:RpgAction
	while (a_rolls || d_rolls):
		if (attacker_has_init):
			action = attacker.choose_melee_action(a_rolls, d_rolls)
		else:
			action = defender.choose_melee_action(d_rolls, a_rolls)
		attacker_has_init = !attacker_has_init
	
		if (action):
			gm.attempt(action)
			
		if (attacker.health.is_depleted() || defender.health.is_depleted()):
			break;
			
	attacker.clear_flag(Fighter.FLAGS.CHARGING)

func RangedRound(attacker:Fighter, target:Fighter) -> void:
	if (!attacker || !target):
		return
	
	var a_rolls = attacker.roll_ranged(target)
	
	var action:RpgAction
	while (a_rolls):
		action = attacker.choose_ranged_action(a_rolls)
		
		if (action):
			gm.attempt(action)
			
		if (target.health.is_depleted()):
			break;

func _on_action_preview(action: RpgAction) -> void:
	if (action is Weapon.HitAction):
		var hit = action as Weapon.HitAction
		print(hit.roll.attacker)
		print(hit)
	if (action is Weapon.ParryAction):
		var parry = action as Weapon.ParryAction
		print(parry.roll.attacker)
		print(parry)

func _on_action_resolved(outcome: Outcome) -> void:
	if (outcome is Weapon.HitOutcome):
		if (outcome.is_success()):
			var action = (outcome as Weapon.HitOutcome).source
			var hit = action as Weapon.HitAction
			var defender = hit.roll.defender as Fighter
			defender.health.value -= hit.damage
		#else:
			#print("Weapon Fail")
			#
	if (outcome is Weapon.ParryOutcome):
		if (outcome.is_success()):
			var action = (outcome as Weapon.ParryOutcome).source
			var parry = action as Weapon.ParryAction
			var defender = parry.roll.defender as Fighter
			var parried = parry.against as Weapon.Roll
			defender.rolls.erase(parried)
		#else:
			#print("Parry Fail")
			#
	#if (outcome is Armour.SaveOutcome):
		#if (outcome.is_success()):
			#print("Armour Saved")
		#else:
			#print("Armour Fail")
