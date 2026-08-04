class_name Box
extends AnimatableBody2D

@export var tile_size := 32
@export var push_delay := 0.1
@export var collision_detection_radius = 32
@export var move_time := 0.15
@onready var ray2d = $RayCast2D

var moving := false


func _to_cardinal_direction(vec: Vector2) -> Vector2:
	if abs(vec.x) > abs(vec.y):
		return Vector2(sign(vec.x), 0)

	return Vector2(0, sign(vec.y))


func _update_collision_ray(vec: Vector2):
	var ray_orientation = _to_cardinal_direction(vec)
	var ray_vec = collision_detection_radius * ray_orientation

	ray2d.target_position = ray_vec
	ray2d.force_raycast_update()


func _can_move() -> bool:
	return not ray2d.is_colliding()
	# var collider = ray2d.get_collider()
	# if not collider:
	# 	return true
	# print("collision: ", collider)

	# return collider is not Box


func _move(vec: Vector2):
	if moving:
		return false

	moving = true

	position += tile_size * _to_cardinal_direction(vec)
	moving = false


func handle_player_collision(direction: Vector2):
	_update_collision_ray(direction)
	if not _can_move():
		return

	_move(direction)


func handle_collision():
	return true
