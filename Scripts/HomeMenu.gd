extends CanvasLayer

@onready var suv = $Root/Vehicle/suv

@export var rotation_speed = 10.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	suv.rotate_y(deg_to_rad(rotation_speed * delta))
