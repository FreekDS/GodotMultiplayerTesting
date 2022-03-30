extends Spatial

onready var PlayersNode = $Players

var player = preload("res://Player.tscn")

var players = {}

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	
	Global.connect("instance_player", self, "_instance_player")
	
	if get_tree().network_peer != null:
		Global.emit_signal("toggle_network_setup", false)
	print("jep, init")
	
	Global.emit_signal("instance_player", get_tree().get_network_unique_id())


func _player_connected(id):
	
	print("Player " + str(id) + " connected")
	_instance_player(id)
	rpc_id(id, "update_color", get_tree().get_network_unique_id(), Global.playerColor)


func _player_disconnected(id):
	print("Player " + str(id) + " disconnected")
	players.erase(id)
	if PlayersNode.has_node(str(id)):
		PlayersNode.get_node(str(id)).queue_free()



func _instance_player(id, color=null):
	
	print("Instance player with ID " + str(id))
	
	var player_instance = player.instance()
	player_instance.set_network_master(id)
	player_instance.name = str(id)
	
	PlayersNode.add_child(player_instance)
	
	if not color:
		player_instance.set_color(Global.playerColor)
	else:
		player_instance.set_color(color)
	
	player_instance.global_transform.origin = Vector3(0, 15, 0)
	
	players[id] = player_instance


remote func update_color(id, color):
	players[id].set_color(color)
	
	
	
