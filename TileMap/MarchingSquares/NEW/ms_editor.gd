class_name MS_Editor extends Node2D 

@onready var generator: MS_Generator = $MS_Generator;
@onready var ms_canvas_2d: MS_Canvas2D = $MS_Canvas2D;

func _ready() -> void:
	generator.source_canvas = ms_canvas_2d.canvas;
	generator.source_ms_bitmap = ms_canvas_2d.ms_bitmap;
