@tool
class_name AsteroidMesh
extends Resource

@export var texture: Texture2D;
@export var corner_sampling: Dictionary[Vector2, float];
@export var collider_shape: ConvexPolygonShape2D;
@export var mesh: ArrayMesh;
@export var mesh_instance_position_offset: Vector2;

var collision_shapes: Array[CollisionShape2D];
var mesh_instances: Array[MeshInstance2D];

func _init(
	p_mesh: ArrayMesh = ArrayMesh.new(), 
	p_texture: Texture2D = Texture2D.new(), 
	p_mesh_instance_position_offset: Vector2 = Vector2(),
	p_corner_sampling: Dictionary[Vector2, float] = {},
	p_collider_shape: ConvexPolygonShape2D = ConvexPolygonShape2D.new(),
) -> void:
	mesh = p_mesh;
	texture = p_texture;
	mesh_instance_position_offset = p_mesh_instance_position_offset
	corner_sampling = p_corner_sampling;
	collider_shape = p_collider_shape;
	
	collision_shapes = [];
	mesh_instances = [];

func apply(asteroid: Asteroid) -> void:
	var collision := CollisionShape2D.new();
	collision.shape = collider_shape;
	collision_shapes.append(collision);
	asteroid.add_child(collision);
	
	var mesh_instance := MarchingSquaresGenerate.upsert_mesh_instance(mesh, texture);
	collision.add_child(mesh_instance);
	mesh_instance.position = mesh_instance_position_offset;
	mesh_instances.append(mesh_instance);

func update(asteroid: Asteroid, new_corner_samples: Dictionary[Vector2, float], viewport_rect: Rect2) -> void:
	corner_sampling = new_corner_samples
	
	var new_convex_shapes := MarchingSquaresGenerate.generate_collision_shapes(
		viewport_rect,
		corner_sampling
	);
	if (new_convex_shapes.size() == collision_shapes.size()):
		# No shatter; Update shapes and mesh
		print("NO SHATTER");
		for i:int in collision_shapes.size():
			var shape_center := MarchingSquaresUtility.get_center_point_of_polygon(new_convex_shapes[i].points);
			var new_points: Array[Vector2] = [];
			for point in new_convex_shapes[i].points:
				new_points.append(point - shape_center);
			collision_shapes[i].call_deferred("set_shape", new_convex_shapes[i]);

		collision_shapes[0].position = mesh_instances[0].position;
		mesh_instances[0].position = Vector2.ZERO;
		MarchingSquaresGenerate.upsert_generated_mesh_instance(viewport_rect, corner_sampling, texture, mesh_instances[0]);
	else:
		print("SHATTER from -> to: ", collision_shapes.size(), " -> ", new_convex_shapes.size());

# Corner sample values are reapplied by applying each damage_shape
# to intersecting corners with the shapes centered around the collision_point
# TODO: This doesn't work because the collision point wont necessarily be the edge
# 			a bullet travels so fast that the point may be on the far side of the object
# 			Instead, need to craft a raytrace from prior position to current position and determine first intersect
func apply_damage_shape_to_corner_samples(
	collision_point: Vector2,
	damage_shapes: Array[DamageShape],
) -> Dictionary[Vector2, float]:
	var new_corner_samples := corner_sampling.duplicate();
	for key: Vector2 in corner_sampling:
		for damage_shape in damage_shapes:
			if (damage_shape.shape is CircleShape2D):
				var circle_damage_shape: CircleShape2D = damage_shape.shape;
				if (Geometry2D.is_point_in_circle(key, collision_point, circle_damage_shape.radius)):
					var new_sample := corner_sampling[key] - damage_shape.damage;
					new_corner_samples[key] = new_sample;
			elif (damage_shape.shape is ConvexPolygonShape2D):
				var convex_shape: ConvexPolygonShape2D = damage_shape.shape;
				if (Geometry2D.is_point_in_polygon(collision_point, convex_shape.points)):
					var new_sample := corner_sampling[key] - damage_shape.damage;
					new_corner_samples[key] = new_sample;
			else:
				printerr("Unsupported DamageShape Shape2D: " + type_string(typeof(damage_shape.shape)));
	
	return new_corner_samples;
