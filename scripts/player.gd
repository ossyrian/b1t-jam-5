extends CharacterBody2D

@export var speed = 400
@export var push_collision_radius = 16

var collision_direction = Vector2.ZERO


func _to_cardinal_direction(vec: Vector2) -> Vector2:
	if abs(vec.x) > abs(vec.y):
		return Vector2(sign(vec.x), 0)

	return Vector2(0, sign(vec.y))


func _handle_collision(collision: KinematicCollision2D):
	if not collision:
		return

	var collider = collision.get_collider()
	if collider.has_method("handle_player_collision"):
		collider.handle_player_collision(collision_direction)


func _move():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

	collision_direction = _to_cardinal_direction(velocity)
	var collision = move_and_collide(velocity)
	_handle_collision(collision)


func _physics_process(_delta):
	_move()
