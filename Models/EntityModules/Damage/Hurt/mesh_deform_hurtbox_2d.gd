class_name MeshDeformHurtbox2D
extends Hurtbox2D
## Instantiates an MS_CollisionMeshGroup as DeformableMesh2D as the shape of a Hurtbox

@export var collision_mesh_group: MS_CollisionMeshGroup;

var mesh_deformation_shapes: Array[MeshDeformationShape] = [];
var deformable_mesh_2d: DeformableMesh2D;

signal spawn_new_group(new_collision_mesh_group: MS_CollisionMeshGroup);
signal all_colliders_destroyed;

func _init(
	p_health_stats: HealthStats = HealthStats.new(),
	p_owner_node: Node = null,
	p_collision_mesh_group: MS_CollisionMeshGroup = null,
) -> void:
	super(p_health_stats, null, p_owner_node);
	collision_mesh_group = p_collision_mesh_group;

func _enter_tree() -> void:
	deformable_mesh_2d = DeformableMesh2D.new(
		collision_mesh_group,
		self
	);
	deformable_mesh_2d.spawn_new_group.connect(_spawn_new_group);
	deformable_mesh_2d.all_colliders_destroyed.connect(_all_colliders_destroyed);    
	add_child(deformable_mesh_2d);

func _spawn_new_group(new_group: MS_CollisionMeshGroup) -> void:
	spawn_new_group.emit(new_group);

func _all_colliders_destroyed() -> void:
	all_colliders_destroyed.emit(); 

func get_colliders() -> Array[CollisionShape2D]:
	var colliders := deformable_mesh_2d.get_colliders();
	var transformed_colliders: Array[CollisionShape2D] = [];

	for collider in colliders:
		if collider is CollisionShape2D:
			var transformed_collider: CollisionShape2D = collider;
			transformed_colliders.append(transformed_collider);

	return transformed_colliders;
