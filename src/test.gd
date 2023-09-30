extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var vp = get_viewport()
	vp.use_xr = false
	
	var xri = XRServer.find_interface("OpenXR") as OpenXRInterface
	xri.uninitialize()
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if(Input.is_physical_key_pressed(KEY_D)):
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
	
	
	pass
