@tool 
class_name MS_Canvas extends Resource
## Responsible for managing the size of the canvas and tile for proc gen
@export var canvas_rect: Rect2;
@export var tile_size: int;

const CORNER_NW = Vector2(-1,1);
const CORNER_NE = Vector2(1,1);
const CORNER_SE = Vector2(1,-1);
const CORNER_SW = Vector2(-1,-1);

const CORNERS: PackedVector2Array = [
	CORNER_NW,
	CORNER_NE,
	CORNER_SE,
	CORNER_SW,
];

func _init(
	p_canvas_rect: Rect2 = Rect2(),
	p_tile_size: int = 8
) -> void:
	canvas_rect = p_canvas_rect;
	tile_size = p_tile_size;

func get_tile_position(position: Vector2) -> Vector2i:
	return Vector2(roundi(position.x / tile_size), roundi(position.y / tile_size));

func get_max_x() -> int:
	return roundi(canvas_rect.size.x / tile_size)

func get_max_y() -> int:
	return roundi(canvas_rect.size.y / tile_size)

func get_canvas_pos_from_tile(tile_pos: Vector2i) -> Vector2:
	return Vector2(tile_pos.x * tile_size, tile_pos.y * tile_size);

func for_each_tile(callable: Callable) -> void:
	for x: int in range(0, get_max_x()):
		for y: int in range(0, get_max_y()):
			var center := Vector2(x + 0.5, y + 0.5) * float(tile_size);
			callable.call(center);

func resize(new_size: Vector2) -> void:
	canvas_rect.size = new_size;