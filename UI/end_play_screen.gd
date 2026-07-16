class_name EndPlayScreen
extends Node2D

@onready var link_to_itch: TextureButton = %LinkButton;
@onready var quit_button: AreaButton = $QuitButton;
@onready var title_button: AreaButton = $TitleButton;

var hand_cursor: Texture = load("uid://bqcqhr7rjdhcm");
var pointer_cursor: Texture = load("uid://demtrt53ppmqh");

# TODO: Change cursor on hover over link to alert
func _ready() -> void:
	link_to_itch.pressed.connect(_open_itch);
	link_to_itch.mouse_entered.connect(_make_cursor_hand);
	link_to_itch.mouse_exited.connect(_make_cursor_pointer);

	quit_button.button_click.connect(get_tree().quit);
	title_button.button_click.connect(get_tree().reload_current_scene);

func _open_itch() -> void:
	OS.shell_open("https://brige.itch.io/rogue-asteroids");

func _make_cursor_hand() -> void:
	Input.set_custom_mouse_cursor(hand_cursor);

func _make_cursor_pointer() -> void:
	Input.set_custom_mouse_cursor(pointer_cursor);
