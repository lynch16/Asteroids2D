class_name AsteroidCollisionTester extends Node2D

@onready var ast1: Asteroid = $Asteroid;
@onready var ast2: Asteroid = $Asteroid2;

func _ready() -> void:
	ast2.velocity = Vector2.LEFT * 400;