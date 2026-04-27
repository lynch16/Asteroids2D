class_name ApplyDamageResult
extends DamageResult

func on_damage(dmg: float, _damager_node: Node) -> bool: 
	if (_damager_node.is_in_group("player")):
		ScoreManager.add_score(dmg);
	return true;
