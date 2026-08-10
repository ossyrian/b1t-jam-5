class_name Target

extends Area2D

signal covered(target: Target)
signal uncovered(target: Target)

@onready 

var occupant: PushableObject = null
var stage := 0


func _ready():
	global_position = global_position.snapped(Vector2(32,32))
	add_to_group("targets")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func is_covered() -> bool:
	return occupant != null


func _on_body_entered(body: Node2D):
	if occupant == null and body is PushableObject:
		# $SwitchSound.pitch_scale = randf_range(0.3, 0.4)
		$SwitchSound.play()
		occupant = body
		stage = 0
		covered.emit(self)


func _on_body_exited(body: Node2D):
	if body == occupant:
		# $SwitchSound.pitch_scale = randf_range(0.3, 0.4)
		$SwitchSound.play()
		occupant = null
		stage = 0
		uncovered.emit(self)
