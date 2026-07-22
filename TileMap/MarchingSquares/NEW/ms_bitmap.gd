class_name MS_Bitmap extends Resource

@export var bitmap_cutoff: float = 0.0;
# @export var min_polygon_area: float = 4.0 * 4.0;

var bitmap_cells: Array[Array];
var bitmap: BitMap;

func _init(
	p_bitmap_cells: Array[Array] = [],
) -> void:
	bitmap_cells = p_bitmap_cells;

	bitmap = BitMap.new();
	var size_x := bitmap_cells.size();
	var size_y := bitmap_cells[0].size() if size_x > 0 else 0;
	bitmap.resize(Vector2i(size_x, size_y));
	for x in range(size_x):
		for y in range(size_y):
			var cell_val: float = bitmap_cells[x][y];
			bitmap.set_bit(x, y, cell_val >= bitmap_cutoff)

func resize(new_size: Vector2i) -> void:
	bitmap.resize(new_size);

	var size_x := bitmap_cells.size();
	var size_y := bitmap_cells[0].size() if size_x > 0 else 0;

	bitmap_cells.resize(new_size.x);
	for x in range(new_size.x):
		if (x >= size_x):
			bitmap_cells[x] = [];
			bitmap_cells[x].resize(new_size.y);
			bitmap_cells[x].fill(0);
			bitmap.set_bit_rect(Rect2(x, 0, new_size.y, 1), 0);
		else:
			bitmap_cells[x].resize(new_size.y);
			for y in range(new_size.y):
				if (y >= size_y):
					bitmap_cells[x][y] = 0;
					bitmap.set_bit(x, y, 0);

func get_size() -> Vector2i:
	var size_x := bitmap_cells.size();
	var size_y := bitmap_cells[0].size() if size_x > 0 else 0;
	return Vector2i(size_x, size_y);

func set_cellv(pos: Vector2i, value: float) -> void:
	set_cell(pos.x, pos.y, value);
	
func get_cellv(pos: Vector2i) -> float:
	return get_cell(pos.x, pos.y);

func set_cell(x: int, y: int, value: float) -> void:
	bitmap_cells[x][y] = value;
	bitmap.set_bit(x, y, _above_cutoff(value));

func get_cell(x: int, y: int) -> float:
	var row := bitmap_cells[x];
	if (!row): 
		return 0;

	return bitmap_cells[x][y];

func get_bitmap_cellv(pos: Vector2i) -> bool:
	return get_bitmap_cell(pos.x, pos.y);

func get_bitmap_cell(x: int, y: int) -> bool:
	return _above_cutoff(get_cell(x, y));

func _above_cutoff(val: float) -> bool:
	return val > bitmap_cutoff;

func shrink(mutate: bool = true) -> Array[Array]:
	var size := get_size();

	var min_x: int = size.x - 1;
	var min_y: int = size.y - 1;
	var max_x: int = 0;
	var max_y: int = 0;

	for x in range(size.x):
		for y in range(size.y):
			var val: float = bitmap_cells[x][y];
			if (val > 0):
				if (x < min_x):
					min_x = x;
				if (x > max_x):
					max_x = x;
				if (y < min_y):
					min_y = y;
				if (y > max_y):
					max_y = y;

	var new_x_size := max_x - min_x + 1;
	var new_y_size := max_y - min_y + 1;

	var new_cells: Array[Array];
	new_cells.resize(new_x_size);

	for x in range(new_x_size):
		new_cells[x] = [];
		new_cells[x].resize(new_y_size);
		new_cells[x].fill(0);
		for y in range(new_y_size):
			new_cells[x][y] = bitmap_cells[x + min_x][y + min_y];

	if (mutate):
		bitmap_cells = new_cells;

		bitmap.resize(Vector2i(new_x_size, new_y_size));
		for x in range(new_x_size):
			for y in range(new_y_size):
				var cell_val: float = bitmap_cells[x][y];
				bitmap.set_bit(x, y, _above_cutoff(cell_val));
	
	return new_cells;

func to_polygon_shapes(canvas: MS_Canvas, fidelity: float = 1.0) -> Array[ConvexPolygonShape2D]:
	var collision_polygons := bitmap.opaque_to_polygons(
			canvas.canvas_rect,
			fidelity
		);

	var shapes: Array[ConvexPolygonShape2D] = [];

	for polygon in collision_polygons:
		var convex_shape := ConvexPolygonShape2D.new();
		var resized_polygon := PackedVector2Array();
		for point in polygon:
			resized_polygon.append(
				Vector2(point.x * canvas.tile_size, point.y * canvas.tile_size)
			);

		convex_shape.set_point_cloud(resized_polygon);
		shapes.append(convex_shape);

	return shapes;

# func _is_polygon_too_small(polygon: PackedVector2Array) -> bool:
# 	var min_val: Vector2 = polygon[0];
# 	var max_val: Vector2 = polygon[0];

# 	for i in range(1, polygon.size()):
# 		var p := polygon[i];
# 		min_val.x = minf(min_val.x, p.x)
# 		min_val.y = minf(min_val.y, p.y)
# 		max_val.x = maxf(max_val.x, p.x)
# 		max_val.y = maxf(max_val.y, p.y)
	
# 	var polygon_rect := Rect2(min_val, max_val - min_val);
# 	return polygon_rect.get_area() < min_polygon_area;
