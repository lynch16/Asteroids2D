class_name MS_Bitmap extends Resource

@export var bitmap_cells: Array[Array];

func resize(new_size: Vector2i) -> void:
	var size_x := bitmap_cells.size();
	var size_y := bitmap_cells[0].size() if size_x > 0 else 0;

	bitmap_cells.resize(new_size.x);
	for x in range(new_size.x):
		if (x >= size_x):
			bitmap_cells[x] = [];
			bitmap_cells[x].resize(new_size.y);
			bitmap_cells[x].fill(0);
		else:
			bitmap_cells[x].resize(new_size.y);
			for y in range(new_size.y):
				if (y >= size_y):
					bitmap_cells[x][y] = 0;

func set_pos_value(pos: Vector2i, value: float) -> void:
	set_cell_value(pos.x, pos.y, value);
	
func get_pos_value(pos: Vector2i) -> float:
	return get_cell_value(pos.x, pos.y);

func set_cell_value(x: int, y: int, value: float) -> void:
	bitmap_cells[x][y] = value;

func get_cell_value(x: int, y: int) -> float:
	var row := bitmap_cells[x];
	if (!row): 
		return 0;

	return bitmap_cells[x][y] || 0;
