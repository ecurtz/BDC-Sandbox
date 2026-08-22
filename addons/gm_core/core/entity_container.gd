class_name EntityContainer
extends Resource
## Container for entities and their [RpgComponent].
## Provides id generation, storage and typed queries.


## Emitted after an entity is registered, before any [signal component_added].
signal entity_added(entity_id: int)

## Emitted when an entity is removed, after any [signal component_removed].
signal entity_removed(entity_id: int)

## Emitted for each component added to an entity, after [signal entity_added].
signal component_added(component: RpgComponent)

## Emitted for each component removed from an entity, before [signal entity_removed].
signal component_removed(component: RpgComponent)


## Tracks the last generated ID.
@export_storage var last_id: int = 0

## Stores a list of [RpgComponent] objects by their entity ID.
@export_storage var components_by_entity: Dictionary[int, Array] = {}


## Adds an entity with the provided components and returns the new entity id.
##
## It first generates a new entity ID and emits [signal entity_added],
## then emits [signal component_added] for each added component.
func add_entity(components: Array[RpgComponent]) -> int:
	var id := _next_id()
	components_by_entity[id] = []

	for component in components:
		if component == null:
			continue
		component.entity_id = id
		components_by_entity[id].append(component)

	entity_added.emit(id)
	for component in components_by_entity[id]:
		component_added.emit(component)

	return id


## Adds a single component to an existing entity.
##
## If the entity does not exist the method logs an error and does nothing.
func add_component(component: RpgComponent, entity_id: int) -> void:
	if entity_id <= 0 or entity_id not in components_by_entity:
		push_error("invalid entity_id ", entity_id)
		return

	component.entity_id = entity_id
	components_by_entity[entity_id].append(component)
	component_added.emit(component)


## Returns a list of entity ids matching the optional filter.
## The filter callable receives `(entity_id: int, components: Array[RpgComponent])` and must return `bool`.
##
## If no filter is provided, all entities are returned.
func get_entities(filter: Callable) -> Array[int]:
	if filter == null:
		return components_by_entity.keys().duplicate()

	var res: Array[int] = []
	for id in components_by_entity:
		if filter.call(id, components_by_entity[id]):
			res.append(id)
	
	return res


## Returns the first component of the given script type attached to the entity, or null.
##
## If multiple components are found, only the first is returned.
func get_component(component_type: Script, entity_id: int) -> RpgComponent:
	if entity_id not in components_by_entity:
		return null
	
	for component in components_by_entity[entity_id]:
		if component and _is_matching_type(component.get_script(), component_type):
			return component
	
	return null


## Returns all component of the given script type attached to the entity, or an empty list.
func get_components(component_type: Script, entity_id: int) -> Array[RpgComponent]:
	if entity_id not in components_by_entity:
		return []
	
	var res: Array[RpgComponent] = []
	for component in components_by_entity[entity_id]:
		if component and _is_matching_type(component.get_script(), component_type):
			res.append(component)
	
	return res


## Returns a duplicate list of the components attached to an entity.
func get_entity(entity_id: int) -> Array[RpgComponent]:
	if entity_id not in components_by_entity:
		return []
	
	# Ugly trick to provide the correct type
	var res: Array[RpgComponent] = []
	for c in components_by_entity[entity_id]:
		res.append(c as RpgComponent)
	return res


## Removes an entire entity and emits [signal component_removed] for each component, then [signal entity_removed].
func remove_entity(entity_id: int) -> void:
	if entity_id not in components_by_entity:
		return
	
	for comp in components_by_entity[entity_id]:
		component_removed.emit(comp)

	components_by_entity.erase(entity_id)
	entity_removed.emit(entity_id)


## Removes the first specific component from an entity and emits [signal component_removed].
func remove_component(component: RpgComponent) -> void:
	var entity_id = component.entity_id

	var tmp := components_by_entity.get(entity_id, [])
	if component in tmp:
		tmp.erase(component)
		component_removed.emit(component)
	
	if tmp.size() == 0:
		components_by_entity.erase(entity_id)
		entity_removed.emit(entity_id)


# Helper to check exact script matches, script inheritance, or resource_path fallbacks.
func _is_matching_type(component_type: Script, ref_type: Script) -> bool:
	if component_type == ref_type:
		return true

	# Resource path fallback (for re-loaded file-based scripts in tool/editor modes)
	if not component_type.resource_path.is_empty() and component_type.resource_path == ref_type.resource_path:
		return true

	# Walk up the script inheritance chain (handles inner classes & derived subclasses)
	var current: Script = component_type.get_base_script()
	while current != null:
		if current == ref_type:
			return true
		if not current.resource_path.is_empty() and current.resource_path == ref_type.resource_path:
			return true
		current = current.get_base_script()

	return false


# Returns the next available entity id (increments internal counter).
func _next_id() -> int:
	last_id += 1
	return last_id
