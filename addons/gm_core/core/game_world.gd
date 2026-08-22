@abstract
class_name GameWorld
extends Resource
## Base class for data objects that contain the state of the game world.
## When added to the [GameMaster], it will be notified of changes to entities and components.


## Called by the parent [GameMaster] when a [RpgComponent] is added to an entity.
##
## Subclasses should listen for the correct type of components to update
## their internal data structures.
func add_component(component: RpgComponent) -> void:
	return


## Called by the parent [GameMaster] when a [RpgComponent] is removed from an entity.
##
## Subclasses should clear their internal data structures on update.
func remove_component(component: RpgComponent) -> void:
	return
