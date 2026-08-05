extends Node
## ENEMY MANAGER
## Manages spawning enemies in a formation and sets communication among them


var enemy_scene := preload("uid://bhivcoamxxg4n");
var current_enemy_count := 0;
var total_enemy_count := 0;
var spawn_parent_node: Node;

signal enemy_created();
signal enemy_destroyed();

func set_spawn_parent_node(node: Node) -> void:
	spawn_parent_node = node;

func create_enemy() -> Enemy:
	var enemy: Enemy = enemy_scene.instantiate();
	enemy.name = "Enemy_" + str(total_enemy_count);
	spawn_parent_node.add_child(enemy);
	current_enemy_count += 1;
	total_enemy_count += 1;
	enemy_created.emit();
	return enemy;

func get_enemy_count() -> int:
	return current_enemy_count;

func _on_enemy_destroyed() -> void:
	current_enemy_count -= 1;
	enemy_destroyed.emit();
	
func reset_enemy_count() -> void:
	current_enemy_count = 0;