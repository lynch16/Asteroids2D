@tool
class_name TileMapGameControls

# Corner sample values are reapplied by applying each damage_shape
# to intersecting corners with the shapes centered around the collision_point
# TODO: This doesn't work because the collision point wont necessarily be the edge
# 			a bullet travels so fast that the point may be on the far side of the object
# 			Instead, need to craft a raytrace from prior position to current position and determine first intersect
static func _apply_damage_shape_to_corner_samples(
	collision_point: Vector2,
	damage_shapes: Array[DamageShape],
	corner_samples: Dictionary[Vector2, float],
) -> Dictionary[Vector2, float]:
	var new_corner_samples := corner_samples.duplicate();
	for key: Vector2 in corner_samples:
		for damage_shape in damage_shapes:
			if (damage_shape.shape is CircleShape2D):
				var circle_damage_shape: CircleShape2D = damage_shape.shape;
				if (Geometry2D.is_point_in_circle(key, collision_point, circle_damage_shape.radius)):
					var new_sample := corner_samples[key] - damage_shape.damage;
					new_corner_samples[key] = new_sample;
			elif (damage_shape.shape is ConvexPolygonShape2D):
				var convex_shape: ConvexPolygonShape2D = damage_shape.shape;
				if (Geometry2D.is_point_in_polygon(collision_point, convex_shape.points)):
					var new_sample := corner_samples[key] - damage_shape.damage;
					new_corner_samples[key] = new_sample;
			else:
				printerr("Unsupported DamageShape Shape2D: " + type_string(typeof(damage_shape.shape)));
				
	return new_corner_samples;
