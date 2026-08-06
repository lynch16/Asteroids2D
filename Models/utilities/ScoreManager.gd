extends Node

signal score_updated(updated_score: int);
signal new_high_score(high_score: int);

const HS_SAVE_PATH := "user://high_score.tres";

var _score := 0;
var high_score: HighScoreResource;

var save_high_score_timer: Timer;

func _ready() -> void:
	if (ResourceLoader.exists(HS_SAVE_PATH)):
		var saved_score: HighScoreResource = ResourceLoader.load(HS_SAVE_PATH);
		if (saved_score):
			high_score = saved_score;
	else:
		high_score = HighScoreResource.new();

	save_high_score_timer = Timer.new();
	save_high_score_timer.wait_time = 1.0;
	save_high_score_timer.one_shot = true;
	save_high_score_timer.timeout.connect(_save_high_score);
	add_child(save_high_score_timer);

func add_score(score_increment: int) -> void:
	_score += score_increment;
	score_updated.emit(_score);

	if (_score > high_score.high_score):
		high_score.high_score = _score;
		_on_new_high_score();
	
func _reset_score() -> void:
	_score = 0;
	score_updated.emit(_score);

func _on_new_high_score() -> void:
	if (save_high_score_timer.is_stopped()):
		save_high_score_timer.start();

	new_high_score.emit(high_score.high_score);

func _save_high_score() -> void:
	var error := ResourceSaver.save(high_score, HS_SAVE_PATH);
	print("SAVED: ", error);
	if (error != OK):
		push_error("Failed to save game: " + error_string(error));

func get_high_score() -> int:
	return high_score.high_score;