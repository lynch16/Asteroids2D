class_name Damageable
extends Resource

var combat_stats: CombatStats;
var damage_result_states: Array[DamageResult];

static func get_damageable(_owner: Node) -> Damageable:
	var damageable: Damageable;
	var maybe_damageable: Variant = _owner.get("damageable");
	if (maybe_damageable is Damageable):
		damageable = maybe_damageable;
	
	return damageable;

func _init(p_combat_stats: CombatStats, p_damage_results: Array[DamageResult]) -> void:
	combat_stats = p_combat_stats;
	damage_result_states = p_damage_results;

func on_init() -> void:
	for damage_result in damage_result_states:
		damage_result.on_init(self);

func on_damage(damage_amount: float, damager_node: Node) -> void:
	for damage_result in damage_result_states:
		var check_next_result: bool = damage_result.on_damage(damage_amount, damager_node);
			
		if !check_next_result:
			break;
