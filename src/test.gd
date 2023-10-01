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
		r.make_rune_mesh()
		r.make_collision()
		r.spell_prime()
		
		runes.append(r)
	
	runes[0].global_position = Vector3(-1.28, 0, 0)
	runes[1].global_position = Vector3(0,0,-1.28)
	runes[2].global_position = Vector3(0,0,+1.28)
	runes[3].global_position = Vector3(+1.28, 0, 0)
	
	runes[4].spell_prime()
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if(Input.is_physical_key_pressed(KEY_SPACE)):
		for r in runes:
			r.make_rune_mesh()
			r.make_collision()
	
	for r in runes:
		r.global_rotate(Vector3.UP, 1 * delta)
	
	pulsePos += delta
	if pulsePos > 2.0:
		pulsePos = 0
		
	if(Input.is_key_pressed(KEY_I)):
		runes[4].global_position = runes[4].global_position.lerp(runes[0].global_position, delta)
	elif(Input.is_key_pressed(KEY_K)):
		runes[4].global_position = runes[4].global_position.lerp(runes[1].global_position, delta)
	elif(Input.is_key_pressed(KEY_J)):
		runes[4].global_position = runes[4].global_position.lerp(runes[2].global_position, delta)
	elif(Input.is_key_pressed(KEY_L)):
		runes[4].global_position = runes[4].global_position.lerp(runes[3].global_position, delta)
	else:
		runes[4].global_position = runes[4].global_position.lerp(Vector3.ZERO, delta*3.0)

	
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
