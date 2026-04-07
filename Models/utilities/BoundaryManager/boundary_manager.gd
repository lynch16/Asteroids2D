extends Node2D

@export var node: Node2D

func _physics_process(_delta: float) -> void:
	var screen_size := get_viewport_rect().size;
	node.position.x = wrapf(node.position.x, 0, screen_size.x)
	node.position.y = wrapf(node.position.y, 0, screen_size.y)
