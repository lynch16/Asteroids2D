@tool
class_name AsteroidMesh
extends Resource

@export var textures: Array[Texture2D];
@export var per_collision_corner_samplings: Array[Dictionary]; # Array[Dictionary[Vector2, float]]
# TODO: do I need this global tracker?
@export var viewport_corner_sampling: Dictionary[Vector2, float];
@export var convex_shapes: Array[ConvexPolygonShape2D];
@export var meshes: Array[ArrayMesh];
@export var mesh_instance_position_offsets: Array[Vector2];

var collision_shapes: Array[CollisionShape2D];
var mesh_instances: Array[MeshInstance2D];
var asteroid: Asteroid;

func _init(
	p_meshes: Array[ArrayMesh] = [], 
	p_textures: Array[Texture2D] = [], 
	p_mesh_instance_position_offsets: Array[Vector2] = [],
	p_per_collision_corner_samplings: Array[Dictionary] = [],
	p_viewport_corner_sampling: Dictionary[Vector2, float] = {},
	p_convex_shapes: Array[ConvexPolygonShape2D] = [],
	p_asteroid: Asteroid = Asteroid.new(),
) -> void:
	meshes = p_meshes;
	textures = p_textures;
	mesh_instance_position_offsets = p_mesh_instance_position_offsets
	per_collision_corner_samplings = p_per_collision_corner_samplings;
	viewport_corner_sampling = p_viewport_corner_sampling;
	convex_shapes = p_convex_shapes;
	
	collision_shapes = [];
	mesh_instances = [];
	asteroid = p_asteroid;

func apply(asteroid: Asteroid) -> void:
	for i: int in convex_shapes.size():
		var collision := CollisionShape2D.new();
		collision.shape = convex_shapes[i];
		collision_shapes.append(collision);
		asteroid.add_child(collision);
	
		var mesh_instance := MarchingSquaresGenerate.upsert_mesh_instance(meshes[i], textures[i]);
		collision.add_child(mesh_instance);
		mesh_instance.position = mesh_instance_position_offsets[i];
		mesh_instances.append(mesh_instance);

# TODO: Update should be updating specific colliders
func update(new_corner_samples: Dictionary[Vector2, float], viewport_rect: Rect2) -> void:
	viewport_corner_sampling = new_corner_samples
	
	var new_convex_shapes := MarchingSquaresGenerate.generate_collision_shapes(
		viewport_rect,
		viewport_corner_sampling
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
		#MarchingSquaresGenerate.upsert_generated_mesh_instance(viewport_rect, corner_sampling, texture, mesh_instances[0]);
	else:
		print("SHATTER from -> to: ", collision_shapes.size(), " -> ", new_convex_shapes.size());

func update_collider(collider_index: int, viewport_rect: Rect2) -> void:
	var new_convex_shapes := MarchingSquaresGenerate.generate_collision_shapes(
		viewport_rect,
		per_collision_corner_samplings[collider_index]
	);
	if (new_convex_shapes.size() == 0):
		print("DESTROY");
	else:
		var max_index := collision_shapes.size();
		
		if (new_convex_shapes.size() > 1):
			var new_max_index := max_index + new_convex_shapes.size();
			mesh_instance_position_offsets.resize(new_max_index);
			textures.resize(new_max_index);
			mesh_instances.resize(new_max_index);
			per_collision_corner_samplings.resize(new_max_index);
		
		for i: int in new_convex_shapes.size():
			var index := collider_index if i == 0 else max_index + i;
			var convex_shape := new_convex_shapes[i];
			print("INDEX: ", index);
			print("new_convex_shapes: ", new_convex_shapes.size());
			print("mesh_instance_position_offsets: ", mesh_instance_position_offsets.size());
			mesh_instance_position_offsets[index] = MarchingSquaresUtility.get_center_point_of_polygon(convex_shape.points);
			var new_points: Array[Vector2] = [];
			for point in convex_shape.points:
				new_points.append(point -  mesh_instance_position_offsets[index]);
			convex_shape.points = new_points;
			
			if i == 0:
				var collision_shape := collision_shapes[index];
				collision_shape.call_deferred("set_shape", convex_shape);
				
			else:
				var collision := CollisionShape2D.new();
				collision.shape = convex_shape;
				asteroid.add_child(collision);
				textures[index] = textures[collider_index];
				mesh_instances[index] = MeshInstance2D.new();
				per_collision_corner_samplings[index] = MarchingSquaresUtility.filter_corner_samples_by_polygon(convex_shape.points, per_collision_corner_samplings[collider_index]);
				
			MarchingSquaresGenerate.upsert_generated_mesh_instance(viewport_rect, per_collision_corner_samplings[index], textures[index], mesh_instances[index]);
			
			
			# TODO: This is working enough to deform collision and mesh shapes. The mesh becomes offset though over collisions and collisions still are not accurate
			
			if (i > 1):
				print("SHATTER");
			else:
				print("HIT")
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
		#mesh_instance_position_offsets[collider_index] = MarchingSquaresUtility.get_center_point_of_polygon(new_convex_shapes[0].points);
		#var new_points: Array[Vector2] = [];
		#for point in new_convex_shapes[0].points:
			#new_points.append(point -  mesh_instance_position_offsets[collider_index]);
		#new_convex_shapes[0].points = new_points;
		#collision_shape.call_deferred("set_shape", new_convex_shapes[0]);
		#var convex_shape := collision_shape.shape as ConvexPolygonShape2D;
		#var collision_corners := MarchingSquaresUtility.filter_corner_samples_by_polygon(convex_shape.points, per_collision_corner_samplings[collider_index]);
		#MarchingSquaresGenerate.upsert_generated_mesh_instance(viewport_rect, collision_corners, textures[collider_index], mesh_instances[collider_index]);
		#
		
# Corner sample values are reapplied by applying each damage_shape
# to intersecting corners with the shapes centered around the collision_point
func apply_damage_shape_to_corner_samples(
	collision_point: Vector2,
	damage_shapes: Array[DamageShape],
	corner_sampling: Dictionary[Vector2, float],
) -> void:
	for key: Vector2 in corner_sampling:
		for damage_shape in damage_shapes:
			if (damage_shape.shape is CircleShape2D):
				var circle_damage_shape: CircleShape2D = damage_shape.shape;
				if (Geometry2D.is_point_in_circle(key, collision_point, circle_damage_shape.radius)):
					var new_sample := corner_sampling[key] - damage_shape.damage;
					corner_sampling[key] = new_sample;
			elif (damage_shape.shape is ConvexPolygonShape2D):
				var convex_shape: ConvexPolygonShape2D = damage_shape.shape;
				if (Geometry2D.is_point_in_polygon(collision_point, convex_shape.points)):
					var new_sample := corner_sampling[key] - damage_shape.damage;
					corner_sampling[key] = new_sample;
			else:
				printerr("Unsupported DamageShape Shape2D: " + type_string(typeof(damage_shape.shape)));
	
