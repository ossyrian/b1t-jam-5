class_name Player

extends CharacterBody2D

@export var speed = 400
@export var push_collision_radius = 16
@export var is_frozen = false
@export var push_delay = 0.2

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var grid_movement := $GridMovement
@onready var grid_detection := $GridDetection

var collision_direction = Vector2.ZERO
var is_resting := false
var is_caught := false # play caught animation

func _ready():
	global_position = global_position.snapped(Vector2(32,32))

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
	if is_frozen or is_caught or grid_movement.moving:
		# if is_caught:
		# 	play caught animation
		return

	var input_direction = Input.get_vector("left", "right", "up", "down")

	if is_resting:
		sprite.play("rest")
		sprite.rotation_degrees = 90.0
		if input_direction == Vector2.ZERO:
			return
		is_resting = false
		sprite.rotation_degrees = 0.0
		
	if input_direction == Vector2.ZERO:
		sprite.play("idle")
	else:
		sprite.play("walk")
	if input_direction.x != 0:
		sprite.flip_h = input_direction.x < 0

	_try_step(input_direction)

	# velocity = input_direction * speed

	# grid_detection.point_at(velocity)

	# var collision = move_and_collide(velocity)
	# _handle_collision(collision)


func _try_step(direction: Vector2) -> void:
	grid_detection.point_at(direction)

	if grid_detection.is_colliding():
		var collider = grid_detection.get_collider()
		if not collider.has_method("handle_player_collision"): # not a pushable object
			return
		is_frozen = true
		collider.handle_player_collision(grid_detection.target_position)
		await get_tree().create_timer(push_delay).timeout
		is_frozen = false
		grid_detection.force_raycast_update()
		if grid_detection.is_colliding():
			return

	grid_movement.try_move()

func _physics_process(_delta):
	if not is_caught:
		_move()
