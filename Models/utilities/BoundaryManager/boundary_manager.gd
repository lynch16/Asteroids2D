extends Node2D

@export var node: Node2D

var screen_buffer := 20.0;

func _physics_process(_delta: float) -> void:
	var screen_size := get_viewport_rect().size;
	node.position.x = wrapf(node.position.x, -screen_buffer, screen_size.x + screen_buffer)
	node.position.y = wrapf(node.position.y, -screen_buffer, screen_size.y + screen_buffer)
