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
