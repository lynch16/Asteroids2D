class_name Damageable
extends Node

var combat_stats: CombatStats;
var damage_result_states: Array[DamageResult];
var initialized := false;

static func get_damageable_node(_owner: Node) -> Damageable:
	var damageable: Damageable;
	var maybe_damageable: Variant = _owner.get("damageable");
	if (maybe_damageable is Damageable):
		damageable = maybe_damageable;
	
	return damageable;

func _ready() -> void:
	var node_children := get_children();
	for child in node_children:
		if (child is DamageResult):
			damage_result_states.push_back(child as DamageResult);

func _process(_delta:float) -> void:
	for damage_result in damage_result_states:
		damage_result.update(_delta);

func on_init(_combat_stats: CombatStats) -> void:
	initialized = true;
	combat_stats = _combat_stats;
	for damage_result in damage_result_states:
		damage_result.on_init();

func on_damage(damage_amount: float, damager_node: Node) -> void:
	if (!initialized):
		printerr("Damageable node for " + owner.name + " never initialized");
	for damage_result in damage_result_states:
		var check_next_result: bool = damage_result.on_damage(damage_amount, damager_node);
			
		if !check_next_result:
			break;
