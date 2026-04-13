@tool
class_name Asteroid extends RigidBody2D

# Change impact spead to use DealDamage

@export var max_velocity := 400; # m/s

@export var debug_collide := false;
@export var debug_random_movement := false;
@export var _collision_mesh_group: MS_CollisionMeshGroup;

var child_number := 0;
var collision_damage := 50.0;

@onready var deformable_mesh: DeformableMesh2D = get_node("DeformableMesh2D");
@onready var damageable: Damageable = get_node("Damageable");
@onready var deal_damage: DealDamage = get_node("DealDamage");
@onready var invince_frames_dr: DamageResult = get_node("Damageable/InvincibleFramesDamageResult");
var impact_points: Array[Vector2] = [];

func _ready() -> void:
	add_to_group("enemy");
	
	deformable_mesh.spawn_new_group.connect(_shatter);
	
	# TODO: Players don't cause _on_body_entered
	body_entered.connect(deal_damage.damage);
	
	# TODO: None of damageable works with the new mesh based damage
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
		
func _shatter(new_mesh_group: MS_CollisionMeshGroup) -> void:
	var new_asteroid := AsteroidManager.spawn_asteroid(self, new_mesh_group);
		# Launch child off in semi-random direction
	var impact_force := Vector2(
		randf_range(0, 100),
		randf_range(0, 100),
	)
	var rand_rotation := randf_range(-PI/4, PI/4);
	var rotated_force := impact_force.rotated((impact_force.angle() + rand_rotation)) ;
	new_asteroid.apply_central_impulse(rotated_force); 
		
func get_colliders() -> Array[CollisionShape2D]:
	return _collision_mesh_group.collision_shapes;
	
func get_collision_mesh_group() -> MS_CollisionMeshGroup:
	return _collision_mesh_group;

func _disable_colliders() -> void:
	for collision in get_colliders():
		collision.set_deferred("disabled", true);
	
func _enable_colliders() -> void:
	for collision in get_colliders():
		collision.set_deferred("disabled", false);
		
func _integrate_forces(_state: PhysicsDirectBodyState2D) -> void:
	# Clamp velocity to reasonable playable value
	linear_velocity = linear_velocity.normalized() * min(linear_velocity.length(), max_velocity);

func _destroy() -> void:
	call_deferred("queue_free");
	# TODO: Destroy animation
