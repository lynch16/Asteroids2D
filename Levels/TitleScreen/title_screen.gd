class_name TitleScreen extends Level

@onready var start_button: AreaButton = $GameArea/StartButton;
@onready var options_button: AreaButton = $GameArea/OptionsButton;
@onready var controls_button: AreaButton = $GameArea/ControlsButton;
@onready var exit_button: AreaButton = $GameArea/ExitButton;
@onready var settings: Settings = $Settings;
@onready var controls_dialog: ControlsDialog = $ControlsDialog;
@onready var high_score_container: HBoxContainer = %HighScoreContainer;
@onready var high_score_value: Label = %HighScoreValue;

var dialog_open := false;

signal start();
signal exit_game();

func _ready() -> void:
	start_button.button_click.connect(_start);
	options_button.button_click.connect(_open_options);
	controls_button.button_click.connect(_open_controls_dialog);
	exit_button.button_click.connect(_exit_game);
	settings.on_close.connect(_close_options);
	settings._load();
	settings.center_in_viewport();
	controls_dialog.on_close.connect(_close_controls_dialog);
	controls_dialog.center_in_viewport();

	var high_score := ScoreManager.get_high_score();
	if (high_score > 0):
		high_score_container.show();
		high_score_value.text = str(high_score);

	super();

func _on_player_die(player: Player) -> void:
	player.queue_free();
	player_spawn.spawn_player(_on_player_die);

func _start() -> void:
	start.emit();

func _open_options() -> void:
	if (dialog_open): return;
	dialog_open = true;
	
	get_tree().paused = true;
	settings.open();

func _exit_game() -> void:
	exit_game.emit();
	
func _close_options() -> void:
	dialog_open = false;
	get_tree().paused = false;
	settings.close();

func _open_controls_dialog() -> void:
	if (dialog_open): return;
	dialog_open = true;
	controls_dialog.show();

func _close_controls_dialog() -> void:
	dialog_open = false;
	controls_dialog.hide();
