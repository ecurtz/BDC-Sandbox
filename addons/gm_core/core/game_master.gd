@icon("res://addons/gm_core/icon_gm_small.svg")
class_name GameMaster
extends Node
## The Game Master orchestrates the game world, entity management, and action resolution.
## It manages an [EntityContainer], forwards its signals, and executes [RpgAction] commands.


## Emitted before an action is attempted, allowing systems to intercept and modify it.
signal action_preview(source: RpgAction)

## Emitted after an action is resolved with its outcome.
signal action_resolved(outcome: Outcome)

## Emitted when a component is added to an entity, forwarded from [EntityContainer].
signal component_added(component: RpgComponent)

## Emitted when a component is removed from an entity, forwarded from [EntityContainer].
signal component_removed(component: RpgComponent)

## Emitted when an entity is added, forwarded from [EntityContainer].
signal entity_added(entity_id: int)

## Emitted when an entity is removed, forwarded from [EntityContainer].
signal entity_removed(entity_id: int)


## The container managing all entities and their components.
## If not provided, a default one will be created when ready.
@export var entities: EntityContainer:
	set(value):
		if value == null or entities == value:
			return
		
		if entities:
			entities.component_added.disconnect(_on_container_component_added)
			entities.component_removed.disconnect(_on_container_component_removed)
			entities.entity_added.disconnect(_on_container_entity_added)
			entities.entity_removed.disconnect(_on_container_entity_removed)
		
		entities = value
		entities.component_added.connect(_on_container_component_added)
		entities.component_removed.connect(_on_container_component_removed)
		entities.entity_added.connect(_on_container_entity_added)
		entities.entity_removed.connect(_on_container_entity_removed)

## Optional Game World for spatial or environment logic.
@export var world: GameWorld:
	set(value):
		if value == null or world == value:
			return

		if world:
			component_added.disconnect(world.add_component)
			component_removed.disconnect(world.remove_component)
		
		world = value
		component_added.connect(value.add_component)
		component_removed.connect(value.remove_component)


var _systems: Dictionary[Script, RpgSystem] = {}


## Called on scene tree ready.
## Forwards entities container signals to [GameMaster]'s own signals.
##
## If there are [RpgSystem] children they are registered automatically.
func _ready() -> void:
	if entities == null:
		entities = EntityContainer.new()


## Attempts to execute an [RpgAction] by following these steps:[br][br]
##
## 1. Checks if [method RpgAction.is_allowed],[br]
## 2. Emits [signal action_preview],[br]
## 3. Calls [method RpgAction.attempt],[br]
## 4. Routes results to [signal action_resolved].[br][br]
##
## Returns true if the action was allowed and attempted, false otherwise.[br][br]
##
## Some Notes on execution:[br][br]
##
## - [signal action_resolved] may be emitted after this method returns.[br]
## - if the attempt fails (i.e. return false),[signal action_resolved]
## is not emitted if not specifically foreseen by the [RpgAction] implementation.[br]
## - [method RpgAction.is_allowed] is checked only once at the start, if the conditions
## are changed by an observer of [signal action_preview] they should be explicitly
## considered inside [method RpgAction.attempt].
func attempt(action: RpgAction) -> bool:
	if not action.is_allowed(self):
		return false
	
	action_preview.emit(action)
	action.resolved.connect(func(o: Outcome): action_resolved.emit(o), CONNECT_ONE_SHOT)
	return action.attempt(self)


## Returns a system that was previously registered via [method register_system],
## or null if no such system exists.
##
## Having multiple Systems of the same type, will cause undefined behavior.
func get_system(system_type: Script) -> RpgSystem:
	return _systems.get(system_type)


## Registers a [RpgSystem], automatically setting up its callbacks
## and providing it with a link to this [GameMaster] instance.
##
## Registered systems can be retrieved via [method get_system], but note
## that multiple Systems of the same type, will cause undefined behavior.
##
## Note that it is not necessary to register a custom System in this way,
## it may just be more convenient.
func register_system(system: RpgSystem) -> void:
	if system in _systems.values():
		return
	
	system.gm = self
	component_added.connect(system.on_component_added)
	component_removed.connect(system.on_component_removed)
	entity_added.connect(system.on_entity_added)
	entity_removed.connect(system.on_entity_removed)
	
	if system.connect_to_action_preview:
		action_preview.connect(system.on_action_preview)
	
	if system.connect_to_action_resolved:
		action_resolved.connect(system.on_action_resolved)
	
	_systems[system.get_script()] = system

# Private explicit forwarders, these are used as workaround for disconnecting
# the signals of `entities` when updating it, I don't know about a smarte way.
func _on_container_component_added(c: RpgComponent) -> void: component_added.emit(c)
func _on_container_component_removed(c: RpgComponent) -> void: component_removed.emit(c)
func _on_container_entity_added(eid: int) -> void: entity_added.emit(eid)
func _on_container_entity_removed(eid: int) -> void: entity_removed.emit(eid)
