
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"
var points = []

func _ready():
	# Initialization here
	set_fixed_process(true)
	set_process_input(true)
	pass

func _input(event):
	if event.type == InputEvent.MOUSE_BUTTON and !event.is_pressed():
		update_path()

func update_path():
	# refresh the points in the path
	points = Map.get_node("nav").get_simple_path(get_global_pos() + Vector2(12,12), get_global_mouse_pos(), false)
	var tile = Game.navmap.world_to_map(get_global_mouse_pos())
	print("mouse at tile: ", Game.navmap.get_cell(tile.x, tile.y), " at pos: ", tile)
	print("oi: ", Game.navmap.map_to_world(Vector2(0, 0)), " ", Game.navmap.map_to_world(Vector2(1, 0)))
	# if the path has more than one point
	if points.size() > 1:
		update() # we update the node so it has to draw it self again
	#print("points: ", Array(points))

func _draw():
	# if there are points to draw
	for p in points:
		draw_circle(p - get_global_pos(), 4, Color(1, 0, 0))
			
