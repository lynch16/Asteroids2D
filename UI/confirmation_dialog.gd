class_name CustomConfirmationDialog
extends Node2D

@onready var yes_button: AreaButton = $YesButton;
@onready var cancel_button: AreaButton = $CancelButton;

signal confirm();
signal cancel();

func _ready() -> void:
	yes_button.button_click.connect(confirm.emit);
	cancel_button.button_click.connect(cancel.emit);