@tool
class_name Asteroid extends CharacterBody2D

@export var max_velocity := 400; # m/s
@export var collision_mesh_group: MS_CollisionMeshGroup;
@export var _combat_stats: CombatStats;

# TODO: Make rail gun style deformation shape (blast through object until end of screeen)
@export var mesh_deformation_shapes: Array[MeshDeformationShape] = [];

var mass := 10000;
var child_number := 0;
var collision_damage := 50.0;

var deformable_mesh: DeformableMesh2D;
@onready var damageable: Damageable = get_node("Damageable");
@onready var deal_damage: DealDamage = get_node("DealDamage");
@onready var invince_frames_dr: DamageResult = get_node("Damageable/InvincibleFramesDamageResult");

# TODO: Temp
@onready var area_2d: Area2D = get_node("Area2D");

var impact_points: Array[Vector2] = [];
var last_position: Vector2;

func _enter_tree() -> void:
	deformable_mesh = get_node("DeformableMesh2D");
	deformable_mesh._collision_mesh_group = collision_mesh_group.duplicate(true);

func _ready() -> void:
	add_to_group("enemy");
	_combat_stats.resource_local_to_scene = true;
	
	deformable_mesh.spawn_new_group.connect(_shatter);
	
	# TODO: Players don't cause _on_body_entered
	area_2d.body_entered.connect(deal_damage.damage);
	area_2d.area_entered.connect(deal_damage.damage);
	area_2d.body_shape_entered.connect(_on_body_shape_entered)
	area_2d.area_shape_entered.connect(_on_body_shape_entered)
	
	# TODO: Need a way to damage when asteroids hit each other or player
	damageable.on_init(_combat_stats);
	invince_frames_dr.init.connect(_disable_colliders);
	invince_frames_dr.end.connect(_enable_colliders);

func _physics_process(_delta: float) -> void:
	# Clamp velocity to reasonable playable value
	velocity = velocity.normalized() * min(velocity.length(), max_velocity);
	move_and_slide();
	last_position = global_position;

func _on_body_entered(node: Node2D) -> void:
	deal_damage.damage(node);
	
		
func _shatter(new_mesh_group: MS_CollisionMeshGroup) -> void:
	AsteroidManager.shatter_asteroid(self, new_mesh_group);
		
func get_colliders() -> Array[DeformableMeshCollider2D]:
	return deformable_mesh.get_colliders();

func _disable_colliders() -> void:
	for collision in get_colliders():
		if (is_instance_valid(collision)):
			collision.set_deferred("disabled", true);
	
func _enable_colliders() -> void:
	for collision in get_colliders():
		if (is_instance_valid(collision)):
			collision.set_deferred("disabled", false);
		

func _destroy() -> void:
	call_deferred("queue_free");
	# TODO: Destroy animation

# TODO: Need a minimum velocity difference for when to shatter
# TODO: Try converting these to CharacterBody2D instead of physics objects
func _on_body_shape_entered(_body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if (body is Area2D):
		var collision_body: Area2D = body;
		var body_shape_owner := collision_body.shape_find_owner(body_shape_index);
		var body_collider := collision_body.shape_owner_get_owner(body_shape_owner);
		
		# TODO: area_2d is temp
		var local_shape_owner := area_2d.shape_find_owner(local_shape_index);
		var local_collider := area_2d.shape_owner_get_owner(local_shape_owner);
		
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

				# TODO: This should not be exactly the same bounce velocity
				var new_speed := velocity.length() * randf_range(0.5, 2.0);
				velocity = (new_speed * velocity.normalized()).rotated(PI/2);

		else:
			print("OTHER COLLISION");
