@abstract
class_name RpgSystem
extends Node
## Abstract base class for Systems that want do be automatically managed via [GameMaster].
## Such Systems can be added as child nodes of the [GameMaster] or explicitly registered
## via [method GameMaster.register_system].


## If true, when registered, [method on_action_preview] will be automatically connected.
@export var connect_to_action_preview := false

## If true, when registered, [method on_action_resolved] will be automatically connected.
@export var connect_to_action_resolved := false

## Returns the reference [GameMaster].
## It is Automatically populated by [method GameMaster.register_system].
var gm: GameMaster


# Automatic self-registration if placed as a child of a [GameMaster].
func _ready() -> void:
	if get_parent() is GameMaster:
		get_parent().register_system(self)


## Connected to [signal GameMaster.action_preview] if [member connect_to_action_preview] is true.
##
## Default implementation does nothing.
func on_action_preview(action: RpgAction) -> void:
	pass


## Connected to [signal GameMaster.action_resolved] if [member connect_to_action_resolved] is true.
##
## Default implementation does nothing.
func on_action_resolved(outcome: Outcome) -> void:
	pass


## Connected to [signal GameMaster.component_added] for managing components.
##
## Default implementation does nothing; override in subclasses for custom results.
func on_component_added(component: RpgComponent) -> void:
	pass


## Connected to [signal GameMaster.component_removed] for managing components.
##
## Default implementation does nothing; override in subclasses for custom results.
func on_component_removed(component: RpgComponent) -> void:
	pass


## Connected to [signal GameMaster.entity_added] for managing entities.
##
## Default implementation does nothing; override in subclasses for custom results.
func on_entity_added(entity_id: int) -> void:
	pass


## Connected to [signal GameMaster.entity_removed] for managing entities.
##
## Default implementation does nothing; override in subclasses for custom results.
func on_entity_removed(entity_id: int) -> void:
	pass
