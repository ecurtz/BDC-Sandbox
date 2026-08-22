class_name ModifiableStat
extends RpgStat
## Extends [RpgStat] with support for temporary and permanent modifiers.
## Modifiers are tracked by name and can be stacked.


## Emitted when a modifier is added, removed, or changed
signal mod_changed(stat: RpgStat, modifier_name: String, value: int)


## Dictionary of named modifiers mapped to their values
@export var modifiers: Dictionary[String, int] = {}


## Removes all modifiers by setting them first to zero.
## Note that [signal mod_changed] will be triggered for each one.
func clear_mods() -> void:
	for mod in modifiers:
		set_mod(mod, 0)
	modifiers.clear()


## Returns the current value accounting for all active modifiers.
func get_modified_value() -> int:
	var total_modifier: int = 0
	for mod_value in modifiers.values():
		total_modifier += mod_value
	return value + total_modifier


## Returns the value of a specific modifier, or `default_value` if it doesn't exist.
func get_mod(name: String, default_value: int = 0) -> int:
	return modifiers.get(name, default_value)


## Returns the total sum of all active modifiers.
func get_mod_total() -> int:
	var total: int = 0
	for mod_value in modifiers.values():
		total += mod_value
	return total


## Sets a modifier by name. If it already exists, it will be overwritten.
func set_mod(name: String, mod_value: int) -> void:
	var old_value: int = modifiers.get(name, 0)
	modifiers[name] = mod_value
	mod_changed.emit(self, name, mod_value)
