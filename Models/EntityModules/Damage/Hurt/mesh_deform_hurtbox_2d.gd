class_name MeshDeformHurtbox2D
extends Hurtbox2D

@export var collision_mesh_group: MS_CollisionMeshGroup;

signal spawn_new_group(new_collision_mesh_group: MS_CollisionMeshGroup);
signal all_colliders_destroyed;

func _enter_tree() -> void:
	var deformable_mesh_2d := DeformableMesh2D.new();
	deformable_mesh_2d._collision_mesh_group = collision_mesh_group;
	deformable_mesh_2d.physics_node = self;
	deformable_mesh_2d.spawn_new_group.connect(_spawn_new_group);
	deformable_mesh_2d.all_colliders_destroyed.connect(_all_colliders_destroyed);    
	add_child(deformable_mesh_2d);

func _spawn_new_group(new_group: MS_CollisionMeshGroup) -> void:
	spawn_new_group.emit(new_group);

func _all_colliders_destroyed() -> void:
	all_colliders_destroyed.emit(); 
