class_name ScoreDamageResult
extends DamageResult

@export var score_value: int = 100;
@export var score_display_length: float = 2.0; # In seconds	
@export var score_movement_speed := Vector2(0, -50); # Pixels per second
@export var score_color := Color(137, 95, 251); # Purple
@export var score_font_size := 24;

var score_label: Label;
var score_timer: Timer;

func on_damage(_damage_dealt: float, _damager_node: Node, _hit_position: Vector2, _hit_angle: float) -> bool: 
	if (_damager_node && (_damager_node.is_in_group("player") || _damager_node.is_in_group("player_weapon"))):
		ScoreManager.add_score(score_value);
		var score_popup := ScorePopup.new();
		score_popup.score_value = score_value;
		score_popup.global_position = _hit_position;
		get_tree().current_scene.add_child(score_popup);

	return true;

func _release_score_label() -> void:
	if (score_label):
		score_label.queue_free();
	
	if (score_timer):
		score_timer.queue_free();
