extends Node

var IP_ADDRESS = "localhost"
var PORT = 8910
var MAX_CLIENTS = 10
var peer

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(playerConnected)
	multiplayer.peer_disconnected.connect(playerDisconnected)
	multiplayer.connected_to_server.connect(playerConnectedToServer)
	multiplayer.connection_failed.connect(playerConnectionFailed)

# Called on the server and all clients
func playerConnected(id):
	print("Player connected with id " + str(id))

# Called on the server and all clients
func playerDisconnected(id):
	print("Player disconnected with id " + str(id))

# Called only from clients
func playerConnectedToServer():
	print("Player connected to server with")
	send_player_information.rpc_id(1, "", multiplayer.get_unique_id())

# Called only from clients
func playerConnectionFailed():
	print("Player connection failed with id")


func _on_host_button_down():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CLIENTS)
	
	if error != OK:
		print("Cannot host: " + error)
		return
	
	multiplayer.set_multiplayer_peer(peer)
	send_player_information("", multiplayer.get_unique_id())
	print("Created server")


func _on_join_button_down():
	peer = ENetMultiplayerPeer.new()
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.set_multiplayer_peer(peer)
	

func _on_start_game_button_down():
	start_game.rpc()

@rpc("any_peer", "call_local")
func start_game():
	var scene = load("res://level_scene.tscn").instantiate()
	get_tree().root.add_child(scene)
	self.visible = false

@rpc("any_peer")
func send_player_information(name, id):
	if !GameManager.Players.has(id):
		GameManager.Players[id] = {
			"name": name,
			"id": id,
			"score": 0
		}
	
	if multiplayer.is_server():
		for i in GameManager.Players:
			send_player_information.rpc(GameManager.Players[i].name, i)
