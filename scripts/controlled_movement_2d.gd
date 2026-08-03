extends CharacterBody2D

@export var speed = 400
@export var push_collision_radius = 16
@onready var ray2d = $RayCast2D

signal player_collided(collider_id: int, collision_direction: Vector2)


func _to_cardinal_direction(vec: Vector2) -> Vector2:
	if abs(vec.x) > abs(vec.y):
		return Vector2(sign(vec.x), 0)

	return Vector2(0, sign(vec.y))


func _set_collision_direction(vec: Vector2) -> Vector2:
	var ray_orientation = _to_cardinal_direction(vec)
	var ray_vec = push_collision_radius * ray_orientation
	ray2d.target_position = ray_vec
	ray2d.force_raycast_update()

	return ray_orientation


func _handle_collision(collision: KinematicCollision2D, collision_direction: Vector2):
	if not collision:
		return

	player_collided.emit(collision.get_collider_id(), collision_direction)


func _move():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

	var collision_direction = _set_collision_direction(velocity)
	var collision = move_and_collide(velocity)
	_handle_collision(collision, collision_direction)


func _physics_process(_delta):
	_move()
