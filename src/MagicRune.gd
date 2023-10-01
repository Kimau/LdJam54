extends Node3D

class_name MagicRune

@export var mat: Material
@export var element : RuneMesh.Element = RuneMesh.Element.Neutral
@export var runeMesh : RuneMesh
@onready var meshInst : MeshInstance3D = $MeshInstance3D
@onready var colArea : Area3D = $Area3D

var spellPrimed : bool = false
var pulsePos : float = 0.0
var spellLength = 1.0
var spellSpeed = 1.0
var spellLast = false
var colList = []
var extendToWorldPoint : Vector3 = Vector3.ZERO

const SPELL_SPEED = 3.0

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
	
	colArea.monitoring = false
	if not runeMesh:
		reroll()

func _process(delta: float) -> void:
	if spellPrimed:
		pulsePos += spellSpeed * delta 
		if pulsePos > 1.3:
			pulsePos = 0
			
		meshInst.set_instance_shader_parameter("uvpos", pulsePos)
		meshInst.set_instance_shader_parameter("amplitude", 0.03)
		meshInst.set_instance_shader_parameter("width", 0.09 / spellLength)
	elif spellLast:
		meshInst.set_instance_shader_parameter("uvpos", 1.0)
		meshInst.set_instance_shader_parameter("amplitude", 0.03)
		meshInst.set_instance_shader_parameter("width", 0.03 / spellLength)
	else:
		meshInst.set_instance_shader_parameter("uvpos", -1)
		meshInst.set_instance_shader_parameter("amplitude", 0)
		meshInst.set_instance_shader_parameter("width", 0)
	meshInst.set_instance_shader_parameter("extend", extendToWorldPoint)

func reroll():
	element = random_elem()
	make_rune_mesh()
	make_collision()
	
func random_elem() -> RuneMesh.Element:
	match(randi_range(0,4)):
		0: return RuneMesh.Element.Fire
		1: return RuneMesh.Element.Air
		2: return RuneMesh.Element.Earth
		3: return RuneMesh.Element.Water
	return RuneMesh.Element.Neutral

func make_rune_mesh():
	runeMesh = RuneMesh.new()
	runeMesh.generate_rune(element)
	runeMesh.surface_set_material(0, mat)
	runeMesh.surface_set_material(1, mat)
	meshInst.mesh = runeMesh
	spellLength = 0
	var prevP = Vector3.ZERO
	for p in runeMesh.runePoints:
		spellLength += (prevP - p).length()
		prevP = p
	spellSpeed = SPELL_SPEED / (spellLength + 0.01 + runeMesh.runePoints.size())

func get_bounds() -> AABB:
	var b : AABB = AABB()
	for p in runeMesh.runePoints:
		b = b.expand(p)
	return b;

func make_collision():
	for k in colArea.get_children():
		colArea.remove_child(k)
		k.queue_free()
	
	var ball = SphereShape3D.new()
	ball.radius = 0.03
	var prevP = null
	var skipFirst = true
	for p in runeMesh.runePoints:
		if skipFirst:
			skipFirst = false
			continue
		
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
			
			if(delta.is_equal_approx(Vector3.ZERO)):
				delta = Vector3.RIGHT
			
			var xAxis : Vector3 = delta.normalized()
			var yAxis : Vector3 = Vector3.UP
			var zAxis : Vector3 = xAxis.cross(yAxis)
			var newBasis = Basis(xAxis, yAxis, zAxis)
			if newBasis.determinant() == 0:
				yAxis = Vector3.RIGHT
				zAxis = xAxis.cross(yAxis)
				newBasis = Basis(xAxis, yAxis, zAxis)
			cJoin.basis = newBasis
		
		prevP = p

func spell_prime():
	spellPrimed = true
	colArea.monitoring = true
	pulsePos = 0

func spell_cast():
	spellPrimed = false
	spellLast = true
	colArea.monitoring = false
	
func get_start_point() -> Vector3:
	return global_transform * runeMesh.runePoints[0]

func get_start_dir() -> Vector3:
	var d = runeMesh.runePoints[1] - runeMesh.runePoints[0]
	return (global_transform * d).normalized()

func get_end_point() -> Vector3:
	return global_transform * runeMesh.runePoints[-1]

func get_end_dir() -> Vector3:
	var d = runeMesh.runePoints[-1] - runeMesh.runePoints[-2]
	return (global_transform * d).normalized()

func get_collisions() -> Array[Vector3]:
	var c : Array[Vector3] = []
	for col in colList:
		var colShape :Node3D= colArea.get_child(col.local_shape_index)
		c.append(colShape.global_position)
	return c

func _on_area_3d_area_shape_entered(area_rid: RID, area: Area3D, area_shape_index: int, local_shape_index: int) -> void:
	colList.append({
		"area_rid": area_rid,
		"area": area,
		"area_shape_index": area_shape_index,
		"local_shape_index": local_shape_index
	})
	
	DebugCanvas.debug("Area Col", "%d - %s" %[colList.size(), str(colList)])


func _on_area_3d_area_shape_exited(area_rid: RID, area: Area3D, area_shape_index: int, local_shape_index: int) -> void:
	colList.erase({
		"area_rid": area_rid,
		"area": area,
		"area_shape_index": area_shape_index,
		"local_shape_index": local_shape_index
	})
	
	DebugCanvas.debug("Area Col", "%d - %s" %[colList.size(), str(colList)])
