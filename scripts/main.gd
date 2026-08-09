extends Node

@export var levels: Array[PackedScene] = []
# @export var fade_time := 0.4 # replaced with bloom effect in level
@export var card_time := 1.2

@onready var holder: Node2D = $LevelHolder
@onready var card: Label = $Transition/Card
@onready var opening_card: Label = $Opening/Card

var _index := 0
var _level: Node = null
var _busy := false


func _ready():
	_load_level(0)
	opening_card.text = "Turn on the dark and get thee to bed for a goodnight's rest. ([WASD,R])\n\nNight 1"
	opening_card.show()
	await get_tree().create_timer(card_time).timeout
	opening_card.hide()

func _unhandled_input(event):
	if event.is_action_pressed("restart"):
		_change_level(_index, "", true)


func _load_level(index: int):
	_index = index
	if _level:
		holder.remove_child(_level)
		_level.queue_free()
	_level = levels[index].instantiate()
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
	_change_level(_index + 1, "Night %d" % (_index + 2))


func _on_failed():
	_change_level(_index, "You shall not sleep well tonight.")
