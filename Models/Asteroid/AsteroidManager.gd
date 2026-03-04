extends Node

# Responsible for spawning all Asteroids, including after collision when an asteroid "shatters"

var asteroid_scenes: Array[PackedScene] = [
	preload("uid://drhrxw7642nqd"), # Asteroid scene
	preload("uid://drhrxw7642nqd"), # Asteroid scene
	preload("uid://drhrxw7642nqd"), # Asteroid scene
];
var child_angle_spread := PI/12;

func spawn_asteroid(initial_aster: Asteroid = null) -> Asteroid:
	var child_num: int = 0 if initial_aster == null else (initial_aster.child_number + 1);
	if (child_num >= asteroid_scenes.size()):
		return;
		
	var scene := asteroid_scenes[child_num];
	var aster: Asteroid = scene.instantiate();
	aster.child_number = child_num;

	call_deferred("add_child", aster);
	
	return aster;
	
