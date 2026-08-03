extends AnimatableBody2D

@export var tile_size := 32
@export var push_delay := 0.1
@export var move_time := 0.15

var moving := false


func _to_cardinal_direction(vec: Vector2) -> Vector2:
	if abs(vec.x) > abs(vec.y):
		return Vector2(sign(vec.x), 0)

	return Vector2(0, sign(vec.y))


func _move(vec: Vector2):
	if moving:
		return false

	moving = true

	position += tile_size * _to_cardinal_direction(vec)
	moving = false

# func _ready():
# 	var player = get_node("Player")


func handle_player_collision(direction: Vector2):
	_move(direction)

	return true
