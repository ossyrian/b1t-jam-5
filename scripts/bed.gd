class_name Bed
extends Area2D

signal rested(bed: Bed)
signal woke(bed: Bed)

@export var rest_time := 1.0

var sleeper: Player = null

var _candidate: Player = null
var _progress := 0.0


func _ready():
	global_position = global_position.snapped(Vector2(32,32))
	add_to_group("beds")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(delta: float):
	if sleeper and not sleeper.is_resting:
		sleeper = null
		_progress = 0.0
		woke.emit(self)
		return

	if _candidate == null or sleeper:
		return

	_progress += delta
	if _progress >= rest_time:
		sleeper = _candidate
		sleeper.is_resting = true
		rested.emit(self)


func is_occupied() -> bool:
	return sleeper != null


func _on_body_entered(body: Node2D):
	if body is Player:
		_candidate = body
		_progress = 0.0


func _on_body_exited(body: Node2D):
	if body == _candidate:
		_candidate = null
		_progress = 0.0
	if body == sleeper:
		sleeper.is_resting = false
		sleeper = null
		woke.emit(self)

func remaining_rest_time(p: Player) -> float:
	if sleeper == p:
		return 0.0
	if _candidate == p:
		return maxf(rest_time - _progress, 0.0)
	return -1
	
