@tool
class_name BundleCollider extends Node2D

@export_tool_button("Reset", "EditKey") var clear := _clear;
@export_tool_button("Load", "EditKey") var generate := _generate;
@export_tool_button("Collide", "EditKey") var collider := _collide;

@onready var target_generator: MS_Generator = $TargetGenerator;
@onready var subtractive_generator: MS_Generator = $SubtractiveGenerator;
@onready var result_generator: MS_Generator = $ResultGenerator;


## TODO::::
	# Rewind collision efforts to make this tool work again

func _generate() -> void:
	_clear();

	target_generator.generate();
	subtractive_generator.generate();

func _collide() -> void:
	var children := target_generator.get_children();
	for child in children:
		child.queue_free();

	var position_diff := subtractive_generator.global_position - target_generator.global_position;
	var new_cells := target_generator.generative_bundle.ms_bitmap._subtract(
		subtractive_generator.generative_bundle.ms_bitmap,
		target_generator.generative_bundle.ms_canvas.get_tile_position(position_diff)
	);

	result_generator.generative_bundle = MS_GenerativeBundle.new(
		target_generator.generative_bundle.ms_canvas,
		MS_Bitmap.new(new_cells),
		target_generator.generative_bundle.texture,
	)

	target_generator.hide();
	subtractive_generator.hide();
	result_generator.generate();

func _clear() -> void:
	_clear_generator(target_generator);
	_clear_generator(subtractive_generator);
	_clear_generator(result_generator);
	target_generator.show();
	subtractive_generator.show();

func _clear_generator(generator: MS_Generator) -> void:
	var children := generator.get_children();
	for child in children:
		child.queue_free();