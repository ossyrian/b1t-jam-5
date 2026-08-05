extends Node2D

@export var body: Node2D
@export var current_direction: RayCast2D

var moving := false


func _to_cardinal_direction(vec: Vector2) -> Vector2:
	if abs(vec.x) > abs(vec.y):
		return Vector2(sign(vec.x), 0)

	return Vector2(0, sign(vec.y))


func _move():
	if moving:
		return false

	moving = true

	var tween = create_tween()
	tween.tween_property(body, "position", body.position + current_direction.target_position, 0.15)

	moving = false
	return true


func try_move():
	if current_direction.is_colliding():
		return

	return _move()
