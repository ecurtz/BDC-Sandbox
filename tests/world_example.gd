extends Node


@onready var gm: GameMaster = $GameMaster


func _ready() -> void:
	# Init the world
	gm.world = ChessBoard.new()
	
	# Add a piece
	var piece_id = gm.entities.add_entity([ChessPiece.new()])
	
	# The piece was placed correctly by the game world
	var piece = gm.entities.get_component(ChessPiece, piece_id)
	print_debug(piece.coords)
	assert(piece.coords != -Vector2i.ONE)


## Component example
class ChessPiece extends RpgComponent:
	const CELL_SIZE := Vector2i(16, 16)
	const STEP_DURATION := 0.5
	
	@export var coords := -Vector2i.ONE # negative means not initialized
	var view: Node2D # reference to the "presentation" node
	
	func move(delta: Vector2i) -> void:
		coords += delta
		var duration := STEP_DURATION * delta.length()
		view.create_tween().tween_property(view, "position", coords * CELL_SIZE, duration)


## Custom GameWorld example
class ChessBoard extends GameWorld:
	var pieces: Dictionary[Vector2i, ChessPiece] = {}
	var size := Vector2i(8, 8)
	
	func add_component(component: RpgComponent) -> void:
		# skip invalid components or exisitng ones
		if component is not ChessPiece or component in pieces.values():
			return
		
		# set a random spawn point, should check if empty...
		var spawn_point := Vector2i(randi() % size.x, randi() % size.y)
		component.coords = spawn_point
		pieces[spawn_point] = component
