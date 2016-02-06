
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"
const GRIDSIZE = 24

const UP = 0
const DOWN = 1
const LEFT = 2
const RIGHT = 3

var directions = [Vector2(0,-1), Vector2(0, 1), Vector2(-1, 0), Vector2(1, 0)]

func move(dir):
	set_pos(get_pos() + directions[dir] * GRIDSIZE)

func _ready():
	# Initialization here
	set_process_input(true)
	pass

func _input(event):
	if event.is_action("move_up") and !event.is_pressed():
		move(UP)
	elif event.is_action("move_down") and !event.is_pressed():
		move(DOWN)
	elif event.is_action("move_left") and !event.is_pressed():
		move(LEFT)
	elif event.is_action("move_right") and !event.is_pressed():
		move(RIGHT)
