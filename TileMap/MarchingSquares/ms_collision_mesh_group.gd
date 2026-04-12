@tool
class_name MS_CollisionMeshGroup
extends Resource

const MIN_CORNERS = 8;
const KEEP_COLLIDER = 0;
const REMOVE_COLLIDER = 1;

@export var collision_meshes: Array[MS_CollisionMesh];

var collision_shapes: Array[CollisionShape2D];
var owner: Node2D;

func _init(
	p_collision_meshes: Array[MS_CollisionMesh] = [], 
) -> void:
	collision_meshes = p_collision_meshes;
	
	collision_shapes = [];
	owner = Node2D.new();
	resource_local_to_scene = true;

func apply(_owner: Node2D) -> void:
	owner = _owner;
	for i: int in collision_meshes.size():
		if (!collision_meshes[i] || MarchingSquaresUtility.count_positive_corners(collision_meshes[i].corner_sampling) < MIN_CORNERS):
			continue;
		
		var collision := CollisionShape2D.new();
		collision.shape = collision_meshes[i].convex_shape;
		collision_shapes.append(collision);
		owner.add_child(collision);
		
		var mesh_instance := MarchingSquaresGenerate.upsert_mesh_instance(collision_meshes[i].mesh, collision_meshes[i].texture);
		collision.add_child(mesh_instance);
		collision.position = collision_meshes[i].position_offset;
		mesh_instance.position = mesh_instance.position + Vector2(MarchingSquaresUtility.HALF_TILE_SIZE, MarchingSquaresUtility.HALF_TILE_SIZE);
		
		# Set custom AABB to prevent mesh culling when object near camera borders
		var collision_shape_rect := collision.shape.get_rect();
		collision_meshes[i].mesh.custom_aabb = AABB(Vector3(collision_shape_rect.position.x, collision_shape_rect.position.y, 0.0), Vector3(collision_shape_rect.size.x, collision_shape_rect.size.y, 0));

func release_collider(collider_index: int) -> void:
	collision_shapes[collider_index].call_deferred("queue_free");
	collision_shapes.remove_at(collider_index);
	collision_meshes.remove_at(collider_index);

func update_collider(collider_index: int, viewport_rect: Rect2) -> int:
	var new_convex_shapes := MarchingSquaresGenerate.generate_collision_shapes(
		viewport_rect,
		collision_meshes[collider_index].corner_sampling
	);
	var filtered_shapes: Array[ConvexPolygonShape2D] = new_convex_shapes.filter(
		func(convex_shape: ConvexPolygonShape2D) -> bool:
			var new_corners := MarchingSquaresUtility.filter_corner_samples_by_polygon(convex_shape.points, collision_meshes[collider_index].corner_sampling);
			return MarchingSquaresUtility.count_positive_corners(new_corners) >= MIN_CORNERS;
	);
	
	if (filtered_shapes.size() == 0):
		return REMOVE_COLLIDER;
	else:
		var max_index := collision_shapes.size();
		
		if (filtered_shapes.size() > 1):
			print("SHATTER: ", filtered_shapes.size());
			var new_max_index := max_index + filtered_shapes.size();
			collision_meshes.resize(new_max_index);
		#
		for i: int in filtered_shapes.size():
			var convex_shape := filtered_shapes[i];
			
			if (i == 0):
				collision_meshes[collider_index].position_offset = collision_meshes[collider_index].position_offset;
				var collision_shape := collision_shapes[collider_index];
				collision_shape.call_deferred("set_shape", convex_shape);
				var mesh_instance: MeshInstance2D = collision_shapes[collider_index].get_child(0);
				var new_corners := MarchingSquaresUtility.filter_corner_samples_by_polygon(convex_shape.points, collision_meshes[collider_index].corner_sampling);
				MarchingSquaresGenerate.upsert_generated_mesh_instance(viewport_rect, new_corners, collision_meshes[collider_index].texture, mesh_instance);
			else:
				var new_corners := MarchingSquaresUtility.filter_corner_samples_by_polygon(convex_shape.points, collision_meshes[collider_index].corner_sampling);
				var mesh := MarchingSquaresGenerate.generate_mesh(
					viewport_rect.size,
					new_corners,
					collision_meshes[collider_index].texture
				);
				var new_collision_mesh := MS_CollisionMesh.new(
					collision_meshes[collider_index].texture,
					new_corners,
					convex_shape,
					mesh,
					collision_meshes[collider_index].position_offset
				);
				var new_collision_mesh_group := MS_CollisionMeshGroup.new([new_collision_mesh]);
				# TODO: Emit signals to destroy colliders, create new group, etc;
				AsteroidManager.spawn_asteroid(owner as Asteroid, new_collision_mesh_group);
			
			
		return KEEP_COLLIDER;
			
func _apply_position_offset(offset: Vector2, position: Vector2) -> Vector2:
	return position - offset;

func _revert_position_offset(offset: Vector2, position: Vector2) -> Vector2:
	return position + offset;

# Corner sample values are reapplied by applying each damage_shape
# to intersecting corners with the shapes centered around the collision_point
func apply_damage_shape_to_corner_samples(
	raw_collidion_point: Vector2,
	collision_angle: float,
	damage_shapes: Array[DamageShape],
	collider_index: int,
) -> void:
	var corner_sampling := collision_meshes[collider_index].corner_sampling;
	var collider_position_offset := collision_meshes[collider_index].position_offset;
	var normalized_collision_point := _apply_position_offset(collider_position_offset, raw_collidion_point);
	for key: Vector2 in corner_sampling:
		for damage_shape in damage_shapes:
			var new_corner_sample := damage_shape.apply_vector(
				normalized_collision_point,
				collision_angle,
				key,
				corner_sampling[key]
			);
			corner_sampling[key] = new_corner_sample;
	
