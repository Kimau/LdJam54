extends Node3D

var camDist = 0.0
var runes : Array[MagicRune] = []

@export var pulsePos : float = 0.0
@export var pulseAmplitude : float = 0.1
@export var pulseWidth : float = 0.1
const RUNE_PREFAB = preload("res://magic_rune.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var vp = get_viewport()
	vp.use_xr = false
	
	var xri = XRServer.find_interface("OpenXR") as OpenXRInterface
	xri.uninitialize()
	
	camDist = $Camera3D.global_position.length()
	
	for elem in [RuneMesh.Element.Fire,RuneMesh.Element.Air,RuneMesh.Element.Earth,RuneMesh.Element.Water,RuneMesh.Element.Neutral]:
		var r = RUNE_PREFAB.instantiate()
		self.add_child(r)
		
		r.element = elem
		r.makeRuneMesh()
		r.makeCollision()
		
		runes.append(r)
	
	runes[0].global_position = Vector3(-1.28, 0, 0)
	runes[1].global_position = Vector3(0,0,-1.28)
	runes[2].global_position = Vector3(0,0,+1.28)
	runes[3].global_position = Vector3(+1.28, 0, 0)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if(Input.is_physical_key_pressed(KEY_SPACE)):
		for r in runes:
			r.makeRuneMesh()
			r.makeCollision()
	
	for r in runes:
		r.global_rotate(Vector3.UP, 1 * delta)
		r.meshInst.set_instance_shader_parameter("uvpos", pulsePos)
		r.meshInst.set_instance_shader_parameter("amplitude", pulseAmplitude)
		r.meshInst.set_instance_shader_parameter("width", pulseWidth)
	
	pulsePos += delta
	if pulsePos > 2.0:
		pulsePos = 0

	
	if(Input.is_key_pressed(KEY_A)):
		$Camera3D.global_position += $Camera3D.quaternion * Vector3.RIGHT * delta
		$Camera3D.global_position = $Camera3D.global_position.normalized() * camDist
		$Camera3D.look_at(Vector3.ZERO)
		
	if(Input.is_key_pressed(KEY_D)):
		$Camera3D.global_position -= $Camera3D.quaternion * Vector3.RIGHT * delta
		$Camera3D.global_position = $Camera3D.global_position.normalized() * camDist
		$Camera3D.look_at(Vector3.ZERO)
		
		
	if(Input.is_key_pressed(KEY_W)):
		$Camera3D.global_position.y += delta *5
		$Camera3D.global_position = $Camera3D.global_position.normalized() * camDist
		$Camera3D.look_at(Vector3.ZERO)
	
	if(Input.is_key_pressed(KEY_S)):
		$Camera3D.global_position.y -= delta*5
		$Camera3D.global_position = $Camera3D.global_position.normalized() * camDist
		$Camera3D.look_at(Vector3.ZERO)
	pass
