@tool
class_name TileMapProcGen
extends Node2D

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
const NEXT_CHECK: PackedVector2Array = [
	Vector2.UP,
	Vector2.RIGHT,
	Vector2.DOWN,
	Vector2.LEFT
]
const TILE_SIZE = 32;
const HALF_TILE_SIZE = TILE_SIZE/2;
const BLOCK_DIVISION = 0.5;
const DOT_BUTTON_RADIUS = 2.0;
const ALL_CORNERS = 15 # 1111 in binary
const NO_CORNERS = 0 # 0000 in binary

func _get_position_tile_center_coord(mouse_position: Vector2) -> Vector2:
	var tile_pos := Vector2(floori(mouse_position.x / TILE_SIZE), floori(mouse_position.y / TILE_SIZE)); 
	var center := Vector2(tile_pos.x + BLOCK_DIVISION, tile_pos.y + BLOCK_DIVISION) * float(TILE_SIZE);

	return center;
		
func _get_position_tile_corner_coord(mouse_position: Vector2) -> Vector2:
	var center := _get_position_tile_center_coord(mouse_position);
	
	for i: int in CORNERS.size():
		var corner := center + CORNERS[i] * float(HALF_TILE_SIZE);
		if (mouse_position.distance_to(corner) < HALF_TILE_SIZE):
			return corner;
			
	return Vector2(-1.0, -1.0); # Off screen
	
func _calculate_weighted_vertex(center: Vector2, normalized_vertex: Vector2) -> Vector2:
	var is_edge := absf(normalized_vertex.x) + absf(normalized_vertex.y) == 1.0;
	var direction := Vector2.UP if normalized_vertex.x != 0.0 else Vector2.RIGHT;
			
	var vertex := normalized_vertex * float(HALF_TILE_SIZE) + center;
	#if (is_edge):
		#var corner_1 := vertex + direction * HALF_TILE_SIZE;
		#var corner_2 := vertex - direction * HALF_TILE_SIZE;
		#var value_1: float = corner_sample_tracker.get(corner_1);
		#var value_2: float = corner_sample_tracker.get(corner_2);
		#var weight := (value_1 + value_2)/(value_1 - value_2) / 2.0 + 0.5;
		#vertex = corner_1.lerp(corner_2, weight);
	
	return vertex;
		
# Utility function to get normalized tile coordinates from viewport
func _for_each_tile(callable: Callable) -> void:
	var viewport := get_viewport_rect().size;
	# Determine how many tiles will fit across X and Y
	var x_viewport_tiles := int(viewport.x/TILE_SIZE);
	var y_viewport_tiles := int(viewport.y/TILE_SIZE);
	
	for x: int in range(0, x_viewport_tiles):
		for y: int in range(0, y_viewport_tiles + 1):
			var center := Vector2(x + BLOCK_DIVISION, y + BLOCK_DIVISION) * float(TILE_SIZE);
			callable.call(center);
			
func _for_each_corner(center: Vector2, callable: Callable) -> void:
	for i: int in CORNERS.size():
		var corner := center + CORNERS[i] * float(HALF_TILE_SIZE);
		callable.call(corner);
