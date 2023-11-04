extends Area3D

signal updated_players_state

@export var check_point_name : String

@rpc("any_peer", "call_remote", "reliable")
func send_player_data_all_rpc(updatedState):
	GameManager.Players = updatedState
	
	var hud = get_tree().get_root().get_node("LevelScene/HUD")
	
	var text = ""
	for i in GameManager.Players:
		var player = GameManager.Players[i]
		text += player['name'] + " lap (" + str(player['current_lap']) + "/" + str(GameManager.GameState['LapCount']) + ") \n"
	
	hud.get_node("MarginContainer/Info").set_text(text)
	

@rpc("any_peer")
func validate_checkpoint_crossing_rpc(player_id, checkpoint_name):
	if not multiplayer.is_server():
		return
	
	if not GameManager.Players.has(player_id):
		print("[Server] could not find player " + str(player_id))
		return
	
	var player = GameManager.Players[player_id]
	
	print("[Server] checking if " + str(player_id) + " crossed the correct checkpoint")
	print("[Server] current: " + player["current_check_point"] + " next: " + player["next_check_point"] + " finished: " + str(player["finished"]))

	if player["finished"]:
		print("[Server] player " + str(player_id) + " has already finished")
		return
	
	if player["next_check_point"] == checkpoint_name:
		
		print("[Server] player " + str(player_id) + " has crossed the correct!")
		
		var all_checkpoints = GameManager.GameState["CheckPoints"]
		player["current_check_point"] = checkpoint_name
		var next_index = all_checkpoints.find(checkpoint_name, 0)
		
		print("[Server] current " + str(next_index) + " len " + str(len(all_checkpoints)))
		
		# If player has reached all checkpoints and is now finished, set their status to finished, otherwise update next_check_point
		if next_index >= len(all_checkpoints) - 1:
			
			
			player["current_lap"] += 1
			
			if player["current_lap"] == GameManager.GameState["LapCount"]:
				player["finished"] = true
				print("[Server] player " + str(player_id) + " has finished!")
			else:
				player["current_check_point"] = ""
				player["next_check_point"] = all_checkpoints[0]
				
				print("[Server] player " + str(player_id) + " has completed lap (" + str(player["current_lap"]) + "/" + str(GameManager.GameState["LapCount"]) + ")")
			
			send_player_data_all_rpc.rpc(GameManager.Players)
			send_player_data_all_rpc(GameManager.Players)
		
		else:
			print("[Server] updated player " + str(player_id) + " next checkpoint to " + all_checkpoints[next_index + 1])
			player["next_check_point"] = all_checkpoints[next_index + 1]
		
		print(GameManager.Players[player_id])

func _on_body_entered(body):
	# If the body.name == the current multiplayer id, that peer crossed the checkpoint
	if str(multiplayer.get_unique_id()) == body.name:
		print(str(multiplayer.get_unique_id()) + " has entered check point " + check_point_name)
		
		# Can't call rpc functions to your own rpc_id. This comes up if you are the server and calling rpc_id(1, ...)
		if multiplayer.is_server():
			validate_checkpoint_crossing_rpc(multiplayer.get_unique_id(), check_point_name)
		else:
			validate_checkpoint_crossing_rpc.rpc_id(1, multiplayer.get_unique_id(), check_point_name)
