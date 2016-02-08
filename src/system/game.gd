
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

const MAX_ROOM_SIZE = 15

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
var total_doors = 0

var start_ticks

func _ready():
	start_ticks = OS.get_ticks_msec()
	init_navmap()
	generate_dungeon(50, 50)
	call_deferred("dig_tunnels")

func init_navmap():
	for x in range(-30, 128):
		for y in range(-30, 128):
			 navmap.set_cell(x, y, 52)

func generate_dungeon(width, height):
	randomize()
	for x in range(0, width, MAX_ROOM_SIZE):
		for y in range(0, height, MAX_ROOM_SIZE):
			if y > height - MAX_ROOM_SIZE:
				generate_room(x, y, true)
			else:
				generate_room(x, y)

func make_tunnel(from, to):
	var grid_points = []
	var cur_pos = from
	var end = to
	var points = Map.get_node("nav").get_simple_path(from, to, false)
	var start_tile = Game.navmap.world_to_map(cur_pos)
	var end_tile = Game.navmap.world_to_map(to)
	var cur_tile = start_tile
	grid_points.append(start_tile)
	grid_points.append(end_tile)


	if Array(points).size() < 2:
		print("pathfinding error")
		return

	for i in range(1, points.size()):
		var p = points[i]
		var dist = abs(p.distance_to(cur_pos))
		if dist < 24:
			continue
		var dx = p.x - cur_pos.x
		var dy = p.y - cur_pos.y
		if abs(dx) > abs(dy):
			if dx > 0:
				cur_tile = cur_tile + Vector2(1, 0)
				cur_pos = cur_pos + Vector2(24, 0)
			else:
				cur_tile = cur_tile + Vector2(-1, 0)
				cur_pos = cur_pos + Vector2(-24, 0)
		else:
			if dy > 0:
				cur_tile = cur_tile + Vector2(0, 1)
				cur_pos = cur_pos + Vector2(0, 24)
			else:
				cur_tile = cur_tile + Vector2(0, -1)
				cur_pos = cur_pos + Vector2(0, -24)
		grid_points.append(cur_tile)
		var tile = floor_tiles[int(rand_range(0, floor_tiles.size()))]
		navmap.set_cell(cur_tile.x, cur_tile.y, tile)

func get_nearest_door(in_room, door_pos):
	var nearest_dist = 0
	var nearest_door
	for room in rooms:
		if room == in_room:
			continue
		for door in room["doors"]:
			if door["connected"]:
				continue
			var dist = abs(door_pos.distance_to(door["pos"]))
			if nearest_dist == 0 or dist < nearest_dist:
				nearest_dist = dist
				nearest_door = door

	nearest_door["connected"] = true
	return nearest_door

func dig_tunnels():
	var finished = false
	for room in rooms:
		for door in room["doors"]:
			if door["connected"]:
				continue
			var end_door = get_nearest_door(room, door["pos"])
			var start = navmap.map_to_world(door["pos"]) + Vector2(12,12)
			var end = navmap.map_to_world(end_door["pos"]) + Vector2(12, 12)
			make_tunnel(start, end)
	print("generated dungeon in ", OS.get_ticks_msec() - start_ticks, " ms")

func generate_room(pos_x, pos_y, last = false):
	var room = room_scn.instance()
	var pos_x_global = 0 + pos_x * 24
	var pos_y_global = 0 + pos_y * 24
	var width  = int(rand_range(5, 15))
	var height = int(rand_range(5, 15))

	var room_tiles = []
	var _x = width
	var _y = height

	var offset_x = int((15 - width) / 2)
	var offset_y = int((15 - height) / 2)

	for x in range(width):
		for y in range(height):
			var tile = floor_tiles[int(rand_range(0, floor_tiles.size()))]
			var tile_pos = Vector2(pos_x + offset_x + x, pos_y + offset_y + y)
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
			room.set_cell(offset_x + x, offset_y + y, tile)
			map[tile_pos] = {WALKABLE:walkable, TYPE:type}
			navmap.set_cell(pos_x + offset_x + x, pos_y + offset_y + y, -1)

	var rnd = randi() % 100
	var num_doors = 2
	if last:
		if (total_doors + 1) % 2 == 0:
			num_doors = 1
	elif rnd > 65:
		num_doors = 1
		if rnd > 90:
			num_doors = 3

	var sides = []
	total_doors += num_doors
	var doors = []
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
		doors.append({"pos":room_tiles[t_id]["pos"], "connected":false, "dir":room_tiles[t_id]["dir"]})

	rooms.append({"node":room, "tiles":room_tiles, "has_door":false, "doors":doors})
	num_rooms += 1
	Map.add_child(room)
	room.set_pos(Vector2(pos_x_global, pos_y_global))


