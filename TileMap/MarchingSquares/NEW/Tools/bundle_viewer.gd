@tool 
class_name BundleViewer extends Node2D

@export var bundle: MS_GenerativeBundle;
@export_tool_button("Update", "EditKey") var generate := _generate;

@onready var generator: MS_Generator = $MS_Generator;

func _generate() -> void:
	generator.generative_bundle = bundle;
	generator.generate();