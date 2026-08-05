extends StaticBody2D

@onready var grid_movement := $GridMovement
@onready var grid_detection := $GridDetection

@export var move_time := 0.15


func handle_player_collision(direction: Vector2):
	grid_detection.point_at(direction)

	if grid_detection.is_colliding():
		return

	grid_movement.try_move()
