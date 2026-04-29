extends Node
# Responsible for spawning all Asteroids, including after collision when an asteroid "shatters"
var asteroid_meshes: Array[MS_CollisionMeshGroup] = [];

var astreroid_scene := preload("uid://drhrxw7642nqd");
var child_angle_spread := PI/12;
var asteroid_count := 0;
var spawn_parent_node: Node;

var asteroid_launcher: Array[AsteroidLaunch] = [];

func _init() -> void:
	var script_path: String = get_script().resource_path;
	var folder_parts := script_path.split("/");
	folder_parts.remove_at(folder_parts.size() - 1);
	var folder_path := "/".join(folder_parts);
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
		new_asteroid.velocity = asteroid_to_launch.launch_velocity;
		new_asteroid.rotation = asteroid_to_launch.launch_angle;

func set_spawn_parent_node(node: Node) -> void:
	spawn_parent_node = node;

func shatter_asteroid(initial_aster: Asteroid, new_mesh: MS_CollisionMeshGroup) -> void:
	var direction := randf_range(0, PI);
	var speed := initial_aster.velocity.length() * randf_range(0.5, 2.0);
	initial_aster.velocity = initial_aster.velocity.rotated(-direction);
	
	var asteroid_launch := AsteroidLaunch.new(
		new_mesh,
		Vector2(speed, 0).rotated(direction),
		direction
	)
	asteroid_launcher.append(asteroid_launch);

func spawn_asteroid(asteroid_mesh: MS_CollisionMeshGroup = null) -> Asteroid:
	var aster: Asteroid = _create_asteroid(asteroid_mesh);
	call_deferred("_add_asteroid", aster);
	return aster;

func _create_asteroid(asteroid_mesh: MS_CollisionMeshGroup = null) -> Asteroid:
	var aster: Asteroid = astreroid_scene.instantiate();
	if (asteroid_mesh):
		aster.collision_mesh_group = asteroid_mesh;
	else:
		var rand_mesh_idx := randi() % asteroid_meshes.size();
		aster.collision_mesh_group = asteroid_meshes[rand_mesh_idx];

	aster.asteroid_destroyed.connect(_on_asteroid_destroyed);
	
	return aster;

func _add_asteroid(asteroid: Asteroid) -> void:
	# Need to be added within the navigation region
	spawn_parent_node.add_child(asteroid);
	asteroid_count += 1;

func get_asteroid_count() -> int:
	return asteroid_count;

func _on_asteroid_destroyed() -> void:
	asteroid_count -= 1;