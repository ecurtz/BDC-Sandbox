@abstract
class_name RpgComponent
extends Resource
## Base RPG component wrapper used to define lightweight, entity-aware data objects.
## Components are Resources that carry an `entity_id` assigned by the [EntityContainer].


## Invalid entity ID, valid IDs must be zero or positive.
const INVALID_ENTITY: int = -1


## The id of the entity this component is attached to.
## [member INVALID_ENTITY] means unassigned.
@export var entity_id := INVALID_ENTITY


## Returns true when the component is currently assigned to an entity.
func is_assigned() -> bool:
	return entity_id >= 0
