extends Node

signal player_health_updated(new_health: int);

func _on_player_health_updated(new_health: int) -> void:
	print("EMIT: ", new_health);           
	emit_signal("player_health_updated", new_health);
