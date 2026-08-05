class_name LevelResource
extends Resource

@export_group("Rock ThrowerComponent Settings")
## How many rocks to seed the level with
@export var num_starting_rocks := 1; 
## How quickly to throw rocks during the game
@export var rock_throw_interval := 0.0; 
## How many rocks to throw during the game
@export var num_rocks_to_throw := 5; 
## How long to wait after the level starts to begin throwing rocks
@export var rock_thrower_start_delay := 10.0; 

@export_group("Enemy Settings")
@export var enemey_scene: PackedScene;
## How many enemies to spawn
@export var possible_num_enemies := Vector2i(0, 0);
## How long to wait before spawning enemies
@export var enemies_start_delay := 10.0;
## Hunters vs shoot at random place
@export var enemy_hunters := false;
## How many enemy groups to send
@export var enemy_group_count := 0;