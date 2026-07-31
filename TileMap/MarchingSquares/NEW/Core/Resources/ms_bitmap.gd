@tool 
class_name MS_Bitmap extends Resource

@export var bitmap_cutoff: float = 0.0;

## Only exported to make debugging in editor easier. Assignment is handled by class
@export var bitmap_cells: Array[Array];
var bitmap: BitMap;

func _init(
	p_bitmap_cells: Array[Array] = [],
) -> void:
	bitmap_cells = p_bitmap_cells;

	bitmap = BitMap.new();
	update_bitmap();

	resource_local_to_scene = true;

# region Core
func update_bitmap() -> void:
	var new_size := get_size();
	bitmap.resize(new_size);
	for x in range(new_size.x):
		for y in range(new_size.y):
			var cell_val: float = bitmap_cells[x][y];
			bitmap.set_bit(x, y, _above_cutoff(cell_val))

func _above_cutoff(val: float) -> bool:
	return val > bitmap_cutoff;

func set_cellv(pos: Vector2i, value: float) -> void:
	set_cell(pos.x, pos.y, maxf(minf(value, 1.0), 0.0));
	
func get_cellv(pos: Vector2i) -> float:
	return get_cell(pos.x, pos.y);

func set_cell(x: int, y: int, value: float) -> void:
	bitmap_cells[x][y] = value;
	bitmap.set_bit(x, y, _above_cutoff(value));

func get_cell(x: int, y: int) -> float:
	if (x > bitmap_cells.size() - 1):
		return 0;

	var row := bitmap_cells[x];
	if (!row): 
		return 0;

	if (y > bitmap_cells[x].size() - 1):
		return 0;

	return bitmap_cells[x][y];

func get_bitmap_cellv(pos: Vector2i) -> bool:
	return get_bitmap_cell(pos.x, pos.y);

func get_bitmap_cell(x: int, y: int) -> bool:
	return _above_cutoff(get_cell(x, y));

func get_size() -> Vector2i:
	var size_x := bitmap_cells.size();
	var size_y := bitmap_cells[0].size() if size_x > 0 else 0;
	return Vector2i(size_x, size_y);
	
# endregion

# region Sizing
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

func shrink(mutate: bool = true, min_max_position: Array[Vector2i] = get_min_max_positions()) -> Array[Array]:
	var min_pos := min_max_position[0];
	var max_pos := min_max_position[1];
	var new_x_size := max_pos.x - min_pos.x + 1;
	var new_y_size := max_pos.y - min_pos.y + 1;

	var new_cells: Array[Array];
	new_cells.resize(new_x_size);

	for x in range(new_x_size):
		new_cells[x] = [];
		new_cells[x].resize(new_y_size);
		new_cells[x].fill(0);
		for y in range(new_y_size):
			new_cells[x][y] = bitmap_cells[x + min_pos.x][y + min_pos.y];

	if (mutate):
		bitmap_cells = new_cells;
		update_bitmap();
	
	return new_cells;

func get_min_max_positions() -> Array[Vector2i]:
	var size := get_size();

	var min_x: int = size.x - 1;
	var min_y: int = size.y - 1;
	var max_x: int = 0;
	var max_y: int = 0;

	for x in range(size.x):
		for y in range(size.y):
			var val: float = bitmap_cells[x][y];
			if (_above_cutoff(val)):
				if (x < min_x):
					min_x = x;
				if (x > max_x):
					max_x = x;
				if (y < min_y):
					min_y = y;
				if (y > max_y):
					max_y = y;

	return [Vector2i(min_x, min_y), Vector2i(max_x, max_y)];
# endregion

# region Generate

## Create N collision polygons from the BitMap shape. [br]
## fidelity will adjust how accurately the shape matches the bitmap with lower numbers being more accurate but more expensive [br]
## cull_min_size is the Vector2i(width,height) minimums from which polygons will be culled [br]
func to_polygon_shapes(
	canvas: MS_Canvas, 
	fidelity: float = 2.0, 
	cull_min_size: Vector2i = Vector2(2, 2)
) -> Array[PackedVector2Array]:
	var collision_polygons := bitmap.opaque_to_polygons(
			canvas.canvas_rect,
			fidelity
		);

	var shapes: Array[PackedVector2Array] = [];

	for polygon in collision_polygons:
		var polygonRect := _get_polygon_rect2(polygon);

		if (polygonRect.size.x < cull_min_size.x || polygonRect.size.y < cull_min_size.y):
			continue;

		var resized_polygon := PackedVector2Array();
		for point in polygon:
			resized_polygon.append(
				Vector2(point.x * canvas.tile_size, point.y * canvas.tile_size)
			);

		shapes.append(resized_polygon);

	return shapes;

func _get_polygon_rect2(polygon: PackedVector2Array) -> Rect2:
	if polygon.is_empty():
		return Rect2()

	var rect := Rect2(polygon[0], Vector2.ZERO)
	for i in range(1, polygon.size()):
		rect = rect.expand(polygon[i])
	
	return rect;
		
func get_bitmap_from_polygon(polygon: PackedVector2Array, canvas: MS_Canvas) -> MS_Bitmap:
	var bitmap_size := get_size();
	var polygon_bitmap_cells: Array[Array] = bitmap_cells.duplicate_deep();

	for x in range(bitmap_size.x):
		for y in range(bitmap_size.y):
			var bit_pos := Vector2i(x, y);
			if (
				Geometry2D.is_point_in_polygon(bit_pos * canvas.tile_size, polygon)
			):
				polygon_bitmap_cells[x][y] = get_cell(x, y);
			else:
				polygon_bitmap_cells[x][y] = 0;

	var new_bitmap := MS_Bitmap.new(polygon_bitmap_cells);
	return new_bitmap;
# endregion

# region Collision

## Subtract a provided MS_Bitmap from this one
func _subtract(subtractive_bitmap: MS_Bitmap, subtractive_offset: Vector2i) -> Array[Array]:
	var subtractive_size := subtractive_bitmap.get_size();
	var this_size := get_size();
	var new_cells: Array[Array] = bitmap_cells.duplicate_deep();

	for x in range(subtractive_size.x):
		for y in range(subtractive_size.y):
			var associated_bit := Vector2i(subtractive_offset.x + x, subtractive_offset.y + y);
			if (
				associated_bit.x >= 0 &&
				associated_bit.y >= 0 &&
				associated_bit.x < this_size.x &&
				associated_bit.y < this_size.y &&
				get_bitmap_cellv(associated_bit)
			):
				var new_val: float = get_cellv(associated_bit) - subtractive_bitmap.get_cell(x, y)
				new_cells[associated_bit.x][associated_bit.y] = new_val;
				bitmap.set_bit(associated_bit.x, associated_bit.y, _above_cutoff(new_val));

	return new_cells;

func subtract(subtractive_bitmap: MS_Bitmap, subtractive_offset: Vector2i) -> void:
	bitmap_cells = _subtract(subtractive_bitmap, subtractive_offset);

# endregion	
