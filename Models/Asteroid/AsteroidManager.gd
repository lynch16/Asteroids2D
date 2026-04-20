extends Node
# Responsible for spawning all Asteroids, including after collision when an asteroid "shatters"
var asteroid_meshes: Array[MS_CollisionMeshGroup] = [];

var astreroid_scene := preload("uid://drhrxw7642nqd");
var child_angle_spread := PI/12;
var asteroid_count := 0;
var spawn_parent_node: Node;

var asteroid_launcher: Array[AsteroidLaunch] = [];

func _ready() -> void:
	var script_path: String = get_script().resource_path;
	var folder_parts := script_path.split("/");
	folder_parts.remove_at(folder_parts.size() - 1);
	var folder_path := "/".join(folder_parts);
	print("folder_path: ", folder_path);
	var asteroid_mesh_dir := DirAccess.open(folder_path + "/AsteroidMesh");
	assert(asteroid_mesh_dir != null);

	for file: String in asteroid_mesh_dir.get_files():
		asteroid_meshes.append(
			load(asteroid_mesh_dir.get_current_dir() + "/" + file)
		);

func _process(_delta: float) -> void:
	var asteroid_to_launch: AsteroidLaunch = asteroid_launcher.pop_front();
	if (asteroid_to_launch):
		var new_asteroid := spawn_asteroid(asteroid_to_launch.asteroid_mesh);
		new_asteroid.linear_velocity = asteroid_to_launch.launch_velocity;
		new_asteroid.rotation = asteroid_to_launch.launch_angle;
		

func set_spawn_parent_node(node: Node) -> void:
	spawn_parent_node = node;

func shatter_asteroid(initial_aster: Asteroid, new_mesh: MS_CollisionMeshGroup) -> void:
	var direction := randf_range(0, PI);
	var speed := initial_aster.linear_velocity.length() * randf_range(0.5, 2.0);
	initial_aster.linear_velocity = initial_aster.linear_velocity.rotated(-direction);
	
	var asteroid_launch := AsteroidLaunch.new(
		new_mesh,
		Vector2(speed, 0).rotated(direction),
		direction
	)
	asteroid_launcher.append(asteroid_launch);

# TODO: Get rid of child_num, change scenes to meshes, make "maybe_spawn_asteroid", differentiate between spawn from and spawn brand new, add impulse to both initial  and new to push them away from each other
# TODO: Build launch queue
func spawn_asteroid(asteroid_mesh: MS_CollisionMeshGroup = null) -> Asteroid:
	var aster: Asteroid = _create_asteroid(asteroid_mesh);
	call_deferred("_add_asteroid", aster);
	return aster;

func _create_asteroid(asteroid_mesh: MS_CollisionMeshGroup = null) -> Asteroid:
	var aster: Asteroid = astreroid_scene.instantiate();
	if (asteroid_mesh):
		aster._collision_mesh_group = asteroid_mesh;
	else:
		var rand_mesh_idx := randi() % asteroid_meshes.size();
		aster._collision_mesh_group = asteroid_meshes[rand_mesh_idx];
	
	return aster;

func _add_asteroid(asteroid: Asteroid) -> void:
	# Need to be added within the navigation region
	spawn_parent_node.add_child(asteroid);
	asteroid_count += 1;
