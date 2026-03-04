extends Node

signal score_updated(updated_score: int);

var _score := 0;

func _update_score(score_increment: int) -> void:
	_score += score_increment;
	score_updated.emit(_score);
	
func _reset_score() -> void:
	_score = 0;
	score_updated.emit(_score);
