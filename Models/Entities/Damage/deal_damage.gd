class_name DealDamage
extends Node

@export var damage_dealt: float = 0.0;

func damage(node: Node) -> void:
	if ("damageable" in node):
		var maybe_damageable: Variant = node.damageable;
		if (maybe_damageable is Damageable):
			var damageable: Damageable = maybe_damageable;
			damageable.on_damage(damage_dealt, get_parent());
