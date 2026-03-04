extends Node

signal game_start;
signal game_over;
signal game_paused;

var paused: bool = false;
var started: bool = false;

func on_start() -> void:
	started = true;
	game_start.emit();

func trigger_game_over() -> void:
	print("GAME OVER");
	game_over.emit();
	pause(true);

func pause(force_set_paused: Variant = null) -> void:
	if (force_set_paused != null):
		paused = force_set_paused;
	else:
		paused = !paused;
	_set_paused();

func _set_paused() -> void:
	get_tree().paused = paused;
	game_paused.emit(paused);
