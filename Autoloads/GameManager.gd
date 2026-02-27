extends Node

signal game_paused;

var paused: bool = false;

func pause(force_set_paused: Variant = null) -> void:
	if (force_set_paused != null):
		paused = force_set_paused;
	else:
		paused = !paused;
	_set_paused();
	
func _set_paused() -> void:
	print("Setting paused", paused);
	get_tree().paused = paused;
	game_paused.emit(paused);
