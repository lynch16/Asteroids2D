@tool
class_name MS_Generator extends Node2D

enum ShatterResult {
	Destroyed = 0,
	Updated = 1,
	Created = 2,
}

## Bundle to generate
@export var generative_bundle: MS_GenerativeBundle;
## Node where collisions will be attached
@export var collision_object: CollisionObject2D;
@export_tool_button("Generate", "EditKey") var gen := generate;

@onready var debugger: DebugBitmap = get_node_or_null("DebugBitmap");

signal generate_new(new_bundle: MS_GenerativeBundle);
signal degenerate();

var created_resources: Array[Node2D] = [];

func _ready() -> void:
	if (debugger):
		debugger.source_bitmap = generative_bundle.ms_bitmap;
		debugger.source_canvas = generative_bundle.ms_canvas;

## Treat all polygons as different parts of the same object
func generate() -> void:
	_clear_created_resources();

	var collision_polygons := _get_source_collision_polygons();

	if (collision_polygons.size() == 0):
		degenerate.emit();
		return;

	for polygon in collision_polygons:
		var collision := CollisionShape2D.new();
		collision.shape = polygon;
		collision_object.call_deferred("add_child", collision);
		created_resources.append(collision);

	var mesher := MS_Mesh.new(
		generative_bundle.ms_bitmap,
		generative_bundle.ms_canvas,
		generative_bundle.texture
	);

	var mesh_instance := mesher.create_mesh_instance();
	add_child(mesh_instance);
	created_resources.append(mesh_instance);

func shrink_to_size() -> void:
	generative_bundle.ms_bitmap.shrink();
	generative_bundle.ms_canvas.resize_to_bitmap(generative_bundle.ms_bitmap);

## Treat each polygon within the bitmap as a unique object [br]
## Need to hook up to regenerate to use the shattered objects
func shatter() -> ShatterResult:
	_clear_created_resources();

	var source_ms_bitmap := generative_bundle.ms_bitmap;
	var source_canvas := generative_bundle.ms_canvas;
	var collision_polygons := _get_source_collision_polygons();

	if (collision_polygons.size() == 0):
		degenerate.emit();
		return ShatterResult.Destroyed;

	## Create new resources with each polygon
	for i in collision_polygons.size():
		var polygon := collision_polygons[i];
		## Isolate a new bitmap and canvas for just this polygon
		var new_bitmap := source_ms_bitmap.get_bitmap_from_polygon(polygon, source_canvas);
		var new_canvas: MS_Canvas = source_canvas.duplicate(true);
		
		## Get min positions of new bitmap [br]
		## Use min to update the offset of the polygon points, 
		## essentially removing the dead space from around the polygon positioning
		var min_max_position := new_bitmap.get_min_max_positions()
		var min_pos: Vector2 = min_max_position[0] * new_canvas.tile_size;
		var shifted_points := PackedVector2Array();
		for point in polygon.points:
			shifted_points.append(point - min_pos);
		polygon.points = shifted_points;

		## Shrink the bitmap and canvas to just be the polygon too
		# new_bitmap.shrink(true, min_max_position);
		# new_canvas.resize_to_bitmap(new_bitmap);
		## Cant do this because then the pieces lose all context of where they fit into the whole

		new_bitmap.update_bitmap();

		var new_bundle := MS_GenerativeBundle.new(
			new_canvas,
			new_bitmap,
			generative_bundle.texture,
		);

		if (i == 0):
			generative_bundle = new_bundle;
			generate();
		else:
			generate_new.emit(new_bundle);

	return ShatterResult.Created if collision_polygons.size() > 0 else ShatterResult.Updated;

func _clear_created_resources() -> void:
	for child in created_resources:
		if (is_instance_valid(child)):
			child.call_deferred("queue_free");
	created_resources = [];

## Shrink bitmap and canvas to only what we will be using
## Convert bitmap to zero, one, or many polygons
func _get_source_collision_polygons() -> Array[ConvexPolygonShape2D]:
	generative_bundle.ms_bitmap.update_bitmap();
	return generative_bundle.ms_bitmap.to_polygon_shapes(generative_bundle.ms_canvas, 0.25);

func collide_with(subtractive_bitmap: MS_Bitmap, subtractive_bitmap_global_position: Vector2) -> void:
	var position_diff := subtractive_bitmap_global_position - global_position;
	var hit_tile_position := generative_bundle.ms_canvas.get_tile_position(position_diff);
	
	if (debugger):
		debugger.update_renders(
			subtractive_bitmap, 
			hit_tile_position,
		);

	generative_bundle.ms_bitmap.subtract(
		subtractive_bitmap,
		hit_tile_position,
	);

func _process(_delta: float) -> void:
	if (debugger):
		queue_redraw();

func _draw() -> void:
	if (debugger):
		_draw_rect();

func _draw_rect() -> void:
	if (generative_bundle):
		draw_rect(generative_bundle.ms_canvas.canvas_rect, Color.BLUE, false, 2.0);
