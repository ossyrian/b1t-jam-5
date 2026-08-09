class_name Player

extends CharacterBody2D

@export var speed = 400
@export var push_collision_radius = 16
@export var is_frozen = false
@export var push_delay = 0.2

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var collision_direction = Vector2.ZERO
var is_resting := false
var is_caught := false

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
	if is_frozen:
		return

	var input_direction = Input.get_vector("left", "right", "up", "down")

	if is_resting:
		# print("RESTING")
		if input_direction == Vector2.ZERO:
			return
		is_resting = false          # any movement gets you out of bed

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
	if not is_caught:
		_move()
	else:
		sprite.play("idle") # Replace with caught animation
