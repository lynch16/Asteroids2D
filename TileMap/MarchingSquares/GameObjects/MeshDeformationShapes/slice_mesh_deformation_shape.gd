class_name SliceMeshDeformationShape
extends MeshDeformationShape

@export var line_cell_width: int = 4;

func apply_vector(
	hitbox: PackedVector2Array,
	ms_corner: Vector2,
	corner_value: float,
) -> float:
	if (Geometry2D.is_point_in_polygon(ms_corner, hitbox)):
		return corner_value - damage;
	return corner_value;

# func apply_shape(
# 	collision_point: Vector2,
# 	collision_angle: float,
# 	corner_sampling: Dictionary[Vector2, float],
# ) -> Dictionary[Vector2, float]:
# 	var hit_line := PackedVector2Array([collision_point, (collision_point * 5000).rotated(collision_angle)]);
# 	var hitbox := Geometry2D.offset_polyline(hit_line, line_width)[0];
# 	var new_corners: Dictionary[Vector2, float] = {};
# 	return corner_sampling.keys().reduce(
# 		func (updated_corners: Dictionary[Vector2, float], key: Vector2) -> Dictionary[Vector2, float]:
# 			updated_corners[key] = apply_vector(
# 				hitbox,
# 				key,
# 				corner_sampling[key]
# 			)
# 			return updated_corners,
# 		new_corners
# 	)
	

func apply_bitmap(
	collision_point: Vector2,
	collision_angle: float,
	target_bitmap: MS_Bitmap,
) -> void:
	var target_size := target_bitmap.get_size();
	var length := target_size.length();
	bitmap.resize(target_size);

	var end_x := length * cos(collision_angle);
	var end_y := length * sin(collision_angle);

	var slope := (end_y - collision_point.y)/ (end_x - collision_point.x);

	for x in target_size.x:
		var line_y := slope * (x - collision_point.x) + collision_point.y;
		
		if (
			line_y > 0 &&
			line_y < target_size.y
		):
			bitmap.set_cell(x, line_y, damage);

	target_bitmap.subtract(get_bitmap(), collision_point);
