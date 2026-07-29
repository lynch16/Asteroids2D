extends Node
## Responsible for spawning all Asteroids, including after collision when an asteroid "shatters"


var asteroid_bundles: Array[AsteroidBundleWeight] = [];

var astreroid_scene := preload("uid://drhrxw7642nqd");
var asteroid_count := 0;
var spawn_parent_node: Node;

var asteroid_launcher: Array[AsteroidLaunch] = [];

signal asteroid_created();
signal asteroid_shattered();
signal asteroid_destroyed();

func _init() -> void:
	var script_path: String = get_script().resource_path;
	var folder_parts := script_path.split("/");
	folder_parts.remove_at(folder_parts.size() - 1);
	var folder_path := "/".join(folder_parts);
	var asteroid_mesh_dir := DirAccess.open(folder_path + "/AsteroidMesh");
	assert(asteroid_mesh_dir != null);

	for file: String in asteroid_mesh_dir.get_files():
		if (file.ends_with(".remap")):
			file = file.replace(".remap", "");

		var bundle := load(asteroid_mesh_dir.get_current_dir() + "/" + file);
		if (bundle is AsteroidBundleWeight):
			asteroid_bundles.append(bundle);

func _process(_delta: float) -> void:
	var asteroid_to_launch: AsteroidLaunch = asteroid_launcher.pop_front();
	if (asteroid_to_launch):
		var new_asteroid := spawn_asteroid(asteroid_to_launch.bundle);
		new_asteroid.global_position = asteroid_to_launch.launch_position;
		new_asteroid.velocity = asteroid_to_launch.launch_velocity;
		new_asteroid.global_rotation = asteroid_to_launch.launch_angle;

func set_spawn_parent_node(node: Node) -> void:
	spawn_parent_node = node;

func shatter_asteroid(initial_aster: Asteroid, bundle: MS_GenerativeBundle) -> void:
	var direction := randf_range(0, PI);
	var speed := initial_aster.velocity.length() * randf_range(0.5, 2.0);
	initial_aster.velocity = initial_aster.velocity.rotated(-direction);
	
	var asteroid_launch := AsteroidLaunch.new(
		bundle,
		initial_aster.global_position,
		Vector2(speed, 0).rotated(direction),
		initial_aster.global_rotation,
	)
	asteroid_launcher.append(asteroid_launch);
	asteroid_shattered.emit();

func spawn_asteroid(bundle: MS_GenerativeBundle = null) -> Asteroid:
	var asteroid: Asteroid = _create_asteroid(bundle);
	# Need to be added within the navigation region
	spawn_parent_node.add_child(asteroid);
	asteroid_count += 1;
	asteroid_created.emit();
	return asteroid;

func _create_asteroid(bundle: MS_GenerativeBundle) -> Asteroid:
	var asteroid: Asteroid = astreroid_scene.instantiate();
	if (bundle):
		asteroid.generative_bundle = bundle;
	else:
		var rng := RandomNumberGenerator.new();
		var weights := PackedFloat32Array()
		var meshes := asteroid_bundles.map(
			func (am: AsteroidBundleWeight) -> MS_GenerativeBundle: 
				weights.append(am.weight);
				return am.generative_bundle;
		)
		var rand_mesh_idx := rng.rand_weighted(weights);
		asteroid.generative_bundle = meshes[rand_mesh_idx];

	asteroid.asteroid_destroyed.connect(_on_asteroid_destroyed);
	
	return asteroid;

func get_asteroid_count() -> int:
	return asteroid_count;

func _on_asteroid_destroyed() -> void:
	asteroid_count -= 1;
	asteroid_destroyed.emit();
