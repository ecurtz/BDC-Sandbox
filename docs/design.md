# Game Master Core - Design Document

A framework for developing RPGs, mainly geared towards the Godot 4 engine.

Godot specific terminology:

- `autoload`: merges the singleton and locator patterns.
- `Node`: base class for functional game engine objects.
- `RefCounted`: lightest objects with garbage collection.
- `Resource`: base class for lightweight serializable objects.
- `signal`: a message "emitted" asynchronously by an object, listeners can "connect" to them.

Note that Godot has no concept of `interface` classes, therefore `abstract` is used in places where an `interface` would be a better fit.

## Core Principles

The framework attempts to merge modern programming patters with traditional RPG design concepts.

This is achieved by starting with core RPG mechanics:

- The **Game Master** (GM): a player that controls the game world, adjudicates actions and directs the game's narrative.
- The **Characters**: players or NPCs that take part in the game. They have their own goals, motivations, and behaviors.
- The **World**: an environment where characters interact with.
- The **Mechanics**: a set of rules that govern what happens when characters act.
- The **Character Sheets**: a way to represent character data and the interface between characters and the world.

The key programming patterns used to representing these concepts are:

- **Data-Driven Design** (DDD): using data classes to represent game entities, such as characters, items, and locations.
  `Resource` objects in Godot.
- **Entity-Component-System** (ECS): a pattern for organizing code that represents the behavior of individual components.
- **Command Pattern**: a design pattern for encapsulating actions and logic into commands.

Other programming patterns used based on SOLID principles are:

- **Observer Pattern**: a design pattern that defines a one-to-many dependency between objects so that when one object changes state, all its dependents are notified and updated automatically. `signal` methods in Godot.
- **Strategy Pattern**: a design pattern that enables multiple algorithms, or mechanics, to be chosen at runtime.
- **Dependency Injection** (DI): a technique for providing dependencies to objects without hard coding them into the object's class definition.
- **Builders** and **Factories**: patterns for creating complex objects from simpler ones.

## Architecture

### Core Classes

```mermaid
classDiagram
    GameMaster --> RpgAction: executes
    RpgAction --> Outcome: generates
    GameMaster "1"o--"1" GameWorld
    GameMaster "1"o--"*" RpgComponent

    Outcome --|> RefCounted
    RpgAction --|> RefCounted
    GameWorld --|> Resource
    RpgComponent --|> Resource
    Node <|-- GameMaster
    Node <|-- RpgSystem
    Resource <|-- EntityContainer
    GameMaster "1"o--"1" EntityContainer

    class RpgAction {
        <<Abstract>>
        +resolved(Outcome outcome) signal
        +attempt(GameMaster gm) bool
        +is_allowed(GameMaster gm) bool
    }

    class EntityContainer {
        +component_added(RpgComponent component) signal
        +component_removed(RpgComponent component) signal
        +entity_added(int entity_id) signal
        +entity_removed(int entity_id) signal
        +add_component(RpgComponent component, int entity_id) void
        +add_entity(Array~RpgComponent~ components) int
        +get_entities(Callable filter) Array~int~
        +get_component(Script component_type, int entity_id) RpgComponent
        +get_components(Script component_type, int entity_id) Array~RpgComponent~
        +get_entity(int entity_id) Array~RpgComponent~
        -next_id() int
        +remove_component(RpgComponent component, int entity_id) void
        +remove_entity(int entity_id) void
    }

    class GameMaster {
        +EntityContainer entities
        +GameWorld world
        +action_preview(RpgAction source) signal
        +action_resolved(Outcome outcome) signal
        +component_added(RpgComponent component) signal
        +component_removed(RpgComponent component) signal
        +entity_added(int entity_id) signal
        +entity_removed(int entity_id) signal
        +attempt(RpgAction action) bool
    }

    class GameWorld {
        <<Abstract>>
        +add_component(RpgComponent component) void
        +remove_component(RpgComponent component) void
    }

    class Outcome {
        +RpgAction source
        +int result
        +get_message() String
        +is_failure() bool
        +is_success() bool
    }
    note for Outcome "result is just a number
    for example expressing
    a measure of success
    subclass as desired"

    class RpgComponent {
        <<Abstract>>
        +int entity_id
        +is_assigned() bool
    }
    
    class RpgSystem {
        <<Abstract>>
        +GameMaster gm
        +bool connect_to_action_preview
        +bool connect_to_action_resolved
        +on_action_preview(action: RpgAction) void
        +on_action_resolved(outcome: Outcome) void
        +on_component_added(RpgComponent component) void
        +on_component_removed(RpgComponent component) void
        +on_entity_added(int entity_id) void
        +on_entity_removed(int entity_id) void
    }
```

### Utilities

