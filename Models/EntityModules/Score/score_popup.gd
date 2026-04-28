class_name ScorePopup
extends Node2D

@export var score_value: int = 100;
@export var score_display_length: float = 2.0; # In seconds	
@export var score_movement_speed := Vector2(0, -50); # Pixels per second
@export var score_color := Color(137, 95, 251); # Purple
@export var score_font_size := 24;

var score_label: Label;
var score_timer: Timer;

func _enter_tree() -> void:
	score_label = Label.new();
	score_label.text = "+" + str(score_value);
	score_label.modulate = score_color;
	score_label.add_theme_font_size_override("font_size", score_font_size);	
	add_child(score_label);

	score_timer = Timer.new();
	score_timer.wait_time = score_display_length;
	score_timer.one_shot = true;
	score_timer.autostart = true;
	add_child(score_timer);

func _ready() -> void:
	score_timer.timeout.connect(Callable(self, "_queue_free"));
	score_timer.start();
func _process(delta: float) -> void:
	score_label.global_position += score_movement_speed * delta;
	if (score_timer.time_left <= score_display_length):
		var alpha := score_timer.time_left / score_display_length;
		score_label.modulate.a = alpha;
