class_name CharacterWeapons
extends Node2D

@export var weapon_to_equip: PackedScene;

@onready var character: CharacterBody2D = get_parent();

var current_weapon: Weapon;

func _ready() -> void:
	if (weapon_to_equip):
		equip_weapon(weapon_to_equip);
	
func equip_weapon(weapon_scene: PackedScene) -> void:
	if (current_weapon):
		unequip_weapon();
		
	var new_weapon := weapon_scene.instantiate() as Weapon;
	current_weapon = new_weapon;
	add_child(current_weapon)
	current_weapon.global_position = global_position;
	current_weapon.owner_character = character;
	
	current_weapon.equip();
	
func unequip_weapon() -> void:
	if (!current_weapon):
		return;
	
	current_weapon.unequip();
	current_weapon.queue_free();
	current_weapon = null;
