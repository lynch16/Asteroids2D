class_name PauseMenu
extends Container

var paused: bool = false;

@onready var resume_button: SlideInButton = $ResumeButton;
@onready var quit_button: SlideInButton = $QuitButton;
@onready var options_button: SlideInButton = $OptionsButton;
@onready var settings_dialog: Settings = $Settings;
@onready var quit_dialog: CustomConfirmationDialog = $QuitDialog;

@export var pause_on_ready: bool = false;

var shake_tween: Tween;

signal on_show();
signal on_hide();

func _ready() -> void:
	resume_button.button_click.connect(on_resume_button);
	quit_button.button_click.connect(_show_quit_dialog);
	options_button.button_click.connect(_show_settings);

	settings_dialog.on_close.connect(on_resume_button);
	quit_dialog.confirm.connect(get_tree().quit);

	# Open options instead of cancel of quit
	quit_dialog.cancel.connect(_show_settings);

	if (pause_on_ready):
		start_monitoring();
		pause(true);
	else:
		stop_monitoring();

func start_monitoring() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS;

func stop_monitoring() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED;

func _process(_delta: float) -> void:
	if (Input.is_action_just_pressed("pause")):
		pause();

func _on_game_paused(is_paused: bool) -> void:
	if (is_paused):
		show();
		_show_settings();
		on_show.emit();
	else:
		hide();
		on_hide.emit();

func pause(force_set_paused: Variant = null) -> void:
	if (force_set_paused != null):
		paused = force_set_paused;
	else:
		paused = !paused;
	_set_paused();

func _set_paused() -> void:
	get_tree().paused = paused;
	_on_game_paused(paused);

	if (paused):
		resume_button.slide_in();
		quit_button.slide_in(0.1);
		options_button.slide_in(0.05);
	else:
		resume_button.slide_out();
		quit_button.slide_out(0.1);
		options_button.slide_out(0.05);

func on_resume_button() -> void:
	pause(false);

func _shake_menu(menu: Node2D) -> void:
	var random_shake := randf_range(-PI/24, PI/24);
	
	if (shake_tween && shake_tween.is_running()):
		shake_tween.kill();

	shake_tween = create_tween();
	shake_tween.tween_property(menu, "rotation", random_shake, 0.1);
	shake_tween.tween_property(menu, "rotation", -random_shake, 0.1);
	shake_tween.tween_property(menu, "rotation", 0, 0.1);

func _show_settings() -> void:
	settings_dialog.open();
	_shake_menu(settings_dialog);
	quit_dialog.hide();

func _show_quit_dialog() -> void:
	quit_dialog.show();
	_shake_menu(quit_dialog);
	settings_dialog.close();
