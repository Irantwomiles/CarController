extends Node3D

@export var ball : RigidBody3D
@export var car_node : Node3D
@onready var camera_anchor = $"../suv/camera_anchor"

var direction = Vector3.FORWARD

var follow_point = Vector3.ZERO

func _physics_process(delta):
	
	follow_point = follow_point.lerp(ball.global_position, delta * 20)
	follow_point.y = ball.global_position.y
	
	var camera_position_goal = global_position.lerp(camera_anchor.global_position, delta * 4)
	var camera_vector = camera_position_goal - car_node.global_position
	
	camera_vector = camera_vector.limit_length(6)
	
	global_position = car_node.global_position + camera_vector
	
#	global_position = global_position.lerp(camera_anchor.global_position, delta * 4)
	look_at(follow_point)
#	var car_rot = car_node.global_transform.basis.get_rotation_quaternion()
#	var my_rot = global_transform.basis.get_rotation_quaternion()
#	var delta_rot = car_rot * my_rot.inverse()
#
#	var delta_axis = delta_rot.get_axis()
#	var delta_angle = delta_rot.get_angle()
#
#	if delta_angle > PI:
#		# TAU = 2 * PI
#		delta_angle -= TAU
#
#	if delta_axis.is_finite():
##		set_quaternion(my_rot.slerp(my_rot * delta_rot, delta * 20))
#		set_quaternion(my_rot * delta_rot)
