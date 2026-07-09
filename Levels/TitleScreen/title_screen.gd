class_name TitleScreen extends Level

@onready var start_button: AreaButton = $GameArea/StartButton;
@onready var options_button: AreaButton = $GameArea/OptionsButton;
@onready var exit_button: AreaButton = $GameArea/ExitButton;

signal start();
signal open_options();
signal exit_game();

func _ready() -> void:
	start_button.button_click.connect(_start);
	options_button.button_click.connect(_open_options);
	exit_button.button_click.connect(_exit_game);

	super();

func _on_player_die(player: Player) -> void:
	player.queue_free();
	player_spawn.spawn_player(_on_player_die);

func _start() -> void:
	start.emit();

func _open_options() -> void:
	open_options.emit();

func _exit_game() -> void:
	exit_game.emit();