extends Node2D

@export var covered_pattern_index := 0

@onready var tilemap: TileMapLayer = $TileMapLayer
@onready var targets := get_tree().get_nodes_in_group("targets")

var _saved_cells := {}

func _ready():
	for target in targets:
		target.covered.connect(_on_target_changed)
		target.uncovered.connect(_on_target_changed)


func _on_target_changed(_target: Target):
	_repaint()
	if targets.all(func(t): return t.is_covered()):
		_on_level_complete()


func _repaint():
	_restore()
	for target in targets:
		if target.is_covered():
			_paint_around(target)


func _paint_around(target: Target):
	var pattern := tilemap.tile_set.get_pattern(covered_pattern_index)
	var size := pattern.get_size()
	var origin := _cell_of(target) - size / 2   # centre the stamp on the target

    # For undoing a cover and keeping the original tile map
	for cell in pattern.get_used_cells():
		var coords := origin + cell
		if not _saved_cells.has(coords):
			_saved_cells[coords] = [
				tilemap.get_cell_source_id(coords),
				tilemap.get_cell_atlas_coords(coords),
				tilemap.get_cell_alternative_tile(coords),
			]

	tilemap.set_pattern(origin, pattern)


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