```mermaid
classDiagram
    RefCounted <|-- DicePool
    Resource <|-- RpgStat
    RpgStat <|-- ModifiableStat
    RpgStat <|-- ProgressStat

    class DicePool {
        +add(int how_many, int sides, int mod) DicePool
        +clear() DicePool
        +keep_highest(int how_many) DicePool
        +keep_lowest(int how_many) DicePool
        +roll_each() Array~int~
        +roll_sum() int
        +$roll(int how_many, int sides, int mod) Array~int~
    }

    class RpgStat {
        +String name
        +int maximum
        +int minimum
        +int value
        +value_changed(Stat updated, int delta)
        +depleted(Stat source) signal
        +maxed(Stat source) signal
    }

    class ModifiableStat {
        +Dictionary~String, int~ modifiers
        +mod_changed(Stat source, String name, int value) signal
        +clear_mods() void
        +get_modified_value() int
        +get_mod(String name, int default_value) int
        +get_mod_total() int
        +set_mod(String name, int value) void
    }

    class ProgressStat {
        +Dictionary~String, int~ threshold
        +threshold_crossed(Stat source, String threshold)
        +get_threshold(String name) int
        +is_at_threshold(String name) bool
        +remove_threshold(String name) void
        +set_threshold(String name, int value) void
    }
```

## Using the Framework

New Systems can be added by connecting to the `GameMaster` signals.

### New Systems and Components

Systems are standalone classes that can manage specific aspects of the game, usually bringing with them new `RpgComponent` objects to implement the desired behavior.

Any object can be a System, and they can connect to the `GameMaster` signals for their specific needs.
Systems can also be based on the `RpgSystem` core base class that provides standard hooks and registration to the `GameMaster`, avoiding boilerplate.

For example, a turn-based RPG may require a `TurnManager` to manage the turn order. This would be a new System that may require a `Initiative` component to track the initiative order.

At initialization, the `TurnManager` would connect to `component_added` and `entity_removed` signals. When a new `Initiative` component is added, the `TurnManager` would add it to the list of managed entities and sort them.

The `TurnManager` would also provide a `turn()` method that would retrieve the next entity in the initiative order and allow it to perform its turn (maybe by retrieving its `Controller` component from the `GameMaster`).

After a turn is over the `TurnManager` could move to the next entity and so on.

```mermaid
sequenceDiagram
    participant Root as RootScene
    participant GM as GameMaster
    participant TM as TurnManager

    TM ->> GM: component_added.connect
    TM ->> GM: entity_removed.connect
    
    opt
        Root ->> GM: add_entity
        GM ->> TM: component_added.emit
        TM ->> TM: update initiative
    end

    loop every turn
        Root ->> TM: turn()
        loop next entity is idle
            TM ->> TM: find next entity by intiative
            TM ->> TM: call entity controller logic
            note over TM, GM: entities may be added or removed here
            TM ->> TM: update initiative
        end
    end
```

### Wrapping existing Nodes

While technically `RpgComponent` could just be an `Object`, it has been preferred to favor wrapping existing nodes in `RpgComponent` objects.
This allows the framework to be more generic and reusable, adding explicit references to an `entity_id`.

For example a `GridEntity` component may wrap a `Node2D` representing a Character or object and include it's position in a grid-based `GameWorld`.

```mermaid
classDiagram
    RpgComponent <|-- GridEntity
    class GridEntity {
        +Node2D node_2d
        +Vector2i grid_position
        +moved(Vector2i new_position) signal
        +animate(String animation) void
        +is_idle() bool
        +move(Vector2i delta) void
    }
```

### New Game Worlds

`GameWorld` is just a generic data interface and different gameplay styles or genres may require specific specializations.

For example a grid-based game could use a `TiledWorld` which contains a list of tiles, each containing a list of `GridEntity` objects and dedicated methods for accessing them and calculate their relations.
An old school adventure game could use a `RoomWorld` which contains a list of `Room` of which only one is active at a certain time.

Note how `GameWorld` works, in fact, as a dedicated System, with the only difference that the `GameMaster` manages it "automatically" since an existing World is always necessary.

```mermaid
classDiagram
    GameWorld <|-- TiledWorld
    GameWorld <|-- RoomWorld

    class TiledWorld {
        -Array~Tile~ tiles
        +Vector2i size
        +tile_updated(Tile tile, Vector2i coords) signal
        +is_explored(Vector2i coords) bool
        +is_visible(Vector2i coords) bool
        +get_entities_at(Vector2i coords) Array~GridEntity~
        +get_tile_type(Vector2i coords) Tile.Type
        +in_line_of_sight(Vector2i coords, Vector2i from) bool
        +update_field_of_view(Vector2i from, int radius) void
    }

    class RoomWorld {
        -Dictionary~String, Room~ rooms
        +Room current_room
        +add_room(String name, Room room) void
        +get_entities_in_room() Array~int~
        +go_to(String room_name) void
    }
```

