class_name RpgStat
extends Resource
## Abstract base class for RPG statistics.
## Provides core stat management with value clamping, change tracking, and lifecycle signals.


## Emitted when the stat reaches its minimum value
signal depleted(stat: RpgStat)

## Emitted when the stat reaches its maximum value
signal maxed(stat: RpgStat)

## Emitted when the stat value changes
signal value_changed(stat: RpgStat, delta: int)


## The maximum allowed value, it cannot be less than [minimum]
@export var maximum: int = 1:
	set(new_value):
		if new_value == maximum or new_value < minimum:
			return
		
		maximum = new_value
		value = value

## The minimum allowed value, it cannot be more than [maximum]
@export var minimum: int = 0:
	set(new_value):
		if new_value == minimum or new_value > maximum:
			return
		
		minimum = new_value
		value = value

## The current value, clamped between minimum and maximum
@export var value: int = 1:
	set(new_value):
		if new_value == value:
			return
		
		var previous_value := value
		value = clampi(new_value, minimum, maximum)
			
		var delta := value - previous_value
		if delta != 0:
			value_changed.emit(self, delta)
			
			if value == minimum:
				depleted.emit(self)
			elif value == maximum:
				maxed.emit(self)


## Initializes the Stat
func _init(start_value: int = 0, start_max: int = -1, start_min: int = 0) -> void:
	maximum = start_value if start_max < start_min else start_max
	minimum = start_min
	value = start_value


## Returns [value] as a percentage between [maximum] and [minimum] (0.0 to 1.0).
func get_percent() -> float:
	if maximum == minimum:
		return 0.0
	
	return float(value - minimum) / float(maximum - minimum)


## Returns true if the stat is at its [minimum] value.
func is_depleted() -> bool:
	return value == minimum


## Returns true if the stat is at its [maximum] value.
func is_maxed() -> bool:
	return value == maximum
