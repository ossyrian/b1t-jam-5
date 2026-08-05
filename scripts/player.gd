extends CharacterBody2D

@export var speed = 400
@export var push_collision_radius = 16
@export var is_frozen = false
@export var push_delay = 0.2

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var collision_direction = Vector2.ZERO


func _handle_collision(collision: KinematicCollision2D):
	if not collision:
		return

	var collider = collision.get_collider()
	if collider.has_method("handle_player_collision"):
		is_frozen = true
		collider.handle_player_collision($GridDetection.target_position)
		await get_tree().create_timer(push_delay).timeout
		is_frozen = false


func _move():
	if is_frozen:
		return

	var input_direction = Input.get_vector("left", "right", "up", "down")

	if input_direction == Vector2.ZERO:
		sprite.play("idle")
	else:
		sprite.play("walk")
	if input_direction.x != 0:
		sprite.flip_h = input_direction.x < 0

	velocity = input_direction * speed

	$GridDetection.point_at(velocity)

	var collision = move_and_collide(velocity)
	_handle_collision(collision)


func _physics_process(_delta):
	_move()
