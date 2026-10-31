@abstract class_name FighterLogic
extends RpgComponent

@abstract func choose_melee_roll(rolls:Array[Weapon.Roll], vs:Array[Weapon.Roll]) -> RpgAction;
@abstract func choose_ranged_roll(rolls:Array[Weapon.Roll]) -> RpgAction;

static func calculate_power(roll:Weapon.Roll) -> float:
	var damage = roll.estimate_damage()
	var armour = roll.defender.armour_set.save_chance(roll)
	return damage * (1 - armour)

static func compare_power(roll1:Weapon.Roll, roll2:Weapon.Roll):
	if calculate_power(roll1) > calculate_power(roll2):
		return true
	else:
		return false

static func calculate_parry(roll:Weapon.Roll, parry:Weapon.Roll) -> float:
	if (!roll.can_parry(parry)):
		return -1
		
	var r_power = calculate_power(roll)
	var p_power = calculate_power(parry)
	return p_power - r_power

class Beast extends FighterLogic:
	func choose_melee_roll(rolls:Array[Weapon.Roll], vs:Array[Weapon.Roll]) -> RpgAction:
		var chosen_roll:Weapon.Roll = null
		for roll in rolls:
			if (roll.can_crit()):
				chosen_roll = roll
				break
			elif (roll.can_hit()):
				chosen_roll = roll
		
		if (chosen_roll):
			rolls.erase(chosen_roll)
			return Weapon.HitAction.new(chosen_roll)
		
		rolls.clear()
		return null
	
	func choose_ranged_roll(rolls:Array[Weapon.Roll]) -> RpgAction:
		rolls.clear()
		return null

class Brute extends FighterLogic:
	func choose_melee_roll(rolls:Array[Weapon.Roll], vs:Array[Weapon.Roll]) -> RpgAction:
		var chosen_roll:Weapon.Roll = null
		for roll in rolls:
			if (roll.can_crit()):
				chosen_roll = roll
				break
			elif (roll.can_hit()):
				chosen_roll = roll
		
		if (chosen_roll):
			rolls.erase(chosen_roll)
			return Weapon.HitAction.new(chosen_roll)
		
		var chosen_parry:Weapon.Roll = null
		for roll in rolls:
			for parry in vs:
				if (roll.can_parry(parry)):
					chosen_roll = roll
					chosen_parry = parry
		
		if (chosen_roll && chosen_parry):
			rolls.erase(chosen_roll)
			return Weapon.ParryAction.new(chosen_roll, chosen_parry)
		
		rolls.clear()
		return null
	
	func choose_ranged_roll(rolls:Array[Weapon.Roll]) -> RpgAction:
		var chosen_roll:Weapon.Roll = null
		for roll in rolls:
			if (roll.can_crit()):
				chosen_roll = roll
				break
			elif (roll.can_hit()):
				chosen_roll = roll
		
		if (chosen_roll):
			rolls.erase(chosen_roll)
			return Weapon.HitAction.new(chosen_roll)
		
		rolls.clear()
		return null

class Soldier extends FighterLogic:
	func choose_melee_roll(rolls:Array[Weapon.Roll], vs:Array[Weapon.Roll]) -> RpgAction:
		var chosen_hit:Weapon.Roll = null
		var chosen_roll:Weapon.Roll = null
		var chosen_parry:Weapon.Roll = null
		
		if (rolls.is_empty()):
			return null
		
		var a_health = rolls[0].attacker.health.value
		var d_health = rolls[0].defender.health.value
		
		rolls.sort_custom(compare_power)

		vs.sort_custom(compare_power)
		
		var crits = 0
		var hits = 0
		for roll in rolls:
			# print("%d : %f" % [roll.value, calculate_power(roll)])
			if (roll.can_crit()):
				chosen_roll = roll
				crits += 1
				hits += 1
			elif (roll.can_hit()):
				chosen_roll = roll
				hits += 1
		
		var vs_crits = 0
		var vs_hits = 0
		for roll in vs:
			if (roll.can_crit()):
				vs_crits += 1
				vs_hits += 1
			elif (roll.can_hit()):
				vs_hits += 1
		
		# Check for impending doom
		if (vs_hits > 1):
			var incoming = calculate_power(vs[1])
			if ((incoming > (a_health - 0.6)) && (hits > 0)):
				chosen_hit = rolls[0]
				rolls.erase(chosen_hit)
				return Weapon.HitAction.new(chosen_hit)
				
		# Check parry options
		var parry_score = 0
		for roll in rolls:
			for parry in vs:
				var score = calculate_parry(roll, parry)
				if (score > parry_score):
					parry_score = score
					chosen_roll = roll
					chosen_parry = parry
		
		if (parry_score > 0.5):
			rolls.erase(chosen_roll)
			return Weapon.ParryAction.new(chosen_roll, chosen_parry)
		
		# Check hit options
		var power_score = 0
		for roll in rolls:
			if (roll.can_hit()):
				chosen_hit = roll
				power_score = calculate_power(chosen_hit)
				break
		
		if (power_score > 0.7):
			rolls.erase(chosen_hit)
			return Weapon.HitAction.new(chosen_hit)
		
		if (parry_score > 0):
			rolls.erase(chosen_roll)
			return Weapon.ParryAction.new(chosen_roll, chosen_parry)
			
		if (power_score > 0):
			rolls.erase(chosen_hit)
			return Weapon.HitAction.new(chosen_hit)
		
		rolls.clear()
		return null
	
	func choose_ranged_roll(rolls:Array[Weapon.Roll]) -> RpgAction:
		var chosen_roll:Weapon.Roll = null
		for roll in rolls:
			if (roll.can_crit()):
				chosen_roll = roll
				break
			elif (roll.can_hit()):
				chosen_roll = roll
		
		if (chosen_roll):
			rolls.erase(chosen_roll)
			return Weapon.HitAction.new(chosen_roll)
		
		rolls.clear()
		return null
