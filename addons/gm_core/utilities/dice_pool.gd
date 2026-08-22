class_name DicePool
extends RefCounted
## A lightweight, chainable dice rolling utility with support for dice pools and modifiers.
## Implements a fluent interface for building complex roll expressions.


## Structure representing a single dice group
class DiceGroup:
	var count: int
	var sides: int
	var modifier: int
	
	func _init(p_count: int, p_sides: int, p_modifier: int = 0) -> void:
		count = p_count
		sides = p_sides
		modifier = p_modifier


# The collection of dice groups to roll
var _dice_groups: Array[DiceGroup] = []

# Active filters for keeping highest or lowest dice
var _keep_highest: int = -1
var _keep_lowest: int = -1


## Adds a group of dice to the pool with optional modifier.
## [method roll_each] results will be provided in order of addition.
##
## Returns self for method chaining.
func add(count: int, sides: int, modifier: int = 0) -> DicePool:
	_dice_groups.append(DiceGroup.new(count, sides, modifier))
	return self


## Clears all dice from the pool.
##
## Returns self for method chaining.
func clear() -> DicePool:
	_dice_groups.clear()
	_keep_highest = -1
	_keep_lowest = -1
	return self


## Filters results to keep only the highest dice.
##
## Returns self for method chaining.
func keep_highest(count: int) -> DicePool:
	_keep_highest = count
	_keep_lowest = -1
	return self


## Filters results to keep only the lowest dice.
##
## Returns self for method chaining.
func keep_lowest(count: int) -> DicePool:
	_keep_lowest = count
	_keep_highest = -1
	return self


## Rolls each die in the pool individually.
## Returns an array of individual die results, in order.
func roll_each() -> Array[int]:
	var results: Array[int] = []
	
	for die in _dice_groups:
		results.append(roll(die.count, die.sides, die.modifier))
	
	results = _apply_filters(results)
	return results


## Rolls all dice in the pool and returns the total sum.
func roll_sum() -> int:
	var total := 0
	for res in roll_each():
		total += res
	return total


## Static utility for quick dice rolls without creating a pool.
static func roll(count: int, sides: int, modifier: int = 0) -> int:
	var total := modifier
	for _i in range(count):
		total += randi() % sides + 1
	return total


# Applies keep_highest and keep_lowest filters to roll results.
# It keeps the same order from the input.
func _apply_filters(results: Array[int]) -> Array[int]:
	if results.is_empty():
		return results
	
	if _keep_highest > 0:
		var tmp := results.duplicate()
		tmp.sort_custom(func(a: int, b: int) -> bool: return a < b)
		for i in range(0, tmp.size() - _keep_highest):
			results.erase(tmp[i])
		return results
	
	if _keep_lowest > 0:
		var tmp := results.duplicate()
		tmp.sort_custom(func(a: int, b: int) -> bool: return a > b)
		for i in range(0, tmp.size() - _keep_lowest):
			results.erase(tmp[i])
		return results
	
	return results
