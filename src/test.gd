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

func makeRigidBody(rune : MeshInstance3D):
	var shapeArea : Area3D;
	var kids = rune.find_children("*", "Area3D")
	if kids.is_empty() or (kids[0] as Area3D == null):
		shapeArea = Area3D.new()
		rune.add_child(shapeArea)
		shapeArea.owner = rune
	else:
		shapeArea = kids[0]
		
	for k in shapeArea.get_children():
		shapeArea.remove_child(k)
		k.queue_free()
	
	var rm : RuneMesh = rune.mesh as RuneMesh
	
	var ball = SphereShape3D.new()
	ball.radius = 0.03
	var prevP = null
	for p in rm.runePoints:
		var c = CollisionShape3D.new()
		c.shape = ball
		shapeArea.add_child(c)
		c.owner = shapeArea
		c.position = p
		
		if prevP:
			var delta = p - prevP

			var cJoin = CollisionShape3D.new()
			var box = BoxShape3D.new()
			box.size = Vector3(delta.length(), 0.06, 0.06)
			cJoin.shape = box
			shapeArea.add_child(cJoin)
			cJoin.owner = shapeArea
			cJoin.position = (p + prevP) * 0.5
			
			var xAxis : Vector3 = delta.normalized()
			var yAxis : Vector3 = Vector3.RIGHT if xAxis.is_equal_approx(Vector3.UP) else Vector3.UP
			var zAxis : Vector3 = xAxis.cross(yAxis)
			
			cJoin.basis = Basis(xAxis, yAxis, zAxis)
		
		prevP = p


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if(Input.is_physical_key_pressed(KEY_SPACE)):
		$Fire.mesh = $SplineDraw.make_new_rune(RuneMesh.Element.Fire)
		$Air.mesh = $SplineDraw.make_new_rune(RuneMesh.Element.Air)
		$Earth.mesh = $SplineDraw.make_new_rune(RuneMesh.Element.Earth)
		$Water.mesh = $SplineDraw.make_new_rune(RuneMesh.Element.Water)
		$Neutral.mesh = $SplineDraw.make_new_rune(RuneMesh.Element.Neutral)
		
		makeRigidBody($Fire)
		makeRigidBody($Air)
		makeRigidBody($Earth)
		makeRigidBody($Water)
		makeRigidBody($Neutral)
			
		
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
