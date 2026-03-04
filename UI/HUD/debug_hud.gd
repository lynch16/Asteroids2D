extends Node

@onready var fps_value: Label = get_node("VBoxContainer/HBoxContainer/FPS_Value");
@onready var num_asteroids_value: Label = get_node("VBoxContainer/HBoxContainer/NumAsteroids_Value");

func _process(_delta: float) -> void:
	fps_value.text = str(Engine.get_frames_per_second());
	num_asteroids_value.text = str(AsteroidManager.asteroid_count);
