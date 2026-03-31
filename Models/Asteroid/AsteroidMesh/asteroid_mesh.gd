@tool
class_name AsteroidMesh
extends Resource

const MIN_CORNERS = 8;
const KEEP_COLLIDER = 0;
const REMOVE_COLLIDER = 1;

@export var asteroid_collisions: Array[AsteroidCollision];
@export var viewport_corner_sampling: Dictionary[Vector2, float];

var collision_shapes: Array[CollisionShape2D];
var asteroid: Asteroid;

func _init(
	p_asteroid_collisions: Array[AsteroidCollision] = [], 
	p_viewport_corner_sampling: Dictionary[Vector2, float] = {},
) -> void:
	asteroid_collisions = p_asteroid_collisions;
	viewport_corner_sampling = p_viewport_corner_sampling;
	
	collision_shapes = [];
	asteroid = Asteroid.new();

func apply(attach_asteroid: Asteroid) -> void:
	asteroid = attach_asteroid;
	for i: int in asteroid_collisions.size():
		var collision := CollisionShape2D.new();
		collision.shape = asteroid_collisions[i].convex_shape;
		collision_shapes.append(collision);
		asteroid.add_child(collision);
	
		var mesh_instance := MarchingSquaresGenerate.upsert_mesh_instance(asteroid_collisions[i].mesh, asteroid_collisions[i].texture);
		collision.add_child(mesh_instance);
		collision.position = asteroid_collisions[i].position_offset;

func release_collider(collider_index: int) -> void:
	collision_shapes[collider_index].call_deferred("queue_free");
	collision_shapes.remove_at(collider_index);
	asteroid_collisions.remove_at(collider_index);

func update_collider(collider_index: int, viewport_rect: Rect2) -> int:
	var new_convex_shapes := MarchingSquaresGenerate.generate_collision_shapes(
		viewport_rect,
		asteroid_collisions[collider_index].corner_sampling
	);
	var filtered_shapes: Array[ConvexPolygonShape2D] = new_convex_shapes.filter(
		func(convex_shape: ConvexPolygonShape2D) -> bool:
			var new_corners := MarchingSquaresUtility.filter_corner_samples_by_polygon(convex_shape.points, asteroid_collisions[collider_index].corner_sampling);
			var active_corners := new_corners.values().filter(
				func(val: float) -> bool:
					return val > 0.0;
			)
			return active_corners.size() >= MIN_CORNERS;
	);
	
	if (filtered_shapes.size() == 0):
		return REMOVE_COLLIDER;
	else:
		var max_index := collision_shapes.size();
		
		if (filtered_shapes.size() > 1):
			print("SHATTER: ", filtered_shapes.size());
			var new_max_index := max_index + filtered_shapes.size();
			asteroid_collisions.resize(new_max_index);
		#
		for i: int in filtered_shapes.size():
			var index := collider_index;
			
			# If Shatter, create a new collision resource to populate
			if i > 0:
				index = max_index + 1;
				var new_asteroid_collision := AsteroidCollision.new();
				asteroid_collisions[index] = new_asteroid_collision;
			
			var convex_shape := filtered_shapes[i];
			asteroid_collisions[index].position_offset = asteroid_collisions[collider_index].position_offset;
			
			if i == 0:
				var collision_shape := collision_shapes[index];
				collision_shape.call_deferred("set_shape", convex_shape);
				var mesh_instance: MeshInstance2D = collision_shapes[index].get_child(0);
				MarchingSquaresGenerate.upsert_generated_mesh_instance(viewport_rect, asteroid_collisions[index].corner_sampling, asteroid_collisions[index].texture, mesh_instance);
				
			else:
				var collision := CollisionShape2D.new();
				collision.shape = convex_shape;
				collision_shapes.append(collision);
				
				var new_corners := MarchingSquaresUtility.filter_corner_samples_by_polygon(convex_shape.points, asteroid_collisions[collider_index].corner_sampling);
				asteroid_collisions[index].position_offset = asteroid_collisions[collider_index].position_offset;
				asteroid_collisions[index].texture = asteroid_collisions[collider_index].texture;
				asteroid_collisions[index].corner_sampling = new_corners;

				var new_instance := MarchingSquaresGenerate.upsert_generated_mesh_instance(viewport_rect, asteroid_collisions[index].corner_sampling, asteroid_collisions[collider_index].texture);
				collision.position = asteroid_collisions[index].position_offset;
				collision.add_child(new_instance);
				asteroid.call_deferred("add_child", collision);
			
		return KEEP_COLLIDER;
			
func _apply_position_offset(offset: Vector2, position: Vector2) -> Vector2:
	return position - offset;

func _revert_position_offset(offset: Vector2, position: Vector2) -> Vector2:
	return position + offset;

# Corner sample values are reapplied by applying each damage_shape
# to intersecting corners with the shapes centered around the collision_point
func apply_damage_shape_to_corner_samples(
	raw_collider: Vector2,
	damage_shapes: Array[DamageShape],
	collider_index: int,
) -> void:
	var corner_sampling := asteroid_collisions[collider_index].corner_sampling;
	var collider_position_offset := asteroid_collisions[collider_index].position_offset;
	var normalized_collision_point := _apply_position_offset(collider_position_offset, raw_collider);
	for key: Vector2 in corner_sampling:
		for damage_shape in damage_shapes:
			var new_corner_sample := damage_shape.apply_vector(
				normalized_collision_point,
				key,
				corner_sampling[key]
			);
			corner_sampling[key] = new_corner_sample;
	
