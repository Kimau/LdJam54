extends Node

@export var mat: Material
@export var points: Array[Vector3]
var mesh : RuneMesh


func make_new_rune(element : RuneMesh.Element) -> RuneMesh:
	mesh = RuneMesh.new()
	mesh.generate_rune(element)
	
	if mat == null:
		mat = StandardMaterial3D.new()
		mat.no_depth_test = true
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		mat.vertex_color_use_as_albedo = true
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.normal_enabled = false
		
	mesh.surface_set_material(0, mat)
	
	return mesh
