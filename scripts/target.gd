class_name Target

extends Area2D

signal covered(target: Target)
signal uncovered(target: Target)

var occupant: PushableObject = null


func _ready():
	global_position = global_position.snapped(Vector2(32,32))
	add_to_group("targets")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func is_covered() -> bool:
	return occupant != null


func _on_body_entered(body: Node2D):
	if occupant == null and body is PushableObject:
		occupant = body
		covered.emit(self)


func _on_body_exited(body: Node2D):
	if body == occupant:
		occupant = null
		uncovered.emit(self)
