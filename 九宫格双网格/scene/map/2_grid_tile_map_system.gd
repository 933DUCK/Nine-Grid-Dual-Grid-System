@tool
class_name TwoGridTileMapSystem extends Node2D
@onready var view_map_layer: TileMapLayer = $ViewMapLayer
@onready var char_map_layer: DoubleMapLayer = $CharMapLayer

@export var char_tileset : TileSet :
	set(value):
		char_tileset = value
		_sync()

@export var view_tileset : TileSet :
	set(value):
		view_tileset = value
		_sync()

@export var block_size : int = 16

func _sync() -> void:
	if not is_inside_tree():
		return
	var cl := get_node_or_null("CharMapLayer") as TileMapLayer
	var vl := get_node_or_null("ViewMapLayer") as TileMapLayer
	if cl and cl.tile_set != char_tileset:
		cl.tile_set = char_tileset
	if vl and vl.tile_set != view_tileset:
		vl.tile_set = view_tileset
		

## 单元格大小
@export var cell_size = Vector2i(64, 64)

func to_cell_pos(screen_pos:Vector2):
	return floor(screen_pos / Vector2(cell_size))
	
# 更新点击位置及其一周
func update_9_cell(pos : Vector2i,type : DoubleMapLayer.TileType)-> void:
	if char_map_layer.get_tile_type(pos) == type:	#类型一样直接返回
		return
	char_map_layer.set_cell(pos,0,Vector2i(type-1,0))
	for i in char_map_layer.NINE_CELLS:
		var target_pos = pos + i
		char_map_layer.set_display_tile(target_pos)
	
func _input(event):
	if event is InputEventMouseButton and event.pressed:
		var mouse_pos = get_global_mouse_position() # 鼠标位置
		var target_pos : Vector2i = to_cell_pos(mouse_pos)   # 获取鼠标所在位置数据格坐标
		if event.button_index == MOUSE_BUTTON_LEFT:
			update_9_cell(target_pos,DoubleMapLayer.TileType.Dirt)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			update_9_cell(target_pos,DoubleMapLayer.TileType.Grass)
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			update_9_cell(target_pos,DoubleMapLayer.TileType.Water)
		
