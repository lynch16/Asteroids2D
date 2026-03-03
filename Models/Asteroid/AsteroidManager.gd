extends Node

# Responsible for spawning all Asteroids, including after collision when an asteroid "shatters"

var asteroid_scenes: Array[PackedScene] = [
	preload("uid://drhrxw7642nqd"), # Asteroid scene
	preload("uid://drhrxw7642nqd"), # Asteroid scene
	preload("uid://drhrxw7642nqd"), # Asteroid scene
];
var child_angle_spread := PI/12;

func spawn_asteroid(initial_aster: Asteroid = null) -> Asteroid:
	var child_num: int = 0 if initial_aster == null else initial_aster.child_number;
	var scene := asteroid_scenes[child_num];
	var aster: Asteroid = scene.instantiate();
	call_deferred("add_child", aster);
	
	# TEMP: Should be included in the scene details
	var new_scale := 1.0/(pow(2, child_num));
	
	# Smaller asteroid will shatter and destroy with half the force
	aster.shatter_limit_force_total = aster.shatter_limit_force_total * new_scale;
	aster.destroy_limit_force_total = aster.destroy_limit_force_total * new_scale;
	aster.child_number = child_num + 1;
	
	# TODO: Change sprites;
	var collision_shape: CircleShape2D = (aster.get_node("AsteroidCollision") as CollisionShape2D).shape;
	collision_shape.radius = collision_shape.radius * new_scale;
	
	var sprite: AnimatedSprite2D = aster.get_node("Sprite2D");
	sprite.scale = sprite.scale * new_scale;
	if (aster.child_number == 2):
		sprite.modulate = Color(200, 0, 150, 1);;
	elif (aster.child_number == 3):
		sprite.modulate = Color(0, 200, 150, 1);;
		
	
	return aster;
	
