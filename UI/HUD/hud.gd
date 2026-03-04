extends Node

@export var _debug_mode := false;

var viewport_size: Vector2;

@onready var debug_controls: Node = get_node("DebugHUD");
@onready var score_value: Label = get_node("VBoxContainer/MarginContainer/HBoxContainer/Score_Value");

func _ready() -> void:
	# Track viewport sizes and resizes
	_update_viewport_size();
	# Should update all menu sizes, not just viewport var
	get_viewport().size_changed.connect(_update_viewport_size);
	
	ScoreManager.score_updated.connect(_update_score_view);
	
func _update_score_view(new_score: int) -> void:
	score_value.text = str(new_score);
	
func _update_viewport_size() -> void:
	viewport_size = get_viewport().get_visible_rect().size;
	
func _configure_debug_screen() -> void:
	if (_debug_mode): 
		debug_controls.process_mode = Node.PROCESS_MODE_INHERIT;
	else:
		debug_controls.process_mode = Node.PROCESS_MODE_DISABLED;
