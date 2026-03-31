@tool
class_name AsteroidMesh
extends Resource

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
		mesh_instance.position = asteroid_collisions[i].position_offset;

func update_collider(collider_index: int, viewport_rect: Rect2) -> void:
	var mesh_instance: MeshInstance2D = collision_shapes[collider_index].get_child(0);
	MarchingSquaresGenerate.upsert_generated_mesh_instance(viewport_rect, asteroid_collisions[collider_index].corner_sampling, asteroid_collisions[collider_index].texture, mesh_instance);
	var new_convex_shapes := MarchingSquaresGenerate.generate_collision_shapes(
		viewport_rect,
		asteroid_collisions[collider_index].corner_sampling
	);
	if (new_convex_shapes.size() == 0):
		print("DESTROY");
	else:
		var max_index := collision_shapes.size();
		
		if (new_convex_shapes.size() > 1):
			print("SHATTER");
			var new_max_index := max_index + new_convex_shapes.size();
			asteroid_collisions.resize(new_max_index);
		#
		#for i: int in new_convex_shapes.size():
			#var index := collider_index;
			#if i > 0:
				#index = max_index + 1;
				#var new_asteroid_collision := AsteroidCollision.new();
				#asteroid_collisions[index] = new_asteroid_collision;
				#
			#var convex_shape := new_convex_shapes[i];
			#asteroid_collisions[index].position_offset = MarchingSquaresUtility.get_center_point_of_polygon(convex_shape.points);
			#var new_points: Array[Vector2] = [];
			#for point in convex_shape.points:
				#new_points.append(_apply_position_offset(asteroid_collisions[index].position_offset, point));
			#convex_shape.points = new_points;
			#
			#if i == 0:
				#var collision_shape := collision_shapes[index];
				#collision_shape.call_deferred("set_shape", convex_shape);
				#
			#else:
				#var collision := CollisionShape2D.new();
				#collision.shape = convex_shape;
				#asteroid.call_deferred("add_child", collision);
				#asteroid_collisions[index].texture = asteroid_collisions[collider_index].texture;
				#asteroid_collisions[index].corner_sampling = MarchingSquaresUtility.filter_corner_samples_by_polygon(convex_shape.points, asteroid_collisions[collider_index].corner_sampling);
			#
			#MarchingSquaresGenerate.upsert_generated_mesh_instance(viewport_rect, asteroid_collisions[index].corner_sampling, asteroid_collisions[index].texture);
			#
			#
			## TODO: This is working enough to deform collision and mesh shapes. The mesh becomes offset though over collisions and collisions still are not accurate
			#
			#if (i > 1):
				#print("SHATTER");
			#else:
				#print("HIT")
		#
	#elif (new_convex_shapes.size() == 1):
		## No shatter; Update shapes and mesh
		#print("NO SHATTER");
#
		#
		#
		##MarchingSquaresGenerate.upsert_generated_mesh_instance(viewport_rect, corner_sampling, texture, mesh_instances[0]);
		#
		##for i:int in collision_shapes.size():
			##var shape_center := MarchingSquaresUtility.get_center_point_of_polygon(new_convex_shapes[i].points);
			##var new_points: Array[Vector2] = [];
			##for point in new_convex_shapes[i].points:
				##new_points.append(point - shape_center);
			##collision_shapes[i].call_deferred("set_shape", new_convex_shapes[i]);
##
		##collision_shapes[0].position = mesh_instances[0].position;
		##mesh_instances[0].position = Vector2.ZERO;
		##MarchingSquaresGenerate.upsert_generated_mesh_instance(viewport_rect, corner_sampling, texture, mesh_instances[0]);
	#else:
		#print("SHATTER to: ", new_convex_shapes.size(), " pieces");
		#var collision_shape := collision_shapes[collider_index];
		#position_offsets[collider_index] = MarchingSquaresUtility.get_center_point_of_polygon(new_convex_shapes[0].points);
		#var new_points: Array[Vector2] = [];
		#for point in new_convex_shapes[0].points:
			#new_points.append(point -  position_offsets[collider_index]);
		#new_convex_shapes[0].points = new_points;
		#collision_shape.call_deferred("set_shape", new_convex_shapes[0]);
		#var convex_shape := collision_shape.shape as ConvexPolygonShape2D;
		#var collision_corners := MarchingSquaresUtility.filter_corner_samples_by_polygon(convex_shape.points, per_collision_corner_samplings[collider_index]);
		#MarchingSquaresGenerate.upsert_generated_mesh_instance(viewport_rect, collision_corners, textures[collider_index], mesh_instances[collider_index]);
		#
func _apply_position_offset(offset: Vector2, position: Vector2) -> Vector2:
	return position - offset;

func _revert_position_offset(offset: Vector2, position: Vector2) -> Vector2:
	return position + offset;

# Corner sample values are reapplied by applying each damage_shape
# to intersecting corners with the shapes centered around the collision_point
func apply_damage_shape_to_corner_samples(
	collision_point: Vector2,
	damage_shapes: Array[DamageShape],
	collider_index: int,
) -> void:
	var corner_sampling := asteroid_collisions[collider_index].corner_sampling;
	var collider_position_offset := asteroid_collisions[collider_index].position_offset;
	var normalized_collision_point := _apply_position_offset(collision_point, collider_position_offset);
	print("collider_position_offset: ", collider_position_offset)
	print("collision_point: ", collision_point)
	print("normalized_collision_point: ", normalized_collision_point)
	print("CORNER RANGE: ", corner_sampling.keys()[0], ", ", corner_sampling.keys()[corner_sampling.keys().size() - 1])
	for key: Vector2 in corner_sampling:
		for damage_shape in damage_shapes:
			var new_corner_sample := damage_shape.apply_vector(
				collision_point,
				key,
				corner_sampling[key]
			);
			if (new_corner_sample != corner_sampling[key]):
				print("CHANGE: ", key, " from: ", corner_sampling[key], " to: ", new_corner_sample)
			corner_sampling[key] = new_corner_sample;
	
