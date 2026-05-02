class_name BoundaryManager
extends Node2D

@export var node: Node2D
@export var wrap_after_screen_enter := true;

var screen_buffer := 20.0;
var is_in_screen := false;
var allow_enter_screen_wait := 10.0;

func _enter_tree() -> void:
	var timer := Timer.new();
	timer.one_shot = true;
	timer.wait_time = allow_enter_screen_wait;
	timer.autostart = true;
	timer.timeout.connect(_force_in_screen)
	add_child(timer);

func _physics_process(_delta: float) -> void:
	var screen_size := get_viewport_rect().size;
	if (is_in_screen):
		_wrap_node();
	else:
		if (node.position.x > 0 && node.position.x < screen_size.x && node.position.y > 0 && node.position.y < screen_size.y):
			is_in_screen = true;

func _wrap_node() -> void:
	var screen_size := get_viewport_rect().size;
	node.position.x = wrapf(node.position.x, -screen_buffer, screen_size.x + screen_buffer)
	node.position.y = wrapf(node.position.y, -screen_buffer, screen_size.y + screen_buffer)

func _force_in_screen() -> void:
	if (!is_in_screen):
		_wrap_node();
		is_in_screen = true;