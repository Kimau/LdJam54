extends Node3D

var camDist = 0.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var vp = get_viewport()
	vp.use_xr = false
	
	var xri = XRServer.find_interface("OpenXR") as OpenXRInterface
	xri.uninitialize()
	
	camDist = $Camera3D.global_position.length()
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if(Input.is_physical_key_pressed(KEY_SPACE)):
		$Fire.mesh = $SplineDraw.make_new_rune(RuneMesh.Element.Fire)
		$Air.mesh = $SplineDraw.make_new_rune(RuneMesh.Element.Air)
		$Earth.mesh = $SplineDraw.make_new_rune(RuneMesh.Element.Earth)
		$Water.mesh = $SplineDraw.make_new_rune(RuneMesh.Element.Water)
		$Neutral.mesh = $SplineDraw.make_new_rune(RuneMesh.Element.Neutral)
		
	$Fire.global_rotate(Vector3.UP, 1 * delta)
	$Air.global_rotate(Vector3.UP, 1 * delta)
	$Earth.global_rotate(Vector3.UP, 1 * delta)
	$Water.global_rotate(Vector3.UP, 1 * delta)
	$Neutral.global_rotate(Vector3.UP, 1 * delta)
	
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
