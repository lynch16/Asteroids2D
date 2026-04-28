class_name DeformableMeshCollider2D
extends CollisionShape2D

const MIN_CORNERS = 8;

@export var _collision_mesh: MS_CollisionMesh;

var mesh_instance: MeshInstance2D;
var collision_mesh_group: DeformableMesh2D;

# Track velocity of object to calculate hit force
var last_self_velocities: Array[Vector2] = [];
var last_self_velocity_check_time: float;
var last_self_velocity_check_position: Vector2;
var max_last_velocities := 5;

signal spawn_new_group(new_collision_mesh_group: MS_CollisionMeshGroup);

func _enter_tree() -> void:
	var collision_mesh := _get_collision_mesh();
	if (MarchingSquaresUtility.count_positive_corners(collision_mesh.corner_sampling) < MIN_CORNERS):
		queue_free();
		
	shape = collision_mesh.convex_shape;
		
	mesh_instance = MarchingSquaresGenerate.upsert_mesh_instance(collision_mesh.mesh, collision_mesh.texture);
	
	add_child(mesh_instance);
	position = collision_mesh.position_offset;
	mesh_instance.position = mesh_instance.position + Vector2(MarchingSquaresUtility.HALF_TILE_SIZE, MarchingSquaresUtility.HALF_TILE_SIZE);
		
	# Set custom AABB to prevent mesh culling when object near camera borders
	var collision_shape_rect := shape.get_rect();
	collision_mesh.mesh.custom_aabb = AABB(Vector3(collision_shape_rect.position.x, collision_shape_rect.position.y, 0.0), Vector3(collision_shape_rect.size.x, collision_shape_rect.size.y, 0));

func _process(_delta: float) -> void:
	var new_time := Time.get_unix_time_from_system()

	# Track own velocity as a Node2D
	if (last_self_velocities.size() > max_last_velocities):
		last_self_velocities.pop_front();
		
	var self_time := new_time - last_self_velocity_check_time;
	last_self_velocity_check_time = new_time;
	var self_distance := global_position - last_self_velocity_check_position;
	last_self_velocity_check_position = global_position;
	last_self_velocities.append(self_distance / self_time);

func get_velocity() -> Vector2:
	var velocity_sum := Vector2.ZERO;
	for v in last_self_velocities:
		velocity_sum += v;
	
	var velocity_count := last_self_velocities.size();
	if (velocity_count > 0):
		return velocity_sum / velocity_count;
	else:
		return Vector2.ZERO;

func _get_collision_mesh() -> MS_CollisionMesh:
	return _collision_mesh;

func _release_collider() -> void:
	queue_free();

func update_collider() -> void:
	var viewport_rect := get_viewport_rect();
	var collision_mesh := _get_collision_mesh();
	var new_convex_shapes := MarchingSquaresGenerate.generate_collision_shapes(
		viewport_rect,
		collision_mesh.corner_sampling
	);
	
	var filtered_corners: Array[Dictionary] = [];
	
	var filtered_shapes: Array[ConvexPolygonShape2D] = new_convex_shapes.filter(
		func(convex_shape: ConvexPolygonShape2D) -> bool:
			var new_corners := MarchingSquaresUtility.filter_corner_samples_by_polygon(convex_shape.points, collision_mesh.corner_sampling);
			if (MarchingSquaresUtility.count_positive_corners(new_corners) >= MIN_CORNERS):
				filtered_corners.append(new_corners);
				return true;
			else:
				return false;
	);
	
	if (filtered_shapes.size() == 0):
		call_deferred("_release_collider");
		return;
	else:
		for i: int in filtered_shapes.size():
			var convex_shape := filtered_shapes[i];
			var new_corners := filtered_corners[i];
			
			if (i == 0):
				collision_mesh.position_offset = collision_mesh.position_offset;
				call_deferred("set_shape", convex_shape);
				MarchingSquaresGenerate.upsert_generated_mesh_instance(viewport_rect, new_corners, collision_mesh.texture, mesh_instance);
			else:
				var mesh := MarchingSquaresGenerate.generate_mesh(
					viewport_rect.size,
					new_corners,
					collision_mesh.texture
				);
				var new_collision_mesh := MS_CollisionMesh.new(
					collision_mesh.texture,
					new_corners,
					convex_shape,
					mesh,
					collision_mesh.position_offset
				);
				var new_collision_mesh_group := MS_CollisionMeshGroup.new([new_collision_mesh]);
				spawn_new_group.emit(new_collision_mesh_group);

func apply_mesh_deformation(
	collidion_point: Vector2,
	collision_angle: float,
	mesh_deformation_shapes: Array[MeshDeformationShape],
) -> void:
	_get_collision_mesh().apply_mesh_deformation_shapes_to_corner_samples(
		collidion_point,
		collision_angle,
		mesh_deformation_shapes
	);
	update_collider();
