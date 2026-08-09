extends Node

@export var levels: Array[PackedScene] = []
@export var card_time := 3.0

@export var darken_patterns: Array[int] = [0, 1, 2, 3, 4, 5, 6]
@export var darken_step_time := 0.5
@export var level_transition_bloom_step := 0.1
@export var level_transition_zoom_time := 1.0

@onready var holder: Node2D = $LevelHolder
@onready var card: Label = $Transition/Card
@onready var opening_card: Label = $Opening/Card

var _index := 0
var _level: Node = null
var _busy := false


func _ready():
	_load_level(0)
	opening_card.text = "Turn on the dark and get to bed for a goodnight's rest. ([WASD,R])\n\nNight 1"
	opening_card.show()
	await get_tree().create_timer(card_time).timeout
	opening_card.hide()

func _unhandled_input(event):
	if event.is_action_pressed("restart"):
		_change_level(_index, "", true)

func _set_level_parameters(level):
	level.darken_patterns = darken_patterns
	level.step_time = darken_step_time
	level.bloom_step = level_transition_bloom_step
	level.zoom_time = level_transition_zoom_time

func _load_level(index: int):
	_index = index
	if _level:
		holder.remove_child(_level)
		_level.queue_free()
	_level = levels[index].instantiate()
	_set_level_parameters(_level)
	_level.failed.connect(_on_failed, CONNECT_ONE_SHOT)
	_level.completed.connect(_on_completed, CONNECT_ONE_SHOT)
	holder.add_child(_level)


func _change_level(index: int, text: String, restarting := false):
	if _busy:
		return
	_busy = true
	if text:
		card.text = text
		card.show()
	if _level and _level.has_method("play_exit_bloom"):
		_level.play_exit_bloom(restarting)
	await get_tree().create_timer(0.3).timeout
	if text:
		await get_tree().create_timer(card_time).timeout
	card.hide()
	_load_level(index)
	_busy = false


func _on_completed():
	if _index + 1 >= levels.size():
		card.text = "A good night's rest at last."
		card.show()
		return
	_change_level(_index + 1, "A good night's rest at last.\nNight %d" % (_index + 2))


func _on_failed():
	_change_level(_index, "You shall not sleep well tonight.")
