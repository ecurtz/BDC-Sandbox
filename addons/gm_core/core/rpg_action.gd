@abstract
class_name RpgAction
extends RefCounted
## Abstract base class for encapsulating Actions that can be attempted by entities.
## Actions are executed through the [GameMaster] and produce an [Outcome].


## Emitted when the action is resolved with an [Outcome].
signal resolved(outcome: Outcome)


## Attempts to execute this action within the given [GameMaster] context.
## Returns true if the action is valid and is being executed, false otherwise.
## Emits [signal resolved] when the action is actually completed.
##
## This method should only be called by [method GameMaster.attempt].
##
## Must be overridden in subclass.
@abstract func attempt(gm: GameMaster) -> bool;


## Returns true if this action is allowed to be attempted in the current game state.
##
## Default implementation returns true and always allow execution;
## override in subclasses for custom results.
func is_allowed(gm: GameMaster) -> bool:
	return true
