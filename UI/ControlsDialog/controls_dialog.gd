class_name ControlsDialog
extends Node2D

@onready var close_button: AreaButton = $CloseButton;

signal on_close();

func _ready() -> void:
	close_button.button_click.connect(on_close.emit)

func center_in_viewport() -> void:
	var viewport := get_viewport_rect();

	var sprite: Sprite2D = $ContainerSprite;
	var sprite_rect := sprite.get_rect();

	global_position = Vector2((viewport.size.x - sprite_rect.size.x)/2, (viewport.size.y - sprite_rect.size.y)/2);
