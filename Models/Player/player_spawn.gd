class_name PlayerSpawn
extends Node2D

@export var player_scene: PackedScene;
@export var spawn_delay := 1.0;

@onready var particles: GPUParticles2D = $GPUParticles2D;

signal player_spawned;


func spawn_player(on_player_die: Callable) -> void:
	var player: Player = player_scene.instantiate();
	player.player_died.connect(on_player_die);
	particles.emitting = true;
	get_tree().create_timer(spawn_delay).timeout.connect(_add_player.bind(player));
	
func _add_player(player: Player) -> void:
	add_child(player);
	player_spawned.emit();
