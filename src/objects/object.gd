
extends Node

const GRIDSIZE = 24

const UP = 0
const DOWN = 1
const LEFT = 2
const RIGHT = 3
export var player = false
onready var parent = get_parent()
var directions = [Vector2(0,-1), Vector2(0, 1), Vector2(-1, 0), Vector2(1, 0)]
var pos = Vector2()
var game_object
func move(dir):
	if player:
		pass
	parent.set_pos(parent.get_pos() + directions[dir] * GRIDSIZE)

func init(_pos):
	pos = _pos
	print(_pos)
	parent.set_pos(Vector2(0 + pos.x * 24, 0 + pos.y * 24))
	game_object = Game.map[pos]
	game_object[Game.TYPE] = Game.TILE_OBJECT
	game_object["Object"] = self

func _ready():
	if player:
		set_process_input(true)

func _input(event):
	if event.is_action("move_up") and !event.is_pressed():
		move(UP)
	elif event.is_action("move_down") and !event.is_pressed():
		move(DOWN)
	elif event.is_action("move_left") and !event.is_pressed():
		move(LEFT)
	elif event.is_action("move_right") and !event.is_pressed():
		move(RIGHT)

