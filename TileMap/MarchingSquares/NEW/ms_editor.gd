class_name MS_Editor extends Node2D 

@export_category("Source")
@export var bitmap: MS_Bitmap;
@export var canvas: MS_Canvas;

@export_category("Edit")
@export_range(0, 10, 1, "suffix:corners") var cursor_radius := 2;
@export_range(0.0, 1.0, 0.1) var cursor_strength := 0.5;
@export_enum("circle", "square") var cursor_shape := "circle";
@export var gradual_change := true;

@export_category("Save")
@export_custom(PROPERTY_HINT_NONE, "suffix:.tres") var file_name: String = "test";

@onready var save_button: Button = $SaveButton;
@onready var generate_button: Button = $GenButton;
@onready var generator: MS_Generator = $MS_Generator;

const FOLDER_NAME =  "res://TileMap/MarchingSquares/NEW/exports/";

func _ready() -> void:
	if (!bitmap):
		bitmap = MS_Bitmap.new();

	bitmap.resize(canvas.canvas_rect.size / canvas.tile_size);

	save_button.button_up.connect(save);
	generate_button.button_up.connect(generate);

func save() -> void:
	var bundle: MS_GenerativeBundle = MS_GenerativeBundle.new(
		canvas,
		bitmap
	);
	
	bundle.save(FOLDER_NAME + file_name + ".tres");

func generate() -> void:
	var bundle: MS_GenerativeBundle = MS_GenerativeBundle.new(
		canvas,
		bitmap
	);
	generator.generative_bundle = bundle;

	generator.shrink_to_size();
	generator.generate();

func _process(delta: float) -> void:
	if Input.is_action_pressed("left_click"):
		_handle_mouse_click(delta);
	elif Input.is_action_pressed("right_click"):
		_handle_mouse_click(delta, true);

	queue_redraw();

# Filters a Dictionary of corner samples to what is contained within the polygon
func _handle_mouse_click(delta: float, right_click: bool = false) -> void:
	var mouse_down_position := get_viewport().get_mouse_position();
	_for_points_in_cursor(mouse_down_position, _update_bitmap.bind(delta, right_click));

func _update_bitmap(bit_position: Vector2i, delta: float, remove: bool) -> void:
	var new_val := bitmap.get_cellv(bit_position);
	var cursor_change := cursor_strength * delta;
	if (remove):
		new_val -= cursor_change;
	else:
		new_val += cursor_change;

	if (!gradual_change):
		new_val = 0.0 if remove else 1.0;

	bitmap.set_cellv(bit_position, new_val);

## Iterates over all integer positions, executing callable on each position
func _for_points_in_cursor(cursor_position: Vector2, callable: Callable) -> void:
	if (!canvas.canvas_rect.has_point(cursor_position)):
		return;
		
	var tile_position := canvas.get_tile_position(cursor_position);

	for x in range(-cursor_radius, cursor_radius + 1):
		for y in range(-cursor_radius, cursor_radius + 1):
			if (cursor_shape == "circle" && (abs(x) + abs(y) > cursor_radius)):
				continue;

			var bit_pos := Vector2i(tile_position.x + x, tile_position.y + y);

			if (
				bit_pos.x > -1 &&
				bit_pos.x < canvas.get_max_x() && 
				bit_pos.y > -1 &&
				bit_pos.y < canvas.get_max_y()
			):
				callable.call(bit_pos);

# Draw dots at each vertex, colored whether the mouse is hovering
func _draw() -> void:
	draw_rect(canvas.canvas_rect, Color.AQUA, false);
	_draw_dots();
		
func _draw_dots() -> void:
	for x in bitmap.bitmap_cells.size():
		var row: Array = bitmap.bitmap_cells[x];
		
		for y in row.size():
			var value := bitmap.get_cell(x, y);

			if (value > 0):
				var color := Color.RED;
				color.a = value;
				draw_circle(canvas.get_canvas_pos_from_tile(Vector2i(x, y)), canvas.tile_size/2.0, color);
