extends Node2D

@export var darken_patterns: Array[int] = [0, 1, 2, 3, 4, 5, 6]
@export var step_time := 1.0

@onready var tilemap: TileMapLayer = $TileMapLayer
@onready var targets := get_tree().get_nodes_in_group("targets")
@onready var player: Player = $Player

var _saved_cells := {}


func _unhandled_input(event):
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()

func _ready():
	for target in targets:
		target.covered.connect(_on_covered)
		target.uncovered.connect(_on_uncovered)


func _on_covered(target: Target):
	# Patterns are cumulative — each blob contains the previous one — so they can
	# be darkened in sequence without restoring the floor in between.
	for i in darken_patterns.size():
		if not target.is_covered():
			return                      # box left mid-darken
		_darken(target, darken_patterns[i])
		await get_tree().create_timer(step_time).timeout

	if targets.all(func(t): return t.is_covered()) and player.is_resting:
		_on_level_complete()


func _on_uncovered(_target: Target):
	# _saved_cells is shared, so one target's blob can't be lifted in isolation:
	# rebuild the floor, then re-darken whoever is still covered.
	_restore()
	for target in targets:
		if target.is_covered():
			_darken(target, darken_patterns[-1])


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
	_check_player()


func is_dark(coords: Vector2i) -> bool:
	return _saved_cells.has(coords)


func _check_player():
	var cell := tilemap.local_to_map(tilemap.to_local(player.global_position + Vector2(16, 16)))
	if is_dark(cell) and not player.is_resting:
		player.is_caught = true
		print("Player got caught")


func _restore():
	for coords in _saved_cells:
		var cell = _saved_cells[coords]
		tilemap.set_cell(coords, cell[0], cell[1], cell[2])
	_saved_cells.clear()


func _cell_of(target: Target) -> Vector2i:
	# +16 samples the tile centre rather than the sprite's top-left origin
	return tilemap.local_to_map(tilemap.to_local(target.global_position + Vector2(16, 16)))


func _on_level_complete():
	print("level complete")
