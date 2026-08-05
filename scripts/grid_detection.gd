extends RayCast2D

@export var magnitude = 32


func _to_cardinal_direction(vec: Vector2) -> Vector2:
	if abs(vec.x) > abs(vec.y):
		return Vector2(sign(vec.x), 0)

	return Vector2(0, sign(vec.y))


func point_at(direction: Vector2):
	var prev = _to_cardinal_direction(direction)
	var next = magnitude * prev

	target_position = next
	force_raycast_update()
