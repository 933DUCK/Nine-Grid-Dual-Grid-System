class_name DoubleMapLayer extends TileMapLayer

@onready var view_map_layer: TileMapLayer = $"../ViewMapLayer"

enum TileType{
	Null,
	Dirt,
	Grass,
	Water,
}
# 方便获取类型的
const ATLAS_TO_TYPE := {
	Vector2i(0, 0): TileType.Dirt,
	Vector2i(1, 0): TileType.Grass,
	Vector2i(2, 0): TileType.Water,
}
# 四边+四角+中心
const NINE_CELLS : Array[Vector2i] = [
	Vector2i(-1,-1),Vector2i(0,-1),	Vector2i(1,-1),
	Vector2i(-1,0),	Vector2i(0,0),	Vector2i(1,0),
	Vector2i(-1,1),	Vector2i(0,1),	Vector2i(1,1),
]
# 四边		便于通过中心格获取四边坐标
const FOUR_SIDE : Array[Vector2i] = [
					Vector2i(0,-1),	#上边
	Vector2i(-1,0),						Vector2i(1,0),#左右边
					Vector2i(0,1),	#下边
]
# 四角		便于通过中心格获取四角坐标
const FOUR_ANGLE : Array[Vector2i] = [
	Vector2i(-1,-1),		Vector2i(1,-1),	# 左上角 右上角

	Vector2i(-1,1),			Vector2i(1,1),	# 左下角 右下角
]

func _ready() -> void:
	for coord : Vector2i in get_used_cells(): # 遍历 已生成数据格
		set_display_tile(coord)


# 设置显示格
func set_display_tile(coord : Vector2i) -> void:
	var pos = get_view_pos(coord)		# 数据格 对应 显示格中心坐标
	var type = get_tile_type(coord)		# 获取 数据格 类型
	
	calculate_display_tile_CENTER(pos,coord, type)	# 计算显示 中心块 的纹理
	calculate_display_tile_SIDE(pos,coord, type)	# 计算显示 边 的纹理
	calculate_display_tile_ANGLE(pos,coord, type)	# 计算显示 角的纹理


		
# 获取 数据格 对应 显示格中心坐标
func get_view_pos(pos : Vector2i) -> Vector2i:
	return Vector2i(4 * pos.x + 1, 4 * pos.y + 1)

# 获取 显示格中心 对应 数据格坐标
func get_char_pos(pos : Vector2i) -> Vector2i:
	var re_pos : Vector2i
	re_pos = Vector2i(floor(pos.x - 1) / 4,floor(pos.y - 1) / 4 )
	return re_pos

# 获取 图块类型枚举
func get_tile_type(coord: Vector2i) -> TileType:
	var atlas_coords  = get_cell_atlas_coords(coord) # 图块种类：泥土(0,0)草(1,0)水(2,0)
	return ATLAS_TO_TYPE.get(atlas_coords, TileType.Null)
	
	
# 计算显示 中心块纹理
func calculate_display_tile_CENTER(pos : Vector2i,_coord : Vector2i ,type : TileType) -> void:
	view_map_layer.set_cell(pos, type, Vector2i(1,6))
	

# 计算显示 边 的纹理
func calculate_display_tile_SIDE(pos : Vector2i,coord : Vector2i,type : TileType) -> void:
	#  前四个是同类边图集坐标 后四个是异类相邻边图集坐标
	var tile : Array = [[Vector2i(1,0), Vector2i(0,1), Vector2i(4,1),Vector2i(1,4)],
						[Vector2i(1,5), Vector2i(0,6), Vector2i(4,6),Vector2i(1,9)]]
	for i in 4:
		var pos_side : Vector2i = pos + FOUR_SIDE[i]
		# 邻格同类
		if get_tile_type(coord + FOUR_SIDE[i]) == type:
			view_map_layer.set_cell(pos_side, type, tile[0][i])
		# 邻格不同类	
		else:
			view_map_layer.set_cell(pos_side, type, tile[1][i])
			
# 四个角格子的相对 对角 左 右 格子
const FOUR_ANGLE_R : = [
#相对位置		对角				左				右
	[Vector2i(-1,-1),Vector2i(-1,0),Vector2i(0,-1)],#左上角
	[Vector2i(1,-1),Vector2i(0,-1),Vector2i(1,0)],	#右上角
 	[Vector2i(-1,1),Vector2i(0,1),Vector2i(-1,0)],	#左下角
	[Vector2i(1,1),Vector2i(1,0),Vector2i(0,1)]	#右下角
]		
# 通过 相对的 对角 左 右 数据块类型 决定使用哪种角
func get_3_cell_type(coord : Vector2i,tile : Array,type : TileType)-> int:
	var three_cell_type : Array			#相对 对角 左 右 数据块类型
	for i in 3:
		var pos_angle : Vector2i = coord + tile[i]
		three_cell_type.append(get_tile_type(pos_angle))
	# 对角同类型
	if three_cell_type[0] == type:
		# 全是同类型
		if three_cell_type[1] == type and three_cell_type[2] == type:
			return 3	#返回平角
		# 两侧类型相同 但 优先值小于本身
		if (three_cell_type[1] == three_cell_type[2])and type <three_cell_type[1]:
			return 2	#返回内角
		# 两边任意
		else :
			return 1	#返回外角
	# 对角不同
	else :
		# 两边空
		if three_cell_type[1] ==  three_cell_type[2] :
			return 2	#返回内角
		# 两边任意
		else:
			return 3	#返回平角
			
# 计算显示 角 的纹理
func calculate_display_tile_ANGLE(pos : Vector2i,coord : Vector2i,type : TileType) -> void:
	var tile :Array[Array]= [
#相对位置		外角				内角				平角
		[Vector2i(5,0),Vector2i(5,2),Vector2i(5,4)],	#左上角
		[Vector2i(6,0),Vector2i(6,2),Vector2i(6,4)],	#右上角	
		[Vector2i(5,1),Vector2i(5,3),Vector2i(5,5)],	#左下角
		[Vector2i(6,1),Vector2i(6,3),Vector2i(6,5)]		#右下角
	]
	for i in 4:
		var pos_angle : Vector2i = pos + FOUR_ANGLE[i]
		var three_cell_type = get_3_cell_type(coord,FOUR_ANGLE_R[i],type)
		# 外角
		if three_cell_type == 1:
			view_map_layer.set_cell(pos_angle, type, tile[i][0])
		# 内角
		elif three_cell_type == 2:
			view_map_layer.set_cell(pos_angle, type, tile[i][1])
		# 平角
		elif three_cell_type == 3:
			view_map_layer.set_cell(pos_angle, type, tile[i][2])
		
	