Continuing the example in the [previous section](#wrapping-existing-nodes), `TiledWorld` would subscribe to the `GridAvatar.moved()` signal to update its content, keeping coupling to a minimum.

### Specialized Entity Containers

The base implementation of `EntityContainer` provides flexibility but may become a bottleneck especially if Entities have many `RpgComponent` objects that are filtered all the time.

In such cases it is encouraged to create a class that inherits from `EntityContainer` that is passed to the `GameMaster`.
This dedicated class can provide caching and offer dedicated methods to access the cached data and lookup specific Components.

## Behavior

### Adding Entities

```mermaid
sequenceDiagram
    participant Src as Source
    participant GM as GameMaster
    participant Sys as RpgSystem
    participant GW as GameWorld

    Sys ->> GM: component_added.connect
    Sys ->> GM: entity_added.connect
    Src ->> GM: add_entity(components)
    GM ->> GM: next entity_id
    GM ->> GM: update entities
    GM ->> GW: add_component(component)
    opt valid component
        GW ->> GW: update entities
    end
    GM ->> Sys: entity_added.emit(entity_id)
    loop for each component
        GM ->> Sys: component_added.emit(component)
        opt valid component
            Sys ->> Sys: update entities
        end
    end
    GM ->> Src: entity_id
```

### Removing Entities

```mermaid
sequenceDiagram
    participant Src as Source
    participant GM as GameMaster
    participant Sys as RpgSystem
    participant GW as GameWorld

    Sys ->> GM: entity_removed.connect
    Src ->> GM: remove_entity(id)
    loop for each component
        GM ->> GW: remove_component
        GW ->> GW: update entities
        GM ->> Sys: component_removed.emit(component)
        opt valid component
            Sys ->> Sys: update entities
        end
    end
    GM ->> Sys: entity_removed.emit(id)
    opt valid entity
        Sys ->> Sys: update entities
    end
    GM ->> GM: update entities
```

### Perform Actions

```mermaid
sequenceDiagram
    participant Src as Source
    participant GM as GameMaster
    participant Sys as Listener

    Sys ->> GM: action_preview.connect
    Sys ->> GM: action_resolved.connect
    Src ->> GM: attempt(action)
    GM ->> GM: action.is_allowed(self)
    opt
        GM -->> Src: false
    end
    GM ->> Sys: action_preview(action)
    opt
        Sys ->> Sys: modify as needed
    end
    GM ->> GM: action.resolved.connect
    GM ->> GM: action.attempt(self)
    GM -->> Src: true/false
    opt action.resolved
        GM ->> Sys: action_resolved.emit(outcome)
    end
```

The `action_preview signal` can be used by dedicated Systems to modify an `RpgAction` before actual execution.
For example a `CombatSystem` may apply damage reduction based on its own logic, setting a specific value into an `AttackAction`.
It's also fine to implement this kind of logic within the `RpgAction` itself.

## Extensions Examples

### Trait System Example

Example of a full System, used to track status Effects, Skills and other qualities of an Entity.

```mermaid
classDiagram
    RpgSystem <|-- TraitSystem
    Resource <|-- RpgTrait
    Resource <|-- RpgComponent
    RpgComponent <|-- Traits

    TraitSystem *-- RpgTrait
    TraitSystem --> Traits

    class TraitSystem {
        -Dictionary~String, RpgTrait~ traits
        -GameMaster gm
        +_init(GameMaster gm)
        +add_trait(String trait_name, int entity_id) void
        +remove_trait(String trait_name, int entity_id) void
    }

    class RpgTrait {
        <<Abstract>>
        +String name
        +is_allowed(int entity_id, GameMaster gm) void
        +on_added(int entity_id, GameMaster gm) void
        +on_removed(int entity_id, GameMaster gm) void
    }

    class Traits {
        +added(String trait, Traits to) signal
        +removed(String trait, Traits from) signal
        +add(String trait_name, GameMaster gm) void
        +has(String trait_name) bool
        +remove(String trait_name, GameMaster gm) void
    }
```

## Porting to Python

As a personal note, since this framework's architecture is mostly standard OOP and observers, it translates cleanly to other languages, such as Python.
Followgin are a few notes on how to implement it using `dataclasses` and custom `callables`.

### Primitive Mapping

| Godot Primitive | Python Equivalent                   | Architectural Note                                                                  |
| :-------------- | :---------------------------------- | :---------------------------------------------------------------------------------- |
| `Resource`      | `@dataclass`                        | Use `dataclasses.field(default_factory=...)` to handle unique configurations.       |
| `RefCounted`    | Standard Class / `@dataclass`       | Python handles reference counting and garbage collection natively.                  |
| `Node`          | Standard Class                      | Manage structural hierarchies or execution trees manually via lists or composition. |
| `signal`        | Custom `Signal` or `blinker.Signal` | Implements the synchronous Observer pattern.                                        |

### Handling the Observer Pattern (Signals)

Godot's native signaling system can be replaced by an implementation using `Callable`:

```python
from typing import Callable, List, Any

class Signal:
    """A lightweight, synchronous implementation of Godot's signal engine primitive."""
    def __init__(self):
        self._listeners: List[Callable[..., None]] = []

    def connect(self, callback: Callable[..., None]) -> None:
        if callback not in self._listeners:
            self._listeners.append(callback)

    def disconnect(self, callback: Callable[..., None]) -> None:
        if callback in self._listeners:
            self._listeners.remove(callback)

    def emit(self, *args: Any, **kwargs: Any) -> None:
        # Executes synchronously, matching Godot's default signal dispatch behavior
        for callback in self._listeners:
            callback(*args, **kwargs)
```
