extends Node3D

class_name MagicRune

@export var mat: Material

@export var element : RuneMesh.Element = RuneMesh.Element.Neutral
@export var runeMesh : RuneMesh

@onready var meshInst : MeshInstance3D = $MeshInstance3D
@onready var colArea : Area3D = $Area3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if mat == null:
		mat = StandardMaterial3D.new()
		mat.no_depth_test = true
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		mat.vertex_color_use_as_albedo = true
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.normal_enabled = false
	
	if not runeMesh:
		reroll()


func reroll():
	element = random_elem()
	makeRuneMesh()
	makeCollision()
	
func random_elem() -> RuneMesh.Element:
	match(randi_range(0,4)):
		0: return RuneMesh.Element.Fire
		1: return RuneMesh.Element.Air
		2: return RuneMesh.Element.Earth
		3: return RuneMesh.Element.Water
	return RuneMesh.Element.Neutral

func makeRuneMesh():
	
	runeMesh = RuneMesh.new()
	runeMesh.generate_rune(element)
	runeMesh.surface_set_material(0, mat)
	meshInst.mesh = runeMesh
	
func makeCollision():
	for k in colArea.get_children():
		colArea.remove_child(k)
		k.queue_free()
	
	var ball = SphereShape3D.new()
	ball.radius = 0.03
	var prevP = null
	for p in runeMesh.runePoints:
		var c = CollisionShape3D.new()
		c.shape = ball
		colArea.add_child(c)
		c.owner = colArea
		c.position = p
		
		if prevP:
			var delta = p - prevP

			var cJoin = CollisionShape3D.new()
			var box = BoxShape3D.new()
			box.size = Vector3(delta.length(), 0.06, 0.06)
			cJoin.shape = box
			colArea.add_child(cJoin)
			cJoin.owner = colArea
			cJoin.position = (p + prevP) * 0.5
			
			var xAxis : Vector3 = delta.normalized()
			var yAxis : Vector3 = Vector3.RIGHT if xAxis.is_equal_approx(Vector3.UP) else Vector3.UP
			var zAxis : Vector3 = xAxis.cross(yAxis)
			
			cJoin.basis = Basis(xAxis, yAxis, zAxis)
		
		prevP = p
