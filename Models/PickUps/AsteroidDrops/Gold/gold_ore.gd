class_name GoldOrePickUp
extends PickUp

### 
# MeshDeformHurtbox2D that loads the generated mesh, texture and collider
# Set to a collision layer that projectiles don't fuck with - will need to update hit and hurtboxes logic.
# On asteroid death caused by player, spawn this pickup
@export var collision_mesh_group: MS_CollisionMeshGroup;
@export var gold_value: int = 1;

var deformable_mesh_2d: DeformableMesh2D;

func _enter_tree() -> void:
	deformable_mesh_2d = DeformableMesh2D.new(
		collision_mesh_group,
		get_node("Area2D")
	);
	add_child(deformable_mesh_2d);
