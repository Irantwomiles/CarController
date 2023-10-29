extends VehicleBody3D


const MAX_STEER = 0.65
const ENGINE_POWER = 25
const MAX_TORQUE = 50
const MAX_RPM = 500

# Called when the node enters the scene tree for the first time.
func _ready():
	$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())
	
	$DebugLabel.visible = false
	
	if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		$CameraPosition.add_child(Camera3D.new())
		$BreakLights.visible = false
		$DebugLabel.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
	
		var steering_input = Input.get_axis("ui_right", "ui_left")
		var acceleration_input = Input.get_axis("ui_down", "ui_up")
		
		if acceleration_input >= 0:
			$BreakLights.visible = false
		elif acceleration_input == -1:
			$BreakLights.visible = true
			
		if acceleration_input == 0:
			$BackLeft.set_brake(2.5) 
			$BackRight.set_brake(2.5)
		
		steering = move_toward(steering, steering_input * MAX_STEER, delta * 1.5)
		
		var acceleration = acceleration_input * ENGINE_POWER
		var rpm = $BackLeft.get_rpm()
		
		$BackLeft.engine_force = acceleration * MAX_TORQUE * (1 - rpm / MAX_RPM)
		
		rpm = $BackRight.get_rpm()
		$BackRight.engine_force = acceleration * MAX_TORQUE * (1 - rpm / MAX_RPM)
		
		$DebugLabel.text = "L_RPM:" + str($BackLeft.get_rpm()) + " R_RPM:" + str($BackRight.get_rpm()) + "\n Friction:" + str($FrontRight.get_friction_slip())
