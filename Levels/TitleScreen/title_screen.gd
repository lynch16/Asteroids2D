class_name TitleScreen extends Level

@onready var start_button: AreaButton = $GameArea/StartButton;
@onready var options_button: AreaButton = $GameArea/OptionsButton;
@onready var exit_button: AreaButton = $GameArea/ExitButton;
@onready var settings: Settings = $Settings;

var settings_open := false;

signal start();
signal exit_game();

func _ready() -> void:
	start_button.button_click.connect(_start);
	options_button.button_click.connect(_open_options);
	exit_button.button_click.connect(_exit_game);
	settings.on_close.connect(_close_options);
	settings._load();
	settings.center_in_viewport();

	super();

func _on_player_die(player: Player) -> void:
	player.queue_free();
	player_spawn.spawn_player(_on_player_die);

func _start() -> void:
	start.emit();

func _open_options() -> void:
	if (settings_open): return;
	settings_open = true;
	
	get_tree().paused = true;
	settings.open();

func _exit_game() -> void:
	exit_game.emit();
	
func _close_options() -> void:
	settings_open = false;
	get_tree().paused = false;
	settings.close();
