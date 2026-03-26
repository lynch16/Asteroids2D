@tool
class_name Asteroid extends RigidBody2D

# Change impact spead to use DealDamage

@export var max_velocity := 400; # m/s

@export var debug_collide := false;
@export var debug_random_movement := false;
@export var asteroid_mesh: AsteroidMesh;

var child_number := 0;
var collision_damage := 50.0;

@onready var damageable: Damageable = get_node("Damageable");
@onready var deal_damage: DealDamage = get_node("DealDamage");
@onready var invince_frames_dr: DamageResult = get_node("Damageable/InvincibleFramesDamageResult");
#@onready var collision: CollisionShape2D = get_node("AsteroidCollision");
#@onready var mesh_instance: MeshInstance2D = get_node("MeshInstance2D");

#var collisions: Array[CollisionShape2D] = [];

func _ready() -> void:
	add_to_group("enemy");
	
	if (asteroid_mesh):
		asteroid_mesh.apply(self);
	
	# TODO: Players don't cause _on_body_entered
	body_entered.connect(deal_damage.damage);
	
	#damageable.on_init(self);
	damageable.on_destroy.connect(_destroy);
	invince_frames_dr.init.connect(_disable_colliders);
	invince_frames_dr.end.connect(_enable_colliders);
	
	# TODO: This should be part of _integrate_forces
	if (debug_collide):
		linear_velocity = Vector2.LEFT * 100;
		
	if (debug_random_movement):
		var direction := rotation;
		direction += randf_range(0, PI/2);
		rotation = direction + PI/2;
		
		# Fly in the direction we're facing
		var velocity := Vector2(
			10.0, 
			0.0
		);
		linear_velocity =  velocity.rotated(rotation - PI/2);
		
#func get_mesh_instances() -> Array[MeshInstance2D]:
	#return asteroid_mesh.mesh_instances;

func get_colliders() -> Array[CollisionShape2D]:
	return asteroid_mesh.collision_shapes;
	
#func _calculate_offset_from_global_position(collider_shapes: Array[ConvexPolygonShape2D]) -> Vector2:
	#var cX := 0.0;
	#var cY := 0.0;
	#
	#for shape in collider_shapes:
		#var center := shape.get_rect().get_center();
		#cX += center.x;
		#cY += center.y;
		#
	#cX = cX / collider_shapes.size();
	#cY = cY / collider_shapes.size();
	#
	#return global_position - to_global(Vector2(cX, cY));

func _disable_colliders() -> void:
	for collision in get_colliders():
		collision.set_deferred("disabled", true);
	
func _enable_colliders() -> void:
	for collision in get_colliders():
		collision.set_deferred("disabled", false);
	
func _physics_process(_delta: float) -> void:
	# TODO: This should be part of _integrate_forces
	# Clamp velocity to reasonable playable value
	linear_velocity = linear_velocity.normalized() * min(linear_velocity.length(), max_velocity);

func _destroy() -> void:
	call_deferred("queue_free");
	# TODO: Destroy animation
	
func handle_projectile(
	last_projectile_position: Vector2, 
	projectile_collision: CollisionShape2D, 
	damage_shapes: Array[DamageShape]
) -> void:
	# TODO: Identify which colliders the projectile hit and where they were hit
	# Pass those to update:
	# Update will apply corner updates to the respective colliders and generate new collision / mesh
	# If more than one collision shape is generated from a single collider, shatter
	var colliders := get_colliders();
	var first_collision_points: Dictionary[CollisionShape2D, Vector2] = {};
	var space_state := get_world_2d().direct_space_state;
	
	for i: int in colliders.size():
		var collider := colliders[i];
		if (!is_instance_valid(collider)): 
			continue;
			
		var collision_points := projectile_collision.shape.collide_and_get_contacts(
			projectile_collision.global_transform,
			collider.shape,
			collider.global_transform
		);
		
		var cX := 0.0;
		var cY := 0.0;
		var include_collider: bool = false;
	
		var ray_collision_points: Array[Vector2] = [];
		
		for point in collision_points:
			var ray_query := PhysicsRayQueryParameters2D.create(
				last_projectile_position,
				point
			);
			ray_query.exclude = [projectile_collision];
			var result := space_state.intersect_ray(ray_query);
			if (result.has("position")):
				include_collider = true;
				ray_collision_points.append(result.get("position"));
				cX += point.x;
				cY += point.y;
		var center := Vector2(cX / ray_collision_points.size(), cY / ray_collision_points.size());
		
		if (include_collider):
			asteroid_mesh.apply_damage_shape_to_corner_samples(
				center,
				damage_shapes,
				asteroid_mesh.per_collision_corner_samplings[i],
			);
			asteroid_mesh.update_collider(i, get_viewport_rect());
	
			first_collision_points.set(collider, center);
		
	print("first_collision_points: ", first_collision_points)

	#var orig_samples := asteroid_mesh.corner_sampling;
	#var damage_result_samples := asteroid_mesh.apply_damage_shape_to_corner_samples(
		#center,
		#damage_shapes,
	#);
	#
	#var diff_samples: Dictionary[Vector2, Array] = {};
	#for key in orig_samples:
		#if (damage_result_samples[key] != orig_samples[key]):
			#diff_samples[key] = [damage_result_samples[key], orig_samples[key]];
#
	#asteroid_mesh.update(
		#damage_result_samples,
		#get_viewport_rect()
	#);
