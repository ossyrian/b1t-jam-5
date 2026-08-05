extends Node2D

@export var body: Node2D
@export var current_direction: RayCast2D

var moving := false


func _move():
	moving = true

	var tween = create_tween()
	tween.tween_property(body, "position", body.position + current_direction.target_position, 0.15)
	await tween.finished
	moving = false


func try_move():
	if moving:
		return false
	if current_direction.is_colliding():
		return false

	_move()
	return true
