class_name HUD
extends Node

@export var _debug_mode := false;

var viewport_size: Vector2;

@onready var debug_controls: Node = get_node("DebugHUD");
@onready var score_value: Label = get_node("RuntimeHUD/VBoxContainer/MarginContainer/HBoxContainer/Score_Value");
@onready var health_value: Label = get_node("RuntimeHUD/VBoxContainer/MarginContainer/HBoxContainer/Health_Value");
@onready var level_announce: Label = get_node("RuntimeHUD/BoxContainer/LevelAnnounce");
@onready var game_manager: GameManager = get_node("/root/GameManager");

var level_announce_fade_duration := 1.0;

func _ready() -> void:
	# Track viewport sizes and resizes
	_update_viewport_size();
	# Should update all menu sizes, not just viewport var
	get_viewport().size_changed.connect(_update_viewport_size);
	
	ScoreManager.score_updated.connect(_update_score_view);
	SignalBus.player_health_updated.connect(_update_health_view);
	game_manager.level_start.connect(_announce_level_start);
	
func _update_score_view(new_score: int) -> void:
	score_value.text = str(new_score);
	
func _update_health_view(new_health: int) -> void:
	health_value.text = str(new_health);

func _update_viewport_size() -> void:
	viewport_size = get_viewport().get_visible_rect().size;
	
func _configure_debug_screen() -> void:
	if (_debug_mode): 
		debug_controls.process_mode = Node.PROCESS_MODE_INHERIT;
	else:
		debug_controls.process_mode = Node.PROCESS_MODE_DISABLED;

func _announce_level_start(level_index: int) -> void:
	level_announce.text = "Level " + str(level_index + 1);
	level_announce.show();
	var tween := create_tween();
	# Tweens the alpha channel to 0.0 over the specified duration
	tween.tween_property(level_announce, "modulate:a", 0.0, level_announce_fade_duration)
	
	# Optional: Free the label or disable it once the fade is complete
	await tween.finished
	level_announce.hide();