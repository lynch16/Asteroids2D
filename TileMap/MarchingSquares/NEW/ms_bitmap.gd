class_name MS_Bitmap extends Resource

@export var bitmap_cells: Array[Array];
@export var bitmap_cutoff: float = 0.0;

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

	return bitmap_cells[x][y] || 0;

func _above_cutoff(val: float) -> bool:
	return val > bitmap_cutoff;

func shrink() -> void:
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

	bitmap_cells = new_cells;

	bitmap.resize(Vector2i(new_x_size, new_y_size));
	for x in range(new_x_size):
		for y in range(new_y_size):
			var cell_val: float = bitmap_cells[x][y];
			bitmap.set_bit(x, y, _above_cutoff(cell_val));


	
