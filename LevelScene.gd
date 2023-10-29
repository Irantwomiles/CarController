extends Node3D

@export var PlayerScene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	var index = 0
	
	for i in GameManager.Players:
		var currentPlayer = PlayerScene.instantiate()
		currentPlayer.name = str(GameManager.Players[i].id)
		add_child(currentPlayer)
		
		for spawn in get_tree().get_nodes_in_group("SpawnPoints"):
			if spawn.name == str(index):
				currentPlayer.set_position(spawn.get_position())
				currentPlayer.set_rotation(spawn.get_rotation())
				
		index += 1
	
	#$GameTimer.start(15)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_game_timer_timeout():
	print("Timer hit 0")


@rpc("any_peer", "call_local", "unreliable_ordered")
func player_crossed_finish_line_rpc(id):
	if GameManager.Players.has(id):
		GameManager.Players[id].finished = true
		print(str(multiplayer.get_unique_id()) + " - Updated " + str(id) + " to finished")


func _on_finish_line_body_entered(body):
	if str(multiplayer.get_unique_id()) == body.name:
		player_crossed_finish_line_rpc.rpc(multiplayer.get_unique_id())
		
