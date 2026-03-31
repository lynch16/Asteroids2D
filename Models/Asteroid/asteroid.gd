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
var impact_points: Array[Vector2] = [];

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
	var colliders := get_colliders();
	var release_indicies: Array[int] = [];
	
	for i: int in colliders.size():
		print("I: ", i, " ", colliders.size())
		var collider := colliders[i];
		if (!is_instance_valid(collider)): 
			continue;
			
		var collision_points := projectile_collision.shape.collide_and_get_contacts(
			projectile_collision.global_transform,
			collider.shape,
			collider.global_transform
		);
		
		if (collision_points.size() > 0):
			var impact_point: Vector2 = collision_points.get(0);
			impact_points.append(to_local(impact_point));
			queue_redraw();
			
			if (!asteroid_mesh.asteroid_collisions.get(i)):
				continue;
			
			asteroid_mesh.apply_damage_shape_to_corner_samples(
				to_local(impact_point),
				damage_shapes,
				i,
			);
			var result: = asteroid_mesh.update_collider(i, get_viewport_rect());
			if (result == AsteroidMesh.REMOVE_COLLIDER):
				release_indicies.append(i);
			
	for idx in release_indicies:
		asteroid_mesh.release_collider(idx);


func _draw() -> void:
	for point in impact_points:
		draw_circle(point, 10, Color.BLUE);
