@tool
class_name MarchingSquaresUtility
## Constants and utility functions for MarchingSquares algorithm

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
const TILE_SIZE = 16;
const HALF_TILE_SIZE = TILE_SIZE/2;
const BLOCK_DIVISION = 0.5;
const DOT_BUTTON_RADIUS = 2.0;
const ALL_CORNERS = 15 # 1111 in binary
const NO_CORNERS = 0 # 0000 in binary
const OFF_SCREEN = Vector2(-1.0, -1.0);

# Reduces the polygon to tile size in order to gather corners for full tiles involved in the polygon
# Returns a new Dictonary with the filtered samples
static func filter_corner_samples_by_polygon(
	polygon: PackedVector2Array,
	corner_samples: Dictionary[Vector2, float]
) -> Dictionary[Vector2, float]:
	var polygon_corner_tracker: Dictionary[Vector2, float] = {}
	
	return corner_samples.keys().reduce(
		func(tracker: Dictionary[Vector2, float], key: Vector2) -> Dictionary[Vector2, float]:
			if (Geometry2D.is_point_in_polygon(key, polygon)):
				tracker.set(key, corner_samples[key]);
				# Expand out to include all connected tiles
				for i in MarchingSquaresUtility.CORNERS.size():
					var center := key - MarchingSquaresUtility.CORNERS[i] * float(MarchingSquaresUtility.HALF_TILE_SIZE);
					# Gather all corners of connected tiles
					for j in MarchingSquaresUtility.CORNERS.size():
						MarchingSquaresUtility.for_each_corner(center, 
							func(corner: Vector2) -> void:
								if (!tracker.has(corner) && corner_samples.has(corner)):
									tracker.set(corner, corner_samples[corner]);
						);
	
			return tracker;,
		polygon_corner_tracker
	);
	
static func get_tile_index_from_corners(
	center: Vector2, 
	corner_samples: Dictionary[Vector2, float],
) -> int:
	var tile_index := 0;
	for i: int in MarchingSquaresUtility.CORNERS.size():
		var corner := center + MarchingSquaresUtility.CORNERS[i] * float(MarchingSquaresUtility.HALF_TILE_SIZE);
		if (!corner_samples.has(corner)):
			continue;
		
		tile_index += get_sample_int_from_vertex(corner, corner_samples) << i;
		
	return tile_index;
	
static func get_sample_int_from_vertex(
	corner_vector: Vector2, 
	corner_samples: Dictionary[Vector2, float]
) -> int:
	if (!corner_samples.has(corner_vector)): return 0;
	var corner_sample: float = corner_samples.get(corner_vector);
	return int(corner_sample > 0.0)

static func get_center_point_of_polygon(polygon_points: Array[Vector2]) -> Vector2:
	var cX := 0.0;
	var cY := 0.0;
	
	for point in polygon_points:
		cX += point.x;
		cY += point.y;
		
	return Vector2(cX / polygon_points.size(), cY / polygon_points.size())

static func get_position_tile_center_coord(mouse_position: Vector2) -> Vector2:
	var tile_pos := Vector2(floori(mouse_position.x / TILE_SIZE), floori(mouse_position.y / TILE_SIZE)); 
	var center := Vector2(tile_pos.x + BLOCK_DIVISION, tile_pos.y + BLOCK_DIVISION) * float(TILE_SIZE);

	return center;
		
static func get_position_tile_corner_coord(mouse_position: Vector2) -> Vector2:
	var center := get_position_tile_center_coord(mouse_position);
	
	for i: int in CORNERS.size():
		var corner := center + CORNERS[i] * float(HALF_TILE_SIZE);
		if (mouse_position.distance_to(corner) < HALF_TILE_SIZE):
			return corner;
			
	return OFF_SCREEN; # Off screen

static func count_positive_corners(corner_sampling: Dictionary[Vector2, float]) -> int:
	return corner_sampling.keys().reduce(
		func(count: int, corner: Vector2) -> int:
			if (corner_sampling[corner] > 0.0):
				count += 1;
			return count;, 0
	);

# Utility function to get normalized tile coordinates from viewport
static func for_each_tile(viewport_size: Vector2, callable: Callable) -> void:
	# Determine how many tiles will fit across X and Y
	var x_viewport_tiles := int(viewport_size.x/TILE_SIZE);
	var y_viewport_tiles := int(viewport_size.y/TILE_SIZE);
	
	for x: int in range(0, x_viewport_tiles):
		for y: int in range(0, y_viewport_tiles):
			var center := Vector2(x + BLOCK_DIVISION, y + BLOCK_DIVISION) * float(TILE_SIZE);
			callable.call(center);
			
static func for_each_corner(center: Vector2, callable: Callable) -> void:
	for i: int in CORNERS.size():
		var corner := center + CORNERS[i] * float(HALF_TILE_SIZE);
		callable.call(corner);
