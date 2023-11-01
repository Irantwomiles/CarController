extends Node3D

@export var ball : RigidBody3D
@export var car_node : Node3D

var direction = Vector3.FORWARD

func _physics_process(delta):

	global_position = global_position.lerp(ball.global_position, delta * 20)
	var car_rot = car_node.global_transform.basis.get_rotation_quaternion()
	var my_rot = global_transform.basis.get_rotation_quaternion()
	var delta_rot = car_rot * my_rot.inverse()
	
	var delta_axis = delta_rot.get_axis()
	var delta_angle = delta_rot.get_angle()
	
	if delta_angle > PI:
		# TAU = 2 * PI
		delta_angle -= TAU
	
	if delta_axis.is_finite():
		set_quaternion(my_rot.slerp(my_rot * delta_rot, delta * 1))

func get_rotation_from_direction(look_direction : Vector3) -> Basis:
	look_direction = look_direction.normalized()
	var x_axis = look_direction.cross(Vector3.UP)
	return Basis(x_axis, Vector3.UP, -look_direction)
