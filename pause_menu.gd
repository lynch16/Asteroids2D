extends Container

@onready var pause_button: Button = get_node("VBoxContainer/Unpause");

func _ready() -> void:
	GameManager.game_paused.connect(_on_game_paused);
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
	GameManager.pause();
