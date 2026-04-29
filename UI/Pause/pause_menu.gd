class_name PauseMenu
extends Container

@onready var pause_button: Button = get_node("VBoxContainer/Unpause");

var paused: bool = false;

func _ready() -> void:
	pause_button.pressed.connect(_on_pause_button_pressed);

func _process(_delta: float) -> void:
	if (Input.is_action_just_pressed("pause")):
		_on_pause_button_pressed();

func _on_game_paused(is_paused: bool) -> void:
	if (is_paused):
		show();
	else:
		hide();

func _on_pause_button_pressed() -> void:
	pause();

func pause(force_set_paused: Variant = null) -> void:
	if (force_set_paused != null):
		paused = force_set_paused;
	else:
		paused = !paused;
	_set_paused();

func _set_paused() -> void:
	get_tree().paused = paused;
	_on_game_paused(paused)
