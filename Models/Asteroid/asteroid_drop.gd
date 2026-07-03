class_name AsteroidDrop extends Node2D

@export var pick_up_scene: PackedScene;

func create_pick_up() -> void:
	var new_pick_up: PickUp = pick_up_scene.instantiate();
	new_pick_up.global_position = global_position;
	new_pick_up.global_rotation = global_rotation;
	get_tree().get_root().add_child(new_pick_up);
