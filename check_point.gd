extends Area3D

@export var check_point_name : String

@rpc("any_peer", "call_local", "unreliable_ordered")
func player_crossed_check_point_rpc(id):
	if GameManager.Players.has(id):
		GameManager.Players[id].finished = true
		print(str(multiplayer.get_unique_id()) + " - Updated " + str(id) + " to finished")

@rpc("any_peer", "call_local", "reliable")
func send_player_data_all_rpc(updatedState):
	GameManager.Players = updatedState

@rpc("any_peer")
func update_player_state_rpc(player_id, check_point_name):
	if multiplayer.is_server():
		if GameManager.Players.has(player_id):
			
			print("Found " + str(player_id) + " for " + check_point_name)
			
			var all_check_points = GameManager.GameState["CheckPoints"]
			var player = GameManager.Players[player_id]
			
			print(all_check_points)
			
			if player["finished"]:
				print("Player has already finished " + str(player_id))
				return
			
			if check_point_name != player["next_check_point"]:
				print("Crossed the wrong check point " + str(player_id))
				return
				
			var current_index = all_check_points.find(check_point_name, 0)
			
			print("current_index " + str(current_index))
			print(all_check_points.length())
			if current_index == (all_check_points.length() - 1):
				
				print("")
				
				player["current_lap"] += 1
				
				if player["current_lap"] >= GameManager.GameState["LapCount"]:
					player["finished"] = true
					player_crossed_check_point_rpc.rpc(player_id)
				else:
					print(str(player_id) + " has finished lap " + str(player["current_lap"] - 1))
			else:
				player["current_check_point"] = all_check_points[current_index]
				player["next_check_point"] = all_check_points[current_index + 1]
			
			send_player_data_all_rpc.rpc(GameManager.Players)
		else:
			print("Couldn't find player " + str(player_id))		

func _on_body_entered(body):
	print("body: " + body.name)
	if str(multiplayer.get_unique_id()) == body.name:
		print(str(multiplayer.get_unique_id()) + " has crossed check point " + check_point_name)
		update_player_state_rpc.rpc_id(1, multiplayer.get_unique_id(), check_point_name)
#		player_crossed_check_point_rpc.rpc(multiplayer.get_unique_id())
