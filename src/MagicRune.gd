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
var colList = []

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
		meshInst.set_instance_shader_parameter("amplitude", 0.04)
		meshInst.set_instance_shader_parameter("width", 0.05)
	else:
		meshInst.set_instance_shader_parameter("uvpos", -1)
		meshInst.set_instance_shader_parameter("amplitude", 0)
		meshInst.set_instance_shader_parameter("width", 0)

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
	meshInst.mesh = runeMesh
	spellLength = 0
	var prevP = Vector3.ZERO
	for p in runeMesh.runePoints:
		spellLength += (prevP - p).length()
		prevP = p
	spellSpeed = SPELL_SPEED / (spellLength + 0.01 + runeMesh.runePoints.size())
	
func make_collision():
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
	colArea.monitoring = false


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
