
extends "../object.gd"

var down = true

onready var sprite = get_node("../Sprite")
func _ready():
	pass


func init(pos, _down):
	.init(pos)
	if !_down:
		down = _down
		var rect = sprite.get_region_rect()
		rect.pos = Vector2(16, 0)
		sprite.set_region_rect(rect)
