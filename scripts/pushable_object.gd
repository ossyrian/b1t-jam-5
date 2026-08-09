class_name PushableObject

extends StaticBody2D

@onready var grid_movement := $GridMovement
@onready var grid_detection := $GridDetection

@export var move_time := 0.15

func _ready():
	global_position = global_position.snapped(Vector2(32,32))

func handle_player_collision(direction: Vector2):
	grid_detection.point_at(direction)

	if grid_detection.is_colliding():
		var obj = grid_detection.get_collider()
		if obj is PushableObject:
			return

	if grid_movement.try_move():
		$PushSound.pitch_scale = randf_range(0.3, 0.4)
		$PushSound.play()
