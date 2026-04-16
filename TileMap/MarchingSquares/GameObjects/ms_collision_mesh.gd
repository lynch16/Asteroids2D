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

# Corner sample values are reapplied by applying each mesh_deformation_shapes
# to intersecting corners with the shapes centered around the collision_point
func apply_mesh_deformation_shapes_to_corner_samples(
	collidion_point: Vector2,
	collision_angle: float,
	mesh_deformation_shapes: Array[MeshDeformationShape],
) -> void:
	for mesh_deformation_shape in mesh_deformation_shapes:
		corner_sampling = mesh_deformation_shape.apply_shape(
			collidion_point,
			collision_angle,
			corner_sampling	
		);
