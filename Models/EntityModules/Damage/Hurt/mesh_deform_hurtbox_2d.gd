class_name MeshDeformHurtbox2D
extends Hurtbox2D

@export var collision_mesh_group: MS_CollisionMeshGroup;

var last_position: Vector2;
var mesh_deformation_shapes: Array[MeshDeformationShape] = [];
var deformable_mesh_2d: DeformableMesh2D;

signal spawn_new_group(new_collision_mesh_group: MS_CollisionMeshGroup);
signal all_colliders_destroyed;

func _init(
	p_combat_stats: CombatStats,
	p_damage_results: Array[DamageResult] = [],
	p_collision_mesh_group: MS_CollisionMeshGroup = null,
) -> void:
	super(p_combat_stats, p_damage_results);
	collision_mesh_group = p_collision_mesh_group;

func _enter_tree() -> void:
	deformable_mesh_2d = DeformableMesh2D.new(
		collision_mesh_group,
		self
	);
	deformable_mesh_2d.spawn_new_group.connect(_spawn_new_group);
	deformable_mesh_2d.all_colliders_destroyed.connect(_all_colliders_destroyed);    
	add_child(deformable_mesh_2d);

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super();
	area_shape_entered.connect(_on_body_shape_entered);

func _physics_process(_delta: float) -> void:
	last_position = global_position;

func _spawn_new_group(new_group: MS_CollisionMeshGroup) -> void:
	spawn_new_group.emit(new_group);

func _all_colliders_destroyed() -> void:
	all_colliders_destroyed.emit(); 

func get_colliders() -> Array[DeformableMeshCollider2D]:
	return deformable_mesh_2d.get_colliders();

func _on_body_shape_entered(_body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	print("HITBOX SHAPE ENTERED: ", body);
	if (body is Area2D):
		var collision_body: Area2D = body;
		var body_shape_owner := collision_body.shape_find_owner(body_shape_index);
		var body_collider := collision_body.shape_owner_get_owner(body_shape_owner);

		var local_shape_owner := shape_find_owner(local_shape_index);
		var local_collider := shape_owner_get_owner(local_shape_owner);

		if (body_collider is DeformableMeshCollider2D):
			var mesh_collider: DeformableMeshCollider2D = body_collider;
			var local_mesh_collider: CollisionShape2D = local_collider;
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
