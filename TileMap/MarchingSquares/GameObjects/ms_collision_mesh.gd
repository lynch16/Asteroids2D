class_name MS_CollisionMesh
extends Resource

@export var texture: Texture2D;
@export var corner_sampling: Dictionary[Vector2, float];
@export var convex_shape: ConvexPolygonShape2D;
@export var mesh: ArrayMesh;
@export var position_offset: Vector2;

func _init(
	p_texture: Texture2D = Texture2D.new(),
	p_corner_sampling: Dictionary[Vector2, float] = {},
	p_convex_shape: ConvexPolygonShape2D = ConvexPolygonShape2D.new(),
	p_mesh: ArrayMesh = ArrayMesh.new(),
	p_position_offset: Vector2 = Vector2(),
) -> void:
	texture = p_texture;
	corner_sampling = p_corner_sampling;
	convex_shape = p_convex_shape;
	mesh = p_mesh;
	position_offset = p_position_offset;
	resource_local_to_scene = true;

# Corner sample values are reapplied by applying each damage_shape
# to intersecting corners with the shapes centered around the collision_point
func apply_damage_shape_to_corner_samples(
	raw_collidion_point: Vector2,
	collision_angle: float,
	damage_shapes: Array[DamageShape],
) -> void:
	var normalized_collision_point := _apply_position_offset(position_offset, raw_collidion_point);
	for key: Vector2 in corner_sampling:
		for damage_shape in damage_shapes:
			var new_corner_sample := damage_shape.apply_vector(
				normalized_collision_point,
				collision_angle,
				key,
				corner_sampling[key]
			);
			corner_sampling[key] = new_corner_sample;
			
func _apply_position_offset(offset: Vector2, position: Vector2) -> Vector2:
	return position - offset;
