@abstract class_name FighterLogic
extends RpgComponent

@abstract func choose_melee_roll(rolls:Array[Weapon.Roll], vs:Array[Weapon.Roll]) -> RpgAction;
@abstract func choose_ranged_roll(rolls:Array[Weapon.Roll]) -> RpgAction;

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
