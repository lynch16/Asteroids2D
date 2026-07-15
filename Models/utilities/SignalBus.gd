extends Node

signal player_health_updated(new_health: int);

func _on_player_health_updated(new_health: int) -> void:
	emit_signal("player_health_updated", new_health);

signal player_energy_updated(new_energy: float);

func _on_player_energy_updated(new_energy: float) -> void:
	emit_signal("player_energy_updated", new_energy);