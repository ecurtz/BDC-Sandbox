class_name ProgressStat
extends RpgStat
## Extends [RpgStat] with support for milestone thresholds and progression tracking.
## Tracks when the stat crosses predefined thresholds and emits signals.


## Emitted when the stat value crosses a threshold.
## [param delta] is positive when surpassing a threshold, and negative when dropping below it.
signal threshold_crossed(stat: RpgStat, threshold_name: String, delta: int)


## Dictionary mapping threshold names to their value triggers
@export var thresholds: Dictionary[String, int] = {}


# Internal state tracking to detect actual threshold boundary transitions.
var _previous_value: int


## Initializes the Stat and threshold tracking when value changes.
func _init(start_value: int = 0, start_max: int = 100, start_min: int = 0) -> void:
	super(start_value, start_max, start_min)
	_previous_value = value
	value_changed.connect(func(stat: RpgStat, delta: int) -> void:
		_on_value_changed(stat.value, delta)
	)


## Returns the value of a specific threshold, or -1 if it doesn't exist.
func get_threshold(name: String) -> int:
	return thresholds.get(name, -1)


## Returns true if the stat is currently at or above a specific threshold.
func is_at_threshold(name: String) -> bool:
	if name not in thresholds:
		return false
	return value >= thresholds[name]


## Removes a threshold by name.
func remove_threshold(name: String) -> void:
	thresholds.erase(name)


## Adds a named threshold at the specified value.
func set_threshold(name: String, threshold_value: int) -> void:
	thresholds[name] = threshold_value


# Catches the parent [signal value_changed] to check threshold crossing.
func _on_value_changed(new_value: int, delta: int) -> void:
	var old_value := _previous_value
	_previous_value = new_value

	for threshold_name in thresholds.keys():
		var target: int = thresholds[threshold_name]
		
		if old_value < target and new_value >= target:
			threshold_crossed.emit(self, threshold_name, delta)
			print_debug([threshold_name, delta])
		elif old_value >= target and new_value < target:
			threshold_crossed.emit(self, threshold_name, delta)
			print_debug([threshold_name, delta])
