@tool
class_name Asteroid extends RigidBody2D

@export var max_velocity := 400; # m/s
@export var _collision_mesh_group: MS_CollisionMeshGroup;
@export var _combat_stats: CombatStats;

# TODO: Make rail gun style deformation shape (blast through object until end of screeen)
@export var mesh_deformation_shapes: Array[MeshDeformationShape] = [];

var child_number := 0;
var collision_damage := 50.0;

@onready var deformable_mesh: DeformableMesh2D = get_node("DeformableMesh2D");
@onready var damageable: Damageable = get_node("Damageable");
@onready var deal_damage: DealDamage = get_node("DealDamage");
@onready var invince_frames_dr: DamageResult = get_node("Damageable/InvincibleFramesDamageResult");
var impact_points: Array[Vector2] = [];
var last_position: Vector2;

func _ready() -> void:
	add_to_group("enemy");
	_combat_stats.resource_local_to_scene = true;
	
	deformable_mesh.spawn_new_group.connect(_shatter);
	
	# TODO: Players don't cause _on_body_entered
	body_entered.connect(deal_damage.damage);
	body_shape_entered.connect(_on_body_shape_entered)
	
	# TODO: Need a way to damage when asteroids hit each other or player
	damageable.on_init(_combat_stats);
	invince_frames_dr.init.connect(_disable_colliders);
	invince_frames_dr.end.connect(_enable_colliders);
	
func _process(_delta: float) -> void:
	last_position = global_position;

func _on_body_entered(node: Node2D) -> void:
	deal_damage.damage(node);
	
		
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
		
func get_colliders() -> Array[DeformableMeshCollider2D]:
	return deformable_mesh.get_colliders();
	
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

func _on_body_shape_entered(_body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if (body is PhysicsBody2D):
		var physics_body: PhysicsBody2D = body;
		var body_shape_owner := physics_body.shape_find_owner(body_shape_index);
		var body_collider := physics_body.shape_owner_get_owner(body_shape_owner);
		
		var local_shape_owner := shape_find_owner(local_shape_index);
		var local_collider := shape_owner_get_owner(local_shape_owner);
		
		if (body_collider is DeformableMeshCollider2D && local_collider is DeformableMeshCollider2D):
			print("ASTEROID COLLISION");
			var mesh_collider: DeformableMeshCollider2D = body_collider;
			var local_mesh_collider: DeformableMeshCollider2D = local_collider;
			var collision_points := local_mesh_collider.shape.collide_and_get_contacts(
				local_mesh_collider.global_transform,
				mesh_collider.shape,
				mesh_collider.global_transform
			);
			
			if (collision_points.size() > 0):
				var impact_point: Vector2 = collision_points.get(0);
				var impact_angle := last_position.angle_to(impact_point);
			
				mesh_collider.apply_group_deformation(
					mesh_collider.to_local(impact_point),
					impact_angle,
					mesh_deformation_shapes,
				);
		else:
			print("OTHER COLLISION");
