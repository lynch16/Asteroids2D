extends Node

signal player_health_updated(new_health: int);

func _on_player_health_updated(new_health: int) -> void:
	emit_signal("player_health_updated", new_health);

signal player_gold_updated(new_gold_count: int);
func on_player_gold_updated(new_gold_count: int) -> void:
	emit_signal("player_gold_updated", new_gold_count);
