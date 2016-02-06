
extends Node

const WALKABLE = 0
const TYPE = 1

const TILE_WALL0 = 0
const TILE_WALL1 = 1
const TILE_FLOOR = 2
const TILE_OBJECT = 3

const WALL_UP_LEFT = 22
const WALL_UP_RIGHT = 44
const WALL_H_MIDDLE = 11
const WALL_V_MIDDLE = 27
const WALL_DOWN_LEFT = 33
const WALL_DOWN_RIGHT = 50

const DIR_LEFT = 2
const DIR_RIGHT = 0
const DIR_UP = 3
const DIR_DOWN = 1

const directions = [Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0), Vector2(0, -1)]
onready var navmap = Map.get_node("nav/TileMap")
var room_scn = preload("../map/base_room.tscn")
var door_scn = preload("../objects/dungeon/door.tscn")
var floor_tiles = [0, 8, 14, 20, 25, 31, 36, 42, 47]
var possible_floors = []
var map = {}
var rooms = []
var num_rooms = 0
var current_tunnel_tiles = []

func _ready():
	init_navmap()
	print(navmap.get_tileset().get_tiles_ids().size())
	generate_dungeon()
	pass

func init_navmap():
	for x in range(128):
		for y in range(128):
			 navmap.set_cell(x, y, 52)
func generate_dungeon():
	randomize()
	for x in range(0, 100, 15):
		for y in range(0, 100, 15):
			generate_room(x, y)
	print("rooms: ", num_rooms)
	#dig_tunnels()

func get_room(tile_pos):
	for i in range(rooms.size()):
		var id = rooms[i]["tiles"].find(tile_pos)
		if id != -1:
			return i
	print("error, couldn't find room for tile position: ", tile_pos)
	return -1

func dig_tunnels():
	var finished = false
	while !finished:
		
		var index = int(rand_range(0, possible_floors.size()))
		var pos = possible_floors[index]
		var room_id = get_room(pos)
		if room_id != -1:
			rooms[room_id]["has_door"] = true
		for dir in directions:
			if !map.has(pos + dir):
				print("can dig here")
				if dig_to(pos, dir):
					for tile in current_tunnel_tiles:
						var floor_type = floor_tiles[int(rand_range(0, floor_tiles.size()))]
						rooms[0]["node"].set_cell(tile.x, tile.y, floor_type)
						possible_floors.append(tile)
						print(tile.x, tile.y)
		finished = true
		for room in rooms:
			if !room["has_door"]:
				finished = false
				break
	pass

func dig_to(pos, dir):
	var ret = false
	current_tunnel_tiles = []
	for i in range(30):
		var tile = pos + dir * i
		print("try tile ", tile)
		if map.has(tile):
			var type = map[tile][TYPE]
			print("type is :", type)
			if type == TILE_WALL0:
				ret = true
				rooms[get_room(tile)]["has_door"] = true
			#if type == TILE_WALL1:
		else:
			current_tunnel_tiles.append(tile)
	if !ret:
		current_tunnel_tiles = []
	return ret

func generate_room(pos_x, pos_y):
	var room = room_scn.instance()
	var pos_x_global = 0 + pos_x * 24
	var pos_y_global = 0 + pos_y * 24
	var _x = int(rand_range(5, 15))
	var _y = int(rand_range(5, 15))
	var rect = Rect2(pos_x_global, pos_y_global, _x + 3, _y + 3)
	var room_tiles = []
	for x in range(_x):
		for y in range(_y):
			var tile = floor_tiles[int(rand_range(0, floor_tiles.size()))]
			var tile_pos = Vector2(pos_x + x, pos_y + y)
			var walkable = true
			var type = TILE_FLOOR
			if (x == 0 and y == 0):
				tile = WALL_UP_LEFT
				walkable = false
				type = TILE_WALL1
			if ((x == 0 or x == _x-1) and y < _y -1 and y != 0):
				tile = WALL_V_MIDDLE
				possible_floors.append(tile_pos)
				walkable = false
				type = TILE_WALL0
				if x == 0:
					room_tiles.append({"pos":tile_pos, "dir":DIR_LEFT})
				else:
					room_tiles.append({"pos":tile_pos, "dir":DIR_RIGHT})
			if (x == 0 and y == _y-1):
				tile = WALL_DOWN_LEFT
				walkable = false
				type = TILE_WALL1

			if (x == _x -1 and y == 0):
				tile = WALL_UP_RIGHT
				walkable = false
				type = TILE_WALL1
			if ((x != 0 and x < _x -1) and (y == 0 or y == _y-1)):
				tile = WALL_H_MIDDLE
				possible_floors.append(tile_pos)
				walkable = false
				type = TILE_WALL0
				if y == 0:
					room_tiles.append({"pos":tile_pos, "dir":DIR_UP})
				else:
					room_tiles.append({"pos":tile_pos, "dir":DIR_DOWN})
			if (x == _x-1 and y == _y-1):
				tile = WALL_DOWN_RIGHT
				walkable = false
				type = TILE_WALL1
			room.set_cell(x, y, tile)
			map[tile_pos] = {WALKABLE:walkable, TYPE:type}
	#var num_doors = int(rand_range(0, 3
	var rnd = randi() % 100
	var num_doors = 1
	if rnd > 65:
		num_doors = 2
		if rnd > 90:
			num_doors = 3
	print("num doors: ", num_doors)
	var sides = []
	for i in range(num_doors):
		var can_place = false
		var t_id
		while !can_place:
			t_id = int(rand_range(0, room_tiles.size()))
			if sides.find(room_tiles[t_id]["dir"]) == -1:
				can_place = true
		var door = door_scn.instance()
		Map.add_child(door)
		door.get_node("Object").init(room_tiles[t_id]["pos"])
		sides.append(room_tiles[t_id]["dir"])
		
	rooms.append({"node":room, "tiles":room_tiles, "has_door":false})
	num_rooms += 1
	Map.add_child(room)
	room.set_pos(Vector2(pos_x_global, pos_y_global))


