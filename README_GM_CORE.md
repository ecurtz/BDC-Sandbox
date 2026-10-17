# Game Master Core

**GMCore** is an RPG framework for Godot 4 built on traditional tabletop-RPG principles.

It attempts to merge modern software design patterns with classic pen-and-paper concepts, such as the role of the *Game Master* and the *action adjudication loop*, to provide an extensible base for building RPGs and roguelikes.

## Features

- **Tabletop Metaphor:** Rules and action resolution are handled by a central `GameMaster` router.
- **Action Handling:** Each `RpgAction` is a self-contained rule that can be executed by the `GameMaster`. Intercept and modify `RpgAction` data synchronously via signals before execution.
- **Systems Oriented:** `signal`s are used extensively to provide hooks for your own custom systems and managers. You can extend the optional `RpgSystem` nodes to skip basic signal boilerplate too.
- **Data-Driven:** Entities, worlds, and stats are represented with extensible and composable  `RpgComponent` resources.

> Note that GMCore *does not* provide a ready to use game template.
> It focuses instead on eliminating boilerplate and offering an opinionated architectural structure for RPG and roguelike games.

## Quick Start

1. Download or clone this repository and copy the `addons/gm_core` folder into your Godot 4 project's `addons/` directory.
2. Go to **Project -> Project Settings -> Plugins** and enable **GMCore**.
3. Add a `GameMaster` node to your main scene tree or configure it as an Autoload.

## Usage

Building a game with GMCore tries to mirror running a tabletop session, from rules setup to action adjudication:

1. **The Core Rules:** Add the `GameMaster` node to your main scene. It manages your world state, entity lists, and game mechanics.
2. **Define the Mechanics:** Extend `RpgComponent` to store data (like a section in a character sheet) and `RpgAction` to handle specific rule logic (like casting a spell or attacking).
3. **Populate the Adventure:** Use `GameMaster.entities` to register game objects and attach their initial components. If your game tracks layout or positioning, you can implement a custom `GameWorld` resource and add it to the GM here.
4. **Setup the Game Systems:** Build your observers (like turn managers or combat controllers) to listen to the session's events. You can connect directly to `GameMaster` signals or extend the `RpgSystem` node class to handle hooks automatically.
5. **Run the Game:** Pass player choices or AI behaviors into `GameMaster.attempt(action)`. The GM checks requirements, runs your preview interceptors, executes the action, and broadcasts the final outcome.

For a deeper dive, check out the [design documentation](docs/design.md#Using-the-Framework).

### Examples

Self-contained examples can be found in the `tests` folder:

- [Basic implementation](tests/basic_example.gd).
- [Custom World and Wrappers](tests/basic_example.gd).

You can also check the [design documentation](docs/design.md#Using-the-Framework) for more extensive details.

#### Basic Implementation

Define your character data component(s):

```gdscript
class_name CharacterSheet
extends RpgComponent

@export var attack := RpgStat.new(4, 10)
@export var defense := RpgStat.new(0, 10)
@export var health := RpgStat.new(10)
```

Define a context-driven Action:

```gdscript
class_name AttackAction
extends RpgAction

var attacker_id: int
var target_id: int
var damage_mod := 0

func _init(my_attacker_id: int, my_target_id: int) -> void:
    attacker_id = my_attacker_id
    target_id = my_target_id

func attempt(gm: GameMaster) -> bool:
    var attacker_stats = gm.entities.get_component(CharacterSheet, attacker_id)
    var target_stats = gm.entities.get_component(CharacterSheet, target_id)

    var roll := DicePool.roll(1, attacker_stats.attack.value, damage_mod)
    var damage := maxi(roll - target_stats.defense.value, 0)
    target_stats.health.value -= damage

    resolved.emit(Outcome.new(self, damage))
    return true
```

> Note that `RpgStat` and `DicePool` are two utilities provided by GMCore.

Then initialize your main loop and connect any optional logic:

```gdscript
extends Node

@onready var gm: GameMaster = $GameMaster

func _ready() -> void:
    # Connect a preview interceptor and an outcome listener
    gm.action_preview.connect(_on_action_preview)
    gm.action_resolved.connect(_on_action_resolved)
    
    # Spawn a couple of entities
    var hero_id = gm.entities.add_entity([CharacterSheet.new()])
    var enemy_id = gm.entities.add_entity([CharacterSheet.new()])
    
    # Run the action through the GM
    gm.attempt(AttackAction.new(hero_id, enemy_id))

func _on_action_preview(action: RpgAction) -> void:
    if action is AttackAction:
        # Tweak the action data before execution
        # This can be handled by the action itself or an external system
        action.damage_mod = -1

func _on_action_resolved(outcome: Outcome) -> void:
    print_debug(outcome.get_message())
```

If you prefer automated callbacks, you can create a node that extends `RpgSystem` and either add it as a child of the `GameMaster` or register it programmatically via `GameMaster.register_system(my_system)`.

#### Custom World and Wrappers

The `GameMaster` can manage a `GameWorld` resource, like:

```gdscript
class_name ChessBoard
extends GameWorld

@export var pieces: Dictionary[Vector2i, ChessPiece] = {}
@export var size := Vector2i(8, 8)
    
func add_component(component: RpgComponent) -> void:
    # skip invalid components or existing ones
    if component is not ChessPiece or component in pieces.values():
        return
        
    # random spawn point example, should check if empty...
    var spawn_point := Vector2i(randi() % size.x, randi() % size.y)
    component.coords = spawn_point
    pieces[spawn_point] = component
```

If necessary, Godot resources and Nodes can be wrapped as `RpgComponent` objects:

```gdscript
class_name ChessPiece
extends RpgComponent

const CELL_SIZE := Vector2i(16, 16)
const STEP_DURATION := 0.5
    
@export var coords := -Vector2i.ONE # negative means not initialized
var view: Node2D # reference to the "presentation" node
    
func move(delta: Vector2i) -> void:
    coords += delta
    var duration := STEP_DURATION * delta.length()
    view.create_tween().tween_property(view, "position", coords * CELL_SIZE, duration)
```

Then they can be used in your own code:

```gdscript
extends Node

@onready var gm: GameMaster = $GameMaster

func _ready() -> void:
    # Init the world
    gm.world = ChessBoard.new()
    
    # Add a piece
    var piece_id = gm.entities.add_entity([ChessPiece.new()])
    
    # The piece was placed correctly on the board
    var piece = gm.entities.get_component(ChessPiece, piece_id)
    print_debug(piece.coords)
    assert(piece.coords != -Vector2i.ONE)
```

## Documentation

For class diagrams and architectural details, check the local files:

- Architecture & Primitives: See [docs/design.md](docs/design.md).
- Release History: See [CHANGELOG.md](CHANGELOG.md).

## Contributing & Support

GMCore is primarily a personal framework built for game jams and rapid prototyping.
It is shared openly with the Godot community as a free utility gift.

Pull requests and issue tracking are disabled to keep maintenance simple and low-overhead.
If you find it helpful, feel free to fork, adapt, or build your own extensions on top of it!

## License

This project is licensed under the [MIT LICENSE](LICENSE.md).
