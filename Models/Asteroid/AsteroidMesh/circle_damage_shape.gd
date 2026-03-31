extends DamageShape

func apply_vector(
	_collision_point: Vector2,
	_ms_corner: Vector2,
	corner_value: float,
) -> float:
	return corner_value;
