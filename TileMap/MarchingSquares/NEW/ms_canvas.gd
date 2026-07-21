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

# Draws a rectangle viewport
# Tracks hover and click
# Builds a bitmap as you click

# ## Tile centers are not used as bitmap coordinates so should not be used outside this resource
# func _get_tile_center_position(position: Vector2) -> Vector2:
# 	var tile_pos := get_tile_position(position)
# 	var center := Vector2(tile_pos.x + 0.5, tile_pos.y + 0.5) * float(tile_size);

# 	return center;

# func get_tile_corner_position(position: Vector2) -> Vector2:
# 	var center := _get_tile_center_position(position);

# 	for i: int in CORNERS.size():
# 		var corner := center + CORNERS[i] * float(tile_size/2.0);
# 		if (position.distance_to(corner) < tile_size/2.0):
# 			return corner;

# 	return MarchingSquaresUtility.OFF_SCREEN;

func get_tile_position(position: Vector2) -> Vector2i:
	return Vector2(roundi(position.x / tile_size), roundi(position.y / tile_size));

func get_max_x() -> int:
	return roundi(canvas_rect.size.x / tile_size)

func get_max_y() -> int:
	return roundi(canvas_rect.size.y / tile_size)

func get_canvas_pos_from_tile(tile_pos: Vector2i) -> Vector2:
	return Vector2(tile_pos.x * tile_size, tile_pos.y * tile_size);