class_name Outcome
extends RefCounted
## Represents the outcome of an [RpgAction] attempt, including the source action and numeric result.
## Subclasses can extend this to provide domain-specific success/failure semantics.


## The [RpgAction] that produced this Outcome.
var source: RpgAction

## A numeric result value. Meaning is defined by the [RpgAction] and subclasses.
## Can represent degrees of success, damage amounts, or other domain logic.
var result: int = 0


## Intializes the Outcome.
func _init(source_action: RpgAction, action_result: int):
	self.source = source_action
	self.result = action_result


## Returns a human-readable message describing this outcome.
##
## Default implementation returns a basic information string;
## override in subclasses for custom messages.
func get_message() -> String:
	if is_failure():
		return "%s failed with result %d" % [source, result]
	
	return "%s succeded with result %d" % [source, result]


## Returns true if this outcome represents a failed action.
##
## Default implementation returns false if [member result] is zero or negative;
## override in subclasses for custom logic.
func is_failure() -> bool:
	return result <= 0


## Returns true if this outcome represents a successful action.
##
## Default implementation returns true if [member result] is positive;
## override in subclasses for custom logic.
func is_success() -> bool:
	return result > 0
