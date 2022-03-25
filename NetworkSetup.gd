extends Control


func _ready():
	Global.connect("toggle_network_setup", self, "_toggle_network_setup")


func _on_IPAddress_text_changed(new_text):
	Network.ip = new_text


func _on_Host_pressed():
	Network.create_server()
	hide()
	
	Global.emit_signal("instance_player", get_tree().get_network_unique_id())


func _on_Join_pressed():
	Network.join_server()
	hide()
	
	Global.emit_signal("instance_player", get_tree().get_network_unique_id())

func _toggle_network_setup(value):
	visible = value


func _on_ColorPicker_color_changed(color):
	Global.playerColor = color
