extends Spatial

export var sensitivity = 30.0
var minLookAngle = -40.0
var maxLookAngle = 90

var mouseDelta = Vector2.ZERO
var mouseCaptured = false

onready var player = get_parent()


func _ready():
	if not Network.is_networked() or is_network_master():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		mouseCaptured = true


func _input(event):
	if Network.is_networked() and not is_network_master():
		return
	if event is InputEventMouseMotion:
		mouseDelta = event.relative
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			if mouseCaptured:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				mouseCaptured = false
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_LEFT:
			if not mouseCaptured:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				mouseCaptured = true


func handleMouseMovement(delta):
	if not mouseCaptured:
		return
	var rot = Vector2(mouseDelta.y, mouseDelta.x) * sensitivity * delta
	rotation_degrees.x -= rot.x
	rotation_degrees.x = clamp(rotation_degrees.x, minLookAngle, maxLookAngle)
	player.rotation_degrees.y -= rot.y
	mouseDelta = Vector2.ZERO


func _process(delta):
	handleMouseMovement(delta)
