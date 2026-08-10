extends Node2D

signal completed
signal failed

@onready var tilemap: TileMapLayer = $TileMapLayer
@onready var targets := get_tree().get_nodes_in_group("targets")
@onready var player: Player = $Player
@onready var bed: Bed = $Bed

var dark_src := 2
var dark_atlas := Vector2i(2, 1)
var dark_alt := 0
var light_src := 2
var light_atlas := Vector2i(2, 0)
var light_alt := 0
var _saved_cells := { }
var _finished := false
var darken_patterns: Array[int]
var step_time: float
var bloom_step: float
var zoom_time: float
var dark_startup_time: float
var dark_escape_time : float
var _dark_time := 0.0


func _ready():
	for target in targets:
		target.covered.connect(_on_covered)
		target.uncovered.connect(_on_uncovered)


func _cell_under_player() -> Vector2i:
	return tilemap.local_to_map(tilemap.to_local(player.global_position + Vector2(16, 16)))


func _physics_process(delta):
	if _finished:
		return
	if is_dark(_cell_under_player()):
		_dark_time += delta
		if _dark_time >= dark_escape_time:
			_check_player()
	else:
		_dark_time = 0.0


func _on_covered(target: Target):
	if dark_startup_time > 0.0:
		await get_tree().create_timer(dark_startup_time).timeout
		if not is_inside_tree() or not target.is_covered():
			return
	while is_inside_tree() and target.is_covered():
		_redraw()
		if target.stage >= darken_patterns.size() - 1:
			break
		await get_tree().create_timer(step_time).timeout
		if target.is_covered():
			target.stage += 1

	if (targets.all(
				func(t):
					return t.is_covered(),
			)
			and player.is_resting):
		_on_level_complete()


func _on_uncovered(_target: Target):
	_redraw()


func _redraw():
	_restore()
	for t in targets:
		if t.is_covered():
			_darken(t, darken_patterns[t.stage])


func _darken(target: Target, pattern_index: int):
	var pattern := tilemap.tile_set.get_pattern(pattern_index)
	var origin := _cell_of(target) - pattern.get_size() / 2

	# Save originals before overwriting, so uncovering can put the floor back
	for cell in pattern.get_used_cells():
		var coords := origin + cell
		if not _saved_cells.has(coords):
			_saved_cells[coords] = [
				tilemap.get_cell_source_id(coords),
				tilemap.get_cell_atlas_coords(coords),
				tilemap.get_cell_alternative_tile(coords),
			]

	tilemap.set_pattern(origin, pattern)


func is_dark(coords: Vector2i) -> bool:
	return (
			tilemap.get_cell_source_id(coords) == dark_src
			and tilemap.get_cell_atlas_coords(coords) == dark_atlas
	)


func _restore():
	for coords in _saved_cells:
		var cell = _saved_cells[coords]
		tilemap.set_cell(coords, cell[0], cell[1], cell[2])
	# _saved_cells.clear()


func _cell_of(target: Target) -> Vector2i:
	# +16 samples the tile centre rather than the sprite's top-left origin
	return tilemap.local_to_map(tilemap.to_local(target.global_position + Vector2(16, 16)))


func _check_player():
	if _finished:
		return

	var cell := _cell_under_player()
	if is_dark(cell):
		player.is_caught = true
		if targets.all(
			func(t):
				return t.is_covered(),
		):
			var remaining_time: float = bed.remaining_rest_time(player)
			await get_tree().create_timer(remaining_time).timeout
			if player.is_resting:
				_on_level_complete()
			else:
				_on_level_failed("Couldn't make it to bed...")
		else:
			_on_level_failed("Fell asleep in the dark...")


func _on_level_failed(reason: String = ""):
	if _finished:
		return
	_finished = true
	print("level failed")
	failed.emit(reason)


func _on_level_complete():
	if _finished:
		return
	_finished = true
	print("level complete")
	completed.emit()


func play_exit_bloom(restarting := false) -> void:
	if not is_inside_tree():
		return
	player.is_frozen = true

	var src := light_src if restarting else dark_src
	var atlas := light_atlas if restarting else dark_atlas
	var alt := light_alt if restarting else dark_alt

	var cam: Camera2D = player.get_node("Camera2D")
	var zoom_tween := create_tween().set_trans(Tween.TRANS_SINE)
	zoom_tween.tween_property(cam, "zoom", Vector2.ONE, zoom_time)

	var origin := tilemap.local_to_map(tilemap.to_local(player.global_position + Vector2(16, 16)))
	var rect := tilemap.get_used_rect()

	# Bucket every cell by its distance from the player, then reveal ring by ring.
	var rings := { }
	var max_r := 0
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			var cell := Vector2i(x, y)
			var r := int(Vector2(cell - origin).length())
			if not rings.has(r):
				rings[r] = []
			rings[r].append(cell)
			max_r = maxi(max_r, r)

	for r in range(max_r + 1):
		if not is_inside_tree():
			return
		for cell in rings[r] if rings.has(r) else []:
			tilemap.set_cell(cell, src, atlas, dark_alt)
		await get_tree().create_timer(bloom_step).timeout
