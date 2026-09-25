class_name BoundaryManager
extends Node2D

@export var node: Node2D
@export var wrap_after_screen_enter := true;

var screen_buffer := 20.0;
var is_in_screen := false;
var allow_enter_screen_wait := 10.0;

var alternative_position_calculator: Callable;

func _enter_tree() -> void:
	get_tree().create_timer(allow_enter_screen_wait, false).timeout.connect(_force_in_screen);

func set_position_calculator(_p_calculator: Callable) -> void:
	alternative_position_calculator = _p_calculator;

func _physics_process(_delta: float) -> void:
	var screen_size := get_viewport_rect().size;
	if (is_in_screen):
		_wrap_node();
	else:
		if (node.global_position.x > 0 && node.global_position.x < screen_size.x && node.global_position.y > 0 && node.global_position.y < screen_size.y):
			is_in_screen = true;

func _wrap_node() -> void:
	var screen_size := get_viewport_rect().size;

	var current_position: Vector2 = node.global_position if alternative_position_calculator.is_null() else alternative_position_calculator.call();

	var node_position_offset: Vector2 = abs(node.global_position - current_position);

	if (current_position.x < -screen_buffer):
		node.global_position.x = screen_size.x + screen_buffer - 1 - node_position_offset.x;
	elif (current_position.x > screen_size.x + screen_buffer):
		node.global_position.x = node_position_offset.x - screen_buffer + 1;
	
	if (current_position.y < -screen_buffer):
		node.global_position.y = screen_size.y + screen_buffer - 1 - node_position_offset.y;
	elif (current_position.y > screen_size.y + screen_buffer):
		node.global_position.y = node_position_offset.y - screen_buffer + 1;

func _force_in_screen() -> void:
	if (!is_in_screen):
		_wrap_node();
		is_in_screen = true;