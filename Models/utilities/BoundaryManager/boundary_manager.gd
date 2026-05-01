extends Node2D

@export var node: Node2D
@export var wrap_after_screen_enter := true;

var screen_buffer := 20.0;
var is_in_screen := false;

func _physics_process(_delta: float) -> void:
	var screen_size := get_viewport_rect().size;
	if (is_in_screen):
		node.position.x = wrapf(node.position.x, -screen_buffer, screen_size.x + screen_buffer)
		node.position.y = wrapf(node.position.y, -screen_buffer, screen_size.y + screen_buffer)
	else:
		if (node.position.x > 0 && node.position.x < screen_size.x && node.position.y > 0 && node.position.y < screen_size.y):
			is_in_screen = true;