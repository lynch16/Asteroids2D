class_name SliceMeshDeformationShape
extends MeshDeformationShape

@export var line_width: int = 32;

func apply_vector(
	hitbox: PackedVector2Array,
	ms_corner: Vector2,
	corner_value: float,
) -> float:
	if (Geometry2D.is_point_in_polygon(ms_corner, hitbox)):
		return corner_value - damage;
	return corner_value;

func apply_shape(
	collision_point: Vector2,
	collision_angle: float,
	corner_sampling: Dictionary[Vector2, float],
) -> Dictionary[Vector2, float]:
	var hit_line := PackedVector2Array([collision_point, (collision_point * 5000).rotated(collision_angle)]);
	var hitbox := Geometry2D.offset_polyline(hit_line, line_width)[0];
	var new_corners: Dictionary[Vector2, float] = {};
	return corner_sampling.keys().reduce(
		func (updated_corners: Dictionary[Vector2, float], key: Vector2) -> Dictionary[Vector2, float]:
			updated_corners[key] = apply_vector(
				hitbox,
				key,
				corner_sampling[key]
			)
			return updated_corners,
		new_corners
	)
	
