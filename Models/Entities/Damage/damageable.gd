class_name Damageable
extends Node

@export var init_health := 100.0;

var curr_health := init_health;
var damage_result_states: Array[DamageResult];
var attached_node: Variant;

# TODO: Make destroy a regular damage result
signal on_destroy;

func _ready() -> void:
	var node_children = get_children();
	for child in node_children:
		if (child is DamageResult):
			damage_result_states.push_back(child as DamageResult);
	if on_destroy.get_connections().size() == 0:
		printerr("Damageable has no destroy action connected");

func _process(_delta:float) -> void:
	for damage_result in damage_result_states:
		damage_result.update(_delta);

func on_init(attached_object: Variant) -> void:
	attached_node = attached_object;
	
	for damage_result in damage_result_states:
		damage_result.on_init(attached_object);

func on_damage(damage_amount: float) -> void:
	curr_health -= damage_amount;

	for damage_result in damage_result_states:
		var check_next_result: bool = damage_result.on_damage(damage_amount);
			
		if !check_next_result:
			break;
			
	if (curr_health <= 0):
		on_destroy.emit();
