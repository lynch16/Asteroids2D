extends Node
# Responsible for spawning all Asteroids, including after collision when an asteroid "shatters"

var asteroid_scenes: Array[PackedScene] = [
	preload("uid://drhrxw7642nqd"), # Asteroid scene
	preload("uid://drhrxw7642nqd"), # Asteroid scene
	preload("uid://drhrxw7642nqd"), # Asteroid scene
];
var child_angle_spread := PI/12;
var asteroid_count := 0;
var spawn_parent_node: Node;

func set_spawn_parent_node(node: Node) -> void:
	spawn_parent_node = node;

func spawn_asteroid(initial_aster: Asteroid = null, asteroid_mesh: MS_CollisionMeshGroup = null) -> Asteroid:
	var child_num: int = 0 if initial_aster == null else (initial_aster.child_number + 1);
	if (child_num >= asteroid_scenes.size()):
		return;
		
	var scene := asteroid_scenes[child_num];
	var aster: Asteroid = scene.instantiate();
	# TODO: Hook up signals for spawning from new mesh
	if (asteroid_mesh):
		aster._collision_mesh_group = asteroid_mesh;
	aster.child_number = child_num;
	
	if initial_aster:
		aster.position = initial_aster.position; # TODO: Move off center??
		aster.rotation = initial_aster.rotation;
		aster.linear_velocity = initial_aster.linear_velocity;

	call_deferred("_add_asteroid", aster);
	
	return aster;

func _add_asteroid(asteroid: Asteroid) -> void:
	# Need to be added within the navigation region
	spawn_parent_node.add_child(asteroid);
	asteroid_count += 1;
