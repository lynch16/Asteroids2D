class_name DeformableMeshCollider2D
extends CollisionShape2D

const MIN_CORNERS = 8;

@export var _collision_mesh: MS_CollisionMesh;

var mesh_instance: MeshInstance2D;
var collision_mesh_group: DeformableMesh2D;

signal spawn_new_group(new_collision_mesh_group: MS_CollisionMeshGroup);

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var collision_mesh := _get_collision_mesh();
	if (MarchingSquaresUtility.count_positive_corners(collision_mesh.corner_sampling) < MIN_CORNERS):
		return;
		
	shape = collision_mesh.convex_shape;
		
	mesh_instance = MarchingSquaresGenerate.upsert_mesh_instance(collision_mesh.mesh, collision_mesh.texture);
	add_child(mesh_instance);
	position = collision_mesh.position_offset;
	mesh_instance.position = mesh_instance.position + Vector2(MarchingSquaresUtility.HALF_TILE_SIZE, MarchingSquaresUtility.HALF_TILE_SIZE);
		
	# Set custom AABB to prevent mesh culling when object near camera borders
	var collision_shape_rect := shape.get_rect();
	collision_mesh.mesh.custom_aabb = AABB(Vector3(collision_shape_rect.position.x, collision_shape_rect.position.y, 0.0), Vector3(collision_shape_rect.size.x, collision_shape_rect.size.y, 0));

func _get_collision_mesh() -> MS_CollisionMesh:
	return _collision_mesh;

func _release_collider() -> void:
	print("RELEASE");
	queue_free();

func update_collider() -> void:
	var viewport_rect := get_viewport_rect();
	var collision_mesh := _get_collision_mesh();
	var new_convex_shapes := MarchingSquaresGenerate.generate_collision_shapes(
		viewport_rect,
		collision_mesh.corner_sampling
	);
	var filtered_shapes: Array[ConvexPolygonShape2D] = new_convex_shapes.filter(
		func(convex_shape: ConvexPolygonShape2D) -> bool:
			var new_corners := MarchingSquaresUtility.filter_corner_samples_by_polygon(convex_shape.points, collision_mesh.corner_sampling);
			return MarchingSquaresUtility.count_positive_corners(new_corners) >= MIN_CORNERS;
	);
	
	if (filtered_shapes.size() == 0):
		call_deferred("_release_collider");
		return;
	else:
		for i: int in filtered_shapes.size():
			var convex_shape := filtered_shapes[i];
			
			if (i == 0):
				collision_mesh.position_offset = collision_mesh.position_offset;
				call_deferred("set_shape", convex_shape);
				# TODO: new_corners calculated 3x
				var new_corners := MarchingSquaresUtility.filter_corner_samples_by_polygon(convex_shape.points, collision_mesh.corner_sampling);
				MarchingSquaresGenerate.upsert_generated_mesh_instance(viewport_rect, new_corners, collision_mesh.texture, mesh_instance);
			else:
				var new_corners := MarchingSquaresUtility.filter_corner_samples_by_polygon(convex_shape.points, collision_mesh.corner_sampling);
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

var point: Vector2;
var angle: float;

func apply_mesh_deformation(
	collidion_point: Vector2,
	collision_angle: float,
	mesh_deformation_shapes: Array[MeshDeformationShape],
) -> void:
	point = collidion_point;
	angle = collision_angle;
	_get_collision_mesh().apply_mesh_deformation_shapes_to_corner_samples(
		collidion_point,
		collision_angle,
		mesh_deformation_shapes
	);
	update_collider();
	#queue_redraw();
#
#func _draw() -> void:
	#if (point && angle):
		#var hit_line := PackedVector2Array([point, (point * 5000).rotated(angle)]);
		#var hitbox := Geometry2D.offset_polyline(hit_line, 16)[0];
		#print("HITBOX SIZE: ", Geometry2D.offset_polyline(hit_line, 16).size());
		#draw_colored_polygon(hitbox, Color.WHITE);

func apply_group_deformation(
	collidion_point: Vector2,
	collision_angle: float,
	mesh_deformation_shapes: Array[MeshDeformationShape],
) -> void:
	collision_mesh_group.deform_group(
		collidion_point,
		collision_angle,
		mesh_deformation_shapes
	)
	
