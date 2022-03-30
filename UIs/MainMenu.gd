extends Control

onready var tween: Tween = Tween.new()
onready var NormalMenu = $VBoxContainer
onready var MPMenu = $Multiplayer
onready var JoinButton = $Multiplayer/HBoxContainer/join_btn

export(PackedScene) var GameScene = preload("res://DEBUG.tscn")
export(PackedScene) var WorldScene = preload("res://World.tscn")


var _ip = ''
var ipChecker = RegEx.new()

func _ready():
	add_child(tween)
	ipChecker.compile("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}")
	JoinButton.disabled = true

func _on_HostButton_pressed():
	Network.create_server()
	get_tree().change_scene(WorldScene.resource_path)
	


func finalize_mp():
	print("Jep")
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	Global.emit_signal("instance_player", get_tree().get_network_unique_id())

func _on_ip_input_text_changed(new_text):
	_ip = new_text
	JoinButton.disabled = ipChecker.search(_ip) == null and _ip != 'localhost'


func _on_join_btn_pressed():
	Network.ip = _ip
	Network.join_server()
	get_tree().change_scene(WorldScene.resource_path)



func _on_back_btn_pressed():
	NormalMenu.visible = !NormalMenu.visible
	MPMenu.visible = !MPMenu.visible


func _on_sp_button_pressed():
	get_tree().change_scene(GameScene.resource_path)


func _on_mp_button_pressed():
	NormalMenu.visible = !NormalMenu.visible
	MPMenu.visible = !MPMenu.visible

func _on_exit_button_pressed():
	get_tree().quit()
