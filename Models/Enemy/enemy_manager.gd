extends Node
## ENEMY MANAGER
## Manages spawning enemies in a formation and sets communication among them
# TODO: Get rid of singleton autoloads (can use regular nodes)


var enemy_scene := preload("uid://bhivcoamxxg4n");
var enemy_count := 0;
var spawn_parent_node: Node;

func set_spawn_parent_node(node: Node) -> void:
	spawn_parent_node = node;

func create_enemy() -> Enemy:
	var enemy: Enemy = enemy_scene.instantiate();
	spawn_parent_node.add_child(enemy);
	enemy_count += 1;
	return enemy;

func get_enemy_count() -> int:
	return enemy_count;

func _on_enemy_destroyed() -> void:
	enemy_count -= 1;
	
