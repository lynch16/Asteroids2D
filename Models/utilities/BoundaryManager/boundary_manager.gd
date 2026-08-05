class_name BoundaryManager
extends Node2D

@export var node: Node2D
@export var wrap_after_screen_enter := true;

var screen_buffer := 20.0;
var is_in_screen := false;
var allow_enter_screen_wait := 10.0;

func _enter_tree() -> void:
	get_tree().create_timer(allow_enter_screen_wait).timeout.connect(_force_in_screen);

func _physics_process(_delta: float) -> void:
	var screen_size := get_viewport_rect().size;
	if (is_in_screen):
		_wrap_node();
	else:
		if (node.global_position.x > 0 && node.global_position.x < screen_size.x && node.global_position.y > 0 && node.global_position.y < screen_size.y):
			is_in_screen = true;

func _wrap_node() -> void:
	var screen_size := get_viewport_rect().size;
	if (node.global_position.x < -screen_buffer):
		node.global_position.x = screen_size.x;
	elif (node.global_position.x > screen_size.x + screen_buffer):
		node.global_position.x = 0;
	
	if (node.global_position.y < -screen_buffer):
		node.global_position.y = screen_size.y;
	elif (node.global_position.y > screen_size.y + screen_buffer):
		node.global_position.y = 0;

func _force_in_screen() -> void:
	if (!is_in_screen):
		_wrap_node();
		is_in_screen = true;