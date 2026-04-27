class_name ShipStats
extends Resource

@export var movement_stats: MovementStats;
@export var combat_stats: CombatStats;

func _init(
	p_movement_stats: MovementStats = MovementStats.new(),
	p_combat_stats: CombatStats = CombatStats.new(),
) -> void:
	movement_stats = p_movement_stats;
	combat_stats = p_combat_stats;
	
