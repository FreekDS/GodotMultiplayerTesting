extends Node

const DEFAULT_PORT = 21321
const MAX_CLIENTS = 10

const LOCAL_IP = '127.0.0.1'

var server = null
var client = null

var ip = LOCAL_IP

var upnp = null

func _ready():
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	get_tree().connect("connection_failed", self, "_connection_failed")
	get_tree().connect("network_peer_connected", self, "_player_connected")

func create_server():
	print("Creating server...")
	
	upnp = UPNP.new()
	var err = upnp.discover()

	if err != OK:
		push_error(str(err))
		return

	if upnp.get_gateway() and upnp.get_gateway().is_valid_gateway():
		upnp.add_port_mapping(DEFAULT_PORT, DEFAULT_PORT, "testje", "UDP")
		upnp.add_port_mapping(DEFAULT_PORT, DEFAULT_PORT, "testje", "TCP")
		print(upnp.query_external_address())
	
	server = NetworkedMultiplayerENet.new()
	server.create_server(DEFAULT_PORT, MAX_CLIENTS)
	get_tree().set_network_peer(server)


func join_server():
	print("Joining server")

	client = NetworkedMultiplayerENet.new()
	client.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(client)

func _connected_to_server():
	print("Connected succesfully")

func _server_disconnected():
	print("Server disconnected")
	reset_network_connection()

func _connection_failed():
	print("Connection failed")
	reset_network_connection()
	
func reset_network_connection():
	if get_tree().has_network_peer():
		get_tree().network_peer = null

func _player_connected(id):
	print("Player with id " + str(id) + " connected")
	
func _exit_tree():
	if upnp:
		upnp.delete_port_mapping(DEFAULT_PORT)
