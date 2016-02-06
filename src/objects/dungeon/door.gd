
extends "res://objects/object.gd"
var open = false

func use():
	if !open:
		open = true
		Game.map[pos][Game.WALKABLE] = true
		hide()

func init(_pos):
	.init(_pos)
	game_object[Game.WALKABLE] = false

func _ready():
	# Initialization here
	pass


