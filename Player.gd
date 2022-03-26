extends KinematicBody

var moveSpeed : float = 10.0
var jumpForce : float = 10.0
var gravity : float = 15.0
var vel : Vector3 = Vector3()

var puppet_position = Vector3.ZERO
var puppet_velocity = Vector3.ZERO
var puppet_rotation = Vector3.ZERO

var timeDelta = 0

#export(NodePath) onready var camera = get_node(camera) as Camera
onready var camera = get_node("CameraOrbit")
onready var mesh = get_node("Skeleton/MeshInstance")
onready var dino = get_node("dino_tersogo")

export(NodePath) onready var movement_tween = get_node(movement_tween) as Tween

export(float, 0.001, 1) var tickRate = 0.03

func set_color(color):
	if not mesh.material_override:
		mesh.set_material_override(SpatialMaterial.new())
	mesh.material_override.albedo_color = color


puppet func initialize(color):
	if is_network_master():
		set_color(color)

func get_input() -> Vector3:
	if not is_network_master():
		return Vector3.ZERO
	var inp = Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		inp.z -= 1
	if Input.is_action_pressed("move_backward"):
		inp.z += 1
	if Input.is_action_pressed("move_left"):
		inp.x -= 1
	if Input.is_action_pressed("move_right"):
		inp.x += 1
	return inp.normalized()

func jump_pressed():
	if not is_network_master():
		return false
	return Input.is_action_pressed("jump") and is_on_floor()

func _physics_process(delta):
	timeDelta += delta
	
	if abs(vel.x) >= 0.1 or abs(vel.z) >= 0.1:
		dino.AnimationPlayer.play("walk this wae talk this wae")
	else:
#		print("he", vel)
		dino.AnimationPlayer.stop()
	
	vel.x = 0
	vel.z = 0
	
	var input = get_input()
	
	var dir = (transform.basis.z * input.z + transform.basis.x * input.x)
	vel.x = dir.x * moveSpeed
	vel.z = dir.z * moveSpeed
	
	vel.y -= gravity * delta
	
	if jump_pressed():
		vel.y = jumpForce
	
	if not is_network_master():
		
		global_transform.origin = puppet_position
		
		vel.x = puppet_velocity.x
		vel.z = puppet_velocity.z
		
		rotation.y = puppet_rotation.y
		camera.rotation.x = puppet_rotation.x
	
	if !movement_tween.is_active():
		vel = move_and_slide(vel, Vector3.UP)
		
	if timeDelta >= tickRate:
		_on_NetworkTickRate_timeout()
		timeDelta = 0
		
	if global_transform.origin.y < -100:
		global_transform.origin = Vector3(0, 15, 0)

# Puppet function: other players, not this one
puppet func update_state(p_pos, p_vel, p_rot):
	puppet_position = p_pos
	puppet_rotation = p_rot
	puppet_velocity = p_vel
	
	movement_tween.interpolate_property(
		self, "global_transform", global_transform,
		Transform(global_transform.basis, p_pos), 0.1
	)
	movement_tween.start()


func _on_NetworkTickRate_timeout():
	if is_network_master():
		rpc_unreliable("update_state", global_transform.origin, vel, Vector2(camera.rotation.x, rotation.y))

